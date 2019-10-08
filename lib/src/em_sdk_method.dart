class EMSDKMethod {
  /// EMClient methods
  static const String init = 'init';
  static const String createAccount = 'createAccount';
  static const String login = 'login';
  static const String loginWithToken = 'loginWithToken';
  static const String logout = 'logout';
  static const String chatManager = 'chatManager';
  static const String register = 'register';
  static const String changeAppKey = 'changeAppKey';
  static const String getCurrentUser = 'getCurrentUser';
  static const String getUserTokenFromServer = 'getUserTokenFromServer';
  static const String setDebugMode = 'setDebugMode';
  static const String updateCurrentUserNick = 'updateCurrentUserNick';
  static const String uploadLog = 'uploadLog';
  static const String compressLogs = 'compressLogs';
  static const String kickDevice = 'kickDevice';
  static const String kickAllDevices = 'kickAllDevices';
  static const String sendFCMTokenToServer = 'sendFCMTokenToServer';
  static const String sendHMSPushTokenToServer = 'sendHMSPushTokenToServer';
  static const String getDeviceInfo = 'getDeviceInfo';
  static const String getRobotsFromServer = 'getRobotsFromServer';
  static const String onMultiDeviceEvent = 'onMultiDeviceEvent';
  static const String check = 'check';
  static const String onClientMigrate2x = 'onClientMigrate2x';
  static const String onConnectionDidChanged = 'onConnectionDidChanged';
  static const String getLoggedInDevicesFromServer =
      'getLoggedInDevicesFromServer';

  /// EMContactManager methods
  static const String addContact = 'addContact';
  static const String deleteContact = 'deleteContact';
  static const String getAllContactsFromServer = 'getAllContactsFromServer';
  static const String addUserToBlackList = 'addUserToBlackList';
  static const String removeUserFromBlackList = 'removeUserFromBlackList';
  static const String getBlackListFromServer = 'getBlackListFromServer';
  static const String saveBlackList = 'saveBlackList';
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
  static const String setMessageListened = "setMessageListened";
  static const String setVoiceMessageListened = "setVoiceMessageListened";
  static const String updateParticipant = "updateParticipant";
  static const String fetchHistoryMessages = "fetchHistoryMessages";
  static const String searchChatMsgFromDB = "searchChatMsgFromDB";

  /// EMConversation
  static const String getUnreadMsgCount = 'getUnreadMsgCount';
  static const String markAllMessagesAsRead = 'markAllMessagesAsRead';
  static const String getAllMsgCount = 'getAllMsgCount';
  static const String loadMoreMsgFromDB = 'loadMoreMsgFromDB';
  static const String searchConversationMsgFromDB =
      'searchConversationMsgFromDB';
  static const String searchConversationMsgFromDBByType =
      'searchConversationMsgFromDB';
  static const String getAllMessages = 'getAllMessages';
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
}
