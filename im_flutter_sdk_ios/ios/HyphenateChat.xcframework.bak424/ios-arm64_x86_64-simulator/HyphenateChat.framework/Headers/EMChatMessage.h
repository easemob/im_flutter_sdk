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
#import "EMStreamChunk.h"
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
    EMChatTypeChatRoom,     /** \~chinese 聊天室。  \~english Chat room. */
};

/**
 *  \~chinese
 *  消息发送状态。
 *
 *  \~english
 *  The message delivery states.
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
 *  The message directions.
 */
typedef NS_ENUM(NSInteger, EMMessageDirection) {
    EMMessageDirectionSend = 0,    /** \~chinese 该消息是当前用户发送出去的。\~english This message is sent from the local client.*/
    EMMessageDirectionReceive,     /** \~chinese 该消息是当前用户接收到的。 \~english The message is received by the local client.*/
};

/**
 *  \~chinese
 *  聊天室消息的送达优先级。
 *
 *  \~english
 *  The chat room message priorities.
 */
typedef NS_ENUM(NSInteger, EMChatRoomMessagePriority)  {
    /** \~chinese 高。 \~english High. */
    EMChatRoomMessagePriorityHigh = 0,
    /** \~chinese 中。 \~english Normal. */
    EMChatRoomMessagePriorityNormal,
    /** \~chinese 低。 \~english Low. */
    EMChatRoomMessagePriorityLow,
};

/**
 *  \~chinese
 *  消息置顶操作信息。
 *
 * \~english
 * The message pinning information.
 */
@interface EMMessagePinInfo: NSObject
/** \~chinese 操作者的用户 ID。 \~english The user ID of the operator that pins the message. */
@property (strong,nonatomic) NSString* _Nonnull operatorId;
/** \~chinese 消息置顶时间，单位为毫秒。 \~english When the message is pinned. The unit is millisecond. */
@property (nonatomic) NSInteger pinTime;

@end

/**
 *  \~chinese
 *  消息置顶和取消置顶操作。
 *
 * \~english
 * The message pinning and unpinning operations.
 */
typedef NS_ENUM(NSInteger, EMMessagePinOperation) {
    /** \~chinese 置顶。 \~english Pin the message. */
    EMMessagePin = 0,
    
    /** \~chinese 取消置顶。 \~english Unpin the message. */
    EMMessageUnpin
};

/**
 *  \~chinese
 *  消息发送者的用户属性信息。
 *
 * \~english
 * The user attribute information of the message sender.
 */
@interface EMMessageSenderInfo: NSObject
/**
 * \~chinese 发送者的用户Id。
 *
 * \~english The userId of the message sender.
 * */
@property (strong,nonatomic) NSString* _Nullable userId;
/**
 * \~chinese 发送者的昵称。
 *
 * \~english The nickname of the message sender.
 * */
@property (strong,nonatomic) NSString* _Nullable nickname;
/**
 * \~chinese 发送者的头像 URL。
 *
 * \~english The avatar URL of the message sender.
 */
@property (strong,nonatomic) NSString* _Nullable avatarUrl;
/**
 * \~chinese 发送者的好友备注信息。
 *
 * \~english The contact remark information of the message sender.
 */
@property (strong,nonatomic) NSString* _Nullable remark;
/**
 * \~chinese 发送者的群名片，只有群组消息生效。
 *
 * \~english The group name card of the message sender. This property is valid for group messages only.
 */
@property (strong,nonatomic) NSString* _Nullable groupNameCard;

@end

@class EMChatThread;
/**
 *  \~chinese
 *  聊天消息类。
 *
 *  \~english
 *  The chat message class.
 */
@interface EMChatMessage : NSObject

-(instancetype _Nonnull ) init __attribute__((unavailable("call initWithConversationID instead")));

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
 *  The Unix timestamp for the chat server receiving the message.
 *
 *  The unit is second.
 */
@property (nonatomic) long long timestamp;

/**
 *  \~chinese
 *  客户端发送或收到此消息的时间。
 *
 *  单位为毫秒。
 *
 *  \~english
 *  The Unix timestamp for the local client sending or receiving the message.
 *
 * The unit is millisecond.
 */
