//
//  EMSDKMethod.h
//
//
//  Created by 杜洁鹏 ChatOn 2019/10/8.
//

#import <Foundation/Foundation.h>

#pragma mark - EMClientWrapper
static NSString *const ChatInit = @"init";
static NSString *const ChatCreateAccount = @"createAccount";
static NSString *const ChatLogin = @"login";
static NSString *const ChatRenewToken = @"renewToken";
static NSString *const ChatLoginWithAgoraToken = @"loginWithAgoraToken";
static NSString *const ChatLogout = @"logout";
static NSString *const ChatChangeAppKey = @"changeAppKey";

static NSString *const ChatUploadLog = @"uploadLog";
static NSString *const ChatCompressLogs = @"compressLogs";
static NSString *const ChatKickDevice = @"kickDevice";
static NSString *const ChatKickAllDevices = @"kickAllDevices";
static NSString *const ChatGetLoggedInDevicesFromServer = @"getLoggedInDevicesFromServer";

static NSString *const ChatGetToken = @"getToken";
static NSString *const ChatGetCurrentUser = @"getCurrentUser";
static NSString *const ChatIsLoggedInBefore = @"isLoggedInBefore";
static NSString *const ChatIsConnected = @"isConnected";

static NSString *const ChatOnMultiDeviceGroupEvent = @"onMultiDeviceGroupEvent";
static NSString *const ChatOnMultiDeviceContactEvent = @"onMultiDeviceContactEvent";
static NSString *const ChatOnMultiDeviceThreadEvent = @"onMultiDeviceThreadEvent";
static NSString *const ChatOnMultiDeviceRemoveMessagesEvent = @"onMultiDeviceRemoveMessagesEvent";
static NSString *const ChatOnMultiDevicesConversationEvent = @"onMultiDevicesConversationEvent";

#pragma mark - EMClientDelegate
static NSString *const ChatOnConnected = @"onConnected";
static NSString *const ChatOnDisconnected = @"onDisconnected";
static NSString *const ChatOnUserDidLoginFromOtherDevice = @"onUserDidLoginFromOtherDevice";
static NSString *const ChatOnUserDidRemoveFromServer = @"onUserDidRemoveFromServer";
static NSString *const ChatOnUserDidForbidByServer = @"onUserDidForbidByServer";
static NSString *const ChatOnUserDidChangePassword = @"onUserDidChangePassword";
static NSString *const ChatOnUserDidLoginTooManyDevice = @"onUserDidLoginTooManyDevice";
static NSString *const ChatOnUserKickedByOtherDevice = @"onUserKickedByOtherDevice";
static NSString *const ChatOnUserAuthenticationFailed = @"onUserAuthenticationFailed";

static NSString *const ChatSendDataToFlutter = @"onSendDataToFlutter";
static NSString *const ChatOnTokenWillExpire = @"onTokenWillExpire";
static NSString *const ChatOnTokenDidExpire = @"onTokenDidExpire";
static NSString *const ChatOnAppActiveNumberReachLimit = @"onAppActiveNumberReachLimit";

#pragma mark - EMContactManagerWrapper
static NSString *const ChatAddContact = @"addContact";
static NSString *const ChatDeleteContact = @"deleteContact";
static NSString *const ChatGetAllContactsFromServer = @"getAllContactsFromServer";
static NSString *const ChatGetAllContactsFromDB = @"getAllContactsFromDB";
static NSString *const ChatAddUserToBlockList = @"addUserToBlockList";
static NSString *const ChatRemoveUserFromBlockList = @"removeUserFromBlockList";
static NSString *const ChatGetBlockListFromServer = @"getBlockListFromServer";
static NSString *const ChatGetBlockListFromDB = @"getBlockListFromDB";
static NSString *const ChatAcceptInvitation = @"acceptInvitation";
static NSString *const ChatDeclineInvitation = @"declineInvitation";
static NSString *const ChatGetSelfIdsOnOtherPlatform = @"getSelfIdsOnOtherPlatform";

#pragma mark - EMContactDelegate
static NSString *const ChatOnContactChanged = @"onContactChanged";

