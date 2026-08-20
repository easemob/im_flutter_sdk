from __future__ import annotations

import time

from src import Cmd, GroupChangeEvent
from src.tools.group_capacity import get_group_create_max_count

# 群组事件名已统一为 onGroupXxx（Android/iOS Wrapper 与 Python
# GroupChangeEvent 枚举一致），Case 硬编码也已对齐，无需归一化。


_GROUP_STYLE_CONFIGS: dict[int, dict[str, bool]] = {
    # 兼容 4.x case 的 style 别名；真正发给 5.0 的请求使用三个布尔字段。
    0: {"isPublic": False, "joinApprovalRequired": False, "allowInvites": False},
    1: {"isPublic": False, "joinApprovalRequired": False, "allowInvites": True},
    2: {"isPublic": True, "joinApprovalRequired": True, "allowInvites": False},
    3: {"isPublic": True, "joinApprovalRequired": False, "allowInvites": False},
}


def group_style_configs(style: int) -> dict[str, bool]:
    """将旧 style 场景别名转换为 Android 5.0 的 EMGroupConfigs 字段。"""
    try:
        return dict(_GROUP_STYLE_CONFIGS[style])
    except KeyError as error:
        raise ValueError(f"不支持的 group style: {style}; expected 0/1/2/3") from error


def build_group_options(
    *,
    style: int = 0,
    max_count: int | None = None,
    invite_need_confirm: bool = False,
    ext: str = "auto-ext",
) -> dict:
    """构造 5.0 EMGroupConfigs；style 仅作为现有 case 的兼容别名。"""
    if max_count is None:
        max_count = get_group_create_max_count()
    return {
        **group_style_configs(style),
        "maxCount": max_count,
        "inviteNeedConfirm": invite_need_confirm,
        "ext": ext,
    }


def new_group_name(prefix: str = "auto_group") -> str:
    return f"{prefix}_{int(time.time() * 1000)}"


def extract_group_id(resp: dict) -> str:
    result = resp.get("result")
    if isinstance(result, dict):
        gid = result.get("groupId")
        if isinstance(gid, str) and gid:
            return gid
    return ""


def member_count(resp: dict) -> int:
    result = resp.get("result") or {}
    value = result.get("memberCount")
    if isinstance(value, int):
        return value
    members = result.get("memberList")
    if isinstance(members, list):
        return len(members)
    return 0


def member_list(resp: dict) -> list[str]:
    result = resp.get("result") or {}
    members = result.get("memberList")
    if not isinstance(members, list):
        return []
    return [x for x in members if isinstance(x, str)]


def assert_group_members_exact(resp: dict, expected_members: list[str], *, err_prefix: str) -> None:
    actual = member_list(resp)
    assert sorted(actual) == sorted(expected_members), (
        f"{err_prefix}成员列表不一致: expected={sorted(expected_members)}, actual={sorted(actual)}, resp={resp}"
    )


def fetch_group_member_list_from_server(
    device,
    assert_api,
    *,
    group_id: str,
    device_name: str,
    page_size: int = 200,
) -> list[str]:
    """通过 5.0 分页接口获取普通成员列表（不含群主和管理员）。"""
    cursor: str | None = None
    members: list[str] = []
    while True:
        info = {"groupId": group_id, "pageSize": page_size}
        if cursor:
            info["cursor"] = cursor
        response = device.call(
            "GroupManager",
            Cmd.getGroupMemberListFromServer.value,
            info=info,
        )
        assert_api.assert_response_matches(
            response,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.getGroupMemberListFromServer.value,
                "device": device_name,
            },
            ignore_keys={"sequence", "result"},
        )
        result = response.get("result")
        assert isinstance(result, dict), (
            "getGroupMemberListFromServer result 不是分页对象: "
            f"{response}"
        )
        page = result.get("list")
        assert isinstance(page, list), (
            "getGroupMemberListFromServer result.list 不是 list: "
            f"{response}"
        )
        assert all(isinstance(member, str) and member for member in page), (
            "getGroupMemberListFromServer result.list 含非法成员: "
            f"{response}"
        )
        members.extend(page)
        next_cursor = result.get("cursor")
        assert next_cursor is None or isinstance(next_cursor, str), (
            "getGroupMemberListFromServer result.cursor 类型异常: "
            f"{response}"
        )
        if not next_cursor:
            return members
        assert next_cursor != cursor, (
            "getGroupMemberListFromServer 分页游标未前进: "
            f"cursor={cursor!r}, next_cursor={next_cursor!r}, response={response}"
        )
        cursor = next_cursor


