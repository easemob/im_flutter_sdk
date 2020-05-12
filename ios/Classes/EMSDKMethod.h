//
//  EMSDKMethod.h
//  
//
//  Created by 杜洁鹏 on 2019/10/8.
//

#import <Foundation/Foundation.h>


static NSString * const EMMethodKeyDebugLog = @"debugLog";
static NSString * const EMMethodKeyErrorLog = @"errorLog";


#pragma mark - EMClientWrapper

static NSString * const EMMethodKeyInit = @"init";
static NSString * const EMMethodKeyCreateAccount = @"createAccount";
static NSString * const EMMethodKeyLogin = @"login";
static NSString * const EMMethodKeyLoginWithToken = @"loginWithToken";
static NSString * const EMMethodKeyLogout = @"logout";
static NSString * const EMMethodKeyChangeAppKey = @"changeAppKey";
static NSString * const EMMethodKeyIsLoggedInBefore = @"isLoggedInBefore";
static NSString * const EMMethodKeySetDebugMode = @"setDebugMode";
static NSString * const EMMethodKeyUpdateCurrentUserNick = @"updateCurrentUserNick";
static NSString * const EMMethodKeyUploadLog = @"uploadLog";
static NSString * const EMMethodKeyCompressLogs = @"compressLogs";
static NSString * const EMMethodKeyKickDevice = @"kickDevice";
static NSString * const EMMethodKeyKickAllDevices = @"kickAllDevices";
static NSString * const EMMethodKeyGetLoggedInDevicesFromServer = @"getLoggedInDevicesFromServer";
static NSString * const EMMethodKeyGetCurrentUser = @"getCurrentUser";


static NSString * const EMMethodKeyOnConnected = @"onConnected";
static NSString * const EMMethodKeyOnDisconnected = @"onDisconnected";
static NSString * const EMMethodKeyOnMultiDeviceEvent = @"onMultiDeviceEvent";

#pragma mark - EMContactManagerWrapper

static NSString * const EMMethodKeyAddContact = @"addContact";
static NSString * const EMMethodKeyDeleteContact = @"deleteContact";
static NSString * const EMMethodKeyGetAllContactsFromServer = @"getAllContactsFromServer";
static NSString * const EMMethodKeyAddUserToBlackList = @"addUserToBlackList";
static NSString * const EMMethodKeyRemoveUserFromBlackList = @"removeUserFromBlackList";
static NSString * const EMMethodKeyGetBlackListFromServer = @"getBlackListFromServer";
static NSString * const EMMethodKeyAcceptInvitation = @"acceptInvitation";
static NSString * const EMMethodKeyDeclineInvitation = @"declineInvitation";
static NSString * const EMMethodKeyGetSelfIdsOnOtherPlatform = @"getSelfIdsOnOtherPlatform";

static NSString * const EMMethodKeyOnContactChanged = @"onContactChanged";

#pragma mark - EMChatManagerWrapper

static NSString * const EMMethodKeySendMessage = @"sendMessage";
static NSString * const EMMethodKeyAckMessageRead = @"ackMessageRead";
static NSString * const EMMethodKeyRecallMessage = @"recallMessage";
static NSString * const EMMethodKeyGetMessage = @"getMessage";
static NSString * const EMMethodKeyGetConversation = @"getConversation";
static NSString * const EMMethodKeyMarkAllChatMsgAsRead = @"markAllChatMsgAsRead";
static NSString * const EMMethodKeyGetUnreadMessageCount = @"getUnreadMessageCount";
static NSString * const EMMethodKeySaveMessage = @"saveMessage";
static NSString * const EMMethodKeyUpdateChatMessage = @"updateChatMessage";
static NSString * const EMMethodKeyDownloadAttachment = @"downloadAttachment";
static NSString * const EMMethodKeyDownloadThumbnail = @"downloadThumbnail";
static NSString * const EMMethodKeyImportMessages = @"importMessages";
static NSString * const EMMethodKeyGetConversationsByType = @"getConversationsByType";
static NSString * const EMMethodKeyDownloadFile = @"downloadFile";
static NSString * const EMMethodKeyGetAllConversations = @"getAllConversations";
static NSString * const EMMethodKeyLoadAllConversations = @"loadAllConversations";
static NSString * const EMMethodKeyDeleteConversation = @"deleteConversation";
static NSString * const EMMethodKeySetVoiceMessageListened = @"setVoiceMessageListened";
static NSString * const EMMethodKeyUpdateParticipant = @"updateParticipant";
static NSString * const EMMethodKeyFetchHistoryMessages = @"fetchHistoryMessages";
static NSString * const EMMethodKeySearchChatMsgFromDB = @"searchChatMsgFromDB";
static NSString * const EMMethodKeyGetCursor = @"getCursor";

