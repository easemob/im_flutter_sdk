"""
Presence 在线状态用例，对应 presence_manager.dart。
场景：A 发布 presence，B 订阅 A → B 查询 A 的在线状态与订阅列表 → B 取消订阅 → 再次查询应返回空。
"""
from __future__ import annotations

from contextlib import nullcontext

import pytest

from src import Cmd
from src import gt, ne

pytestmark = [pytest.mark.client, pytest.mark.presence]

# 用户 A/B 由 conftest 的 created_test_users 创建，teardown 删除；用例中注入 user_a / user_b

# 订阅有效期（秒），不超过 30 天
PRESENCE_EXPIRY = 3600

# 30 天（秒），用于「过期时间大于 30 天」的非法参数测试
SECONDS_30_DAYS = 30 * 24 * 3600

# 不存在的用户 ID，用于订阅不存在用户的测试
USER_NONEXISTENT = "nonexistent_user_xyz_999"


def _allure_step(name: str):
    try:
        import allure

        return allure.step(name)
    except ImportError:
        return nullcontext()


@pytest.mark.topology("account_a_to_account_b")
def test_presence_publish_subscribe_query_unsubscribe(topology, assert_api):
    """
    多端拓扑：A 发布 presence（动作端）；B 订阅 A，订阅关系为账号级 → B 全部在线端查询订阅列表一致；
    B 取消订阅后全部端查询为空。
    """
    sender = topology.sender_action_device            # A 主端（发布 presence）
    subscriber = topology.recipient_action_device     # B 主端（订阅/取消）
    recipients = topology.recipient_devices           # B 主端 + B 副端（订阅关系账号级共享）
    publisher_user = topology.sender_user             # user_a（被订阅者）

    with _allure_step("测试准备：清理收发账号全部端的历史事件"):
        for device in (*topology.sender_devices, *recipients):
            device.drain_events(timeout=0.5)

    with _allure_step(f"{sender.device_name} 发布在线状态 online"):
        resp_pub = sender.call(
            "PresenceManager",
            Cmd.presenceWithDescription.value,
            info={"desc": "online"},
        )
    with _allure_step("确认发布请求已提交"):
        assert_api.assert_response_matches(
            resp_pub,
            expected={
                "manager": "PresenceManager",
                "cmd": Cmd.presenceWithDescription.value,
                "device": sender.device_name,
                "result": True,
            },
            ignore_keys={"sequence"},
        )

    with _allure_step("A 全部在线端查询自己的状态均为 online（账号级服务端状态同步）"):
        for endpoint in topology.sender_devices:
            resp_status = endpoint.call(
                "PresenceManager",
                Cmd.fetchPresenceStatus.value,
                info={"members": [publisher_user]},
            )
            assert_api.assert_response_matches(
                resp_status,
                expected={
                    "manager": "PresenceManager",
                    "cmd": Cmd.fetchPresenceStatus.value,
                    "device": endpoint.device_name,
                    "result": [{"statusDescription": "online", "publisher": publisher_user, "expiryTime": gt(0)}],
                },
                ignore_keys={"sequence", "lastTime", "statusDetails"},
            )

    with _allure_step(f"{subscriber.device_name} 订阅 A 的在线状态"):
        resp_sub = subscriber.call(
            "PresenceManager",
            Cmd.presenceSubscribe.value,
            info={"members": [publisher_user], "expiry": PRESENCE_EXPIRY},
        )
    with _allure_step("确认订阅请求已提交且返回 A 当前状态"):
        assert_api.assert_response_matches(
            resp_sub,
            expected={
                "manager": "PresenceManager",
                "cmd": Cmd.presenceSubscribe.value,
                "device": subscriber.device_name,
                "result": [{"statusDescription": "online", "publisher": publisher_user, "expiryTime": gt(0)}],
            },
            ignore_keys={"sequence", "lastTime", "statusDetails"},
        )

    with _allure_step("B 全部在线端查询订阅列表均含 A（订阅关系账号级共享）"):
        for endpoint in recipients:
            resp_members = endpoint.call(
                "PresenceManager",
                Cmd.fetchSubscribedMembersWithPageNum.value,
                info={"pageNum": 1, "pageSize": 20},
            )
            assert_api.assert_response_matches(
                resp_members,
                expected={
                    "manager": "PresenceManager",
                    "cmd": Cmd.fetchSubscribedMembersWithPageNum.value,
                    "device": endpoint.device_name,
                    "result": [publisher_user],
                },
                ignore_keys={"sequence"},
            )

    with _allure_step(f"{subscriber.device_name} 取消订阅 A"):
        resp_unsub = subscriber.call(
            "PresenceManager",
            Cmd.presenceUnsubscribe.value,
            info={"members": [publisher_user]},
        )
    with _allure_step("确认取消订阅请求已提交"):
        assert_api.assert_response_matches(
            resp_unsub,
            expected={
                "manager": "PresenceManager",
                "cmd": Cmd.presenceUnsubscribe.value,
                "device": subscriber.device_name,
                "result": None,
            },
            ignore_keys={"sequence"},
        )

    with _allure_step("B 全部在线端再次查询订阅列表均为空"):
        for endpoint in recipients:
            resp_after = endpoint.call(
                "PresenceManager",
                Cmd.fetchSubscribedMembersWithPageNum.value,
                info={"pageNum": 1, "pageSize": 20},
            )
            assert_api.assert_response_matches(
                resp_after,
                expected={
                    "manager": "PresenceManager",
                    "cmd": Cmd.fetchSubscribedMembersWithPageNum.value,
                    "device": endpoint.device_name,
                    "result": [],
                },
                ignore_keys={"sequence"},
            )


