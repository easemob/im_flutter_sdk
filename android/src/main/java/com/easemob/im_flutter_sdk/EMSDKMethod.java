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
    static final String onClientMigrate2x = "onClientMigrate2x"; // 3.x sdk应该用不上
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
    static final String groupacceptInvitation = "acceptInvitation";
    static final String groupdeclineInvitation = "declineInvitation";
    static final String acceptApplication = "acceptApplication";
    static final String declineApplication = "declineApplication";
    static final String inviteUser = "inviteUser";
    static final String applyJoinToGroup = "applyJoinToGroup";
    static final String blockGroupMessage = "blockGroupMessage";
    static final String unblockGroupMessage = "unblockGroupMessage";
    static final String blockUser = "blockUser";
    static final String unblockUser = "unblockUser";
    static final String getBlockedUsers = "getBlockedUsers";
    static final String fetchGroupMembers = "fetchGroupMembers";
    static final String changeOwner = "changeOwner";
    static final String addGroupAdmin = "addGroupAdmin";
    static final String removeGroupAdmin = "removeGroupAdmin";
    static final String muteGroupMembers = "muteGroupMembers";
    static final String unMuteGroupMembers = "unMuteGroupMembers";
    static final String fetchGroupMuteList = "fetchGroupMuteList";
    static final String fetchGroupBlackList = "fetchGroupBlackList";
    static final String updateGroupAnnouncement = "updateGroupAnnouncement";
    static final String fetchGroupAnnouncement = "fetchGroupAnnouncement";
    static final String uploadGroupSharedFile = "uploadGroupSharedFile";
    static final String fetchGroupSharedFileList = "fetchGroupSharedFileList";
    static final String deleteGroupSharedFile = "deleteGroupSharedFile";
    static final String downloadGroupSharedFile = "downloadGroupSharedFile";
    static final String updateGroupExtension = "updateGroupExtension";
    static final String onGroupChange = "onGroupChange";
    
    /// EMGroup
    static final String getGroupId = "getGroupId";
    static final String getGroupName = "getGroupName";
    static final String getDescription = "getDescription";
    static final String isPublic = "isPublic";
    static final String isAllowInvites = "isAllowInvites";
    static final String isMemberAllowToInvite = "isMemberAllowToInvite";
    static final String isMembersOnly = "isMembersOnly";
    static final String getMaxUserCount = "getMaxUserCount";
    static final String isMsgBlocked = "isMsgBlocked";
    static final String getOwner = "getOwner";
    static final String groupSubject = "groupSubject";
    static final String getMembers = "getMembers";
    static final String getMemberCount = "getMemberCount";
    static final String getAdminList = "getAdminList";
    static final String getBlackList = "getBlackList";
    static final String getMuteList = "getMuteList";
    static final String getExtension = "getExtension";
    static final String getAnnouncement = "getAnnouncement";
    static final String getShareFileList = "getShareFileList";
}
