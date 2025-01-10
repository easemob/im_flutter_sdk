声网即时通讯 IM 是一个高度可靠的全球通信平台，用户可以进行一对一单聊、群组聊天或聊天室聊天。用户可以通过发送文本消息、分享图片、音频、视频、文件、表情符号和位置进行沟通。

- **ChatClient 类**是聊天 SDK 的入口，提供登录和登出即时通讯 IM 的方法，并管理 SDK 与聊天服务器之间的连接。
- **ChatManager 类**提供发送和接收消息、管理会话（包括加载和删除会话）以及下载附件的方法。
- **ChatMessage 类**定义消息的属性。
- **Conversation 类**提供管理会话的方法。
- **ContactManager 类**提供管理聊天联系人（如添加、获取、修改和删除联系人）的方法。
- **GroupManager 类**提供群组管理的方法，如群组创建和解散以及成员管理。
- **ChatRoomManager 类**提供聊天室管理的方法，如加入和离开聊天室、获取聊天室列表，以及管理成员权限。
- **PresenceManager 类**提供管理用户在线状态订阅的方法。
- **ChatThreadManager 类**提供了管理子区的方法，包括创建、解散子区以及成员管理。
- **PushManager 类**提供了配置离线推送服务的方法。
- **UserInfoManager 类**提供了管理用户属性的方法，包括获取和更新用户属性。

## Chat Client

| 方法             | 描述           |
| :---------------------------------------------- | :------------------------------------------------ |
| [init](chat_sdk/Client/init.html)               | 初始化SDK。             |
| [loginWithToken](chat_sdk/Client/loginWithToken.html)              | 使用用户ID和token登录聊天服务器。             |
| [renewToken](chat_sdk/Client/renewToken.html)           | 更新token。              |
| [logout](chat_sdk/Client/logout.html)           | 退出登录账号。               |
| [currentUserId](chat_sdk/Client/currentUserId.html)         | 获取当前登录用户的用户ID。              |
| [isConnected](chat_sdk/Client/isConnected.html)          | 检查SDK是否已连接到聊天服务器。           |
| [isLoginBefore](chat_sdk/Client/isLoginBefore.html)          | 检查用户是否已登录聊天应用。             |
| [addConnectionEventHandler](chat_sdk/Client/addConnectionEventHandler.html)              | 添加监听。         |
| [removeConnectionEventHandler](chat_sdk/Client/removeConnectionEventHandler.html)              | 移除监听。         |
| [groupManager](chat_sdk/Client/groupManager.html)           | 获取`GroupManager`类。               |
| [pushManager](chat_sdk/Client/pushManager.html)              | 获取`PushManager`类。            |
| [chatRoomManager](chat_sdk/Client/chatRoomManager.html)              | 获取`RoomManager`类。         |
| [chatManager](chat_sdk/Client/chatManager.html)       | 获取`ChatManager`类。           |
| [userInfoManager](chat_sdk/Client/userInfoManager.html)              | 获取`UserInfoManager`类。            |
| [contactManager](chat_sdk/Client/contactManager.html)       | 获取`ContactManager`类。            |
| [presenceManager](chat_sdk/Client/presenceManager.html)   | 获取`presenceManager`类。            |
| [chatThreadManager](chat_sdk/Client/chatThreadManager.html)      | 获取`ChatThreadManager`类。         |

| 事件         | 描述            |
| :------------------------------------------------ | :------------------------------------------------ |
| [onConnected](chat_sdk/ConnectionEventHandler/onConnected.html)             | 成功连接到 chat 服务器时触发的回调。             |
| [onDisconnected](chat_sdk/ConnectionEventHandler/onDisconnected.html)               |  与 chat 服务器断开连接时触发的回调。           |
| [onOfflineMessageSyncStart](chat_sdk/ConnectionEventHandler/onOfflineMessageSyncStart.html)    | 开始从服务器拉取离线消息时触发。           |
| [onOfflineMessageSyncFinish](chat_sdk/ConnectionEventHandler/onOfflineMessageSyncFinish.html)               | 从服务器拉取离线消息结束时触发。           |
| [onTokenDidExpire](chat_sdk/ConnectionEventHandler/onTokenDidExpire.html)       |  token 已过期时触发。       |
| [onTokenWillExpire](chat_sdk/ConnectionEventHandler/onTokenWillExpire.html)   | token 即将过期时触发。     |
| [onUserAuthenticationFailed](chat_sdk/ConnectionEventHandler/onUserAuthenticationFailed.html)               | 鉴权失败回调。             |
| [onUserDidChangePassword](chat_sdk/ConnectionEventHandler/onUserDidChangePassword.html)               | 用户密码变更回调。            |
| [onUserDidLoginFromOtherDevice](chat_sdk/ConnectionEventHandler/onUserDidLoginFromOtherDevice.html)               | 其他设备登录回调。  |
| [onUserDidLoginTooManyDevice](chat_sdk/ConnectionEventHandler/onUserDidLoginTooManyDevice.html)               | 登录设备过多回调。  |
| [onUserDidRemoveFromServer](chat_sdk/ConnectionEventHandler/onUserDidRemoveFromServer.html)               | 当前用户被服务器移除回调。  |
| [onUserKickedByOtherDevice](chat_sdk/ConnectionEventHandler/onUserKickedByOtherDevice.html)               | 被其他设备踢掉回调。  |

