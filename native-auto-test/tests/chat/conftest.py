"""Chat 默认复用好友；无需好友或自行控制关系的 case 显式退出。"""
import pytest

from src.test_flow.friendship_setup import ensure_friendship


@pytest.fixture(autouse=True)
def ensure_friends(request):
    if request.node.get_closest_marker("no_friend_setup"):
        return
    ensure_friendship(*(request.getfixturevalue(name) for name in (
        "device_a", "device_b", "assert_api", "user_a", "user_b",
    )))
