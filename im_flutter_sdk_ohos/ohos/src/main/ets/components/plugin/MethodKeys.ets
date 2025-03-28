export default class MethodKey {
  /// EMClient methods
  static init = "init";
  static createAccount = "createAccount";
  static login = "login";
  static loginWithAgoraToken = "loginWithAgoraToken";
  static renewToken = "renewToken";
  static logout = "logout";
  static changeAppKey = "changeAppKey";

  static uploadLog = "uploadLog";
  static compressLogs = "compressLogs";
  static kickDevice = "kickDevice";
  static kickAllDevices = "kickAllDevices";
  static getLoggedInDevicesFromServer = "getLoggedInDevicesFromServer";

  static getToken = "getToken";
  static getCurrentUser = "getCurrentUser";
  static isLoggedInBefore = "isLoggedInBefore";
  static isConnected = "isConnected";

  static onConnected = "onConnected";
  static onDisconnected = "onDisconnected";
  static onUserDidLoginFromOtherDevice = "onUserDidLoginFromOtherDevice";
  static onUserDidRemoveFromServer = "onUserDidRemoveFromServer";
  static onUserDidForbidByServer = "onUserDidForbidByServer";
  static onUserDidChangePassword = "onUserDidChangePassword";
  static onUserDidLoginTooManyDevice = "onUserDidLoginTooManyDevice";
  static onUserKickedByOtherDevice = "onUserKickedByOtherDevice";
  static onUserAuthenticationFailed = "onUserAuthenticationFailed";
  static onAppActiveNumberReachLimit = "onAppActiveNumberReachLimit";
  static onMultiDeviceGroupEvent = "onMultiDeviceGroupEvent";
  static onMultiDeviceContactEvent = "onMultiDeviceContactEvent";
  static onMultiDeviceThreadEvent = "onMultiDeviceThreadEvent";
  static onMultiDeviceRemoveMessagesEvent = "onMultiDeviceRemoveMessagesEvent";
  static onMultiDevicesConversationEvent = "onMultiDevicesConversationEvent";
  static onSendDataToFlutter = "onSendDataToFlutter";
  static onTokenWillExpire = "onTokenWillExpire";
  static onTokenDidExpire = "onTokenDidExpire";

  /// EMContactManager methods
  static addContact = "addContact";
  static deleteContact = "deleteContact";
  static getAllContactsFromServer = "getAllContactsFromServer";
  static getAllContactsFromDB = "getAllContactsFromDB";
  static addUserToBlockList = "addUserToBlockList";
  static removeUserFromBlockList = "removeUserFromBlockList";
  static getBlockListFromServer = "getBlockListFromServer";
  static getBlockListFromDB = "getBlockListFromDB";
  static acceptInvitation = "acceptInvitation";
  static declineInvitation = "declineInvitation";
  static getSelfIdsOnOtherPlatform = "getSelfIdsOnOtherPlatform";
  static getAllContacts = "getAllContacts";
  static setContactRemark = "setContactRemark";
  static getContact = "getContact";
  static fetchAllContacts = "fetchAllContacts";
  static fetchContacts = "fetchContacts";

  static onContactChanged = "onContactChanged";

  /// EMChatManager methods
  static sendMessage = "sendMessage";
  static resendMessage = "resendMessage";
  static ackMessageRead = "ackMessageRead";
  static ackGroupMessageRead = "ackGroupMessageRead";
  static ackConversationRead = "ackConversationRead";
  static recallMessage = "recallMessage";
  static getConversation = "getConversation";
  static getThreadConversation = "getThreadConversation";
  static markAllChatMsgAsRead = "markAllChatMsgAsRead";
  static getUnreadMessageCount = "getUnreadMessageCount";
  static updateChatMessage = "updateChatMessage";
  static downloadAttachment = "downloadAttachment";
  static downloadThumbnail = "downloadThumbnail";
  static downloadMessageAttachmentInCombine = "downloadMessageAttachmentInCombine";
  static downloadMessageThumbnailInCombine = "downloadMessageThumbnailInCombine";
  static importMessages = "importMessages";
  static loadAllConversations = "loadAllConversations";
  static getConversationsFromServer = "getConversationsFromServer";
  static deleteConversation = "deleteConversation";
  static fetchHistoryMessages = "fetchHistoryMessages";
  static fetchHistoryMessagesByOptions = "fetchHistoryMessagesByOptions";
  static searchChatMsgFromDB = "searchChatMsgFromDB";
  static getMessage = "getMessage";
  static asyncFetchGroupAcks = "asyncFetchGroupAcks";
  static deleteRemoteConversation = "deleteRemoteConversation";
  static deleteMessagesBeforeTimestamp = "deleteMessagesBeforeTimestamp";

  static translateMessage = "translateMessage";
  static fetchSupportedLanguages = "fetchSupportLanguages";

  static addReaction = "addReaction";
  static removeReaction = "removeReaction";
  static fetchReactionList = "fetchReactionList";
  static fetchReactionDetail = "fetchReactionDetail";
  static reportMessage = "reportMessage";
  static fetchConversationsFromServerWithPage = "fetchConversationsFromServerWithPage";
  static removeMessagesFromServerWithMsgIds = "removeMessagesFromServerWithMsgIds";
  static removeMessagesFromServerWithTs = "removeMessagesFromServerWithTs";

  static getConversationsFromServerWithCursor = "getConversationsFromServerWithCursor";
  static getPinnedConversationsFromServerWithCursor = "getPinnedConversationsFromServerWithCursor";
  static pinConversation = "pinConversation";
  static modifyMessage = "modifyMessage";
  static downloadAndParseCombineMessage = "downloadAndParseCombineMessage";
  /// EMChatManager listener
  static onMessagesReceived = "onMessagesReceived";
  static onCmdMessagesReceived = "onCmdMessagesReceived";
  static onMessagesRead = "onMessagesRead";
  static onGroupMessageRead = "onGroupMessageRead";
  static onReadAckForGroupMessageUpdated = "onReadAckForGroupMessageUpdated";
  static onMessagesDelivered = "onMessagesDelivered";
  static onMessagesRecalled = "onMessagesRecalled";

  static onConversationUpdate = "onConversationUpdate";
  static onConversationHasRead = "onConversationHasRead";

  static onMessageReactionDidChange = "messageReactionDidChange";
  static onMessageContentChanged = "onMessageContentChanged";


  /// EMMessage listener
  static onMessageProgressUpdate = "onMessageProgressUpdate";
  static onMessageError = "onMessageError";
  static onMessageSuccess = "onMessageSuccess";
  static onMessageReadAck = "onMessageReadAck";
  static onMessageDeliveryAck = "onMessageDeliveryAck";

  /// EMConversation
  static getUnreadMsgCount = "getUnreadMsgCount";
  static markAllMessagesAsRead = "markAllMessagesAsRead";
  static markMessageAsRead = "markMessageAsRead";
  static syncConversationExt = "syncConversationExt";
  static removeMessage = "removeMessage";
  static deleteMessageByIds = "deleteMessageByIds";
  static getLatestMessage = "getLatestMessage";
  static getLatestMessageFromOthers = "getLatestMessageFromOthers";
  static clearAllMessages = "clearAllMessages";

  static deleteMessagesWithTs = "deleteMessagesWithTs";
  static insertMessage = "insertMessage";
  static appendMessage = "appendMessage";
  static updateConversationMessage = "updateConversationMessage";
  static loadMsgWithId = "loadMsgWithId";
  static loadMsgWithStartId = "loadMsgWithStartId";
  static loadMsgWithKeywords = "loadMsgWithKeywords";
  static loadMsgWithMsgType = "loadMsgWithMsgType";
  static loadMsgWithTime = "loadMsgWithTime";
  static messageCount = "messageCount";
  static removeMsgFromServerWithMsgList = "removeMsgFromServerWithMsgList";
  static removeMsgFromServerWithTimeStamp = "removeMsgFromServerWithTimeStamp";

  // EMMessage method
  static getReactionList = "getReactionList";
  static groupAckCount = "groupAckCount";
  static getChatThread = "chatThread";

  // EMChatRoomManager
  static joinChatRoom = "joinChatRoom";
  static leaveChatRoom = "leaveChatRoom";
  static fetchPublicChatRoomsFromServer = "fetchPublicChatRoomsFromServer";
  static fetchChatRoomInfoFromServer = "fetchChatRoomInfoFromServer";
  static getChatRoom = "getChatRoom";
  static getAllChatRooms = "getAllChatRooms";
  static createChatRoom = "createChatRoom";
  static destroyChatRoom = "destroyChatRoom";
  static changeChatRoomSubject = "changeChatRoomSubject";
  static changeChatRoomDescription = "changeChatRoomDescription";
  static fetchChatRoomMembers = "fetchChatRoomMembers";
  static muteChatRoomMembers = "muteChatRoomMembers";
  static unMuteChatRoomMembers = "unMuteChatRoomMembers";
  static changeChatRoomOwner = "changeChatRoomOwner";
  static addChatRoomAdmin = "addChatRoomAdmin";
  static removeChatRoomAdmin = "removeChatRoomAdmin";
  static fetchChatRoomMuteList = "fetchChatRoomMuteList";
  static removeChatRoomMembers = "removeChatRoomMembers";
  static blockChatRoomMembers = "blockChatRoomMembers";
  static unBlockChatRoomMembers = "unBlockChatRoomMembers";
  static fetchChatRoomBlockList = "fetchChatRoomBlockList";
  static updateChatRoomAnnouncement = "updateChatRoomAnnouncement";
  static fetchChatRoomAnnouncement = "fetchChatRoomAnnouncement";

  static addMembersToChatRoomWhiteList = "addMembersToChatRoomWhiteList";
  static removeMembersFromChatRoomWhiteList = "removeMembersFromChatRoomWhiteList";
  static fetchChatRoomWhiteListFromServer = "fetchChatRoomWhiteListFromServer";
  static isMemberInChatRoomWhiteListFromServer = "isMemberInChatRoomWhiteListFromServer";

  static muteAllChatRoomMembers = "muteAllChatRoomMembers";
  static unMuteAllChatRoomMembers = "unMuteAllChatRoomMembers";
  static fetchChatRoomAttributes = "fetchChatRoomAttributes";
  static setChatRoomAttributes = "setChatRoomAttributes";
  static removeChatRoomAttributes = "removeChatRoomAttributes";

  // EMChatRoomManagerListener
  static chatRoomChange = "onChatRoomChanged";

  /// EMGroupManager
  static getGroupWithId = "getGroupWithId";
  static getJoinedGroups = "getJoinedGroups";
  static getJoinedGroupsFromServer = "getJoinedGroupsFromServer";
  static getPublicGroupsFromServer = "getPublicGroupsFromServer";
  static createGroup = "createGroup";
  static getGroupSpecificationFromServer = "getGroupSpecificationFromServer";
  static getGroupMemberListFromServer = "getGroupMemberListFromServer";
  static getGroupBlockListFromServer = "getGroupBlockListFromServer";
  static getGroupMuteListFromServer = "getGroupMuteListFromServer";
  static getGroupWhiteListFromServer = "getGroupWhiteListFromServer";
  static isMemberInWhiteListFromServer = "isMemberInWhiteListFromServer";
  static getGroupFileListFromServer = "getGroupFileListFromServer";
  static getGroupAnnouncementFromServer = "getGroupAnnouncementFromServer";
  static addMembers = "addMembers";
  static inviterUser = "inviterUser";
  static removeMembers = "removeMembers";
  static blockMembers = "blockMembers";
  static unblockMembers = "unblockMembers";
  static updateGroupSubject = "updateGroupSubject";
  static updateDescription = "updateDescription";
  static leaveGroup = "leaveGroup";
  static destroyGroup = "destroyGroup";
  static blockGroup = "blockGroup";
  static unblockGroup = "unblockGroup";
  static updateGroupOwner = "updateGroupOwner";
  static addAdmin = "addAdmin";
  static removeAdmin = "removeAdmin";
  static muteMembers = "muteMembers";
  static unMuteMembers = "unMuteMembers";
  static muteAllMembers = "muteAllMembers";
  static unMuteAllMembers = "unMuteAllMembers";
  static addWhiteList = "addWhiteList";
  static removeWhiteList = "removeWhiteList";
  static uploadGroupSharedFile = "uploadGroupSharedFile";
  static downloadGroupSharedFile = "downloadGroupSharedFile";
  static removeGroupSharedFile = "removeGroupSharedFile";
  static updateGroupAnnouncement = "updateGroupAnnouncement";
  static updateGroupExt = "updateGroupExt";
  static joinPublicGroup = "joinPublicGroup";
  static requestToJoinPublicGroup = "requestToJoinPublicGroup";
  static acceptJoinApplication = "acceptJoinApplication";
  static declineJoinApplication = "declineJoinApplication";
  static acceptInvitationFromGroup = "acceptInvitationFromGroup";
  static declineInvitationFromGroup = "declineInvitationFromGroup";
  static setMemberAttributesFromGroup = "setMemberAttributesFromGroup";
  static removeMemberAttributesFromGroup = "removeMemberAttributesFromGroup";
  static fetchMemberAttributesFromGroup = "fetchMemberAttributesFromGroup";
  static fetchMembersAttributesFromGroup = "fetchMembersAttributesFromGroup";
  static fetchJoinedGroupCount = "fetchJoinedGroupCount";

  /// EMGroupManagerListener
  static onGroupChanged = "onGroupChanged";

  /// EMPushManager
  static getImPushConfig = "getImPushConfig";
  static getImPushConfigFromServer = "getImPushConfigFromServer";
  static updateImPushStyle = "updateImPushStyle";
  static updatePushNickname = "updatePushNickname";
  static updateHMSPushToken = "updateHMSPushToken";
  static updateFCMPushToken = "updateFCMPushToken";
  static reportPushAction = "reportPushAction";
  static setConversationSilentMode = "setConversationSilentMode";
  static removeConversationSilentMode = "removeConversationSilentMode";
  static fetchConversationSilentMode = "fetchConversationSilentMode";
  static setSilentModeForAll = "setSilentModeForAll";
  static fetchSilentModeForAll = "fetchSilentModeForAll";
  static fetchSilentModeForConversations = "fetchSilentModeForConversations";
  static setPreferredNotificationLanguage = "setPreferredNotificationLanguage";
  static fetchPreferredNotificationLanguage = "fetchPreferredNotificationLanguage";
  static setPushTemplate = "setPushTemplate";
  static getPushTemplate = "getPushTemplate";

  /// EMUserInfoManager
  static updateOwnUserInfo = "updateOwnUserInfo";
  static updateOwnUserInfoWithType = "updateOwnUserInfoWithType";
  static fetchUserInfoById = "fetchUserInfoById";
  static fetchUserInfoByIdWithType = "fetchUserInfoByIdWithType";

  /// EMPresenceManager methods
  static presenceWithDescription = "publishPresenceWithDescription";
  static presenceSubscribe = "presenceSubscribe";
  static presenceUnsubscribe = "presenceUnsubscribe";
  static fetchSubscribedMembersWithPageNum = "fetchSubscribedMembersWithPageNum";
  static fetchPresenceStatus = "fetchPresenceStatus";

  /// EMPresenceManagerListener
  static onPresenceStatusChanged = "onPresenceStatusChanged";

  /// EMChatThreadManager methods
  static fetchChatThreadDetail = "fetchChatThreadDetail";
  static fetchJoinedChatThreads = "fetchJoinedChatThreads";
  static fetchChatThreadsWithParentId = "fetchChatThreadsWithParentId";
  static fetchJoinedChatThreadsWithParentId = "fetchJoinedChatThreadsWithParentId";
  static fetchChatThreadMember = "fetchChatThreadMember";
  static fetchLastMessageWithChatThreads = "fetchLastMessageWithChatThreads";
  static removeMemberFromChatThread = "removeMemberFromChatThread";
  static updateChatThreadSubject = "updateChatThreadSubject";
  static createChatThread = "createChatThread";
  static joinChatThread = "joinChatThread";
  static leaveChatThread = "leaveChatThread";
  static destroyChatThread = "destroyChatThread";

  // EMChatThreadManagerListener
  static onChatThreadCreate = "onChatThreadCreate";
  static onChatThreadUpdate = "onChatThreadUpdate";
  static onChatThreadDestroy = "onChatThreadDestroy";
  static onUserKickOutOfChatThread = "onUserKickOutOfChatThread";


  /// HandleAction
  static startCallback = "startCallback";


  /// 450
  static getPinInfo = "getPinInfo";
  static pinnedMessages = "pinnedMessages";
  static onMessagePinChanged = "onMessagePinChanged";
  static addRemoteAndLocalConversationsMark = "addRemoteAndLocalConversationsMark";
  static deleteRemoteAndLocalConversationsMark = "deleteRemoteAndLocalConversationsMark";
  static fetchConversationsByOptions = "fetchConversationsByOptions";
  static deleteAllMessageAndConversation = "deleteAllMessageAndConversation";
  static pinMessage = "pinMessage";
  static unpinMessage = "unpinMessage";
  static fetchPinnedMessages = "fetchPinnedMessages";

  // 460
  static onMessagesRecalledInfo = "onMessagesRecalledInfo";
  // 481
  static conversationRemindType = "conversationRemindType";
  static conversationSearchMsgsByOptions = "conversationSearchMsgsByOptions";
  static conversationGetLocalMessageCount = "conversationGetLocalMessageCount";

  static conversationDeleteServerMessageWithIds = "conversationDeleteServerMessageWithIds";
  static conversationDeleteServerMessageWithTime = "conversationDeleteServerMessageWithTime";
  static searchMsgsByOptions = "searchMsgsByOptions";
  static syncSilentModels = "syncSilentModels";
  static clearAllGroupsFromDB = "clearAllGroupsFromDB";
  static updateUsingHttpsOnlySetting =
    "updateUsingHttpsOnlySetting";
  static updateLoginExtensionInfo = "updateLoginExtensionInfo";
  static updateDeleteMessagesWhenLeaveGroupSetting =
    "updateDeleteMessagesWhenLeaveGroupSetting";
  static updateDeleteMessageWhenLeaveRoomSetting =
    "updateDeleteMessageWhenLeaveRoomSetting";
  static updateRoomOwnerCanLeaveSetting =
    "updateRoomOwnerCanLeaveSetting";
  static updateAutoAcceptGroupInvitationSetting =
    "updateAutoAcceptGroupInvitationSetting";
  static acceptInvitationAlways = "acceptInvitationAlways";
  static updateAutoDownloadAttachmentThumbnailSetting =
    "updateAutoDownloadAttachmentThumbnailSetting";
  static updateRequireAckSetting = "updateRequireAckSetting";
  static updateDeliveryAckSetting = "updateDeliveryAckSetting";
  static updateSortMessageByServerTimeSetting =
    "updateSortMessageByServerTimeSetting";
  static updateMessagesReceiveCallbackIncludeSendSetting =
    "updateMessagesReceiveCallbackIncludeSendSetting";
  static updateRegradeMessagesSetting =
    "updateRegradeMessagesSetting";

  static bindDeviceToken = "bindDeviceToken";

  // 4.10
  static onOfflineMessageSyncStart = "onOfflineMessageSyncStart";
  static onOfflineMessageSyncFinish = "onOfflineMessageSyncFinish";
  static getMessageCount = "getMessageCount";
  static isMemberInGroupMuteList = "isMemberInGroupMuteList";

  // shengwang
  static changeAppId = "changeAppId";
}