def assert_group_members_from_server(
    device,
    assert_api,
    *,
    group_id: str,
    device_name: str,
    expected_members: list[str],
    err_prefix: str,
) -> None:
    actual = fetch_group_member_list_from_server(
        device,
        assert_api,
        group_id=group_id,
        device_name=device_name,
    )
    assert sorted(actual) == sorted(expected_members), (
        f"{err_prefix}分页成员列表不一致: expected={sorted(expected_members)}, "
        f"actual={sorted(actual)}"
    )


def event_type(evt: dict) -> str:
    v = evt.get("eventType")
    assert isinstance(v, str) and v, f"群组回调 eventType 非法: {evt}"
    return v


def collect_group_events(
    device,
    *,
    expected_event_types: set[str],
    group_id: str | None = None,
    allow_missing_group_id: bool = False,
    required_all_event_types: set[str] | None = None,
    timeout: float = 10.0,
    idle_grace_window: float = 0.8,
) -> list[dict]:
    expected_norm = set(expected_event_types)
    required_all = set(required_all_event_types or set())
    for required_type in required_all:
        assert required_type in expected_norm, (
            f"required 事件必须包含在 expected_event_types 中: required={required_type}, "
            f"expected={sorted(expected_norm)}"
        )

    deadline = time.monotonic() + timeout
    matched: list[dict] = []
    matched_types: set[str] = set()
    seen_event_types: list[str] = []
    last_matched_at = 0.0

    def _requirements_satisfied() -> bool:
        return (not required_all) or required_all.issubset(matched_types)

    while True:
        remaining = deadline - time.monotonic()
        if remaining <= 0:
            if matched and _requirements_satisfied():
                return matched
            raise AssertionError(
                "群组回调未满足期望: "
                f"required_all={sorted(required_all)}, matched={sorted(matched_types)}, "
                f"expected={sorted(expected_event_types)}, seen={seen_event_types}"
            )

        if matched and _requirements_satisfied() and (time.monotonic() - last_matched_at) >= idle_grace_window:
            return matched

        evt = device.receive_message(timeout=min(remaining, 1.0))
        items: list[dict] = []
        if isinstance(evt, dict):
            items = [evt]
        elif isinstance(evt, list):
            items = [x for x in evt if isinstance(x, dict)]
        if not items:
            continue

        now = time.monotonic()
        for item in items:
            if item.get("type") != "event":
                continue
            evt_type = item.get("eventType")
            if not isinstance(evt_type, str):
                continue
            seen_event_types.append(evt_type)
            if evt_type not in expected_norm:
                continue

            if group_id is not None:
                data = item.get("data")
                if not isinstance(data, dict):
                    continue
                actual_gid = data.get("groupId")
                if actual_gid is None:
                    if not allow_missing_group_id:
                        continue
                elif actual_gid != group_id:
                    continue

            if isinstance(item, dict):
                item["eventType"] = evt_type
            matched.append(item)
            matched_types.add(evt_type)
            last_matched_at = now


def assert_no_group_event(
    device,
    *,
    group_id: str,
    event_types: set[str],
    target_user_ids: set[str] | None = None,
    timeout: float = 2.0,
) -> None:
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        event = device.receive_message(timeout=min(0.5, deadline - time.monotonic()))
        if not isinstance(event, dict) or event.get("type") != "event":
            continue
        if event.get("eventType") not in event_types:
            continue
        data = event.get("data")
        if not isinstance(data, dict) or data.get("groupId") != group_id:
            continue
        if target_user_ids is not None:
            actual_user_ids = data.get("userIds")
            if not isinstance(actual_user_ids, list):
                raise AssertionError(f"群成员事件缺少 userIds: event={event}")
            if not set(actual_user_ids).intersection(target_user_ids):
                continue
        raise AssertionError(f"不应收到群事件: eventTypes={sorted(event_types)}, event={event}")


