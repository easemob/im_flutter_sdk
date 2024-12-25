//
//  ChatTypedef.h
//  Pods
//
//  Created by 杜洁鹏 on 2024/12/25.
//


//#define AgoraChat

#if defined(AgoraChat)

#import <AgoraChat/AgoraChat.h>
#import <AgoraChat/AgoraChatOptions+PrivateDeploy.h>

#define EMClient AgoraChatClient
#define EMError AgoraChatError
#define EMOptions AgoraChatOptions
#define EMChatMessage AgoraChatMessage
#define EMDeviceConfig AgoraChatDeviceConfig
#define EMPresence AgoraChatPresence
#define EMMessageBody AgoraChatMessageBody
#define EMTextMessageBody AgoraChatTextMessageBody

#define EMSilentModeTime AgoraChatSilentModeTime
#define EMSilentModeParam AgoraChatSilentModeParam
#define EMSilentModeResult AgoraChatSilentModeResult

#define EMChatroom AgoraChatroom
#define EMCursorResult AgoraChatCursorResult
#define EMPageResult AgoraChatPageResult

#define EMRecallMessageInfo AgoraChatRecallMessageInfo
#define EMTranslateLanguage AgoraChatTranslateLanguage
#define EMUserInfo AgoraChatUserInfo
#define EMChatThread AgoraChatThread
#define EMChatThreadEvent AgoraChatThreadEvent
#define EMThreadManagerDelegate AgoraChatThreadManagerDelegate
#define EMLoginExtensionInfo AgoraChatLoginExtensionInfo

#define EMMessageBodyType AgoraChatMessageBodyType
#define EMDownloadStatus AgoraChatDownloadStatus
#define EMChatroomPermissionType AgoraChatroomPermissionType
#define EMChatType AgoraChatType
#define EMPushRemindType AgoraChatPushRemindType
#define EMMessageReactionOperation AgoraChatMessageReactionOperation
#define EMConversationType AgoraChatConversationType
#define EMSilentModeParamType AgoraChatSilentModeParamType
#define EMMessageReaction AgoraChatMessageReaction
#define EMMessageReactionChange AgoraChatMessageReactionChange
#define EMGroupPermissionType AgoraChatGroupPermissionType
#define EMMessageSearchDirection AgoraChatMessageSearchDirection

#define EMPresenceManagerDelegate AgoraChatPresenceManagerDelegate
#define EMConversation AgoraChatConversation
#define EMPresenceStatusDetail AgoraChatPresenceStatusDetail

#define EMContact AgoraChatContact
#define EMMessagePinInfo AgoraChatMessagePinInfo
#define EMGroup AgoraChatGroup
#define EMGroupOptions AgoraChatGroupOptions
#define EMGroupSharedFile AgoraChatGroupSharedFile 
#define EMConversationFilter AgoraChatConversationFilter
#define EMPushOptions AgoraChatPushOptions

#define EMChatroomBeKickedReason AgoraChatroomBeKickedReason
#define EMChatroomBeKickedReasonDestroyed AgoraChatroomBeKickedReasonDestroyed
#define EMChatroomBeKickedReasonBeRemoved AgoraChatroomBeKickedReasonBeRemoved
#define EMPushDisplayStyleSimpleBanner AgoraChatPushDisplayStyleSimpleBanner

#define EMMessageStatus AgoraChatMessageStatus

#define EMContactManagerDelegate AgoraChatContactManagerDelegate
#define EMChatroomManagerDelegate AgoraChatroomManagerDelegate

#define EMMessageSearchScope AgoraChatMessageSearchScope

#define EMMarkType AgoraChatMarkType



#else

#import <HyphenateChat/HyphenateChat.h>
#import <HyphenateChat/EMOptions+PrivateDeploy.h>

#endif

