//
//  EMMessageReactionOperation.h
//  HyphenateChat
//
//  Created by 冯钊 on 2023/2/28.
//  Copyright © 2023 easemob.com. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  \~chinese
 *  reaction 操作种类。
 *
 *  \~english
 *  Operation type of reaction.
 */
typedef NS_ENUM(NSUInteger, EMMessageReactionOperate) {
    EMMessageReactionOperateRemove = 0,
    EMMessageReactionOperateAdd,
};

NS_ASSUME_NONNULL_BEGIN

@interface EMMessageReactionOperation : NSObject

/**
 *  \~chinese
 *  操作者。
 *
 *  \~english
 *  Operator.
 */
@property (copy, readonly) NSString *userId;

/**
 *  \~chinese
 *  发生变化的 reaction。
 *
 *  \~english
 *  Changed reaction.
 */
@property (copy, readonly) NSString *reaction;

/**
 *  \~chinese
 *  操作。
 *
 *  \~english
 *  Operate.
 */
@property (assign, readonly) EMMessageReactionOperate operate;

@end

NS_ASSUME_NONNULL_END
