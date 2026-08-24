Android / iOS 5.0 原生 API、Event 与统一协议映射

口径

- 第一列是当前统一协议名；Android/iOS 两列只写 5.0 原生公开方法或回调名。
- 以业务语义对应为准；同步/异步重载合并。
- “协议残留”表示协议名存在，但两个 5.0 原生包都没有对应公开能力。
- “原生未进协议”只覆盖 Client/Manager/Conversation/Thread 等公开业务 API 与回调；不穷举普通 model getter/setter、构造器及内部符号。

API

统一协议 API：两端语义对应

| 模块.统一协议 API | Android 5.0 原生 API | iOS 5.0 原生 API |
|---|---|---|
| Client.init | EMClient.init | EMClient.initializeSDKWithOptions: |
| Client.login | EMClient.loginWithToken | EMClient.loginWithUsername:token:completion: |
| Client.loginWithAgoraToken | EMClient.loginWithToken | EMClient.loginWithUsername:token:completion: |
| Client.renewToken | EMClient.renewToken | EMClient.renewToken:completion: |
| Client.logout | EMClient.logout | EMClient.logout:completion: |
| Client.changeAppKey | EMClient.changeAppkey | EMClient.changeAppkey: |
| Client.uploadLog | EMClient.uploadLog | EMClient.uploadDebugLogToServerWithCompletion: |
| Client.compressLogs | EMClient.compressLogs | EMClient.getLogFilesPathWithCompletion: |
| Client.kickDevice | EMClient.kickDeviceWithToken | EMClient.kickDeviceWithUserId:token:resource:completion: |
| Client.kickAllDevices | EMClient.kickAllDevicesWithToken | EMClient.kickAllDevicesWithUserId:token:completion: |
| Client.getLoggedInDevicesFromServer | EMClient.fetchLoggedInDevicesFromServerWithToken | EMClient.getLoggedInDevicesFromServerWithUserId:token:completion: |
| Client.getToken | EMClient.getAccessToken | EMClient.accessUserToken |
| Client.getCurrentUser | EMClient.getCurrentUser | EMClient.currentUsername |
| Client.isLoggedInBefore | EMClient.isLoggedIn | EMClient.isLoggedIn |
| Client.isConnected | EMClient.isConnected | EMClient.isConnected |
| Client.updateUsingHttpsOnlySetting | EMOptions.setUsingHttpsOnly | EMOptions.usingHttpsOnly |
| Client.updateLoginExtensionInfo | EMOptions.setLoginCustomExt | EMOptions.loginExtensionInfo |
| Client.updateDeleteMessagesWhenLeaveGroupSetting | EMOptions.setDeleteMessagesAsExitGroup | EMOptions.deleteMessagesOnLeaveGroup |
| Client.updateDeleteMessageWhenLeaveRoomSetting | EMOptions.setDeleteMessagesAsExitChatRoom | EMOptions.deleteMessagesOnLeaveChatroom |
| Client.updateRoomOwnerCanLeaveSetting | EMOptions.allowChatroomOwnerLeave | EMOptions.canChatroomOwnerLeave |
| Client.updateAutoAcceptGroupInvitationSetting | EMOptions.setAutoAcceptGroupInvitation | EMOptions.autoAcceptGroupInvitation |
| Client.acceptInvitationAlways | EMOptions.setAcceptInvitationAlways | EMOptions.autoAcceptFriendInvitation |
| Client.updateAutoDownloadAttachmentThumbnailSetting | EMOptions.setAutoDownloadThumbnail | EMOptions.autoDownloadThumbnail |
| Client.updateDeliveryAckSetting | EMOptions.setRequireDeliveryAck | EMOptions.enableDeliveryAck |
| Client.updateSortMessageByServerTimeSetting | EMOptions.setSortMessageByServerTime | EMOptions.sortMessageByServerTime |
| Client.updateMessagesReceiveCallbackIncludeSendSetting | EMOptions.setIncludeSendMessageInMessageListener | EMOptions.includeSendMessageInMessageListener |
| Client.updateRegradeMessagesSetting | EMOptions.setRegardImportedMsgAsRead | EMOptions.regardImportMessagesAsRead |
| Client.changeAppId | EMClient.changeAppId | EMClient.changeAppId: |
| Client.sendFCMTokenToServer | EMClient.sendFCMTokenToServer | EMClient.bindFCMToken:completion: |
| Client.getRTCTokenInfoWithChannelName | EMClient.asyncGetRTCTokenInfoWithChannelName | EMClient.getRTCTokenWithChannel:completion: |
| Client.getUserIdsWithRTCUids | EMClient.asyncGetUserIdsWithRTCUids | EMClient.getUserIdByRTCUIds:completion: |
| Client.setDataSyncType | EMOptions.setDataSyncType | EMOptions.setDataSyncType: |
| Client.getDataSyncType | EMOptions.getDataSyncType | EMOptions.dataSyncType |
| Contact.addContact | EMContactManager.addContact / asyncAddContact | IEMContactManager.addContact:message:completion: |
| Contact.deleteContact | EMContactManager.deleteContact / asyncDeleteContact | IEMContactManager.deleteContact:isDeleteConversation:completion: |
| Contact.getAllContactsFromDB | EMContactManager.getContactsFromLocal | IEMContactManager.getContacts |
| Contact.addUserToBlockList | EMContactManager.addUserToBlackList / asyncAddUserToBlackList | IEMContactManager.addUserToBlackList:completion: |
| Contact.removeUserFromBlockList | EMContactManager.removeUserFromBlackList / asyncRemoveUserFromBlackList | IEMContactManager.removeUserFromBlackList:completion: |
| Contact.getBlockListFromServer | EMContactManager.getBlackListFromServer / asyncGetBlackListFromServer | IEMContactManager.getBlackListFromServerWithCompletion: |
| Contact.getBlockListFromDB | EMContactManager.getBlackListUsernames | IEMContactManager.getBlackList |
| Contact.acceptInvitation | EMContactManager.acceptInvitation / asyncAcceptInvitation | IEMContactManager.approveFriendRequestFromUser:completion: |
| Contact.declineInvitation | EMContactManager.declineInvitation / asyncDeclineInvitation | IEMContactManager.declineFriendRequestFromUser:completion: |
| Contact.getSelfIdsOnOtherPlatform | EMContactManager.getSelfIdsOnOtherPlatform / asyncGetSelfIdsOnOtherPlatform | IEMContactManager.getSelfIdsOnOtherPlatformWithCompletion: |
| Contact.getAllContacts | EMContactManager.asyncFetchAllContactsFromLocal | IEMContactManager.getAllContacts |
| Contact.setContactRemark | EMContactManager.asyncSetContactRemark | IEMContactManager.setContactRemark:remark:completion: |
| Contact.getContact | EMContactManager.fetchContactFromLocal | IEMContactManager.getContact: |
| Contact.fetchAllContacts | EMContactManager.asyncFetchAllContactsFromLocal | IEMContactManager.getAllContacts |
| Contact.saveBlackList | EMContactManager.saveBlackList / asyncSaveBlackList | IEMContactManager.saveBlackList:completion: |
| Presence.publishPresenceWithDescription | EMPresenceManager.publishPresence | IEMPresenceManager.publishPresenceWithDescription:completion: |
| Presence.presenceSubscribe | EMPresenceManager.subscribePresences | IEMPresenceManager.subscribe:expiry:completion: |
| Presence.presenceUnsubscribe | EMPresenceManager.unsubscribePresences | IEMPresenceManager.unsubscribe:completion: |
| Presence.fetchSubscribedMembersWithPageNum | EMPresenceManager.fetchSubscribedMembers | IEMPresenceManager.fetchSubscribedMembersWithPageNum:pageSize:Completion: |
| Presence.fetchPresenceStatus | EMPresenceManager.fetchPresenceStatus | IEMPresenceManager.fetchPresenceStatus:completion: |
| UserInfo.updateOwnUserInfo | EMUserInfoManager.updateOwnInfo | IEMUserInfoManager.updateOwnUserInfo:completion: |
| UserInfo.updateOwnUserInfoWithType | EMUserInfoManager.updateOwnInfoByAttribute | IEMUserInfoManager.updateOwnUserInfo:withType:completion: |
| UserInfo.fetchOwnInfo | EMClient.getCurrentUser + EMUserInfoManager.fetchUserInfoByUserId | EMClient.currentUsername + IEMUserInfoManager.fetchUserInfoById:completion: |
| UserInfo.fetchUserInfoById | EMUserInfoManager.fetchUserInfoByUserId | IEMUserInfoManager.fetchUserInfoById:completion: |
| UserInfo.fetchUserInfoByIdWithType | EMUserInfoManager.fetchUserInfoByAttribute | IEMUserInfoManager.fetchUserInfoById:type:completion: |
| UserInfo.getUserInfoWithUserId | EMUserInfoManager.getUserInfoWithUserId | IEMUserInfoManager.getUserInfoByIds: |
| UserInfo.getUserInfoWithUserIds | EMUserInfoManager.getUserInfoWithUserIds | IEMUserInfoManager.getUserInfoByIds: |
| UserInfo.subscribeUsersInfo | EMUserInfoManager.subscribeUsersInfo | IEMUserInfoManager.subscribeUsersInfo:completion: |
| UserInfo.unsubscribeUsersInfo | EMUserInfoManager.unsubscribeUsersInfo | IEMUserInfoManager.unsubscribeUsersInfo:completion: |
| UserInfo.fetchSubscribedUsers | EMUserInfoManager.fetchSubscribedUsers | IEMUserInfoManager.fetchSubscribedUsers: |
| Push.getImPushConfig | EMPushManager.getPushConfigs | IEMPushManager.pushOptions |
| Push.getImPushConfigFromServer | EMPushManager.getPushConfigsFromServer / asyncGetPushConfigsFromServer | IEMPushManager.getPushNotificationOptionsFromServerWithCompletion: |
| Push.getPushConfigsFromServer | EMPushManager.getPushConfigsFromServer / asyncGetPushConfigsFromServer | IEMPushManager.getPushNotificationOptionsFromServerWithCompletion: |
| Push.updateImPushStyle | EMPushManager.updatePushDisplayStyle / asyncUpdatePushDisplayStyle | IEMPushManager.updatePushDisplayStyle:completion: |
| Push.updatePushNickname | EMPushManager.updatePushNickname / asyncUpdatePushNickname | IEMPushManager.updatePushDisplayName:completion: |
| Push.updateFCMPushToken | EMClient.sendFCMTokenToServer | EMClient.bindFCMToken:completion: |
| Push.setConversationSilentMode | EMPushManager.setSilentModeForConversation | IEMPushManager.setSilentModeForConversation:conversationType:params:completion: |
| Push.removeConversationSilentMode | EMPushManager.clearRemindTypeForConversation | IEMPushManager.clearRemindTypeForConversation:conversationType:completion: |
| Push.fetchConversationSilentMode | EMPushManager.getSilentModeForConversation | IEMPushManager.getSilentModeForConversation:conversationType:completion: |
| Push.setSilentModeForAll | EMPushManager.setSilentModeForAll | IEMPushManager.setSilentModeForAll:completion: |
| Push.fetchSilentModeForAll | EMPushManager.getSilentModeForAll | IEMPushManager.getSilentModeForAllWithCompletion: |
| Push.fetchSilentModeForConversations | EMPushManager.getSilentModeForConversations | IEMPushManager.getSilentModeForConversations:completion: |
| Push.setPreferredNotificationLanguage | EMPushManager.setPreferredNotificationLanguage | IEMPushManager.setPreferredNotificationLanguage:completion: |
| Push.fetchPreferredNotificationLanguage | EMPushManager.getPreferredNotificationLanguage | IEMPushManager.getPreferredNotificationLanguageCompletion: |
| Push.setPushTemplate | EMPushManager.setPushTemplate | IEMPushManager.setPushTemplate:completion: |
| Push.getPushTemplate | EMPushManager.getPushTemplate | IEMPushManager.getPushTemplate: |
| Push.syncSilentModels | EMPushManager.syncSilentModeConversationsFromServer | IEMPushManager.syncSilentModeConversationsFromServerCompletion: |
| Push.bindDeviceToken | EMPushManager.bindDeviceToken | EMClient.registerForRemoteNotificationsWithCertName:deviceToken:completion: |
| ChatManager.sendMessage | EMChatManager.sendMessage | IEMChatManager.sendMessage:progress:completion: |
| ChatManager.resendMessage | EMChatManager.sendMessage | IEMChatManager.sendMessage:progress:completion: |
| ChatManager.ackMessageRead | EMChatManager.asyncSendMessageReadReceipts | IEMChatManager.sendMessageReadReceipts:completion: |
| ChatManager.ackGroupMessageRead | EMChatManager.asyncSendMessageReadReceipts | IEMChatManager.sendMessageReadReceipts:completion: |
| ChatManager.ackConversationRead | EMChatManager.asyncClearConversationUnreadMessageCount | IEMChatManager.clearConversationUnreadMessageCount:completion: |
| ChatManager.recallMessage | EMChatManager.recallMessage / EMChatManager.asyncRecallMessage | IEMChatManager.recallMessageWithMessageId:completion: / IEMChatManager.recallMessageWithMessageId:ext:completion: |
| ChatManager.getConversation | EMChatManager.getConversation | IEMChatManager.getConversationWithConvId: / IEMChatManager.getConversation:type:createIfNotExist: |
| ChatManager.getThreadConversation | EMChatManager.getConversation | IEMChatManager.getConversation:type:createIfNotExist:isThread: |
| ChatManager.markAllChatMsgAsRead | EMChatManager.asyncClearAllConversationUnreadMessageCount | IEMChatManager.clearAllConversationUnreadMessageCount: |
| ChatManager.getUnreadMessageCount | EMChatManager.getUnreadMessageCount | IEMChatManager.getUnreadMessageCount |
| ChatManager.updateChatMessage | EMChatManager.updateMessage | IEMChatManager.updateMessage:completion: |
| ChatManager.downloadAttachment | EMChatManager.downloadAttachment | IEMChatManager.downloadMessageAttachment:progress:completion: |
| ChatManager.downloadBigImage | EMChatManager.downloadBigImage | IEMChatManager.downloadBigImageAttachment:progress:completion: |
| ChatManager.downloadThumbnail | EMChatManager.downloadThumbnail | IEMChatManager.downloadMessageThumbnail:progress:completion: |
| ChatManager.downloadMessageAttachmentInCombine | EMChatManager.downloadAttachment | IEMChatManager.downloadMessageAttachment:progress:completion: |
| ChatManager.downloadMessageThumbnailInCombine | EMChatManager.downloadThumbnail | IEMChatManager.downloadMessageThumbnail:progress:completion: |
| ChatManager.importMessages | EMChatManager.importMessages | IEMChatManager.importMessages:completion: |
| ChatManager.loadAllConversations | EMChatManager.getAllConversations / EMChatManager.getAllConversationsBySort | IEMChatManager.getAllConversations / IEMChatManager.getAllConversations: |
| ChatManager.deleteConversation | EMChatManager.deleteConversation | IEMChatManager.deleteConversation:isDeleteMessages:completion: |
| ChatManager.fetchHistoryMessages | EMChatManager.asyncFetchHistoryMessages | IEMChatManager.fetchMessagesFromServerBy:conversationType:cursor:pageSize:option:completion: |
| ChatManager.fetchHistoryMessagesByOptions | EMChatManager.asyncFetchHistoryMessages | IEMChatManager.fetchMessagesFromServerBy:conversationType:cursor:pageSize:option:completion: |
| ChatManager.searchChatMsgFromDB | EMChatManager.searchMsgFromDB | IEMChatManager.loadMessagesWithKeyword:timestamp:count:fromUser:searchDirection:scope:completion: |
| ChatManager.getMessage | EMChatManager.getMessage | IEMChatManager.getMessageWithMessageId: |
| ChatManager.asyncFetchGroupAcks | EMChatManager.asyncFetchGroupMessageReadReceipts | IEMChatManager.asyncFetchGroupMessageReadUsersFromServer:groupId:readReceiptId:pageSize:completion: |
| ChatManager.deleteRemoteConversation | EMChatManager.deleteConversationFromServer | IEMChatManager.deleteServerConversation:conversationType:isDeleteServerMessages:completion: |
| ChatManager.deleteMessagesBeforeTimestamp | EMChatManager.deleteMessagesBeforeTimestamp | IEMChatManager.deleteMessagesBefore:completion: |
| ChatManager.translateMessage | EMChatManager.translateMessage | IEMChatManager.translateMessage:targetLanguages:completion: |
| ChatManager.fetchSupportLanguages | EMChatManager.fetchSupportLanguages | IEMChatManager.fetchSupportedLanguages: |
| ChatManager.addReaction | EMChatManager.addReaction / EMChatManager.asyncAddReaction | IEMChatManager.addReaction:toMessage:completion: |
| ChatManager.removeReaction | EMChatManager.removeReaction / EMChatManager.asyncRemoveReaction | IEMChatManager.removeReaction:fromMessage:completion: |
| ChatManager.fetchReactionList | EMChatManager.getReactionList / EMChatManager.asyncGetReactionList | IEMChatManager.getReactionList:groupId:chatType:completion: |
| ChatManager.fetchReactionDetail | EMChatManager.getReactionDetail / EMChatManager.asyncGetReactionDetail | IEMChatManager.getReactionDetail:reaction:cursor:pageSize:completion: |
| ChatManager.removeMessagesFromServerWithMsgIds | EMConversation.removeMessagesFromServer | IEMChatManager.removeMessagesFromServerWithConversation:messageIds:completion: / EMConversation.removeMessagesFromServerMessageIds:completion: |
| ChatManager.removeMessagesFromServerWithTs | EMConversation.removeMessagesFromServer | IEMChatManager.removeMessagesFromServerWithConversation:timeStamp:completion: / EMConversation.removeMessagesFromServerWithTimeStamp:completion: |
| ChatManager.pinConversation | EMChatManager.asyncPinConversation | IEMChatManager.pinConversation:isPinned:completionBlock: |
| ChatManager.modifyMessage | EMChatManager.asyncModifyMessage | IEMChatManager.modifyMessage:body:ext:completion: |
| ChatManager.downloadAndParseCombineMessage | EMChatManager.downloadAndParseCombineMessage | IEMChatManager.downloadAndParseCombineMessage:completion: |
| ChatManager.addRemoteAndLocalConversationsMark | EMChatManager.asyncAddConversationMark | IEMChatManager.addConversationMark:mark:completion: |
| ChatManager.deleteRemoteAndLocalConversationsMark | EMChatManager.asyncRemoveConversationMark | IEMChatManager.removeConversationMark:mark:completion: |
| ChatManager.deleteAllMessageAndConversation | EMChatManager.asyncDeleteAllMsgsAndConversations | IEMChatManager.deleteAllMessagesAndConversations:completion: |
| ChatManager.pinMessage | EMChatManager.asyncPinMessage | IEMChatManager.pinMessage:completion: |
| ChatManager.unpinMessage | EMChatManager.asyncUnPinMessage | IEMChatManager.unpinMessage:completion: |
| ChatManager.fetchPinnedMessages | EMChatManager.asyncGetPinnedMessagesFromServer | IEMChatManager.getPinnedMessagesFromServer:completion: |
| ChatManager.searchMsgsByOptions | EMChatManager.searchMsgFromDB | IEMChatManager.searchMessagesWithTypes:timestamp:count:fromUser:searchDirection:completion: |
| ChatManager.getMessageCount | EMChatManager.asyncGetMessageCount | IEMChatManager.getMessageCountWithCompletion: |
| ChatManager.getGroupMessageReadReceipts | EMChatManager.asyncGetGroupMessageReadReceipts | IEMChatManager.getGroupMessageReadReceipts:completion: |
| ChatManager.searchMessagesFromServer | EMChatManager.asyncSearchMessagesFromServer | IEMChatManager.searchMessagesFromServerWithOption:pageSize:pageNum:completion: |
| ChatManager.deleteConversations | EMChatManager.asyncDeleteConversations | IEMChatManager.deleteConversations:isDeleteMessages:completion: |
| ChatManager.loadConversationMessagesWithKeyword | EMChatManager.asyncLoadConversationMessagesWithKeyword | IEMChatManager.loadConversationMessagesWithKeyword:timestamp:fromUser:searchDirection:scope:completion: |
| ChatManager.loadMessagesWithIds | EMChatManager.asyncLoadMessages | IEMChatManager.getMessages:withConversationId:completion: |
| ChatManager.cleanConversationsMemoryCache | EMChatManager.cleanConversationsMemoryCache | IEMChatManager.cleanConversationsMemoryCache |
| ChatManager.filterConversationsFromDB | EMChatManager.asyncFilterConversationsFromDB | IEMChatManager.filterConversationsFromDB:filter: |
| ChatManager.setVoiceMessageListened | EMChatManager.setVoiceMessageListened | EMChatMessage.setIsListened: |
| ChatManager.voiceMessageToText | EMChatManager.voiceMessageToText | IEMChatManager.voiceMessageToText:completion: |
| ChatManager.voiceFileToText | EMChatManager.voiceFileToText | IEMChatManager.voiceFileToText:voiceParam:completion: |
| Conversation.getUnreadMsgCount | EMConversation.getUnreadMsgCount | EMConversation.unreadMessagesCount |
| Conversation.markAllMessagesAsRead | EMChatManager.asyncClearConversationUnreadMessageCount | IEMChatManager.clearConversationUnreadMessageCount:completion: |
| Conversation.markMessageAsRead | EMChatManager.asyncSendMessageReadReceipts | IEMChatManager.sendMessageReadReceipts:completion: |
| Conversation.syncConversationExt | EMConversation.setExtField | EMConversation.setExt: |
| Conversation.removeMessage | EMConversation.removeMessage | EMConversation.deleteMessageWithId:error: |
| Conversation.deleteMessageByIds | EMConversation.removeMessage | EMConversation.deleteMessageWithId:error: |
| Conversation.getLatestMessage | EMConversation.getLastMessage | EMConversation.latestMessage |
| Conversation.getLatestMessageFromOthers | EMConversation.getLatestMessageFromOthers | EMConversation.lastReceivedMessage |
| Conversation.clearAllMessages | EMConversation.clearAllMessages | EMConversation.deleteAllMessages: |
| Conversation.deleteMessagesWithTs | EMConversation.removeMessages | EMConversation.removeMessagesStart:to: |
| Conversation.insertMessage | EMConversation.insertMessage | EMConversation.insertMessage:error: |
| Conversation.appendMessage | EMConversation.appendMessage | EMConversation.appendMessage:error: |
| Conversation.updateConversationMessage | EMConversation.updateMessage | EMConversation.updateMessageChange:error: |
| Conversation.loadMsgWithId | EMConversation.getMessage | EMConversation.loadMessageWithId:error: |
| Conversation.loadMsgWithStartId | EMConversation.loadMoreMsgFromDB | EMConversation.loadMessagesStartFromId:count:searchDirection: / EMConversation.loadMessagesStartFromId:count:searchDirection:completion: |
| Conversation.loadMsgWithKeywords | EMConversation.asyncSearchMsgFromDB | EMConversation.loadMessagesWithKeyword:timestamp:count:fromUsers:searchDirection:scope:completion: |
| Conversation.loadMsgWithMsgType | EMConversation.searchMsgFromDB | EMConversation.loadMessagesWithType:timestamp:count:fromUser:searchDirection: / EMConversation.loadMessagesWithType:timestamp:count:fromUser:searchDirection:completion: |
| Conversation.loadMsgWithTime | EMConversation.searchMsgFromDB | EMConversation.loadMessagesFrom:to:count: / EMConversation.loadMessagesFrom:to:count:completion: |
| Conversation.messageCount | EMConversation.getAllMsgCount | EMConversation.messagesCount |
| Conversation.removeMsgFromServerWithTimeStamp | EMConversation.removeMessagesFromServer | EMConversation.removeMessagesFromServerWithTimeStamp:completion: |
| Conversation.pinnedMessages | EMConversation.pinnedMessages | EMConversation.pinnedMessages |
| Conversation.conversationRemindType | EMConversation.pushRemindType | EMConversation.disturbType |
| Conversation.conversationSearchMsgsByOptions | EMConversation.searchMsgFromDB | EMConversation.searchMessagesWithTypes:timestamp:count:fromUser:searchDirection:completion: |
| Conversation.getConversationName | EMConversation.getConversationName | EMConversation.conversationName |
| Conversation.getConversationAvatar | EMConversation.getConversationAvatar | EMConversation.conversationAvatar |
| Conversation.conversationGetLocalMessageCount | EMConversation.getAllMsgCount | EMConversation.getMessageCountStart:to: |
| Conversation.conversationDeleteServerMessageWithIds | EMConversation.removeMessagesFromServer | EMConversation.removeMessagesFromServerMessageIds:completion: |
| Conversation.conversationDeleteServerMessageWithTime | EMConversation.removeMessagesFromServer | EMConversation.removeMessagesFromServerWithTimeStamp:completion: |
| Message.getReactionList | EMMessage.getMessageReaction | EMChatMessage.reactionList |
| Message.groupAckCount | EMMessage.readReceiptCount | EMChatMessage.groupReadReceiptCount |
| Message.chatThread | EMMessage.getChatThread | EMChatMessage.chatThread |
| Message.getPinInfo | EMMessage.pinnedInfo | EMChatMessage.pinnedInfo |
| ThreadManager.fetchChatThreadDetail | EMChatThreadManager.getChatThreadFromServer | IEMThreadManager.getChatThreadFromSever:completion: |
| ThreadManager.fetchJoinedChatThreads | EMChatThreadManager.getJoinedChatThreadsFromServer | IEMThreadManager.getJoinedChatThreadsFromServerWithCursor:pageSize:completion: |
| ThreadManager.fetchChatThreadsWithParentId | EMChatThreadManager.getChatThreadsFromServer | IEMThreadManager.getChatThreadsFromServerWithParentId:cursor:pageSize:completion: |
| ThreadManager.fetchJoinedChatThreadsWithParentId | EMChatThreadManager.getJoinedChatThreadsFromServer | IEMThreadManager.getJoinedChatThreadsFromServerWithParentId:cursor:pageSize:completion: |
| ThreadManager.fetchChatThreadMember | EMChatThreadManager.getChatThreadMembers | IEMThreadManager.getChatThreadMemberListFromServerWithId:cursor:pageSize:completion: |
| ThreadManager.fetchLastMessageWithChatThreads | EMChatThreadManager.getChatThreadLatestMessage | IEMThreadManager.getLastMessageFromSeverWithChatThreads:completion: |
| ThreadManager.removeMemberFromChatThread | EMChatThreadManager.removeMemberFromChatThread | IEMThreadManager.removeMemberFromChatThread:threadId:completion: |
| ThreadManager.updateChatThreadSubject | EMChatThreadManager.updateChatThreadName | IEMThreadManager.updateChatThreadName:threadId:completion: |
| ThreadManager.createChatThread | EMChatThreadManager.createChatThread | IEMThreadManager.createChatThread:messageId:parentId:completion: |
| ThreadManager.joinChatThread | EMChatThreadManager.joinChatThread | IEMThreadManager.joinChatThread:completion: |
| ThreadManager.leaveChatThread | EMChatThreadManager.leaveChatThread | IEMThreadManager.leaveChatThread:completion: |
| ThreadManager.destroyChatThread | EMChatThreadManager.destroyChatThread | IEMThreadManager.destroyChatThread:completion: |
| Group.getJoinedGroups | EMGroupManager.getAllGroups | IEMGroupManager.getJoinedGroups |
| Group.createGroup | EMGroupManager.createGroup / EMGroupManager.asyncCreateGroup | IEMGroupManager.createGroupWithSubject:avatar:description:invitees:message:setting:completion: |
| Group.getGroupSpecificationFromServer | EMGroupManager.getGroupFromServer / EMGroupManager.asyncGetGroupFromServer | IEMGroupManager.getGroupSpecificationFromServerWithId:completion: / IEMGroupManager.getGroupSpecificationFromServerWithId:fetchMembers:completion: |
| Group.getGroupMemberListFromServer | EMGroupManager.fetchGroupMembers / EMGroupManager.asyncFetchGroupMembers | IEMGroupManager.getGroupMemberListFromServerWithId:cursor:pageSize:completion: |
| Group.getGroupBlockListFromServer | EMGroupManager.getBlockedUsers / EMGroupManager.asyncGetBlockedUsers | IEMGroupManager.getGroupBlacklistFromServerWithId:pageNumber:pageSize:completion: |
| Group.getGroupMuteListFromServer | EMGroupManager.fetchGroupMuteList / EMGroupManager.asyncFetchGroupMuteList | IEMGroupManager.fetchGroupMuteListFromServerWithId:pageNumber:pageSize:completion: |
| Group.getGroupWhiteListFromServer | EMGroupManager.fetchGroupWhiteList | IEMGroupManager.getGroupWhiteListFromServerWithId:completion: |
| Group.isMemberInWhiteListFromServer | EMGroupManager.checkIfInGroupWhiteList | IEMGroupManager.isMemberInWhiteListFromServerWithGroupId:completion: |
| Group.getGroupFileListFromServer | EMGroupManager.fetchGroupSharedFileList / EMGroupManager.asyncFetchGroupSharedFileList | IEMGroupManager.getGroupFileListWithId:pageNumber:pageSize:completion: |
| Group.getGroupAnnouncementFromServer | EMGroupManager.fetchGroupAnnouncement / EMGroupManager.asyncFetchGroupAnnouncement | IEMGroupManager.getGroupAnnouncementWithId:completion: |
| Group.addMembers | EMGroupManager.addUsersToGroup / EMGroupManager.asyncAddUsersToGroup | IEMGroupManager.addMembers:toGroup:message:completion: |
| Group.inviterUser | EMGroupManager.inviteUser / EMGroupManager.asyncInviteUser | IEMGroupManager.addMembers:toGroup:message:completion: |
| Group.removeMembers | EMGroupManager.removeUsersFromGroup / EMGroupManager.asyncRemoveUsersFromGroup | IEMGroupManager.removeMembers:fromGroup:completion: |
| Group.blockMembers | EMGroupManager.blockUsers / EMGroupManager.asyncBlockUsers | IEMGroupManager.blockMembers:fromGroup:completion: |
| Group.unblockMembers | EMGroupManager.unblockUsers / EMGroupManager.asyncUnblockUsers | IEMGroupManager.unblockMembers:fromGroup:completion: |
| Group.updateGroupSubject | EMGroupManager.changeGroupName / EMGroupManager.asyncChangeGroupName | IEMGroupManager.updateGroupSubject:forGroup:completion: |
| Group.updateDescription | EMGroupManager.changeGroupDescription / EMGroupManager.asyncChangeGroupDescription | IEMGroupManager.updateDescription:forGroup:completion: |
| Group.leaveGroup | EMGroupManager.leaveGroup / EMGroupManager.asyncLeaveGroup | IEMGroupManager.leaveGroup:completion: |
| Group.destroyGroup | EMGroupManager.destroyGroup / EMGroupManager.asyncDestroyGroup | IEMGroupManager.destroyGroup:finishCompletion: |
| Group.blockGroup | EMGroupManager.blockGroupMessage / EMGroupManager.asyncBlockGroupMessage | IEMGroupManager.blockGroup:completion: |
| Group.unblockGroup | EMGroupManager.unblockGroupMessage / EMGroupManager.asyncUnblockGroupMessage | IEMGroupManager.unblockGroup:completion: |
| Group.updateGroupOwner | EMGroupManager.changeOwner / EMGroupManager.asyncChangeOwner | IEMGroupManager.updateGroupOwner:newOwner:completion: |
| Group.addAdmin | EMGroupManager.addGroupAdmin / EMGroupManager.asyncAddGroupAdmin | IEMGroupManager.addAdmin:toGroup:completion: |
| Group.removeAdmin | EMGroupManager.removeGroupAdmin / EMGroupManager.asyncRemoveGroupAdmin | IEMGroupManager.removeAdmin:fromGroup:completion: |
| Group.muteMembers | EMGroupManager.muteGroupMembers / EMGroupManager.asyncMuteGroupMembers | IEMGroupManager.muteMembers:muteMilliseconds:fromGroup:completion: |
| Group.unMuteMembers | EMGroupManager.unMuteGroupMembers / EMGroupManager.asyncUnMuteGroupMembers | IEMGroupManager.unmuteMembers:fromGroup:completion: |
| Group.muteAllMembers | EMGroupManager.muteAllMembers | IEMGroupManager.muteAllMembersFromGroup:completion: |
| Group.unMuteAllMembers | EMGroupManager.unmuteAllMembers | IEMGroupManager.unmuteAllMembersFromGroup:completion: |
| Group.addWhiteList | EMGroupManager.addToGroupWhiteList | IEMGroupManager.addWhiteListMembers:fromGroup:completion: |
| Group.removeWhiteList | EMGroupManager.removeFromGroupWhiteList | IEMGroupManager.removeWhiteListMembers:fromGroup:completion: |
| Group.uploadGroupSharedFile | EMGroupManager.uploadGroupSharedFile / EMGroupManager.asyncUploadGroupSharedFile | IEMGroupManager.uploadGroupSharedFileWithId:filePath:progress:completion: |
| Group.downloadGroupSharedFile | EMGroupManager.downloadGroupSharedFile / EMGroupManager.asyncDownloadGroupSharedFile | IEMGroupManager.downloadGroupSharedFileWithId:filePath:sharedFileId:progress:completion: |
| Group.removeGroupSharedFile | EMGroupManager.deleteGroupSharedFile / EMGroupManager.asyncDeleteGroupSharedFile | IEMGroupManager.removeGroupSharedFileWithId:sharedFileId:completion: |
| Group.updateGroupAnnouncement | EMGroupManager.updateGroupAnnouncement / EMGroupManager.asyncUpdateGroupAnnouncement | IEMGroupManager.updateGroupAnnouncementWithId:announcement:completion: |
| Group.updateGroupExt | EMGroupManager.updateGroupExtension / EMGroupManager.asyncUpdateGroupExtension | IEMGroupManager.updateGroupExtWithId:ext:completion: |
| Group.joinPublicGroup | EMGroupManager.joinGroup / EMGroupManager.asyncJoinGroup | IEMGroupManager.joinPublicGroup:completion: |
| Group.requestToJoinPublicGroup | EMGroupManager.applyJoinToGroup / EMGroupManager.asyncApplyJoinToGroup | IEMGroupManager.requestToJoinPublicGroup:message:completion: |
| Group.acceptJoinApplication | EMGroupManager.acceptApplication / EMGroupManager.asyncAcceptApplication | IEMGroupManager.approveJoinGroupRequest:sender:completion: |
| Group.declineJoinApplication | EMGroupManager.declineApplication / EMGroupManager.asyncDeclineApplication | IEMGroupManager.declineJoinGroupRequest:sender:reason:completion: |
| Group.acceptInvitationFromGroup | EMGroupManager.acceptInvitation / EMGroupManager.asyncAcceptInvitation | IEMGroupManager.acceptInvitationFromGroup:inviter:completion: |
| Group.declineInvitationFromGroup | EMGroupManager.declineInvitation / EMGroupManager.asyncDeclineInvitation | IEMGroupManager.declineGroupInvitation:inviter:reason:completion: |
| Group.setMemberAttributesFromGroup | EMGroupManager.asyncSetGroupMemberAttributes | IEMGroupManager.setMemberAttribute:userId:attributes:completion: |
| Group.removeMemberAttributesFromGroup | EMGroupManager.asyncSetGroupMemberAttributes | IEMGroupManager.setMemberAttribute:userId:attributes:completion: |
| Group.fetchMemberAttributesFromGroup | EMGroupManager.asyncFetchGroupMemberAllAttributes | IEMGroupManager.fetchMemberAttribute:userId:completion: |
| Group.fetchMembersAttributesFromGroup | EMGroupManager.asyncFetchGroupMembersAttributes | IEMGroupManager.fetchMembersAttributes:userIds:keys:completion: |
| Group.fetchMemberAllAttributes | EMGroupManager.asyncFetchGroupMemberAllAttributes | —（iOS 原生 fetchMemberAttribute:userId: 语义对应但返回结构不同：Android {userId:{k:v}} vs iOS {k:v}；iOS 侧未适配） |
| Group.fetchJoinedGroupCount | EMGroupManager.asyncGetJoinedGroupsCountFromServer | IEMGroupManager.getJoinedGroupsCountFromServerWithCompletion: |
| Group.clearAllGroupsFromDB | EMGroupManager.cleanAllGroupsFromLocal | IEMGroupManager.cleanAllGroupsFromDB |
| Group.isMemberInGroupMuteList | EMGroupManager.asyncCheckIfInMuteList | IEMGroupManager.isMemberInMuteListFromServerWithGroupId:completion: |
| Group.fetchGroupMembersInfo | EMGroupManager.asyncFetchGroupMembersInfo | IEMGroupManager.fetchGroupMemberInfoListFromServerWithGroupId:cursor:limit:completion: |
| Group.updateGroupAvatar | EMGroupManager.changeGroupAvatar / EMGroupManager.asyncChangeGroupAvatar | IEMGroupManager.updateGroupAvatar:groupId:completion: |
| Group.updateGroupConfigs | EMGroupManager.updateGroupConfigs / EMGroupManager.asyncUpdateGroupConfigs | IEMGroupManager.updateGroupWithId:types:configs:completion: |（协议未收录：Android wrapper 预埋、无 Dart/Python/case 调用方；iOS 未实现）|
| Group.updateGroupExtension | EMGroupManager.updateGroupExtension / EMGroupManager.asyncUpdateGroupExtension | IEMGroupManager.updateGroupExtWithId:ext:completion: |（协议规范名=updateGroupExt；本行与 updateGroupExt 重复，Android 预埋残留）|
| Group.blockUser | EMGroupManager.blockUser / EMGroupManager.asyncBlockUser | IEMGroupManager.blockMembers:fromGroup:completion: |
| Group.unblockUser | EMGroupManager.unblockUser / EMGroupManager.asyncUnblockUser | IEMGroupManager.unblockMembers:fromGroup:completion: |
| Group.fetchGroupBlackList | EMGroupManager.fetchGroupBlackList / EMGroupManager.asyncFetchGroupBlackList | IEMGroupManager.getGroupBlacklistFromServerWithId:pageNumber:pageSize:completion: |
| Group.getGroupNamecard | EMGroupManager.getGroupNamecard | IEMGroupManager.getGroupNamecardWithGroupId:userId: |
| Group.removeUserFromGroup | EMGroupManager.removeUserFromGroup / EMGroupManager.asyncRemoveUserFromGroup | IEMGroupManager.removeMembers:fromGroup:completion: |
| Group.updateGroupNamecard | EMGroupManager.asyncUpdateGroupNamecard | IEMGroupManager.updateGroupNamecard:namecard:completion: |
| Chatroom.joinChatRoom | EMChatRoomManager.joinChatRoom | IEMChatroomManager.joinChatroom:error: / IEMChatroomManager.joinChatroom:completion: / IEMChatroomManager.joinChatroom:ext:leaveOtherRooms:completion: |
| Chatroom.leaveChatRoom | EMChatRoomManager.leaveChatRoom | IEMChatroomManager.leaveChatroom:error: / IEMChatroomManager.leaveChatroom:completion: |
| Chatroom.fetchPublicChatRoomsFromServer | EMChatRoomManager.fetchPublicChatRoomsFromServer / EMChatRoomManager.asyncFetchPublicChatRoomsFromServer | IEMChatroomManager.getChatroomsFromServerWithPage:pageSize:error: / IEMChatroomManager.getChatroomsFromServerWithPage:pageSize:completion: |
| Chatroom.fetchChatRoomInfoFromServer | EMChatRoomManager.fetchChatRoomFromServer / EMChatRoomManager.asyncFetchChatRoomFromServer | IEMChatroomManager.getChatroomSpecificationFromServerWithId:error: / IEMChatroomManager.getChatroomSpecificationFromServerWithId:completion: / IEMChatroomManager.getChatroomSpecificationFromServerWithId:fetchMembers:completion: |
| Chatroom.changeChatRoomSubject | EMChatRoomManager.changeChatRoomSubject / EMChatRoomManager.asyncChangeChatRoomSubject | IEMChatroomManager.updateSubject:forChatroom:error: / IEMChatroomManager.updateSubject:forChatroom:completion: |
| Chatroom.changeChatRoomDescription | EMChatRoomManager.changeChatroomDescription / EMChatRoomManager.asyncChangeChatroomDescription | IEMChatroomManager.updateDescription:forChatroom:error: / IEMChatroomManager.updateDescription:forChatroom:completion: |
| Chatroom.fetchChatRoomMembers | EMChatRoomManager.fetchChatRoomMembers / EMChatRoomManager.asyncFetchChatRoomMembers | IEMChatroomManager.getChatroomMemberListFromServerWithId:cursor:pageSize:error: / IEMChatroomManager.getChatroomMemberListFromServerWithId:cursor:pageSize:completion: |
| Chatroom.muteChatRoomMembers | EMChatRoomManager.muteChatRoomMembers / EMChatRoomManager.asyncMuteChatRoomMembers | IEMChatroomManager.muteMembers:muteMilliseconds:fromChatroom:error: / IEMChatroomManager.muteMembers:muteMilliseconds:fromChatroom:completion: |
| Chatroom.unMuteChatRoomMembers | EMChatRoomManager.unMuteChatRoomMembers / EMChatRoomManager.asyncUnMuteChatRoomMembers | IEMChatroomManager.unmuteMembers:fromChatroom:error: / IEMChatroomManager.unmuteMembers:fromChatroom:completion: |
| Chatroom.changeChatRoomOwner | EMChatRoomManager.changeOwner / EMChatRoomManager.asyncChangeOwner | IEMChatroomManager.updateChatroomOwner:newOwner:error: / IEMChatroomManager.updateChatroomOwner:newOwner:completion: |
| Chatroom.addChatRoomAdmin | EMChatRoomManager.addChatRoomAdmin / EMChatRoomManager.asyncAddChatRoomAdmin | IEMChatroomManager.addAdmin:toChatroom:error: / IEMChatroomManager.addAdmin:toChatroom:completion: |
| Chatroom.removeChatRoomAdmin | EMChatRoomManager.removeChatRoomAdmin / EMChatRoomManager.asyncRemoveChatRoomAdmin | IEMChatroomManager.removeAdmin:fromChatroom:error: / IEMChatroomManager.removeAdmin:fromChatroom:completion: |
| Chatroom.fetchChatRoomMuteList | EMChatRoomManager.fetchChatRoomMuteList / EMChatRoomManager.asyncFetchChatRoomMuteList | IEMChatroomManager.getChatroomMuteListFromServerWithId:pageNumber:pageSize:error: / IEMChatroomManager.getChatroomMuteListFromServerWithId:pageNumber:pageSize:completion: |
| Chatroom.removeChatRoomMembers | EMChatRoomManager.removeChatRoomMembers / EMChatRoomManager.asyncRemoveChatRoomMembers | IEMChatroomManager.removeMembers:fromChatroom:error: / IEMChatroomManager.removeMembers:fromChatroom:completion: |
| Chatroom.blockChatRoomMembers | EMChatRoomManager.blockChatroomMembers / EMChatRoomManager.asyncBlockChatroomMembers | IEMChatroomManager.blockMembers:fromChatroom:error: / IEMChatroomManager.blockMembers:fromChatroom:completion: |
| Chatroom.unBlockChatRoomMembers | EMChatRoomManager.unblockChatRoomMembers / EMChatRoomManager.asyncUnBlockChatRoomMembers | IEMChatroomManager.unblockMembers:fromChatroom:error: / IEMChatroomManager.unblockMembers:fromChatroom:completion: |
| Chatroom.fetchChatRoomBlockList | EMChatRoomManager.fetchChatRoomBlackList / EMChatRoomManager.asyncFetchChatRoomBlackList | IEMChatroomManager.getChatroomBlacklistFromServerWithId:pageNumber:pageSize:error: / IEMChatroomManager.getChatroomBlacklistFromServerWithId:pageNumber:pageSize:completion: |
| Chatroom.updateChatRoomAnnouncement | EMChatRoomManager.updateChatRoomAnnouncement / EMChatRoomManager.asyncUpdateChatRoomAnnouncement | IEMChatroomManager.updateChatroomAnnouncementWithId:announcement:error: / IEMChatroomManager.updateChatroomAnnouncementWithId:announcement:completion: |
| Chatroom.fetchChatRoomAnnouncement | EMChatRoomManager.fetchChatRoomAnnouncement / EMChatRoomManager.asyncFetchChatRoomAnnouncement | IEMChatroomManager.getChatroomAnnouncementWithId:error: / IEMChatroomManager.getChatroomAnnouncementWithId:completion: |
| Chatroom.addMembersToChatRoomWhiteList | EMChatRoomManager.addToChatRoomWhiteList | IEMChatroomManager.addWhiteListMembers:fromChatroom:error: / IEMChatroomManager.addWhiteListMembers:fromChatroom:completion: |
| Chatroom.removeMembersFromChatRoomWhiteList | EMChatRoomManager.removeFromChatRoomWhiteList | IEMChatroomManager.removeWhiteListMembers:fromChatroom:error: / IEMChatroomManager.removeWhiteListMembers:fromChatroom:completion: |
| Chatroom.fetchChatRoomWhiteListFromServer | EMChatRoomManager.fetchChatRoomWhiteList | IEMChatroomManager.getChatroomWhiteListFromServerWithId:error: / IEMChatroomManager.getChatroomWhiteListFromServerWithId:completion: |
| Chatroom.isMemberInChatRoomWhiteListFromServer | EMChatRoomManager.checkIfInChatRoomWhiteList | IEMChatroomManager.isMemberInWhiteListFromServerWithChatroomId:error: / IEMChatroomManager.isMemberInWhiteListFromServerWithChatroomId:completion: |
| Chatroom.muteAllChatRoomMembers | EMChatRoomManager.muteAllMembers | IEMChatroomManager.muteAllMembersFromChatroom:error: / IEMChatroomManager.muteAllMembersFromChatroom:completion: |
| Chatroom.unMuteAllChatRoomMembers | EMChatRoomManager.unmuteAllMembers | IEMChatroomManager.unmuteAllMembersFromChatroom:error: / IEMChatroomManager.unmuteAllMembersFromChatroom:completion: |
| Chatroom.fetchChatRoomAttributes | EMChatRoomManager.asyncFetchChatroomAttributesFromServer | IEMChatroomManager.fetchChatroomAttributes:keys:completion: |
| Chatroom.setChatRoomAttributes | EMChatRoomManager.asyncSetChatroomAttributes / EMChatRoomManager.asyncSetChatroomAttributesForced | IEMChatroomManager.setChatroomAttributes:attributes:autoDelete:completionBlock: / IEMChatroomManager.setChatroomAttributesForced:attributes:autoDelete:completionBlock: |
| Chatroom.removeChatRoomAttributes | EMChatRoomManager.asyncRemoveChatRoomAttributesFromServer / EMChatRoomManager.asyncRemoveChatRoomAttributesFromServerForced | IEMChatroomManager.removeChatroomAttributes:attributes:completionBlock: / IEMChatroomManager.removeChatroomAttributesForced:attributes:completionBlock: |
| Chatroom.isMemberInChatRoomMuteList | EMChatRoomManager.asyncCheckIfInMuteList | IEMChatroomManager.isMemberInMuteListFromServerWithChatroomId:completion: |
| Chatroom.fetchChatRoomAllAttributesFromServer | EMChatRoomManager.asyncFetchChatRoomAllAttributesFromServer | IEMChatroomManager.fetchChatroomAllAttributes:completion: |
| Chatroom.setChatroomAttribute | EMChatRoomManager.asyncSetChatroomAttribute | IEMChatroomManager.setChatroomAttribute:key:value:autoDelete:completionBlock: |
| Chatroom.setChatroomAttributeForced | EMChatRoomManager.asyncSetChatroomAttributeForced | IEMChatroomManager.setChatroomAttributeForced:key:value:autoDelete:completionBlock: |
| Chatroom.removeChatRoomAttributeFromServer | EMChatRoomManager.asyncRemoveChatRoomAttributeFromServer | IEMChatroomManager.removeChatroomAttribute:key:completionBlock: |
| Chatroom.removeChatRoomAttributeFromServerForced | EMChatRoomManager.asyncRemoveChatRoomAttributeFromServerForced | IEMChatroomManager.removeChatroomAttributeForced:key:completionBlock: |
| Contact.getAllContactIds | EMContactManager.getContactsFromLocal | IEMContactManager.getContacts |
| ChatManager.sendMessageWithType | EMMessage.createSendMessage / EMChatManager.sendMessage | EMChatMessage.initWithConversationID:body:ext: / IEMChatManager.sendMessage:progress:completion: |（测试支撑增量：wrapper/Dart 层组合分发 sendXxxMessage，非 5.0 原生 cmd）|
| ChatManager.getAllConversationsBySort | EMChatManager.getAllConversationsBySort | IEMChatManager.getAllConversations: |（能力并入 ChatManager.loadAllConversations：wrapper 内部调 getAllConversationsBySort，无独立协议）|

