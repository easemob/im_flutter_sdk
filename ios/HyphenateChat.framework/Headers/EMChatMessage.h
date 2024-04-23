/**
 *  \~chinese
 *  @header EMChatMessage.h
 *  @abstract 聊天消息
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header EMChatMessage.h
 *  @abstract Chat message
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>

#import "EMMessageBody.h"
#import "EMMessageReaction.h"

/**
 *  \~chinese
 *  聊天类型。
 *
 *  \~english
 *  Chat types.
 */
typedef NS_ENUM(NSInteger, EMChatType) {
    EMChatTypeChat   = 0,   /** \~chinese 单聊。  \~english One-to-one chat. */
    EMChatTypeGroupChat,    /** \~chinese 群聊。  \~english Group chat. */
    EMChatTypeChatRoom,     /** \~chinese 聊天室。  \~english Chatroom. */
};

/**
 *  \~chinese
 *  消息发送状态。
 *
 *  \~english
 *  The message delivery status types.
 */
typedef NS_ENUM(NSInteger, EMMessageStatus) {
    EMMessageStatusPending  = 0,    /** \~chinese 发送未开始。 \~english The message delivery is pending.*/
    EMMessageStatusDelivering,      /** \~chinese 正在发送。 \~english The message is being delivered.*/
    EMMessageStatusSucceed,         /** \~chinese 发送成功。 \~english The message is successfully delivered.*/
    EMMessageStatusFailed,          /** \~chinese 发送失败。 \~english The message fails to be delivered.*/
};

/**
 *  \~chinese
 *  消息方向类型。
 *
 *  \~english
 *  The message direction types.
 */
typedef NS_ENUM(NSInteger, EMMessageDirection) {
    EMMessageDirectionSend = 0,    /** \~chinese 该消息是当前用户发送出去的。\~english This message is sent from the local client.*/
    EMMessageDirectionReceive,     /** \~chinese 该消息是当前用户接收到的。 \~english The message is received by the local client.*/
};

/**
 *  \~chinese
 *  聊天室消息优先级。
 *
 *  \~english
 *  Chatroom message priority.
 */
typedef NS_ENUM(NSInteger, EMChatRoomMessagePriority)  {
    EMChatRoomMessagePriorityHigh = 0, /* \~chinese 高。 \~english High. */
    EMChatRoomMessagePriorityNormal, /* \~chinese 中。 \~english Normal. */
    EMChatRoomMessagePriorityLow, /* \~chinese 低。 \~english Lower. */
};


@class EMChatThread;
/**
 *  \~chinese
 *  聊天消息类。
 *
 *  \~english
 *  The chat message class.
 */
@interface EMChatMessage : NSObject

/**
 *  \~chinese
 *  消息 ID，是消息的唯一标识。
 *
 *  \~english
 *  The message ID, which is the unique identifier of the message.
 */
@property (nonatomic, copy) NSString * _Nonnull messageId;

/**
 *  \~chinese
 *  会话 ID，是会话的唯一标识。
 *
 *  \~english
 *  The conversation ID, which is the unique identifier of the conversation.
 */
@property (nonatomic, copy) NSString * _Nonnull conversationId;

/**
 *  \~chinese
 *  消息的方向。
 *
 *  \~english
 *  The message delivery direction.
 */
@property (nonatomic) EMMessageDirection direction;

/**
 *  \~chinese
 *  消息的发送方。
 *
 *  \~english
 *  The user sending the message.
 */
@property (nonatomic, copy) NSString * _Nonnull from;

/**
 *  \~chinese
 *  消息的接收方。
 *
 *  \~english
 *  The user receiving the message.
 */
@property (nonatomic, copy) NSString * _Nonnull to;

/**
 *  \~chinese
 *  服务器收到该消息的 Unix 时间戳，单位为毫秒。
 *
 *  \~english
 *  The Unix timestamp for the chat server receiving the message. The unit is second.
 */
@property (nonatomic) long long timestamp;

/**
 *  \~chinese
 *  客户端发送/收到此消息的时间。
 *
 *  \~english
 *  The Unix timestamp for the local client sending or receiving the message.
 */
@property (nonatomic) long long localTime;

/**
 *  \~chinese
 *  消息类型。
 *
 *  \~english
 *  The chat type.
 */
@property (nonatomic) EMChatType chatType;

/**
 *  \~chinese
 *  消息发送状态。详见 {@link EMMessageStatus}。
 *
 *  \~english
 *  The message delivery status. See {@link EMMessageStatus}.
 */
@property (nonatomic) EMMessageStatus status;

/*!
 *  \~chinese
 *  消息在线状态（本地数据库不存储，从数据库读取或拉取漫游消息默认值是 YES）
 *
 *  \~english (Local database does not store. The default value for reading or pulling roaming messages from the database is YES)
 *  Message Online Status
 */
@property (nonatomic, readonly) BOOL onlineState;

/**
 *  \~chinese
 *  是否已发送（消息接收方）或收到（消息发送方）消息已读回执。
 *
 * - `YES`: 是；
 * - `NO`: 否。
 *
 *  \~english
 *  Whether the message read receipt (from the message sender) is sent or received (by the message recipient).
 *
 *  - `Yes`: Yes;
 *  - `No`: No.
 */
@property (nonatomic) BOOL isReadAcked;

/**
 *  \~chinese
 *  是否是在thread内发的消息
 *
 *  \~english
 *  Is it a message sent within a thread
 */
@property (nonatomic) BOOL isChatThreadMessage;