@property (nonatomic) long long localTime;

/**
 *  \~chinese
 *  聊天类型。
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

 *  是否为在线消息：
 *  - `YES`: 在线消息。
 *  - `NO`:  离线消息。
 *
 *  消息的在线状态在本地数据库不存储。
 *
 * 从数据库读取或拉取的漫游消息默认值为在线。
 *
 *  \~english
 *
 *  Whether the message is an online message:
 *  - `YES`: online message.
 *  - `NO`: offline message.
 *
 * This message status is not stored in the local database.
 *
 * Messages read from the database or pulled from the server are regarded as online.
 *
 *
 */
@property (nonatomic, readonly) BOOL onlineState;

/**
 *  \~chinese
 *  是否（消息接收方）已发送或（消息发送方）已收到消息已读回执。
 *
 * - `YES`: 是；
 * - `NO`: 否。
 *
 *  \~english
 *  Whether the message read receipt is sent (from the message recipient) or received (by the message sender).
 *
 *  - `YES`: Yes;
 *  - `NO`: No.
 */
@property (nonatomic) BOOL isReadAcked;

/**
 *  \~chinese
 *  是否是在子区内发送的消息：
 *
 *  - `YES`: 是；
 *  - `NO`: 否。
 *
 *  \~english
 *  Whether this message is sent within a thread:
 *
 *  - `YES`: Yes;
 *  - `NO`: No.
 */
@property (nonatomic) BOOL isChatThreadMessage;

/**
 *  \~chinese
 *  是否需要发送群组已读消息回执：
 *
 * - `YES`: 是；
 * - `NO`: 否。
 *
 *  \~english
 *  Whether read receipts are required for group messages.
 *
 *  - `YES`: Yes;
 *  - `NO`: No.
 */
@property (nonatomic) BOOL isNeedGroupAck;

/**
 *  \~chinese
 *  收到的群组已读消息回执数量。
 *
 *  \~english
 *  The number of read receipts received for group messages.
 */
@property (nonatomic, readonly) int groupAckCount;

/**
 *  \~chinese
 *  是否已发送或收到消息送达回执。
 *
 *  - `YES`: 是；
 *  - `NO`: 否。
 *
 *  对于消息发送方，该属性表示是否已收到送达回执。
 *
 *  对于消息接收方，该属性表示是否已发送送达回执。
 *
 *  如果你将 `EMOptions` 中的 `enableDeliveryAck` 设为 `YES`，则 SDK 在收到消息后会自动发送送法回执。
 *
 *  \~english
 *  Whether the delivery receipt is sent or received:
 *
 *  - `YES`: Yes;
 *  - `NO`: No.

 *  For the message sender, this attribute indicates whether the delivery receipt is received.
 *
 *  For the message recipient, this attribute indicates whether the delivery receipt is sent.
 *
 *  If you set `enableDeliveryAck` in `EMOptions` as `YES`, the SDK automatically sends the delivery receipt after receiving a message.
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
 *  - `YES`: Yes;
 *  - `NO`: No.
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
 *  - `YES`: Yes;
 *  - `NO`: No.
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
 *  This data is in the key-value format, where the key is the extension field name of the NSString type, and the value must be of the NSString or NSNumber (Bool, Int, unsigned int, long long, double) type.
 */
@property (nonatomic, copy) NSDictionary * _Nullable ext;
/**
 *  \~chinese
 *  获取消息内的 thread 概览。
 *
 *  目前仅群组消息支持。
 *
 *  \~english
 *  Gets an overview of the thread in the message.
 *
 *  Currently, this attribute is valid only for group messages.
 */

@property (readonly) EMChatThread * _Nullable chatThread;
/**
 *  \~chinese
 *
 *  设置聊天室消息的到达优先级。
 *
 *  目前，该属性仅支持聊天室消息。默认值为 `normal`，表示普通优先级。
 *
 *  \~english
 *  Sets the priority of a chat room message.
 *
 *  Currently, this attribute is valid only for chat room messages.
 *
 *  The default value is `normal`, indicating the normal priority.
 */