统一协议 API：仅 Android 5.0 有对应公开能力

| 模块.统一协议 API | Android 5.0 原生 API | iOS 5.0 原生 API |
|---|---|---|
| Client.notifyTokenExpired | EMClient.notifyTokenExpired | — |
| Client.sendHonorPushTokenToServer | EMClient.sendHonorPushTokenToServer | — |
| Client.isDatabaseOpened | EMClient.isDatabaseOpened | — |
| Push.updateHMSPushToken | EMClient.sendHMSPushTokenToServer | — |
| Push.reportPushAction | EMPushManager.reportPushAction | — |
| ChatManager.saveMessage | EMChatManager.saveMessage | — |
| ChatManager.getConversationsByType | EMChatManager.getConversationsByType | — |

统一协议 API：仅 iOS 5.0 有对应公开能力

| 模块.统一协议 API | Android 5.0 原生 API | iOS 5.0 原生 API |
|---|---|---|
| Client.getCurrentDeviceId | getDeviceInfo (返回不一样)| EMClient.getDeviceConfig: |
| Push.updateAPNsPushToken | — | EMClient.bindDeviceToken: / EMClient.registerForRemoteNotificationsWithDeviceToken:completion: |

统一协议 API：协议残留（两端 5.0 均无）

| 模块.统一协议 API | Android 5.0 原生 API | iOS 5.0 原生 API |
|---|---|---|
| Client.updateRequireAckSetting | — | — |
| Contact.getAllContactsFromServer | — | — |
| Contact.fetchContacts | — | — |
| Client.createAccount | — | — |
| Client.startCallback | — | — |
| ChatManager.getConversationsFromServer | — | — |
| ChatManager.fetchConversationsFromServerWithPage | — | — |
| ChatManager.getConversationsFromServerWithCursor | — | — |
| ChatManager.getPinnedConversationsFromServerWithCursor | — | — |
| ChatManager.fetchConversationsByOptions | — | — |
| ChatManager.reportMessage | — | — |
| Group.getJoinedGroupsFromServer | — | — |
| Group.getPublicGroupsFromServer | — | — |
| Chatroom.createChatRoom | — | — |
| Chatroom.destroyChatRoom | — | — |
| Contact.fetchAllContactIds | — | — |

