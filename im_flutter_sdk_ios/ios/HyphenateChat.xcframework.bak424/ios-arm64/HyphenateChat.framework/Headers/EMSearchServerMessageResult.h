/**
 *  \~chinese
 *  @header EMSearchServerMessageResult.h
 *  @abstract 服务端消息搜索结果
 *  @author Hyphenate
 *
 *  \~english
 *  @header EMSearchServerMessageResult.h
 *  @abstract Server message search result
 *  @author Hyphenate
 */

#import <Foundation/Foundation.h>
#import "EMMessageBody.h"
#import "EMChatMessage.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  \~chinese
 *  服务端消息搜索结果对象。
 *
 *  \~english
 *  The server message search result object.
 */
@interface EMSearchServerMessageResult : NSObject

/**
 *  \~chinese
 *  消息 ID。
 *
 *  \~english
 *  The message ID.
 */
@property (nonatomic, readonly) NSString *messageId;

/**
 *  \~chinese
 *  消息体。
 *
 *  \~english
 *  The message body.
 */
@property (nonatomic, readonly, nullable) EMMessageBody *body;

/**
 *  \~chinese
 *  消息扩展属性。
 *
 *  \~english
 *  The message extension attributes.
 */
@property (nonatomic, readonly, nullable) NSDictionary *ext;

/**
 *  \~chinese
 *  消息发送方。
 *
 *  \~english
 *  The message sender.
 */
@property (nonatomic, readonly) NSString *from;

/**
 *  \~chinese
 *  消息接收方。
 *
 *  \~english
 *  The message receiver.
 */
@property (nonatomic, readonly) NSString *to;

/**
 *  \~chinese
 *  会话 ID。
 *
 *  \~english
 *  The conversation ID.
 */
@property (nonatomic, readonly) NSString *conversationId;

/**
 *  \~chinese
 *  会话类型。
 *
 *  \~english
 *  The chat type.
 */
@property (nonatomic, readonly) EMChatType chatType;

/**
 *  \~chinese
 *  消息时间戳，Unix 时间戳，单位为毫秒。
 *
 *  \~english
 *  The message timestamp in milliseconds.
 */
@property (nonatomic, readonly) NSInteger timestamp;

/**
 *  \~chinese
 *  搜索高亮文本列表。
 *
 *  \~english
 *  The highlighted texts from search.
 */
@property (nonatomic, readonly, nullable) NSArray<NSString *> *highlightTexts;

@end

NS_ASSUME_NONNULL_END
