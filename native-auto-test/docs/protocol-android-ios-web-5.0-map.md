# Android / iOS / Web 5.0 全量业务 API 对照表

## 使用口径

- 第一列是 Android/iOS/Web 三端 5.0 业务协议的并集，不以任一端 Matrix 作为唯一来源；同一语义在三端使用同一协议名，端侧只负责映射到各自 SDK 原生方法。
- Android/iOS/Web 列分别记录对应 5.0 原生 API，以及当前 Wrapper 实际调用的方法；某端没有对应原生能力或 Wrapper 时统一填写 `xxx`。
- 同步/异步重载合并为一行；getter、setter、构造器、缓存/校验内部方法不单独列入公共业务协议。
- “xxx”表示该端当前没有可映射的 5.0 业务 API，不等同于 Wrapper 漏实现；需要结合原生包和官方文档确认。
- 上方表格维护三端协议并集；下方只补充平台独有 API、Wrapper 缺口和未纳入统一协议的业务能力。

## 覆盖结论

- 主表按 Android/iOS/Web 5.0 业务协议并集维护。
- 各端没有对应 API 或 Wrapper 的位置填写 `xxx`，不为了凑齐表格而伪造跨端映射。
- Web wrapper 已接入：`ChatManager.loadAllConversations` 使用 Web 5.0 的 `ChatManager.getConversationList`，`UserInfoManager.getUserInfoWithUserIds` 使用 Web 5.0 的批量 `UserInfoManager.getUserInfoByUserId({userIds})`。

## 公共业务 API