static NSString * const EMMethodKeyOnMessageReceived = @"onMessageReceived";
static NSString * const EMMethodKeyOnCmdMessageReceived = @"onCmdMessageReceived";
static NSString * const EMMethodKeyOnMessageRead = @"onMessageRead";
static NSString * const EMMethodKeyOnMessageDelivered = @"onMessageDelivered";
static NSString * const EMMethodKeyOnMessageRecalled = @"onMessageRecalled";
static NSString * const EMMethodKeyOnMessageChanged = @"onMessageChanged";
static NSString * const EMMethodKeyOnConversationUpdate = @"onConversationUpdate";

static NSString * const EMMethodKeyOnMessageStatusOnProgress = @"onMessageStatusOnProgress";

static NSString * const EMMethodKeyAddMessageListener = @"addMessageListener";

#pragma mark - EMConversationWrapper

static NSString * const EMMethodKeyGetUnreadMsgCount = @"getUnreadMsgCount";
static NSString * const EMMethodKeyMarkAllMessagesAsRead = @"markAllMessagesAsRead";
static NSString * const EMMethodKeyLoadMoreMsgFromDB = @"loadMoreMsgFromDB";
static NSString * const EMMethodKeySearchConversationMsgFromDB = @"searchConversationMsgFromDB";
static NSString * const EMMethodKeySearchConversationMsgFromDBByType = @"searchConversationMsgFromDBByType";
static NSString * const EMMethodKeyLoadMessages = @"loadMessages";
static NSString * const EMMethodKeyMarkMessageAsRead = @"markMessageAsRead";
static NSString * const EMMethodKeyRemoveMessage = @"removeMessage";
static NSString * const EMMethodKeyGetLastMessage = @"getLastMessage";
static NSString * const EMMethodKeyGetLatestMessageFromOthers = @"getLatestMessageFromOthers";
static NSString * const EMMethodKeyClear = @"clear";
static NSString * const EMMethodKeyClearAllMessages = @"clearAllMessages";
static NSString * const EMMethodKeyInsertMessage = @"insertMessage";
static NSString * const EMMethodKeyAppendMessage = @"appendMessage";
static NSString * const EMMethodKeyUpdateConversationMessage = @"updateConversationMessage";
static NSString * const EMMethodKeyGetMessageAttachmentPath = @"getMessageAttachmentPath";

#pragma mark - EMChatroomManagerWrapper

