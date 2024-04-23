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
 *  子区类
 *
 *  \~english
 *  The sub-zone class
 */
@interface EMChatThread : NSObject

/*!
 *  \~chinese
 *  子区id
 *
 *  \~english
 *  sub-zone id
 */
@property (readonly) NSString *threadId;

/*!
*  \~chinese
*  子区的名称(请求子区列表与子区详情都会有)
*
*  \~english
*  Subject of the sub-zone(There will be a list of requested sub-areas and sub-area details)
*/
@property (nonatomic, strong) NSString *threadName;

/*!
 *  \~chinese
 *  子区的创建者,需要请求获取子区详情接口后当前对象会有这个属性
 *
 *  \~english
 *  create  of the sub-zone, require fetch thread's detail first
 */
@property (readonly) NSString *owner;
/*!
 *  \~chinese
 *  创建子区的messageId （可空，因为目前群消息可被撤回）
 *
 *  \~english
 *  A messageId that create sub-zone
 */
@property (readonly) NSString *messageId;
/*!
 *  \~chinese
 *  创建子区的会话id
 *
 *  \~english
 *  A channelId that create sub-zone
 */
@property (readonly) NSString *parentId;


/*!
 *  \~chinese
 *  子区的成员列表数目，需要请求获取子区详情接口后当前对象会有这个属性
 *
 *  \~english
 *  Member list of the sub-zone, require fetch thread's detail first
 */
@property (readonly) int membersCount;
/*!
 *  \~chinese
 *  子区中的消息数
 *
 *  \~english
 *  Number of messages in subsection
 */
@property (readonly) int messageCount;
/*!
 *  \~chinese
 *  子区创建的时间戳
 *
 *  \~english
 *  Timestamp of subarea creation
 */
@property (readonly) int createAt;

/*!
 *  \~chinese
 *  子区中最后一条消息，为空代表最后一条消息被撤回，不为空代表新消息
 *
 *  \~english
 *  The last message in the sub-area, if it is empty, it means the last message is withdrawn. If it is not empty, it means a new message.
 */
@property (readonly) EMChatMessage *lastMessage;

@end


