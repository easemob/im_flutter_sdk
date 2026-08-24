//
//  EMThreadEvent.h
//  HyphenateChat
//
//  Created by 朱继超 on 2022/3/3.
//  Copyright © 2022 easemob.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMChatMessage;
@class EMChatThread;

typedef NS_ENUM(NSUInteger, EMThreadOperation) {
    EMThreadOperationUnknown,
    EMThreadOperationCreate,
    EMThreadOperationUpdate,
    EMThreadOperationDelete,
    EMThreadOperationUpdate_msg,
    EMThreadOperationUserRemoved
};

/*!
 *  \~chinese
 *  子区事件类。
 *
 *  \~english
 *  The message thread event class.
 */
@interface EMChatThreadEvent : NSObject
/*!
 *  \~chinese
 *  子区事件类型。
 *
 *  \~english
 *  The message thread event type.
 */
@property (readonly) EMThreadOperation type;
/*!
 *  \~chinese
 *  子区操作者的用户 ID。
 *
 *  \~english
 *  The user ID of the message thread operator.
 */
@property (readonly) NSString *from;
/*!
 *  \~chinese
 *  子区对象。
 *
 *  \~english
 *  The message thread object.
 */
@property (readonly) EMChatThread *chatThread;

@end

