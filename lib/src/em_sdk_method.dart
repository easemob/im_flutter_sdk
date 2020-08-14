class EMSDKMethod {
  /// EMClient methods
  static const String init = 'init';
  static const String createAccount = 'createAccount';
  static const String login = 'login';
  static const String loginWithToken = 'loginWithToken';
  static const String logout = 'logout';
  static const String changeAppKey = 'changeAppKey';
  static const String isLoggedInBefore = 'isLoggedInBefore';
  static const String setDebugMode = 'setDebugMode';
  static const String updateCurrentUserNick = 'updateCurrentUserNick';
  static const String uploadLog = 'uploadLog';
  static const String compressLogs = 'compressLogs';
  static const String kickDevice = 'kickDevice';
  static const String kickAllDevices = 'kickAllDevices';
  static const String onMultiDeviceEvent = 'onMultiDeviceEvent';
  static const String onConnected = "onConnected";
  static const String onDisconnected = "onDisconnected";
  static const String getLoggedInDevicesFromServer =
      'getLoggedInDevicesFromServer';
  static const String getCurrentUser =  "getCurrentUser";

  /// EMContactManager methods
  static const String addContact = 'addContact';
  static const String deleteContact = 'deleteContact';
  static const String getAllContactsFromServer = 'getAllContactsFromServer';
  static const String addUserToBlackList = 'addUserToBlackList';
  static const String removeUserFromBlackList = 'removeUserFromBlackList';
  static const String getBlackListFromServer = 'getBlackListFromServer';
  static const String acceptInvitation = 'acceptInvitation';
  static const String declineInvitation = 'declineInvitation';
  static const String getSelfIdsOnOtherPlatform = 'getSelfIdsOnOtherPlatform';
  static const String onContactChanged = 'onContactChanged';

  /// EMChatManager methods
  static const String sendMessage = 'sendMessage';
  static const String ackMessageRead = 'ackMessageRead';
  static const String recallMessage = 'recallMessage';
  static const String getMessage = 'getMessage';
  static const String getConversation = "getConversation";
  static const String markAllChatMsgAsRead = "markAllChatMsgAsRead";
  static const String getUnreadMessageCount = "getUnreadMessageCount";
  static const String saveMessage = "saveMessage";
  static const String updateChatMessage = "updateChatMessage";
  static const String downloadAttachment = "downloadAttachment";
  static const String downloadThumbnail = "downloadThumbnail";
  static const String importMessages = "importMessages";
  static const String getConversationsByType = "getConversationsByType";
  static const String downloadFile = "downloadFile";
  static const String getAllConversations = "getAllConversations";
  static const String loadAllConversations = "loadAllConversations";
  static const String deleteConversation = "deleteConversation";
  static const String setVoiceMessageListened = "setVoiceMessageListened";
  static const String updateParticipant = "updateParticipant";
  static const String fetchHistoryMessages = "fetchHistoryMessages";
  static const String searchChatMsgFromDB = "searchChatMsgFromDB";
  static const String getCursor = "getCursor";
  static const String onMessageReceived = "onMessageReceived";
  static const String onCmdMessageReceived = "onCmdMessageReceived";
  static const String onMessageRead = "onMessageRead";
  static const String onMessageDelivered = "onMessageDelivered";
  static const String onMessageRecalled = "onMessageRecalled";
  static const String onMessageChanged = "onMessageChanged";
  static const String onConversationUpdate = "onConversationUpdate";

  static const String onMessageStatusOnProgress = "onMessageStatusOnProgress";

  /// EMConversation
  static const String getUnreadMsgCount = 'getUnreadMsgCount';
  static const String markAllMessagesAsRead = 'markAllMessagesAsRead';
  static const String loadMoreMsgFromDB = 'loadMoreMsgFromDB';
  static const String searchConversationMsgFromDB =
      'searchConversationMsgFromDB';
  static const String searchConversationMsgFromDBByType =
      'searchConversationMsgFromDBByType';
  static const String loadMessages = 'loadMessages';
  static const String markMessageAsRead = 'markMessageAsRead';
  static const String removeMessage = 'removeMessage';
  static const String getLastMessage = 'getLastMessage';
  static const String getLatestMessageFromOthers = 'getLatestMessageFromOthers';
  static const String clear = 'clear';
  static const String clearAllMessages = 'clearAllMessages';
  static const String insertMessage = 'insertMessage';
  static const String appendMessage = 'appendMessage';
  static const String updateConversationMessage = 'updateConversationMessage';
  static const String getMessageAttachmentPath = 'getMessageAttachmentPath';


  ///EMChatRoomManager methods
  static final String joinChatRoom = "joinChatRoom";
  static final String leaveChatRoom = "leaveChatRoom";
  static final String fetchPublicChatRoomsFromServer = "fetchPublicChatRoomsFromServer";
  static final String fetchChatRoomFromServer = "fetchChatRoomFromServer";
  static final String getChatRoom = "getChatRoom";
  static final String getAllChatRooms = "getAllChatRooms";
  static final String createChatRoom = "createChatRoom";
  static final String destroyChatRoom = "destroyChatRoom";
  static final String changeChatRoomSubject = "changeChatRoomSubject";
  static final String changeChatRoomDescription = "changeChatRoomDescription";
  static final String fetchChatRoomMembers = "fetchChatRoomMembers";
  static final String muteChatRoomMembers = "muteChatRoomMembers";
  static final String unMuteChatRoomMembers = "unMuteChatRoomMembers";
  static final String changeChatRoomOwner = "changeChatRoomOwner";
  static final String addChatRoomAdmin = "addChatRoomAdmin";
  static final String removeChatRoomAdmin = "removeChatRoomAdmin";
  static final String fetchChatRoomMuteList = "fetchChatRoomMuteList";
  static final String removeChatRoomMembers = "removeChatRoomMembers";
  static final String blockChatRoomMembers = "blockChatRoomMembers";
  static final String unBlockChatRoomMembers = "unBlockChatRoomMembers";
  static final String fetchChatRoomBlackList = "fetchChatRoomBlackList";
  static final String updateChatRoomAnnouncement = "updateChatRoomAnnouncement";
  static final String fetchChatRoomAnnouncement = "fetchChatRoomAnnouncement";


  /// EMChatRoomManagerListener
  static final String chatRoomChange = "onChatRoomChanged";

  /// EMGroupManager
  static const String getAllGroups = "getAllGroups";
  static const String getGroup = "getGroup";
  static const String createGroup = "createGroup";
  static const String loadAllGroups = "loadAllGroups";
  static const String destroyGroup = "destroyGroup";
  static const String addUsersToGroup = "addUsersToGroup";
  static const String removeUserFromGroup = "removeUserFromGroup";
  static const String leaveGroup = "leaveGroup";
  static const String getGroupFromServer = "getGroupFromServer";
  static const String getJoinedGroupsFromServer = "getJoinedGroupsFromServer";
  static const String getPublicGroupsFromServer = "getPublicGroupsFromServer";
  static const String joinGroup = "joinGroup";
  static const String changeGroupName = "changeGroupName";
  static const String changeGroupDescription = "changeGroupDescription";
  static const String acceptGroupInvitation = "acceptGroupInvitation";
  static const String declineGroupInvitation = "declineGroupInvitation";
  static const String acceptApplication = "acceptApplication";
  static const String declineApplication = "declineApplication";
  static const String inviteUser = "inviteUser";
  static const String applyJoinToGroup = "applyJoinToGroup";
  static const String blockGroupMessage = "blockGroupMessage";
  static const String unblockGroupMessage = "unblockGroupMessage";
  static const String blockUser = "blockUser";
  static const String unblockUser = "unblockUser";
  static const String fetchGroupBlackList = "fetchGroupBlackList";
  static const String fetchGroupMembers = "fetchGroupMembers";
  static const String changeOwner = "changeOwner";
  static const String addGroupAdmin = "addGroupAdmin";
  static const String removeGroupAdmin = "removeGroupAdmin";
  static const String muteGroupMembers = "muteGroupMembers";
  static const String unMuteGroupMembers = "unMuteGroupMembers";
  static const String fetchGroupMuteList = "fetchGroupMuteList";
  static const String updateGroupAnnouncement = "updateGroupAnnouncement";
  static const String fetchGroupAnnouncement = "fetchGroupAnnouncement";
  static const String uploadGroupSharedFile = "uploadGroupSharedFile";
  static const String fetchGroupSharedFileList = "fetchGroupSharedFileList";
  static const String deleteGroupSharedFile = "deleteGroupSharedFile";
  static const String downloadGroupSharedFile = "downloadGroupSharedFile";
  static const String updateGroupExtension = "updateGroupExtension";

  /// EMGroupManagerListener
  static const String onGroupChanged = "onGroupChanged";


  /// EMPushManager
  static const String enableOfflinePush = "enableOfflinePush";
  static const String disableOfflinePush = "disableOfflinePush";
  static const String getPushConfigs = "getPushConfigs";
  static const String getPushConfigsFromServer = "getPushConfigsFromServer";
  static const String updatePushServiceForGroup = "updatePushServiceForGroup";
  static const String getNoPushGroups = "getNoPushGroups";
  static const String updatePushNickname = "updatePushNickname";
  static const String updatePushDisplayStyle = "updatePushDisplayStyle";

  /// EMCallManager
  static const String startCall = "startCall";
  static const String onCallChanged = "onCallChanged";
  static const String registerCallReceiver = "registerCallReceiver";
  static const String setCallOptions = "setCallOptions";

  static const String getCallId = "getCallId";
  static const String getConnectType = "getConnectType";
  static const String getExt = "getExt";
  static const String getLocalName = "getLocalName";
  static const String getRemoteName = "getRemoteName";
  static const String getServerRecordId = "getServerRecordId";
  static const String getCallType = "getCallType";
  static const String isRecordOnServer = "isRecordOnServer";
  static const String registerCallSharedManager = "registerCallSharedManager";

  /// EMConferenceManager
  static const String createAndJoinConference = "createAndJoinConference";
  static const String joinConference = "joinConference";
  static const String registerConferenceSharedManager = "registerConferenceSharedManager";



}
