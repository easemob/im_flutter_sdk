/**
 *  \~chinese
 *  @header EMChatMessageStatistics.h
 *  @abstract 消息流量统计模型类。
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header EMChatMessageStatistics.h
 *  @abstract The message traffic statistics model.
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>
#import "EMChatMessage.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  \~chinese
 *  消息流量信息。
 *
 *  \~english
 *  The message traffic statistics.
 */
@interface EMChatMessageStatistics : NSObject

/**
 *  \~chinese
 *  消息 ID，即消息的唯一标识。
 *
 *  \~english
 *  The message ID, which is the unique identifier of the message.
 */
@property (nonatomic,strong,readonly) NSString* messageId;

/**
 *  \~chinese
 *  消息的接收方。
 *
 *  \~english
 *  The user ID of the message recipient.
 */
@property (nonatomic,strong,readonly) NSString* to;

/**
 *  \~chinese
 *  消息的发送方。
 *
 *  \~english
 *  The user ID of the message sender.
 */
@property (nonatomic,strong,readonly) NSString* from;

/**
 *  \~chinese
 *  消息体类型。
 *
 *  \~english
 *  The message body type.
 */
@property (nonatomic,readonly) EMMessageBodyType type;

/**
 *  \~chinese
 *  聊天类型。
 *
 *  \~english
 *  The chat type.
 */
@property (nonatomic,readonly) EMChatType chatType;

/**
 *  \~chinese
 *  消息方向:
 *  - `Send`：该消息是当前用户发送出去的；
 *  - `Receive`：该消息是当前用户接收到的。
 *
 *  \~english
 *  The message direction:
 *  - `Send`: Messages sent by the current user;
 *  - `Receive`: Messages received by the current user.

 */
@property (nonatomic,readonly) EMMessageDirection direction;

/**
 *  \~chinese
 *  消息体流量大小。
 * 
 *  流量单位为字节。
 *
 *  \~english
 *  The amount of traffic for the message body.
 * 
 *  The traffic is measured in bytes.
 */
@property (nonatomic,readonly) NSUInteger messageSize;

/**
 *  \~chinese
 *  消息附件流量大小。
 * 
 *  流量单位为字节。
 *
 *  \~english
 *  The amount of traffic for the message attachment.
 * 
 *  The traffic is measured in bytes.
 */
@property (nonatomic,readonly) NSUInteger attachmentSize;

/**
 *  \~chinese
 *  缩略图流量大小。
 * 
 *  流量单位为字节。
 *
 *  \~english
 *  The amount of traffic for the thumbnail.
 * 
 *  The traffic is measured in bytes.
 */
@property (nonatomic,readonly) NSUInteger thumbnailSize;

/**
 *  \~chinese
 *  服务器收到该消息的 Unix 时间戳。
 * 
 *  时间戳的单位为毫秒。
 *
 *  \~english
 *  The Unix timestamp for the Chat server receiving the message. 
 * 
 *  The Unix timestamp is in the unit of millisecond.
 */
@property (nonatomic,readonly) NSUInteger timestamp;
@end

NS_ASSUME_NONNULL_END
