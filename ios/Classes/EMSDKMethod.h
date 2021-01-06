//
//  EMSDKMethod.h
//  
//
//  Created by 杜洁鹏 EMMethodKeyOn 2019/10/8.
//

#import <Foundation/Foundation.h>


static NSString * const EMMethodKeyDebugLog = @"debugLog";
static NSString * const EMMethodKeyErrorLog = @"errorLog";


#pragma mark - EMClientWrapper
static NSString * const EMMethodKeyInit = @"init";
static NSString * const EMMethodKeyCreateAccount = @"createAccount";
static NSString * const EMMethodKeyLogin = @"login";
static NSString * const EMMethodKeyLogout = @"logout";
static NSString * const EMMethodKeyChangeAppKey = @"changeAppKey";
static NSString * const EMMethodKeyIsLoggedInBefore = @"isLoggedInBefore";
static NSString * const EMMethodKeySetNickname = @"setNickname";
static NSString * const EMMethodKeyUploadLog = @"uploadLog";
static NSString * const EMMethodKeyCompressLogs = @"compressLogs";
static NSString * const EMMethodKeyKickDevice = @"kickDevice";
static NSString * const EMMethodKeyKickAllDevices = @"kickAllDevices";
static NSString * const EMMethodKeyCurrentUser = @"currentUser";
static NSString * const EMMethodKeyGetLoggedInDevicesFromServer = @"getLoggedInDevicesFromServer";

#pragma mark - EMClientDelegate
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

#pragma mark - EMContactDelegate
static NSString * const EMMethodKeyOnContactChanged = @"onContactChanged";

#pragma mark - EMChatManagerWrapper
static NSString * const EMMethodKeySendMessage = @"sendMessage";
static NSString * const EMMethodKeyAckMessageRead = @"ackMessageRead";
static NSString * const EMMethodKeyRecallMessage = @"recallMessage";
static NSString * const EMMethodKeyGetConversation = @"getConversation";
static NSString * const EMMethodKeyMarkAllChatMsgAsRead = @"markAllChatMsgAsRead";
static NSString * const EMMethodKeyGetUnreadMessageCount = @"getUnreadMessageCount";
static NSString * const EMMethodKeyUpdateChatMessage = @"updateChatMessage";
static NSString * const EMMethodKeyDownloadAttachment = @"downloadAttachment";
static NSString * const EMMethodKeyDownloadThumbnail = @"downloadThumbnail";
static NSString * const EMMethodKeyImportMessages = @"importMessages";
static NSString * const EMMethodKeyLoadAllConversations = @"loadAllConversations";
static NSString * const EMMethodKeyDeleteConversation = @"deleteConversation";
//static NSString * const EMMethodKeySetVoiceMessageListened = @"setVoiceMessageListened";
//static NSString * const EMMethodKeyUpdateParticipant = @"updateParticipant";
static NSString * const EMMethodKeyFetchHistoryMessages = @"fetchHistoryMessages";
static NSString * const EMMethodKeySearchChatMsgFromDB = @"searchChatMsgFromDB";
static NSString * const EMMethodKeyGetMessage = @"getMessage";

#pragma mark - EMChatManagerDelegate
static NSString * const EMMethodKeyOnMessagesReceived = @"onMessagesReceived";
static NSString * const EMMethodKeyOnCmdMessagesReceived = @"onCmdMessagesReceived";
static NSString * const EMMethodKeyOnMessagesRead = @"onMessagesRead";
static NSString * const EMMethodKeyOnMessagesDelivered = @"onMessagesDelivered";
static NSString * const EMMethodKeyOnMessagesRecalled = @"onMessagesRecalled";
static NSString * const EMMethodKeyOnConversationUpdate = @"onConversationUpdate";

#pragma mark - EMMessageListener
static NSString * const EMMethodKeyOnMessageProgressUpdate = @"onMessageProgressUpdate";
static NSString * const EMMethodKeyOnMessageSuccess = @"onMessageSuccess";
static NSString * const EMMethodKeyOnMessageError = @"onMessageError";
static NSString * const EMMethodKeyOnMessageReadAck = @"onMessageReadAck";
static NSString * const EMMethodKeyOnMessageDeliveryAck = @"onMessageDeliveryAck";
static NSString * const EMMethodKeyOnMessageStatusChanged = @"onMessageStatusChanged";

#pragma mark - EMConversationWrapper

static NSString * const EMMethodKeyGetUnreadMsgCount = @"getUnreadMsgCount";
static NSString * const EMMethodKeyMarkAllMsgsAsRead = @"markAllMessagesAsRead";

