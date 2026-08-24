//
//  EMMessageReactionChange.h
//  HyphenateChat
//
//  Created by 冯钊 on 2022/3/11.
//  Copyright © 2022 easemob.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMMessageReaction;
#import "EMMessageReactionOperation.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  \~chinese
 *  消息Reaction变更回调通知类。
 *
 *  \~english
 *  The message reaction change callback object.
 */
@interface EMMessageReactionChange : NSObject

/**
 *  \~chinese
 *  会话 ID。
 *
 *  \~english
 *  The conversation ID.
 */
@property (nullable, readonly) NSString *conversationId;
/**
 *  \~chinese
 *  消息 ID。
 *
 *  \~english
 *  The message ID.
 */
@property (nullable, readonly) NSString *messageId;
/**
 *  \~chinese
 *  发生变化后的 Reaction。
 *
 *  \~english
 *  The Reaction which is changed.
 */
@property (nullable, readonly) NSArray <EMMessageReaction *>*reactions;

/**
 *  \~chinese
 *  发生变化的操作详情。
 *
 *  \~english
 *  Details of changed operation.
 */
@property (nullable, readonly) NSArray <EMMessageReactionOperation *>*operations;

@end

NS_ASSUME_NONNULL_END