## Chat manager

| 方法             | 描述             |
| :------------------------------------------------ | :------------------------------------------------ |
| [sendMessage](chat_sdk/ChatManager/sendMessage.html)             | 发送消息。              |
| [sendConversationReadAck](chat_sdk/ChatManager/sendConversationReadAck.html)        | 向服务器发送会话已读回执。           |
| [sendMessageReadAck](chat_sdk/ChatManager/sendMessageReadAck.html)          | 向服务器发送会话已读回执。              |
| [sendGroupMessageReadAck](chat_sdk/ChatManager/sendGroupMessageReadAck.html)         | 向服务器发送群消息的已读回执。            |
| [getConversation](chat_sdk/ChatManager/getConversation.html)           | 根据会话ID获取会话对象。              |
| [importMessages](chat_sdk/ChatManager/importMessages.html)          | 将消息导入内存和本地数据库。              |
| [updateMessage](chat_sdk/ChatManager/updateMessage.html)            | 更新本地消息。             |
| [downloadAttachment](chat_sdk/ChatManager/downloadAttachment.html)     | 下载消息附件。             |
| [downloadThumbnail](chat_sdk/ChatManager/downloadThumbnail.html)       | 下载消息缩略图。              |
| [loadAllConversations](chat_sdk/ChatManager/loadAllConversations.html)            | 获取所有本地会话。            |
| [fetchConversationsByOptions](chat_sdk/ChatManager/fetchConversationsByOptions.html)          | 从服务器获取会话列表。            |
| [deleteAllMessageAndConversation](chat_sdk/ChatManager/deleteAllMessageAndConversation.html)              | 从本地数据库中删除会话及其本地消息。     |
| [deleteRemoteConversation](chat_sdk/ChatManager/deleteRemoteConversation.html)              | 从服务器删除指定会话及其历史消息。       |
| [fetchGroupAcks](chat_sdk/ChatManager/fetchGroupAcks.html)         | 从服务器分页获取群消息的已读回执。              |
| [searchMsgsByOptions](chat_sdk/ChatManager/searchMsgsByOptions.html)        | 从本地数据库中检索特定类型的消息。       |
| [deleteMessagesBefore](chat_sdk/ChatManager/deleteMessagesBefore.html)       | 根据时间删除本地消息。            |
| [reportMessage](chat_sdk/ChatManager/reportMessage.html)     | 举报不当消息。             |
| [fetchSupportedLanguages](chat_sdk/ChatManager/fetchSupportedLanguages.html)          | 查询翻译服务支持的语言。             |
| [translateMessage](chat_sdk/ChatManager/translateMessage.html)            | 翻译文本消息。             |
| [addReaction](chat_sdk/ChatManager/addReaction.html)           | 添加Reaction。              |
| [removeReaction](chat_sdk/ChatManager/removeReaction.html)            | 删除Reaction。              |
| [fetchReactionList](chat_sdk/ChatManager/fetchReactionList.html)        | 获取Reaction列表。             |
| [fetchReactionDetail](chat_sdk/ChatManager/fetchReactionDetail.html)      | 获取Reaction详情。             |
| [pinMessage](chat_sdk/ChatManager/pinMessage.html)              | 置顶消息。              |
| [unpinMessage](chat_sdk/ChatManager/unpinMessage.html)              | 取消置顶消息。              |
| [modifyMessage](chat_sdk/ChatManager/modifyMessage.html)           | 修改消息。              |
| [fetchHistoryMessagesByOption](chat_sdk/ChatManager/fetchHistoryMessagesByOption.html)            | 从服务器拉取历史消息。              |
| [addEventHandler](chat_sdk/ChatManager/addEventHandler.html)            | 添加监听器。              |
| [removeEventHandler](chat_sdk/ChatManager/removeEventHandler.html.html)            | 移除监听器。              |

| 事件           | 描述               |
| :-------------------------------------------------- | :-------------------------------------------------- |
| [onMessagesReceived](chat_sdk/ChatEventHandler/onMessagesReceived.html)           | 当收到消息时触发。              |
| [onCmdMessagesReceived](chat_sdk/ChatEventHandler/onCmdMessagesReceived.html)           | 当收到cmd消息时触发。              |
| [onMessagesRead](chat_sdk/ChatEventHandler/onMessagesRead.html)    | 当收到消息的已读回执时触发。            |
| [onGroupMessageRead](chat_sdk/ChatEventHandler/onGroupMessageRead.html)          | 当收到群消息的已读回执时触发。               |
| [onReadAckForGroupMessageUpdated](chat_sdk/ChatEventHandler/onReadAckForGroupMessageUpdated.html)      | 当收到群消息已读状态更新时触发。             |
| [onMessagesDelivered](chat_sdk/ChatEventHandler/onMessagesDelivered.html)       | 当收到送达回执时触发。               |
| [onMessagesRecalledInfo](chat_sdk/ChatEventHandler/onMessagesRecalledInfo.html)        | 当收到的消息被撤回时触发。               |
| [onMessageReactionDidChange](chat_sdk/ChatEventHandler/onMessageReactionDidChange.html)     | 当消息Reaction发生变化时触发。               |
| [onConversationsUpdate](chat_sdk/ChatEventHandler/onConversationsUpdate.html)         | 当会话列表更新时触发。               |
| [onConversationRead](chat_sdk/ChatEventHandler/onConversationRead.html)        | 当收到会话已读回执时触发。               |
| [onMessagePinChanged](chat_sdk/ChatEventHandler/onMessagePinChanged.html)        | 当消息置顶状态发生变更时触发。               |
| [onMessageContentChanged](chat_sdk/ChatEventHandler/onMessageContentChanged.html)        | 当消息内容变更时触发。               |

