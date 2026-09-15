"""Describe actual public operations, never infer completed business scenarios."""
from contextlib import contextmanager
from contextvars import ContextVar

_PHASE = ContextVar('allure_phase', default=None)
_ORDINAL = ContextVar('allure_step_ordinal', default=0)
_DEPTH = ContextVar('allure_step_depth', default=0)


@contextmanager
def report_phase(phase):
    tokens = (_PHASE.set(phase), _ORDINAL.set(0), _DEPTH.set(0))
    try:
        yield
    finally:
        _DEPTH.reset(tokens[2])
        _ORDINAL.reset(tokens[1])
        _PHASE.reset(tokens[0])


@contextmanager
def business_step(title):
    from .allure_evidence import redact, step
    title = str(redact(title))
    if not _DEPTH.get():
        if _PHASE.get() == 'call':
            number = _ORDINAL.get() + 1
            _ORDINAL.set(number)
            title = f'步骤 {number}：{title}'
        elif _PHASE.get() in ('setup', 'teardown'):
            title = ('前置：' if _PHASE.get() == 'setup' else '清理：') + title
    token = _DEPTH.set(_DEPTH.get() + 1)
    try:
        with step(title):
            yield
    finally:
        _DEPTH.reset(token)


def key(value):
    return str(getattr(value, 'value', value) or '')


def actor(device):
    from .allure_evidence import redact
    name = key(device)
    if name in ('deviceA', 'deviceB', 'deviceC', 'deviceD', 'A', 'B', 'C', 'D'):
        return '用户 ' + name[-1]
    return '设备 ' + str(redact(name)) if name else '当前用户'


