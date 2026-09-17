"""Static regression for the approval example; no device calls."""
import ast
from pathlib import Path


def test_approval_pauses_before_accept_and_server_query():
    """审批链路上的等待不得删除：固定 pause 或同预算的有界断言都算。"""
    path = Path(__file__).parents[1] / 'group/test_group_join_requests_and_invitations.py'
    tree = ast.parse(path.read_text())
    case = next(n for n in tree.body if isinstance(n, ast.FunctionDef)
                and n.name == 'test_group_request_to_join_and_accept_success')
    body = next(n.body for n in case.body if isinstance(n, ast.Try))
    checked = set()
    for i, node in enumerate(body):
        if not isinstance(node, ast.Assign):
            continue
        for command in ('requestToJoinPublicGroup', 'acceptJoinApplication', 'getGroupSpecificationFromServer'):
            if f'Cmd.{command}.value' in ast.unparse(node):
                previous = ast.unparse(body[i - 1]) if i else ''
                own = ast.unparse(node)
                assert (previous == "timing_pause('step.interval', module='group')"
                        or 'assert_response_eventually(' in own
                        or 'assert_eventually(' in own), (command, previous)
                checked.add(command)
    assert len(checked) == 3