## Conversation & Message8

| 方法              | 描述              |
| :-------------------------------------------------- | :-------------------------------------------------- |
| [Conversation.id](chat_sdk/Conversation/id.html) | 获取会话 ID。              |
| [Conversation.unreadCount](chat_sdk/Conversation/unreadCount.html) | 获取会话中的未读消息数量。              |
| [Conversation.markAllMessagesAsRead](chat_sdk/Conversation/markAllMessagesAsRead.html) | 将所有未读消息标记为已读。              |
| [Conversation.getLocalMessageCount](chat_sdk/Conversation/getLocalMessageCount.html) | 获取本地数据库中会话的所有消息数量。     |
| [Conversation.isChatThread](chat_sdk/Conversation/isChatThread.html) | 检查当前会话是否为Thread会话。              |
| [Conversation.loadMessages](chat_sdk/Conversation/loadMessages.html) | 从本地数据库加载消息，从特定消息ID开始。              |
| [Conversation.markMessageAsRead](chat_sdk/Conversation/markMessageAsRead.html) | 将特定消息标记为已读。       |
| [Conversation.deleteMessage](chat_sdk/Conversation/deleteMessage.html) | 在本地数据库中删除特定消息。              |
| [Conversation.latestMessage](chat_sdk/Conversation/latestMessage.html) | 获取会话中的最新消息。       |
| [Conversation.lastReceivedMessage](chat_sdk/Conversation/lastReceivedMessage.html)| 获取会话中的最新接收消息。              |
| [Conversation.deleteAllMessages](chat_sdk/Conversation/deleteAllMessages.html) | 删除会话中的所有消息。       |
| [Conversation.setExt](chat_sdk/Conversation/setExt.html) | 设置会话的扩展字段。             |
| [Conversation.ext](chat_sdk/Conversation/setExt.html) | 获取会话的扩展字段。             |
| [Conversation.insertMessage](chat_sdk/Conversation/insertMessage.html) | 在本地数据库中向会话插入消息。               |
| [Conversation.appendMessage](chat_sdk/Conversation/appendMessage.html) | 在本地数据库中将消息插入到会话的末尾。              |
| [Conversation.updateMessage](chat_sdk/Conversation/updateMessage.html) | 更新本地数据库中的消息。     |
| [Message.status](chat_sdk/Message/status.html) | 消息发送或接收状态。         |
| [Message.chatType](chat_sdk/Message/chatType.html) | 获取聊天消息类型。           |
| [Message.body](chat_sdk/Message/body.html) | 消息正文。              |
| [Message.serverTime](chat_sdk/Message/serverTime.html) | 服务器接收消息时的Unix时间戳。               |
| [Message.localTime](chat_sdk/Message/localTime.html) | 消息的本地时间戳。         |
| [Message.isChatThreadMessage](chat_sdk/Message/isChatThreadMessage.html) | 消息是否为Thread消息。         |
| [Message.chatThread](chat_sdk/Message/chatThread.html) | 获取Thread的概述。         |
| [Message.from](chat_sdk/Message/from.html) | 获取消息发送者的用户ID。     |
| [Message.to](chat_sdk/Message/to.html) | 消息接收者的用户ID。         |
| [Message.msgId](chat_sdk/Message/msgId.html) | 消息ID。              |
| [Message.attributes](chat_sdk/Message/attributes.html) | 消息的扩展属性，类型为字典。               |
| [Message.hasRead](chat_sdk/Message/hasRead.html) | 消息是否已读。             |
| [Message.hasReadAck](chat_sdk/Message/hasReadAck.html) | 消息是否已成功送达。       |
| [Message.direction](chat_sdk/Message/direction.html) | 消息的收发方向。               |
| [Message.conversationId](chat_sdk/Message/conversationId.html) | 获取会话ID。               |
| [Message.reactionList](chat_sdk/Message/reactionList.html) | 获取Reaction列表。             |
| [Message.onlineState](chat_sdk/Message/onlineState.html) | 是否在线消息。              |
| [Message.pinInfo](chat_sdk/Message/pinInfo.html) | 消息的置顶操作信息。 |

## Contacts

