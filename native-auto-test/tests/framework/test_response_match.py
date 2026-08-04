import pytest

from src.tools.response_match import assert_response_matches


def test_success_expectation_with_error_result_reports_business_summary():
    actual = {
        "manager": "ChatManager",
        "cmd": "modifyMessage",
        "result": {"code": 305, "description": "Sorry, edit is not available"},
    }
    expected = {
        "manager": "ChatManager",
        "cmd": "modifyMessage",
        "result": {"msgId": "m1", "body": {"type": 7}},
    }

    with pytest.raises(AssertionError) as error:
        assert_response_matches(actual, expected)

    message = str(error.value)
    assert "ChatManager.modifyMessage 未成功执行：code=305" in message
    assert "Sorry, edit is not available" in message
    assert "msgId" not in message
