"""IM priorities, business steps and stable pytest identity for Allure retries."""
from hashlib import sha256
from pathlib import Path

import pytest

from src.tools.case_priorities import CASE_PRIORITIES
from src.tools.allure_steps import report_phase

ROOT = Path(__file__).resolve().parents[2]
SEVERITIES = {'P0': 'blocker', 'P1': 'critical', 'P2': 'normal'}


def _catalog_nodeid(item):
    # Keep explicit parameter IDs, independent of cwd and pytest's chosen rootdir.
    try:
        relative = item.path.resolve().relative_to(ROOT).as_posix()
    except ValueError:
        return item.nodeid
    return relative + '::' + item.nodeid.split('::', 1)[1]


def pytest_configure(config):
    if not config.getoption('allure_report_dir', default=None):
        return
    import allure_commons

    class StableHistory:
        @allure_commons.hookimpl(hookwrapper=True, tryfirst=True)
        def report_result(self, result):
            # Run before the Allure file logger, after its default parameter hash.
            # Hashing parameter repr would split set-valued cases across processes.
            nodeid = next((label.value for label in result.labels
                           if label.name == 'pytest_nodeid'), None)
            if nodeid is not None:
                result.historyId = sha256(('pytest-nodeid-v1\0' + nodeid).encode('utf-8')).hexdigest()
            yield

    plugin = StableHistory()
    allure_commons.plugin_manager.register(plugin)
    config.add_cleanup(lambda: allure_commons.plugin_manager.unregister(plugin))


@pytest.hookimpl(hookwrapper=True, tryfirst=True)
def pytest_runtest_setup(item):
    # Resume after Allure's default setup name/description, even for static skips.
    with report_phase('setup'):
        yield
    if item.config.getoption('allure_report_dir', default=None):
        import allure
        allure.dynamic.label('pytest_nodeid', _catalog_nodeid(item))
        priority = CASE_PRIORITIES.get(_catalog_nodeid(item))
        if priority in SEVERITIES:
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