| 方法              | 描述      |
| :------------------------------------------------- | :------------------------------------------------- |
| [fetchAllContacts](chat_sdk/ContactManager/fetchAllContacts.html)   | 从服务器获取所有联系人。              |
| [addUserToBlockList](chat_sdk/ContactManager/addUserToBlockList.html)            | 将用户添加到黑名单。      |
| [removeUserFromBlockList](chat_sdk/ContactManager/removeUserFromBlockList.html)         | 从黑名单中移除联系人。             |
| [getBlockIds](chat_sdk/ContactManager/getBlockIds.html)            | 获取本地黑名单。      |
| [fetchBlockIds](chat_sdk/ContactManager/fetchBlockIds.html)       | 从服务器获取黑名单。            |
| [acceptInvitation](chat_sdk/ContactManager/acceptInvitation.html)    | 接受好友邀请。              |
| [declineInvitation](chat_sdk/ContactManager/declineInvitation.html)    | 拒绝好友邀请。              |
| [getAllContacts](chat_sdk/ContactManager/getAllContacts.html)     | 从本地数据库获取联系人列表。            |
| [getSelfIdsOnOtherPlatform](chat_sdk/ContactManager/getSelfIdsOnOtherPlatform.html)   | 获取登录用户在其他登录设备上唯一 ID |
| [addEventHandler](chat_sdk/ContactManager/addEventHandler.html)         | 添加联系人变更监听。               |
| [removeEventHandler](chat_sdk/ContactManager/removeEventHandler.html)         | 删除联系人变更监听。               |

| 事件              | 描述              |
| :--------------------------------------------------- | :-------------------------------------------------- |
| [onContactAdded](chat_sdk/ContactEventHandler/onContactAdded.html)              | 当用户被其他用户添加为联系人时触发。              |
| [onContactDeleted](chat_sdk/ContactEventHandler/onContactDeleted.html)              | 当用户被其他用户从联系人列表中移除时触发。    |
| [onContactInvited](chat_sdk/ContactEventHandler/onContactInvited.html)       | 当用户收到好友请求时触发。        |
| [onFriendRequestAccepted](chat_sdk/ContactEventHandler/onFriendRequestAccepted.html) | 当好友请求被批准时触发。        |
| [onFriendRequestDeclined](chat_sdk/ContactEventHandler/onFriendRequestDeclined.html) | 当好友请求被拒绝时触发。        |

## Chat Group

| 方法            | 描述              |
| :-------------------------------------------------- | :-------------------------------------------------- |
| [createGroup](chat_sdk/GroupManager/createGroup.html)      | 创建群组。     |
| [destroyGroup](chat_sdk/GroupManager/destroyGroup.html)           | 销毁群组。             |
| [leaveGroup](chat_sdk/GroupManager/leaveGroup.html)          | 离开群组。               |
| [joinPublicGroup](chat_sdk/GroupManager/joinPublicGroup.html)       | 加入一个公共群组。         |
| [addMembers](chat_sdk/GroupManager/addMembers.html)        | 将用户添加到群组中。      |
| [removeMembers](chat_sdk/GroupManager/removeMembers.html)        | 从群组中移除成员。               |
| [fetchGroupInfoFromServer](chat_sdk/GroupManager/fetchGroupInfoFromServer.html)        | 从服务器获取群组信息。              |
| [fetchJoinedGroupsFromServer](chat_sdk/GroupManager/fetchJoinedGroupsFromServer.html)        | 从服务器分页获取当前用户的所有群组。 |
| [fetchPublicGroupsFromServer](chat_sdk/GroupManager/fetchPublicGroupsFromServer.html)         | 从服务器分页获取公开群组。             |
| [changeGroupName](chat_sdk/GroupManager/changeGroupName.html)         | 更改群组名称。       |
| [changeGroupDescription](chat_sdk/GroupManager/changeGroupDescription.html)           | 更改群组描述。             |
| [acceptInvitation](chat_sdk/GroupManager/acceptInvitation.html)          | 接受群组邀请。              |
| [declineInvitation](chat_sdk/GroupManager/declineInvitation.html)            | 拒绝群组邀请。             |
| [acceptJoinApplication](chat_sdk/GroupManager/acceptJoinApplication.html)        | 批准群组请求。     |
| [declineJoinApplication](chat_sdk/GroupManager/declineJoinApplication.html)            | 拒绝群组请求。     |
| [requestToJoinPublicGroup](chat_sdk/GroupManager/requestToJoinPublicGroup.html)           | 请求加入公共群组。     |
| [blockGroup](chat_sdk/GroupManager/blockGroup.html)           | 阻止群组消息。        |
| [unblockGroup](chat_sdk/GroupManager/unblockGroup.html)           | 取消阻止群组消息。      |
| [blockMembers](chat_sdk/GroupManager/blockMembers.html)          | 将用户添加到群组黑名单。             |
| [unblockMembers](chat_sdk/GroupManager/unblockMembers.html)         | 从群组黑名单中移除用户。             |
| [fetchBlockListFromServer](chat_sdk/GroupManager/fetchBlockListFromServer.html)            | 获取群组黑名单（带分页）。              |
| [fetchMemberListFromServer](chat_sdk/GroupManager/fetchMemberListFromServer.html)           | 获取群组成员列表（带分页）。            |
| [changeOwner](chat_sdk/GroupManager/changeOwner.html)            | 转移群组所有权。             |
| [addAdmin](chat_sdk/GroupManager/addAdmin.html)         | 添加群组管理员。           |
| [removeAdmin](chat_sdk/GroupManager/removeAdmin.html)           | 移除群组管理员。        |
| [muteMembers](chat_sdk/GroupManager/muteMembers.html)             | 禁言群组成员。          |
| [unMuteMembers](chat_sdk/GroupManager/unMuteMembers.html)           | 取消禁言群组成员。        |
| [fetchMuteListFromServer](chat_sdk/GroupManager/fetchMuteListFromServer.html)           | 从服务器获取群组禁言列表。            |
| [fetchBlockListFromServer](chat_sdk/GroupManager/fetchBlockListFromServer.html)            | 从服务器获取群组黑名单（带分页）。        |
| [addAllowList](chat_sdk/GroupManager/addAllowList.html)            | 将成员添加到白名单列表。               |
| [removeAllowList](chat_sdk/GroupManager/removeAllowList.html)            | 从白名单列表中移除成员。    |
| [fetchAllowListFromServer](chat_sdk/GroupManager/fetchAllowListFromServer.html)            | 从服务器获取群组白名单列表。               |
| [updateGroupAnnouncement](chat_sdk/GroupManager/updateGroupAnnouncement.html)            | 更新群组公告。               |
| [fetchAnnouncementFromServer](chat_sdk/GroupManager/fetchAnnouncementFromServer.html)            | 从服务器获取群组公告。            |
| [uploadGroupSharedFile](chat_sdk/GroupManager/uploadGroupSharedFile.html)            | 上传群组共享文件。              |
| [fetchGroupFileListFromServer](chat_sdk/GroupManager/fetchGroupFileListFromServer.html)            | 从服务器获取共享文件列表。              |
| [removeGroupSharedFile](chat_sdk/GroupManager/removeGroupSharedFile.html)            | 移除群组共享文件。              |
| [downloadGroupSharedFile](chat_sdk/GroupManager/downloadGroupSharedFile.html)            | 下载群组共享文件。              |
| [getJoinedGroups](chat_sdk/GroupManager/getJoinedGroups.html)            | 获取当前用户的所有群组（从缓存中）。           |
| [addEventHandler](chat_sdk/GroupManager/addEventHandler.html)            | 添加监听器。            |
| [removeEventHandler](chat_sdk/GroupManager/removeEventHandler.html)            | 移除监听器。            |

