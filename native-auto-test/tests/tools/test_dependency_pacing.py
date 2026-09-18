"""Regression examples for helper, branch and cross-device business pacing."""
import ast
from pathlib import Path

import pytest

ROOT = Path(__file__).parents[1]


@pytest.mark.parametrize('file,function,command', [
    ('chat/test_chat_offline_message_extended_operations.py',
     'test_chat_offline_text_recalled_before_first_recipient_login', 'recallMessage'),
    ('chat/test_chat_offline_message_extended_operations.py',
     'test_chat_offline_text_modified_before_first_recipient_login', 'modifyMessage'),
    ('contact/test_contact_offline_friendship.py',
     'test_contact_offline_invitation_accept_after_login', 'acceptInvitation'),
    ('contact/test_contact_offline_friendship.py',
     'test_contact_offline_invitation_decline_after_login', 'declineInvitation'),
    ('chatroom/test_chatroom_callbacks.py',
     'test_chatroom_owner_changed_callback', 'changeChatRoomOwner'),
])
def test_dependency_operation_has_explicit_pause(file, function, command):
    """依赖操作前的等待不得删除：固定 pause 或同预算的有界断言都算。"""
    tree = ast.parse((ROOT / file).read_text())
    fn = next(n for n in tree.body if isinstance(n, ast.FunctionDef) and n.name == function)
    checked = 0
    for node in ast.walk(fn):
        for _, block in ast.iter_fields(node):
            if not isinstance(block, list):
                continue
            for i, stmt in enumerate(block):
                if not isinstance(stmt, ast.Assign) or not isinstance(stmt.value, ast.Call):
                    continue
                if any(ast.unparse(a) == f'Cmd.{command}.value' for a in stmt.value.args):
                    previous = ast.unparse(block[i - 1]) if i else ''
                    assert (previous.startswith("timing_pause('step.")
                            or 'assert_response_eventually(' in previous
                            or 'assert_eventually(' in previous), previous
                    checked += 1
    assert checked


def test_all_business_cases_have_audit_entries():
    inventory = (ROOT.parent / 'docs/case-dependency-audit.md').read_text()
    nodeids = set()
    for path in ROOT.rglob('test_*.py'):
        if 'tools' in path.relative_to(ROOT).parts:
            continue
        for node in ast.parse(path.read_text()).body:
            if isinstance(node, ast.FunctionDef) and node.name.startswith('test_'):
                nodeids.add(f'{path.relative_to(ROOT.parent)}::{node.name}')
    indexed = {line.removeprefix('### `').removesuffix('`')
               for line in inventory.splitlines() if line.startswith('### `tests/')}
    assert nodeids == indexed


def test_no_ordinary_pacing_inside_deadline_poll_loops():
    for path in ROOT.rglob('*.py'):
        if 'tools' in path.relative_to(ROOT).parts:
            continue
        for loop in ast.walk(ast.parse(path.read_text())):
            if isinstance(loop, ast.While):
                assert not any(isinstance(n, ast.Call) and ast.unparse(n.func) == 'timing_pause'
                               for n in ast.walk(loop)), (path, loop.lineno)
