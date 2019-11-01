package com.easemob.im_flutter_sdk;

public class EMSDKMethod {
    /// EMClient methods
    static final String init = "init";
    static final String createAccount = "createAccount";
    static final String login = "login";
    static final String loginWithToken = "loginWithToken";
    static final String logout = "logout";
    static final String chatManager = "chatManager"; // ?
    static final String changeAppKey = "changeAppKey";
    static final String getCurrentUser = "getCurrentUser"; // ?
    static final String setDebugMode = "setDebugMode";
    static final String updateCurrentUserNick = "updateCurrentUserNick";
    static final String uploadLog = "uploadLog";
    static final String compressLogs = "compressLogs";
    static final String kickDevice = "kickDevice";
    static final String kickAllDevices = "kickAllDevices";
    static final String sendFCMTokenToServer = "sendFCMTokenToServer";
    static final String sendHMSPushTokenToServer = "sendHMSPushTokenToServer";
    static final String getDeviceInfo = "getDeviceInfo";
    static final String onMultiDeviceEvent = "onMultiDeviceEvent";
    static final String check = "check";
    static final String onConnected = "onConnected";
    static final String onDisconnected = "onDisconnected";
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
    static final String asyncFetchChatRoomFromServer = "fetchChatRoomFromServer";
    static final String getChatRoom = "getChatRoom";
    static final String getAllChatRooms = "getAllChatRooms";
    static final String asyncCreateChatRoom = "createChatRoom";
    static final String asyncDestroyChatRoom = "destroyChatRoom";
    static final String asyncChangeChatRoomSubject = "changeChatRoomSubject";
    static final String asyncChangeChatRoomDescription = "changeChatRoomDescription";
    static final String asyncFetchChatRoomMembers = "fetchChatRoomMembers";
    static final String asyncMuteChatRoomMembers = "muteChatRoomMembers";
    static final String asyncUnMuteChatRoomMembers = "unMuteChatRoomMembers";
    static final String asyncChangeOwner = "changeChatRoomOwner";
    static final String asyncAddChatRoomAdmin = "addChatRoomAdmin";
    static final String asyncRemoveChatRoomAdmin = "removeChatRoomAdmin";
    static final String asyncFetchChatRoomMuteList = "fetchChatRoomMuteList";
    static final String asyncRemoveChatRoomMembers = "removeChatRoomMembers";
    static final String asyncBlockChatRoomMembers = "blockChatRoomMembers";
    static final String asyncUnBlockChatRoomMembers = "unBlockChatRoomMembers";
    static final String asyncFetchChatRoomBlackList = "fetchChatRoomBlackList";
    static final String asyncUpdateChatRoomAnnouncement = "updateChatRoomAnnouncement";
    static final String asyncFetchChatRoomAnnouncement = "fetchChatRoomAnnouncement";

    //EMChatRoomManagerListener
    static final String chatRoomChange = "onChatRoomChange";

    //EMChatRoom
    static final String getId = "getId";
    static final String getName = "getName";
    static final String getChatRoomDescription = "getChatRoomDescription";
    static final String getChatRoomOwner = "getChatRoomOwner";
    static final String getChatRoomAdminList = "getChatRoomAdminList";
    static final String getChatRoomMemberCount = "getChatRoomMemberCount";
    static final String getMaxUsers = "getMaxUsers";
    static final String getMemberList = "getMemberList";
    static final String getChatRoomBlackList = "getChatRoomBlackList";
    static final String getChatRoomMuteList = "getChatRoomMuteList";
    static final String getChatRoomAnnouncement = "getChatRoomAnnouncement";

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
    static final String onInvitationReceived = "onInvitationReceived";
    static final String onRequestToJoinReceived = "onRequestToJoinReceived";
    static final String onRequestToJoinAccepted = "onRequestToJoinAccepted";
    static final String onRequestToJoinDeclined = "onRequestToJoinDeclined";
    static final String onInvitationAccepted = "onInvitationAccepted";
    static final String onInvitationDeclined = "onInvitationDeclined";
    static final String onUserRemoved = "onUserRemoved";
    static final String onGroupDestroyed = "onGroupDestroyed";
    static final String onAutoAcceptInvitationFromGroup = "onAutoAcceptInvitationFromGroup";
    static final String onMuteListAdded = "onMuteListAdded";
    static final String onMuteListRemoved = "onMuteListRemoved";
    static final String onAdminAdded = "onAdminAdded";
    static final String onAdminRemoved = "onAdminRemoved";
    static final String onOwnerChanged = "onOwnerChanged";
    static final String onMemberJoined = "onMemberJoined";
    static final String onMemberExited = "onMemberExited";
    static final String onAnnouncementChanged = "onAnnouncementChanged";
    static final String onSharedFileAdded = "onSharedFileAdded";
    static final String onSharedFileDeleted = "onSharedFileDeleted";
}