| 事件              | 描述              |
| :------------------------------------------------- | :------------------------------------------------- |
| [onInvitationReceivedFromGroup](chat_sdk/GroupEventHandler/onInvitationReceivedFromGroup.html)            | 当用户收到群组邀请时触发。     |
| [onRequestToJoinReceivedFromGroup](chat_sdk/GroupEventHandler/onRequestToJoinReceivedFromGroup.html)        | 当群组所有者或管理员收到用户的加入请求时触发。 |
| [onRequestToJoinAcceptedFromGroup](chat_sdk/GroupEventHandler/onRequestToJoinAcceptedFromGroup.html)            | 当群组请求被接受时触发。    |
| [onRequestToJoinDeclinedFromGroup](chat_sdk/GroupEventHandler/onRequestToJoinDeclinedFromGroup.html)         | 当群组请求被拒绝时触发。    |
| [onInvitationAcceptedFromGroup](chat_sdk/GroupEventHandler/onInvitationAcceptedFromGroup.html)           | 当群组邀请被接受时触发。              |
| [onInvitationDeclinedFromGroup](chat_sdk/GroupEventHandler/onInvitationDeclinedFromGroup.html)            | 当群组邀请被拒绝时触发。 |
| [onAutoAcceptInvitationFromGroup](chat_sdk/GroupEventHandler/onAutoAcceptInvitationFromGroup.html)        | 当群组邀请自动接受时触发。         |
| [onAdminRemovedFromGroup](chat_sdk/GroupEventHandler/onAdminRemovedFromGroup.html)       | 当前用户被群组管理员移除时触发。         |
| [onMuteListAddedFromGroup](chat_sdk/GroupEventHandler/onMuteListAddedFromGroup.html)            | 当一个或多个群组成员被禁言时触发。            |
| [onMuteListRemovedFromGroup](chat_sdk/GroupEventHandler/onMuteListRemovedFromGroup.html)              | 当一个或多个群组成员被取消禁言时触发。    |
| [onAllowListAddedFromGroup](chat_sdk/GroupEventHandler/onAllowListAddedFromGroup.html)           | 当一个或多个群组成员被添加到白名单列表时触发。             |
| [onAllowListRemovedFromGroup](chat_sdk/GroupEventHandler/onAllowListRemovedFromGroup.html)           | 当一个或多个成员从白名单列表中移除时触发。               |
| [onAllGroupMemberMuteStateChanged](chat_sdk/GroupEventHandler/onAllGroupMemberMuteStateChanged.html)           | 当所有群组成员被禁言或取消禁言时触发。              |
| [onAdminAddedFromGroup](chat_sdk/GroupEventHandler/onAdminAddedFromGroup.html)         | 当某个成员被设置为管理员时触发。    |
| [onAdminRemovedFromGroup](chat_sdk/GroupEventHandler/onAdminRemovedFromGroup.html)     | 当某个成员的管理员权限被移除时触发。             |
| [onOwnerChangedFromGroup](chat_sdk/GroupEventHandler/onOwnerChangedFromGroup.html)             | 当群组所有权被转移时触发。             |
| [onMemberJoinedFromGroup](chat_sdk/GroupEventHandler/onMemberJoinedFromGroup.html)     | 当某个成员加入群组时触发。         |
| [onMemberExitedFromGroup](chat_sdk/GroupEventHandler/onMemberExitedFromGroup.html)     | 当某个成员主动离开群组时触发。    |
| [onAnnouncementChangedFromGroup](chat_sdk/GroupEventHandler/onAnnouncementChangedFromGroup.html)              | 当公告被更新时触发。    |
| [onSharedFileAddedFromGroup](chat_sdk/GroupEventHandler/onSharedFileAddedFromGroup.html)              | 当共享文件被添加到群组时触发。              |
| [onSharedFileDeletedFromGroup](chat_sdk/GroupEventHandler/onSharedFileDeletedFromGroup.html)     | 当共享文件从群组中移除时触发。    |
| [onSpecificationDidUpdate](chat_sdk/GroupEventHandler/onSpecificationDidUpdate.html)             | 当群组详细信息被更新时触发。             |
| [onDisableChanged](chat_sdk/GroupEventHandler/onDisableChanged.html)      | 当群组被启用或禁用时触发。               |