#pragma mark - EMChatManagerWrapper
static NSString *const ChatSendMessage = @"sendMessage";
static NSString *const ChatResendMessage = @"resendMessage";
static NSString *const ChatAckMessageRead = @"ackMessageRead";
static NSString *const ChatAckGroupMessageRead = @"ackGroupMessageRead";
static NSString *const ChatAckConversationRead = @"ackConversationRead";
static NSString *const ChatRecallMessage = @"recallMessage";
static NSString *const ChatGetConversation = @"getConversation";
static NSString *const ChatGetThreadConversation = @"getThreadConversation";
static NSString *const ChatMarkAllChatMsgAsRead = @"markAllChatMsgAsRead";
static NSString *const ChatGetUnreadMessageCount = @"getUnreadMessageCount";
static NSString *const ChatUpdateChatMessage = @"updateChatMessage";
static NSString *const ChatDownloadAttachment = @"downloadAttachment";
static NSString *const ChatDownloadThumbnail = @"downloadThumbnail";
static NSString *const ChatImportMessages = @"importMessages";
static NSString *const ChatLoadAllConversations = @"loadAllConversations";
static NSString *const ChatGetConversationsFromServer = @"getConversationsFromServer";

static NSString *const ChatDeleteConversation = @"deleteConversation";
static NSString *const ChatFetchHistoryMessages = @"fetchHistoryMessages";
static NSString *const ChatFetchHistoryMessagesByOptions = @"fetchHistoryMessagesByOptions";
static NSString *const ChatSearchChatMsgFromDB = @"searchChatMsgFromDB";
static NSString *const ChatGetMessage = @"getMessage";
static NSString *const ChatAsyncFetchGroupAcks = @"asyncFetchGroupAcks";
static NSString *const ChatDeleteRemoteConversation = @"deleteRemoteConversation";
static NSString *const ChatDeleteMessagesBeforeTimestamp = @"deleteMessagesBeforeTimestamp";

static NSString *const ChatTranslateMessage = @"translateMessage";
static NSString *const ChatFetchSupportedLanguages = @"fetchSupportLanguages";

static NSString *const ChatAddReaction = @"addReaction";
static NSString *const ChatRemoveReaction = @"removeReaction";
static NSString *const ChatFetchReactionList = @"fetchReactionList";
static NSString *const ChatFetchReactionDetail = @"fetchReactionDetail";
static NSString *const ChatReportMessage = @"reportMessage";
static NSString *const ChatFetchConversationsFromServerWithPage = @"fetchConversationsFromServerWithPage";
static NSString *const ChatRemoveMessagesFromServerWithMsgIds = @"removeMessagesFromServerWithMsgIds";
static NSString *const ChatRemoveMessagesFromServerWithTs = @"removeMessagesFromServerWithTs";

static NSString *const GetConversationsFromServerWithCursor = @"getConversationsFromServerWithCursor";
static NSString *const GetPinnedConversationsFromServerWithCursor = @"getPinnedConversationsFromServerWithCursor";
static NSString *const PinConversation = @"pinConversation";
static NSString *const modifyMessage = @"modifyMessage";
static NSString *const downloadAndParseCombineMessage = @"downloadAndParseCombineMessage";

#pragma mark - EMChatManagerDelegate
static NSString *const ChatOnMessagesReceived = @"onMessagesReceived";
static NSString *const ChatOnCmdMessagesReceived = @"onCmdMessagesReceived";
static NSString *const ChatOnMessagesRead = @"onMessagesRead";
static NSString *const ChatOnGroupMessageRead = @"onGroupMessageRead";
static NSString *const ChatOnReadAckForGroupMessageUpdated = @"onReadAckForGroupMessageUpdated";
static NSString *const ChatOnMessagesDelivered = @"onMessagesDelivered";
static NSString *const ChatOnMessagesRecalled = @"onMessagesRecalled";

static NSString *const ChatOnConversationUpdate = @"onConversationUpdate";
static NSString *const ChatOnConversationHasRead = @"onConversationHasRead";

static NSString *const ChatOnMessageReactionDidChange = @"messageReactionDidChange";

static NSString *const onMessageContentChanged = @"onMessageContentChanged";

#pragma mark - EMMessageListener
static NSString *const ChatOnMessageProgressUpdate = @"onMessageProgressUpdate";
static NSString *const ChatOnMessageSuccess = @"onMessageSuccess";
static NSString *const ChatOnMessageError = @"onMessageError";
static NSString *const ChatOnMessageReadAck = @"onMessageReadAck";
static NSString *const ChatOnMessageDeliveryAck = @"onMessageDeliveryAck";


#pragma mark - EMConversationWrapper

