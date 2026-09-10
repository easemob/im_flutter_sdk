"""Exact-nodeid lane selection; leave pytest's argument parsing and output intact."""
import json
import os
from pathlib import Path

import pytest


class _LaneResults:
    """One outcome per nodeid, without copying potentially sensitive failure text."""

    _priority = {name: rank for rank, name in enumerate(
        ('passed', 'skipped', 'xfailed', 'xpassed', 'failed', 'error')
    )}

    def __init__(self, path):
        self.path = Path(path)
        self.results = {}

    def pytest_runtest_logreport(self, report):
        if report.failed:
            outcome = 'failed' if report.when == 'call' else 'error'
        elif report.skipped:
            outcome = 'xfailed' if hasattr(report, 'wasxfail') else 'skipped'
        elif report.when == 'call' and report.passed:
            outcome = 'xpassed' if hasattr(report, 'wasxfail') else 'passed'
        else:
            return
        previous = self.results.get(report.nodeid)
        if previous is None or self._priority[outcome] > self._priority[previous]:
            self.results[report.nodeid] = outcome

    def pytest_sessionfinish(self, session, exitstatus):
        temporary = self.path.with_name(self.path.name + '.tmp')
        temporary.write_text(json.dumps({
            'schema_version': 1, 'exitstatus': int(exitstatus), 'results': self.results,
        }), encoding='utf-8')
        temporary.replace(self.path)


def pytest_configure(config):
    path = os.environ.get('IM_FLUTTER_LANE_RESULT')
    if path:
        config.pluginmanager.register(_LaneResults(path), 'lane-results')


@pytest.hookimpl(trylast=True)
def pytest_collection_modifyitems(config, items):
    path = os.environ.get("IM_FLUTTER_LANE_NODEIDS")
    if not path:
        return
    selected = set(Path(path).read_text().splitlines())
    kept = [item for item in items if item.nodeid in selected]
    removed = [item for item in items if item.nodeid not in selected]
    items[:] = kept
    if removed:
        config.hook.pytest_deselected(items=removed)
