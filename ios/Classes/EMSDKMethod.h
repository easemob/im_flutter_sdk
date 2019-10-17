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
static NSString * const EMMethodKeyChatManager = @"chatManager";
static NSString * const EMMethodKeyRegister = @"register";
static NSString * const EMMethodKeyChangeAppKey = @"changeAppKey";
static NSString * const EMMethodKeyGetCurrentUser = @"getCurrentUser";
static NSString * const EMMethodKeyGetUserTokenFromServer = @"getUserTokenFromServer";
static NSString * const EMMethodKeySetDebugMode = @"setDebugMode";
static NSString * const EMMethodKeyUpdateCurrentUserNick = @"updateCurrentUserNick";
static NSString * const EMMethodKeyUploadLog = @"uploadLog";
static NSString * const EMMethodKeyCompressLogs = @"compressLogs";
static NSString * const EMMethodKeyKickDevice = @"kickDevice";
static NSString * const EMMethodKeyKickAllDevices = @"kickAllDevices";
static NSString * const EMMethodKeySendFCMTokenToServer = @"sendFCMTokenToServer";
static NSString * const EMMethodKeySendHMSPushTokenToServer = @"sendHMSPushTokenToServer";
static NSString * const EMMethodKeyGetDeviceInfo = @"getDeviceInfo";
static NSString * const EMMethodKeyGetRobotsFromServer = @"getRobotsFromServer";
static NSString * const EMMethodKeyOnMultiDeviceEvent = @"onMultiDeviceEvent";
static NSString * const EMMethodKeyCheck = @"check";
static NSString * const EMMethodKeyOnClientMigrate2x = @"onClientMigrate2x";
static NSString * const EMMethodKeyOnConnectionDidChanged = @"onConnectionDidChanged";
static NSString * const EMMethodKeyGetLoggedInDevicesFromServer = @"getLoggedInDevicesFromServer";

#pragma mark - EMContactManagerWrapper

static NSString * const EMMethodKeyAddContact = @"addContact";
static NSString * const EMMethodKeyDeleteContact = @"deleteContact";
static NSString * const EMMethodKeyGetAllContactsFromServer = @"getAllContactsFromServer";
static NSString * const EMMethodKeyAddUserToBlackList = @"addUserToBlackList";
static NSString * const EMMethodKeyRemoveUserFromBlackList = @"removeUserFromBlackList";
static NSString * const EMMethodKeyGetBlackListFromServer = @"getBlackListFromServer";
static NSString * const EMMethodKeySaveBlackList = @"saveBlackList";
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
static NSString * const EMMethodKeySetMessageListened = @"setMessageListened";
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

#pragma mark - EMConversationWrapper

static NSString * const EMMethodKeyGetUnreadMsgCount = @"getUnreadMsgCount";
static NSString * const EMMethodKeyMarkAllMessagesAsRead = @"markAllMessagesAsRead";
static NSString * const EMMethodKeyGetAllMsgCount = @"getAllMsgCount";
static NSString * const EMMethodKeyLoadMoreMsgFromDB = @"loadMoreMsgFromDB";
static NSString * const EMMethodKeySearchConversationMsgFromDB = @"searchConversationMsgFromDB";
static NSString * const EMMethodKeySearchConversationMsgFromDBByType = @"searchConversationMsgFromDBByType";
static NSString * const EMMethodKeyGetAllMessages = @"getAllMessages";
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

#pragma mark - EMGroupManagerWrapper

static NSString * const EMMethodKeyGetJoinedGroups = @"getJoinedGroups";
static NSString * const EMMethodKeyGetGroupsWithoutPushNotification = @"getGroupsWithoutPushNotification";
static NSString * const EMMethodKeyGetJoinedGroupsFromServer = @"getJoinedGroupsFromServer";
static NSString * const EMMethodKeyGetPublicGroupsFromServer = @"getPublicGroupsFromServer";
static NSString * const EMMethodKeySearchPublicGroup = @"searchPublicGroup";
static NSString * const EMMethodKeyCreateGroup = @"createGroup";
static NSString * const EMMethodKeyGetGroupSpecificationFromServer = @"getGroupSpecificationFromServer";
static NSString * const EMMethodKeyGetGroupMemberListFromServer = @"getGroupMemberListFromServer";
static NSString * const EMMethodKeyGetGroupBlacklistFromServer = @"getGroupBlacklistFromServer";
static NSString * const EMMethodKeyGetGroupMuteListFromServer = @"getGroupMuteListFromServer";
static NSString * const EMMethodKeyGetGroupFileList = @"getGroupFileList";
static NSString * const EMMethodKeyGetGroupAnnouncement = @"getGroupAnnouncement";
static NSString * const EMMethodKeyAddMembers = @"addMembers";
static NSString * const EMMethodKeyRemoveMembers = @"removeMembers";
static NSString * const EMMethodKeyBlockMembers = @"blockMembers";
static NSString * const EMMethodKeyUnblockMembers = @"unblockMembers";
static NSString * const EMMethodKeyUpdateGroupSubject = @"updateGroupSubject";
static NSString * const EMMethodKeyUpdateDescription = @"updateDescription";
static NSString * const EMMethodKeyLeaveGroup = @"leaveGroup";
static NSString * const EMMethodKeyDestroyGroup = @"destroyGroup";
static NSString * const EMMethodKeyBlockGroup = @"blockGroup";
static NSString * const EMMethodKeyUnblockGroup = @"unblockGroup";
static NSString * const EMMethodKeyUpdateGroupOwner = @"updateGroupOwner";
static NSString * const EMMethodKeyAddAdmin = @"addAdmin";
static NSString * const EMMethodKeyRemoveAdmin = @"removeAdmin";
static NSString * const EMMethodKeyMuteMembers = @"muteMembers";
static NSString * const EMMethodKeyUnmuteMembers = @"unmuteMembers";
static NSString * const EMMethodKeyUploadGroupSharedFile = @"uploadGroupSharedFile";
static NSString * const EMMethodKeyDownloadGroupSharedFile = @"downloadGroupSharedFile";
static NSString * const EMMethodKeyRemoveGroupSharedFile = @"removeGroupSharedFile";
static NSString * const EMMethodKeyUpdateGroupAnnouncement = @"updateGroupAnnouncement";
static NSString * const EMMethodKeyUpdateGroupExt = @"updateGroupExt";
static NSString * const EMMethodKeyJoinPublicGroup = @"joinPublicGroup";
static NSString * const EMMethodKeyRequestToJoinPublicGroup = @"requestToJoinPublicGroup";
static NSString * const EMMethodKeyApproveJoinGroupRequest = @"approveJoinGroupRequest";
static NSString * const EMMethodKeyDeclineJoinGroupRequest = @"declineJoinGroupRequest";
static NSString * const EMMethodKeyAcceptInvitationFromGroup = @"acceptInvitationFromGroup";
static NSString * const EMMethodKeyDeclineGroupInvitation = @"declineGroupInvitation";
static NSString * const EMMethodKeyUpdatePushServiceForGroup = @"updatePushServiceForGroup";
static NSString * const EMMethodKeyUpdatePushServiceForGroups = @"updatePushServiceForGroups";

static NSString * const EMMethodKeyOnGroupChanged = @"onGroupChanged";




