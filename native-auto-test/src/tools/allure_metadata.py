"""Add IM priority prefixes without replacing Allure's module tree or details."""
from pathlib import Path

import pytest

from src.tools.case_priorities import CASE_PRIORITIES
from src.tools.allure_steps import report_phase

ROOT = Path(__file__).resolve().parents[2]
SEVERITIES = {'P0': 'blocker', 'P1': 'critical', 'P2': 'normal'}


def _catalog_nodeid(item):
    # Derive a stable repository key without changing pytest/Allure identity.
    try:
        relative = item.path.resolve().relative_to(ROOT).as_posix()
    except ValueError:
        return item.nodeid
    return relative + '::' + item.nodeid.split('::', 1)[1]


@pytest.hookimpl(hookwrapper=True, tryfirst=True)
def pytest_runtest_setup(item):
    # Resume after Allure's default setup name/description, even for static skips.
    with report_phase('setup'):
        yield
    if item.config.getoption('allure_report_dir', default=None):
        priority = CASE_PRIORITIES.get(_catalog_nodeid(item))
        if priority in SEVERITIES:
            import allure
            allure.dynamic.title(f'[{priority}] {item.name}')
            allure.dynamic.label('priority', priority)
            allure.dynamic.severity(SEVERITIES[priority])


@pytest.hookimpl(hookwrapper=True, tryfirst=True)
def pytest_runtest_call(item):
    with report_phase('call'):
        yield


@pytest.hookimpl(hookwrapper=True, tryfirst=True)
def pytest_runtest_teardown(item):
    with report_phase('teardown'):
        yield