## Chat Room

| 方法              | 描述               |
| :------------------------------------------------------- | :------------------------------------------------------- |
| [createChatRoom](chat_sdk/ChatRoomManager/createChatRoom.html)          | 创建聊天室。              |
| [destroyChatRoom](chat_sdk/ChatRoomManager/destroyChatRoom.html)          | 销毁聊天室。             |
| [joinChatRoom](chat_sdk/ChatRoomManager/joinChatRoom.html)           | 加入聊天室。            |
| [leaveChatRoom](chat_sdk/ChatRoomManager/leaveChatRoom.html)         | 退出聊天室。            |
| [fetchPublicChatRoomsFromServer](chat_sdk/ChatRoomManager/fetchPublicChatRoomsFromServer.html)            | 从服务器获取聊天室数据，支持分页。             |
| [fetchChatRoomInfoFromServer](chat_sdk/ChatRoomManager/fetchChatRoomInfoFromServer.html)            | 从服务器获取聊天室的详细信息。     |
| [changeChatRoomName](chat_sdk/ChatRoomManager/changeChatRoomName.html)            | 修改聊天室名称。            |
| [changeChatRoomDescription](chat_sdk/ChatRoomManager/changeChatRoomDescription.html)           | 修改聊天室描述。    |
| [fetchChatRoomMembers](chat_sdk/ChatRoomManager/fetchChatRoomMembers.html)           | 获取聊天室成员列表。        |
| [muteChatRoomMembers](chat_sdk/ChatRoomManager/muteChatRoomMembers.html)            | 在聊天室中禁言成员。          |
| [unMuteChatRoomMembers](chat_sdk/ChatRoomManager/unMuteChatRoomMembers.html)            | 在聊天室中取消禁言成员。        |
| [addChatRoomAdmin](chat_sdk/ChatRoomManager/addChatRoomAdmin.html)            | 添加聊天室管理员。           |
| [removeChatRoomAdmin](chat_sdk/ChatRoomManager/removeChatRoomAdmin.html)            | 移除聊天室管理员的管理权限。              |
| [fetchChatRoomMuteList](chat_sdk/ChatRoomManager/fetchChatRoomMuteList.html)            | 从服务器获取禁言聊天室成员列表。            |
| [removeChatRoomMembers](chat_sdk/ChatRoomManager/removeChatRoomMembers.html)            | 从聊天室中移除成员。      |
| [blockChatRoomMembers](chat_sdk/ChatRoomManager/blockChatRoomMembers.html)             | 将成员添加到聊天室的黑名单中。              |
| [unBlockChatRoomMembers](chat_sdk/ChatRoomManager/unBlockChatRoomMembers.html)             | 从聊天室的黑名单中移除成员。            |
| [fetchChatRoomBlockList](chat_sdk/ChatRoomManager/fetchChatRoomBlockList.html)             | 获取聊天室黑名单，支持分页。              |
| [addMembersToChatRoomAllowList](chat_sdk/ChatRoomManager/addMembersToChatRoomAllowList.html)             | 将成员添加到聊天室的白名单中。              |
| [removeMembersFromChatRoomAllowList](chat_sdk/ChatRoomManager/removeMembersFromChatRoomAllowList.html)              | 从聊天室的白名单中移除成员。              |
| [fetchChatRoomAllowListFromServer](chat_sdk/ChatRoomManager/fetchChatRoomAllowListFromServer.html)              | 从服务器获取聊天室的白名单。              |
| [muteAllChatRoomMembers](chat_sdk/ChatRoomManager/muteAllChatRoomMembers.html)            | 禁言所有成员。            |
| [unMuteAllChatRoomMembers](chat_sdk/ChatRoomManager/unMuteAllChatRoomMembers.html)              | 取消禁言所有成员。              |
| [updateChatRoomAnnouncement](chat_sdk/ChatRoomManager/updateChatRoomAnnouncement.html)             | 更新聊天室公告。    |
| [fetchChatRoomAnnouncement](chat_sdk/ChatRoomManager/fetchChatRoomAnnouncement.html)              | 从服务器获取聊天室公告。              |
| [addAttributes](chat_sdk/ChatRoomManager/addAttributes.html)            | 添加自定义聊天室属性。      |
| [removeAttributes](chat_sdk/ChatRoomManager/removeAttributes.html)              | 设置自定义聊天室属性。     |
| [fetchChatRoomAttributes](chat_sdk/ChatRoomManager/fetchChatRoomAttributes.html)              | 根据属性键列表获取聊天室的自定义属性列表。 |
| [addEventHandler](chat_sdk/ChatRoomManager/addEventHandler.html)            | 添加监听器。            |
| [removeEventHandler](chat_sdk/ChatRoomManager/removeEventHandler.html)            | 移除监听器。            |

