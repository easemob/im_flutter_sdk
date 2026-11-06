"""Exercise the real preparation chain; replace only the network-facing make call."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]


class PrepareDataTest(unittest.TestCase):
    def setUp(self):
        (ROOT / 'testing/tmp').mkdir(exist_ok=True)
        self.run = Path(tempfile.mkdtemp(prefix='prepare-cli-', dir=ROOT / 'testing/tmp'))
        self.bin = self.run / 'bin'
        self.bin.mkdir()
        make = self.bin / 'make'
        make.write_text('''#!/usr/bin/env python3
import json, os, sys
from pathlib import Path
root = Path.cwd()
with Path(os.environ['PREPARE_TEST_CALLS']).open('a') as log:
    log.write(sys.argv[1] + '\\n')
if sys.argv[1] == 'config':
    sys.exit(0)
assert sys.argv[1] == 'env-gettoken', sys.argv
run_id = next(arg.split('=', 1)[1] for arg in sys.argv if arg.startswith('RUN_ID='))
out = root / 'testing/tmp' / run_id / 'main/environment.json'
out.parent.mkdir(parents=True)
out.write_text(json.dumps({'appKey': 'fake', 'accounts': [
    {'id': 'fake-a', 'token': 'fake-ta'}, {'id': 'fake-b', 'token': 'fake-tb'}]}))
''')
        make.chmod(0o755)
        self.env = dict(os.environ,
                        PATH=str(self.bin) + os.pathsep + os.environ['PATH'],
                        PREPARE_TEST_CALLS=str(self.run / 'make-calls'))

    def tearDown(self):
        shutil.rmtree(self.run)

    def prepare(self, *args):
        return subprocess.run(
            ['/bin/bash', 'testing/scripts/prepare_data', '--run-id', self.run.name, *args],
            cwd=ROOT, env=self.env, capture_output=True, text=True, timeout=30)

    def read(self, name):
        return json.loads((self.run / name).read_text())

    def test_presence_declaration_reaches_generated_data_and_is_not_reused(self):
        result = self.prepare('--flow', '5.0.0-multi-presence-positive.yaml')
        self.assertEqual(result.returncode, 0, result.stderr)
        declaration = self.read('data-declaration.json')
        self.assertEqual(declaration['accounts'], {'alice': 0, 'bob': 1})
        data = self.read('data.json')
        self.assertEqual(data['account']['alice']['userId'], 'fake-a')
        self.assertEqual(data['account']['bob']['userId'], 'fake-b')
        self.assertRegex(data['biz']['input']['presenceDescription'], '^presence-[0-9a-f]{32}$')
        self.assertEqual(data['biz']['result'], {})
        self.assertFalse((self.run / 'devices.json').exists())
        calls = (self.run / 'make-calls').read_text()
        repeated = self.prepare('--flow', '5.0.0-multi-presence-positive.yaml')
        self.assertEqual(repeated.returncode, 65, repeated.stderr)
        self.assertEqual((self.run / 'make-calls').read_text(), calls)
        self.assertEqual(self.read('data.json'), data)

    def test_explicit_override_remains_a_complete_replacement(self):
        declaration = {'accounts': {'alice': 1, 'bob': 0},
                       'unique': {'presenceDescription': 'override-'}, 'distinctAccounts': True}
        override = self.run / 'override.json'
        override.write_text(json.dumps(declaration))
        result = self.prepare('--flow', '5.0.0-multi-presence-positive.yaml', '--data', str(override))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.read('data-declaration.json'), declaration)
        data = self.read('data.json')
        self.assertEqual(data['account']['alice']['userId'], 'fake-b')
        self.assertTrue(data['biz']['input']['presenceDescription'].startswith('override-'))

    def test_bad_data_fails_before_token_refresh(self):
        (self.run / 'commands.json').write_text('{"data": null, "steps": []}')
        flow = self.run / 'case.yaml'
        flow.write_text('name: fixture\nagents:\n  alice: {script: commands.json}\nsteps: []\n')
        result = self.prepare('--flow', str(flow))
        self.assertEqual(result.returncode, 65, result.stderr)
        self.assertIn('must be an object', result.stderr)
        self.assertFalse((self.run / 'make-calls').exists())
        self.assertFalse((self.run / 'data.json').exists())

    def test_roles_only_keeps_default_account_selection(self):
        result = self.prepare('--roles', 'alice,bob')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.read('data-declaration.json'), {})
        data = self.read('data.json')
        self.assertEqual(data['account']['alice']['userId'], 'fake-a')
        self.assertEqual(data['account']['bob']['userId'], 'fake-b')


if __name__ == '__main__':
    unittest.main()
