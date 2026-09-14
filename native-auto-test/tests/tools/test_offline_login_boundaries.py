"""Guard offline recipient relogin boundaries without running business cases."""
import ast
from pathlib import Path

ROOT = Path(__file__).parents[1]


def test_offline_cases_do_not_bypass_shared_login_wait():
    shared = 0
    for path in ROOT.rglob('*.py'):
        if 'tools' in path.relative_to(ROOT).parts:
            continue
        for fn in ast.walk(ast.parse(path.read_text())):
            if not isinstance(fn, ast.FunctionDef) or not fn.name.startswith('test_'):
                continue
            if 'offline' not in fn.name:
                continue
            for call in (n for n in ast.walk(fn) if isinstance(n, ast.Call)):
                if ast.unparse(call.func) == 'login_preserving_offline_events':
                    shared += 1
                if any(ast.unparse(a) == 'Cmd.login.value' for a in call.args):
                    assert fn.name == 'test_login_then_receive_offline_sync_event', (path, fn.name)
                    assert "timing_pause('settle.offline', module='client')" in ast.unparse(fn)
    assert shared > 0


def test_nested_offline_helpers_reach_the_paced_login():
    # These cases have no direct login helper call in their test body.
    cases = [
        ('contact/test_contact_offline_friendship.py',
         'test_contact_offline_invitation_accept_after_login', '_prepare_offline_invitation'),
        ('group/test_group_offline_roles_and_configuration.py',
         'test_group_offline_metadata_final_state', '_relogin_b'),
    ]
    for file, case, helper in cases:
        funcs = {n.name: n for n in ast.parse((ROOT / file).read_text()).body
                 if isinstance(n, ast.FunctionDef)}
        assert any(isinstance(n, ast.Call) and ast.unparse(n.func) == helper
                   for n in ast.walk(funcs[case]))
        assert any(isinstance(n, ast.Call) and ast.unparse(n.func) == 'login_preserving_offline_events'
                   for n in ast.walk(funcs[helper]))
    flow = ROOT.parent / 'src/test_flow/offline_test_flow.py'
    login = next(n for n in ast.parse(flow.read_text()).body
                 if isinstance(n, ast.FunctionDef) and n.name == 'login_preserving_offline_events')
    assert ast.unparse(login.body[1]) == "pause('settle.offline', module=module)"
    assert not any(isinstance(n, ast.Call) and isinstance(n.func, ast.Attribute)
                   and n.func.attr == 'drain_events' for n in ast.walk(login))


def test_direct_friend_sync_login_has_pause_before_and_after():
    path = ROOT / 'contact/test_friend_info_sync.py'
    fn = next(n for n in ast.parse(path.read_text()).body
              if isinstance(n, ast.FunctionDef) and n.name == 'test_friend_info_auto_sync_after_login')
    body = next(n.body for n in fn.body if isinstance(n, ast.Try))
    count = 0
    for i, stmt in enumerate(body):
        if 'Cmd.login.value' in ast.unparse(stmt):
            assert ast.unparse(body[i - 1]) == "timing_pause('settle.offline', module='contact')"
            assert ast.unparse(body[i + 1]) == "timing_pause('settle.offline', module='contact')"
            count += 1
    assert count == 2
