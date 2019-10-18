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
    static final String getCursor = "getCursor";
    static final String onMessageReceived = "onMessageReceived";
    static final String onCmdMessageReceived = "onCmdMessageReceived";
    static final String onMessageRead = "onMessageRead";
    static final String onMessageDelivered = "onMessageDelivered";
    static final String onMessageRecalled = "onMessageRecalled";
    static final String onMessageChanged = "onMessageChanged";
    static final String onConversationUpdate = "onConversationUpdate";

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


    //EMChatRoomManager
    static final String joinChatRoom = "joinChatRoom";
    static final String leaveChatRoom = "leaveChatRoom";
    static final String fetchPublicChatRoomsFromServer = "fetchPublicChatRoomsFromServer";
    static final String asyncFetchChatRoomFromServer = "asyncFetchChatRoomFromServer";
    static final String getChatRoom = "getChatRoom";
    static final String getAllChatRooms = "getAllChatRooms";
    static final String asyncCreateChatRoom = "asyncCreateChatRoom";
    static final String asyncDestroyChatRoom = "asyncDestroyChatRoom";
    static final String asyncChangeChatRoomSubject = "asyncChangeChatRoomSubject";
    static final String asyncChangeChatroomDescription = "asyncChangeChatroomDescription";
    static final String asyncFetchChatRoomMembers = "asyncFetchChatRoomMembers";
    static final String asyncMuteChatRoomMembers = "asyncMuteChatRoomMembers";
    static final String asyncUnMuteChatRoomMembers = "asyncUnMuteChatRoomMembers";
    static final String asyncChangeOwner = "asyncChangeOwner";
    static final String asyncAddChatRoomAdmin = "asyncAddChatRoomAdmin";
    static final String asyncRemoveChatRoomAdmin = "asyncRemoveChatRoomAdmin";
    static final String asyncFetchChatRoomMuteList = "asyncFetchChatRoomMuteList";
    static final String asyncRemoveChatRoomMembers = "asyncRemoveChatRoomMembers";
    static final String asyncBlockChatroomMembers = "asyncBlockChatroomMembers";
    static final String asyncUnBlockChatRoomMembers = "asyncUnBlockChatRoomMembers";
    static final String asyncFetchChatRoomBlackList = "asyncFetchChatRoomBlackList";
    static final String asyncUpdateChatRoomAnnouncement = "asyncUpdateChatRoomAnnouncement";
    static final String asyncFetchChatRoomAnnouncement = "asyncFetchChatRoomAnnouncement";

    //EMChatRoomManagerListener
    static final String ChatRoomChange = "ChatRoomChange";

    //EMChatRoom
    static final String getId = "getId";
    static final String getName = "getName";
    static final String getDescription = "getDescription";
    static final String getOwner = "getOwner";
    static final String getAdminList = "getAdminList";
    static final String getMemberCount = "getMemberCount";
    static final String getMaxUsers = "getMaxUsers";
    static final String getMemberList = "getMemberList";
    static final String getBlackList = "getBlackList";
    static final String getMuteList = "getMuteList";
    static final String getAnnouncement = "getAnnouncement";
}