static NSString * const EMMethodKeyMarkMsgAsRead = @"markMessageAsRead";
static NSString * const EMMethodKeyRemoveMsg = @"removeMessage";
static NSString * const EMMethodKeyGetLatestMsg = @"getLatestMessage";
static NSString * const EMMethodKeyGetLatestMsgFromOthers = @"getLatestMessageFromOthers";
static NSString * const EMMethodKeyClearAllMsg = @"clearAllMessages";
static NSString * const EMMethodKeyInsertMsg = @"insertMessage";
static NSString * const EMMethodKeyAppendMsg = @"appendMessage";
static NSString * const EMMethodKeyUpdateConversationMsg = @"updateConversationMessage";

static NSString * const EMMethodKeyLoadMsgWithId = @"loadMsgWithId";
static NSString * const EMMethodKeyLoadMsgWithStartId = @"loadMsgWithStartId";
static NSString * const EMMethodKeyLoadMsgWithKeywords = @"loadMsgWithKeywords";
static NSString * const EMMethodKeyLoadMsgWithMsgType = @"loadMsgWithMsgType";
static NSString * const EMMethodKeyLoadMsgWithTime = @"loadMsgWithTime";



#pragma mark - EMChatroomManagerWrapper

static NSString * const EMMethodKeyJoinChatRoom = @"joinChatRoom";
static NSString * const EMMethodKeyLeaveChatRoom = @"leaveChatRoom";
static NSString * const EMMethodKeyGetChatroomsFromServer = @"fetchPublicChatRoomsFromServer";
static NSString * const EMMethodKeyFetchChatRoomFromServer = @"fetchChatRoomInfoFromServer";
static NSString * const EMMethodKeyGetChatRoom = @"getChatRoom";
static NSString * const EMMethodKeyGetAllChatRooms = @"getAllChatRooms";
static NSString * const EMMethodKeyCreateChatRoom = @"createChatRoom";
static NSString * const EMMethodKeyDestroyChatRoom = @"destroyChatRoom";
static NSString * const EMMethodKeyChatRoomUpdateSubject = @"changeChatRoomSubject";
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
static NSString * const EMMethodKeyFetchChatroomBlacklistFromServer = @"fetchChatRoomBlackList";
static NSString * const EMMethodKeyUpdateChatRoomAnnouncement = @"updateChatRoomAnnouncement";
static NSString * const EMMethodKeyFetchChatroomAnnouncement = @"fetchChatRoomAnnouncement";

static NSString * const EMMethodKeyChatroomChanged = @"onChatroomChanged";

#pragma mark - EMGroupManagerWrapper

static NSString * const EMMethodKeyGetGroupWithId = @"getGroupWithId";
static NSString * const EMMethodKeyGetJoinedGroups = @"getJoinedGroups";
static NSString * const EMMethodKeyGetGroupsWithoutPushNotification = @"getGroupsWithoutPushNotification";
static NSString * const EMMethodKeyGetJoinedGroupsFromServer = @"getJoinedGroupsFromServer";
static NSString * const EMMethodKeyGetPublicGroupsFromServer = @"getPublicGroupsFromServer";
static NSString * const EMMethodKeyCreateGroup = @"createGroup";
static NSString * const EMMethodKeyGetGroupSpecificationFromServer = @"getGroupSpecificationFromServer";
static NSString * const EMMethodKeyGetGroupMemberListFromServer = @"getGroupMemberListFromServer";
static NSString * const EMMethodKeyGetGroupBlacklistFromServer = @"getGroupBlacklistFromServer";
static NSString * const EMMethodKeyGetGroupMuteListFromServer = @"getGroupMuteListFromServer";
static NSString * const EMMethodKeyGetGroupWhiteListFromServer = @"getGroupWhiteListFromServer";
static NSString * const EMMethodKeyIsMemberInWhiteListFromServer = @"isMemberInWhiteListFromServer";
static NSString * const EMMethodKeyGetGroupFileListFromServer = @"getGroupFileListFromServer";
static NSString * const EMMethodKeyGetGroupAnnouncementFromServer = @"getGroupAnnouncementFromServer";
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
static NSString * const EMMethodKeyUnMuteMembers = @"unMuteMembers";
static NSString * const EMMethodKeyMuteAllMembers = @"muteAllMembers";
static NSString * const EMMethodKeyUnMuteAllMembers = @"unMuteAllMembers";
static NSString * const EMMethodKeyAddWhiteList = @"addWhiteList";
static NSString * const EMMethodKeyRemoveWhiteList = @"removeWhiteList";
static NSString * const EMMethodKeyUploadGroupSharedFile = @"uploadGroupSharedFile";
static NSString * const EMMethodKeyDownloadGroupSharedFile = @"downloadGroupSharedFile";
static NSString * const EMMethodKeyRemoveGroupSharedFile = @"removeGroupSharedFile";
static NSString * const EMMethodKeyUpdateGroupAnnouncement = @"updateGroupAnnouncement";
static NSString * const EMMethodKeyUpdateGroupExt = @"updateGroupExt";
static NSString * const EMMethodKeyJoinPublicGroup = @"joinPublicGroup";
static NSString * const EMMethodKeyRequestToJoinPublicGroup = @"requestToJoinPublicGroup";
static NSString * const EMMethodKeyAcceptJoinApplication = @"acceptJoinApplication";
static NSString * const EMMethodKeyDeclineJoinApplication = @"declineJoinApplication";
static NSString * const EMMethodKeyAcceptInvitationFromGroup = @"acceptInvitationFromGroup";
static NSString * const EMMethodKeyDeclineInvitationFromGroup = @"declineInvitationFromGroup";
static NSString * const EMMethodKeyIgnoreGroupPush = @"ignoreGroupPush";

