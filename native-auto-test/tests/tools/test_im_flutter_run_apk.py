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
    for name in ('run.sh', 'release_apk_cache.py', 'adb_preflight.py', 'summarize_lanes.py', 'clean_install.py'):
        if (SCRIPTS / name).exists():
            shutil.copy(SCRIPTS / name, scripts / name)
    executable(native / 'scripts/collect_cases.py', "print('tests/test_example.py::test_a\\ntests/test_example.py::test_b')\n")
    executable(scripts / 'setup_emulator.sh', '#!/bin/sh\necho setup >> "$CALLS"\nprintf "setup %s\\n" "$ADB_MDNS" >> "$MDNS_ENVS"\n')
    executable(native / '.venv/bin/python', f'#!/bin/sh\nexec "{sys.executable}" "$@"\n')
    native.joinpath('config.yaml').write_text('websocket:\n  base_url: "ws://127.0.0.1:40100"\n')
    sdk = tmp_path / 'sdk'
    executable(sdk / 'platform-tools/adb', '''#!/bin/sh
printf 'adb %s\n' "$*" >> "$CALLS"
printf 'adb %s\n' "$ADB_MDNS" >> "$MDNS_ENVS"
case "$*" in
  start-server)
    [ -f "$MDNS_STATE" ] || printf '%s' "$ADB_MDNS" > "$MDNS_STATE"
    ;;
  server-status)
    if [ "$(cat "$MDNS_STATE")" = 0 ]; then
      echo 'mdns_enabled: false'
    else
      echo 'mdns_enabled: true'
    fi
    ;;
  *'emu avd name')
    case "$2" in
      emulator-5554) echo im_flutter_test_a ;;
      emulator-5556) echo im_flutter_test_b ;;
      emulator-5558) echo im_flutter_test_a_lane1 ;;
      emulator-5560) echo im_flutter_test_b_lane1 ;;
    esac ;;
  *'pm list packages'*)
    [ ! -f "$MDNS_STATE.$2.installed" ] || echo package:com.easemob.im_flutter_test ;;
  *' uninstall '*) rm -f "$MDNS_STATE.$2.installed"; echo Success ;;
  *' install '*) touch "$MDNS_STATE.$2.installed"; echo Success ;;
  *'printenv EXTERNAL_STORAGE') echo /sdcard ;;
  *getprop*) echo 1 ;;
esac
''')
    executable(sdk / 'emulator/emulator', '#!/bin/sh\nprintf "emulator %s\\n" "$ADB_MDNS" >> "$MDNS_ENVS"\nexit 0\n')
    tools = tmp_path / 'bin'
    for name in ('sleep', 'pkill', 'tail'):
        executable(tools / name, '#!/bin/sh\nexit 0\n')
    reporter = tmp_path / 'fake-pytest-result.py'
    reporter.write_text('''import json, os
from pathlib import Path
if os.environ.get('IM_FLUTTER_LANE_RESULT'):
    nodes = Path(os.environ['IM_FLUTTER_LANE_NODEIDS']).read_text().splitlines()
    outcome = os.environ.get('FAKE_PYTEST_OUTCOME', 'passed')
    code = 1 if outcome in ('failed', 'error') else 0
    Path(os.environ['IM_FLUTTER_LANE_RESULT']).write_text(json.dumps({
        'schema_version': 1, 'exitstatus': code, 'results': dict.fromkeys(nodes, outcome),
    }))
    raise SystemExit(code)
''')
    executable(tools / 'make', '#!/bin/sh\nprintf "make %s\\n" "$*" >> "$CALLS"\nprintf "make %s\\n" "$ADB_MDNS" >> "$MDNS_ENVS"\n'
               + f'if [ "$1" = test-local ]; then "{sys.executable}" "{reporter}"; fi\n')
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
    for key in ('APK_PATH', 'GH_REPO', 'ANDROID_SDK_ROOT', 'ADB_MDNS'):
        env.pop(key, None)
    env.update(PATH=f'{tools}:' + env['PATH'], ANDROID_HOME=str(sdk), CALLS=str(calls),
               MDNS_STATE=str(tmp_path / 'mdns-state'), MDNS_ENVS=str(tmp_path / 'mdns-envs'))
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
    executable(recorder, f'#!{sys.executable}\nimport json,sys,runpy\nfrom pathlib import Path\nPath("argv-" + __import__("os").environ.get("TEST_LANE", "single") + ".json").write_text(json.dumps(sys.argv[1:]))\n'
               + f'runpy.run_path({str(tmp / "fake-pytest-result.py")!r})\n')
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
case "$*" in
  *getprop*) echo 0 ;;
  server-status) echo 'mdns_enabled: false' ;;