def _assert_any_non_empty_str_field(
    data: dict,
    field_candidates: tuple[str, ...],
    *,
    field_label: str,
    evt: dict,
    expected_value: str | None = None,
) -> None:
    for key in field_candidates:
        if key not in data:
            continue
        value = data.get(key)
        if isinstance(value, str) and value:
            if expected_value is not None:
                assert value == expected_value, (
                    f"{field_label} 字段值不匹配: expected={expected_value}, actual={value}, evt={evt}"
                )
            return
    raise AssertionError(
        f"群组回调 data 缺少有效 {field_label} 字段，候选={field_candidates}, data={data}, evt={evt}"
    )


def _assert_if_present_non_empty_str_field(
    data: dict,
    field_candidates: tuple[str, ...],
    *,
    field_label: str,
    evt: dict,
) -> None:
    exists = False
    for key in field_candidates:
        if key not in data:
            continue
        exists = True
        value = data.get(key)
        if isinstance(value, str) and value:
            return
    if exists:
        raise AssertionError(
            f"群组回调 data 的 {field_label} 字段存在但值无效，候选={field_candidates}, data={data}, evt={evt}"
        )


def _assert_any_str_field(
    data: dict,
    field_candidates: tuple[str, ...],
    *,
    field_label: str,
    evt: dict,
) -> None:
    for key in field_candidates:
        if key not in data:
            continue
        value = data.get(key)
        if isinstance(value, str):
            return
    raise AssertionError(
        f"群组回调 data 缺少有效 {field_label} 字符串字段，候选={field_candidates}, data={data}, evt={evt}"
    )


def _assert_any_dict_field(
    data: dict,
    field_candidates: tuple[str, ...],
    *,
    field_label: str,
    evt: dict,
) -> None:
    for key in field_candidates:
        if key not in data:
            continue
        value = data.get(key)
        if isinstance(value, dict):
            return
    raise AssertionError(
        f"群组回调 data 缺少有效 {field_label} 字典字段，候选={field_candidates}, data={data}, evt={evt}"
    )


def _assert_any_int_field(
    data: dict,
    field_candidates: tuple[str, ...],
    *,
    field_label: str,
    evt: dict,
) -> None:
    for key in field_candidates:
        if key not in data:
            continue
        value = data.get(key)
        if isinstance(value, int):
            return
    raise AssertionError(
        f"群组回调 data 缺少有效 {field_label} 整数字段，候选={field_candidates}, data={data}, evt={evt}"
    )


def _assert_list_field_contains_user(
    data: dict,
    field_candidates: tuple[str, ...],
    *,
    field_label: str,
    expected_member: str | None,
    evt: dict,
) -> None:
    for key in field_candidates:
        if key not in data:
            continue
        value = data.get(key)
        if isinstance(value, list) and all(isinstance(item, str) for item in value):
            if expected_member is not None:
                assert expected_member in value, (
                    f"{field_label} 不包含预期成员: expected_member={expected_member}, actual={value}, evt={evt}"
                )
            return
    raise AssertionError(
        f"群组回调 data 缺少有效 {field_label} 列表字段，候选={field_candidates}, data={data}, evt={evt}"
    )


def _assert_member_field(data: dict, *, expected_member: str | None, evt: dict) -> None:
    # administrator 是生产 Wrapper 对 onGroupAdminAdded 的成员字段
    member_keys = ("member", "userId", "username", "admin", "administrator", "applicant", "invitee", "accepter", "decliner")
    member_list_keys = ("members", "userIds", "users", "admins")
    for key in member_keys:
        if key not in data:
            continue
        value = data.get(key)
        if isinstance(value, str) and value:
            if expected_member is not None:
                assert value == expected_member, (
                    f"member 字段值不匹配: expected={expected_member}, actual={value}, evt={evt}"
                )
            return
    for key in member_list_keys:
        if key not in data:
            continue
        value = data.get(key)
        if isinstance(value, list) and all(isinstance(item, str) for item in value):
            if expected_member is not None:
                assert expected_member in value, (
                    f"members 字段不包含预期成员: expected_member={expected_member}, actual={value}, evt={evt}"
                )
            return
    raise AssertionError(f"群组回调 data 缺少成员字段(member/members)，data={data}, evt={evt}")