static NSString * const EMMethodKeyOnGroupChanged = @"onGroupChanged";

/// EMCallManager
static NSString * const EMMethodKeySetCallOptions = @"setCallOptions";
static NSString * const EMMethodKeyGetCallOptions = @"getCallOptions";


static NSString * const EMMethodKeyMakeCall = @"makeCall";
static NSString * const EMMethodKeyAnswerCall = @"answerCall";
static NSString * const EMMethodKeyRejectCall = @"rejectCall";
static NSString * const EMMethodKeyEndCall = @"endCall";
static NSString * const EMMethodKeyEnableVoiceTransfer = @"enableVoiceTransfer";
static NSString * const EMMethodKeyEnableVideoTransfer = @"enableVideoTransfer";
static NSString * const EMMethodKeyMuteRemoteAudio = @"muteRemoteAudio";
static NSString * const EMMethodKeyMuteRemoteVideo = @"muteRemoteVideo";
static NSString * const EMMethodKeySwitchCamera = @"switchCamera";
static NSString * const EMMethodKeySetSurfaceView = @"setSurfaceView";
static NSString * const EMMethodKeyReleaseView = @"releaseView";

/// EMCallManager Listener
static NSString * const EMMethodKeyOnCallReceived = @"onCallReceived";
static NSString * const EMMethodKeyOnCallAccepted = @"onCallAccepted";
static NSString * const EMMethodKeyOnCallRejected = @"onCallRejected";
static NSString * const EMMethodKeyOnCallHangup = @"onCallHangup";
static NSString * const EMMethodKeyOnCallBusy = @"onCallBusy";
static NSString * const EMMethodKeyOnCallVideoPause = @"onCallVideoPause";
static NSString * const EMMethodKeyOnCallVideoResume = @"onCallVideoResume";
static NSString * const EMMethodKeyOnCallVoicePause = @"onCallVoicePause";
static NSString * const EMMethodKeyOnCallVoiceResume = @"onCallVoiceResume";
static NSString * const EMMethodKeyOnCallNetworkUnStable = @"onCallNetworkUnStable";
static NSString * const EMMethodKeyOnCallNetworkNormal = @"onCallNetworkNormal";
static NSString * const EMMethodKeyOnCallNetworkDisconnect = @"onCallNetworkDisconnect";

#pragma mark - EMConferenceManagerWrapper
static NSString * const EMMethodKeySetConferenceAppKey = @"setConferenceAppKey";
static NSString * const EMMethodKeyConferenceHasExists = @"conferenceHasExists";
static NSString * const EMMethodKeyJoinConference = @"joinConference";
static NSString * const EMMethodKeyJoinRoom = @"joinRoom";

static NSString * const EMMethodKeyCreateWhiteboardRoom = @"createWhiteboardRoom";
static NSString * const EMMethodKeyDestroyWhiteboardRoom = @"destroyWhiteboardRoom";
static NSString * const EMMethodKeyJoinWhiteboardRoom = @"joinWhiteboardRoom";

