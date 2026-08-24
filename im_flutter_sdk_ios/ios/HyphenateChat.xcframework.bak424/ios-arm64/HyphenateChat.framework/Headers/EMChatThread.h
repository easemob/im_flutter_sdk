//
//  EMChatThread.h
//  HyphenateChat
//
//  Created by 朱继超 on 2022/3/1.
//  Copyright © 2022 easemob.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@class EMChatMessage;

/*!
 *  \~chinese
 *  子区模型类，用于定义子区属性。
 * 
 *  \~english
 *  The message thread model class, which defines attributes of a message thread.
 */
@interface EMChatThread : NSObject

/*!
 *  \~chinese
 *  子区 ID。
 *
 *  \~english
 *  The message thread ID.
 */
@property (readonly) NSString *threadId;

/*!
*  \~chinese
*  子区名称。
*
*  \~english
*  The message thread name.
*/
@property (nonatomic, strong) NSString *threadName;

/*!
 *  \~chinese
 *  子区创建者。
 *
 *  \~english
 *  The message thread creator.
 */
@property (readonly) NSString *owner;
/*!
 *  \~chinese
 *  子区父消息 ID。
 * 
 *  该属性为空，表示父消息被撤回。
 *
 *  \~english
 *  The ID of the parent message of the message thread.
 * 
 *  If this attribute is empty, the parent message of the message thread is withdrawn.
 */
@property (readonly) NSString *messageId;
/*!
 *  \~chinese
 *  子区所属的群组 ID。
 *
 *  \~english
 *  The group ID where the message thread belongs.
 */
@property (readonly) NSString *parentId;


/*!
 *  \~chinese
 *  子区成员数量。
 * 
 * 只有获取子区详情 {@link IEMChatThread#getChatThreadDetail:} 后，该属性才存在。
 *
 *  \~english
 *  The count of members in the message thread.
 * 
 *  This attribute exists only after you call {@link IEMChatThread#getChatThreadDetail:} to get details of a message thread.
 */
@property (readonly) int membersCount;
/*!
 *  \~chinese
 *  子区中的消息数。
 *
 *  \~english
 *  The number of messages in a message thread.
 */
@property (readonly) int messageCount;
/*!
 *  \~chinese
 *  子区创建的 Unix 时间戳，单位为毫秒。
 *
 *  \~english
 *  The Unix timestamp when the message thread is created. The unit is millisecond.
 */
@property (readonly) NSInteger createAt;

/*!
 *  \~chinese
 *  子区中的最新一条消息。
 * 
 *  若该属性为空，表示最后一条消息被撤回。
 *
 *  \~english
 *  The last reply in the message thread.
 * 
 *  If this attribute is empty, the last reply is withdrawn. 
 */
@property (readonly) EMChatMessage *lastMessage;

@end