esac
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


@pytest.mark.parametrize('lanes', [1, 2])
@pytest.mark.parametrize('existing', [False, True])
def test_mdns_is_disabled_and_checked_for_entire_runner_tree(runner, lanes, existing):
    run, tmp = runner
    if existing:
        (tmp / 'mdns-state').write_text('0')
    result, calls = run('--lanes', str(lanes), ADB_MDNS='1')
    assert result.returncode == 0, result.stderr
    assert (tmp / 'mdns-state').read_text() == '0'
    # Removing the gate or its inheritance breaks observable startup ordering.
    assert calls.index('adb server-status') < next(i for i, c in enumerate(calls) if c.startswith('curl '))
    assert calls.count('adb server-status') == 2 * lanes + (lanes > 1)
    assert 'adb kill-server' not in calls
    environments = [line.split() for line in (tmp / 'mdns-envs').read_text().splitlines()]
    assert {entry[0] for entry in environments} == {'setup', 'adb', 'emulator', 'make'}
    assert all(entry[1:] == ['0'] for entry in environments)


@pytest.mark.parametrize('lanes', [1, 2])
@pytest.mark.parametrize('state', ['enabled', 'missing', 'duplicate', 'duplicate-malformed', 'malformed', 'query-error', 'start-error'])
def test_mdns_unsafe_or_unknown_server_stops_before_device_work(runner, lanes, state):
    run, tmp = runner
    (tmp / 'mdns-state').write_text('1' if state == 'enabled' else '0')
    adb = tmp / 'sdk/platform-tools/adb'
    source = adb.read_text()
    status_outputs = {
        'missing': "echo 'version: old'",
        'duplicate': "printf 'mdns_enabled: false\\nmdns_enabled: true\\n'",
        'duplicate-malformed': "printf 'mdns_enabled: false\\nmdns_enabled: invalid value\\n'",
        'malformed': "echo 'mdns_enabled: unknown'",
        'query-error': "echo 'private-status-sentinel' >&2; exit 9",
    }
    if state in status_outputs:
        source = source.replace("echo 'mdns_enabled: false'", status_outputs[state])
    if state == 'start-error':
        source = source.replace('start-server)', "start-server)\n    echo 'private-start-sentinel' >&2; exit 8")
    adb.write_text(source)
    result, calls = run('--lanes', str(lanes), ADB_MDNS='1')
    assert result.returncode != 0
    assert 'ADB' in result.stderr
    assert not any(c.startswith('curl ') or ' install ' in c or c.startswith('make test-local ') for c in calls)
    assert 'adb kill-server' not in calls
    assert 'private-status-sentinel' not in result.stderr + result.stdout
    assert 'private-start-sentinel' not in result.stderr + result.stdout
    assert not any(line.startswith('emulator ') for line in (tmp / 'mdns-envs').read_text().splitlines())
    if state == 'enabled':
        assert 'kill-server' in result.stderr and 'ADB_MDNS=0' in result.stderr
        assert str(adb) in result.stderr


