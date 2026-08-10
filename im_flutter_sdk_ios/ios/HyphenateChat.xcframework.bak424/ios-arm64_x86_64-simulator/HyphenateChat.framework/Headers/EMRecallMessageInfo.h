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
 *  消息撤回者。
 *
 *  \~english
 *  The user that recalls the message.
 */
@property (nonatomic, copy) NSString * _Nonnull recallBy;

/*!
 *  \~chinese
 *  被撤回的消息的消息 ID。
 *
 *  \~english
 *  The ID of the recalled message.
 */
@property (nonatomic, copy) NSString * _Nonnull recallMessageId;

/*!
 *  \~chinese
 *  撤回的消息，离线撤回会为空。
 *
 *  \~english
 *  The recalled message.
 * 
 * The value of this property is nil if the recipient is offline during message recall.
 */
@property (nonatomic, strong) EMChatMessage * _Nullable recallMessage;

/*!
 *  \~chinese
 *  撤回消息时要透传的信息。
 *
 *  \~english
 *  The information to be transparently transmitted during message recall.
 */
@property (nonatomic, strong) NSString* _Nullable ext;

/*!
 *  \~chinese
 *  撤回消息的会话Id。
 *
 *  \~english
 *  The  conversationId of the recalled message.
 */
@property (nonatomic, strong) NSString* _Nonnull conversationId;

@end

