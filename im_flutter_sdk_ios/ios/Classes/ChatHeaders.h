//
//  ChatTypedef.h
//  Pods
//
//  Created by 杜洁鹏 on 2024/12/25.
//


//#define AgoraChat

#if defined(AgoraChat)

#import <HyphenateChat/HyphenateChat.h>
#import "ChatManagerCompat5.h"
#import <HyphenateChat/HyphenateChat.h>
#import "ChatManagerCompat5.h"

// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMClient AgoraChatClient


// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMOptions AgoraChatOptions
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMChatMessage AgoraChatMessage
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMDeviceConfig AgoraChatDeviceConfig
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMPresence AgoraChatPresence
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMMessageBody AgoraChatMessageBody
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMTextMessageBody AgoraChatTextMessageBody
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMFileMessageBody AgoraChatFileMessageBody
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMCmdMessageBody AgoraChatCmdMessageBody
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMCustomMessageBody AgoraChatCustomMessageBody
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMCombineMessageBody AgoraChatCombineMessageBody
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMVoiceMessageBody AgoraChatVoiceMessageBody
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMImageMessageBody AgoraChatImageMessageBody
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMVideoMessageBody AgoraChatVideoMessageBody
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMLocationMessageBody AgoraChatLocationMessageBody

// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMMessageBodyType AgoraChatMessageBodyType
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMMessageBodyTypeText AgoraChatMessageBodyTypeText
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMMessageBodyTypeImage AgoraChatMessageBodyTypeImage
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMMessageBodyTypeFile AgoraChatMessageBodyTypeFile
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMMessageBodyTypeVoice AgoraChatMessageBodyTypeVoice
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMMessageBodyTypeVideo AgoraChatMessageBodyTypeVideo
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMMessageBodyTypeLocation AgoraChatMessageBodyTypeLocation
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMMessageBodyTypeCmd AgoraChatMessageBodyTypeCmd
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMMessageBodyTypeCustom AgoraChatMessageBodyTypeCustom
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMMessageBodyTypeCombine AgoraChatMessageBodyTypeCombine


// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMSilentModeTime AgoraChatSilentModeTime
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMSilentModeParam AgoraChatSilentModeParam
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMSilentModeResult AgoraChatSilentModeResult

// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMChatroom AgoraChatroom
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMCursorResult AgoraChatCursorResult
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMPageResult AgoraChatPageResult

// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMRecallMessageInfo AgoraChatRecallMessageInfo
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMTranslateLanguage AgoraChatTranslateLanguage
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMUserInfo AgoraChatUserInfo
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMChatThread AgoraChatThread
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMChatThreadEvent AgoraChatThreadEvent
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMThreadManagerDelegate AgoraChatThreadManagerDelegate
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMLoginExtensionInfo AgoraChatLoginExtensionInfo

// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMDownloadStatus AgoraChatDownloadStatus
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMDownloadStatusFailed AgoraChatDownloadStatusFailed
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMDownloadStatusSucceed AgoraChatDownloadStatusSucceed
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMDownloadStatusDownloading AgoraChatDownloadStatusDownloading

// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMChatroomPermissionType AgoraChatroomPermissionType
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMChatroomPermissionTypeMember AgoraChatroomPermissionTypeMember
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMChatroomPermissionTypeAdmin AgoraChatroomPermissionTypeAdmin
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMChatroomPermissionTypeOwner AgoraChatroomPermissionTypeOwner
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMChatroomPermissionTypeNone AgoraChatroomPermissionTypeNone

// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMChatType AgoraChatType
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMChatTypeGroupChat AgoraChatTypeGroupChat
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMPushRemindType AgoraChatPushRemindType
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMMessageReactionOperation AgoraChatMessageReactionOperation

// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMConversationType AgoraChatConversationType
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMConversationTypeGroupChat AgoraChatConversationTypeGroupChat
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMConversationTypeChatRoom AgoraChatConversationTypeChatRoom

// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMSilentModeParamType AgoraChatSilentModeParamType
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMSilentModeParamTypeRemindType AgoraChatSilentModeParamTypeRemindType
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMSilentModeParamTypeDuration AgoraChatSilentModeParamTypeDuration
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMSilentModeParamTypeInterval AgoraChatSilentModeParamTypeInterval
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMPushRemindTypeAll AgoraChatPushRemindTypeAll
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMPushRemindTypeMentionOnly AgoraChatPushRemindTypeMentionOnly
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMPushRemindTypeNone AgoraChatPushRemindTypeNone


// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMMessageReaction AgoraChatMessageReaction
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMMessageReactionChange AgoraChatMessageReactionChange
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMGroupPermissionType AgoraChatGroupPermissionType
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMGroupPermissionTypeMember AgoraChatGroupPermissionTypeMember
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMGroupPermissionTypeAdmin AgoraChatGroupPermissionTypeAdmin
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMGroupPermissionTypeOwner AgoraChatGroupPermissionTypeOwner
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMGroupPermissionTypeNone AgoraChatGroupPermissionTypeNone

// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMMessageSearchDirection AgoraChatMessageSearchDirection

// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMGroupStylePrivateOnlyOwnerInvite AgoraChatGroupStylePrivateOnlyOwnerInvite
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMGroupStylePrivateMemberCanInvite AgoraChatGroupStylePrivateMemberCanInvite
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMGroupStylePublicJoinNeedApproval AgoraChatGroupStylePublicJoinNeedApproval
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMGroupStylePublicOpenJoin AgoraChatGroupStylePublicOpenJoin

// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMPresenceManagerDelegate AgoraChatPresenceManagerDelegate
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMConversation AgoraChatConversation
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMPresenceStatusDetail AgoraChatPresenceStatusDetail

// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMContact AgoraChatContact
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMMessagePinInfo AgoraChatMessagePinInfo
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMMessagePinOperation AgoraChatMessagePinOperation
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMGroup AgoraChatGroup
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMGroupOptions AgoraChatGroupOptions
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMGroupSharedFile AgoraChatGroupSharedFile
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMConversationFilter AgoraChatConversationFilter
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMPushOptions AgoraChatPushOptions

// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMChatroomBeKickedReason AgoraChatroomBeKickedReason
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMChatroomBeKickedReasonDestroyed AgoraChatroomBeKickedReasonDestroyed
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMChatroomBeKickedReasonBeRemoved AgoraChatroomBeKickedReasonBeRemoved
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMPushDisplayStyleSimpleBanner AgoraChatPushDisplayStyleSimpleBanner

// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMMessageStatus AgoraChatMessageStatus
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMMessageDirection AgoraChatMessageDirection

// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMContactManagerDelegate AgoraChatContactManagerDelegate
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMChatroomManagerDelegate AgoraChatroomManagerDelegate

// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMMessageSearchScope AgoraChatMessageSearchScope
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMMessageReactionOperate AgoraChatMessageReactionOperate
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMThreadOperation AgoraChatThreadOperation

// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMMarkType AgoraChatMarkType

// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMChatManagerDelegate AgoraChatManagerDelegate
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMPushDisplayStyle AgoraChatPushDisplayStyle
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMGroupStyle AgoraChatGroupStyle
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMGroupMessageAck AgoraChatGroupMessageAck
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMUserInfoType AgoraChatUserInfoType
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMUserInfoTypeNickName AgoraChatUserInfoTypeNickName
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMUserInfoTypeAvatarURL AgoraChatUserInfoTypeAvatarURL
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMUserInfoTypePhone AgoraChatUserInfoTypePhone
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMUserInfoTypeMail AgoraChatUserInfoTypeMail
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMUserInfoTypeGender AgoraChatUserInfoTypeGender
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMUserInfoTypeSign AgoraChatUserInfoTypeSign
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMUserInfoTypeBirth AgoraChatUserInfoTypeBirth
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMUserInfoTypeExt AgoraChatUserInfoTypeExt

// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMFetchServerMessagesOption AgoraChatFetchServerMessagesOption
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMMessageFetchHistoryDirection AgoraChatMessageFetchHistoryDirection
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMMessageFetchHistoryDirectionUp AgoraChatMessageFetchHistoryDirectionUp
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMMessageFetchHistoryDirectionDown AgoraChatMessageFetchHistoryDirectionDown

// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMGroupManagerDelegate AgoraChatGroupManagerDelegate
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMGroupLeaveReasonBeRemoved AgoraChatGroupLeaveReasonBeRemoved
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMGroupLeaveReasonDestroyed AgoraChatGroupLeaveReasonDestroyed
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMGroupLeaveReason AgoraChatGroupLeaveReason

// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMError AgoraChatError
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMErrorCode AgoraChatErrorCode
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMErrorServerServingForbidden AgoraChatErrorServerServingForbidden
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMErrorUserNotLogin AgoraChatErrorUserNotLogin
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMErrorServerServingForbidden AgoraChatErrorServerServingForbidden
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMErrorAppActiveNumbersReachLimitation AgoraChatErrorAppActiveNumbersReachLimitation
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMErrorUserKickedByChangePassword AgoraChatErrorUserKickedByChangePassword
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMErrorUserLoginTooManyDevices AgoraChatErrorUserLoginTooManyDevices
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMErrorUserKickedByOtherDevice AgoraChatErrorUserKickedByOtherDevice
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMErrorUserAuthenticationFailed AgoraChatErrorUserAuthenticationFailed
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMErrorMessageInvalid AgoraChatErrorMessageInvalid
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMErrorInvalidParam AgoraChatErrorInvalidParam

// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMClientDelegate AgoraChatClientDelegate
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMMultiDevicesDelegate AgoraChatMultiDevicesDelegate

// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMConnectionState AgoraChatConnectionState
// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMConnectionConnected AgoraChatConnectionConnected

// 5.0 移除 AgoraChat 前缀，原生直接用 EM* 名: #define EMMultiDevicesEvent AgoraChatMultiDevicesEvent
#define EMGroupMemberInfo AgoraGroupMemberInfo
#else

#import <HyphenateChat/HyphenateChat.h>
#import "ChatManagerCompat5.h"
#import <HyphenateChat/EMOptions+PrivateDeploy.h>

#endif