| 统一协议 | Android 5.0 原生 API | iOS 5.0 原生 API | Web 5.0 原生 API / 当前 wrapper 调用 |
|---|---|---|---|
| Client.init | EMClient.init | EMClient.initializeSDKWithOptions: | IMSDK.ChatClient.init |
| Client.getCurrentDeviceId | getDeviceInfo (返回不一样) | EMClient.getDeviceConfig: | IMSDK.ChatClient.getClientResource |
| Client.isConnected | EMClient.isConnected | EMClient.isConnected | IMSDK.ChatClient.getConnectionState |
| Client.getCurrentUser | EMClient.getCurrentUser | EMClient.currentUsername | IMSDK.ChatClient.getCurrentUserId |
| Client.login | EMClient.loginWithToken | EMClient.loginWithUsername:token:completion: | IMSDK.ChatClient.login |
| Client.logout | EMClient.logout | EMClient.logout:completion: | IMSDK.ChatClient.logout |
| Client.renewToken | EMClient.renewToken | EMClient.renewToken:completion: | IMSDK.ChatClient.renewToken |
| Client.getUserIdsWithRTCUids | EMClient.asyncGetUserIdsWithRTCUids | EMClient.getUserIdByRTCUIds:completion: | IMSDK.ChatClient.getUserIdsWithRTCUids |
| Client.getRTCTokenInfoWithChannelName | EMClient.asyncGetRTCTokenInfoWithChannelName | EMClient.getRTCTokenWithChannel:completion: | IMSDK.ChatClient.getRTCTokenInfo |
| ChatManager.sendMessage | EMChatManager.sendMessage | IEMChatManager.sendMessage:progress:completion: | IMSDK.ChatManager.sendMessage |
| ChatManager.addReaction | EMChatManager.addReaction / EMChatManager.asyncAddReaction | IEMChatManager.addReaction:toMessage:completion: | IMSDK.ChatManager.addReaction |
| ChatManager.removeReaction | EMChatManager.removeReaction / EMChatManager.asyncRemoveReaction | IEMChatManager.removeReaction:fromMessage:completion: | IMSDK.ChatManager.removeReaction |
| ChatManager.fetchReactionList | EMChatManager.getReactionList / EMChatManager.asyncGetReactionList | IEMChatManager.getReactionList:groupId:chatType:completion: | IMSDK.ChatManager.getReactionList |
| ChatManager.fetchReactionDetail | EMChatManager.getReactionDetail / EMChatManager.asyncGetReactionDetail | IEMChatManager.getReactionDetail:reaction:cursor:pageSize:completion: | IMSDK.ChatManager.getReactionDetail |
| ChatManager.fetchHistoryMessages | EMChatManager.asyncFetchHistoryMessages | IEMChatManager.fetchMessagesFromServerBy:conversationType:cursor:pageSize:option:completion: | IMSDK.ChatManager.getHistoryMessages |
| ChatManager.recallMessage | EMChatManager.recallMessage / EMChatManager.asyncRecallMessage | IEMChatManager.recallMessageWithMessageId:completion: / IEMChatManager.recallMessageWithMessageId:ext:completion: | IMSDK.ChatManager.recallMessage |
| ChatManager.modifyMessage | EMChatManager.asyncModifyMessage | IEMChatManager.modifyMessage:body:ext:completion: | IMSDK.ChatManager.modifyMessage |
| ContactManager.getAllContacts | EMContactManager.asyncFetchAllContactsFromLocal | IEMContactManager.getAllContacts | IMSDK.ContactManager.getContacts |
| ContactManager.addContact | EMContactManager.addContact / asyncAddContact | IEMContactManager.addContact:message:completion: | IMSDK.ContactManager.addContact |
| ContactManager.deleteContact | EMContactManager.deleteContact / asyncDeleteContact | IEMContactManager.deleteContact:isDeleteConversation:completion: | IMSDK.ContactManager.deleteContact |
| ContactManager.acceptInvitation | EMContactManager.acceptInvitation / asyncAcceptInvitation | IEMContactManager.approveFriendRequestFromUser:completion: | IMSDK.ContactManager.acceptContactInvite |
| ContactManager.declineInvitation | EMContactManager.declineInvitation / asyncDeclineInvitation | IEMContactManager.declineFriendRequestFromUser:completion: | IMSDK.ContactManager.declineContactInvite |
| ContactManager.setContactRemark | EMContactManager.asyncSetContactRemark | IEMContactManager.setContactRemark:remark:completion: | IMSDK.ContactManager.setContactRemark |
| ContactManager.getBlockListFromDB | EMContactManager.getBlackListUsernames | IEMContactManager.getBlackList | IMSDK.ContactManager.getBlocklist |
| ContactManager.addUserToBlockList | EMContactManager.addUserToBlackList / asyncAddUserToBlackList | IEMContactManager.addUserToBlackList:completion: | IMSDK.ContactManager.addUsersToBlocklist |
| ContactManager.removeUserFromBlockList | EMContactManager.removeUserFromBlackList / asyncRemoveUserFromBlackList | IEMContactManager.removeUserFromBlackList:completion: | IMSDK.ContactManager.removeUsersFromBlocklist |
| GroupManager.getJoinedGroups | EMGroupManager.getAllGroups | IEMGroupManager.getJoinedGroups | IMSDK.GroupManager.getJoinedGroupList |
| GroupManager.getGroupMemberListFromServer | EMGroupManager.fetchGroupMembers / EMGroupManager.asyncFetchGroupMembers | IEMGroupManager.getGroupMemberListFromServerWithId:cursor:pageSize:completion: | IMSDK.GroupManager.getGroupMemberList |
| GroupManager.getGroupWithId | EMGroupManager.getGroup | EMGroup.groupWithId: | IMSDK.GroupManager.getGroup |
| GroupManager.createGroup | EMGroupManager.createGroup / EMGroupManager.asyncCreateGroup | IEMGroupManager.createGroupWithSubject:avatar:description:invitees:message:setting:completion: | IMSDK.GroupManager.createGroup |
| GroupManager.requestToJoinPublicGroup | EMGroupManager.applyJoinToGroup / EMGroupManager.asyncApplyJoinToGroup | IEMGroupManager.requestToJoinPublicGroup:message:completion: | IMSDK.GroupManager.joinGroup |
| GroupManager.joinPublicGroup | EMGroupManager.joinGroup / EMGroupManager.asyncJoinGroup | IEMGroupManager.joinPublicGroup:completion: | IMSDK.GroupManager.joinGroup |
| GroupManager.leaveGroup | EMGroupManager.leaveGroup / EMGroupManager.asyncLeaveGroup | IEMGroupManager.leaveGroup:completion: | IMSDK.GroupManager.leaveGroup |
| GroupManager.destroyGroup | EMGroupManager.destroyGroup / EMGroupManager.asyncDestroyGroup | IEMGroupManager.destroyGroup:finishCompletion: | IMSDK.GroupManager.destroyGroup |
| GroupManager.addMembers | EMGroupManager.addUsersToGroup / EMGroupManager.asyncAddUsersToGroup | IEMGroupManager.addMembers:toGroup:message:completion: | IMSDK.GroupManager.inviteUsersToGroup |
| GroupManager.removeMembers | EMGroupManager.removeUsersFromGroup / EMGroupManager.asyncRemoveUsersFromGroup | IEMGroupManager.removeMembers:fromGroup:completion: | IMSDK.GroupManager.removeGroupMembers |
| GroupManager.getGroupSpecificationFromServer | EMGroupManager.getGroupFromServer / EMGroupManager.asyncGetGroupFromServer | IEMGroupManager.getGroupSpecificationFromServerWithId:completion: / IEMGroupManager.getGroupSpecificationFromServerWithId:fetchMembers:completion: | IMSDK.GroupManager.getGroupInfo |
| PresenceManager.publishPresenceWithDescription | EMPresenceManager.publishPresence | IEMPresenceManager.publishPresenceWithDescription:completion: | IMSDK.PresenceManager.publishPresence |
| PresenceManager.presenceSubscribe | EMPresenceManager.subscribePresences | IEMPresenceManager.subscribe:expiry:completion: | IMSDK.PresenceManager.subscribePresence |
| PresenceManager.presenceUnsubscribe | EMPresenceManager.unsubscribePresences | IEMPresenceManager.unsubscribe:completion: | IMSDK.PresenceManager.unsubscribePresence |
| PresenceManager.fetchPresenceStatus | EMPresenceManager.fetchPresenceStatus | IEMPresenceManager.fetchPresenceStatus:completion: | IMSDK.PresenceManager.getPresenceStatus |
| ChatManager.ackConversationRead | EMChatManager.asyncClearConversationUnreadMessageCount | IEMChatManager.clearConversationUnreadMessageCount:completion: | IMSDK.ChatManager.clearConversationUnreadMessageCount |
| ChatManager.ackGroupMessageRead | EMChatManager.asyncSendMessageReadReceipts | IEMChatManager.sendMessageReadReceipts:completion: | IMSDK.ChatManager.sendMessageReadReceipts |
| ChatManager.ackMessageRead | EMChatManager.asyncSendMessageReadReceipts | IEMChatManager.sendMessageReadReceipts:completion: | IMSDK.ChatManager.sendMessageReadReceipts |
| ChatManager.addRemoteAndLocalConversationsMark | EMChatManager.asyncAddConversationMark | IEMChatManager.addConversationMark:mark:completion: | IMSDK.ChatManager.addConversationMark |
| ChatManager.asyncFetchGroupAcks | EMChatManager.asyncFetchGroupMessageReadReceipts | IEMChatManager.asyncFetchGroupMessageReadUsersFromServer:groupId:readReceiptId:pageSize:completion: | IMSDK.ChatManager.getGroupMessageReadReceipts |
| ChatManager.deleteAllMessageAndConversation | EMChatManager.asyncDeleteAllMsgsAndConversations | IEMChatManager.deleteAllMessagesAndConversations:completion: | IMSDK.ChatManager.clearAllMessagesAndConversations |
| ChatManager.deleteConversation | EMChatManager.deleteConversation | IEMChatManager.deleteConversation:isDeleteMessages:completion: | IMSDK.ChatManager.deleteConversation |
| ChatManager.deleteConversations | EMChatManager.asyncDeleteConversations | IEMChatManager.deleteConversations:isDeleteMessages:completion: | IMSDK.ChatManager.deleteConversation |
| ChatManager.deleteMessagesBeforeTimestamp | EMChatManager.deleteMessagesBeforeTimestamp | IEMChatManager.deleteMessagesBefore:completion: | IMSDK.ChatManager.removeHistoryMessages |
| ChatManager.deleteRemoteAndLocalConversationsMark | EMChatManager.asyncRemoveConversationMark | IEMChatManager.removeConversationMark:mark:completion: | IMSDK.ChatManager.removeConversationMark |
| ChatManager.deleteRemoteConversation | EMChatManager.deleteConversationFromServer | IEMChatManager.deleteServerConversation:conversationType:isDeleteServerMessages:completion: | IMSDK.ChatManager.deleteConversation |
| ChatManager.downloadAndParseCombineMessage | EMChatManager.downloadAndParseCombineMessage | IEMChatManager.downloadAndParseCombineMessage:completion: | IMSDK.ChatManager.downloadAndParseCombineMessage |
| ChatManager.downloadAttachment | EMChatManager.downloadAttachment | IEMChatManager.downloadMessageAttachment:progress:completion: | IMSDK.ChatManager.downloadAttachment |
| ChatManager.downloadThumbnail | EMChatManager.downloadThumbnail | IEMChatManager.downloadMessageThumbnail:progress:completion: | IMSDK.ChatManager.downloadAttachment |
| ChatManager.fetchHistoryMessagesByOptions | EMChatManager.asyncFetchHistoryMessages | IEMChatManager.fetchMessagesFromServerBy:conversationType:cursor:pageSize:option:completion: | IMSDK.ChatManager.getHistoryMessages |
| ChatManager.fetchPinnedMessages | EMChatManager.asyncGetPinnedMessagesFromServer | IEMChatManager.getPinnedMessagesFromServer:completion: | IMSDK.ChatManager.getPinnedMessageList |
| ChatManager.fetchSupportLanguages | EMChatManager.fetchSupportLanguages | IEMChatManager.fetchSupportedLanguages: | IMSDK.ChatManager.getSupportedTranslationLanguages |
| ChatManager.getGroupMessageReadReceipts | EMChatManager.asyncGetGroupMessageReadReceipts | IEMChatManager.getGroupMessageReadReceipts:completion: | IMSDK.ChatManager.getGroupMessageReadReceipts |
| ChatManager.loadAllConversations | EMChatManager.getAllConversations / EMChatManager.getAllConversationsBySort | IEMChatManager.getAllConversations / IEMChatManager.getAllConversations: | `ChatManager.getConversationList(filter?)` |
| ChatManager.loadConversationMessagesWithKeyword | EMChatManager.asyncLoadConversationMessagesWithKeyword | IEMChatManager.loadConversationMessagesWithKeyword:timestamp:fromUser:searchDirection:scope:completion: | IMSDK.ChatManager.searchMessages |
| ChatManager.markAllChatMsgAsRead | EMChatManager.asyncClearAllConversationUnreadMessageCount | IEMChatManager.clearAllConversationUnreadMessageCount: | IMSDK.ChatManager.clearConversationUnreadMessageCount |
| ChatManager.pinConversation | EMChatManager.asyncPinConversation | IEMChatManager.pinConversation:isPinned:completionBlock: | IMSDK.ChatManager.setConversationPinned |
| ChatManager.pinMessage | EMChatManager.asyncPinMessage | IEMChatManager.pinMessage:completion: | IMSDK.ChatManager.pinMessage |
| ChatManager.removeMessagesFromServerWithMsgIds | EMConversation.removeMessagesFromServer | IEMChatManager.removeMessagesFromServerWithConversation:messageIds:completion: / EMConversation.removeMessagesFromServerMessageIds:completion: | IMSDK.ChatManager.removeHistoryMessages |
| ChatManager.removeMessagesFromServerWithTs | EMConversation.removeMessagesFromServer | IEMChatManager.removeMessagesFromServerWithConversation:timeStamp:completion: / EMConversation.removeMessagesFromServerWithTimeStamp:completion: | IMSDK.ChatManager.removeHistoryMessages |
| ChatManager.resendMessage | EMChatManager.sendMessage | IEMChatManager.sendMessage:progress:completion: | IMSDK.ChatManager.sendMessage |
| ChatManager.searchChatMsgFromDB | EMChatManager.searchMsgFromDB | IEMChatManager.loadMessagesWithKeyword:timestamp:count:fromUser:searchDirection:scope:completion: | IMSDK.ChatManager.searchMessages |
| ChatManager.searchMessagesFromServer | EMChatManager.asyncSearchMessagesFromServer | IEMChatManager.searchMessagesFromServerWithOption:pageSize:pageNum:completion: | IMSDK.ChatManager.searchMessages |
| ChatManager.searchMsgsByOptions | EMChatManager.searchMsgFromDB | IEMChatManager.searchMessagesWithTypes:timestamp:count:fromUser:searchDirection:completion: | IMSDK.ChatManager.searchMessages |
| ChatManager.translateMessage | EMChatManager.translateMessage | IEMChatManager.translateMessage:targetLanguages:completion: | IMSDK.ChatManager.translateMessage |
| ChatManager.unpinMessage | EMChatManager.asyncUnPinMessage | IEMChatManager.unpinMessage:completion: | IMSDK.ChatManager.unpinMessage |
| ChatManager.updateChatMessage | EMChatManager.updateMessage | IEMChatManager.updateMessage:completion: | IMSDK.ChatManager.modifyMessage |
| ChatManager.voiceFileToText | EMChatManager.voiceFileToText | IEMChatManager.voiceFileToText:voiceParam:completion: | IMSDK.ChatManager.voiceFileToText |
| ChatManager.voiceMessageToText | EMChatManager.voiceMessageToText | IEMChatManager.voiceMessageToText:completion: | IMSDK.ChatManager.voiceMessageToText |
| ConversationManager.markAllMessagesAsRead | EMChatManager.asyncClearConversationUnreadMessageCount | IEMChatManager.clearConversationUnreadMessageCount:completion: | IMSDK.ChatManager.clearAllConversationUnreadMessageCount |
| ConversationManager.pinnedMessages | EMConversation.pinnedMessages | EMConversation.pinnedMessages | IMSDK.ChatManager.getPinnedMessageList |
| MessageManager.chatThread | EMMessage.getChatThread | EMChatMessage.chatThread | IMSDK.ChatThreadManager.getChatThread |
| MessageManager.getPinInfo | EMMessage.pinnedInfo | EMChatMessage.pinnedInfo | IMSDK.ChatManager.getPinnedMessageList |
| MessageManager.getReactionList | EMMessage.getMessageReaction | EMChatMessage.reactionList | IMSDK.ChatManager.getReactionList |
| MessageManager.groupAckCount | EMMessage.readReceiptCount | EMChatMessage.groupReadReceiptCount | IMSDK.ChatManager.getGroupMessageReadReceipts |
| ChatRoomManager.fetchPublicChatRoomsFromServer | EMChatRoomManager.fetchPublicChatRoomsFromServer / EMChatRoomManager.asyncFetchPublicChatRoomsFromServer | IEMChatroomManager.getChatroomsFromServerWithPage:pageSize:error: / IEMChatroomManager.getChatroomsFromServerWithPage:pageSize:completion: | IMSDK.ChatRoomManager.getChatRoomList |
| ChatRoomManager.fetchChatRoomInfoFromServer | EMChatRoomManager.fetchChatRoomFromServer / EMChatRoomManager.asyncFetchChatRoomFromServer | IEMChatroomManager.getChatroomSpecificationFromServerWithId:error: / IEMChatroomManager.getChatroomSpecificationFromServerWithId:completion: / IEMChatroomManager.getChatroomSpecificationFromServerWithId:fetchMembers:completion: | IMSDK.ChatRoomManager.getChatRoomInfo |
| ChatRoomManager.getChatRoom | EMChatRoomManager.getChatRoom | EMChatroom.chatroomWithId: | IMSDK.ChatRoomManager.getChatRoom |
| ChatRoomManager.fetchChatRoomMembers | EMChatRoomManager.fetchChatRoomMembers / EMChatRoomManager.asyncFetchChatRoomMembers | IEMChatroomManager.getChatroomMemberListFromServerWithId:cursor:pageSize:error: / IEMChatroomManager.getChatroomMemberListFromServerWithId:cursor:pageSize:completion: | IMSDK.ChatRoomManager.getMemberList |
| ChatRoomManager.fetchChatRoomMuteList | EMChatRoomManager.fetchChatRoomMuteList / EMChatRoomManager.asyncFetchChatRoomMuteList | IEMChatroomManager.getChatroomMuteListFromServerWithId:pageNumber:pageSize:error: / IEMChatroomManager.getChatroomMuteListFromServerWithId:pageNumber:pageSize:completion: | IMSDK.ChatRoomManager.getMuteList |
| ChatRoomManager.fetchChatRoomBlockList | EMChatRoomManager.fetchChatRoomBlackList / EMChatRoomManager.asyncFetchChatRoomBlackList | IEMChatroomManager.getChatroomBlacklistFromServerWithId:pageNumber:pageSize:error: / IEMChatroomManager.getChatroomBlacklistFromServerWithId:pageNumber:pageSize:completion: | IMSDK.ChatRoomManager.getBlocklist |
| ChatRoomManager.fetchChatRoomWhiteListFromServer | EMChatRoomManager.fetchChatRoomWhiteList | IEMChatroomManager.getChatroomWhiteListFromServerWithId:error: / IEMChatroomManager.getChatroomWhiteListFromServerWithId:completion: | IMSDK.ChatRoomManager.getAllowlist |
| ChatRoomManager.isMemberInChatRoomMuteList | EMChatRoomManager.asyncCheckIfInMuteList | IEMChatroomManager.isMemberInMuteListFromServerWithChatroomId:completion: | IMSDK.ChatRoomManager.checkIfInMuteList |
| ChatRoomManager.isMemberInChatRoomWhiteListFromServer | EMChatRoomManager.checkIfInChatRoomWhiteList | IEMChatroomManager.isMemberInWhiteListFromServerWithChatroomId:error: / IEMChatroomManager.isMemberInWhiteListFromServerWithChatroomId:completion: | IMSDK.ChatRoomManager.checkIfInAllowList |
| ChatRoomManager.joinChatRoom | EMChatRoomManager.joinChatRoom | IEMChatroomManager.joinChatroom:error: / IEMChatroomManager.joinChatroom:completion: / IEMChatroomManager.joinChatroom:ext:leaveOtherRooms:completion: | IMSDK.ChatRoomManager.joinChatRoom |
| ChatRoomManager.leaveChatRoom | EMChatRoomManager.leaveChatRoom | IEMChatroomManager.leaveChatroom:error: / IEMChatroomManager.leaveChatroom:completion: | IMSDK.ChatRoomManager.leaveChatRoom |
| ChatRoomManager.muteAllChatRoomMembers | EMChatRoomManager.muteAllMembers | IEMChatroomManager.muteAllMembersFromChatroom:error: / IEMChatroomManager.muteAllMembersFromChatroom:completion: | IMSDK.ChatRoomManager.muteAllMembers |
| ChatRoomManager.unMuteAllChatRoomMembers | EMChatRoomManager.unmuteAllMembers | IEMChatroomManager.unmuteAllMembersFromChatroom:error: / IEMChatroomManager.unmuteAllMembersFromChatroom:completion: | IMSDK.ChatRoomManager.unmuteAllMembers |
| ChatRoomManager.muteChatRoomMembers | EMChatRoomManager.muteChatRoomMembers / EMChatRoomManager.asyncMuteChatRoomMembers | IEMChatroomManager.muteMembers:muteMilliseconds:fromChatroom:error: / IEMChatroomManager.muteMembers:muteMilliseconds:fromChatroom:completion: | IMSDK.ChatRoomManager.muteMembers |
| ChatRoomManager.unMuteChatRoomMembers | EMChatRoomManager.unMuteChatRoomMembers / EMChatRoomManager.asyncUnMuteChatRoomMembers | IEMChatroomManager.unmuteMembers:fromChatroom:error: / IEMChatroomManager.unmuteMembers:fromChatroom:completion: | IMSDK.ChatRoomManager.unmuteMembers |
| ChatRoomManager.blockChatRoomMembers | EMChatRoomManager.blockChatroomMembers / EMChatRoomManager.asyncBlockChatroomMembers | IEMChatroomManager.blockMembers:fromChatroom:error: / IEMChatroomManager.blockMembers:fromChatroom:completion: | IMSDK.ChatRoomManager.blockMembers |
| ChatRoomManager.unBlockChatRoomMembers | EMChatRoomManager.unblockChatRoomMembers / EMChatRoomManager.asyncUnBlockChatRoomMembers | IEMChatroomManager.unblockMembers:fromChatroom:error: / IEMChatroomManager.unblockMembers:fromChatroom:completion: | IMSDK.ChatRoomManager.unblockMembers |
| ChatRoomManager.removeChatRoomMembers | EMChatRoomManager.removeChatRoomMembers / EMChatRoomManager.asyncRemoveChatRoomMembers | IEMChatroomManager.removeMembers:fromChatroom:error: / IEMChatroomManager.removeMembers:fromChatroom:completion: | IMSDK.ChatRoomManager.removeMembers |
| ChatRoomManager.addMembersToChatRoomWhiteList | EMChatRoomManager.addToChatRoomWhiteList | IEMChatroomManager.addWhiteListMembers:fromChatroom:error: / IEMChatroomManager.addWhiteListMembers:fromChatroom:completion: | IMSDK.ChatRoomManager.addUsersToAllowlist |
| ChatRoomManager.removeMembersFromChatRoomWhiteList | EMChatRoomManager.removeFromChatRoomWhiteList | IEMChatroomManager.removeWhiteListMembers:fromChatroom:error: / IEMChatroomManager.removeWhiteListMembers:fromChatroom:completion: | IMSDK.ChatRoomManager.removeUsersFromAllowlist |
| ChatRoomManager.addChatRoomAdmin | EMChatRoomManager.addChatRoomAdmin / EMChatRoomManager.asyncAddChatRoomAdmin | IEMChatroomManager.addAdmin:toChatroom:error: / IEMChatroomManager.addAdmin:toChatroom:completion: | IMSDK.ChatRoomManager.addAdmin |
| ChatRoomManager.removeChatRoomAdmin | EMChatRoomManager.removeChatRoomAdmin / EMChatRoomManager.asyncRemoveChatRoomAdmin | IEMChatroomManager.removeAdmin:fromChatroom:error: / IEMChatroomManager.removeAdmin:fromChatroom:completion: | IMSDK.ChatRoomManager.removeAdmin |
| ChatRoomManager.fetchChatRoomAllAttributesFromServer | EMChatRoomManager.asyncFetchChatRoomAllAttributesFromServer | IEMChatroomManager.fetchChatroomAllAttributes:completion: | IMSDK.ChatRoomManager.getAttributes |
| ChatRoomManager.fetchChatRoomAttributes | EMChatRoomManager.asyncFetchChatroomAttributesFromServer | IEMChatroomManager.fetchChatroomAttributes:keys:completion: | IMSDK.ChatRoomManager.getAttributes |
| ChatRoomManager.setChatRoomAttributes | EMChatRoomManager.asyncSetChatroomAttributes / EMChatRoomManager.asyncSetChatroomAttributesForced | IEMChatroomManager.setChatroomAttributes:attributes:autoDelete:completionBlock: / IEMChatroomManager.setChatroomAttributesForced:attributes:autoDelete:completionBlock: | IMSDK.ChatRoomManager.setAttributes |
| ChatRoomManager.removeChatRoomAttributes | EMChatRoomManager.asyncRemoveChatRoomAttributesFromServer / EMChatRoomManager.asyncRemoveChatRoomAttributesFromServerForced | IEMChatroomManager.removeChatroomAttributes:attributes:completionBlock: / IEMChatroomManager.removeChatroomAttributesForced:attributes:completionBlock: | IMSDK.ChatRoomManager.removeAttributes |
| ChatRoomManager.removeChatRoomAttributeFromServer | EMChatRoomManager.asyncRemoveChatRoomAttributeFromServer | IEMChatroomManager.removeChatroomAttribute:key:completionBlock: | IMSDK.ChatRoomManager.removeAttributes |
| ChatRoomManager.removeChatRoomAttributeFromServerForced | EMChatRoomManager.asyncRemoveChatRoomAttributeFromServerForced | IEMChatroomManager.removeChatroomAttributeForced:key:completionBlock: | IMSDK.ChatRoomManager.removeAttributes |
| ChatRoomManager.updateChatRoomAnnouncement | EMChatRoomManager.updateChatRoomAnnouncement / EMChatRoomManager.asyncUpdateChatRoomAnnouncement | IEMChatroomManager.updateChatroomAnnouncementWithId:announcement:error: / IEMChatroomManager.updateChatroomAnnouncementWithId:announcement:completion: | IMSDK.ChatRoomManager.updateAnnouncement |
| ChatRoomManager.fetchChatRoomAnnouncement | EMChatRoomManager.fetchChatRoomAnnouncement / EMChatRoomManager.asyncFetchChatRoomAnnouncement | IEMChatroomManager.getChatroomAnnouncementWithId:error: / IEMChatroomManager.getChatroomAnnouncementWithId:completion: | IMSDK.ChatRoomManager.getAnnouncement |
| ChatRoomManager.changeChatRoomSubject | EMChatRoomManager.changeChatRoomSubject / EMChatRoomManager.asyncChangeChatRoomSubject | IEMChatroomManager.updateSubject:forChatroom:error: / IEMChatroomManager.updateSubject:forChatroom:completion: | IMSDK.ChatRoomManager.updateChatRoomInfo |
| ChatRoomManager.changeChatRoomDescription | EMChatRoomManager.changeChatroomDescription / EMChatRoomManager.asyncChangeChatroomDescription | IEMChatroomManager.updateDescription:forChatroom:error: / IEMChatroomManager.updateDescription:forChatroom:completion: | IMSDK.ChatRoomManager.updateChatRoomInfo |
| ChatRoomManager.changeChatRoomOwner | EMChatRoomManager.changeOwner / EMChatRoomManager.asyncChangeOwner | IEMChatroomManager.updateChatroomOwner:newOwner:error: / IEMChatroomManager.updateChatroomOwner:newOwner:completion: | IMSDK.ChatRoomManager.updateChatRoomInfo |
| ChatThreadManager.createChatThread | EMChatThreadManager.createChatThread | IEMThreadManager.createChatThread:messageId:parentId:completion: | IMSDK.ChatThreadManager.createChatThread |
| ChatThreadManager.destroyChatThread | EMChatThreadManager.destroyChatThread | IEMThreadManager.destroyChatThread:completion: | IMSDK.ChatThreadManager.destroyChatThread |
| ChatThreadManager.fetchChatThreadDetail | EMChatThreadManager.getChatThreadFromServer | IEMThreadManager.getChatThreadFromSever:completion: | IMSDK.ChatThreadManager.getChatThreadInfo |
| ChatThreadManager.fetchChatThreadMember | EMChatThreadManager.getChatThreadMembers | IEMThreadManager.getChatThreadMemberListFromServerWithId:cursor:pageSize:completion: | IMSDK.ChatThreadManager.getChatThreadMemberList |
| ChatThreadManager.fetchChatThreadsWithParentId | EMChatThreadManager.getChatThreadsFromServer | IEMThreadManager.getChatThreadsFromServerWithParentId:cursor:pageSize:completion: | IMSDK.ChatThreadManager.getChatThreadList |
| ChatThreadManager.fetchJoinedChatThreads | EMChatThreadManager.getJoinedChatThreadsFromServer | IEMThreadManager.getJoinedChatThreadsFromServerWithCursor:pageSize:completion: | IMSDK.ChatThreadManager.getJoinedChatThreadList |
| ChatThreadManager.fetchJoinedChatThreadsWithParentId | EMChatThreadManager.getJoinedChatThreadsFromServer | IEMThreadManager.getJoinedChatThreadsFromServerWithParentId:cursor:pageSize:completion: | IMSDK.ChatThreadManager.getJoinedChatThreadList |
| ChatThreadManager.fetchLastMessageWithChatThreads | EMChatThreadManager.getChatThreadLatestMessage | IEMThreadManager.getLastMessageFromSeverWithChatThreads:completion: | IMSDK.ChatThreadManager.getChatThreadLastMessageList |
| ChatThreadManager.joinChatThread | EMChatThreadManager.joinChatThread | IEMThreadManager.joinChatThread:completion: | IMSDK.ChatThreadManager.joinChatThread |
| ChatThreadManager.leaveChatThread | EMChatThreadManager.leaveChatThread | IEMThreadManager.leaveChatThread:completion: | IMSDK.ChatThreadManager.leaveChatThread |
| ChatThreadManager.removeMemberFromChatThread | EMChatThreadManager.removeMemberFromChatThread | IEMThreadManager.removeMemberFromChatThread:threadId:completion: | IMSDK.ChatThreadManager.removeChatThreadMember |
| ChatThreadManager.updateChatThreadSubject | EMChatThreadManager.updateChatThreadName | IEMThreadManager.updateChatThreadName:threadId:completion: | IMSDK.ChatThreadManager.updateChatThreadName |
| ContactManager.fetchAllContacts | EMContactManager.asyncFetchAllContactsFromLocal | IEMContactManager.getAllContacts | IMSDK.ContactManager.getContacts |
| ContactManager.getAllContactsFromDB | EMContactManager.getContactsFromLocal | IEMContactManager.getContacts | IMSDK.ContactManager.getContacts |
| ContactManager.getBlockListFromServer | EMContactManager.getBlackListFromServer / asyncGetBlackListFromServer | IEMContactManager.getBlackListFromServerWithCompletion: | IMSDK.ContactManager.getBlocklist |
| ContactManager.getSelfIdsOnOtherPlatform | EMContactManager.getSelfIdsOnOtherPlatform / asyncGetSelfIdsOnOtherPlatform | IEMContactManager.getSelfIdsOnOtherPlatformWithCompletion: | IMSDK.ChatClient.getSelfIdsOnOtherPlatform |
| GroupManager.acceptInvitationFromGroup | EMGroupManager.acceptInvitation / EMGroupManager.asyncAcceptInvitation | IEMGroupManager.acceptInvitationFromGroup:inviter:completion: | IMSDK.GroupManager.acceptInvitation |
| GroupManager.acceptJoinApplication | EMGroupManager.acceptApplication / EMGroupManager.asyncAcceptApplication | IEMGroupManager.approveJoinGroupRequest:sender:completion: | IMSDK.GroupManager.acceptGroupJoinRequest |
| GroupManager.addAdmin | EMGroupManager.addGroupAdmin / EMGroupManager.asyncAddGroupAdmin | IEMGroupManager.addAdmin:toGroup:completion: | IMSDK.GroupManager.addGroupAdmin |
| GroupManager.addWhiteList | EMGroupManager.addToGroupWhiteList | IEMGroupManager.addWhiteListMembers:fromGroup:completion: | IMSDK.GroupManager.addUsersToGroupAllowlist |
| GroupManager.blockMembers | EMGroupManager.blockUsers / EMGroupManager.asyncBlockUsers | IEMGroupManager.blockMembers:fromGroup:completion: | IMSDK.GroupManager.blockGroupMembers |
| GroupManager.blockUser | EMGroupManager.blockUser / EMGroupManager.asyncBlockUser | IEMGroupManager.blockMembers:fromGroup:completion: | IMSDK.GroupManager.blockGroupMembers |
| GroupManager.declineInvitationFromGroup | EMGroupManager.declineInvitation / EMGroupManager.asyncDeclineInvitation | IEMGroupManager.declineGroupInvitation:inviter:reason:completion: | IMSDK.GroupManager.rejectInvitation |
| GroupManager.declineJoinApplication | EMGroupManager.declineApplication / EMGroupManager.asyncDeclineApplication | IEMGroupManager.declineJoinGroupRequest:sender:reason:completion: | IMSDK.GroupManager.rejectGroupJoinRequest |
| GroupManager.downloadGroupSharedFile | EMGroupManager.downloadGroupSharedFile / EMGroupManager.asyncDownloadGroupSharedFile | IEMGroupManager.downloadGroupSharedFileWithId:filePath:sharedFileId:progress:completion: | IMSDK.GroupManager.downloadGroupSharedFile |
| GroupManager.fetchGroupBlackList | EMGroupManager.fetchGroupBlackList / EMGroupManager.asyncFetchGroupBlackList | IEMGroupManager.getGroupBlacklistFromServerWithId:pageNumber:pageSize:completion: | IMSDK.GroupManager.getGroupBlocklist |
| GroupManager.fetchGroupMembersInfo | EMGroupManager.asyncFetchGroupMembersInfo | IEMGroupManager.fetchGroupMemberInfoListFromServerWithGroupId:cursor:limit:completion: | IMSDK.GroupManager.getGroupMemberList |
| GroupManager.fetchMemberAttributesFromGroup | EMGroupManager.asyncFetchGroupMemberAllAttributes | IEMGroupManager.fetchMemberAttribute:userId:completion: | IMSDK.GroupManager.getGroupMembersAttributes |
| GroupManager.fetchMembersAttributesFromGroup | EMGroupManager.asyncFetchGroupMembersAttributes | IEMGroupManager.fetchMembersAttributes:userIds:keys:completion: | IMSDK.GroupManager.getGroupMembersAttributes |
| GroupManager.fetchMemberAllAttributes | EMGroupManager.asyncFetchGroupMemberAllAttributes（单成员全部属性） | IEMGroupManager.fetchMemberAttribute:userId:completion:（单成员全部属性） | IMSDK.GroupManager.getGroupMembersAttributes | iOS 原生语义可对应；wrapper 需要把 `{k:v}` 归一为 Android 的 `{userId:{k:v}}`，不能标记为原生缺失。 |
| GroupManager.getGroupAnnouncementFromServer | EMGroupManager.fetchGroupAnnouncement / EMGroupManager.asyncFetchGroupAnnouncement | IEMGroupManager.getGroupAnnouncementWithId:completion: | IMSDK.GroupManager.getGroupAnnouncement |
| GroupManager.getGroupBlockListFromServer | EMGroupManager.getBlockedUsers / EMGroupManager.asyncGetBlockedUsers | IEMGroupManager.getGroupBlacklistFromServerWithId:pageNumber:pageSize:completion: | IMSDK.GroupManager.getGroupBlocklist |
| GroupManager.getGroupFileListFromServer | EMGroupManager.fetchGroupSharedFileList / EMGroupManager.asyncFetchGroupSharedFileList | IEMGroupManager.getGroupFileListWithId:pageNumber:pageSize:completion: | IMSDK.GroupManager.getGroupSharedFileList |
| GroupManager.getGroupMuteListFromServer | EMGroupManager.fetchGroupMuteList / EMGroupManager.asyncFetchGroupMuteList | IEMGroupManager.fetchGroupMuteListFromServerWithId:pageNumber:pageSize:completion: | IMSDK.GroupManager.getGroupMuteList |
| GroupManager.getGroupWhiteListFromServer | EMGroupManager.fetchGroupWhiteList | IEMGroupManager.getGroupWhiteListFromServerWithId:completion: | IMSDK.GroupManager.getGroupAllowlist |
| GroupManager.inviterUser | EMGroupManager.inviteUser / EMGroupManager.asyncInviteUser | IEMGroupManager.addMembers:toGroup:message:completion: | IMSDK.GroupManager.inviteUsersToGroup |
| GroupManager.isMemberInGroupMuteList | EMGroupManager.asyncCheckIfInMuteList | IEMGroupManager.isMemberInMuteListFromServerWithGroupId:completion: | IMSDK.GroupManager.checkIfInGroupMuteList |
| GroupManager.isMemberInWhiteListFromServer | EMGroupManager.checkIfInGroupWhiteList | IEMGroupManager.isMemberInWhiteListFromServerWithGroupId:completion: | IMSDK.GroupManager.checkIfInGroupAllowList |
| GroupManager.muteAllMembers | EMGroupManager.muteAllMembers | IEMGroupManager.muteAllMembersFromGroup:completion: | IMSDK.GroupManager.muteAllGroupMembers |
| GroupManager.muteMembers | EMGroupManager.muteGroupMembers / EMGroupManager.asyncMuteGroupMembers | IEMGroupManager.muteMembers:muteMilliseconds:fromGroup:completion: | IMSDK.GroupManager.muteGroupMembers |
| GroupManager.removeAdmin | EMGroupManager.removeGroupAdmin / EMGroupManager.asyncRemoveGroupAdmin | IEMGroupManager.removeAdmin:fromGroup:completion: | IMSDK.GroupManager.removeGroupAdmin |
| GroupManager.removeGroupSharedFile | EMGroupManager.deleteGroupSharedFile / EMGroupManager.asyncDeleteGroupSharedFile | IEMGroupManager.removeGroupSharedFileWithId:sharedFileId:completion: | IMSDK.GroupManager.deleteGroupSharedFile |
| GroupManager.removeUserFromGroup | EMGroupManager.removeUserFromGroup / EMGroupManager.asyncRemoveUserFromGroup | IEMGroupManager.removeMembers:fromGroup:completion: | IMSDK.GroupManager.removeGroupMembers |
| GroupManager.removeWhiteList | EMGroupManager.removeFromGroupWhiteList | IEMGroupManager.removeWhiteListMembers:fromGroup:completion: | IMSDK.GroupManager.removeUsersFromGroupAllowlist |
| GroupManager.setMemberAttributesFromGroup | EMGroupManager.asyncSetGroupMemberAttributes | IEMGroupManager.setMemberAttribute:userId:attributes:completion: | IMSDK.GroupManager.setGroupMemberAttributes |
| GroupManager.unMuteAllMembers | EMGroupManager.unmuteAllMembers | IEMGroupManager.unmuteAllMembersFromGroup:completion: | IMSDK.GroupManager.unmuteAllGroupMembers |
| GroupManager.unMuteMembers | EMGroupManager.unMuteGroupMembers / EMGroupManager.asyncUnMuteGroupMembers | IEMGroupManager.unmuteMembers:fromGroup:completion: | IMSDK.GroupManager.unmuteGroupMembers |
| GroupManager.unblockMembers | EMGroupManager.unblockUsers / EMGroupManager.asyncUnblockUsers | IEMGroupManager.unblockMembers:fromGroup:completion: | IMSDK.GroupManager.unblockGroupMembers |
| GroupManager.unblockUser | EMGroupManager.unblockUser / EMGroupManager.asyncUnblockUser | IEMGroupManager.unblockMembers:fromGroup:completion: | IMSDK.GroupManager.unblockGroupMembers |
| GroupManager.updateDescription | EMGroupManager.changeGroupDescription / EMGroupManager.asyncChangeGroupDescription | IEMGroupManager.updateDescription:forGroup:completion: | IMSDK.GroupManager.updateGroupInfo |
| GroupManager.updateGroupAnnouncement | EMGroupManager.updateGroupAnnouncement / EMGroupManager.asyncUpdateGroupAnnouncement | IEMGroupManager.updateGroupAnnouncementWithId:announcement:completion: | IMSDK.GroupManager.updateGroupAnnouncement |
| GroupManager.updateGroupAvatar | EMGroupManager.changeGroupAvatar / EMGroupManager.asyncChangeGroupAvatar | IEMGroupManager.updateGroupAvatar:groupId:completion: | IMSDK.GroupManager.updateGroupInfo |
| GroupManager.updateGroupConfigs | EMGroupManager.updateGroupConfigs / EMGroupManager.asyncUpdateGroupConfigs | IEMGroupManager.updateGroupWithId:types:configs:completion: | IMSDK.GroupManager.updateGroupInfo |
| GroupManager.updateGroupExt | EMGroupManager.updateGroupExtension / EMGroupManager.asyncUpdateGroupExtension | IEMGroupManager.updateGroupExtWithId:ext:completion: | IMSDK.GroupManager.updateGroupInfo |
| GroupManager.updateGroupExtension | EMGroupManager.updateGroupExtension / EMGroupManager.asyncUpdateGroupExtension | IEMGroupManager.updateGroupExtWithId:ext:completion: | IMSDK.GroupManager.updateGroupInfo |
| GroupManager.updateGroupOwner | EMGroupManager.changeOwner / EMGroupManager.asyncChangeOwner | IEMGroupManager.updateGroupOwner:newOwner:completion: | IMSDK.GroupManager.changeGroupOwner |
| GroupManager.updateGroupSubject | EMGroupManager.changeGroupName / EMGroupManager.asyncChangeGroupName | IEMGroupManager.updateGroupSubject:forGroup:completion: | IMSDK.GroupManager.updateGroupInfo |
| GroupManager.uploadGroupSharedFile | EMGroupManager.uploadGroupSharedFile / EMGroupManager.asyncUploadGroupSharedFile | IEMGroupManager.uploadGroupSharedFileWithId:filePath:progress:completion: | IMSDK.GroupManager.uploadGroupSharedFile |
| PresenceManager.fetchSubscribedMembersWithPageNum | EMPresenceManager.fetchSubscribedMembers | IEMPresenceManager.fetchSubscribedMembersWithPageNum:pageSize:Completion: | IMSDK.PresenceManager.getSubscribedPresenceList |
| PushManager.bindDeviceToken | EMPushManager.bindDeviceToken | EMClient.registerForRemoteNotificationsWithCertName:deviceToken:completion: | IMSDK.PushManager.uploadPushToken |
| PushManager.fetchConversationSilentMode | EMPushManager.getSilentModeForConversation | IEMPushManager.getSilentModeForConversation:conversationType:completion: | IMSDK.PushManager.getConversationSilentMode |
| PushManager.fetchPreferredNotificationLanguage | EMPushManager.getPreferredNotificationLanguage | IEMPushManager.getPreferredNotificationLanguageCompletion: | IMSDK.PushManager.getPushLanguage |
| PushManager.fetchSilentModeForAll | EMPushManager.getSilentModeForAll | IEMPushManager.getSilentModeForAllWithCompletion: | IMSDK.PushManager.getGlobalSilentMode |
| PushManager.fetchSilentModeForConversations | EMPushManager.getSilentModeForConversations | IEMPushManager.getSilentModeForConversations:completion: | IMSDK.PushManager.getConversationSilentModes |
| PushManager.removeConversationSilentMode | EMPushManager.clearRemindTypeForConversation | IEMPushManager.clearRemindTypeForConversation:conversationType:completion: | IMSDK.PushManager.clearConversationRemindType |
| PushManager.setConversationSilentMode | EMPushManager.setSilentModeForConversation | IEMPushManager.setSilentModeForConversation:conversationType:params:completion: | IMSDK.PushManager.setConversationSilentMode |
| PushManager.setPreferredNotificationLanguage | EMPushManager.setPreferredNotificationLanguage | IEMPushManager.setPreferredNotificationLanguage:completion: | IMSDK.PushManager.setPushLanguage |
| PushManager.setSilentModeForAll | EMPushManager.setSilentModeForAll | IEMPushManager.setSilentModeForAll:completion: | IMSDK.PushManager.setGlobalSilentMode |
| PushManager.updateFCMPushToken | EMClient.sendFCMTokenToServer | EMClient.bindFCMToken:completion: | IMSDK.PushManager.uploadPushToken |
| PushManager.updateHMSPushToken | EMClient.sendHMSPushTokenToServer | — | IMSDK.PushManager.uploadPushToken |
| UserInfoManager.fetchOwnInfo | EMClient.getCurrentUser + EMUserInfoManager.fetchUserInfoByUserId | EMClient.currentUsername + IEMUserInfoManager.fetchUserInfoById:completion: | IMSDK.UserInfoManager.getUserInfoByUserId |
| UserInfoManager.fetchSubscribedUsers | EMUserInfoManager.fetchSubscribedUsers | IEMUserInfoManager.fetchSubscribedUsers: | IMSDK.UserInfoManager.getSubscribedUsers |
| UserInfoManager.fetchUserInfoById | EMUserInfoManager.fetchUserInfoByUserId | IEMUserInfoManager.fetchUserInfoById:completion: | IMSDK.UserInfoManager.getUserInfoByUserId |
| UserInfoManager.fetchUserInfoByIdWithType | EMUserInfoManager.fetchUserInfoByAttribute | IEMUserInfoManager.fetchUserInfoById:type:completion: | IMSDK.UserInfoManager.getUserInfoByAttribute |
| UserInfoManager.getUserInfoWithUserId | EMUserInfoManager.getUserInfoWithUserId | IEMUserInfoManager.getUserInfoByIds: | IMSDK.UserInfoManager.getUserInfoByUserId |
| UserInfoManager.getUserInfoWithUserIds | EMUserInfoManager.getUserInfoWithUserIds | IEMUserInfoManager.getUserInfoByIds: | `UserInfoManager.getUserInfoByUserId({userIds})`，wrapper 将数组转换为 `{userId: userInfo}` |
| UserInfoManager.subscribeUsersInfo | EMUserInfoManager.subscribeUsersInfo | IEMUserInfoManager.subscribeUsersInfo:completion: | IMSDK.UserInfoManager.subscribeUsersInfo |
| UserInfoManager.unsubscribeUsersInfo | EMUserInfoManager.unsubscribeUsersInfo | IEMUserInfoManager.unsubscribeUsersInfo:completion: | IMSDK.UserInfoManager.unsubscribeUsersInfo |
| UserInfoManager.updateOwnUserInfo | EMUserInfoManager.updateOwnInfo | IEMUserInfoManager.updateOwnUserInfo:completion: | IMSDK.UserInfoManager.updateOwnInfo |
| UserInfoManager.updateOwnUserInfoWithType | EMUserInfoManager.updateOwnInfoByAttribute | IEMUserInfoManager.updateOwnUserInfo:withType:completion: | IMSDK.UserInfoManager.updateOwnInfoByAttribute |