统一协议 API：名称可映射，但语义或行为不完全等价

| 模块.统一协议 API | Android 5.0 原生 API | iOS 5.0 原生 API |
|---|---|---|
| Group.getGroupWithId | EMGroupManager.getGroup | EMGroup.groupWithId: |
| Group.getUsers | EMGroup.getUsers | EMGroup.users |
| Chatroom.getChatRoom | EMChatRoomManager.getChatRoom | EMChatroom.chatroomWithId: |
| Chatroom.getAllChatRooms | EMChatRoomManager.fetchPublicChatRoomsFromServer / asyncFetchPublicChatRoomsFromServer | IEMChatroomManager.getChatroomsFromServerWithPage:pageSize:error: / completion: |

语义提醒：Group.getGroupWithId 的 Android 方法只查缓存，iOS 方法在不存在时创建实例；Chatroom.getChatRoom 的 Android 方法查缓存，iOS 方法构造实例；Chatroom.getAllChatRooms 是否只是公开聊天室分页列表的旧别名，协议本身未定义清楚。

原生 API 未进统一协议：两端都有

| 模块.统一协议 API | Android 5.0 原生 API | iOS 5.0 原生 API |
|---|---|---|
| Client.— | EMClient.addConnectionListener | EMClient.addDelegate:delegateQueue: |
| Client.— | EMClient.removeConnectionListener | EMClient.removeDelegate: |
| MultiDevice.— | EMClient.addMultiDeviceListener | EMClient.addMultiDevicesDelegate:delegateQueue: |
| MultiDevice.— | EMClient.removeMultiDeviceListener | EMClient.removeMultiDevicesDelegate: |
| Client.— | EMClient.addLogListener | EMClient.addLogDelegate:delegateQueue: |
| Client.— | EMClient.removeLogListener | EMClient.removeLogDelegate: |
| Client.— | EMLog.d / EMLog.e / EMLog.i / EMLog.v / EMLog.w | EMClient.log: |
| Client.— | EMClient.setDebugMode | EMOptions.enableConsoleLog |
| Client.— | EMClient.getOptions | EMClient.options |
| Client.— | EMOptions.getVersion | EMClient.version |
| Contact.— | EMContactManager.setContactListener | IEMContactManager.addDelegate:delegateQueue: |
| Contact.— | EMContactManager.removeContactListener | IEMContactManager.removeDelegate: |
| Presence.— | EMPresenceManager.addListener | IEMPresenceManager.addDelegate:delegateQueue: |
| Presence.— | EMPresenceManager.removeListener | IEMPresenceManager.removeDelegate: |
| UserInfo.— | EMUserInfoManager.addUserInfoManagerListener | IEMUserInfoManager.addDelegate:delegateQueue: |
| UserInfo.— | EMUserInfoManager.removeUserInfoManagerListener | IEMUserInfoManager.removeDelegate: |
| Group.— | EMGroupManager.addGroupChangeListener | IEMGroupManager.addDelegate:delegateQueue: |
| Group.— | EMGroupManager.removeGroupChangeListener | IEMGroupManager.removeDelegate: |
| Chatroom.— | EMChatRoomManager.addChatRoomChangeListener | IEMChatroomManager.addDelegate:delegateQueue: |
| Chatroom.— | EMChatRoomManager.removeChatRoomChangeListener | IEMChatroomManager.removeDelegate: |
| ChatManager.— | EMChatManager.addMessageListener | IEMChatManager.addDelegate:delegateQueue: |
| ChatManager.— | EMChatManager.removeMessageListener | IEMChatManager.removeDelegate: |
| ChatManager.— | EMChatManager.addConversationListener | IEMChatManager.addConversationDelegate:delegateQueue: |
| ChatManager.— | EMChatManager.removeConversationListener | IEMChatManager.removeConversationDelegate: |
| Conversation.— | EMConversation.getMessageAttachmentPath | IEMChatManager.getMessageAttachmentPath: |
| Conversation.— | EMConversation.searchCustomMsgFromDB | EMConversation.loadCustomMsgWithKeyword:timestamp:count:fromUser:searchDirection: / EMConversation.loadCustomMsgWithKeyword:timestamp:count:fromUser:searchDirection:completion: |
| ThreadManager.— | EMChatThreadManager.addChatThreadChangeListener | IEMThreadManager.addDelegate:delegateQueue: |
| ThreadManager.— | EMChatThreadManager.removeChatThreadChangeListener | IEMThreadManager.removeDelegate: |