@property (nonatomic) EMChatRoomMessagePriority  priority;

/**
 *  \~chinese
 *
 *  是否是全局广播消息。
 *
 *
 *  \~english
 *
 *  Whether it is a broadcast message.
 */
@property (nonatomic,readonly) BOOL broadcast;

/**
 * \~chinese
 *
 *  消息是否只投递给在线用户：
 * - `YES`：只有消息接收方在线时才能投递成功。若接收方离线，消息不投递。
 * - （默认）`NO`：无论接收方在线或离线，消息均投递。
 *
 *
  * \~english
 *
 * Whether the message is delivered only when the recipient(s) is/are online:
 * - `YES`：The message is delivered only when the recipient(s) is/are online. If the recipient is offline, the message is not delivered.
 * - (Default) `NO`：The message is delivered to the recipients regardless of whether they are online or offline.
 */
@property (nonatomic) BOOL deliverOnlineOnly;

/**
  * \~chinese
  *
  *  消息回调路由的环境标识。
  *
  *  - 不传或传入 `nil`：服务器将使用默认的回调路由。
  *  - 传入空字符串 `@""`：服务器将视为空白标识，按“未匹配到任何路由”进行处理。
  *  - 传入有效字符串：服务器将根据该字符串匹配对应的特定环境回调路由。
  *
  * \~english
  *
  * The environment identifier for callback routing.
  *
  * - If this property is `nil` or omitted, the server uses the default callback route.
  * - If an empty string `@""` is passed,  the server treats it as a blank identifier with no matching route.
  * - If a valid string is passed, the server matches the specific callback route by the identifier.
  */
@property (nonatomic, copy) NSString * _Nullable webhookEnv;

/**
  * \~chinese
  *
  *  定向消息的接收方。
  *
  *  该属性仅对群组和聊天室中的消息有效。若传入 `nil`，则消息发送给群组或聊天室的所有成员。
  *
  * \~english
  *
  * The recipient list of a targeted message.
  *
  * This property is used only for messages in groups and chat rooms. If you pass in `nil`, the messages are sent to all members in the group or chat room.
  */
@property (nonatomic,strong) NSArray<NSString*>* _Nullable receiverList;

/**
  * \~chinese
  *
  *  消息内容是否已被替换，开启`EMOptions#useReplacedMessageContent`后有效
  *
  * \~english
  *
  * Whether the message content has been replaced by server.This property is used only when EMOptions#useReplacedMessageContent is true.
  *
  */
@property (nonatomic,readonly) BOOL isContentReplaced;
/**
 *  \~chinese
 *  附件消息文件上传或下载的进度。
 *  单位为百分比（0~100）。
 *  \~english
 *  The progress of uploading or downloading the file of the attachment message.
 *  The unit is percentage (0~100).
 */
@property (nonatomic,readonly) CGFloat progress;

/**
 *  \~chinese
 *
 *  消息的置顶操作信息。
 *
 *  若消息未置顶，返回 nil。
 *
 *
 *  \~english
 *
 *  The message pinning information.
 *
 *  For a message that is not pinned, nil is returned.
 */
@property (nonatomic,readonly)  EMMessagePinInfo* _Nullable  pinnedInfo;

/**
 * \~chinese 流式消息片段信息
 * \~english Stream chunk information of the message.
 */
@property (nonatomic,readonly) EMStreamChunk * _Nullable streamChunk;

/**
 * \~chinese 消息发送者的用户属性信息
 * \~english The user attribute information of the message sender.
 */
@property (nonatomic, readonly) EMMessageSenderInfo* _Nullable senderInfo;
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


- (instancetype _Nonnull)initWithConversationID:(NSString *_Nonnull)aConversationId
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


- (instancetype _Nonnull)initWithConversationID:(NSString *_Nonnull)aConversationId
                                  body:(EMMessageBody *_Nonnull)aBody
                                   ext:(NSDictionary *_Nullable)aExt;

@end