def _assert_member_list_field(data: dict, *, expected_members: list[str] | None, evt: dict) -> None:
    member_list_keys = ("members", "userIds", "users", "admins")
    for key in member_list_keys:
        if key not in data:
            continue
        value = data.get(key)
        if isinstance(value, list) and all(isinstance(item, str) for item in value):
            if expected_members is not None:
                missing = [m for m in expected_members if m not in value]
                assert not missing, (
                    f"members 列表缺少预期成员: missing={missing}, actual={value}, evt={evt}"
                )
            return
    raise AssertionError(f"群组回调 data 缺少成员列表字段(members/userIds/users/admins)，data={data}, evt={evt}")


def assert_group_event_data_fields(
    *,
    event_type_value: str,
    data: dict,
    expected_inviter: str | None,
    expected_member: str | None,
    evt: dict,
) -> None:
    invitation_events = {
        GroupChangeEvent.ON_INVITATION_RECEIVED.value,
        GroupChangeEvent.ON_AUTO_ACCEPT_INVITATION.value,
        "onGroupAutoAcceptInvitation",
    }
    if event_type_value in invitation_events:
        _assert_any_non_empty_str_field(
            data,
            ("inviter", "from", "operator", "operatorId"),
            field_label="inviter",
            expected_value=expected_inviter,
            evt=evt,
        )
        _assert_if_present_non_empty_str_field(
            data,
            ("groupName", "name"),
            field_label="groupName",
            evt=evt,
        )
        return

    request_join_received_events = {
        GroupChangeEvent.ON_REQUEST_TO_JOIN_RECEIVED.value,
        "onGroupRequestToJoinReceived",
        "onGroupRequestToJoinReceived",
    }
    if event_type_value in request_join_received_events:
        _assert_member_field(data, expected_member=expected_member, evt=evt)
        _assert_if_present_non_empty_str_field(
            data,
            ("reason", "message", "application"),
            field_label="reason",
            evt=evt,
        )
        return

    request_join_accepted_events = {
        GroupChangeEvent.ON_REQUEST_TO_JOIN_ACCEPTED.value,
        "onGroupRequestToJoinAccepted",
        "onGroupRequestToJoinAccepted",
    }
    if event_type_value in request_join_accepted_events:
        _assert_any_non_empty_str_field(
            data,
            ("accepter", "accepter", "operator", "operatorId", "owner", "admin"),
            field_label="accepter",
            evt=evt,
        )
        return

    request_join_declined_events = {
        GroupChangeEvent.ON_REQUEST_TO_JOIN_DECLINED.value,
        "onGroupRequestToJoinDeclined",
        "onGroupRequestToJoinDeclined",
    }
    if event_type_value in request_join_declined_events:
        _assert_any_non_empty_str_field(
            data,
            ("decliner", "operator", "operatorId", "owner", "admin"),
            field_label="decliner",
            evt=evt,
        )
        _assert_if_present_non_empty_str_field(
            data,
            ("reason", "message"),
            field_label="reason",
            evt=evt,
        )
        return

    if event_type_value == "onGroupMemberJoined":
        _assert_member_field(data, expected_member=expected_member, evt=evt)
        return

    if event_type_value in {"onGroupMembersJoined", "onGroupMembersExited"}:
        expected_members = [expected_member] if expected_member else None
        _assert_member_list_field(data, expected_members=expected_members, evt=evt)
        return

    if event_type_value == "onGroupWhiteListRemoved":
        _assert_list_field_contains_user(
            data,
            ("members", "whitelist", "allowList"),
            field_label="allowList",
            expected_member=expected_member,
            evt=evt,
        )
        return

    admin_events = {
        GroupChangeEvent.ON_ADMIN_ADDED.value,
        GroupChangeEvent.ON_ADMIN_REMOVED.value,
        "onGroupAdminAdded",
        "onGroupAdminRemoved",
    }
    if event_type_value in admin_events:
        _assert_member_field(data, expected_member=expected_member, evt=evt)
        return

    if event_type_value in {GroupChangeEvent.ON_OWNER_CHANGED.value, "onGroupOwnerChanged"}:
        _assert_any_non_empty_str_field(
            data,
            ("newOwner", "owner", "to"),
            field_label="newOwner",
            evt=evt,
        )
        _assert_any_non_empty_str_field(
            data,
            ("oldOwner", "from", "operator", "operatorId"),
            field_label="oldOwner",
            evt=evt,
        )
        return

    mute_list_events = {
        GroupChangeEvent.ON_MUTE_LIST_ADDED.value,
        GroupChangeEvent.ON_MUTE_LIST_REMOVED.value,
    }
    if event_type_value in mute_list_events:
        _assert_list_field_contains_user(
            data,
            ("members", "muted", "mutes", "muteList"),  # 5.0 两端事件字段为 mutes
            field_label="muteList",
            expected_member=expected_member,
            evt=evt,
        )
        return

    white_list_events = {
        GroupChangeEvent.ON_WHITE_LIST_ADDED.value,
        GroupChangeEvent.ON_WHITE_LIST_REMOVED.value,
    }
    if event_type_value in white_list_events:
        _assert_list_field_contains_user(
            data,
            ("members", "whitelist", "allowList"),
            field_label="whiteList",
            expected_member=expected_member,
            evt=evt,
        )
        return

    if event_type_value == GroupChangeEvent.ON_ALL_MEMBER_MUTE_STATE_CHANGED.value:
        state_keys = ("isMuted", "isAllMemberMuted", "muteAll")
        for key in state_keys:
            if key in data:
                assert isinstance(data.get(key), bool), f"全员禁言状态字段非 bool: key={key}, data={data}, evt={evt}"
                return
        raise AssertionError(f"全员禁言回调缺少状态字段: keys={state_keys}, data={data}, evt={evt}")

    if event_type_value in {
        GroupChangeEvent.ON_ATTRIBUTES_CHANGED_OF_MEMBER.value,
        "onGroupAttributesChangedOfMember",
        "onGroupAttributesChangedOfMember",
    }:
        _assert_member_field(data, expected_member=expected_member, evt=evt)
        _assert_any_dict_field(
            data,
            ("attributes", "attrs", "attributeMap"),
            field_label="attributes",
            evt=evt,
        )
        return

    removed_events = {
        GroupChangeEvent.ON_USER_REMOVED.value,
        "onGroupUserRemoved",
    }
    if event_type_value in removed_events:
        assert any(isinstance(data.get(key), str) for key in ("groupName", "name")), (
            f"群组回调 data 缺少 groupName/name 字符串字段，data={data}, evt={evt}"
        )
        return

    # onGroupMemberExited 的 SDK 回调只带 groupId + member，无 groupName
    if event_type_value == "onGroupMemberExited":
        _assert_member_field(data, expected_member=expected_member, evt=evt)
        return

    invitation_feedback_events = {
        GroupChangeEvent.ON_INVITATION_ACCEPTED.value,
        GroupChangeEvent.ON_INVITATION_DECLINED.value,
        "onGroupInvitationAccepted",
        "onGroupInvitationDeclined",
    }
    if event_type_value in invitation_feedback_events:
        _assert_member_field(data, expected_member=expected_member, evt=evt)
        _assert_if_present_non_empty_str_field(
            data,
            ("reason", "message"),
            field_label="reason",
            evt=evt,
        )
        return

    if event_type_value in {GroupChangeEvent.ON_SHARED_FILE_ADDED.value, "onGroupSharedFileAdded"}:
        _assert_any_dict_field(
            data,
            ("sharedFile", "file"),
            field_label="sharedFile",
            evt=evt,
        )
        return

    if event_type_value in {GroupChangeEvent.ON_SHARED_FILE_DELETED.value, "onGroupSharedFileDeleted"}:
        _assert_any_str_field(
            data,
            ("fileId", "id"),
            field_label="fileId",
            evt=evt,
        )
        return

    if event_type_value in {
        GroupChangeEvent.ON_SPECIFICATION_DID_UPDATE.value,
        "onGroupSpecificationDidUpdate",
    }:
        _assert_any_dict_field(
            data,
            ("group",),
            field_label="group",
            evt=evt,
        )
        group = data.get("group")
        if isinstance(group, dict):
            _assert_any_non_empty_str_field(
                group,
                ("groupId",),
                field_label="groupId",
                evt=evt,
            )
        return

    if event_type_value == GroupChangeEvent.ON_GROUP_DESTROYED.value:
        _assert_any_str_field(
            data,
            ("groupName", "name"),
            field_label="groupName",
            evt=evt,
        )