@pytest.mark.topology("account_a_to_account_b")
def test_presence_publish_empty_desc_then_fetch(topology, assert_api):
    """
    多端拓扑：A 发布空 desc 在线状态；A 全部端查询状态 desc 为空；B 订阅后，B 全部端查询 A 状态 desc 也为空。
    """
    sender = topology.sender_action_device        # A 主端（发布空 desc）
    subscriber = topology.recipient_action_device  # B 主端（订阅）
    publisher_user = topology.sender_user          # user_a（被订阅者）

    with _allure_step("测试准备：清理收发账号全部端的历史事件"):
        for device in (*topology.sender_devices, *topology.recipient_devices):
            device.drain_events(timeout=0.5)

    with _allure_step(f"{sender.device_name} 发布空 desc 的在线状态"):
        resp_pub = sender.call(
            "PresenceManager",
            Cmd.presenceWithDescription.value,
            info={"desc": ""},
        )
    with _allure_step("确认发布请求已提交"):
        assert_api.assert_response_matches(
            resp_pub,
            expected={
                "manager": "PresenceManager",
                "cmd": Cmd.presenceWithDescription.value,
                "device": sender.device_name,
                "result": True,
            },
            ignore_keys={"sequence"},
        )

    with _allure_step("A 全部在线端查询自己的状态 desc 均为空（账号级服务端状态同步）"):
        for endpoint in topology.sender_devices:
            resp_status = endpoint.call(
                "PresenceManager",
                Cmd.fetchPresenceStatus.value,
                info={"members": [publisher_user]},
            )
            assert_api.assert_response_matches(
                resp_status,
                expected={
                    "manager": "PresenceManager",
                    "cmd": Cmd.fetchPresenceStatus.value,
                    "device": endpoint.device_name,
                    "result": [{"statusDescription": "", "publisher": publisher_user}],
                },
                ignore_keys={"sequence", "lastTime", "expiryTime", "statusDetails"},
            )

    with _allure_step(f"{subscriber.device_name} 订阅 A 的在线状态"):
        resp_sub = subscriber.call(
            "PresenceManager",
            Cmd.presenceSubscribe.value,
            info={"members": [publisher_user], "expiry": PRESENCE_EXPIRY},
        )
    with _allure_step("确认订阅请求已提交"):
        assert_api.assert_response_matches(
            resp_sub,
            expected={
                "manager": "PresenceManager",
                "cmd": Cmd.presenceSubscribe.value,
                "device": subscriber.device_name,
                "result": [{"statusDescription": "", "publisher": publisher_user}],
            },
            ignore_keys={"sequence", "lastTime", "expiryTime", "statusDetails"},
        )

    with _allure_step("B 全部在线端查询 A 状态 desc 均为空"):
        for endpoint in topology.recipient_devices:
            resp_status = endpoint.call(
                "PresenceManager",
                Cmd.fetchPresenceStatus.value,
                info={"members": [publisher_user]},
            )
            assert_api.assert_response_matches(
                resp_status,
                expected={
                    "manager": "PresenceManager",
                    "cmd": Cmd.fetchPresenceStatus.value,
                    "device": endpoint.device_name,
                    "result": [{"statusDescription": "", "publisher": publisher_user}],
                },
                ignore_keys={"sequence", "lastTime", "expiryTime", "statusDetails"},
            )


