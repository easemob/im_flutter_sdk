"""Execute the real runner in a disposable tree with external tools stubbed."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import pytest

SCRIPTS = Path(__file__).resolve().parents[2] / 'skills/im-flutter-run/scripts'


def executable(path, text):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text)
    path.chmod(0o755)


@pytest.fixture
def runner(tmp_path):
    project = tmp_path / 'project'
    native = project / 'native-auto-test'
    scripts = native / 'skills/im-flutter-run/scripts'
    scripts.mkdir(parents=True)
    for name in ('run.sh', 'release_apk_cache.py'):
        if (SCRIPTS / name).exists():
            shutil.copy(SCRIPTS / name, scripts / name)
    executable(native / 'scripts/collect_cases.py', "print('tests/test_example.py::test_a\\ntests/test_example.py::test_b')\n")
    executable(scripts / 'setup_emulator.sh', '#!/bin/sh\necho setup >> "$CALLS"\n')
    executable(native / '.venv/bin/python', f'#!/bin/sh\nexec "{sys.executable}" "$@"\n')
    native.joinpath('config.yaml').write_text('websocket:\n  base_url: "ws://127.0.0.1:40100"\n')
    sdk = tmp_path / 'sdk'
    executable(sdk / 'platform-tools/adb', '''#!/bin/sh
printf 'adb %s\n' "$*" >> "$CALLS"
case "$*" in
  *getprop*) echo 1 ;;
esac
''')
    executable(sdk / 'emulator/emulator', '#!/bin/sh\nexit 0\n')
    tools = tmp_path / 'bin'
    for name in ('sleep', 'pkill', 'tail'):
        executable(tools / name, '#!/bin/sh\nexit 0\n')
    executable(tools / 'make', '#!/bin/sh\nprintf "make %s\\n" "$*" >> "$CALLS"\n')
    executable(tools / 'allure', '#!/bin/sh\nexit 0\n')
    executable(tools / 'flutter', '''#!/bin/sh
echo build >> "$CALLS"
mkdir -p build/app/outputs/flutter-apk
printf fixture > build/app/outputs/flutter-apk/app-release.apk
''')
    project.joinpath('im_flutter_test').mkdir()
    executable(tools / 'curl', f'''#!{sys.executable}
import json, os, pathlib, sys
args = sys.argv[1:]
with open(os.environ['CALLS'], 'a') as log: log.write('curl ' + args[-1] + '\\n')
if os.environ.get('FAIL_QUERY') == '1': sys.exit(22)
if '-o' in args:
    pathlib.Path(args[args.index('-o') + 1]).write_bytes(b'fixture')
else:
    sys.stdout.write('HTTP/2 200\\r\\ncontent-type: application/json\\r\\n\\r\\n')
    print(json.dumps({{'id': 1, 'tag_name': 'v1', 'assets': [{{'id': 2, 'name': 'app-release.apk', 'state': 'uploaded', 'size': 7, 'updated_at': '2026-01-01T00:00:00Z', 'digest': None, 'browser_download_url': 'https://github.com/easemob/im_flutter_sdk/releases/download/v1/app-release.apk'}}]}}))
''')
    # Keep even absolute /tmp runner artifacts inside this disposable fixture.
    sandbox = tmp_path / 'tmp'
    sandbox.mkdir()
    copied = scripts / 'run.sh'
    copied.write_text(copied.read_text().replace('/tmp/im-flutter-run', str(sandbox / 'im-flutter-run')))
    calls = tmp_path / 'calls'
    env = os.environ.copy()
    for key in ('APK_PATH', 'GH_REPO', 'ANDROID_SDK_ROOT'):
        env.pop(key, None)
    env.update(PATH=f'{tools}:' + env['PATH'], ANDROID_HOME=str(sdk), CALLS=str(calls))
    def run(*args, **overrides):
        calls.write_text('')
        result = subprocess.run(['bash', str(copied), '--no-open', '-q', *args], env={**env, **overrides},
                                text=True, capture_output=True, timeout=20)
        return result, calls.read_text().splitlines()
    return run, tmp_path


def test_default_hit_and_refresh(runner):
    run, _ = runner
    first, calls = run()
    assert first.returncode == 0, first.stderr
    assert len([c for c in calls if c.startswith('curl ')]) == 2
    second, calls = run()
    assert second.returncode == 0, second.stderr
    assert len([c for c in calls if c.startswith('curl ')]) == 1
    assert '缓存命中' in second.stderr
    refreshed, calls = run('--refresh-apk')
    assert refreshed.returncode == 0, refreshed.stderr
    assert len([c for c in calls if c.startswith('curl ')]) == 2
    for serial in ('emulator-5554', 'emulator-5556'):
        uninstall = next(i for i, c in enumerate(calls) if c == f'adb -s {serial} uninstall com.easemob.im_flutter_test')
        install = next(i for i, c in enumerate(calls) if c.startswith(f'adb -s {serial} install '))
        assert uninstall < install
    assert len([c for c in calls if ' push ' in c]) == 2


@pytest.mark.parametrize('lanes', [1, 2])
def test_runner_preserves_pytest_output_options_without_injecting_defaults(runner, lanes):
    run, _ = runner
    result, calls = run('--lanes', str(lanes))
    assert result.returncode == 0, result.stderr
    recipes = [call for call in calls if call.startswith('make test-local ')]
    assert len(recipes) == lanes
    for recipe in recipes:
        args = recipe.split('ARGS=', 1)[1].split()
        assert args.count('-q') == 1
        assert '-v' not in args
        assert not any(arg.startswith('--color=') for arg in args)


def test_pytest_configs_do_not_override_native_output_defaults():
    import configparser
    import tomllib
    root = SCRIPTS.parents[2]
    ini = configparser.ConfigParser()
    ini.read(root / 'pytest.ini')
    assert not ini['pytest'].get('addopts', '').strip()
    config = tomllib.loads((root / 'pyproject.toml').read_text())
    assert not config['tool']['pytest']['ini_options'].get('addopts', '').strip()


def test_multilane_has_stable_output_and_unique_logs(runner):
    run, tmp = runner
    first, _ = run('--lanes', '2')
    second, _ = run('--lanes', '2')
    for result in (first, second):
        assert result.returncode == 0, result.stderr
        assert '[lane 0] 1 cases — running' in result.stdout
        assert '[lane 1] 1 cases — running' in result.stdout
        assert 'Overall: PASS' in result.stdout
        assert 'Logs:' in result.stdout
    assert first.stdout.split('Logs: ')[1].splitlines()[0] != second.stdout.split('Logs: ')[1].splitlines()[0]


@pytest.mark.parametrize('body', ['raise SystemExit(2)', "print('')"])
def test_collection_failure_never_starts_lanes(runner, body):
    run, tmp = runner
    executable(tmp / 'project/native-auto-test/scripts/collect_cases.py', body + '\n')
    result, calls = run('--lanes', '2')
    assert result.returncode != 0
    assert not calls
    assert 'fall back' not in result.stdout


def test_multi_lane_downloads_once(runner):
    run, _ = runner
    result, calls = run('--lanes', '2', '--refresh-apk')
    assert result.returncode == 0, result.stderr
    assert len([c for c in calls if c.startswith('curl ')]) == 2
    assert len([c for c in calls if ' install ' in c]) == 4


@pytest.mark.parametrize('lanes', [1, 2])
@pytest.mark.parametrize('source', ['path', 'build'])
def test_local_sources_bypass_remote(runner, lanes, source):
    run, tmp = runner
    apk = tmp / 'local.apk'
    apk.write_bytes(b'local')
    args = ['--lanes', str(lanes)]
    kwargs = {}
    if source == 'path': kwargs['APK_PATH'] = str(apk)
    else: args.append('--build')
    result, calls = run(*args, **kwargs)
    assert result.returncode == 0, result.stderr
    assert not any(c.startswith('curl ') for c in calls)
    assert calls.count('build') == (1 if source == 'build' else 0)


@pytest.mark.parametrize('args,with_path', [(['--refresh-apk', '--build'], False), (['--refresh-apk'], True), (['--build'], True)])
def test_conflicts_fail_before_setup(runner, args, with_path):
    run, tmp = runner
    apk = tmp / 'local.apk'
    apk.write_bytes(b'local')
    result, calls = run(*args, **({'APK_PATH': str(apk)} if with_path else {}))
    assert result.returncode != 0
    assert 'conflict' in result.stderr
    assert calls == []


def test_invalid_path_fails_without_fallback(runner):
    run, tmp = runner
    result, calls = run(APK_PATH=str(tmp / 'absent.apk'))
    assert result.returncode != 0
    assert 'APK_PATH' in result.stderr
    assert calls == []


def test_query_failure_with_cache_stops_before_install(runner):
    run, _ = runner
    result, _ = run()
    assert result.returncode == 0, result.stderr
    result, calls = run(FAIL_QUERY='1')
    assert result.returncode != 0
    assert not any(' install ' in c for c in calls)


@pytest.mark.parametrize('lanes', [1, 2])
def test_pytest_nodeids_survive_make_and_shell(runner, lanes):
    run, tmp = runner
    native = tmp / 'project/native-auto-test'
    nodeids = [
        'tests/chatroom/test_room.py::test_empty[usernames is null or empty!]',
        "tests/chatroom/test_room.py::test_empty[Server is unreachable-$HOME-$(touch INJECTED)-it's]",
    ]
    executable(native / 'scripts/collect_cases.py',
               'print(' + repr('\n'.join(nodeids)) + ')\n')
    # Exercise the real production recipe, with only device health checking stubbed.
    shutil.copy(SCRIPTS.parents[2] / 'Makefile', native / 'Makefile')
    executable(native / 'scripts/ws_bridge_local.sh', '#!/bin/sh\nexit 0\n')
    for lane in range(lanes):
        state = native / f'.local/lane{lane}'
        state.mkdir(parents=True, exist_ok=True)
        (state / 'ws-bridge.env').write_text('')
    (native / '.local/ws-bridge.env').write_text('')
    recorder = tmp / 'record-python'
    executable(recorder, f'#!{sys.executable}\nimport json,sys\nfrom pathlib import Path\nPath("argv-" + __import__("os").environ.get("TEST_LANE", "single") + ".json").write_text(json.dumps(sys.argv[1:]))\n')
    real_make = shutil.which('make')
    executable(tmp / 'bin/make', f'''#!/bin/bash
if [[ "$1" != test-local ]]; then exit 0; fi
args=()
for arg in "$@"; do
  case "$arg" in
    PY=*) args+=("PY={recorder}") ;;
    WS_STATE_DIR=*) export TEST_LANE="${{arg##*/}}"; args+=("$arg") ;;
    *) args+=("$arg") ;;
  esac
done
exec "{real_make}" "${{args[@]}}"
''')
    result, _ = run('--lanes', str(lanes), *(nodeids if lanes == 1 else ['tests/chatroom']))
    assert result.returncode == 0, result.stdout + result.stderr
    actual = []
    for path in native.glob('argv-*.json'):
        args = json.loads(path.read_text())
        if lanes == 1:
            actual.extend(arg for arg in args if arg.startswith('tests/'))
        else:
            assert 'tests/chatroom' in args
    if lanes > 1:
        for path in (tmp / 'tmp').glob('im-flutter-run-session.*/lane*.nodeids'):
            actual.extend(path.read_text().splitlines())
    assert sorted(actual) == sorted(nodeids)
    assert not (native / 'INJECTED').exists()


def test_boot_failure_does_not_clean_unstarted_bridge(runner):
    run, tmp = runner
    executable(tmp / 'sdk/platform-tools/adb', '''#!/bin/sh
printf 'adb %s\\n' "$*" >> "$CALLS"
case "$*" in *getprop*) echo 0 ;; esac
''')
    executable(tmp / 'bin/pgrep', '#!/bin/sh\nexit 1\n')
    result, calls = run()
    assert result.returncode != 0
    assert '模拟器进程已退出' in result.stderr
    assert not any('ws-bridge-down' in call for call in calls)
    assert not any(' install ' in call for call in calls)


def test_same_source_and_lane_destination(runner):
    run, tmp = runner
    apk = tmp / 'tmp/im-flutter-run-lane0.apk'
    apk.write_bytes(b'local')
    result, calls = run(APK_PATH=str(apk))
    assert result.returncode == 0, result.stderr
    assert not any(c.startswith('curl ') for c in calls)
