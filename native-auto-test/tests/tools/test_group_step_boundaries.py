"""Static regression for the approval example; no device calls."""
import ast
from pathlib import Path


def test_approval_pauses_before_accept_and_server_query():
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
                assert ast.unparse(body[i - 1]) == "timing_pause('step.interval', module='group')"
                checked.add(command)
    assert len(checked) == 3
