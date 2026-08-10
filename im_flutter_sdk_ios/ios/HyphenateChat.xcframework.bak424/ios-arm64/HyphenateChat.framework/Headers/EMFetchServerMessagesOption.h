//
//  EMFetchServerMessagesOption.h
//  HyphenateChat
//
//  Created by li xiaoming on 2023/4/10.
//  Copyright © 2023 easemob.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMConversation.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  \~chinese
 *  从服务端查询历史消息的参数配置类。
 *
 *  \~english
 *  The parameter configuration class for pulling historical messages from the server.
 */
 
@interface EMFetchServerMessagesOption: NSObject
 
/** \~chinese 群组会话中的消息发送方的用户 ID。  \~english The user ID of the message sender in the group conversation.*/
@property (nonatomic,strong) NSString* _Nullable from __deprecated_msg("Use fromIds instead");

/** \~chinese 群组会话中的消息发送方的用户 ID 数组, 如果设置了 from 则优先使用 from。 \~english The array of user IDs of the message sender in the group conversation. If from is set, it will be used first.*/
@property (nonatomic,strong) NSArray<NSString*>* _Nullable fromIds;
 
/** \~chinese 要查询的消息类型数组。默认值为 `nil`，表示返回所有类型的消息。 \~english The array of message types for query. The default value is `null`, indicating that all types of messages are retrieved. */
@property (nonatomic,strong) NSArray<NSNumber*>* _Nullable msgTypes;
 
/** \~chinese 消息查询的起始时间，Unix 时间戳，单位为毫秒。默认为 `-1`，表示消息查询时会忽略该参数。若起始时间设置为特定时间点，而结束时间采用默认值 `-1`，则查询起始时间至当前时间的消息。若起始时间采用默认值 `-1`，而结束时间设置了特定时间，SDK 返回从会话中最早的消息到结束时间点的消息。 \~english The start time for message query. The time is a UNIX time stamp in milliseconds. The default value is `-1`, indicating that this parameter is ignored during message query. If the start time is set to a specific time spot and the end time uses the default value `-1`, the SDK returns messages that are sent and received in the period that is from the start time to the current time. If the start time uses the default value `-1` and the end time is set to a specific time spot, the SDK returns messages that are sent and received in the period that is from the timestamp of the first message to the current time.*/
@property (nonatomic) NSInteger startTime;
 
/** \~chinese 消息查询的结束时间，Unix 时间戳，单位为毫秒。默认为 `-1`，表示消息查询时会忽略该参数。若起始时间设置为特定时间点，而结束时间采用默认值 `-1`，则查询起始时间至当前时间的消息。若起始时间采用默认值 `-1`，而结束时间设置了特定时间，SDK 返回从会话中最早的消息到结束时间点的消息。 \~english The end time for message query. The time is a UNIX time stamp in milliseconds. The default value is `-1`, indicating that this parameter is ignored during message query. If the start time is set to a specific time spot and the end time uses the default value `-1`, the SDK returns messages that are sent and received in the period that is from the start time to the current time. If the start time uses the default value `-1` and the end time is set to a specific time spot, the SDK returns messages that are sent and received in the period that is from the timestamp of the first message to the current time.*/
@property (nonatomic) NSInteger endTime;
 
/** \~chinese 消息搜索方向。详见 {@link EMConversation.EMMessageSearchDirection}。  \~english The message search direction. See {@link EMConversation.EMMessageSearchDirection}.  */
@property (nonatomic) EMMessageSearchDirection direction;
 
/** \~chinese 获取的消息是否保存到数据库：-`YES`：保存到数据库；-（默认）`NO`：不保存到数据库。 \~english Whether to save the retrieved messages to the database: -`YES`: Yes; -`NO`：No.*/
@property (nonatomic) BOOL isSave;
 
@end

NS_ASSUME_NONNULL_END