#pragma mark - EMConference
static NSString * const EMMethodKeyPublishConference = @"publishConference";
static NSString * const EMMethodKeyUnPublishConference = @"unPublishConference";
static NSString * const EMMethodKeySubscribeConference = @"subscribeConference";
static NSString * const EMMethodKeyUnSubscribeConference = @"unSubscribeConference";
static NSString * const EMMethodKeyChangeMemberRoleWithMemberName = @"changeMemberRoleWithMemberName";
static NSString * const EMMethodKeyKickConferenceMember = @"kickConferenceMember";
static NSString * const EMMethodKeyDestroyConference = @"destroyConference";
static NSString * const EMMethodKeyLeaveConference = @"leaveConference";
static NSString * const EMMethodKeyStartMonitorSpeaker = @"startMonitorSpeaker";
static NSString * const EMMethodKeyStopMonitorSpeaker = @"stopMonitorSpeaker";
static NSString * const EMMethodKeyRequestTobeConferenceSpeaker = @"requestTobeConferenceSpeaker";
static NSString * const EMMethodKeyRequestTobeConferenceAdmin = @"requestTobeConferenceAdmin";
static NSString * const EMMethodKeyMuteConferenceMember = @"muteConferenceMember";
static NSString * const EMMethodKeyResponseReqSpeaker = @"responseReqSpeaker";
static NSString * const EMMethodKeyResponseReqAdmin = @"responseReqAdmin";
static NSString * const EMMethodKeyUpdateConferenceWithSwitchCamera = @"updateConferenceWithSwitchCamera";
static NSString * const EMMethodKeyUpdateConferenceMute = @"updateConferenceMute";
static NSString * const EMMethodKeyUpdateConferenceVideo = @"updateConferenceVideo";
//static NSString * const EMMethodKeyUpdateRemoteView = @"updateRemoteView";
//static NSString * const EMMethodKeyUpdateMaxVideoKbps = @"updateMaxVideoKbps";
static NSString * const EMMethodKeySetConferenceAttribute = @"setConferenceAttribute";
static NSString * const EMMethodKeyDeleteAttributeWithKey = @"deleteAttributeWithKey";
static NSString * const EMMethodKeyMuteConferenceRemoteAudio = @"muteConferenceRemoteAudio";
static NSString * const EMMethodKeyMuteConferenceRemoteVideo = @"muteConferenceRemoteVideo";
static NSString * const EMMethodKeyMuteConferenceAll = @"muteConferenceAll";
static NSString * const EMMethodKeyAddVideoWatermark = @"addVideoWatermark";
static NSString * const EMMethodKeyClearVideoWatermark = @"clearVideoWatermark";

#pragma mark - EMConferenceManager Listener
static NSString * const EMMethodKeyOnMemberJoined = @"onMemberJoined";
static NSString * const EMMethodKeyOnMemberExited = @"onMemberExited";
static NSString * const EMMethodKeyOnStreamAdded = @"onStreamAdded";
static NSString * const EMMethodKeyOnStreamRemoved = @"onStreamRemoved";
static NSString * const EMMethodKeyOnStreamUpdate = @"onStreamUpdate";
static NSString * const EMMethodKeyOnPassiveLeave = @"onPassiveLeave";
static NSString * const EMMethodKeyOnAdminAdd = @"onMemberAdminAdd";
static NSString * const EMMethodKeyOnAdminRemoved = @"onMemberAdminRemoved";
static NSString * const EMMethodKeyOnPubStreamFailed = @"onPubStreamFailed";
static NSString * const EMMethodKeyOnStreamSetup = @"onStreamSetup";
static NSString * const EMMethodKeyOnUpdateStreamFailed = @"onUpdateStreamFailed";
static NSString * const EMMethodKeyOnConferenceStateChanged = @"onConferenceStateChanged";
static NSString * const EMMethodKeyOnStreamStateUpdated = @"onStreamStateUpdated";
static NSString * const EMMethodKeyOnSpeakers = @"onSpeakers";
static NSString * const EMMethodKeyOnReceiveInvite = @"onReceiveInvite";
static NSString * const EMMethodKeyOnRoleChanged = @"onRoleChanged";
static NSString * const EMMethodKeyOnReqSpeaker = @"onReqSpeaker";
static NSString * const EMMethodKeyOnReqAdmin = @"onReqAdmin";
static NSString * const EMMethodKeyOnMute = @"onMute";
static NSString * const EMMethodKeyOnMuteAll = @"onMuteAll";
static NSString * const EMMethodKeyOnApplySpeakerRefused = @"onApplySpeakerRefused";
static NSString * const EMMethodKeyOnApplyAdminRefused = @"onApplyAdminRefused";


#pragma mark - EMPushManagerWrapper
static NSString * const EMMethodKeyGetImPushConfig = @"getImPushConfig";
static NSString * const EMMethodKeyGetImPushConfigFromServer = @"getImPushConfigFromServer";
static NSString * const EMMethodKeyUpdatePushNickname = @"updatePushNickname";


static NSString * const EMMethodKeyImPushNoDisturb = @"imPushNoDisturb";
static NSString * const EMMethodKeyUpdateImPushStyle = @"updateImPushStyle";
static NSString * const EMMethodKeyUpdateGroupPushService = @"updateGroupPushService";
static NSString * const EMMethodKeyGetNoDisturbGroups = @"getNoDisturbGroups";



