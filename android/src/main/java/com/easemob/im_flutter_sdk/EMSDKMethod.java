package com.easemob.im_flutter_sdk;

public class EMSDKMethod {
    /// EMClient methods
    static final String init = "init";
    static final String createAccount = "createAccount";
    static final String login = "login";
    static final String loginWithToken = "loginWithToken";
    static final String logout = "logout";
    static final String changeAppKey = "changeAppKey";
    static final String isLoggedInBefore = "isLoggedInBefore";
    static final String setDebugMode = "setDebugMode";
    static final String updateCurrentUserNick = "updateCurrentUserNick";
    static final String uploadLog = "uploadLog";
    static final String compressLogs = "compressLogs";
    static final String kickDevice = "kickDevice";
    static final String kickAllDevices = "kickAllDevices";
    static final String getLoggedInDevicesFromServer =  "getLoggedInDevicesFromServer";
    static final String getCurrentUser =  "getCurrentUser";

    static final String onConnected = "onConnected";
    static final String onDisconnected = "onDisconnected";
    static final String onMultiDeviceEvent = "onMultiDeviceEvent";

    /// EMContactManager methods
    static final String addContact = "addContact";
    static final String deleteContact = "deleteContact";
    static final String getAllContactsFromServer = "getAllContactsFromServer";
    static final String addUserToBlackList = "addUserToBlackList";
    static final String removeUserFromBlackList = "removeUserFromBlackList";
    static final String getBlackListFromServer = "getBlackListFromServer";
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
    static final String onMessageStatusOnProgress = "onMessageStatusOnProgress";

    /// EMConversation
    static final String getUnreadMsgCount = "getUnreadMsgCount";
    static final String markAllMessagesAsRead = "markAllMessagesAsRead";
    static final String loadMoreMsgFromDB = "loadMoreMsgFromDB";
    static final String searchConversationMsgFromDB = "searchConversationMsgFromDB";
    static final String searchConversationMsgFromDBByType = "searchConversationMsgFromDBByType";
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

    //EMChatRoomManagerListener
    static final String chatRoomChange = "onChatRoomChange";

    /// EMGroupManager
    static final String getAllGroups = "getAllGroups";
    static final String getGroup = "getGroup";
    static final String createGroup = "createGroup";
    static final String loadAllGroups = "loadAllGroups";
    static final String destroyGroup = "destroyGroup";
    static final String addUsersToGroup = "addUsersToGroup";
    static final String removeUserFromGroup = "removeUserFromGroup";
    static final String leaveGroup = "leaveGroup";
    static final String getGroupFromServer = "getGroupFromServer";
    static final String getJoinedGroupsFromServer = "getJoinedGroupsFromServer";
    static final String getPublicGroupsFromServer = "getPublicGroupsFromServer";
    static final String joinGroup = "joinGroup";
    static final String changeGroupName = "changeGroupName";
    static final String changeGroupDescription = "changeGroupDescription";
    static final String acceptGroupInvitation = "acceptGroupInvitation";
    static final String declineGroupInvitation = "declineGroupInvitation";
    static final String acceptApplication = "acceptApplication";
    static final String declineApplication = "declineApplication";
    static final String inviteUser = "inviteUser";
    static final String applyJoinToGroup = "applyJoinToGroup";
    static final String blockGroupMessage = "blockGroupMessage";
    static final String unblockGroupMessage = "unblockGroupMessage";
    static final String blockUser = "blockUser";
    static final String unblockUser = "unblockUser";
    static final String fetchGroupBlackList = "fetchGroupBlackList";
    static final String fetchGroupMembers = "fetchGroupMembers";
    static final String changeOwner = "changeOwner";
    static final String addGroupAdmin = "addGroupAdmin";
    static final String removeGroupAdmin = "removeGroupAdmin";
    static final String muteGroupMembers = "muteGroupMembers";
    static final String unMuteGroupMembers = "unMuteGroupMembers";
    static final String fetchGroupMuteList = "fetchGroupMuteList";
    static final String updateGroupAnnouncement = "updateGroupAnnouncement";
    static final String fetchGroupAnnouncement = "fetchGroupAnnouncement";
    static final String uploadGroupSharedFile = "uploadGroupSharedFile";
    static final String fetchGroupSharedFileList = "fetchGroupSharedFileList";
    static final String deleteGroupSharedFile = "deleteGroupSharedFile";
    static final String downloadGroupSharedFile = "downloadGroupSharedFile";
    static final String updateGroupExtension = "updateGroupExtension";

    static final String onGroupChanged = "onGroupChanged";

    //EMPushManager
    static final String enableOfflinePush = "enableOfflinePush";
    static final String disableOfflinePush = "disableOfflinePush";
    static final String getPushConfigs = "getPushConfigs";
    static final String getPushConfigsFromServer = "getPushConfigsFromServer";
    static final String updatePushServiceForGroup = "updatePushServiceForGroup";
    static final String getNoPushGroups = "getNoPushGroups";
    static final String updatePushNickname = "updatePushNickname";
    static final String updatePushDisplayStyle = "updatePushDisplayStyle";

    //EMCallStatusListener
    public static final String callStatusConnecting = "connecting";
    public static final String callStatusConnected = "connected";
    public static final String callStatusAccepted  = "accepted";
    public static final String callStatusDisconnected  = "disconnected";
    public static final String netWorkDisconnected = "netWorkDisconnected";
    public static final String netWorkUnstable = "networkUnstable";
    public static final String netWorkNormal = "netWorkNormal";
    public static final String netVideoPause= "netVideoPause";
    public static final String netVideoResume = "netVideoResume";
    public static final String netVoicePause = "netVoicePause";
    public static final String netVoiceResume = "netVoiceResume";

    public static final String onCallChanged = "onCallChanged";
    public static final String startCall = "startCall";
    public static final String registerCallReceiver = "registerCallReceiver";
    public static final String setCallOptions = "setCallOptions";

    public static String getCallId = "getCallId";
    public static String getConnectType = "getConnectType";
    public static String getExt = "getExt";
    public static String getLocalName = "getLocalName";
    public static String getRemoteName = "getRemoteName";
    public static String getServerRecordId = "getServerRecordId";
    public static String getCallType = "getCallType";
    public static String isRecordOnServer = "isRecordOnServer";

}
