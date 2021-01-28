package com.easemob.im_flutter_sdk;

public class EMSDKMethod {
    /// EMClient methods
    static final String init = "init";
    static final String createAccount = "createAccount";
    static final String login = "login";
    static final String logout = "logout";
    static final String changeAppKey = "changeAppKey";
    static final String isLoggedInBefore = "isLoggedInBefore";
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
    static final String getConversation = "getConversation";
    static final String markAllChatMsgAsRead = "markAllChatMsgAsRead";
    static final String getUnreadMessageCount = "getUnreadMessageCount";
    static final String updateChatMessage = "updateChatMessage";
    static final String downloadAttachment = "downloadAttachment";
    static final String downloadThumbnail = "downloadThumbnail";
    static final String importMessages = "importMessages";
    static final String loadAllConversations = "loadAllConversations";
    static final String deleteConversation = "deleteConversation";
    static final String fetchHistoryMessages = "fetchHistoryMessages";
    static final String searchChatMsgFromDB = "searchChatMsgFromDB";
    static final String getMessage = "getMessage";

    /// EMChatManager listener
    static final String onMessagesReceived = "onMessagesReceived";
    static final String onCmdMessagesReceived = "onCmdMessagesReceived";
    static final String onMessagesRead = "onMessagesRead";
    static final String onMessagesDelivered = "onMessagesDelivered";
    static final String onMessagesRecalled = "onMessagesRecalled";
    static final String onMessageChanged = "onMessageChanged";
    
    static final String onConversationUpdate = "onConversationUpdate";

    /// EMMessage listener
    static final String onMessageProgressUpdate = "onMessageProgressUpdate";
    static final String onMessageError = "onMessageError";
    static final String onMessageSuccess = "onMessageSuccess";
    static final String onMessageReadAck = "onMessageReadAck";
    static final String onMessageDeliveryAck = "onMessageDeliveryAck";
    static final String onMessageStatusChanged = "onMessageStatusChanged";

/// EMConversation
    static final String getUnreadMsgCount = "getUnreadMsgCount";
    static final String markAllMessagesAsRead = "markAllMessagesAsRead";
    static final String markMessageAsRead = "markMessageAsRead";
    static final String removeMessage = "removeMessage";
    static final String getLatestMessage = "getLatestMessage";
    static final String getLatestMessageFromOthers = "getLatestMessageFromOthers";
    static final String clearAllMessages = "clearAllMessages";
    static final String insertMessage = "insertMessage";
    static final String appendMessage = "appendMessage";
    static final String updateConversationMessage = "updateConversationMessage";


    // 根据消息id获取消息
    static final String loadMsgWithId = "loadMsgWithId";
    // 根据起始消息id获取消息
    static final String loadMsgWithStartId = "loadMsgWithStartId";
    // 根据关键字获取消息
    static final String loadMsgWithKeywords = "loadMsgWithKeywords";
    // 根据消息类型获取消息
    static final String loadMsgWithMsgType = "loadMsgWithMsgType";
    // 通过时间获取消息
    static final String loadMsgWithTime = "loadMsgWithTime";


    //EMChatRoomManager
    static final String joinChatRoom = "joinChatRoom";
    static final String leaveChatRoom = "leaveChatRoom";
    static final String fetchPublicChatRoomsFromServer = "fetchPublicChatRoomsFromServer";
    static final String fetchChatRoomInfoFromServer = "fetchChatRoomInfoFromServer";
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
    static final String getGroupWithId = "getGroupWithId";
    static final String getJoinedGroups = "getJoinedGroups";
    static final String getGroupsWithoutPushNotification = "getGroupsWithoutPushNotification";
    static final String getJoinedGroupsFromServer = "getJoinedGroupsFromServer";
    static final String getPublicGroupsFromServer = "getPublicGroupsFromServer";
    static final String createGroup = "createGroup";
    static final String getGroupSpecificationFromServer = "getGroupSpecificationFromServer";
    static final String getGroupMemberListFromServer = "getGroupMemberListFromServer";
    static final String getGroupBlacklistFromServer = "getGroupBlacklistFromServer";
    static final String getGroupMuteListFromServer = "getGroupMuteListFromServer";
    static final String getGroupWhiteListFromServer = "getGroupWhiteListFromServer";
    static final String isMemberInWhiteListFromServer = "isMemberInWhiteListFromServer";
    static final String getGroupFileListFromServer = "getGroupFileList";
    static final String getGroupAnnouncementFromServer = "getGroupAnnouncementFromServer";
    static final String addMembers = "addMembers";
    static final String removeMembers = "removeMembers";
    static final String blockMembers = "blockMembers";
    static final String unblockMembers = "unblockMembers";
    static final String updateGroupSubject = "updateGroupSubject";
    static final String updateDescription = "updateDescription";
    static final String leaveGroup = "leaveGroup";
    static final String destroyGroup = "destroyGroup";
    static final String blockGroup = "blockGroup";
    static final String unblockGroup = "unblockGroup";
    static final String updateGroupOwner = "updateGroupOwner";
    static final String addAdmin = "addAdmin";
    static final String removeAdmin = "removeAdmin";
    static final String muteMembers = "muteMembers";
    static final String unMuteMembers = "unMuteMembers";
    static final String muteAllMembers = "muteAllMembers";
    static final String unMuteAllMembers = "unMuteAllMembers";
    static final String addWhiteList = "addWhiteList";
    static final String removeWhiteList = "removeWhiteList";
    static final String uploadGroupSharedFile = "uploadGroupSharedFile";
    static final String downloadGroupSharedFile = "downloadGroupSharedFile";
    static final String removeGroupSharedFile = "removeGroupSharedFile";
    static final String updateGroupAnnouncement = "updateGroupAnnouncement";
    static final String updateGroupExt = "updateGroupExt";
    static final String joinPublicGroup = "joinPublicGroup";
    static final String requestToJoinPublicGroup = "requestToJoinPublicGroup";
    static final String acceptJoinApplication = "acceptJoinApplication";
    static final String declineJoinApplication = "declineJoinApplication";
    static final String acceptInvitationFromGroup = "acceptInvitationFromGroup";
    static final String declineInvitationFromGroup = "declineInvitationFromGroup";
    static final String ignoreGroupPush = "ignoreGroupPush";

    /// EMGroupManagerListener
    static final String onGroupChanged = "onGroupChanged";

    /// EMPushManager
    static final String getImPushConfig = "getImPushConfig";
    static final String getImPushConfigFromServer = "getImPushConfigFromServer";
    static final String updatePushNickname = "updatePushNickname";

    /// ImPushConfig
    static final String imPushNoDisturb = "imPushNoDisturb";
    static final String updateImPushStyle = "updateImPushStyle";
    static final String updateGroupPushService = "updateGroupPushService";
    static final String getNoDisturbGroups = "getNoDisturbGroups";
}