# 128KB 字符，用于 desc 上限/大体积测试
DESC_128K = "x" * (128 * 1024)


def test_presence_publish_128k_desc(device_a, device_b, assert_api):
    """
    A 发布 128KB 大小 desc 的在线状态
    """
    # 1. A 发布 128k desc
    resp_pub = device_a.call(
        "PresenceManager",
        Cmd.presenceWithDescription.value,
        info={"desc": DESC_128K},
    )
    assert_api.assert_response_matches(
        resp_pub,
        expected={
            "manager": "PresenceManager",
            "cmd": Cmd.presenceWithDescription.value,
            "device": "{{device}}",
            "result": {
		        "description": "Presence parameter length is exceeded",
		        "code": 1100
	        },
        },
        context={"device": "deviceA"},
        ignore_keys={"sequence"},
    )


def test_presence_subscribe_nonexistent_user(device_a, assert_api):
    """
    订阅不存在用户：B 对不存在用户发起 presenceSubscribe。
    """
    resp = device_a.call(
        "PresenceManager",
        Cmd.presenceSubscribe.value,
        info={"members": [USER_NONEXISTENT], "expiry": PRESENCE_EXPIRY},
    )
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "PresenceManager",
            "cmd": Cmd.presenceSubscribe.value,
            "device": "{{device}}",
            "result": [{"statusDescription": "", "publisher": "{{publisher}}", "expiryTime": gt(0),"statusDetails":{},"lastTime":0}],
        },
        context={"device": "deviceA", "publisher": USER_NONEXISTENT},
        ignore_keys={"sequence"},
    )


def test_presence_subscribe_expiry_over_30_days(device_a, device_b, assert_api, user_a):
    """
    订阅存在用户但过期时间大于 30 天：B 订阅 A，expiry 设为超过 30 天，预期返回错误。
    """
    # A 先发布 presence，确保 A 存在且在线
    resp_pub = device_a.call(
        "PresenceManager",
        Cmd.presenceWithDescription.value,
        info={"desc": "online"},
    )
    assert_api.assert_success(resp_pub)
    # B 订阅 A，但 expiry 超过 30 天（30*24*3600 + 1 秒）
    resp = device_b.call(
        "PresenceManager",
        Cmd.presenceSubscribe.value,
        info={"members": [user_a], "expiry": SECONDS_30_DAYS + 1},
    )
    assert_api.assert_error(resp)


# presenceSubscribe / presenceUnsubscribe 单次成员数上限（超过则预期报错）
PRESENCE_SUBSCRIBE_MAX_MEMBERS = 100


def test_presence_subscribe_over_100_members(device_a, assert_api):
    """
    订阅超过 100 个用户：presenceSubscribe 传入超过 100 个 members，预期返回错误。
    """
    members_over_limit = [f"user_{i}" for i in range(PRESENCE_SUBSCRIBE_MAX_MEMBERS + 1)]
    resp = device_a.call(
        "PresenceManager",
        Cmd.presenceSubscribe.value,
        info={"members": members_over_limit, "expiry": PRESENCE_EXPIRY},
    )
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "PresenceManager",
            "cmd": Cmd.presenceSubscribe.value,
            "device": "{{device}}",
            "result": {
                "description": "Presence parameter length is exceeded",
                "code": 1100
            },
        },
        context={"device": "deviceA"},
        ignore_keys={"sequence"},
    )


def test_presence_unsubscribe_over_100_members(device_b, assert_api):
    """
    取消订阅超过 100 个用户：presenceUnsubscribe 传入超过 100 个 members，预期返回错误。
    """
    members_over_limit = [f"user_{i}" for i in range(PRESENCE_SUBSCRIBE_MAX_MEMBERS + 1)]
    resp = device_b.call(
        "PresenceManager",
        Cmd.presenceUnsubscribe.value,
        info={"members": members_over_limit},
    )
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "PresenceManager",
            "cmd": Cmd.presenceUnsubscribe.value,
            "device": "{{device}}",
            "result": {
                "description": "Presence parameter length is exceeded",
                "code": 1100
            },
        },
        context={"device": "deviceB"},
        ignore_keys={"sequence"},
    )

# ---------- fetchSubscribedMembersWithPageNum 分页测试 ----------