def assert_group_event(
    assert_api,
    evt: dict,
    *,
    event_type_value: str,
    group_id: str,
    allow_missing_group_id: bool = False,
    expected_inviter: str | None = None,
    expected_member: str | None = None,
) -> None:
    assert_api.assert_response_matches(
        evt,
        expected={
            "type": "event",
            "eventType": event_type_value,
        },
        ignore_keys={"timestamp", "sequence", "data"},
    )
    assert "data" in evt, f"群组回调缺少 data 字段: {evt}"
    data = evt.get("data")
    assert isinstance(data, dict), f"群组回调 data 不是 dict: {evt}"
    if not allow_missing_group_id or "groupId" in data:
        assert data.get("groupId") == group_id, f"群组回调 groupId 不匹配: expected={group_id}, actual={evt}"
    assert_group_event_data_fields(
        event_type_value=event_type_value,
        data=data,
        expected_inviter=expected_inviter,
        expected_member=expected_member,
        evt=evt,
    )


def assert_group_events(
    assert_api,
    events: list[dict],
    *,
    expected_event_types: set[str],
    group_id: str,
    allow_missing_group_id: bool = False,
    required_all_event_types: set[str] | None = None,
    expected_inviter: str | None = None,
    expected_member: str | None = None,
) -> None:
    assert events, "群组回调列表为空"
    expected_norm = set(expected_event_types)
    required_all = set(required_all_event_types or set())
    seen_types: set[str] = set()

    for evt in events:
        evt_type = event_type(evt)
        assert evt_type in expected_norm, (
            f"群组回调事件类型不在 expected 中: eventType={evt_type}, expected={sorted(expected_event_types)}, evt={evt}"
        )
        assert_group_event(
            assert_api,
            evt,
            event_type_value=evt_type,
            group_id=group_id,
            allow_missing_group_id=allow_missing_group_id,
            expected_inviter=expected_inviter,
            expected_member=expected_member,
        )
        seen_types.add(evt_type)

    if required_all:
        missing = required_all - seen_types
        assert not missing, (
            f"群组回调缺少必选事件: missing={sorted(missing)}, seen={sorted(seen_types)}, "
            f"required_all={sorted(required_all)}"
        )