static NSString * const EMMethodKeyJoinChatRoom = @"joinChatRoom";
static NSString * const EMMethodKeyLeaveChatRoom = @"leaveChatRoom";
static NSString * const EMMethodKeyGetChatroomsFromServer = @"fetchPublicChatRoomsFromServer";
static NSString * const EMMethodKeyGetChatroomSpecificationFromServer = @"fetchChatRoomFromServer";
static NSString * const EMMethodKeyGetChatRoom = @"getChatRoom";
static NSString * const EMMethodKeyGetAllChatRooms = @"getAllChatRooms";
static NSString * const EMMethodKeyCreateChatRoom = @"createChatRoom";
static NSString * const EMMethodKeyDestroyChatRoom = @"destroyChatRoom";
static NSString * const EMMethodKeyuChatRoomUpdateSubject = @"changeChatRoomSubject";
static NSString * const EMMethodKeyChatRoomUpdateDescription = @"changeChatRoomDescription";
static NSString * const EMMethodKeyGetChatroomMemberListFromServer = @"fetchChatRoomMembers";
static NSString * const EMMethodKeyChatRoomMuteMembers = @"muteChatRoomMembers";
static NSString * const EMMethodKeyChatRoomUnmuteMembers = @"unMuteChatRoomMembers";
static NSString * const EMMethodKeyChangeChatRoomOwner = @"changeChatRoomOwner";
static NSString * const EMMethodKeyChatRoomAddAdmin = @"addChatRoomAdmin";
static NSString * const EMMethodKeyChatRoomRemoveAdmin = @"removeChatRoomAdmin";
static NSString * const EMMethodKeyGetChatroomMuteListFromServer = @"fetchChatRoomMuteList";
static NSString * const EMMethodKeyChatRoomRemoveMembers = @"removeChatRoomMembers";
static NSString * const EMMethodKeyChatRoomBlockMembers = @"blockChatRoomMembers";
static NSString * const EMMethodKeyChatRoomUnblockMembers = @"unBlockChatRoomMembers";
static NSString * const EMMethodKeyGetChatroomBlacklistFromServer = @"fetchChatRoomBlackList";
static NSString * const EMMethodKeyUpdateChatRoomAnnouncement = @"updateChatRoomAnnouncement";
static NSString * const EMMethodKeyGetChatroomAnnouncement = @"fetchChatRoomAnnouncement";

static NSString * const EMMethodKeyChatroomChanged = @"onChatroomChanged";

#pragma mark - EMGroupManagerWrapper

static NSString * const EMMethodKeyGetJoinedGroups = @"getAllGroups";
// 有疑议
static NSString * const EMMethodKeyGetGroupsWithoutPushNotification = @"getGroupsWithoutPushNotification";
static NSString * const EMMethodKeyGetGroup = @"getGroup";
// 有疑议
static NSString * const EMMethodKeyLoadAllGroups = @"loadAllGroups";
static NSString * const EMMethodKeyGetJoinedGroupsFromServer = @"getJoinedGroupsFromServer";
static NSString * const EMMethodKeyGetPublicGroupsFromServer = @"getPublicGroupsFromServer";
static NSString * const EMMethodKeyCreateGroup = @"createGroup";
static NSString * const EMMethodKeyGetGroupSpecificationFromServer = @"getGroupFromServer";
static NSString * const EMMethodKeyGetGroupMemberListFromServer = @"fetchGroupMembers";
static NSString * const EMMethodKeyGetGroupBlacklistFromServer = @"fetchGroupBlackList";
static NSString * const EMMethodKeyGetGroupMuteListFromServer = @"fetchGroupMuteList";
static NSString * const EMMethodKeyGetGroupFileList = @"fetchGroupSharedFileList";
static NSString * const EMMethodKeyGetGroupAnnouncement = @"fetchGroupAnnouncement";
static NSString * const EMMethodKeyAddOccupants = @"inviteUser";
static NSString * const EMMethodKeyAddMembers = @"addUsersToGroup";
static NSString * const EMMethodKeyRemoveMembers = @"removeUserFromGroup";
static NSString * const EMMethodKeyBlockMembers = @"blockUser";
static NSString * const EMMethodKeyUnblockMembers = @"unblockUser";
static NSString * const EMMethodKeyUpdateGroupSubject = @"changeGroupName";
static NSString * const EMMethodKeyUpdateDescription = @"changeGroupDescription";
static NSString * const EMMethodKeyLeaveGroup = @"leaveGroup";
static NSString * const EMMethodKeyDestroyGroup = @"destroyGroup";
static NSString * const EMMethodKeyBlockGroup = @"blockGroupMessage";
static NSString * const EMMethodKeyUnblockGroup = @"unblockGroupMessage";
static NSString * const EMMethodKeyUpdateGroupOwner = @"changeOwner";
static NSString * const EMMethodKeyAddAdmin = @"addGroupAdmin";
static NSString * const EMMethodKeyRemoveAdmin = @"removeGroupAdmin";
static NSString * const EMMethodKeyMuteMembers = @"muteGroupMembers";
static NSString * const EMMethodKeyUnmuteMembers = @"unMuteGroupMembers";
static NSString * const EMMethodKeyUploadGroupSharedFile = @"uploadGroupSharedFile";
static NSString * const EMMethodKeyDownloadGroupSharedFile = @"downloadGroupSharedFile";
static NSString * const EMMethodKeyRemoveGroupSharedFile = @"deleteGroupSharedFile";
static NSString * const EMMethodKeyUpdateGroupAnnouncement = @"updateGroupAnnouncement";
static NSString * const EMMethodKeyUpdateGroupExt = @"updateGroupExtension";
static NSString * const EMMethodKeyJoinPublicGroup = @"joinGroup";
static NSString * const EMMethodKeyRequestToJoinPublicGroup = @"applyJoinToGroup";
static NSString * const EMMethodKeyApproveJoinGroupRequest = @"acceptApplication";
static NSString * const EMMethodKeyDeclineJoinGroupRequest = @"declineApplication";
static NSString * const EMMethodKeyAcceptInvitationFromGroup = @"acceptGroupInvitation";
static NSString * const EMMethodKeyDeclineGroupInvitation = @"declineGroupInvitation";
// 有疑议
static NSString * const EMMethodKeyUpdatePushServiceForGroup = @"updatePushServiceForGroup";
// 有疑议
static NSString * const EMMethodKeyUpdatePushServiceForGroups = @"updatePushServiceForGroups";

