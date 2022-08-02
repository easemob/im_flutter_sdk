class ChatMethodKeys {
  /// EMClient methods
  static const String init = "init";
  static const String createAccount = "createAccount";
  static const String login = "login";
  static const String loginWithAgoraToken = "loginWithAgoraToken";
  static const String renewToken = "renewToken";
  static const String logout = "logout";
  static const String changeAppKey = "changeAppKey";

  static const String uploadLog = "uploadLog";
  static const String compressLogs = "compressLogs";
  static const String kickDevice = "kickDevice";
  static const String kickAllDevices = "kickAllDevices";
  static const String getLoggedInDevicesFromServer =
      "getLoggedInDevicesFromServer";

  static const String getToken = "getToken";
  static const String getCurrentUser = "getCurrentUser";
  static const String isLoggedInBefore = "isLoggedInBefore";
  static const String isConnected = "isConnected";

  /// EMClient listener
  static const String onMultiDeviceGroupEvent = "onMultiDeviceGroupEvent";
  static const String onMultiDeviceContactEvent = "onMultiDeviceContactEvent";
  static const String onMultiDeviceThreadEvent = "onMultiDeviceThreadEvent";
  static const String onConnected = "onConnected";
  static const String onDisconnected = "onDisconnected";
  static const String onUserDidLoginFromOtherDevice =
      "onUserDidLoginFromOtherDevice";
  static const String onUserDidRemoveFromServer = "onUserDidRemoveFromServer";
  static const String onUserDidForbidByServer = "onUserDidForbidByServer";
  static const String onUserDidChangePassword = "onUserDidChangePassword";
  static const String onUserDidLoginTooManyDevice =
      "onUserDidLoginTooManyDevice";
  static const String onUserKickedByOtherDevice = "onUserKickedByOtherDevice";
  static const String onUserAuthenticationFailed = "onUserAuthenticationFailed";

  static const String onSendDataToFlutter = "onSendDataToFlutter";
  static const String onTokenWillExpire = "onTokenWillExpire";
  static const String onTokenDidExpire = "onTokenDidExpire";

  /// EMContactManager methods
  static const String addContact = "addContact";
  static const String deleteContact = "deleteContact";
  static const String getAllContactsFromServer = "getAllContactsFromServer";
  static const String getAllContactsFromDB = "getAllContactsFromDB";
  static const String addUserToBlockList = "addUserToBlockList";
  static const String removeUserFromBlockList = "removeUserFromBlockList";
  static const String getBlockListFromServer = "getBlockListFromServer";
  static const String getBlockListFromDB = "getBlockListFromDB";
  static const String acceptInvitation = "acceptInvitation";
  static const String declineInvitation = "declineInvitation";
  static const String getSelfIdsOnOtherPlatform = "getSelfIdsOnOtherPlatform";

  /// EMContactManager listener
  static const String onContactChanged = "onContactChanged";

  /// EMChatManager methods
  static const String sendMessage = "sendMessage";
  static const String resendMessage = "resendMessage";
  static const String ackMessageRead = "ackMessageRead";
  static const String ackGroupMessageRead = "ackGroupMessageRead";
  static const String ackConversationRead = "ackConversationRead";
  static const String recallMessage = "recallMessage";
  static const String getConversation = "getConversation";
  static const String getThreadConversation = "getThreadConversation";
  static const String markAllChatMsgAsRead = "markAllChatMsgAsRead";
  static const String getUnreadMessageCount = "getUnreadMessageCount";
  static const String updateChatMessage = "updateChatMessage";
  static const String downloadAttachment = "downloadAttachment";
  static const String downloadThumbnail = "downloadThumbnail";
  static const String importMessages = "importMessages";
  static const String loadAllConversations = "loadAllConversations";
  static const String getConversationsFromServer = "getConversationsFromServer";
  static const String deleteConversation = "deleteConversation";

  static const String fetchHistoryMessages = "fetchHistoryMessages";
  static const String searchChatMsgFromDB = "searchChatMsgFromDB";
  static const String getMessage = "getMessage";
  static const String asyncFetchGroupAcks = "asyncFetchGroupAcks";
  static const String deleteRemoteConversation = "deleteRemoteConversation";

  static const String translateMessage = "translateMessage";
  static const String fetchSupportLanguages = "fetchSupportLanguages";

  static const String addReaction = "addReaction";
  static const String removeReaction = "removeReaction";
  static const String fetchReactionList = "fetchReactionList";
  static const String fetchReactionDetail = "fetchReactionDetail";
  static const String reportMessage = "reportMessage";

  /// EMChatManager listener
  static const String onMessagesReceived = "onMessagesReceived";
  static const String onCmdMessagesReceived = "onCmdMessagesReceived";
  static const String onMessagesRead = "onMessagesRead";
  static const String onReadAckForGroupMessageUpdated =
      "onReadAckForGroupMessageUpdated";
  static const String onGroupMessageRead = "onGroupMessageRead";
  static const String onMessagesDelivered = "onMessagesDelivered";
  static const String onMessagesRecalled = "onMessagesRecalled";
  static const String onMessageChanged = "onMessageChanged";

  static const String onConversationUpdate = "onConversationUpdate";
  static const String onConversationHasRead = "onConversationHasRead";

  static const String onMessageReactionDidChange = "messageReactionDidChange";

  /// EMMessage listener
  static const String onMessageProgressUpdate = "onMessageProgressUpdate";
  static const String onMessageError = "onMessageError";
  static const String onMessageSuccess = "onMessageSuccess";
  static const String onMessageReadAck = "onMessageReadAck";
  static const String onMessageDeliveryAck = "onMessageDeliveryAck";

  /// EMPresenceManagerDelegate
  static const String onPresenceStatusChanged = "onPresenceStatusChanged";

  /// EMConversation method
  static const String getUnreadMsgCount = "getUnreadMsgCount";
  static const String markAllMessagesAsRead = "markAllMessagesAsRead";
  static const String markMessageAsRead = "markMessageAsRead";
  static const String syncConversationExt = "syncConversationExt";
  static const String removeMessage = "removeMessage";
  static const String getLatestMessage = "getLatestMessage";
  static const String getLatestMessageFromOthers = "getLatestMessageFromOthers";
  static const String clearAllMessages = "clearAllMessages";
  static const String insertMessage = "insertMessage";
  static const String appendMessage = "appendMessage";
  static const String updateConversationMessage = "updateConversationMessage";
  static const String loadMsgWithId = "loadMsgWithId";
  static const String loadMsgWithStartId = "loadMsgWithStartId";
  static const String loadMsgWithKeywords = "loadMsgWithKeywords";
  static const String loadMsgWithMsgType = "loadMsgWithMsgType";
  static const String loadMsgWithTime = "loadMsgWithTime";
  static const String messageCount = "messageCount";

  /// EMMessage method
  static const String getReactionList = "getReactionList";
  static const String groupAckCount = "groupAckCount";
  static const String getChatThread = "chatThread";

  /// EMChatRoomManager methods
  static const String joinChatRoom = "joinChatRoom";
  static const String leaveChatRoom = "leaveChatRoom";
  static const String fetchPublicChatRoomsFromServer =
      "fetchPublicChatRoomsFromServer";
  static const String fetchChatRoomInfoFromServer =
      "fetchChatRoomInfoFromServer";
  static const String getChatRoom = "getChatRoom";
  static const String getAllChatRooms = "getAllChatRooms";
  static const String createChatRoom = "createChatRoom";
  static const String destroyChatRoom = "destroyChatRoom";
  static const String changeChatRoomSubject = "changeChatRoomSubject";
  static const String changeChatRoomDescription = "changeChatRoomDescription";
  static const String fetchChatRoomMembers = "fetchChatRoomMembers";
  static const String muteChatRoomMembers = "muteChatRoomMembers";
  static const String unMuteChatRoomMembers = "unMuteChatRoomMembers";
  static const String changeChatRoomOwner = "changeChatRoomOwner";
  static const String addChatRoomAdmin = "addChatRoomAdmin";
  static const String removeChatRoomAdmin = "removeChatRoomAdmin";
  static const String fetchChatRoomMuteList = "fetchChatRoomMuteList";
  static const String removeChatRoomMembers = "removeChatRoomMembers";
  static const String blockChatRoomMembers = "blockChatRoomMembers";
  static const String unBlockChatRoomMembers = "unBlockChatRoomMembers";
  static const String fetchChatRoomBlockList = "fetchChatRoomBlockList";
  static const String updateChatRoomAnnouncement = "updateChatRoomAnnouncement";
  static const String fetchChatRoomAnnouncement = "fetchChatRoomAnnouncement";
  static const String addMembersToChatRoomWhiteList =
      "addMembersToChatRoomWhiteList";
  static const String removeMembersFromChatRoomWhiteList =
      "removeMembersFromChatRoomWhiteList";
  static const String fetchChatRoomWhiteListFromServer =
      "fetchChatRoomWhiteListFromServer";
  static const String isMemberInChatRoomWhiteListFromServer =
      "isMemberInChatRoomWhiteListFromServer";

  static const String muteAllChatRoomMembers = "muteAllChatRoomMembers";
  static const String unMuteAllChatRoomMembers = "unMuteAllChatRoomMembers";

  /// EMChatRoomManagerListener
  static const String chatRoomChange = "onChatRoomChanged";

  /// EMGroupManager
  static const String getGroupWithId = "getGroupWithId";
  static const String getJoinedGroups = "getJoinedGroups";
  static const String getGroupsWithoutPushNotification =
      "getGroupsWithoutPushNotification";
  static const String getJoinedGroupsFromServer = "getJoinedGroupsFromServer";
  static const String getPublicGroupsFromServer = "getPublicGroupsFromServer";
  static const String createGroup = "createGroup";
  static const String getGroupSpecificationFromServer =
      "getGroupSpecificationFromServer";
  static const String getGroupMemberListFromServer =
      "getGroupMemberListFromServer";
  static const String getGroupBlockListFromServer =
      "getGroupBlockListFromServer";
  static const String getGroupMuteListFromServer = "getGroupMuteListFromServer";
  static const String getGroupWhiteListFromServer =
      "getGroupWhiteListFromServer";
  static const String isMemberInWhiteListFromServer =
      "isMemberInWhiteListFromServer";
  static const String getGroupFileListFromServer = "getGroupFileListFromServer";
  static const String getGroupAnnouncementFromServer =
      "getGroupAnnouncementFromServer";
  static const String addMembers = "addMembers";
  static const String inviterUser = "inviterUser";
  static const String removeMembers = "removeMembers";
  static const String blockMembers = "blockMembers";
  static const String unblockMembers = "unblockMembers";
  static const String updateGroupSubject = "updateGroupSubject";
  static const String updateDescription = "updateDescription";
  static const String leaveGroup = "leaveGroup";
  static const String destroyGroup = "destroyGroup";
  static const String blockGroup = "blockGroup";
  static const String unblockGroup = "unblockGroup";
  static const String updateGroupOwner = "updateGroupOwner";
  static const String addAdmin = "addAdmin";
  static const String removeAdmin = "removeAdmin";
  static const String muteMembers = "muteMembers";
  static const String unMuteMembers = "unMuteMembers";
  static const String muteAllMembers = "muteAllMembers";
  static const String unMuteAllMembers = "unMuteAllMembers";
  static const String addWhiteList = "addWhiteList";
  static const String removeWhiteList = "removeWhiteList";
  static const String uploadGroupSharedFile = "uploadGroupSharedFile";
  static const String downloadGroupSharedFile = "downloadGroupSharedFile";
  static const String removeGroupSharedFile = "removeGroupSharedFile";
  static const String updateGroupAnnouncement = "updateGroupAnnouncement";
  static const String updateGroupExt = "updateGroupExt";
  static const String joinPublicGroup = "joinPublicGroup";
  static const String requestToJoinPublicGroup = "requestToJoinPublicGroup";
  static const String acceptJoinApplication = "acceptJoinApplication";
  static const String declineJoinApplication = "declineJoinApplication";
  static const String acceptInvitationFromGroup = "acceptInvitationFromGroup";
  static const String declineInvitationFromGroup = "declineInvitationFromGroup";

  /// EMGroupManagerListener
  static const String onGroupChanged = "onGroupChanged";

  /// EMPushManager
  static const String getImPushConfig = "getImPushConfig";
  static const String getImPushConfigFromServer = "getImPushConfigFromServer";
  static const String enableOfflinePush = "enableOfflinePush";
  static const String disableOfflinePush = "disableOfflinePush";
  static const String updateImPushStyle = "updateImPushStyle";
  static const String updatePushNickname = "updatePushNickname";

  static const String updateGroupPushService = "updateGroupPushService";
  static const String getNoPushGroups = "getNoPushGroups";
  static const String updateUserPushService = "updateUserPushService";
  static const String getNoPushUsers = "getNoPushUsers";

  static const String updateHMSPushToken = "updateHMSPushToken";
  static const String updateFCMPushToken = "updateFCMPushToken";
  static const String updateAPNsPushToken = "updateAPNsPushToken";

  static const String reportPushAction = "reportPushAction";
  static const String setConversationSilentMode = "setConversationSilentMode";
  static const String removeConversationSilentMode =
      "removeConversationSilentMode";
  static const String fetchConversationSilentMode =
      "fetchConversationSilentMode";
  static const String setSilentModeForAll = "setSilentModeForAll";
  static const String fetchSilentModeForAll = "fetchSilentModeForAll";
  static const String fetchSilentModeForConversations =
      "fetchSilentModeForConversations";
  static const String setPreferredNotificationLanguage =
      "setPreferredNotificationLanguage";
  static const String fetchPreferredNotificationLanguage =
      "fetchPreferredNotificationLanguage";

  /// EMUserInfoManager methods
  static const String updateOwnUserInfo = "updateOwnUserInfo";
  static const String updateOwnUserInfoWithType = "updateOwnUserInfoWithType";
  static const String fetchUserInfoById = "fetchUserInfoById";
  static const String fetchUserInfoByIdWithType = "fetchUserInfoByIdWithType";

  /// EMPresenceManager methods
  static const String presenceWithDescription =
      "publishPresenceWithDescription";
  static const String presenceSubscribe = "presenceSubscribe";
  static const String presenceUnsubscribe = "presenceUnsubscribe";
  static const String fetchSubscribedMembersWithPageNum =
      "fetchSubscribedMembersWithPageNum";
  static const String fetchPresenceStatus = "fetchPresenceStatus";

  /// EMChatThreadManager methods
  static const String fetchChatThreadDetail = "fetchChatThreadDetail";
  static const String fetchJoinedChatThreads = "fetchJoinedChatThreads";
  static const String fetchChatThreadsWithParentId =
      "fetchChatThreadsWithParentId";
  static const String fetchJoinedChatThreadsWithParentId =
      "fetchJoinedChatThreadsWithParentId";
  static const String fetchChatThreadMember = "fetchChatThreadMember";
  static const String fetchLastMessageWithChatThreads =
      "fetchLastMessageWithChatThreads";
  static const String removeMemberFromChatThread = "removeMemberFromChatThread";
  static const String updateChatThreadSubject = "updateChatThreadSubject";
  static const String createChatThread = "createChatThread";
  static const String joinChatThread = "joinChatThread";
  static const String leaveChatThread = "leaveChatThread";
  static const String destroyChatThread = "destroyChatThread";

  // EMChatThreadManagerListener
  static const String onChatThreadCreate = "onChatThreadCreate";
  static const String onChatThreadUpdate = "onChatThreadUpdate";
  static const String onChatThreadDestroy = "onChatThreadDestroy";
  static const String onUserKickOutOfChatThread = "onUserKickOutOfChatThread";

  /// HandleAction
  static const String startCallback = "startCallback";
}
