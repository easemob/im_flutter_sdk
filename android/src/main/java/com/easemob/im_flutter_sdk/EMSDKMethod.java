package com.easemob.im_flutter_sdk;

public class EMSDKMethod {
    /// EMClient methods
    static final String init = "init";
    static final String createAccount = "createAccount";
    static final String login = "login";
    static final String loginWithToken = "loginWithToken";
    static final String logout = "logout";
    static final String chatManager = "chatManager";
    static final String register = "register";
    static final String changeAppKey = "changeAppKey";
    static final String getCurrentUser = "getCurrentUser";
    static final String getUserTokenFromServer = "getUserTokenFromServer";
    static final String setDebugMode = "setDebugMode";
    static final String updateCurrentUserNick = "updateCurrentUserNick";
    static final String uploadLog = "uploadLog";
    static final String compressLogs = "compressLogs";
    static final String kickDevice = "kickDevice";
    static final String kickAllDevices = "kickAllDevices";
    static final String sendFCMTokenToServer = "sendFCMTokenToServer";
    static final String sendHMSPushTokenToServer = "sendHMSPushTokenToServer";
    static final String getDeviceInfo = "getDeviceInfo";
    static final String getRobotsFromServer = "getRobotsFromServer";
    static final String onMultiDeviceEvent = "onMultiDeviceEvent";
    static final String check = "check";
    static final String onClientMigrate2x = "onClientMigrate2x";
    static final String onConnectionDidChanged = "onConnectionDidChanged";
    static final String getLoggedInDevicesFromServer =
            "getLoggedInDevicesFromServer";

    /// EMContactManager methods
    static final String addContact = "addContact";
    static final String deleteContact = "deleteContact";
    static final String getAllContactsFromServer = "getAllContactsFromServer";
    static final String addUserToBlackList = "addUserToBlackList";
    static final String removeUserFromBlackList = "removeUserFromBlackList";
    static final String getBlackListFromServer = "getBlackListFromServer";
    static final String saveBlackList = "saveBlackList";
    static final String acceptInvitation = "acceptInvitation";
    static final String declineInvitation = "declineInvitation";
    static final String getSelfIdsOnOtherPlatform = "getSelfIdsOnOtherPlatform";
    static final String onContactChanged = "onContactChanged";

    /// EMChatManager methods
    static final String sendMessage = "sendMessage";
    static final String ackMessageRead = "ackMessageRead";
    static final String recallMessage = "recallMessage";
    static final String getMessage = "getMessage";
    static final String getConversation = "getConversation";
    static final String markAllChatMsgAsRead = "markAllChatMsgAsRead";
    static final String getUnreadMessageCount = "getUnreadMessageCount";
    static final String saveMessage = "saveMessage";
    static final String updateChatMessage = "updateChatMessage";
    static final String downloadAttachment = "downloadAttachment";
    static final String downloadThumbnail = "downloadThumbnail";
    static final String importMessages = "importMessages";
    static final String getConversationsByType = "getConversationsByType";
    static final String downloadFile = "downloadFile";
    static final String getAllConversations = "getAllConversations";
    static final String loadAllConversations = "loadAllConversations";
    static final String deleteConversation = "deleteConversation";
    static final String setMessageListened = "setMessageListened";
    static final String setVoiceMessageListened = "setVoiceMessageListened";
    static final String updateParticipant = "updateParticipant";
    static final String fetchHistoryMessages = "fetchHistoryMessages";
    static final String searchChatMsgFromDB = "searchChatMsgFromDB";

    /// EMConversation
    static final String getUnreadMsgCount = "getUnreadMsgCount";
    static final String markAllMessagesAsRead = "markAllMessagesAsRead";
    static final String getAllMsgCount = "getAllMsgCount";
    static final String loadMoreMsgFromDB = "loadMoreMsgFromDB";
    static final String searchConversationMsgFromDB = "searchConversationMsgFromDB";
    static final String searchConversationMsgFromDBByType = "searchConversationMsgFromDBByType";
    static final String getAllMessages = "getAllMessages";
    static final String loadMessages = "loadMessages";
    static final String markMessageAsRead = "markMessageAsRead";
    static final String removeMessage = "removeMessage";
    static final String getLastMessage = "getLastMessage";
    static final String getLatestMessageFromOthers = "getLatestMessageFromOthers";
    static final String clear = "clear";
    static final String clearAllMessages = "clearAllMessages";
    static final String insertMessage = "insertMessage";
    static final String appendMessage = "appendMessage";
    static final String updateConversationMessage = "updateConversationMessage";
    static final String getMessageAttachmentPath = "getMessageAttachmentPath";
}
