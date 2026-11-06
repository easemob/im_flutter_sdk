"""Composition failure tests; device and data providers are replaced at their boundaries."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]


class RunFlowTest(unittest.TestCase):
    def setUp(self):
        (ROOT / 'testing/tmp').mkdir(exist_ok=True)
        self.root = Path(tempfile.mkdtemp(prefix='composition-', dir=ROOT / 'testing/tmp'))
        scripts = self.root / 'testing/scripts'
        scripts.mkdir(parents=True)
        for name in ['run_flow', '_compat.sh']:
            shutil.copy(ROOT / 'testing/scripts' / name, scripts / name)
        (self.root / 'bin').mkdir()
        (self.root / 'testing/flows').mkdir()
        (self.root / 'testing/flows/case.yaml').write_text('name: fixture\n')
        self.env = dict(os.environ, PATH=str(self.root / 'bin') + os.pathsep + os.environ['PATH'],
                        FIXTURE=str(self.root))
        provider = '''#!/usr/bin/env python3
import json,os,sys
from pathlib import Path
root=Path(os.environ['FIXTURE']); stage=Path(sys.argv[0]).name
with (root/'calls').open('a') as f: f.write(stage+'\\n')
if os.environ.get('FAIL_STAGE')==stage: sys.exit(65)
run=root/'testing/tmp/test-run'
(run/('data.json' if stage=='prepare_data' else 'devices.json')).write_text('{}' if stage=='prepare_data' else '[]')
'''
        for name in ['prepare_data', 'setup_devices', 'collect_report']:
            p = scripts / name
            p.write_text(provider if name != 'collect_report' else '#!/bin/bash\nexit 0\n')
            p.chmod(0o755)
        dart = self.root / 'bin/dart'
        dart.write_text('''#!/usr/bin/env python3
import json,os,sys
from pathlib import Path
root=Path(os.environ['FIXTURE']); args=sys.argv
if 'roles' in args: print('alice,bob'); sys.exit(0)
stage='bind' if 'bind' in args else 'execute'
with (root/'calls').open('a') as f: f.write(stage+'\\n')
run=root/'testing/tmp/test-run'
if stage=='bind':
    for name in ['flow.yaml','global.json','agents.json']: (run/name).write_text('{}')
else:
    (run/'trace.jsonl').write_text('retained evidence\\n')
if os.environ.get('FAIL_STAGE')==stage: sys.exit(1)
''')
        dart.chmod(0o755)
        stop = self.root / 'testing/tools/runner/stop_devices.py'
        stop.parent.mkdir(parents=True)
        stop.write_text('''import os
from pathlib import Path
with (Path(os.environ['FIXTURE'])/'calls').open('a') as f: f.write('cleanup\\n')
''')

    def tearDown(self):
        shutil.rmtree(self.root)

    def run_case(self, failure=None):
        env = dict(self.env)
        if failure:
            env['FAIL_STAGE'] = failure
        result = subprocess.run(['/bin/bash', 'testing/scripts/run_flow', '--flow', 'case.yaml',
                                 '--platform', 'ios', '--run-id', 'test-run'],
                                cwd=self.root, env=env, capture_output=True, text=True, timeout=15)
        return result, (self.root / 'calls').read_text().splitlines()

    def test_data_failure_never_starts_devices(self):
        result, calls = self.run_case('prepare_data')
        self.assertEqual(result.returncode, 65, result.stderr)
        self.assertEqual(calls, ['prepare_data'])

    def test_binding_failure_never_executes_and_cleans_devices(self):
        result, calls = self.run_case('bind')
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertEqual(calls, ['prepare_data', 'setup_devices', 'bind', 'cleanup'])

    def test_execution_failure_preserves_code_and_evidence(self):
        result, calls = self.run_case('execute')
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertEqual(calls[-2:], ['execute', 'cleanup'])
        run = self.root / 'testing/tmp/test-run'
        self.assertTrue((run / 'trace.jsonl').exists())
        self.assertEqual(json.loads((run / 'exit.json').read_text())['exitCode'], 1)

    def test_success_uses_all_stages_and_cannot_reuse_run(self):
        result, calls = self.run_case()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(calls, ['prepare_data', 'setup_devices', 'bind', 'execute', 'cleanup'])
        repeated, _ = self.run_case()
        self.assertEqual(repeated.returncode, 65)


if __name__ == '__main__':
    unittest.main()