/**
 *  \~chinese
 *  是否需要发送群组已读消息回执。
 *
 * - `YES`: 是；
 * - `NO`: 否。
 *
 *  \~english
 *  Whether read receipts are required for group messages.
 *
 *  - `Yes`: Yes;
 *  - `No`: No.
 */
@property (nonatomic) BOOL isNeedGroupAck;

/**
 *  \~chinese
 *  收到的群组已读消息回执数量。
 *
 *  \~english
 *  The number of read receipts for group messages.
 */
@property (nonatomic, readonly) int groupAckCount;

/**
 *  \~chinese
 *  是否已发送或收到消息送达回执。
 *
 *      - 对于消息发送方，该属性表示是否已收到送达回执。
 *      - 对于消息接收方，该属性表示是否已发送送达回执。
 *
 *  如果你将 EMOptions 中的 `enableDeliveryAck` 设为 `YES`，则 SDK 在收到消息后会自动发送送法回执。
 *
 *  \~english
 *  For the message sender, this property indicates whether the delivery receipt is received.
 *
 *      - For the message sender, this property indicates whether the delivery receipt is received.
 *      - For the message recipient, this property indicates whether the delivery receipt is sent.
 *
 *  If you set `enableDeliveryAck` in EMOptions as `YES`, the SDK automatically sends the delivery receipt after receiving a message.
 */
@property (nonatomic) BOOL isDeliverAcked;

/**
 *  \~chinese
 *  消息是否已读。
 *
 * - `YES`: 是；
 * - `NO`: 否。
 *
 *  \~english
 *  Whether the message is read.
 *
 *  - `Yes`: Yes;
 *  - `No`: No.
 */
@property (nonatomic) BOOL isRead;

/**
 *  \~chinese
 *  语音消息是否已播放。
 *
 * - `YES`: 是；
 * - `NO`: 否。
 *
 *  \~english
 *  Whether the voice message is played.
 *
 *  - `Yes`: Yes;
 *  - `No`: No.
 */
@property (nonatomic) BOOL isListened;

/**
 *  \~chinese
 *  消息体。
 *
 *  \~english
 *  The message body.
 */
@property (nonatomic, strong) EMMessageBody * _Nonnull body;

/**
 *  \~chinese
 *  Reaction 列表。
 *
 *  \~english
 *  The Reaction list.
 */
@property (nonatomic, readonly) NSArray <EMMessageReaction *>* _Nullable reactionList;

/**
 *  \~chinese
 *  根据 Reaction ID 获取 Reaction 内容。
 *
 *  @param reaction  Reaction ID。
 *
 *  @result    Reaction 内容。
 *
 *  \~english
 *  Gets the Reaction content by the Reaction ID.
 *
 *  @param reaction   The Reaction ID.
 *
 *  @result    The Reaction content.
 */
- (EMMessageReaction *_Nullable)getReaction:(NSString * _Nonnull)reaction;

/**
 *  \~chinese
 *  自定义消息扩展。
 *
 *  该参数数据形式是一个 Key-Value 的键值对，其中 Key 为 NSString 型，Value 为 NSString、NSNumber 类型的 Bool、Int、Unsigned int、long long 或 double.
 *
 *  \~english
 *  The custom message extension.
 *
 *  This member is in the key-value format, where the key is the extension field name of the NSString type, and the value must be of the NSString or NSNumber(Bool, Int, unsigned int, long long, double) type.
 */
@property (nonatomic, copy) NSDictionary * _Nullable ext;
/**
 *  \~chinese
 *  获取消息内的thread概览（目前仅群组消息支持）
 *
 *  \~english
 *  Get an overview of the thread in the message (currently only supported by group messages)
 */

@property (readonly) EMChatThread * _Nullable chatThread;
/**
 *  \~chinese
 *  设置聊天室消息的到达优先级（目前仅聊天室消息支持）不传默认为normal
 *
 *  \~english
 *  Setting priority of chatroom message.(Support only chatroom)  `default` normal,if not set.
 */
@property (nonatomic) EMChatRoomMessagePriority  priority;

/**
 *  \~chinese
 *  初始化消息实例。
 *
 *  @param aConversationId  会话 ID。
 *  @param aFrom            消息发送方。
 *  @param aTo              消息接收方。
 *  @param aBody            消息体实例。
 *  @param aExt             扩展信息。
 *
 *  @result    消息实例。
 *
 *  \~english
 *  Initializes a message instance.
 *
 *  @param aConversationId   The conversation ID.
 *  @param aFrom           The user that sends the message.
 *  @param aTo         The user that receives the message.
 *  @param aBody             The message body.
 *  @param aExt              The message extention.
 *
 *  @result    The message instance.
 */


- (id _Nonnull )initWithConversationID:(NSString *_Nonnull)aConversationId
                                  from:(NSString *_Nonnull)aFrom
                                    to:(NSString *_Nonnull)aTo
                                  body:(EMMessageBody *_Nonnull)aBody
                                   ext:(NSDictionary *_Nullable)aExt;

/**
 *  \~chinese
 *  初始化消息实例。
 *
 *  @param aConversationId  会话 ID。
 *  @param aBody            消息体实例。
 *  @param aExt             扩展信息。
 *
 *  @result    消息实例。
 *
 *  \~english
 *  Initializes a message instance.
 *
 *  @param aConversationId   The conversation ID.
 *  @param aBody             The message body.
 *  @param aExt              The message extention.
 *
 *  @result    The message instance.
 */


- (id _Nonnull )initWithConversationID:(NSString *_Nonnull)aConversationId
                                  body:(EMMessageBody *_Nonnull)aBody
                                   ext:(NSDictionary *_Nullable)aExt;

@end