### Matrix 并集补充

以下协议存在于 Android/iOS 5.0 Matrix，但不在 Web 5.0 Matrix；Web 列统一使用 `xxx`。主表与本补充表合计覆盖三端 Matrix 的全部 284 个协议。

| 统一协议 | Android 5.0 原生 API | iOS 5.0 原生 API | Web 5.0 原生 API / 当前 Wrapper 调用 |
|---|---|---|---|
| `ChatManager.cleanConversationsMemoryCache` | `EMChatManager.cleanConversationsMemoryCache` | `IEMChatManager.cleanConversationsMemoryCache` | `xxx` |
| `ChatManager.downloadBigImage` | `EMChatManager.downloadBigImage` | `IEMChatManager.downloadBigImageAttachment:progress:completion:` | `xxx` |
| `ChatManager.downloadMessageAttachmentInCombine` | `EMChatManager.downloadAttachment` | `IEMChatManager.downloadMessageAttachment:progress:completion:` | `xxx` |
| `ChatManager.downloadMessageThumbnailInCombine` | `EMChatManager.downloaVdThumbnail` | `IEMChatManager.downloadMessageThumbnail:progress:completion:` | `xxx` |
| `ChatManager.filterConversationsFromDB` | `EMChatManager.asyncFilterConversationsFromDB` | `IEMChatManager.filterConversationsFromDB:filter:` | `xxx` |
| `ChatManager.getConversation` | `EMChatManager.getConversation` | `IEMChatManager.getConversationWithConvId: / IEMChatManager.getConversation:type:createIfNotExist:` | `xxx` |
| `ChatManager.getConversationsByType` | `EMChatManager.getConversationsByType` | `xxx` | `xxx` |
| `ChatManager.getMessage` | `EMChatManager.getMessage` | `IEMChatManager.getMessageWithMessageId:` | `xxx` |
| `ChatManager.getMessageCount` | `EMChatManager.asyncGetMessageCount` | `IEMChatManager.getMessageCountWithCompletion:` | `xxx` |
| `ChatManager.getThreadConversation` | `EMChatManager.getConversation` | `IEMChatManager.getConversation:type:createIfNotExist:isThread:` | `xxx` |
| `ChatManager.getUnreadMessageCount` | `EMChatManager.getUnreadMessageCount` | `IEMChatManager.getUnreadMessageCount` | `xxx` |
| `ChatManager.importMessages` | `EMChatManager.importMessages` | `IEMChatManager.importMessages:completion:` | `xxx` |
| `ChatManager.loadMessagesWithIds` | `EMChatManager.asyncLoadMessages` | `IEMChatManager.getMessages:withConversationId:completion:` | `xxx` |
| `ChatManager.saveMessage` | `EMChatManager.saveMessage` | `xxx` | `xxx` |
| `ChatManager.setVoiceMessageListened` | `EMChatManager.setVoiceMessageListened` | `EMChatMessage.setIsListened:` | `xxx` |
| `ChatRoomManager.setChatroomAttribute` | `EMChatRoomManager.asyncSetChatroomAttribute` | `IEMChatroomManager.setChatroomAttribute:key:value:autoDelete:completionBlock:` | `xxx` |
| `ChatRoomManager.setChatroomAttributeForced` | `EMChatRoomManager.asyncSetChatroomAttributeForced` | `IEMChatroomManager.setChatroomAttributeForced:key:value:autoDelete:completionBlock:` | `xxx` |
| `Client.acceptInvitationAlways` | `EMOptions.setAcceptInvitationAlways` | `EMOptions.autoAcceptFriendInvitation` | `xxx` |
| `Client.changeAppId` | `EMClient.changeAppId` | `EMClient.changeAppId:` | `xxx` |
| `Client.changeAppKey` | `EMClient.changeAppkey` | `EMClient.changeAppkey:` | `xxx` |
| `Client.compressLogs` | `EMClient.compressLogs` | `EMClient.getLogFilesPathWithCompletion:` | `xxx` |
| `Client.getDataSyncType` | `EMOptions.getDataSyncType` | `EMOptions.dataSyncType` | `xxx` |
| `Client.getLoggedInDevicesFromServer` | `EMClient.fetchLoggedInDevicesFromServerWithToken` | `EMClient.getLoggedInDevicesFromServerWithUserId:token:completion:` | `xxx` |
| `Client.getToken` | `EMClient.getAccessToken` | `EMClient.accessUserToken` | `xxx` |
| `Client.isDatabaseOpened` | `EMClient.isDatabaseOpened` | `xxx` | `xxx` |
| `Client.isLoggedInBefore` | `EMClient.isLoggedIn` | `EMClient.isLoggedIn` | `xxx` |
| `Client.kickAllDevices` | `EMClient.kickAllDevicesWithToken` | `EMClient.kickAllDevicesWithUserId:token:completion:` | `xxx` |
| `Client.kickDevice` | `EMClient.kickDeviceWithToken` | `EMClient.kickDeviceWithUserId:token:resource:completion:` | `xxx` |
| `Client.notifyTokenExpired` | `EMClient.notifyTokenExpired` | `xxx` | `xxx` |
| `Client.sendFCMTokenToServer` | `EMClient.sendFCMTokenToServer` | `EMClient.bindFCMToken:completion:` | `xxx` |
| `Client.sendHonorPushTokenToServer` | `EMClient.sendHonorPushTokenToServer` | `xxx` | `xxx` |
| `Client.setDataSyncType` | `EMOptions.setDataSyncType` | `EMOptions.setDataSyncType:` | `xxx` |
| `Client.updateAutoAcceptGroupInvitationSetting` | `EMOptions.setAutoAcceptGroupInvitation` | `EMOptions.autoAcceptGroupInvitation` | `xxx` |
| `Client.updateAutoDownloadAttachmentThumbnailSetting` | `EMOptions.setAutoDownloadThumbnail` | `EMOptions.autoDownloadThumbnail` | `xxx` |
| `Client.updateDeleteMessageWhenLeaveRoomSetting` | `EMOptions.setDeleteMessagesAsExitChatRoom` | `EMOptions.deleteMessagesOnLeaveChatroom` | `xxx` |
| `Client.updateDeleteMessagesWhenLeaveGroupSetting` | `EMOptions.setDeleteMessagesAsExitGroup` | `EMOptions.deleteMessagesOnLeaveGroup` | `xxx` |
| `Client.updateDeliveryAckSetting` | `EMOptions.setRequireDeliveryAck` | `EMOptions.enableDeliveryAck` | `xxx` |
| `Client.updateLoginExtensionInfo` | `EMOptions.setLoginCustomExt` | `EMOptions.loginExtensionInfo` | `xxx` |
| `Client.updateMessagesReceiveCallbackIncludeSendSetting` | `EMOptions.setIncludeSendMessageInMessageListener` | `EMOptions.includeSendMessageInMessageListener` | `xxx` |
| `Client.updateRegradeMessagesSetting` | `EMOptions.setRegardImportedMsgAsRead` | `EMOptions.regardImportMessagesAsRead` | `xxx` |
| `Client.updateRoomOwnerCanLeaveSetting` | `EMOptions.allowChatroomOwnerLeave` | `EMOptions.canChatroomOwnerLeave` | `xxx` |
| `Client.updateSortMessageByServerTimeSetting` | `EMOptions.setSortMessageByServerTime` | `EMOptions.sortMessageByServerTime` | `xxx` |
| `Client.updateUsingHttpsOnlySetting` | `EMOptions.setUsingHttpsOnly` | `EMOptions.usingHttpsOnly` | `xxx` |
| `Client.uploadLog` | `EMClient.uploadLog` | `EMClient.uploadDebugLogToServerWithCompletion:` | `xxx` |
| `ContactManager.getContact` | `EMContactManager.fetchContactFromLocal` | `IEMContactManager.getContact:` | `xxx` |
| `ContactManager.saveBlackList` | `EMContactManager.saveBlackList / asyncSaveBlackList` | `IEMContactManager.saveBlackList:completion:` | `xxx` |
| `ConversationManager.appendMessage` | `EMConversation.appendMessage` | `EMConversation.appendMessage:error:` | `xxx` |
| `ConversationManager.clearAllMessages` | `EMConversation.clearAllMessages` | `EMConversation.deleteAllMessages:` | `xxx` |
| `ConversationManager.conversationDeleteServerMessageWithIds` | `EMConversation.removeMessagesFromServer` | `EMConversation.removeMessagesFromServerMessageIds:completion:` | `xxx` |
| `ConversationManager.conversationDeleteServerMessageWithTime` | `EMConversation.removeMessagesFromServer` | `EMConversation.removeMessagesFromServerWithTimeStamp:completion:` | `xxx` |
| `ConversationManager.conversationGetLocalMessageCount` | `EMConversation.getAllMsgCount` | `EMConversation.getMessageCountStart:to:` | `xxx` |
| `ConversationManager.conversationRemindType` | `EMConversation.pushRemindType` | `EMConversation.disturbType` | `xxx` |
| `ConversationManager.conversationSearchMsgsByOptions` | `EMConversation.searchMsgFromDB` | `EMConversation.searchMessagesWithTypes:timestamp:count:fromUser:searchDirection:completion:` | `xxx` |
| `ConversationManager.deleteMessageByIds` | `EMConversation.removeMessage` | `EMConversation.deleteMessageWithId:error:` | `xxx` |
| `ConversationManager.deleteMessagesWithTs` | `EMConversation.removeMessages` | `EMConversation.removeMessagesStart:to:` | `xxx` |
| `ConversationManager.getConversationAvatar` | `EMConversation.getConversationAvatar` | `EMConversation.conversationAvatar` | `xxx` |
| `ConversationManager.getConversationName` | `EMConversation.getConversationName` | `EMConversation.conversationName` | `xxx` |
| `ConversationManager.getLatestMessage` | `EMConversation.getLastMessage` | `EMConversation.latestMessage` | `xxx` |
| `ConversationManager.getLatestMessageFromOthers` | `EMConversation.getLatestMessageFromOthers` | `EMConversation.lastReceivedMessage` | `xxx` |
| `ConversationManager.getUnreadMsgCount` | `EMConversation.getUnreadMsgCount` | `EMConversation.unreadMessagesCount` | `xxx` |
| `ConversationManager.insertMessage` | `EMConversation.insertMessage` | `EMConversation.insertMessage:error:` | `xxx` |
| `ConversationManager.loadMsgWithId` | `EMConversation.getMessage` | `EMConversation.loadMessageWithId:error:` | `xxx` |
| `ConversationManager.loadMsgWithKeywords` | `EMConversation.asyncSearchMsgFromDB` | `EMConversation.loadMessagesWithKeyword:timestamp:count:fromUsers:searchDirection:scope:completion:` | `xxx` |
| `ConversationManager.loadMsgWithMsgType` | `EMConversation.searchMsgFromDB` | `EMConversation.loadMessagesWithType:timestamp:count:fromUser:searchDirection: / EMConversation.loadMessagesWithType:timestamp:count:fromUser:searchDirection:completion:` | `xxx` |
| `ConversationManager.loadMsgWithStartId` | `EMConversation.loadMoreMsgFromDB` | `EMConversation.loadMessagesStartFromId:count:searchDirection: / EMConversation.loadMessagesStartFromId:count:searchDirection:completion:` | `xxx` |
| `ConversationManager.loadMsgWithTime` | `EMConversation.searchMsgFromDB` | `EMConversation.loadMessagesFrom:to:count: / EMConversation.loadMessagesFrom:to:count:completion:` | `xxx` |
| `ConversationManager.markMessageAsRead` | `EMChatManager.asyncSendMessageReadReceipts` | `IEMChatManager.sendMessageReadReceipts:completion:` | `xxx` |
| `ConversationManager.messageCount` | `EMConversation.getAllMsgCount` | `EMConversation.messagesCount` | `xxx` |
| `ConversationManager.removeMessage` | `EMConversation.removeMessage` | `EMConversation.deleteMessageWithId:error:` | `xxx` |
| `ConversationManager.removeMsgFromServerWithTimeStamp` | `EMConversation.removeMessagesFromServer` | `EMConversation.removeMessagesFromServerWithTimeStamp:completion:` | `xxx` |
| `ConversationManager.syncConversationExt` | `EMConversation.setExtField` | `EMConversation.setExt:` | `xxx` |
| `ConversationManager.updateConversationMessage` | `EMConversation.updateMessage` | `EMConversation.updateMessageChange:error:` | `xxx` |
| `GroupManager.blockGroup` | `EMGroupManager.blockGroupMessage / EMGroupManager.asyncBlockGroupMessage` | `IEMGroupManager.blockGroup:completion:` | `xxx` |
| `GroupManager.clearAllGroupsFromDB` | `EMGroupManager.cleanAllGroupsFromLocal` | `IEMGroupManager.cleanAllGroupsFromDB` | `xxx` |
| `GroupManager.fetchJoinedGroupCount` | `EMGroupManager.asyncGetJoinedGroupsCountFromServer` | `IEMGroupManager.getJoinedGroupsCountFromServerWithCompletion:` | `xxx` |
| `GroupManager.getGroupNamecard` | `EMGroupManager.getGroupNamecard` | `IEMGroupManager.getGroupNamecardWithGroupId:userId:` | `xxx` |
| `GroupManager.getUsers` | `EMGroup.getUsers` | `EMGroup.users` | `xxx` |
| `GroupManager.removeMemberAttributesFromGroup` | `EMGroupManager.asyncSetGroupMemberAttributes` | `IEMGroupManager.setMemberAttribute:userId:attributes:completion:` | `xxx` |
| `GroupManager.unblockGroup` | `EMGroupManager.unblockGroupMessage / EMGroupManager.asyncUnblockGroupMessage` | `IEMGroupManager.unblockGroup:completion:` | `xxx` |
| `GroupManager.updateGroupNamecard` | `EMGroupManager.asyncUpdateGroupNamecard` | `IEMGroupManager.updateGroupNamecard:namecard:completion:` | `xxx` |
| `PushManager.getImPushConfig` | `EMPushManager.getPushConfigs` | `IEMPushManager.pushOptions` | `xxx` |
| `PushManager.getImPushConfigFromServer` | `EMPushManager.getPushConfigsFromServer / asyncGetPushConfigsFromServer` | `IEMPushManager.getPushNotificationOptionsFromServerWithCompletion:` | `xxx` |
| `PushManager.getPushConfigsFromServer` | `EMPushManager.getPushConfigsFromServer / asyncGetPushConfigsFromServer` | `IEMPushManager.getPushNotificationOptionsFromServerWithCompletion:` | `xxx` |
| `PushManager.getPushTemplate` | `EMPushManager.getPushTemplate` | `IEMPushManager.getPushTemplate:` | `xxx` |
| `PushManager.reportPushAction` | `EMPushManager.reportPushAction` | `xxx` | `xxx` |
| `PushManager.setPushTemplate` | `EMPushManager.setPushTemplate` | `IEMPushManager.setPushTemplate:completion:` | `xxx` |
| `PushManager.syncSilentModels` | `EMPushManager.syncSilentModeConversationsFromServer` | `IEMPushManager.syncSilentModeConversationsFromServerCompletion:` | `xxx` |
| `PushManager.updateAPNsPushToken` | `xxx` | `EMClient.bindDeviceToken: / EMClient.registerForRemoteNotificationsWithDeviceToken:completion:` | `xxx` |
| `PushManager.updateImPushStyle` | `EMPushManager.updatePushDisplayStyle / asyncUpdatePushDisplayStyle` | `IEMPushManager.updatePushDisplayStyle:completion:` | `xxx` |
| `PushManager.updatePushNickname` | `EMPushManager.updatePushNickname / asyncUpdatePushNickname` | `IEMPushManager.updatePushDisplayName:completion:` | `xxx` |

