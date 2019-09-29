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

  /// EMConversation
  static const String getUnreadMsgCount = 'getUnreadMsgCount';
  static const String markAllMessagesAsRead = 'markAllMessagesAsRead';
  static const String getAllMsgCount = 'getAllMsgCount';
  static const String loadMoreMsgFromDB = 'loadMoreMsgFromDB';
  static const String searchMsgFromDB = 'searchMsgFromDB';
  static const String getAllMessage = 'getAllMessage';
  static const String markMessageAsRead = 'markMessageAsRead';
  static const String removeMessage = 'removeMessage';
  static const String getLastMessage = 'getLastMessage';
  static const String getLatestMessageFromOthers = 'getLatestMessageFromOthers';
  static const String clear = 'clear';
  static const String clearAllMessages = 'clearAllMessages';
  static const String insertMessage = 'insertMessage';
  static const String appendMessage = 'appendMessage';
  static const String updateMessage = 'updateMessage';
  static const String getMessageAttachmentPath = 'getMessageAttachmentPath';
}
