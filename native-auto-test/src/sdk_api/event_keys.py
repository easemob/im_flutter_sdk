"""
SDK 回调事件枚举，与 im_flutter_sdk em_event_keys.dart 一一对应。
用于识别 WebSocket 下发的 type=event 消息中的 eventType。
"""
from enum import Enum


class ContactChangeEvent(str, Enum):
    """联系人变更事件，对应 EMContactChangeEvent。"""

    CONTACT_ADD = "onContactAdded"
    CONTACT_DELETE = "onContactDeleted"
    INVITED = "onContactInvited"
    INVITATION_ACCEPTED = "onFriendRequestAccepted"
    INVITATION_DECLINED = "onFriendRequestDeclined"
    CONTACT_INFO_UPDATE = "onContactInfoUpdate"


class ChatRoomEvent(str, Enum):
    """聊天室事件，对应 EMChatRoomEvent。"""

    ON_CHAT_ROOM_DESTROYED = "onRoomDestroyed"
    ON_MEMBER_JOINED = "onRoomMemberJoined"
    ON_MEMBER_EXITED = "onRoomMemberExited"
    ON_REMOVED_FROM_CHAT_ROOM = "onRoomRemoved"
    ON_MUTE_LIST_ADDED = "onRoomMuteListAdded"
    ON_MUTE_LIST_REMOVED = "onRoomMuteListRemoved"
    ON_ADMIN_ADDED = "onRoomAdminAdded"
    ON_ADMIN_REMOVED = "onRoomAdminRemoved"
    ON_OWNER_CHANGED = "onRoomOwnerChanged"
    ON_ANNOUNCEMENT_CHANGED = "onRoomAnnouncementChanged"
    ON_WHITE_LIST_REMOVED = "onRoomWhiteListRemoved"
    ON_WHITE_LIST_ADDED = "onRoomWhiteListAdded"
    ON_ALL_MEMBER_MUTE_STATE_CHANGED = "onRoomAllMemberMuteStateChanged"
    ON_SPECIFICATION_CHANGED = "onRoomSpecificationChanged"
    ON_ATTRIBUTES_UPDATED = "onRoomAttributesDidUpdated"
    ON_ATTRIBUTES_REMOVED = "onRoomAttributesDidRemoved"


class GroupChangeEvent(str, Enum):
    """群组变更事件，对应 EMGroupChangeEvent。"""

    ON_INVITATION_RECEIVED = "onGroupInvitationReceived"
    ON_INVITATION_ACCEPTED = "onGroupInvitationAccepted"
    ON_INVITATION_DECLINED = "onGroupInvitationDeclined"
    ON_AUTO_ACCEPT_INVITATION = "onGroupAutoAcceptInvitation"
    ON_USER_REMOVED = "onGroupUserRemoved"
    ON_REQUEST_TO_JOIN_RECEIVED = "onGroupRequestToJoinReceived"
    ON_REQUEST_TO_JOIN_DECLINED = "onGroupRequestToJoinDeclined"
    ON_REQUEST_TO_JOIN_ACCEPTED = "onGroupRequestToJoinAccepted"
    ON_GROUP_DESTROYED = "onGroupDestroyed"
    ON_MUTE_LIST_ADDED = "onGroupMuteListAdded"
    ON_MUTE_LIST_REMOVED = "onGroupMuteListRemoved"
    ON_ADMIN_ADDED = "onGroupAdminAdded"
    ON_ADMIN_REMOVED = "onGroupAdminRemoved"
    ON_OWNER_CHANGED = "onGroupOwnerChanged"
    ON_MEMBER_JOINED = "onGroupMemberJoined"
    ON_MEMBER_EXITED = "onGroupMemberExited"
    ON_ANNOUNCEMENT_CHANGED = "onGroupAnnouncementChanged"
    ON_SHARED_FILE_ADDED = "onGroupSharedFileAdded"
    ON_SHARED_FILE_DELETED = "onGroupSharedFileDeleted"
    ON_WHITE_LIST_REMOVED = "onGroupWhiteListRemoved"
    ON_WHITE_LIST_ADDED = "onGroupWhiteListAdded"
    ON_ALL_MEMBER_MUTE_STATE_CHANGED = "onGroupAllMemberMuteStateChanged"
    ON_SPECIFICATION_DID_UPDATE = "onGroupSpecificationDidUpdate"
    ON_STATE_CHANGED = "onGroupStateChanged"
    ON_ATTRIBUTES_CHANGED_OF_MEMBER = "onGroupAttributesChangedOfMember"
    ON_USER_GROUPNAMECARD_UPDATED = "onUserGroupNamecardUpdated"


class UserInfoChangeEvent(str, Enum):
    """用户信息更新事件，对应 EMUserInfoManagerListener。"""

    ON_SELF_USER_INFO_UPDATE = "onSelfUserInfoUpdate"
    ON_USER_INFO_UPDATE = "onUserInfoUpdate"


# 消息本地变更事件（5.0 EMMessageListener.onMessageChanged）
MESSAGE_CHANGED = "onMessageChanged"


# 所有 eventType 字符串的集合，便于判断某字符串是否为已知回调事件
ALL_EVENT_VALUES = frozenset(
    [e.value for e in ContactChangeEvent]
    + [e.value for e in ChatRoomEvent]
    + [e.value for e in GroupChangeEvent]
    + [e.value for e in UserInfoChangeEvent]
    + [MESSAGE_CHANGED]
)