# Display vocabulary only. Unknown SDK keys keep their exact protocol names.
ACTIONS = {
    'init': '初始化 IM 客户端', 'createAccount': '注册 IM 账号',
    'login': '登录 IM', 'loginWithAgoraToken': '使用 Token 登录 IM',
    'logout': '退出 IM 登录', 'renewToken': '更新登录 Token',
    'isConnected': '查询连接状态', 'isLoggedInBefore': '查询登录状态',
    'getCurrentUser': '查询当前登录用户', 'kickDevice': '踢出指定设备',
    'kickAllDevices': '踢出其他设备', 'getLoggedInDevicesFromServer': '查询已登录设备',
    'sendMessage': '发送消息', 'sendMessageWithType': '发送指定类型的消息',
    'resendMessage': '重新发送消息', 'recallMessage': '撤回消息',
    'modifyMessage': '修改消息', 'updateChatMessage': '更新本地消息',
    'ackMessageRead': '发送消息已读回执', 'ackGroupMessageRead': '发送群消息已读回执',
    'ackConversationRead': '发送会话已读回执', 'getMessage': '查询消息',
    'fetchHistoryMessages': '获取历史消息', 'fetchHistoryMessagesByOptions': '按条件获取历史消息',
    'getConversation': '获取会话', 'deleteConversation': '删除本地会话',
    'deleteRemoteConversation': '删除服务端会话', 'pinConversation': '设置会话置顶状态',
    'pinMessage': '置顶消息', 'unpinMessage': '取消消息置顶',
    'fetchPinnedMessages': '获取置顶消息', 'pinnedMessages': '获取本地置顶消息',
    'addReaction': '添加消息表情回复', 'removeReaction': '删除消息表情回复',
    'fetchReactionList': '获取消息表情回复列表', 'fetchReactionDetail': '获取消息表情回复详情',
    'translateMessage': '翻译消息', 'downloadAttachment': '下载消息附件',
    'downloadThumbnail': '下载消息缩略图', 'downloadBigImage': '下载消息原图',
    'downloadAndParseCombineMessage': '下载并解析合并消息',
    'downloadMessageAttachmentInCombine': '下载合并消息中的附件',
    'downloadMessageThumbnailInCombine': '下载合并消息中的缩略图',
    'addContact': '发送好友申请', 'deleteContact': '删除好友',
    'acceptInvitation': '接受好友申请', 'declineInvitation': '拒绝好友申请',
    'fetchContacts': '分页获取好友', 'fetchAllContacts': '获取全部好友',
    'setContactRemark': '设置好友备注', 'addUserToBlockList': '添加用户到黑名单',
    'removeUserFromBlockList': '从黑名单移除用户',
    'createGroup': '创建群组', 'destroyGroup': '解散群组', 'leaveGroup': '退出群组',
    'getGroupWithId': '获取本地群组信息', 'getJoinedGroups': '获取本地已加入群组',
    'getJoinedGroupsFromServer': '获取已加入群组',
    'getGroupSpecificationFromServer': '获取群组详情',
    'getGroupMemberListFromServer': '获取群成员列表', 'fetchGroupMembersInfo': '获取群成员信息',
    'getGroupBlockListFromServer': '获取群黑名单', 'getGroupMuteListFromServer': '获取群禁言列表',
    'getGroupWhiteListFromServer': '获取群白名单',
    'addMembers': '添加群成员', 'inviterUser': '邀请用户入群', 'removeMembers': '移除群成员',
    'blockMembers': '将群成员加入黑名单', 'unblockMembers': '将群成员移出黑名单',
    'addAdmin': '添加群管理员', 'removeAdmin': '移除群管理员',
    'updateGroupOwner': '转让群主', 'muteMembers': '禁言群成员', 'unMuteMembers': '解除群成员禁言',
    'muteAllMembers': '开启群全员禁言', 'unMuteAllMembers': '解除群全员禁言',
    'addWhiteList': '添加群白名单成员', 'removeWhiteList': '移除群白名单成员',
    'joinPublicGroup': '加入公开群', 'requestToJoinPublicGroup': '申请加入公开群',
    'acceptJoinApplication': '同意入群申请', 'declineJoinApplication': '拒绝入群申请',
    'acceptInvitationFromGroup': '接受入群邀请', 'declineInvitationFromGroup': '拒绝入群邀请',
    'updateGroupSubject': '修改群名称', 'updateDescription': '修改群描述',
    'updateGroupAnnouncement': '更新群公告', 'getGroupAnnouncementFromServer': '获取群公告',
    'setMemberAttributesFromGroup': '设置群成员属性',
    'removeMemberAttributesFromGroup': '删除群成员属性',
    'fetchMemberAttributesFromGroup': '查询群成员属性',
    'fetchMembersAttributesFromGroup': '批量查询群成员属性',
    'uploadGroupSharedFile': '上传群共享文件', 'downloadGroupSharedFile': '下载群共享文件',
    'removeGroupSharedFile': '删除群共享文件',
    'createChatRoom': '创建聊天室', 'destroyChatRoom': '销毁聊天室',
    'joinChatRoom': '加入聊天室', 'leaveChatRoom': '退出聊天室',
    'fetchChatRoomMembers': '获取聊天室成员', 'fetchChatRoomInfoFromServer': '获取聊天室详情',
    'updateChatRoomAnnouncement': '更新聊天室公告', 'fetchChatRoomAnnouncement': '获取聊天室公告',
    'muteChatRoomMembers': '禁言聊天室成员', 'unMuteChatRoomMembers': '解除聊天室成员禁言',
    'addChatRoomAdmin': '添加聊天室管理员', 'removeChatRoomAdmin': '移除聊天室管理员',
    'removeChatRoomMembers': '移除聊天室成员', 'changeChatRoomOwner': '转让聊天室所有者',
    'setChatRoomAttributes': '设置聊天室属性', 'removeChatRoomAttributes': '删除聊天室属性',
    'fetchChatRoomAttributes': '查询聊天室属性',
    'createChatThread': '创建子区', 'joinChatThread': '加入子区',
    'leaveChatThread': '退出子区', 'destroyChatThread': '销毁子区',
    'fetchChatThreadDetail': '查询子区详情', 'fetchChatThreadMember': '查询子区成员',
    'fetchLastMessageWithChatThreads': '查询子区最新消息',
    'removeMemberFromChatThread': '移除子区成员', 'updateChatThreadSubject': '修改子区名称',
    'updateOwnUserInfo': '更新自己的用户资料', 'updateOwnUserInfoWithType': '更新指定用户资料字段',
    'fetchOwnInfo': '查询自己的用户资料', 'fetchUserInfoById': '查询用户资料',
    'fetchUserInfoByIdWithType': '查询指定用户资料字段',
    'publishPresenceWithDescription': '发布在线状态', 'presenceSubscribe': '订阅在线状态',
    'presenceUnsubscribe': '取消在线状态订阅', 'fetchPresenceStatus': '查询在线状态',
    'getImPushConfigFromServer': '查询服务端推送配置', 'updatePushNickname': '更新推送昵称',
    'setConversationSilentMode': '设置会话免打扰', 'setSilentModeForAll': '设置全局免打扰',
}