| 事件               | 描述             |
| :------------------------------------------------- | :------------------------------------------------- |
| [onRemovedFromChatRoom](chat_sdk/ChatRoomEventHandler/onRemovedFromChatRoom.html)            | 当前用户被移出聊天室时触发。    |
| [onMemberJoinedFromChatRoom](chat_sdk/ChatRoomEventHandler/onMemberJoinedFromChatRoom.html)                | 当其他成员加入聊天室时触发。             |
| [onMemberExitedFromChatRoom](chat_sdk/ChatRoomEventHandler/onMemberExitedFromChatRoom.html)               | 当其他成员退出聊天室时触发。             |
| [onMuteListAddedFromChatRoom](chat_sdk/ChatRoomEventHandler/onMuteListAddedFromChatRoom.html)              | 当聊天室成员被添加到禁言列表时触发。      |
| [onMuteListRemovedFromChatRoom](chat_sdk/ChatRoomEventHandler/onMuteListRemovedFromChatRoom.html)               | 当聊天室成员从禁言列表中移除时触发。  |
| [onAllowListAddedFromChatRoom](chat_sdk/ChatRoomEventHandler/onAllowListAddedFromChatRoom.html)             | 当聊天室成员被添加到白名单时触发。     |
| [onAllowListRemovedFromChatRoom](chat_sdk/ChatRoomEventHandler/onAllowListRemovedFromChatRoom.html)              | 当聊天室成员从白名单中移除时触发。 |
| [onAllChatRoomMemberMuteStateChanged](chat_sdk/ChatRoomEventHandler/onAllChatRoomMemberMuteStateChanged.html)               | 当聊天室中的全员禁言状态变更时触发。          |
| [onAdminAddedFromChatRoom](chat_sdk/ChatRoomEventHandler/onAdminAddedFromChatRoom.html)               | 当聊天室成员被设置为管理员时触发。             |
| [onAdminRemovedFromChatRoom](chat_sdk/ChatRoomEventHandler/onAdminRemovedFromChatRoom.html)               | 当聊天室成员从管理员列表中移除时触发。 |
| [onOwnerChangedFromChatRoom](chat_sdk/ChatRoomEventHandler/onOwnerChangedFromChatRoom.html)               | 当聊天室的拥有者更改时触发。             |
| [onAnnouncementChangedFromChatRoom](chat_sdk/ChatRoomEventHandler/onAnnouncementChangedFromChatRoom.html)               | 当聊天室公告更改时触发。            |
| [onSpecificationChanged](chat_sdk/ChatRoomEventHandler/onSpecificationChanged.html)               | 当聊天室详情更改时触发。              |
| [onAttributesUpdated](chat_sdk/ChatRoomEventHandler/onAttributesUpdated.html)                | 当自定义聊天室属性更新时触发。           |
| [onAttributesRemoved](chat_sdk/ChatRoomEventHandler/onAttributesRemoved.html)               | 当自定义聊天室属性被移除时触发。           |

## Presence

| 方法            | 描述            |
| :-------------------------------------------------------- | :--------------------------------------------------- |
| [publishPresence](chat_sdk/PresenceManager/publishPresence.html)            | 发布自定义的在线状态。            |
| [subscribe](chat_sdk/PresenceManager/subscribe.html)            | 订阅用户的在线状态。       |
| [unsubscribe](chat_sdk/PresenceManager/unsubscribe.html)              | 取消订阅用户的在线状态。              |
| [fetchSubscribedMembers](chat_sdk/PresenceManager/fetchSubscribedMembers.html)           | 使用分页获取已订阅的用户的列表。 |
| [fetchPresenceStatus](chat_sdk/PresenceManager/fetchPresenceStatus.html)             | 获取用户的当前在线状态。     |
| [addEventHandler](chat_sdk/GroupManager/addEventHandler.html)            | 添加监听器。            |
| [removeEventHandler](chat_sdk/GroupManager/removeEventHandler.html)            | 移除监听器。            |

