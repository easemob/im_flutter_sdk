//
//  EMGroupMessageAck.h
//  HyphenateSDK
//
//  Created by 杜洁鹏 on 2019/6/3.
//  Copyright © 2019 easemob.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  \~chinese
 *  群组消息的回执。
 *
 *  \~english
 *  The group message receipt.
 */
@interface EMGroupMessageAck : NSObject

/**
 *  \~chinese
 *  群组消息 ID。
 *
 *  \~english
 *  The group message ID.
 */
@property (nonatomic, copy) NSString *messageId;

/**
 *  \~chinese
 *  群组消息已读回执 ID。
 *
 *  \~english
 *  The group message read receipt ID.
 */
@property (nonatomic, copy) NSString *readAckId;

/**
 *  \~chinese
 *  群组消息发送者。
 *
 *  \~english
 *  The user that sends the group message.
 */
@property (nonatomic, copy) NSString *from;

/**
 *  \~chinese
 *  群组消息内容。
 *
 *  \~english
 *  The group message content.
 */
@property (nonatomic, copy) NSString *content;

/**
 *  \~chinese
 *  群组消息已读人数。
 *
 *  \~english
 *  The number of group members that have read the group message.
 */
@property (nonatomic) int readCount;

/**
 *  \~chinese
 *  群组消息回执发送的 Unix 时间戳。
 *
 *  \~english
 *  The Unix timestamp for group message ack.
 */
@property (nonatomic) long long timestamp;

@end

NS_ASSUME_NONNULL_END