原生 API 未进统一协议：Android-only

| 模块.统一协议 API | Android 5.0 原生 API | iOS 5.0 原生 API |
|---|---|---|
| Client.— | EMClient.isSdkInited | — |
| Client.— | EMClient.isAutoLogin | — |
| Presence.— | EMPresenceManager.clearListeners | — |
| Client.— | EMOptions.setFixedHBInterval / EMOptions.getFixedInterval | — |
| Conversation.— | EMConversation.getAllMessages | — |
| Conversation.— | EMConversation.clear | — |
| Conversation.— | EMConversation.isGroup | — |
| Conversation.— | EMConversation.msgType2ConversationType | — |

原生 API 未进统一协议：iOS-only

| 模块.统一协议 API | Android 5.0 原生 API | iOS 5.0 原生 API |
|---|---|---|
| Client.— | — | EMOptions.logLevel |

OS 平台专属 API

| 模块.统一协议 API | Android 5.0 原生 API | iOS 5.0 原生 API |
|---|---|---|
| Client.— | EMClient.getContext | — |
| Push.— | EMClient.isFCMAvailable | — |
| Client.— | EMOptions.setNativeLibBasePath / EMOptions.getNativeLibBasePath | — |
| Push.— | EMPushHelper.init / register / unregister / onReceiveToken / reBindToken / getPushType / getPushToken / getFCMPushToken / setFCMPushToken / getPushTokenWithType / setPushTokenWithType | — |
| Push.— | EMPushConfig.Builder.enableMiPush / enableHWPush / enableFCM / enableMeiZuPush / enableOppoPush / enableVivoPush / enableHonorPush / build | — |
| Push.— | — | EMClient.bindPushKitToken: / registerPushKitToken:completion: / unBindPushKitToken / unRegisterPushKitTokenWithCompletion: |
| Client.— | — | EMClient.applicationDidEnterBackground: |
| Client.— | — | EMClient.applicationWillEnterForeground: |
| Client.— | — | EMClient.application:didReceiveRemoteNotification: |
| Push.— | EMOptions.getPushConfig / EMOptions.setPushConfig | EMOptions.apnsCertName / EMOptions.pushKitCertName |
| Client.— | — | EMOptions.workPathCopiable |
| Push.— | — | EMLocalNotificationManager.launchWithDelegate: / userNotificationCenter:willPresentNotification:withCompletionHandler: / userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler: |