## Web 平台独有或暂未纳入公共协议的业务 API

这些能力属于 Web 5.0 原生包，但 Android/iOS 当前没有可直接复用的同语义公共协议。已实现的 Web-only 能力可以直接写 Web case；其余能力先评估是否值得新增协议。

| Web 协议/原生 API | 状态 | 说明 |
|---|---|---|
| `ChatManager.createTextMessage` | 已接入 Wrapper | Web 端独有的消息构造便利 API，不改变公共发送协议。 |
| `ChatManager.getGroupMessageReadUsers` | 待评估 | 群消息已读用户明细；现有 `groupAckCount` 只覆盖汇总读取。 |
| `ChatRoomManager.getAdminList` | 待评估 | 聊天室管理员列表；当前公共协议通过管理员事件和聊天室详情覆盖。 |
| `GroupManager.getGroupAdminList` | 待评估 | 群管理员列表，不等同于群详情中的 `adminList` 字段。 |
| `GroupManager.getGroupInfoList` | 待评估 | 批量查询群信息，需先确认 Android/iOS 是否有同语义能力。 |

## 维护原则

- 公共 Matrix 已登记并有三端实现的能力，不在本文重复列为“缺口”。
- 新增平台能力时，先判断是否与现有协议语义一致；一致则补平台映射，不一致则登记为平台独有协议。
- 原生错误码、返回结构或事件时序不同，优先修 Wrapper 映射或记录平台差异，不直接放宽业务断言。

