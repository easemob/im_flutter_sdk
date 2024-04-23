//
//  EMRecallMessageInfo.h
//  HyphenateChat
//
//  Created by zhangchong on 2022/1/20.
//  Copyright © 2022 easemob.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMChatMessage.h"

/**
 *  \~chinese
 *  消息撤回详情类。
 *
 *  \~english
 *  The message recall information object.
 */
@interface EMRecallMessageInfo : NSObject

/*!
 *  \~chinese
 *  消息撤回者
 *
 *  \~english
 *  Users who recall messages
 */
@property (nonatomic, copy) NSString * _Nonnull recallBy;

/*!
 *  \~chinese
 *  撤回的消息
 *
 *  \~english
 *  A recall message
 */
@property (nonatomic, strong) EMChatMessage * _Nonnull recallMessage;

@end