def assert_group_snapshot(
    assert_api,
    resp: dict,
    *,
    cmd: str,
    group_id: str,
    group_name: str,
    owner: str,
    expected_desc: str = "auto-test group",
    expected_ext: str = "auto-ext",
    max_user_count_value: int | None = None,
    member_count_value: int | None = None,
    member_list_value: list[str] | None = None,
    admin_list_value: list[str] | None = None,
    block_list_value: list[str] | None = None,
    mute_list_value: list[str] | None = None,
    allow_list_value: list[str] | None = None,
    is_member_allow_to_invite: bool = False,
    is_public: bool = False,
    join_approval_required: bool = False,
    is_all_member_muted: bool = False,
    message_blocked: bool = False,
    permission_type: int = 2,
    device: str = "deviceA",
) -> None:
    if max_user_count_value is None:
        max_user_count_value = get_group_create_max_count()

    expected_result = {
        "groupId": group_id,
        "name": group_name,
        "owner": owner,
        "desc": expected_desc,
        "ext": expected_ext,
        "announcement": "",
        "avatarUrl": "",
        "maxUserCount": max_user_count_value,
        "adminList": admin_list_value or [],
        "blockList": [],
        "muteList": [],
        "isDisabled": False,
        "isAllMemberMuted": is_all_member_muted,
        "permissionType": permission_type,
        "isPublic": is_public,
        "joinApprovalRequired": join_approval_required,
        "isMemberAllowToInvite": is_member_allow_to_invite,
        "messageBlocked": message_blocked,
    }
    # 最小忽略：固定保留 sequence；对端侧可能漂移的辅助字段按不确定字段处理
    ignore_keys = {"sequence", "noticeEnable"}
    if member_count_value is None:
        ignore_keys.add("memberCount")
    else:
        expected_result["memberCount"] = member_count_value
    if member_list_value is None:
        ignore_keys.add("memberList")
    else:
        expected_result["memberList"] = member_list_value
    if block_list_value is None:
        ignore_keys.add("blockList")
    else:
        expected_result["blockList"] = block_list_value
    if mute_list_value is None:
        ignore_keys.add("muteList")
    else:
        expected_result["muteList"] = mute_list_value
    if allow_list_value is None:
        ignore_keys.add("allowList")
    else:
        expected_result["allowList"] = allow_list_value

    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "GroupManager",
            "cmd": cmd,
            "device": device,
            "result": expected_result,
        },
        ignore_keys=ignore_keys,
    )