Event

统一协议 Event：两端语义对应

| 模块.统一协议 Event | Android 5.0 原生 Event | iOS 5.0 原生 Event |
|---|---|---|
| Client.onConnected | EMConnectionListener.onConnected | EMClientDelegate.connectionStateDidChange: |
| Client.onDisconnected | EMConnectionListener.onDisconnected | EMClientDelegate.connectionStateDidChange: |
| Client.onUserDidLoginFromOtherDevice | EMConnectionListener.onLogout | EMClientDelegate.userAccountDidLoginFromOtherDeviceWithInfo: |
| Client.onUserDidRemoveFromServer | EMConnectionListener.onLogout | EMClientDelegate.userAccountDidRemoveFromServer |
| Client.onUserDidForbidByServer | EMConnectionListener.onLogout | EMClientDelegate.userDidForbidByServer |
| Client.onUserDidChangePassword | EMConnectionListener.onLogout | EMClientDelegate.userAccountDidForcedToLogout: |
| Client.onUserDidLoginTooManyDevice | EMConnectionListener.onLogout | EMClientDelegate.userAccountDidForcedToLogout: |
| Client.onUserKickedByOtherDevice | EMConnectionListener.onLogout | EMClientDelegate.userAccountDidForcedToLogout: |
| Client.onTokenWillExpire | EMConnectionListener.onTokenWillExpire | EMClientDelegate.tokenWillExpire: |
| Client.onTokenDidExpire | EMConnectionListener.onTokenExpired | EMClientDelegate.tokenDidExpire: |
| Client.onOfflineMessageSyncStart | EMConnectionListener.onOfflineMessageSyncStart | EMClientDelegate.onOfflineMessageSyncStart |
| Client.onOfflineMessageSyncFinish | EMConnectionListener.onOfflineMessageSyncFinish | EMClientDelegate.onOfflineMessageSyncFinish |
| Client.onDataSyncStart | EMConnectionListener.onDataSyncStart | EMClientDelegate.syncDataStartWithType: |
| Client.onDataSyncFinish | EMConnectionListener.onDataSyncFinish | EMClientDelegate.syncDataFinished:type: |
| Client.onDatabaseOpened | EMConnectionListener.onDatabaseOpened | EMClientDelegate.onDatabaseOpened:username: |
| Client.onConversationUnreadMessageCountCleared | EMMultiDeviceListener.onConversationEvent | EMMultiDevicesDelegate.multiDevicesConversationEvent:conversationId:conversationType: |
| Client.onAllConversationsUnreadMessageCountCleared | EMMultiDeviceListener.onConversationEvent | EMMultiDevicesDelegate.multiDevicesConversationEvent:conversationId:conversationType: |
| MultiDevice.onMultiDeviceContactEvent | EMMultiDeviceListener.onContactEvent | EMMultiDevicesDelegate.multiDevicesContactEventDidReceive:username:ext: |
| MultiDevice.onMultiDeviceGroupEvent | EMMultiDeviceListener.onGroupEvent | EMMultiDevicesDelegate.multiDevicesGroupEventDidReceive:groupId:ext: |
| MultiDevice.onMultiDeviceThreadEvent | EMMultiDeviceListener.onChatThreadEvent | EMMultiDevicesDelegate.multiDevicesChatThreadEventDidReceive:threadId:ext: |
| MultiDevice.onMultiDeviceRemoveMessagesEvent | EMMultiDeviceListener.onMessageRemoved | EMMultiDevicesDelegate.multiDevicesMessageBeRemoved:deviceId: |
| MultiDevice.onMultiDevicesConversationEvent | EMMultiDeviceListener.onConversationEvent | EMMultiDevicesDelegate.multiDevicesConversationEvent:conversationId:conversationType: |
| Contact.onContactChanged/onContactAdded | EMContactListener.onContactAdded | EMContactManagerDelegate.friendshipDidAddByUser: |
| Contact.onContactChanged/onContactDeleted | EMContactListener.onContactDeleted | EMContactManagerDelegate.friendshipDidRemoveByUser: |
| Contact.onContactChanged/onContactInvited | EMContactListener.onContactInvited | EMContactManagerDelegate.friendRequestDidReceiveFromUser:message: |
| Contact.onContactChanged/onFriendRequestAccepted | EMContactListener.onFriendRequestAccepted | EMContactManagerDelegate.friendRequestDidApproveByUser: |
| Contact.onContactChanged/onFriendRequestDeclined | EMContactListener.onFriendRequestDeclined | EMContactManagerDelegate.friendRequestDidDeclineByUser: |
| Presence.onPresenceStatusChanged | EMPresenceListener.onPresenceUpdated | EMPresenceManagerDelegate.presenceStatusDidChanged: |
| ChatManager.onMessagesReceived | EMMessageListener.onMessageReceived | EMChatManagerDelegate.messagesDidReceive: |
| ChatManager.onStreamMessagesReceived | EMMessageListener.onStreamMessageReceived | EMChatManagerDelegate.onStreamMessagesReceived: |
| ChatManager.onCmdMessagesReceived | EMMessageListener.onCmdMessageReceived | EMChatManagerDelegate.cmdMessagesDidReceive: |
| ChatManager.onMessagesRead | EMMessageListener.onMessageReadReceipts | EMChatManagerDelegate.onMessageReadReceipts: |
| Message.onMessageReadAck | EMMessageListener.onMessageReadReceipts | EMChatManagerDelegate.onMessageReadReceipts: |
| ChatManager.onMessagesDelivered | EMMessageListener.onMessageDelivered | EMChatManagerDelegate.messagesDidDeliver: |
| Message.onMessageDeliveryAck | EMMessageListener.onMessageDelivered | EMChatManagerDelegate.messagesDidDeliver: |
| ChatManager.messageReactionDidChange | EMMessageListener.onReactionChanged | EMChatManagerDelegate.messageReactionDidChange: |
| ChatManager.onMessageContentChanged | EMMessageListener.onMessageContentChanged | EMChatManagerDelegate.onMessageContentChanged:operatorId:operationTime: |
| ChatManager.onMessagePinChanged | EMMessageListener.onMessagePinChanged | EMChatManagerDelegate.onMessagePinChanged:conversationId:operation:pinInfo: |
| ChatManager.onMessagesRecalledInfo | EMMessageListener.onMessageRecalledWithExt | EMChatManagerDelegate.messagesInfoDidRecall: |
| ChatManager.onConversationUpdate | EMConversationListener.onConversationUpdate | EMConversationDelegate.conversationListDidUpdate: |
| Message.onMessageProgressUpdate | EMCallBack.onProgress | IEMChatManager.sendMessage:progress:completion: |
| Message.onMessageSuccess | EMCallBack.onSuccess | IEMChatManager.sendMessage:progress:completion: |
| Message.onMessageError | EMCallBack.onError | IEMChatManager.sendMessage:progress:completion: |
| Thread.onChatThreadCreate | EMChatThreadChangeListener.onChatThreadCreated | EMThreadManagerDelegate.onChatThreadCreate: |
| Thread.onChatThreadUpdate | EMChatThreadChangeListener.onChatThreadUpdated | EMThreadManagerDelegate.onChatThreadUpdate: |
| Thread.onChatThreadDestroy | EMChatThreadChangeListener.onChatThreadDestroyed | EMThreadManagerDelegate.onChatThreadDestroy: |
| Thread.onUserKickOutOfChatThread | EMChatThreadChangeListener.onChatThreadUserRemoved | EMThreadManagerDelegate.onUserKickOutOfChatThread: |
| Group.onGroupChanged/onGroupWhiteListAdded | EMGroupChangeListener.onWhiteListAdded | EMGroupManagerDelegate.groupWhiteListDidUpdate:addedWhiteListMembers: |
| Group.onGroupChanged/onGroupWhiteListRemoved | EMGroupChangeListener.onWhiteListRemoved | EMGroupManagerDelegate.groupWhiteListDidUpdate:removedWhiteListMembers: |
| Group.onGroupChanged/onGroupAllMemberMuteStateChanged | EMGroupChangeListener.onAllMemberMuteStateChanged | EMGroupManagerDelegate.groupAllMemberMuteChanged:isAllMemberMuted: |
| Group.onGroupChanged/onGroupInvitationReceived | EMGroupChangeListener.onInvitationReceived | EMGroupManagerDelegate.groupInvitationDidReceive:groupName:inviter:message: |
| Group.onGroupChanged/onGroupRequestToJoinReceived | EMGroupChangeListener.onRequestToJoinReceived | EMGroupManagerDelegate.joinGroupRequestDidReceive:user:reason: |
| Group.onGroupChanged/onGroupRequestToJoinAccepted | EMGroupChangeListener.onRequestToJoinAccepted | EMGroupManagerDelegate.joinGroupRequestDidApprove: |
| Group.onGroupChanged/onGroupRequestToJoinDeclined | EMGroupChangeListener.onRequestToJoinDeclined | EMGroupManagerDelegate.joinGroupRequestDidDecline:reason:decliner:applicant: |
| Group.onGroupChanged/onGroupInvitationAccepted | EMGroupChangeListener.onInvitationAccepted | EMGroupManagerDelegate.groupInvitationDidAccept:invitee: |
| Group.onGroupChanged/onGroupInvitationDeclined | EMGroupChangeListener.onInvitationDeclined | EMGroupManagerDelegate.groupInvitationDidDecline:invitee:reason: |
| Group.onGroupChanged/onGroupUserRemoved | EMGroupChangeListener.onUserRemoved | EMGroupManagerDelegate.didLeaveGroup:reason: |
| Group.onGroupChanged/onGroupDestroyed | EMGroupChangeListener.onGroupDestroyed | EMGroupManagerDelegate.didLeaveGroup:reason: |
| Group.onGroupChanged/onGroupAutoAcceptInvitation | EMGroupChangeListener.onAutoAcceptInvitationFromGroup | EMGroupManagerDelegate.didJoinGroup:inviter:message: |
| Group.onGroupChanged/onGroupMuteListAdded | EMGroupChangeListener.onMuteListAdded | EMGroupManagerDelegate.groupMuteListDidUpdate:addedMutedMembers:muteExpire: |
| Group.onGroupChanged/onGroupMuteListRemoved | EMGroupChangeListener.onMuteListRemoved | EMGroupManagerDelegate.groupMuteListDidUpdate:removedMutedMembers: |
| Group.onGroupChanged/onGroupAdminAdded | EMGroupChangeListener.onAdminAdded | EMGroupManagerDelegate.groupAdminListDidUpdate:addedAdmin: |
| Group.onGroupChanged/onGroupAdminRemoved | EMGroupChangeListener.onAdminRemoved | EMGroupManagerDelegate.groupAdminListDidUpdate:removedAdmin: |
| Group.onGroupChanged/onGroupOwnerChanged | EMGroupChangeListener.onOwnerChanged | EMGroupManagerDelegate.groupOwnerDidUpdate:newOwner:oldOwner: |
| Group.onGroupChanged/onGroupMembersJoined | EMGroupChangeListener.onMembersJoined | EMGroupManagerDelegate.userDidJoinGroup:users: |
| Group.onGroupChanged/onGroupMembersExited | EMGroupChangeListener.onMembersExited | EMGroupManagerDelegate.userDidLeaveGroup:users: |
| Group.onGroupChanged/onGroupMemberJoined | EMGroupChangeListener.onMembersJoined | EMGroupManagerDelegate.userDidJoinGroup:users: |
| Group.onGroupChanged/onGroupMemberExited | EMGroupChangeListener.onMembersExited | EMGroupManagerDelegate.userDidLeaveGroup:users: |
| Group.onGroupChanged/onGroupAnnouncementChanged | EMGroupChangeListener.onAnnouncementChanged | EMGroupManagerDelegate.groupAnnouncementDidUpdate:announcement: |
| Group.onGroupChanged/onGroupSharedFileAdded | EMGroupChangeListener.onSharedFileAdded | EMGroupManagerDelegate.groupFileListDidUpdate:addedSharedFile: |
| Group.onGroupChanged/onGroupSharedFileDeleted | EMGroupChangeListener.onSharedFileDeleted | EMGroupManagerDelegate.groupFileListDidUpdate:removedSharedFile: |
| Group.onGroupChanged/onGroupAttributesChangedOfMember | EMGroupChangeListener.onGroupMemberAttributeChanged | EMGroupManagerDelegate.onAttributesChangedOfGroupMember:userId:attributes:operatorId: |
| Group.onGroupChanged/onGroupSpecificationDidUpdate | EMGroupChangeListener.onSpecificationChanged | EMGroupManagerDelegate.groupSpecificationDidUpdate: |
| Group.onGroupChanged/onGroupStateChanged | EMGroupChangeListener.onStateChanged | EMGroupManagerDelegate.groupStateChanged:isDisabled: |
| Chatroom.onChatRoomChanged/onRoomWhiteListAdded | EMChatRoomChangeListener.onWhiteListAdded | EMChatroomManagerDelegate.chatroomWhiteListDidUpdate:addedWhiteListMembers: |
| Chatroom.onChatRoomChanged/onRoomWhiteListRemoved | EMChatRoomChangeListener.onWhiteListRemoved | EMChatroomManagerDelegate.chatroomWhiteListDidUpdate:removedWhiteListMembers: |
| Chatroom.onChatRoomChanged/onRoomAllMemberMuteStateChanged | EMChatRoomChangeListener.onAllMemberMuteStateChanged | EMChatroomManagerDelegate.chatroomAllMemberMuteChanged:isAllMemberMuted: |
| Chatroom.onChatRoomChanged/onRoomDestroyed | EMChatRoomChangeListener.onChatRoomDestroyed | EMChatroomManagerDelegate.didDismissFromChatroom:reason: |
| Chatroom.onChatRoomChanged/onRoomMemberJoined | EMChatRoomChangeListener.onMemberJoined | EMChatroomManagerDelegate.userDidJoinChatroom:user:ext: |
| Chatroom.onChatRoomChanged/onRoomMemberExited | EMChatRoomChangeListener.onMemberExited | EMChatroomManagerDelegate.userDidLeaveChatroom:user: |
| Chatroom.onChatRoomChanged/onRoomRemoved | EMChatRoomChangeListener.onRemovedFromChatRoom | EMChatroomManagerDelegate.didDismissFromChatroom:reason: |
| Chatroom.onChatRoomChanged/onRoomMuteListAdded | EMChatRoomChangeListener.onMuteListAdded | EMChatroomManagerDelegate.chatroomMuteListDidUpdate:addedMutedMembers: |
| Chatroom.onChatRoomChanged/onRoomMuteListRemoved | EMChatRoomChangeListener.onMuteListRemoved | EMChatroomManagerDelegate.chatroomMuteListDidUpdate:removedMutedMembers: |
| Chatroom.onChatRoomChanged/onRoomAdminAdded | EMChatRoomChangeListener.onAdminAdded | EMChatroomManagerDelegate.chatroomAdminListDidUpdate:addedAdmin: |
| Chatroom.onChatRoomChanged/onRoomAdminRemoved | EMChatRoomChangeListener.onAdminRemoved | EMChatroomManagerDelegate.chatroomAdminListDidUpdate:removedAdmin: |
| Chatroom.onChatRoomChanged/onRoomOwnerChanged | EMChatRoomChangeListener.onOwnerChanged | EMChatroomManagerDelegate.chatroomOwnerDidUpdate:newOwner:oldOwner: |
| Chatroom.onChatRoomChanged/onRoomAnnouncementChanged | EMChatRoomChangeListener.onAnnouncementChanged | EMChatroomManagerDelegate.chatroomAnnouncementDidUpdate:announcement: |
| Chatroom.onChatRoomChanged/onRoomSpecificationChanged | EMChatRoomChangeListener.onSpecificationChanged | EMChatroomManagerDelegate.chatroomSpecificationDidUpdate: |
| Chatroom.onChatRoomChanged/onRoomAttributesDidUpdated | EMChatRoomChangeListener.onAttributesUpdate | EMChatroomManagerDelegate.chatroomAttributesDidUpdated:attributeMap:from: |
| Chatroom.onChatRoomChanged/onRoomAttributesDidRemoved | EMChatRoomChangeListener.onAttributesRemoved | EMChatroomManagerDelegate.chatroomAttributesDidRemoved:attributes:from: |
| ChatManager.onMessageChanged | EMMessageListener.onMessageChanged | EMChatManagerDelegate.messageStatusDidChange:error: / messageAttachmentStatusDidChange:error: |（Android=本地消息对象变更；iOS=发送/附件状态变更，近似映射） |
| Contact.onContactInfoUpdate | EMContactListener.onContactInfoUpdate | EMContactManagerDelegate.onFriendInfoChanged: |
| Group.onUserGroupNamecardUpdated | EMGroupChangeListener.onUserGroupNamecardUpdated | EMGroupManagerDelegate.onUserGroupNamecardChanged:userId:namecard: |
| UserInfo.onSelfUserInfoUpdate | EMUserInfoManagerListener.onSelfUserInfoUpdate | EMUserInfoManagerDelegate.onSelfUserInfoUpdate: |
| UserInfo.onUserInfoUpdate | EMUserInfoManagerListener.onUserInfoUpdate | EMUserInfoManagerDelegate.onUserInfoUpdate: |
| ChatManager.onMessageProgress | EMCallBack.onProgress | IEMChatManager.sendMessage:progress:completion: |

