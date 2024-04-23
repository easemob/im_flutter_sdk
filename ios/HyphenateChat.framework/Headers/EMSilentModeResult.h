//
//  EMSilentModeResult.h
//  HyphenateChat
//
//  Created by hxq on 2022/3/30.
//  Copyright © 2022 easemob.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSilentModeTime.h"
#import "EMSilentModeParam.h"
#import "EMConversation.h"

/**
 *  \~chinese
 *  消息免打扰配置的结果类
 *
 *  \~english
 *  The silent message result object
 */
@interface EMSilentModeResult: NSObject <NSCopying,NSCoding>
/*!
 *  \~chinese
 *  消息免打扰过期时间戳。
 *
 *  \~english
 *  The expiration time for  silent messages.
 *
 */
@property (nonatomic, assign, readonly) NSTimeInterval expireTimestamp;
/*!
 *  \~chinese
 *  离线推送提醒类型。
 *
 *  \~english
 *  The remind type for push messages.
 */
@property (nonatomic, assign, readonly) EMPushRemindType remindType;
/*!
 *  \~chinese
 *  消息免打扰时段的开始时间。
 *
 *  \~english
 *  The start time obtained after the silent message is set.
 *
 */
@property (nonatomic, strong, readonly) EMSilentModeTime * _Nullable silentModeStartTime;
/*!
 *  \~chinese
 *  消息免打扰时段的结束时间。
 *
 *  \~english
 *  The end time obtained after the silent message is set.
 *
 */
@property (nonatomic, strong, readonly) EMSilentModeTime *_Nullable silentModeEndTime;
/*!
 *  \~chinese
 *  会话ID。
 *
 *  \~english
 *  The conversation ID.
 *
 */
@property (nonatomic, copy, readonly) NSString  * _Nonnull conversationID;
/*!
 *  \~chinese
 *  会话类型。
 *
 *  \~english
 *  The conversation type.
 *
 */
@property (nonatomic, assign, readonly) EMConversationType conversationType;
/*!
 *  \~chinese
 *  会话是否设置过消息提醒类型。
 *
 *  \~english
 *  Whether the remind type is set for the conversation.
 *
 */
@property (nonatomic, assign, readonly) BOOL isConversationRemindTypeEnabled;

@end