def assert_group_list_response(
    assert_api,
    resp: dict,
    *,
    cmd: str,
    device: str = "deviceA",
) -> list[dict]:
    """断言群列表接口响应信封，并校验 result 为群对象列表。"""
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "GroupManager",
            "cmd": cmd,
            "device": device,
        },
        ignore_keys={"sequence", "result"},
    )

    result = resp.get("result")
    assert isinstance(result, list), f"{cmd} result 不是 list: {resp}"

    for idx, item in enumerate(result):
        assert isinstance(item, dict), f"{cmd} result[{idx}] 不是 dict: {item!r}"
        group_id = item.get("groupId")
        owner = item.get("owner")
        name = item.get("name")
        assert isinstance(group_id, str) and group_id, f"{cmd} result[{idx}].groupId 非法: {item!r}"
        assert isinstance(owner, str) and owner, f"{cmd} result[{idx}].owner 非法: {item!r}"
        assert isinstance(name, str), f"{cmd} result[{idx}].name 非法: {item!r}"

    return result


def find_group_in_list(groups: list[dict], group_id: str) -> dict | None:
    for item in groups:
        if not isinstance(item, dict):
            continue
        if item.get("groupId") == group_id:
            return item
    return None


def create_group(
    device_a,
    assert_api,
    *,
    owner: str,
    group_name: str,
    invite_members: list[str],
    style: int = 0,
    max_count: int | None = None,
    invite_need_confirm: bool = False,
    expected_member_count: int | None = None,
    device_name: str = "deviceA",
    is_member_allow_to_invite: bool | None = None,
):
    if max_count is None:
        max_count = get_group_create_max_count()

    configs = group_style_configs(style)
    resp_create = device_a.call(
        "GroupManager",
        Cmd.createGroup.value,
        info={
            "groupName": group_name,
            "desc": "auto-test group",
            "inviteMembers": invite_members,
            "inviteReason": "auto-case",
            "options": {
                **configs,
                "maxCount": max_count,
                "inviteNeedConfirm": invite_need_confirm,
                "ext": "auto-ext",
            },
        },
    )
    gid = extract_group_id(resp_create)
    assert gid, f"createGroup 返回中未获取到 groupId: {resp_create}"
    assert_group_snapshot(
        assert_api,
        resp_create,
        cmd=Cmd.createGroup.value,
        group_id=gid,
        group_name=group_name,
        owner=owner,
        member_count_value=(1 + len(invite_members) if expected_member_count is None else expected_member_count),
        max_user_count_value=max_count,
        # 快照字段必须和创建请求中的 5.0 configs 保持一致；可显式传参覆盖
        is_member_allow_to_invite=(
            is_member_allow_to_invite
            if is_member_allow_to_invite is not None
            else configs["allowInvites"]
        ),
        is_public=configs["isPublic"],
        join_approval_required=configs["joinApprovalRequired"],
        device=device_name,
    )
    return gid, resp_create


def destroy_group(
    device_a,
    assert_api,
    group_id: str,
    *,
    device_b=None,
    device_name: str = "deviceA",
):
    resp_destroy = device_a.call("GroupManager", Cmd.destroyGroup.value, info={"groupId": group_id})
    assert_api.assert_response_matches(
        resp_destroy,
        expected={
            "manager": "GroupManager",
            "cmd": Cmd.destroyGroup.value,
            "device": device_name,
            "result": True,
        },
        ignore_keys={"sequence"},
    )
    if device_b is not None:
        expected = {GroupChangeEvent.ON_GROUP_DESTROYED.value}
        events = collect_group_events(
            device_b,
            expected_event_types=expected,
            group_id=group_id,
            required_all_event_types=expected,
            timeout=10.0,
        )
        assert_group_events(
            assert_api,
            events,
            expected_event_types=expected,
            group_id=group_id,
            required_all_event_types=expected,
        )
