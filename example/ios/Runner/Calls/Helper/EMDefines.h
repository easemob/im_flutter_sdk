//
//  EMDefines.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/2/11.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#ifndef EMDefines_h
#define EMDefines_h

#define IS_iPhoneX (\
{\
BOOL isPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
}\
(isPhoneX);}\
)

#define EMVIEWTOPMARGIN (IS_iPhoneX ? 22.f : 0.f)
#define EMVIEWBOTTOMMARGIN (IS_iPhoneX ? 34.f : 0.f)

//账号状态
#define ACCOUNT_LOGIN_CHANGED @"loginStateChange"

#define NOTIF_PUSHVIEWCONTROLLER @"EMPushNotificationViewController"
#define NOTIF_ID @"EMNotifId"
#define NOTIF_NAVICONTROLLER @"EMNaviController"

//聊天
#define CHAT_PUSHVIEWCONTROLLER @"EMPushChatViewController"
#define CHAT_CLEANMESSAGES @"EMChatCleanMessages"

//消息动图
#define MSG_EXT_GIF_ID @"em_expression_id"
#define MSG_EXT_GIF @"em_is_big_expression"

#define MSG_EXT_READ_RECEIPT @"em_read_receipt"
#define MSG_EXT_UN_READ_RECEIPT @"em_read_unreceipt"

//消息撤回
#define MSG_EXT_RECALL @"em_recall"

//多人会议邀请
#define MSG_EXT_CALLOP @"em_conference_op"
#define MSG_EXT_CALLID @"em_conference_id"
#define MSG_EXT_CALLPSWD @"em_conference_password"

//@
//群组消息ext的字段，用于存放被@的环信id数组
#define MSG_EXT_AT @"em_at_list"
//群组消息ext字典中，kGroupMessageAtList字段的值，用于@所有人
#define MSG_EXT_ATALL @"all"

//Typing
#define MSG_TYPING_BEGIN @"TypingBegin"
#define MSG_TYPING_END @"TypingEnd"

#define kHaveUnreadAtMessage    @"kHaveAtMessage"
#define kAtYouMessage           1
#define kAtAllMessage           2

//实时音视频
#define CALL_CHATTER @"chatter"
#define CALL_TYPE @"type"
#define CALL_PUSH_VIEWCONTROLLER @"EMPushCallViewController"
//实时音视频1v1呼叫
#define CALL_MAKE1V1 @"EMMake1v1Call"
//实时音视频多人
#define CALL_MODEL @"EMCallForModel"
#define CALL_MAKECONFERENCE @"EMMakeConference"
#define CALL_SELECTCONFERENCECELL @"EMSelectConferenceCell"

//用户黑名单
#define CONTACT_BLACKLIST_UPDATE @"EMContactBlacklistUpdate"
#define CONTACT_BLACKLIST_RELOAD @"EMContactReloadBlacklist"

//群组
#define GROUP_LIST_PUSHVIEWCONTROLLER @"EMPushGroupsViewController"
#define GROUP_INFO_UPDATED @"EMGroupInfoUpdated"
#define GROUP_SUBJECT_UPDATED @"EMGroupSubjectUpdated"
#define GROUP_INFO_PUSHVIEWCONTROLLER @"EMPushGroupInfoViewController"
#define GROUP_INFO_REFRESH @"EMGroupInfoRefresh"

//聊天室
#define CHATROOM_LIST_PUSHVIEWCONTROLLER @"EMPushChatroomsViewController"
#define CHATROOM_INFO_UPDATED @"EMChatroomInfoUpdated"
#define CHATROOM_INFO_PUSHVIEWCONTROLLER @"EMPushChatroomInfoViewController"


#endif /* EMDefines_h */
