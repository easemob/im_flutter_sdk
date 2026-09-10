"""Real pytest collection/selection in disposable projects, without devices."""
import os
from pathlib import Path
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]


def project(tmp_path):
    scripts = tmp_path / 'scripts'
    scripts.mkdir()
    for name in ('collect_cases.py', 'pytest_lane.py'):
        shutil.copy(ROOT / 'scripts' / name, scripts / name)
    (tmp_path / 'pytest.ini').write_text('[pytest]\ntestpaths = tests\n')
    tests = tmp_path / 'tests'
    tests.mkdir()
    (tests / 'test_sample.py').write_text(
        'import pytest\n'
        '@pytest.mark.parametrize("value", [1, 2], ids=["space is here", "other"])\n'
        'def test_sample(value): pass\n'
        'def test_sample_extra(): pass\n'
    )
    env = os.environ.copy()
    env.pop('PYTEST_ADDOPTS', None)
    env.pop('IM_FLUTTER_LANE_NODEIDS', None)
    env['PYTEST_DISABLE_PLUGIN_AUTOLOAD'] = '1'
    return env


def test_default_collection_filter_and_exact_disjoint_shards(tmp_path):
    env = project(tmp_path)
    def collect(*args):
        return subprocess.run([sys.executable, 'scripts/collect_cases.py', *args],
                              cwd=tmp_path, env=env, capture_output=True, text=True, timeout=15)
    result = collect()
    assert result.returncode == 0, result.stderr
    nodeids = result.stdout.splitlines()
    assert len(nodeids) == 3
    filtered = collect('-k', 'extra')
    assert filtered.returncode == 0
    assert filtered.stdout.splitlines() == [nodeids[-1]]
    assert collect('missing.py').returncode != 0
    assert collect('-k', 'nonexistent').returncode != 0
    for lane in range(2):
        selected = nodeids[lane::2]
        selection = tmp_path / f'lane{lane}.nodeids'
        selection.write_text('\n'.join(selected))
        run = subprocess.run(
            [sys.executable, '-m', 'pytest', '-q', '-p', 'scripts.pytest_lane', '-p', 'no:cacheprovider'],
            cwd=tmp_path, env={**env, 'IM_FLUTTER_LANE_NODEIDS': str(selection)},
            capture_output=True, text=True, timeout=15,
        )
        assert run.returncode == 0, run.stdout + run.stderr
        assert f'{len(selected)} passed' in run.stdout
        assert f'{len(nodeids) - len(selected)} deselected' in run.stdout
