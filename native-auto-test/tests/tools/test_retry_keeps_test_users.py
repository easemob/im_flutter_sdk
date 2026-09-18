"""重试模式必须让测试账号跨尝试存活；账号名规则不得与 conftest 漂移。"""
import os
import re
from datetime import datetime
from pathlib import Path

import pytest

RUN_SH = Path(__file__).parents[2] / 'skills/im-flutter-run/scripts/run.sh'


@pytest.fixture(scope='module')
def run_sh():
    return RUN_SH.read_text()


def test_retry_mode_keeps_users_across_attempts(run_sh):
    """重试复用同一套环境，账号被删重建会导致设备登录态失效、重跑假失败。"""
    retry_block = run_sh.split('# ---- Retry mode:', 1)[1]
    assert 'export KEEP_TEST_USERS=1' in retry_block
    # 尝试 0 之前就要接管，否则首次 teardown 就把账号删了。
    assert retry_block.index('export KEEP_TEST_USERS=1') < retry_block.index('[尝试 1]')


def test_caller_supplied_keep_users_is_not_hijacked(run_sh):
    """调用方已显式 KEEP_TEST_USERS=1 时，重试模式不接管、不代删。"""
    retry_block = run_sh.split('# ---- Retry mode:', 1)[1]
    assert 'RETRY_OWNS_TEST_USERS=0' in retry_block
    assert re.search(r'1\|true\|True\)\s*;;', retry_block), '缺少「调用方已要求保留」的分支'
    assert 'RETRY_OWNS_TEST_USERS" == "1"' in retry_block, '清理必须以接管为前提'


def test_cleanup_runs_after_all_attempts(run_sh):
    """接管账号后必须补上 fixture 被抑制的那次删除，否则账号会残留。"""
    retry_block = run_sh.split('# ---- Retry mode:', 1)[1]
    assert 'make delete-user' in retry_block
    # 清理必须在重试循环结束之后。
    assert retry_block.index('while [[ "$attempt"') < retry_block.index('make delete-user')


def test_username_rule_matches_conftest(monkeypatch, run_sh):
    """run.sh 推导的账号名必须与 tests/conftest.py::_test_usernames 完全一致。"""
    from tests.conftest import _test_usernames

    monkeypatch.setenv('TEST_USER_PREFIX', 'g7')
    expected = _test_usernames()

    # run.sh: TEST_USER_PREFIX="g$LANE"、TEST_USER_DATE="$(date +%m%d)"、
    #         USERNAME="test${TEST_USER_DATE}${TEST_USER_PREFIX}user${suffix}"
    assert 'TEST_USER_DATE="$(date +%m%d)"' in run_sh
    assert 'export TEST_USER_PREFIX="g$LANE"' in run_sh
    pattern = 'test${TEST_USER_DATE}${TEST_USER_PREFIX}user${suffix}'
    assert pattern in run_sh
    rendered = tuple(
        pattern.replace('${TEST_USER_DATE}', datetime.now().strftime('%m%d'))
               .replace('${TEST_USER_PREFIX}', os.environ['TEST_USER_PREFIX'])
               .replace('${suffix}', str(n))
        for n in (1, 2, 3)
    )
    assert rendered == expected