统一协议 Event：仅 Android 5.0 有对应公开事件

| 模块.统一协议 Event | Android 5.0 原生 Event | iOS 5.0 原生 Event |
|---|---|---|
| Client.onUserAuthenticationFailed | EMConnectionListener.onDisconnected | — |
| Client.onAppActiveNumberReachLimit | EMConnectionListener.onLogout / onDisconnected | — |

统一协议 Event：仅 iOS 5.0 有对应公开事件

无。

统一协议 Event：协议残留（两端 5.0 均无）

| 模块.统一协议 Event | Android 5.0 原生 Event | iOS 5.0 原生 Event |
|---|---|---|
| Client.onSendDataToFlutter | — | — |

统一协议 Event：语义待确认

无。

原生 Event 未进统一协议：两端都有

| 模块.统一协议 Event | Android 5.0 原生 Event | iOS 5.0 原生 Event |
|---|---|---|
| Contact.— | EMLogListener.onLog | EMLogDelegate.logDidOutput: |

原生 Event 未进统一协议：Android-only

无。

原生 Event 未进统一协议：iOS-only

| 模块.统一协议 Event | Android 5.0 原生 Event | iOS 5.0 原生 Event |
|---|---|---|
| MultiDevice.onMultiDeviceGroupEvent（子类型） | — | EMMultiDevicesEventGroupUpdate / EMMultiDevicesDelegate.multiDevicesGroupEventDidReceive:groupId:ext: |
| Group.— | — | EMGroupManagerDelegate.groupListDidUpdate: |

OS 平台专属 Event

| 模块.统一协议 Event | Android 5.0 原生 Event | iOS 5.0 原生 Event |
|---|---|---|
| Push.— | PushListener.onBindTokenSuccess | — |
| Push.— | PushListener.onError | — |
| Push.— | — | EMLocalNotificationDelegate.emuserNotificationCenter:willPresentNotification:withCompletionHandler: |
| Push.— | — | EMLocalNotificationDelegate.emuserNotificationCenter:didReceiveNotificationResponse:withCompletionHandler: |
| Push.— | — | EMLocalNotificationDelegate.emuserNotificationCenter:openSettingsForNotification: |
| Push.— | — | EMLocalNotificationDelegate.emGetNotificationMessage:state: |
| Push.— | — | EMLocalNotificationDelegate.emHandleNotificationContent: |
| Push.— | — | EMLocalNotificationDelegate.emDidRecivePushSilentMessage: |

已确认的原生错误码差异

| API / 输入 | Android 5.0 | iOS 5.0 |
|---|---|---|
| ChatManager.voiceFileToText（空路径，已登录） | 400 / The voice file path cannot be empty. | 110 / Invalid parameter |

说明：iOS 未登录时会先返回 201；上表比较的是两端均已登录后的同一空路径输入。
