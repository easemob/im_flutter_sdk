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
    EMThreadOperationUpdate_msg
};

/*!
 *  \~chinese
 *  子区操作事件类
 *
 *  \~english
 *  The sub-zone event class
 */
@interface EMChatThreadEvent : NSObject
/*!
 *  \~chinese
 *  接收到别人对子区的操作类型
 *
 *  \~english
 *  Received the operation type of the sub-area from others
 */
@property (readonly) EMThreadOperation type;
/*!
 *  \~chinese
 *  操作子区的用户id
 *
 *  \~english
 *  User id of the operation sub-area
 */
@property (readonly) NSString *from;
/*!
 *  \~chinese
 *  子区对象
 *
 *  \~english
 *  sub-zone object
 */
@property (readonly) EMChatThread *chatThread;

@end