static NSString *const ChatGetUnreadMsgCount = @"getUnreadMsgCount";
static NSString *const ChatMarkAllMsgsAsRead = @"markAllMessagesAsRead";
static NSString *const ChatMarkMsgAsRead = @"markMessageAsRead";
static NSString *const ChatSyncConversationExt = @"syncConversationExt";
static NSString *const ChatRemoveMsg = @"removeMessage";
static NSString *const ChatGetLatestMsg = @"getLatestMessage";
static NSString *const ChatGetLatestMsgFromOthers = @"getLatestMessageFromOthers";
static NSString *const ChatClearAllMsg = @"clearAllMessages";
static NSString *const ChatDeleteMessagesWithTs = @"deleteMessagesWithTs";
static NSString *const ChatInsertMsg = @"insertMessage";
static NSString *const ChatAppendMsg = @"appendMessage";
static NSString *const ChatUpdateConversationMsg = @"updateConversationMessage";

static NSString *const ChatLoadMsgWithId = @"loadMsgWithId";
static NSString *const ChatLoadMsgWithStartId = @"loadMsgWithStartId";
static NSString *const ChatLoadMsgWithKeywords = @"loadMsgWithKeywords";
static NSString *const ChatLoadMsgWithMsgType = @"loadMsgWithMsgType";
static NSString *const ChatLoadMsgWithTime = @"loadMsgWithTime";
static NSString *const ChatConversationMessageCount = @"messageCount";
static NSString *const ChatRemoveMsgFromServerWithMsgList = @"removeMsgFromServerWithMsgList";
static NSString *const ChatRemoveMsgFromServerWithTimeStamp = @"removeMsgFromServerWithTimeStamp";

#pragma mark - EMChatMessageWrapper
static NSString *const ChatGetReactionList = @"getReactionList";
static NSString *const ChatGroupAckCount = @"groupAckCount";
static NSString *const ChatThread = @"chatThread";


#pragma mark - EMChatroomManagerWrapper

static NSString *const ChatJoinChatRoom = @"joinChatRoom";
static NSString *const ChatLeaveChatRoom = @"leaveChatRoom";
static NSString *const ChatGetChatroomsFromServer = @"fetchPublicChatRoomsFromServer";
static NSString *const ChatFetchChatRoomFromServer = @"fetchChatRoomInfoFromServer";
static NSString *const ChatGetChatRoom = @"getChatRoom";
static NSString *const ChatGetAllChatRooms = @"getAllChatRooms";
static NSString *const ChatCreateChatRoom = @"createChatRoom";
static NSString *const ChatDestroyChatRoom = @"destroyChatRoom";
static NSString *const ChatChatRoomUpdateSubject = @"changeChatRoomSubject";
static NSString *const ChatChatRoomUpdateDescription = @"changeChatRoomDescription";
static NSString *const ChatGetChatroomMemberListFromServer = @"fetchChatRoomMembers";
static NSString *const ChatChatRoomMuteMembers = @"muteChatRoomMembers";
static NSString *const ChatChatRoomUnmuteMembers = @"unMuteChatRoomMembers";
static NSString *const ChatChangeChatRoomOwner = @"changeChatRoomOwner";
static NSString *const ChatChatRoomAddAdmin = @"addChatRoomAdmin";
static NSString *const ChatChatRoomRemoveAdmin = @"removeChatRoomAdmin";
static NSString *const ChatGetChatroomMuteListFromServer = @"fetchChatRoomMuteList";
static NSString *const ChatChatRoomRemoveMembers = @"removeChatRoomMembers";
static NSString *const ChatChatRoomBlockMembers = @"blockChatRoomMembers";
static NSString *const ChatChatRoomUnblockMembers = @"unBlockChatRoomMembers";
static NSString *const ChatFetchChatroomBlockListFromServer = @"fetchChatRoomBlockList";
static NSString *const ChatUpdateChatRoomAnnouncement = @"updateChatRoomAnnouncement";
static NSString *const ChatFetchChatroomAnnouncement = @"fetchChatRoomAnnouncement";

static NSString *const ChatAddMembersToChatRoomWhiteList = @"addMembersToChatRoomWhiteList";
static NSString *const ChatRemoveMembersFromChatRoomWhiteList = @"removeMembersFromChatRoomWhiteList";
static NSString *const ChatFetchChatRoomWhiteListFromServer = @"fetchChatRoomWhiteListFromServer";
static NSString *const ChatIsMemberInChatRoomWhiteListFromServer = @"isMemberInChatRoomWhiteListFromServer";

static NSString *const ChatMuteAllChatRoomMembers = @"muteAllChatRoomMembers";
static NSString *const ChatUnMuteAllChatRoomMembers = @"unMuteAllChatRoomMembers";
static NSString *const ChatFetchChatRoomAttributes = @"fetchChatRoomAttributes";
static NSString *const ChatSetChatRoomAttributes = @"setChatRoomAttributes";
static NSString *const ChatRemoveChatRoomAttributes  = @"removeChatRoomAttributes";