def test_mdns_rechecked_before_pytest_without_restarting_server(runner):
    run, tmp = runner
    make = tmp / 'bin/make'
    make.write_text(make.read_text() + '\ncase "$*" in ws-bridge-up*) printf 1 > "$MDNS_STATE" ;; esac\n')
    result, calls = run()
    assert result.returncode != 0
    assert any(' install ' in c for c in calls)
    assert calls.count('adb start-server') == 1
    assert calls.count('adb server-status') == 2
    assert not any(c.startswith('make test-local ') for c in calls)
    assert any('ws-bridge-down' in c for c in calls)
    assert 'adb kill-server' not in calls


def test_mdns_hung_adb_is_bounded(runner):
    run, tmp = runner
    executable(tmp / 'sdk/platform-tools/adb', f'#!{sys.executable}\nimport time\ntime.sleep(60)\n')
    result, calls = run()
    assert result.returncode != 0
    assert '10' in result.stderr and 'timeout' in result.stderr.lower()
    assert not any(c.startswith('curl ') or c.startswith('make ') for c in calls)


@pytest.mark.parametrize('lanes', [1, 2])
def test_mdns_first_install_prepares_sdk_before_probing(runner, lanes):
    run, tmp = runner
    staged = tmp / 'uninstalled-sdk'
    (tmp / 'sdk').rename(staged)
    setup = tmp / 'project/native-auto-test/skills/im-flutter-run/scripts/setup_emulator.sh'
    setup.write_text(setup.read_text() + '\n[ -d "$ANDROID_HOME" ] || mv "$SDK_STAGING" "$ANDROID_HOME"\n')
    result, calls = run('--lanes', str(lanes),
                        ANDROID_HOME=str(tmp / 'new sdk with spaces'), SDK_STAGING=str(staged))
    assert result.returncode == 0, result.stderr
    assert calls.index('setup') < calls.index('adb start-server')
    assert calls.count('adb server-status') == 2 * lanes + (lanes > 1)


def test_mdns_children_recheck_after_parent_passed(runner):
    run, tmp = runner
    flutter = tmp / 'bin/flutter'
    flutter.write_text(flutter.read_text() + '\nprintf 1 > "$MDNS_STATE"\n')
    result, calls = run('--lanes', '2', '--build')
    assert result.returncode != 0
    assert calls.index('adb server-status') < calls.index('build')
    assert calls.count('adb server-status') == 3
    assert 'adb kill-server' not in calls
    assert not any(' install ' in c or c.startswith('make test-local ') for c in calls)


def test_runner_combines_all_fifteen_failed_nodeids_after_both_lanes(runner):
    run, tmp = runner
    nodeids = [f'tests/test_example.py::test_failure[{i}]' for i in range(15)]
    executable(tmp / 'project/native-auto-test/scripts/collect_cases.py', 'print(' + repr('\n'.join(nodeids)) + ')\n')
    result, _ = run('--lanes', '2', FAKE_PYTEST_OUTCOME='failed')
    assert result.returncode != 0
    assert 'Total: 15' in result.stdout and '15 failed' in result.stdout
    assert sorted(line for line in result.stdout.splitlines() if line.startswith('FAILED ')) == sorted('FAILED ' + n for n in nodeids)
    assert result.stdout.index('Total: 15') > result.stdout.index('[lane 1] FAIL')
    assert result.stdout.index('Total: 15') < result.stdout.index('Overall: FAIL')


def test_runner_reports_missing_pytest_results_as_incomplete(runner):
    run, tmp = runner
    (tmp / 'fake-pytest-result.py').write_text('raise SystemExit(3)\n')
    result, _ = run('--lanes', '2')
    assert result.returncode != 0
    assert 'INCOMPLETE' in result.stdout and '2 unreported' in result.stdout


def test_runner_empty_shards_are_not_missing_results(runner):
    run, tmp = runner
    executable(tmp / 'project/native-auto-test/scripts/collect_cases.py', 'print("tests/test_example.py::test_a")\n')
    result, _ = run('--lanes', '2')
    assert result.returncode == 0, result.stdout + result.stderr
    assert 'Total: 1' in result.stdout and '1 passed' in result.stdout
    assert '0 unreported' in result.stdout