| 事件              | 描述    |
| :------------------------------------------------ | :------------------------------------------------ |
| [onPresenceStatusChanged](chat_sdk/PresenceEventHandler/onPresenceStatusChanged.html) | 当订阅的用户的在线状态更新时触发。 |

## Threading

| 方法               | 描述             |
| :---------------------------------------------------------- | :------------------------------------------------------- |
| [createChatThread](chat_sdk/ThreadManager/createChatThread.html)            | 创建Thread。             |
| [joinChatThread](chat_sdk/ThreadManager/joinChatThread.html)      | 加入Thread。               |
| [destroyChatThread](chat_sdk/ThreadManager/destroyChatThread.html)      | 销毁Thread。              |
| [leaveChatThread](chat_sdk/ThreadManager/leaveChatThread.html)          | 离开Thread。              |
| [fetchChatThread](chat_sdk/ThreadManager/fetchChatThread.html)            | 从服务器获取Thread的详细信息。             |
| [updateChatThreadName](chat_sdk/ThreadManager/updateChatThreadName.html)            | 更改Thread的名称。             |
| [removeMemberFromChatThread](chat_sdk/ThreadManager/removeMemberFromChatThread.html)              | 从Thread中移除成员。           |
| [fetchChatThreadMembers](chat_sdk/ThreadManager/fetchChatThreadMembers.html)            | 分页获取Thread中的成员列表。            |
| [fetchJoinedChatThreads](chat_sdk/ThreadManager/fetchJoinedChatThreads.html)           | 分页获取当前用户已加入的Thread列表。        |
| [fetchJoinedChatThreadsWithParentId](chat_sdk/ThreadManager/fetchJoinedChatThreadsWithParentId.html)         | 分页获取当前用户在指定组中已加入的Thread列表。               |
| [fetchChatThreadsWithParentId](chat_sdk/ThreadManager/fetchChatThreadsWithParentId.html)             | 分页获取指定组中的Thread列表。             |
| [fetchLatestMessageWithChatThreads](chat_sdk/ThreadManager/fetchLatestMessageWithChatThreads.html)             | 从服务器获取指定Thread的最后一条回复。              |
| [addEventHandler](chat_sdk/GroupManager/addEventHandler.html)            | 添加监听器。            |
| [removeEventHandler](chat_sdk/GroupManager/removeEventHandler.html)            | 移除监听器。            |

| 事件               | 描述               |
| :------------------------------------------------------ | :--------------------------------------------------------- |
| [onChatThreadCreate](chat_sdk/ThreadEventHandler/onChatThreadCreate.html)         | 当Thread被创建时触发。              |
| [onChatThreadUpdate](chat_sdk/ThreadEventHandler/onChatThreadUpdate.html)        | 当Thread被更新时触发。              |
| [onChatThreadDestroy](chat_sdk/ThreadEventHandler/onChatThreadDestroy.html)         | 当Thread被销毁时触发。            |
| [onUserKickOutOfChatThread](chat_sdk/ThreadEventHandler/onUserKickOutOfChatThread.html)         | 当当前用户被群主或群管理员从Thread中移除时触发。 |

## Offline push

| 方法              | 描述            |
| :---------------------------------------------------------- | :---------------------------------------------------- |
| [fetchPushConfigsFromServer](chat_sdk/PushManager/fetchPushConfigsFromServer.html)            | 从服务器获取推送配置。              |
| [updatePushNickname](chat_sdk/PushManager/updatePushNickname.html)            | 更新当前用户的推送显示昵称。            |
| [setConversationSilentMode](chat_sdk/PushManager/setConversationSilentMode.html)            | 修改会话的免打扰设置。              |
| [removeConversationSilentMode](chat_sdk/PushManager/removeConversationSilentMode.html)              | 清除会话的离线推送通知类型设置。 |
| [fetchConversationSilentMode](chat_sdk/PushManager/fetchConversationSilentMode.html)             | 获取会话的免打扰设置。     |
| [setSilentModeForAll](chat_sdk/PushManager/setSilentModeForAll.html)              | 设置当前登录用户的免打扰设置。             |
| [fetchSilentModeForAll](chat_sdk/PushManager/fetchSilentModeForAll.html)             | 获取当前登录用户的免打扰设置。              |
| [fetchSilentModeForConversations](chat_sdk/PushManager/fetchSilentModeForConversations.html)            | 批量获取指定会话的免打扰设置。            |
| [bindDeviceToken](chat_sdk/PushManager/bindDeviceToken.html)          | 绑定 APNs Token。            |

## User Attributes

| 方法              | 描述      |
| :------------------------------------------------- | :------------------------------------------------- |
| [fetchOwnInfo](chat_sdk/UserInfoManager/fetchOwnInfo.html)             | 获取当前用户的用户属性           |
| [updateUserInfo](chat_sdk/UserInfoManager/updateUserInfo.html)   | 修改当前用户的用户属性。              |
| [fetchUserInfoById](chat_sdk/UserInfoManager/fetchUserInfoById.html)         | 根据用户ID获取用户属性。            |