static NSString *const ChatChatroomChanged = @"onChatRoomChanged";

#pragma mark - EMGroupManagerWrapper

static NSString *const ChatGetGroupWithId = @"getGroupWithId";
static NSString *const ChatGetJoinedGroups = @"getJoinedGroups";
static NSString *const ChatGetJoinedGroupsFromServer = @"getJoinedGroupsFromServer";
static NSString *const ChatGetPublicGroupsFromServer = @"getPublicGroupsFromServer";
static NSString *const ChatCreateGroup = @"createGroup";
static NSString *const ChatGetGroupSpecificationFromServer = @"getGroupSpecificationFromServer";
static NSString *const ChatGetGroupMemberListFromServer = @"getGroupMemberListFromServer";
static NSString *const ChatGetGroupBlockListFromServer = @"getGroupBlockListFromServer";
static NSString *const ChatGetGroupMuteListFromServer = @"getGroupMuteListFromServer";
static NSString *const ChatGetGroupWhiteListFromServer = @"getGroupWhiteListFromServer";
static NSString *const ChatIsMemberInWhiteListFromServer = @"isMemberInWhiteListFromServer";
static NSString *const ChatGetGroupFileListFromServer = @"getGroupFileListFromServer";
static NSString *const ChatGetGroupAnnouncementFromServer = @"getGroupAnnouncementFromServer";
static NSString *const ChatAddMembers = @"addMembers";
static NSString *const ChatInviterUser = @"inviterUser";
static NSString *const ChatRemoveMembers = @"removeMembers";
static NSString *const ChatBlockMembers = @"blockMembers";
static NSString *const ChatUnblockMembers = @"unblockMembers";
static NSString *const ChatUpdateGroupSubject = @"updateGroupSubject";
static NSString *const ChatUpdateDescription = @"updateDescription";
static NSString *const ChatLeaveGroup = @"leaveGroup";
static NSString *const ChatDestroyGroup = @"destroyGroup";
static NSString *const ChatBlockGroup = @"blockGroup";
static NSString *const ChatUnblockGroup = @"unblockGroup";
static NSString *const ChatUpdateGroupOwner = @"updateGroupOwner";
static NSString *const ChatAddAdmin = @"addAdmin";
static NSString *const ChatRemoveAdmin = @"removeAdmin";
static NSString *const ChatMuteMembers = @"muteMembers";
static NSString *const ChatUnMuteMembers = @"unMuteMembers";
static NSString *const ChatMuteAllMembers = @"muteAllMembers";
static NSString *const ChatUnMuteAllMembers = @"unMuteAllMembers";
static NSString *const ChatAddWhiteList = @"addWhiteList";
static NSString *const ChatRemoveWhiteList = @"removeWhiteList";
static NSString *const ChatUploadGroupSharedFile = @"uploadGroupSharedFile";
static NSString *const ChatDownloadGroupSharedFile = @"downloadGroupSharedFile";
static NSString *const ChatRemoveGroupSharedFile = @"removeGroupSharedFile";
static NSString *const ChatUpdateGroupAnnouncement = @"updateGroupAnnouncement";
static NSString *const ChatUpdateGroupExt = @"updateGroupExt";
static NSString *const ChatJoinPublicGroup = @"joinPublicGroup";
static NSString *const ChatRequestToJoinPublicGroup = @"requestToJoinPublicGroup";
static NSString *const ChatAcceptJoinApplication = @"acceptJoinApplication";
static NSString *const ChatDeclineJoinApplication = @"declineJoinApplication";
static NSString *const ChatAcceptInvitationFromGroup = @"acceptInvitationFromGroup";
static NSString *const ChatDeclineInvitationFromGroup = @"declineInvitationFromGroup";
static NSString *const ChatSetMemberAttributesFromGroup = @"setMemberAttributesFromGroup";
static NSString *const ChatRemoveMemberAttributesFromGroup = @"removeMemberAttributesFromGroup";
static NSString *const ChatFetchMemberAttributesFromGroup = @"fetchMemberAttributesFromGroup";
static NSString *const ChatFetchMembersAttributesFromGroup = @"fetchMembersAttributesFromGroup";

static NSString *const ChatOnGroupChanged = @"onGroupChanged";