EVENTS = {
    'onMessagesReceived': '消息接收回调', 'onCmdMessagesReceived': '透传消息回调',
    'onMessagesRead': '消息已读回调', 'onMessagesDelivered': '消息送达回调',
    'onMessagesRecalled': '消息撤回回调', 'onMessagesRecalledInfo': '消息撤回回调',
    'onMessageContentChanged': '消息内容修改回调', 'onMessagePinChanged': '消息置顶状态回调',
    'messageReactionDidChange': '消息表情回复变更回调', 'onMessageSuccess': '消息发送成功回调',
    'onMessageError': '消息发送失败回调', 'onConnected': '连接成功回调',
    'onDisconnected': '连接断开回调', 'onPresenceStatusChanged': '在线状态变更回调',
    'onGroupInvitationReceived': '群邀请回调', 'onInvitationReceivedFromGroup': '群邀请回调',
    'onGroupInvitationAccepted': '群邀请被接受回调', 'onInvitationAcceptedFromGroup': '群邀请被接受回调',
    'onGroupInvitationDeclined': '群邀请被拒绝回调', 'onInvitationDeclinedFromGroup': '群邀请被拒绝回调',
    'onGroupAutoAcceptInvitation': '自动接受群邀请回调', 'onAutoAcceptInvitationFromGroup': '自动接受群邀请回调',
    'onGroupRequestToJoinReceived': '入群申请回调', 'onRequestToJoinReceivedFromGroup': '入群申请回调',
    'onGroupRequestToJoinAccepted': '入群申请被接受回调', 'onRequestToJoinAcceptedFromGroup': '入群申请被接受回调',
    'onGroupRequestToJoinDeclined': '入群申请被拒绝回调', 'onRequestToJoinDeclinedFromGroup': '入群申请被拒绝回调',
    'onGroupMemberJoined': '群成员加入回调', 'onMemberJoinedFromGroup': '群成员加入回调',
    'onMembersJoinedFromGroup': '群成员加入回调',
    'onGroupMemberExited': '群成员退出回调', 'onMemberExitedFromGroup': '群成员退出回调',
    'onMembersExitedFromGroup': '群成员退出回调', 'onUserRemovedFromGroup': '被移出群回调',
    'onGroupDestroyed': '群解散回调', 'onDestroyedFromGroup': '群解散回调',
    'onGroupAnnouncementChanged': '群公告变更回调', 'onAnnouncementChangedFromGroup': '群公告变更回调',
    'onRoomMemberJoined': '聊天室成员加入回调', 'onRoomMemberExited': '聊天室成员退出回调',
    'onRoomAnnouncementChanged': '聊天室公告变更回调', 'onRoomDestroyed': '聊天室销毁回调',
    'onContactInvited': '好友申请回调', 'onFriendRequestAccepted': '好友申请被接受回调',
    'onFriendRequestDeclined': '好友申请被拒绝回调', 'onContactDeleted': '好友删除回调',
    'onChatThreadCreate': '子区创建回调', 'onChatThreadUpdate': '子区更新回调',
    'onChatThreadDestroy': '子区销毁回调', 'onUserKickOutOfChatThread': '被移出子区回调',
}


def action_title(device, manager, cmd):
    action = ACTIONS.get(key(cmd)) or f'调用 {key(manager)}.{key(cmd)}'
    return f'{actor(device)} {action}'


def event_title(device, filters):
    event = key(filters.get('match_event_type') or filters.get('match_cmd'))
    name = EVENTS.get(event, event + ' 回调' if event else '消息（无类型过滤）')
    return f'{actor(device)} 等待{name}'


def expectation_title(actual, expected=None):
    data = actual if isinstance(actual, dict) else expected if isinstance(expected, dict) else {}
    subject = actor(data['device']) + ' 的' if data.get('device') else ''
    if data.get('type') == 'event' or data.get('eventType'):
        event = key(data.get('eventType') or data.get('cmd'))
        subject += EVENTS.get(event, event + ' 回调' if event else '事件')
    else:
        action = ACTIONS.get(key(data.get('cmd')))
        subject += (action + '响应') if action else '响应'
    return f'校验{subject}是否符合预期'