def test_fetch_subscribed_members_pagination(device_a, device_b, assert_api, user_a):
    """
    分页查询订阅列表：B 订阅 A 后，第 1 页有数据，第 2 页为空。
    """
    # 准备：A 发布，B 订阅 A
    resp_pub = device_a.call(
        "PresenceManager",
        Cmd.presenceWithDescription.value,
        info={"desc": "online"},
    )
    assert_api.assert_success(resp_pub)
    resp_sub = device_b.call(
        "PresenceManager",
        Cmd.presenceSubscribe.value,
        info={"members": [user_a], "expiry": PRESENCE_EXPIRY},
    )
    assert_api.assert_success(resp_sub)

    # 第 1 页：pageNum=1, pageSize=20，应返回 [user_a]
    resp_p1 = device_b.call(
        "PresenceManager",
        Cmd.fetchSubscribedMembersWithPageNum.value,
        info={"pageNum": 1, "pageSize": 20},
    )
    assert_api.assert_response_matches(
        resp_p1,
        expected={
            "manager": "PresenceManager",
            "cmd": Cmd.fetchSubscribedMembersWithPageNum.value,
            "device": "{{device}}",
            "result": ["{{publisher}}"],
        },
        context={"device": "deviceB", "publisher": user_a},
        ignore_keys={"sequence"},
    )

    # 第 2 页：应为空列表
    resp_p2 = device_b.call(
        "PresenceManager",
        Cmd.fetchSubscribedMembersWithPageNum.value,
        info={"pageNum": 2, "pageSize": 20},
    )
    assert_api.assert_response_matches(
        resp_p2,
        expected={
            "manager": "PresenceManager",
            "cmd": Cmd.fetchSubscribedMembersWithPageNum.value,
            "device": "{{device}}",
            "result": [],
        },
        context={"device": "deviceB"},
        ignore_keys={"sequence"},
    )


def test_fetch_subscribed_members_pagination_page_size_one(device_a, device_b, assert_api, user_a):
    """
    分页 pageSize=1：第 1 页 1 条，第 2 页 0 条。
    """
    resp_pub = device_a.call(
        "PresenceManager",
        Cmd.presenceWithDescription.value,
        info={"desc": "online"},
    )
    assert_api.assert_success(resp_pub)
    resp_sub = device_b.call(
        "PresenceManager",
        Cmd.presenceSubscribe.value,
        info={"members": [user_a], "expiry": PRESENCE_EXPIRY},
    )
    assert_api.assert_success(resp_sub)

    resp_1 = device_b.call(
        "PresenceManager",
        Cmd.fetchSubscribedMembersWithPageNum.value,
        info={"pageNum": 1, "pageSize": 1},
    )
    assert_api.assert_response_matches(
        resp_1,
        expected={
            "manager": "PresenceManager",
            "cmd": Cmd.fetchSubscribedMembersWithPageNum.value,
            "device": "{{device}}",
            "result": ["{{publisher}}"],
        },
        context={"device": "deviceB", "publisher": user_a},
        ignore_keys={"sequence"},
    )

    resp_2 = device_b.call(
        "PresenceManager",
        Cmd.fetchSubscribedMembersWithPageNum.value,
        info={"pageNum": 2, "pageSize": 1},
    )
    assert_api.assert_response_matches(
        resp_2,
        expected={
            "manager": "PresenceManager",
            "cmd": Cmd.fetchSubscribedMembersWithPageNum.value,
            "device": "{{device}}",
            "result": [],
        },
        context={"device": "deviceB"},
        ignore_keys={"sequence"},
    )


def test_fetch_subscribed_members_invalid_pagination(device_b, assert_api, user_a):
    """
    非法分页参数：pageNum=0 或 pageSize=0，预期返回错误。
    """
    resp_zero_page = device_b.call(
        "PresenceManager",
        Cmd.fetchSubscribedMembersWithPageNum.value,
        info={"pageNum": 0, "pageSize": 20},
    )
    # pageNum 从 1 开始时，0 可能报错；若服务端从 0 开始则改为断言成功并校验结果
    assert_api.assert_response_matches(
        resp_zero_page,
        expected={
            "manager": "PresenceManager",
            "cmd": Cmd.fetchSubscribedMembersWithPageNum.value,
            "device": "{{device}}",
            "result": ["{{publisher}}"],
        },
        context={"device": "deviceB", "publisher": user_a},
        ignore_keys={"sequence"},
    )

    resp_zero_size = device_b.call(
        "PresenceManager",
        Cmd.fetchSubscribedMembersWithPageNum.value,
        info={"pageNum": 1, "pageSize": 0},
    )
    assert_api.assert_error(resp_zero_size)