#pragma mark - EMPushManagerWrapper
static NSString *const ChatGetImPushConfig = @"getImPushConfig";
static NSString *const ChatGetImPushConfigFromServer = @"getImPushConfigFromServer";
static NSString *const ChatEnablePush = @"enableOfflinePush";
static NSString *const ChatDisablePush = @"disableOfflinePush";
static NSString *const ChatUpdateImPushStyle = @"updateImPushStyle";
static NSString *const ChatUpdatePushNickname = @"updatePushNickname";

static NSString *const ChatUpdateGroupPushService = @"updateGroupPushService";
static NSString *const ChatGetNoPushGroups = @"getNoPushGroups";
static NSString *const ChatUpdateUserPushService = @"updateUserPushService";
static NSString *const ChatGetNoPushUsers = @"getNoPushUsers";
static NSString *const ChatBindDeviceToken = @"updateAPNsPushToken";
static NSString *const UpdateFCMPushToken = @"updateFCMPushToken";


static NSString *const ChatReportPushAction = @"reportPushAction";
static NSString *const ChatSetConversationSilentMode = @"setConversationSilentMode";
static NSString *const ChatRemoveConversationSilentMode = @"removeConversationSilentMode";
static NSString *const ChatFetchConversationSilentMode = @"fetchConversationSilentMode";
static NSString *const ChatSetSilentModeForAll = @"setSilentModeForAll";
static NSString *const ChatFetchSilentModeForAll = @"fetchSilentModeForAll";
static NSString *const ChatFetchSilentModeForConversations = @"fetchSilentModeForConversations";
static NSString *const ChatSetPreferredNotificationLanguage = @"setPreferredNotificationLanguage";
static NSString *const ChatFetchPreferredNotificationLanguage = @"fetchPreferredNotificationLanguage";
static NSString *const ChatSetPushTemplate = @"setPushTemplate";
static NSString *const ChatGetPushTemplate = @"getPushTemplate";

#pragma mark - EMUserInfoManagerWrapper
static NSString *const ChatUpdateOwnUserInfo = @"updateOwnUserInfo";
static NSString *const ChatUpdateOwnUserInfoWithType = @"updateOwnUserInfoWithType";
static NSString *const ChatFetchUserInfoById = @"fetchUserInfoById";
static NSString *const ChatFetchUserInfoByIdWithType = @"fetchUserInfoByIdWithType";


#pragma make - EMPresenceManagerWrapper
static NSString *const ChatPublishPresenceWithDescription = @"publishPresenceWithDescription";
static NSString *const ChatPresenceSubscribe = @"presenceSubscribe";
static NSString *const ChatPresenceUnsubscribe = @"presenceUnsubscribe";
static NSString *const ChatFetchSubscribedMembersWithPageNum = @"fetchSubscribedMembersWithPageNum";
static NSString *const ChatFetchPresenceStatus = @"fetchPresenceStatus";


#pragma mark - EMPresenceManagerDelegate
static NSString *const ChatOnPresenceStatusChanged = @"onPresenceStatusChanged";

#pragma mark - EMChatThreadManager methods
static NSString *const ChatFetchChatThreadDetail = @"fetchChatThreadDetail";
static NSString *const ChatFetchJoinedChatThreads = @"fetchJoinedChatThreads";
static NSString *const ChatFetchChatThreadsWithParentId = @"fetchChatThreadsWithParentId";
static NSString *const ChatFetchJoinedChatThreadsWithParentId = @"fetchJoinedChatThreadsWithParentId";
static NSString *const ChatFetchChatThreadMember = @"fetchChatThreadMember";
static NSString *const ChatFetchLastMessageWithChatThreads = @"fetchLastMessageWithChatThreads";
static NSString *const ChatRemoveMemberFromChatThread = @"removeMemberFromChatThread";
static NSString *const ChatUpdateChatThreadSubject = @"updateChatThreadSubject";
static NSString *const ChatCreateChatThread = @"createChatThread";
static NSString *const ChatJoinChatThread = @"joinChatThread";
static NSString *const ChatLeaveChatThread = @"leaveChatThread";
static NSString *const ChatDestroyChatThread = @"destroyChatThread";

#pragma mark - EMChatThreadManagerListener
static NSString *const onChatThreadCreate = @"onChatThreadCreate";
static NSString *const onChatThreadUpdate = @"onChatThreadUpdate";
static NSString *const onChatThreadDestroy = @"onChatThreadDestroy";
static NSString *const onUserKickOutOfChatThread = @"onUserKickOutOfChatThread";

#pragma mark - HandleAction
static NSString *const ChatStartCallback = @"startCallback";