## 原生 API 与跨端协议的归类

上方公共协议表已经列出 API Matrix 中的统一协议。下面只列两类内容：已有语义但协议/wrapper 不完整的能力，以及原生包中尚未进入 Matrix 的业务 API。不会重复列出已在 Matrix 中的 API，也不列 getter、setter、构造器、消息体属性和内部辅助方法。

| 分类 | 处理规则 |
|---|---|
| 已有统一语义但 wrapper 未实现 | 保持一个统一协议名，补缺失平台的 wrapper/映射；不能为通过测试改业务断言。 |
| 原生有能力但 Matrix 未登记 | 先判断三端语义；语义一致就新增公共协议，只有单端能力就登记为 Android-only、iOS-only 或 Web-only。 |
| 非业务 public 方法 | 不进入本表；例如生命周期、配置对象属性、缓存/校验/事件分发辅助方法。 |

### 仍未进入公共 Matrix 的 iOS 业务 API

| 原生 API/能力 | 业务含义 | 建议归类 |
|---|---|---|
| `updateGroupNamecard:` / `getGroupNamecardWithGroupId:` | 群成员名片更新/查询 | 有跨端同语义就补公共协议，否则 iOS-only。 |
| 聊天室成员分页、黑名单、禁言列表及属性 forced/non-forced 入口 | 聊天室服务端成员和属性管理 | 按业务语义补公共协议，不按 Objective-C selector 拆 case。 |

### Matrix 外的 Web 业务 API

| 原生 API | 业务含义 | 建议归类 |
|---|---|---|
| `ChatManager.getGroupMessageReadUsers` | 查询群消息已读用户明细 | 与 Android/iOS 群已读回执明细能力确认后补公共协议。 |
| `ChatRoomManager.getAdminList` | 查询聊天室管理员列表 | 确认其他端同语义后决定公共协议或 Web-only。 |
| `GroupManager.getGroupAdminList` | 查询群管理员列表 | 与群详情 `adminList` 不是同一个接口，需独立确认。 |
| `GroupManager.getGroupInfoList` | 批量查询群信息 | 确认 Android/iOS 批量群信息能力后决定公共协议或 Web-only。 |

### 事件边界

事件协议继续由 `android-events.yaml`、`ios-events.yaml`、`web-events.yaml` 维护，不和 API 方法表混写。三端同语义事件使用统一 `eventType`；平台独有事件单独登记和测试。

### 结论

- 上方 Matrix 表：已覆盖的统一协议，只列一次。
- 本节：只列 wrapper 缺口和 Matrix 外的业务 API。
- 原生包中的内部方法、模型字段和生命周期方法：不列入业务 API 清单。