static NSString * const EMMethodKeyOnGroupChanged = @"onGroupChanged";

#pragma mark - EMCallManagerWrapper
static NSString * const EMMethodKeyStartCall = @"startCall";
static NSString * const EMMethodKeySetCallOptions = @"setCallOptions";
//static NSString * const EMMethodKeyGetCallOptions = @"getCallOptions";
// 兼容安卓
static NSString * const EMMethodKeyRegisterCallReceiver = @"registerCallReceiver";

static NSString * const EMMethodKeyGetCallId = @"getCallId";
static NSString * const EMMethodKeyGetConnectType = @"getConnectType";
static NSString * const EMMethodKeyGetExt = @"getExt";
static NSString * const EMMethodKeyGetLocalName = @"getLocalName";
static NSString * const EMMethodKeyGetRemoteName = @"getRemoteName";
static NSString * const EMMethodKeyGetServerRecordId = @"getServerRecordId";
static NSString * const EMMethodKeyGetCallType = @"getCallType";
static NSString * const EMMethodKeyIsRecordOnServer = @"isRecordOnServer";
static NSString * const EMMethodKeyRegisterCallSharedManager = @"registerCallSharedManager";

static NSString * const EMMethodKeyOnCallChanged = @"onCallChanged";

#pragma mark - EMConferenceManagerWrapper
static NSString * const EMMethodKeyCreateAndJoinConference = @"createAndJoinConference";
static NSString * const EMMethodKeyJoinConference = @"joinConference";
static NSString * const EMMethodKeyRegisterConferenceSharedManager = @"registerConferenceSharedManager";

#pragma mark - EMPushManagerWrapper
static NSString * const EMMethodKeyEnableOfflinePush = @"enableOfflinePush";
static NSString * const EMMethodKeyDisableOfflinePush = @"disableOfflinePush";
static NSString * const EMMethodKeyGetPushConfigs = @"getPushConfigs";
static NSString * const EMMethodKeyGetPushConfigsFromServer = @"getPushConfigsFromServer";
static NSString * const EMMethodKeyUpdatePushOptionServiceForGroup = @"updatePushServiceForGroup";
static NSString * const EMMethodKeyGetNoPushGroups = @"getNoPushGroups";
static NSString * const EMMethodKeyUpdatePushNickname = @"updatePushNickname";
static NSString * const EMMethodKeyUpdatePushDisplayStyle = @"updatePushDisplayStyle";


