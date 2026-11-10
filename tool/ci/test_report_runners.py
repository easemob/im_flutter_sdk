"""Exercise the real shell entrypoints with fake Flutter/devices, no SDK calls."""

import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

SOURCE = Path(__file__).resolve().parents[2]
FLUTTER = r'''#!/usr/bin/env python3
import json, os, pathlib, sys
if '--version' in sys.argv:
    print('Flutter 3.47.0')
    sys.exit(0)
if 'test' not in sys.argv:
    sys.exit(7 if os.environ.get('FAKE_PREPARE_FAIL') else 0)
destination = pathlib.Path(sys.argv[sys.argv.index('--file-reporter') + 1][5:])
if os.environ.get('FAKE_RETRY') and 'attempt-1.' in str(destination):
    destination.write_text('')
    print('0 tests passed.')
    sys.exit(1)
failed = os.environ.get('FAKE_FAIL_FIRST') and 'logged_in_base_test' in sys.argv[2]
events = [
  {'type': 'group', 'group': {'parentID': None, 'suiteID': 0, 'testCount': 1}},
  {'type': 'testStart', 'test': {'id': 1, 'suiteID': 0, 'name': 'FL-FAKE-001 reporting fixture'}, 'time': 0},
  {'type': 'testDone', 'testID': 1, 'result': 'failure' if failed else 'success', 'time': 12},
  {'type': 'done', 'success': not failed},
]
destination.write_text('\n'.join(json.dumps(e) for e in events))
print('synthetic reporter fixture; not SDK verification')
sys.exit(1 if failed else 0)
'''


class RunnerTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / 'tool/ci').mkdir(parents=True)
        (self.root / 'im_flutter_sdk/example').mkdir(parents=True)
        (self.root / 'im_flutter_sdk/pubspec.yaml').write_text('version: 5.1.0\n')
        for name in ('report.py', 'report.sh', 'nightly_local.sh', 'smoke_local.sh', 'run_android_emulator_test.sh', 'run_ios_simulator_test.sh'):
            shutil.copy(SOURCE / 'tool/ci' / name, self.root / 'tool/ci' / name)
        for name in ('tool/use_local_packages.sh', 'tool/ci/ensure_example_env.sh'):
            (self.root / name).write_text('#!/bin/bash\nexit 0\n')
        boot = self.root / 'tool/ci/boot_ios_simulator.sh'
        boot.write_text('#!/bin/bash\necho fake-ios-device\n')
        boot.chmod(0o755)
        config_writer = self.root / 'tool/ci/write_e2e_dart_defines.sh'
        config_writer.write_text('#!/bin/bash\nprintf "{}" > "$1"\nprintf "%s" "$1" > "$CONFIG_PATH_CAPTURE"\n')
        (self.root / 'bin').mkdir()
        for name, body in {'flutter': FLUTTER, 'adb': '#!/bin/bash\nexit 0\n',
                           'xcrun': '#!/bin/bash\nexit 0\n'}.items():
            command = self.root / 'bin' / name
            command.write_text(body)
            command.chmod(0o755)
        self.config = self.root / 'caller.json'
        self.config.write_text('{}')
        self.env = {**os.environ, 'PATH': str(self.root / 'bin') + os.pathsep + os.environ['PATH'],
                    'E2E_CONFIG_PATH': str(self.config)}
        self.env.pop('CI_REPORT_DIR', None)

    def run_script(self, name, *args):
        return subprocess.run(['bash', 'tool/ci/' + name, *args], cwd=self.root,
                              env=self.env, capture_output=True, text=True, timeout=25)

    def reports(self):
        return sorted((self.root / 'artifacts/ci').glob('*/report.json'))

    def test_nightly_failure_continues_all_batches_and_reports_cases(self):
        self.env['FAKE_FAIL_FIRST'] = '1'
        result = self.run_script('nightly_local.sh', 'android')
        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
        report = json.loads(self.reports()[0].read_text())
        self.assertEqual(report['knownTotal'], 5)
        self.assertEqual(report['counts']['passed'], 4)
        self.assertEqual(report['counts']['failed'], 1)
        self.assertEqual(len(report['batches']), 5)
        self.assertTrue(self.config.exists())

    def test_individual_suite_and_preparation_failure_both_report(self):
        result = self.run_script('run_android_emulator_test.sh', 'integration_test/test.dart', 'single.log')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.env['FAKE_PREPARE_FAIL'] = '1'
        result = self.run_script('run_android_emulator_test.sh', 'integration_test/test.dart', 'single.log')
        self.assertEqual(result.returncode, 7, result.stdout + result.stderr)
        values = [json.loads(path.read_text()) for path in self.reports()]
        self.assertEqual(len(values), 2)
        self.assertEqual(sorted(value['status'] for value in values), ['attention', 'passed'])

    def test_ios_retry_reports_history_without_doubling_cases(self):
        self.env['FAKE_RETRY'] = '1'
        result = self.run_script('run_ios_simulator_test.sh', 'integration_test/test.dart', 'ios.log')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        value = json.loads(self.reports()[0].read_text())
        self.assertEqual(value['knownTotal'], 1)
        self.assertEqual(value['counts']['passed'], 1)
        self.assertEqual(len(value['batches'][0]['attempts']), 2)
        self.assertTrue(value['batches'][0]['attempts'][0]['faults'])

    def test_generated_configuration_is_removed_after_reporting(self):
        self.env.pop('E2E_CONFIG_PATH')
        for key in ('APP_KEY', 'USER_ID', 'REST_API', 'CLIENT_ID', 'CLIENT_SECRET'):
            self.env['E2E_' + key] = 'report-test-fixture'
        self.env['CONFIG_PATH_CAPTURE'] = str(self.root / 'config-path.txt')
        result = self.run_script('nightly_local.sh', 'android')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        path = Path((self.root / 'config-path.txt').read_text())
        self.assertFalse(path.exists())
        self.assertEqual(json.loads(self.reports()[0].read_text())['counts']['passed'], 5)

    def test_smoke_device_precheck_failure_still_has_report(self):
        (self.root / 'bin/adb').write_text('#!/bin/bash\nexit 1\n')
        result = self.run_script('smoke_local.sh', 'android')
        self.assertEqual(result.returncode, 2, result.stdout + result.stderr)
        value = json.loads(self.reports()[0].read_text())
        self.assertEqual(value['unknownTotalBatches'], 1)
        self.assertEqual(value['status'], 'attention')


if __name__ == '__main__':
    unittest.main()
