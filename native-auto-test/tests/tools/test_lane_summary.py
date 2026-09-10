"""Real pytest lane results and combined terminal totals, without devices."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys

import pytest

ROOT = Path(__file__).resolve().parents[2]
SUMMARY = ROOT / 'skills/im-flutter-run/scripts/summarize_lanes.py'


def summary(directory, lanes):
    return subprocess.run([sys.executable, str(SUMMARY), str(directory), str(lanes)],
                          text=True, capture_output=True, timeout=10)


def manifest(directory, lane, nodeids):
    (directory / f'lane{lane}.nodeids').write_text('\n'.join(nodeids))


def result_file(directory, lane, results, exitstatus=0):
    (directory / f'lane{lane}.result.json').write_text(json.dumps({
        'schema_version': 1, 'exitstatus': exitstatus, 'results': results,
    }))
    (directory / f'lane{lane}.exit').write_text(str(exitstatus))


def start_pytest(directory, lane, source, nodeids, *args):
    scripts = directory / 'scripts'
    scripts.mkdir(exist_ok=True)
    shutil.copy(ROOT / 'scripts/pytest_lane.py', scripts / 'pytest_lane.py')
    (directory / 'test_cases.py').write_text(source)
    manifest(directory, lane, nodeids)
    env = {**os.environ, 'PYTEST_DISABLE_PLUGIN_AUTOLOAD': '1', 'PYTEST_ADDOPTS': '',
           'IM_FLUTTER_LANE_NODEIDS': str(directory / f'lane{lane}.nodeids'),
           'IM_FLUTTER_LANE_RESULT': str(directory / f'lane{lane}.result.json')}
    return subprocess.Popen([sys.executable, '-m', 'pytest', '-q', '-p', 'scripts.pytest_lane',
                             '-p', 'no:cacheprovider', 'test_cases.py', *args],
                            cwd=directory, env=env, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)


def finish(directory, lane, process):
    stdout, stderr = process.communicate(timeout=15)
    (directory / f'lane{lane}.exit').write_text(str(process.returncode))
    assert (directory / f'lane{lane}.result.json').exists(), stdout + stderr
    return json.loads((directory / f'lane{lane}.result.json').read_text())


def test_fifteen_failures_in_two_real_lanes_are_all_reported(tmp_path):
    nodeids = [f'test_cases.py::test_failure[{i}]' for i in range(15)]
    source = 'import pytest\n@pytest.mark.parametrize("i", range(15))\ndef test_failure(i): assert False, "private-payload-sentinel"\n'
    processes = [start_pytest(tmp_path, lane, source, nodeids[lane::2]) for lane in range(2)]
    for lane in (1, 0):
        data = finish(tmp_path, lane, processes[lane])
        assert len(data['results']) == len(nodeids[lane::2])
        assert set(data['results'].values()) == {'failed'}
        assert 'private-payload-sentinel' not in json.dumps(data)
    merged = summary(tmp_path, 2)
    assert merged.returncode == 1
    assert 'Total: 15' in merged.stdout and '15 failed' in merged.stdout
    assert '0 unreported' in merged.stdout
    assert sorted(line for line in merged.stdout.splitlines() if line.startswith('FAILED ')) == sorted('FAILED ' + n for n in nodeids)


def test_pytest_phases_are_counted_once_with_errors_taking_precedence(tmp_path):
    source = '''import pytest
def test_pass(): pass
def test_fail(): assert False
@pytest.mark.skip(reason="deferred")
def test_skip(): pass
@pytest.mark.xfail
def test_xfail(): assert False
@pytest.mark.xfail
def test_xpass(): pass
@pytest.fixture
def bad_setup(): raise RuntimeError("setup")
@pytest.fixture
def bad_teardown():
    yield
    raise RuntimeError("teardown")
def test_setup_error(bad_setup): pass
def test_teardown_error(bad_teardown): pass
def test_fail_and_teardown(bad_teardown): assert False
'''
    expected = dict(test_pass='passed', test_fail='failed', test_skip='skipped',
                    test_xfail='xfailed', test_xpass='xpassed', test_setup_error='error',
                    test_teardown_error='error', test_fail_and_teardown='error')
    expected = {'test_cases.py::' + key: value for key, value in expected.items()}
    data = finish(tmp_path, 0, start_pytest(tmp_path, 0, source, list(expected)))
    assert data['results'] == expected
    merged = summary(tmp_path, 1)
    assert merged.returncode == 1
    assert 'Total: 8' in merged.stdout
    assert '1 passed, 1 failed, 3 error, 1 skipped, 1 xfailed, 1 xpassed, 0 unreported' in merged.stdout


def test_stop_on_first_failure_leaves_unreported_cases(tmp_path):
    nodes = ['test_cases.py::test_first', 'test_cases.py::test_second']
    process = start_pytest(tmp_path, 0, 'def test_first(): assert False\ndef test_second(): pass\n', nodes, '-x')
    finish(tmp_path, 0, process)
    merged = summary(tmp_path, 1)
    assert merged.returncode == 1
    assert '1 failed' in merged.stdout and '1 unreported' in merged.stdout
    assert 'UNREPORTED ' + nodes[1] in merged.stdout


@pytest.mark.parametrize('problem', ['missing', 'malformed', 'unknown-outcome', 'extra-node', 'duplicate-shard', 'missing-exit'])
def test_incomplete_or_invalid_lane_never_claims_success(tmp_path, problem):
    manifest(tmp_path, 0, ['test.py::test_a'])
    result_file(tmp_path, 0, {'test.py::test_a': 'passed'})
    manifest(tmp_path, 1, ['test.py::test_a' if problem == 'duplicate-shard' else 'test.py::test_b'])
    result_file(tmp_path, 1, {'test.py::test_b': 'passed'})
    path = tmp_path / 'lane1.result.json'
    if problem == 'missing': path.unlink()
    if problem == 'malformed': path.write_text('not json')
    if problem == 'unknown-outcome': result_file(tmp_path, 1, {'test.py::test_b': 'unknown'})
    if problem == 'extra-node': result_file(tmp_path, 1, {'test.py::other': 'passed'})
    if problem == 'missing-exit': (tmp_path / 'lane1.exit').unlink()
    merged = summary(tmp_path, 2)
    assert merged.returncode == 1
    assert 'INCOMPLETE' in merged.stdout


def test_empty_lane_and_skipped_case_do_not_create_false_failures(tmp_path):
    manifest(tmp_path, 0, ['test.py::a', 'test.py::b'])
    result_file(tmp_path, 0, {'test.py::a': 'passed', 'test.py::b': 'skipped'})
    manifest(tmp_path, 1, [])
    merged = summary(tmp_path, 2)
    assert merged.returncode == 0, merged.stdout + merged.stderr
    assert 'Total: 2' in merged.stdout and '1 skipped' in merged.stdout
    assert '0 unreported' in merged.stdout
