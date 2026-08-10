/**
 *  \~chinese
 *  @header EMConversation.h
 *  @abstract 聊天会话类。
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header EMConversation.h
 *  @abstract Chat conversation
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>

#import "EMMessageBody.h"
#import "EMCursorResult.h"
#import "EMSilentModeParam.h"

/**
 *  \~chinese
 *  会话枚举类型。
 *
 *  \~english
 *  The conversation types.
 */
typedef NS_ENUM(NSInteger, EMConversationType) {
    EMConversationTypeChat = 0,    /** \~chinese 单聊。  \~english One-to-one chat. */
    EMConversationTypeGroupChat,    /** \~chinese 群聊。  \~english Group chat.*/
    EMConversationTypeChatRoom,      /** \~chinese 聊天室。 \~english Chat room.*/
};

/**
 *  \~chinese
 *  会话标记类型。
 *
 * 各会话标记类型与实际意义之间的映射由开发者维护。
 *
 *  \~english
 *  The conversation mark types.
 *
 * The mapping between each type of conversation mark and their actual meanings is maintained by the developer.
 */
typedef NS_ENUM(NSInteger, EMMarkType) {
    EMMarkType0 = 0,
    EMMarkType1 = 1,
    EMMarkType2 = 2,
    EMMarkType3 = 3,
    EMMarkType4 = 4,
    EMMarkType5 = 5,
    EMMarkType6 = 6,
    EMMarkType7 = 7,
    EMMarkType8 = 8,
    EMMarkType9 = 9,
    EMMarkType10 = 10,
    EMMarkType11 = 11,
    EMMarkType12 = 12,
    EMMarkType13 = 13,
    EMMarkType14 = 14,
    EMMarkType15 = 15,
    EMMarkType16 = 16,
    EMMarkType17 = 17,
    EMMarkType18 = 18,
    EMMarkType19 = 19,
};

/**
 *  \~chinese
 *  消息搜索方向枚举类型。
 *
 * 消息搜索基于消息中包含的 Unix 时间戳。每个消息中包含两个 Unix 时间戳：
 * - 消息创建的 Unix 时间戳；
 * - 服务器接收消息的 Unix 时间戳。
 * 消息搜索基于哪个 Unix 时间戳取决于 {@link EMOptions#sortMessageByServerTime} 的设置。
 *
 *  \~english
 *  The message search directions.
 *
 * The message research is based on the Unix timestamp included in messages. Each message contains two Unix timestamps:
 * - The Unix timestamp when the message is created;
 * - The Unix timestamp when the message is received by the server.
 *
 * Which Unix timestamp is used for message search depends on the setting of {@link EMOptions#sortMessageByServerTime}.
 */
typedef NS_ENUM(NSInteger, EMMessageSearchDirection) {
    EMMessageSearchDirectionUp  = 0,    /** \~chinese 按消息中的时间戳的倒序搜索。  \~english Messages are retrieved in the descending order of the timestamp included in them.*/
    EMMessageSearchDirectionDown        /** \~chinese 按消息中的时间戳的顺序搜索。 \~english The Messages are retrieved in the ascending order of the timestamp included in them.*/
};

/**
 *  \~chinese
 *  消息搜索范围枚举类型。
 *
 *  \~english
 *  The message search scopes.
 */
typedef NS_ENUM(NSInteger, EMMessageSearchScope) {
    EMMessageSearchScopeContent  = 0,   /** \~chinese 按消息内容搜索。  \~english Search by message content.*/
    EMMessageSearchScopeExt,           /** \~chinese 按索消息扩展属性搜索。 \~english Search by message extension.*/
    EMMessageSearchScopeAll           /** \~chinese 按消息内容和扩展属性搜索。 \~english Search by message content and extension.*/
};

@class EMChatMessage;
@class EMError;

/**
 *  \~chinese
 *  聊天会话类。
 *
 *  \~english
 *  The chat conversation class.
 */
@interface EMConversation : NSObject
-(instancetype _Nonnull ) init NS_UNAVAILABLE;
/**
 *  \~chinese
 *  会话 ID。
 *  - 单聊：会话 ID 为对方的用户 ID。
 *  - 群聊：会话 ID 为群组 ID。
 *  - 聊天室：会话 ID 为聊天室的 ID。
 *
 *  \~english
 *  The conversation ID.
*   - One-to-one chat: The conversation ID is the user ID of the peer user.
*   - Group chat: The conversation ID is the group ID.
*   - Chat room: The conversation ID is the chat room ID.
 */
@property (nonatomic, copy, readonly) NSString *conversationId;

/**
 *  \~chinese
 *  会话类型。
 *
 *  \~english
 *  The conversation type.
 */
@property (nonatomic, assign, readonly) EMConversationType type;

/**
 *  \~chinese
 *  会话中未读取的消息数量。
 *
 *  \~english
 *  The number of unread messages in the conversation.
 */
@property (nonatomic, assign, readonly) int unreadMessagesCount;

/**
 *  \~chinese
 *  会话中的消息数量。
 *
 *  \~english
 *  The message count in the conversation.
 */
@property (nonatomic, assign, readonly) int messagesCount;

/**
 *  \~chinese
 *  会话扩展属性。
 *
 *  子区功能目前版本暂不可设置。
 *
 *  \~english
 *  The conversation extension attribute.
 *
 *  This attribute is not available for thread conversations.
 */
@property (nonatomic, copy)   NSDictionary *ext;

/*!
 *  \~chinese
 *  是否为 thread 会话：
 * - `YES`：是
 * - `NO`：否
 *
 *  \~english
 *  Whether the conversation is a thread conversation:
 * - `YES`：Yes
 * - `NO`：No
 */
@property (nonatomic, assign) BOOL isChatThread;

/*!
 *  \~chinese
 *  是否为置顶会话：
 * - `YES`：是
 * - `NO`：否
 *
 *  \~english
 *  Whether the conversation is pinned:
 * - `YES`：Yes
 * - `NO`：No
 */
@property (readonly) BOOL isPinned;

/*!
 *  \~chinese
 *  会话置顶的 UNIX 时间戳，单位为毫秒。未置顶时值为 `0`。
 *
 *  \~english
 *  The UNIX timestamp when the conversation is pinned. The unit is millisecond. This value is `0` when the conversation is not pinned.
 */
@property (readonly) int64_t pinnedTime;

/*!
 *  \~chinese
 *  会话中的最新一条消息。
 *
 *  \~english
 *  The latest message in the conversation.
 */
@property (nonatomic, strong, readonly) EMChatMessage *latestMessage;

/**
 *  \~chinese
 *  会话标记。
 *
 *  \~english
 *  The conversation mark.
 */
@property (nonatomic, readonly) NSArray<NSNumber*>* marks;

/**
 *  \~chinese
 *  会话免打扰类型。``EMPushRemindType``
 *
 *  \~english
 *  The conversation no disturb type.``EMPushRemindType``
 */
@property (nonatomic, readonly) EMPushRemindType disturbType;

/**
 *  \~chinese
 *  收到的对方发送的最后一条消息。
 *
 *  @result 消息实例。
 *
 *  \~english
 *  Gets the last received message.
 *
 *  @result The message instance.
 */
- (EMChatMessage * _Nullable)lastReceivedMessage;

/**
 *  \~chinese
 *  插入一条消息在 SDK 本地数据库
 *
 *  消息的会话 ID 应与会话的 ID 保持一致。
 *
 * 消息会根据消息里的时间戳被插入 SDK 本地数据库，SDK 会更新会话的 `latestMessage` 等属性。
 *
 *  @param aMessage 消息实例。
 *  @param pError   错误信息。
 *
 *  \~english
 *  Inserts a message to a conversation in the local database.
 *
 *  To insert the message correctly, ensure that the conversation ID of the message is the same as that of the conversation.
 *
 *  The message is inserted based on timestamp and the SDK will automatically update attributes of the conversation, including `latestMessage`.
 *
 *
 *  @param aMessage The message instance.
 *  @param pError   The error information if the method fails: Error.
 */
- (void)insertMessage:(EMChatMessage *_Nonnull)aMessage
                error:(EMError ** _Nullable)pError;

/**
 *  \~chinese
 *  插入一条消息到 SDK 本地数据库会话尾部。
 *
 * 消息的 conversationId 应该和会话的 conversationId 一致。
 *
 * 消息会被插入 SDK 本地数据库，并且更新会话的 `latestMessage` 等属性。
 *
 *  @param aMessage 消息实例。
 *  @param pError   错误信息。
 *
 *  \~english
 *  Inserts a message to the end of a conversation in local database.
 *
 * To insert the message correctly, ensure that the conversation ID of the message is the same as that of the conversation.
 *
 * After a message is inserted, the SDK will automatically update attributes of the conversation, including `latestMessage`.
 *
 *  @param aMessage The message instance.
 *  @param pError   The error information if the method fails: Error.
 *
 */
- (void)appendMessage:(EMChatMessage *_Nonnull)aMessage
                error:(EMError **_Nullable)pError;

/**
 *  \~chinese
 *  从 SDK 本地数据库删除一条消息。
 *
 *  @param aMessageId   要删除的 ID。
 *  @param pError       错误信息。
 *
 *  \~english
 *  Deletes a message from the local database.
 *
 *  @param aMessageId   The ID of the message to be deleted.
 *  @param pError       The error information if the method fails: Error.
 *
 */
- (void)deleteMessageWithId:(NSString *_Nonnull)aMessageId
                      error:(EMError ** _Nullable)pError;

/**
 *  \~chinese
 *  清除内存和数据库中指定会话中的消息。
 *
 *  @param pError       错误信息。
 *
 *  \~english
 *  Deletes all the messages in the conversation from the memory and local database.
 *
 *  @param pError       The error information if the method fails: Error.
 */
- (void)deleteAllMessages:(EMError ** _Nullable)pError;


/**
 *  \~chinese
 *  从会话中删除消息（包括本地存储和服务器存储）。
 *
 *  @param messageIds   要删除消息 ID 字符串数组。
 *  @param completion   该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Removes messages from the conversation by message id list.
 *
 * This method deletes messages from both local storage and server.
 *
 *  @param messageIds   The list of IDs of messages to be removed form the current conversation.
 *  @param completion   The completion block, which contains the error message if the method fails.
 *
 */
- (void)removeMessagesFromServerMessageIds:(NSArray <__kindof NSString*>*_Nonnull)messageIds completion:(void (^ _Nullable)(EMError * _Nullable aError))aCompletionBlock;
/**
 *  \~chinese
 *  从会话中删除消息（包括本地存储和服务器存储）。
 *
 *  @param beforeTimeStamp   UNIX 时间戳，单位为毫秒。若消息的 UNIX 时间戳小于等于设置的值，则会被删除。
 *  @param completion   该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Removes messages from the conversation timestamp.
 *
 * This method deletes messages from both local storage and server.
 *
 *  @param beforeTimeStamp   The message timestamp in millisecond. Messages with the timestamp smaller than the specified one will be removed from the current conversation.
 *  @param completion   The completion block, which contains the error message if the method fails.
 *
 */
- (void)removeMessagesFromServerWithTimeStamp:(NSTimeInterval)beforeTimeStamp completion:(void (^ _Nullable)(EMError * _Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  更新 SDK 本地数据库的消息。
 *
 * 消息更新时，消息 ID 不会修改。
 *
 * 消息更新后，SDK 会自动更新会话的 `latestMessage` 等属性。
 *
 *  @param aMessage 要更新的消息。
 *  @param pError   错误信息。
 *
 *  \~english
 *  Updates a message in the local database.
 *
 *  After you update a message, the message ID remains unchanged and the SDK automatically updates attributes of the conversation, like `latestMessage`.
 *
 *  @param aMessage The message to be updated.
 *  @param pError   The error information if the method fails: Error.
 *
 */
- (void)updateMessageChange:(EMChatMessage *_Nonnull)aMessage
                      error:(EMError ** _Nullable)pError;

/**
 *  \~chinese
 *  将 SDK 本地数据库中的指定消息设置为已读。
 *
 *  @param aMessageId   要设置消息的 ID。
 *  @param pError       错误信息。
 *
 *  \~english
 *  Marks a message in the local database as read.
 *
 *  @param aMessageId   The message ID.
 *  @param pError       The error information if the method fails: Error.
 *
 */
- (void)markMessageAsReadWithId:(NSString *_Nonnull)aMessageId
                          error:(EMError ** _Nullable)pError;

/**
 *  \~chinese
 *  将 SDK 本地数据库所有未读消息设置为已读。
 *
 *  @param pError   错误信息。
 *
 *  \~english
 *  Marks all messages in the local database as read.
 *
 *  @param pError   The error information if the method fails: Error.
 *
 */
- (void)markAllMessagesAsRead:(EMError ** _Nullable)pError;

/**
 * \~chinese
 *  获取会话内的置顶消息列表。
 *
 * \~english
 *  Get the pinned messages in the conversation
 */
- (NSArray<EMChatMessage*>* _Nullable)pinnedMessages;


#pragma mark - Load Messages Methods

/**
 *  \~chinese
 *  从 SDK 本地数据库获取指定 ID 的消息。
 *
 *  @param aMessageId       消息 ID。
 *  @param pError           错误信息。
 *
 *  \~english
 *  Gets a message with the specified message ID from the local database.
 *
 *  @param aMessageId       The message ID.
 *  @param pError           The error information if the method fails: Error.
 *
 */
- (EMChatMessage * _Nullable)loadMessageWithId:(NSString * _Nonnull)aMessageId
                           error:(EMError ** _Nullable)pError;

/**
 *  \~chinese
 *  从 SDK 本地数据库获取指定数量的消息。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param aMessageId       查询的起始消息 ID。该参数设置后，SDK 从指定的消息 ID 开始按消息检索方向加载。
 *                          如果传入消息的 ID 为空，SDK 忽略该参数，按搜索方向查询消息：
 *                          - 若 `aDirection` 为 `UP`，SDK 从最新消息开始，按消息时间戳的倒序获取；
 *                          - 若 `aDirection` 为 `DOWN`，SDK 从最早消息开始，按消息时间戳的正序获取。
 *  @param aCount           每次获取的消息条数。如果设为小于等于 0，SDK 获取 1 条消息。
 *  @param aDirection       消息搜索方向，详见 {@link EMMessageSearchDirection}。
 *
 *  @result 消息列表。
 *
 *  \~english
 *  Loads the messages from the local database, starting from a specific message ID.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aMessageId       The starting message ID for query. After this parameter is set, the SDK retrieves messages, from the specified one, according to the message search direction.
     *                      If this parameter is set as `nil`, the SDK retrieves messages according to the search direction while ignoring this parameter.
 *                          - If `aDirection` is set as `UP`, the SDK retrieves messages, starting from the latest one, in the descending order of the timestamp included in them.
 *                          - If `aDirection` is set as `DOWN`, the SDK retrieves messages, starting from the oldest one, in the ascending order of the timestamp included in them.
 *  @param aCount           The number of messages to load each time. If you set this parameter to a value less than 1, the SDK retrieves one message.
 *  @param aDirection       The message search direction. See {@link EMMessageSearchDirection}.
 *
 *  @result EMChatMessage  The message instance.
 *
 */
- (NSArray<EMChatMessage *> * _Nullable)loadMessagesStartFromId:(NSString * _Nullable)aMessageId
                          count:(int)aCount
                searchDirection:(EMMessageSearchDirection)aDirection;

/**
 *  \~chinese
 *  从 SDK 本地数据库获取指定数量的消息。
 *
 *  @param aMessageId       查询的起始消息 ID。该参数设置后，SDK 从指定的消息 ID 开始按消息检索方向加载。
 *                          如果传入消息的 ID 为空，SDK 忽略该参数，按搜索方向查询消息：
 *                          - 若 `aDirection` 为 `UP`，SDK 从最新消息开始，按消息时间戳的倒序获取；
 *                          - 若 `aDirection` 为 `DOWN`，SDK 从最早消息开始，按消息时间戳的正序获取。
 *  @param aCount           每次获取的消息条数。如果设为小于等于 0，SDK 获取 1 条消息。
 *  @param aDirection       消息搜索方向，详见 {@link EMMessageSearchDirection}。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Loads messages starting from the specified message ID from local database.
 *
 *  Returning messages are sorted by receiving timestamp based on EMMessageSearchDirection. If the aMessageId is nil, will return starting from the latest message.
 *
 *  @param aMessageId       The starting message ID for query. After this parameter is set, the SDK retrieves messages, from the specified one, according to the message search direction.
     *                      If this parameter is set as `nil`, the SDK retrieves messages according to the search direction while ignoring this parameter.
 *                          - If `aDirection` is set as `UP`, the SDK retrieves messages, starting from the latest one, in the descending order of the timestamp included in them.
 *                          - If `aDirection` is set as `DOWN`, the SDK retrieves messages, starting from the oldest one, in the ascending order of the timestamp included in them.
 *  @param aCount           The number of messages to load each time. If you set this parameter to a value less than 1, the SDK retrieves one message.
 *  @param aDirection       The message search direction. See {@link EMMessageSearchDirection}.
 *  @param aCompletionBlock The completion block, which contains the error message if the method fails.
 *
 */
- (void)loadMessagesStartFromId:(NSString * _Nullable)aMessageId
                          count:(int)aCount
                searchDirection:(EMMessageSearchDirection)aDirection
                     completion:(void (^ _Nullable)(NSArray<EMChatMessage *> * _Nullable aMessages, EMError * _Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  从本地数据库中获取会话中指定用户发送的一定数量的特定类型的消息。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param aType            消息类型，txt:文本消息，img：图片消息，loc：位置消息，audio：语音消息，video：视频消息，file：文件消息，cmd: 透传消息。
 *  @param aTimestamp       当前传入消息的设备时间戳，单位为毫秒。如果该参数设置的时间戳为负数，则从最新消息向前获取。
 *  @param aCount           每次获取的消息条数。如果设为小于等于 0，SDK 会获取 1 条消息。
 *  @param aUsername        消息发送方。设为 NIL 表示忽略该参数。
 *  @param aDirection       消息搜索方向，详见 {@link EMMessageSearchDirection}。
 *
 *  @result 消息列表。
 *
 *  \~english
 *  Gets messages of certain types that a specified user sends in the conversation.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aType            The message type to load. Types include txt (text message), img (image message), loc (location message), audio (audio message), video (video message), file (file message), and cmd (command message).
 *  @param aTimestamp       The starting Unix timestamp in the message for query. The unit is millisecond. If you set this parameter as a negative value, the SDK loads messages from the latest one.
 *  @param aCount           The number of messages to load each time. If you set this parameter to a value less than 1, the SDK retrieves one message.
 *  @param aUsername        The message sender. Setting it as NIL means that the SDK ignores this parameter.
 *  @param aDirection       The message search direction. See {@link EMMessageSearchDirection}.
 *
 *  @result EMChatMessage  The message instance.
 *
 */
- (NSArray<EMChatMessage *> * _Nullable)loadMessagesWithType:(EMMessageBodyType)aType
                                                   timestamp:(long long)aTimestamp
                                                       count:(int)aCount
                                                    fromUser:(NSString* _Nullable)aUsername
                                             searchDirection:(EMMessageSearchDirection)aDirection;

/**
 *  \~chinese
 *  从本地数据库中获取会话中指定用户发送的一定数量的特定类型的消息。
 *
 *  @param aType            消息类型，txt:文本消息，img：图片消息，loc：位置消息，audio：语音消息，video：视频消息，file：文件消息，cmd: 透传消息。
 *  @param aTimestamp       当前传入消息的设备时间戳，单位为毫秒。如果该参数设置的时间戳为负数，则从最新消息向前获取。
 *  @param aCount           每次获取的消息条数。如果设为小于等于 0，SDK 会获取 1 条消息。
 *  @param aUsername        消息发送方。设为 NIL 表示忽略该参数。
 *  @param aDirection       消息搜索方向，详见 {@link EMMessageSearchDirection}。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Gets messages of certain types that a specified user sends in the conversation.
 *
 *  @param aType            The message type to load. Types include txt (text message), img (image message), loc (location message), audio (audio message), video (video message), file (file message), and cmd (command message).
 *  @param aTimestamp       The starting Unix timestamp in the message for query. The unit is millisecond. If you set this parameter as a negative value, the SDK loads messages from the latest one.
 *  @param aCount           The number of messages to load each time. If you set this parameter to a value less than 1, the SDK retrieves one message.
 *  @param aUsername        The message sender. Setting it as nil means that the SDK ignores this parameter.
 *  @param aDirection       The message search direction. See {@link EMMessageSearchDirection}.
 *  @param aCompletionBlock The completion block, which contains the error message if the method fails.
 *
 */
- (void)loadMessagesWithType:(EMMessageBodyType)aType
                   timestamp:(long long)aTimestamp
                       count:(int)aCount
                    fromUser:(NSString* _Nullable)aUsername
             searchDirection:(EMMessageSearchDirection)aDirection
                  completion:(void (^ _Nullable)(NSArray<EMChatMessage *> * _Nullable aMessages, EMError * _Nullable aError))aCompletionBlock;
/**
 *  \~chinese
 *  从本地数据库中获取会话中指定用户发送的一定数量的特定类型的消息。
 *
 *  @param aTypes            消息类型枚举原始值用NSNumber包装后的数组，txt:文本消息，img：图片消息，loc：位置消息，audio：语音消息，video：视频消息，file：文件消息，cmd: 透传消息。``EMMessageBodyType``
 *  @param aTimestamp       当前传入消息的设备时间戳，单位为毫秒。如果该参数设置的时间戳为负数，则从最新消息向前获取。
 *  @param aCount           每次获取的消息条数。如果设为小于等于 0，SDK 会获取 1 条消息。
 *  @param aUsername        消息发送方。设为 NIL 表示忽略该参数。
 *  @param aDirection       消息搜索方向，详见 {@link EMMessageSearchDirection}。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Gets messages of certain types that a specified user sends in the conversation.
 *
 *  @param aTypes           The message types to search. Types include txt (text message), img (image message), loc (location message), audio (audio message), video (video message), file (file message), and cmd (command message). ``EMMessageBodyType``
 *  @param aTimestamp       The starting Unix timestamp in the message for query. The unit is millisecond. If you set this parameter as a negative value, the SDK loads messages from the latest one.
 *  @param aCount           The number of messages to load each time. If you set this parameter to a value less than 1, the SDK retrieves one message.
 *  @param aUsername        The message sender. Setting it as nil means that the SDK ignores this parameter.
 *  @param aDirection       The message search direction. See {@link EMMessageSearchDirection}.
 *  @param aCompletionBlock The completion block, which contains the error message if the method fails.
 *
 */
- (void)searchMessagesWithTypes:(NSArray <NSNumber*> *_Nonnull)aTypes
                   timestamp:(long long)aTimestamp
                       count:(int)aCount
                    fromUser:(NSString* _Nullable)aUsername
             searchDirection:(EMMessageSearchDirection)aDirection
                  completion:(void (^ _Nullable)(NSArray<EMChatMessage *> * _Nullable aMessages, EMError * _Nullable aError))aCompletionBlock;
/**
 *  \~chinese
 *  从本地数据库获取会话中的指定用户发送的包含特定关键词的消息。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param aKeywords        搜索关键词，设为 NIL 表示忽略该参数。
 *  @param aTimestamp       查询的起始消息 Unix 时间戳，单位为毫秒。该参数设置后，SDK 从指定时间戳的消息开始，按消息搜索方向获取。
 *                          如果该参数设置为负数，SDK 从当前时间开始搜索。
 *  @param aCount           每次获取的消息条数。如果设为小于等于 0，SDK 会获取 1 条消息。
 *  @param aSender          消息发送方，设为 NIL 表示忽略该参数。
 *  @param aDirection       消息搜索方向，详见 {@link EMMessageSearchDirection}。
 *
 *  @result 消息列表。
 *
 *  \~english
 *  Loads messages with keywords that the specified user sends in the conversation.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aKeywords         The keywords for query. Setting it as NIL means that the SDK ignores this parameter.
 *  @param aTimestamp       The starting Unix timestamp for search. The unit is millisecond.
 *                          If this parameter is set as a negative value, the SDK retrieves from the current time.
 *  @param aCount           The number of messages to load each time. If you set this parameter to a value less than 1, the SDK retrieves one message.
 *  @param aSender          The message sender. Setting it as nil means that the SDK ignores this parameter.
 *  @param aDirection       The message search direction. See {@link EMMessageSearchDirection}.
 *
 *  @result EMChatMessage  The message list.
 *
 */
- (NSArray<EMChatMessage *> * _Nullable)loadMessagesWithKeyword:(NSString* _Nullable)aKeywords
                      timestamp:(long long)aTimestamp
                          count:(int)aCount
                       fromUser:(NSString* _Nullable)aSender
                searchDirection:(EMMessageSearchDirection)aDirection;

/**
 *  \~chinese
 *  从本地数据库获取会话中的指定用户发送的包含特定关键词的消息。
 *
 *  @param aKeywords        关键词。设为 NIL 表示忽略该参数。
 *  @param aTimestamp       传入的 Unix 时间戳，单位为毫秒。如果该参数设置的时间戳为负数，则从最新消息向前获取。
 *  @param aCount           每次获取的消息条数。如果设为小于等于 0，SDK 会获取 1 条消息。
 *  @param aSender          消息发送方。设为 NIL 表示忽略该参数。
 *  @param aDirection       消息搜索方向，详见 {@link EMMessageSearchDirection}。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Loads messages with specified keyword from local database. Returning messages are sorted by receiving timestamp based on EMMessageSearchDirection. If reference timestamp is negative, load from the latest messages; if message count is negative, will be handled as count=1
 *
 *  @param aKeywords         The keywords for query. Setting it as NIL means that the SDK ignores this parameter.
 *  @param aTimestamp       The starting Unix timestamp for search. The unit is millisecond.
 *                          If this parameter is set as a negative value, the SDK retrieves from the current time.
 *  @param aCount           The number of messages to load each time. If you set this parameter to a value less than 1, the SDK retrieves one message.
 *  @param aSender          The message sender. Setting it as nil means that the SDK ignores this parameter.
 *  @param aDirection       The message search direction. See {@link EMMessageSearchDirection}.
 *  @param aCompletionBlock The completion block, which contains the error message if the method fails.
 *
 */
- (void)loadMessagesWithKeyword:(NSString* _Nullable)aKeywords
                      timestamp:(long long)aTimestamp
                          count:(int)aCount
                       fromUser:(NSString* _Nullable)aSender
                searchDirection:(EMMessageSearchDirection)aDirection
                     completion:(void (^ _Nullable)(NSArray<EMChatMessage *> * _Nullable aMessages, EMError * _Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  从本地数据库获取会话中的指定用户发送的包含特定关键词的消息。
 *
 *  SDK 返回的消息按时间顺序排列。
 *
 *  @param aKeywords        关键词。设为 `nil` 表示忽略该参数。
 *  @param aTimestamp       搜索开始的 Unix 时间戳。单位为毫秒。如果该参数设置的时间戳为负数，则从最新消息向前获取。
 *  @param aCount           每次获取的消息条数。如果设为小于等于 0，SDK 会获取 1 条消息。
 *  @param aSender          消息发送方。设为 `nil` 表示忽略该参数。
 *  @param aDirection       消息搜索方向，详见 {@link EMMessageSearchDirection}。
 *  @param aScope             消息搜索范围，详见 {@link EMMessageSearchScope}。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Loads messages with the specified keyword from a user in the local database.
 *
 *  The SDK returns messages in the chronological order.
 *
 *  @param aKeyword         The keyword for message search. If you set this parameter as `nil`, the SDK ignores this parameter when retrieving messages.
 *  @param aTimestamp       The Unix timestamp threshold for message search. The unit is millisecond. If you set this parameter as a negative value, the SDK loads messages from the latest one.
 *                          If this parameter is set as a negative value, the SDK retrieves from the current time.
 *  @param aCount           The number of messages to load. If you set this parameter to 0 or less, the SDK gets one message from the local database.
 *  @param aSender          The sender of the message. If you set this parameter as `nil`, the SDK ignores this parameter when retrieving messages.
 *  @param aDirection       The message search direction. See {@link EMMessageSearchDirection}.
 *                          - `UP`: The SDK retrieves messages in the descending order of the timestamp included in them.
 *                          - `DOWN`：The SDK retrieves messages in the ascending order of the timestamp included in them.
 *  @param aScope             The message search scope. See {@link EMMessageSearchScope}.
 *  @param aCompletionBlock The completion block, which contains the error message if the method fails.
 *
 */
- (void)loadMessagesWithKeyword:(NSString* _Nullable)aKeywords
                      timestamp:(long long)aTimestamp
                          count:(int)aCount
                       fromUser:(NSString* _Nullable)aSender
                searchDirection:(EMMessageSearchDirection)aDirection
                          scope:(EMMessageSearchScope)aScope
                     completion:(void (^ _Nullable)(NSArray<EMChatMessage *> * _Nullable aMessages, EMError * _Nullable aError))aCompletionBlock __deprecated_msg("Use -loadMessagesWithKeyword:timestamp:count:fromUsers:searchDirection:scope:completion: instead");



/**
 *  \~chinese
 *  从本地数据库获取会话中的指定用户发送的包含特定关键词的消息。
 *
 *  SDK 返回的消息按时间顺序排列。
 *
 *  @param aKeywords        关键词。设为 `nil` 表示忽略该参数。
 *  @param aTimestamp       搜索开始的 Unix 时间戳。单位为毫秒。如果该参数设置的时间戳为负数，则从最新消息向前获取。
 *  @param aCount           每次获取的消息条数。如果设为小于等于 0，SDK 会获取 1 条消息。
 *  @param senders          消息发送方id列表,  长度小于10。设为 `nil` 表示忽略该参数。
 *  @param aDirection       消息搜索方向，详见 {@link EMMessageSearchDirection}。
 *  @param aScope             消息搜索范围，详见 {@link EMMessageSearchScope}。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Loads messages with the specified keyword from a user in the local database.
 *
 *  The SDK returns messages in the chronological order.
 *
 *  @param aKeywords         The keyword for message search. If you set this parameter as `nil`, the SDK ignores this parameter when retrieving messages.
 *  @param aTimestamp       The Unix timestamp threshold for message search. The unit is millisecond. If you set this parameter as a negative value, the SDK loads messages from the latest one.
 *                          If this parameter is set as a negative value, the SDK retrieves from the current time.
 *  @param aCount           The number of messages to load. If you set this parameter to 0 or less, the SDK gets one message from the local database.
 *  @param senders         The senders of the messages. senders size must be less than 10.  If you set this parameter as nil, the SDK ignores this parameter when retrieving messages.
 *  @param aDirection       The message search direction. See {@link EMMessageSearchDirection}.
 *                          - `UP`: The SDK retrieves messages in the descending order of the timestamp included in them.
 *                          - `DOWN`：The SDK retrieves messages in the ascending order of the timestamp included in them.
 *  @param aScope             The message search scope. See {@link EMMessageSearchScope}.
 *  @param aCompletionBlock The completion block, which contains the error message if the method fails.
 *
 */
- (void)loadMessagesWithKeyword:(NSString* _Nullable)aKeywords
                      timestamp:(long long)aTimestamp
                          count:(int)aCount
                       fromUsers:(NSArray<NSString*>* _Nullable)senders
                searchDirection:(EMMessageSearchDirection)aDirection
                          scope:(EMMessageSearchScope)aScope
                     completion:(void (^ _Nullable)(NSArray<EMChatMessage *> * _Nullable aMessages, EMError * _Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  从本地数据库获取会话中的指定用户发送的包含特定关键词的自定义消息。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param aKeywords        关键词。设为 NIL 表示忽略该参数。
 *  @param aTimestamp       传入的时间戳，单位为毫秒。如果该参数设置的时间戳为负数，则从最新消息向前获取。
 *  @param aCount           每次获取的消息条数。如果设为小于等于 0，SDK 会获取 1 条消息。
 *  @param aSender          消息发送方。设为 NIL 表示忽略该参数。
 *  @param aDirection       消息搜索方向，详见 {@link EMMessageSearchDirection}。
 *
 *  @result 消息列表。
 *
 *
 *  \~english
 *  Loads custom messages with keywords that the specified user sends in the conversation.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aKeywords         The keywords for query. Setting it as NIL means that the SDK ignores this parameter.
 *  @param aTimestamp       The starting Unix timestamp in the message for query. The unit is millisecond. After this parameter is set, the SDK retrieves messages, starting from the specified one, according to the message search direction.
     *                      If this parameter is set as a negative value, the SDK retrieves from the current time.
 *  @param aCount           The number of messages to load each time. If you set this parameter to a value less than 1, the SDK retrieves one message.
 *  @param aSender          The message sender. Setting it as NIL means that the SDK ignores this parameter.
 *  @param aDirection       The message search direction. See {@link EMMessageSearchDirection}.
 *  @result EMChatMessage   The message list.
 *
 */
- (NSArray<EMChatMessage *> * _Nullable)loadCustomMsgWithKeyword:(NSString*)aKeywords
                       timestamp:(long long)aTimestamp
                           count:(int)aCount
                        fromUser:(NSString* _Nullable)aSender
                 searchDirection:(EMMessageSearchDirection)aDirection;

/**
 *  \~chinese
 * 从本地数据库获取会话中的指定用户发送的包含特定关键词的自定义消息。
 *
 *  @param aKeywords        关键词。设为 NIL 表示忽略该参数。
 *  @param aTimestamp       传入的 Unix 时间戳，单位为毫秒。如果该参数设置的时间戳为负数，则从最新消息向前获取。
 *  @param aCount           每次获取的消息条数。如果设为小于等于 0，SDK 会获取 1 条消息。
 *  @param aSender          消息发送方。设为 NIL 表示忽略该参数。
 *  @param aDirection       消息搜索方向，详见 {@link EMMessageSearchDirection}。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Loads custom messages with keywords that the specified user sends in the conversation.
 *
 *  @param aKeywords         The keyword for searching the messages. Setting it as NIL means that the SDK ignores this parameter.
 *  @param aTimestamp       The starting Unix timestamp in the message for query. The unit is millisecond. After this parameter is set, the SDK retrieves messages, starting from the specified one, according to the message search direction.
     *                      If this parameter is set as a negative value, the SDK retrieves from the current time.
 *  @param aCount           The number of messages to load each time. If you set this parameter to a value less than 1, the SDK retrieves one message.
 *  @param aSender          The message sender. Setting it as NIL means that the SDK ignores this parameter.
 *  @param aDirection       The message search direction. See {@link EMMessageSearchDirection}.
 *  @param aCompletionBlock The completion block, which contains the error message if the method fails.
 *
 */
- (void)loadCustomMsgWithKeyword:(NSString* _Nullable)aKeywords
                       timestamp:(long long)aTimestamp
                           count:(int)aCount
                        fromUser:(NSString* _Nullable)aSender
                 searchDirection:(EMMessageSearchDirection)aDirection
                      completion:(void (^ _Nullable)(NSArray<EMChatMessage *> * _Nullable aMessages, EMError * _Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  从本地数据库中搜索指定时间段内发送或接收的一定数量的消息。
 *
 *  该方法返回的消息按时间正序排列。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param aStartTimestamp  搜索的起始时间戳。单位为毫秒。
 *  @param aEndTimestamp    搜索的结束时间戳。单位为毫秒。
 *  @param aCount           每次获取的消息条数。如果设为小于等于 0，SDK 会获取 1 条消息。
 *
 *  @result 消息列表。
 *
 *
 *  \~english
 *  Loads a certain quantity of messages sent or received in a certain period from the local database.
 *
 *  Messages are retrieved in the ascending order of the timestamp included in them.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aStartTimestamp  The starting Unix timestamp in the message for query. The unit is millisecond.
 *  @param aEndTimestamp    The ending Unix timestamp in the message for query. The unit is millisecond.
 *  @param aCount           The number of messages to load each time. If you set this parameter to a value less than 1, the SDK retrieves one message.
 *
 *  @result EMChatMessage       The message list.
 *
 */
- (NSArray<EMChatMessage *> * _Nullable)loadMessagesFrom:(long long)aStartTimestamp
                      to:(long long)aEndTimestamp
                   count:(int)aCount;

/**
 *  \~chinese
 *  从本地数据库中搜索指定时间段内发送或接收的一定数量的消息。
 *
 *  @param aStartTimestamp  搜索的起始时间戳。单位为毫秒。
 *  @param aEndTimestamp    搜索的结束时间戳。单位为毫秒。
 *  @param aCount           每次获取的消息条数。如果设为小于等于 0，SDK 会获取 1 条消息。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Loads a certain quantity of messages sent or received in a certain period from the local database.
 *
 *  @param aStartTimestamp  The starting Unix timestamp in the message for query. The unit is millisecond.
 *  @param aEndTimestamp    The ending Unix timestamp in the message for query. The unit is millisecond.
 *  @param aCount           The number of messages to load each time. If you set this parameter to a value less than 1, the SDK retrieves one message.
 *  @param aCompletionBlock The completion block, which contains the error message if the method fails.
 *
 */
- (void)loadMessagesFrom:(long long)aStartTimestamp
                      to:(long long)aEndTimestamp
                   count:(int)aCount
              completion:(void (^ _Nullable)(NSArray<EMChatMessage *> * _Nullable aMessages, EMError * _Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  从本地数据库中删除指定时间段内的消息。
 *
 *  @param aStartTimestamp  删除消息的起始时间。UNIX 时间戳，单位为毫秒。
 *  @param aEndTimestamp    删除消息的结束时间。UNIX 时间戳，单位为毫秒。
 *  @return EMError         消息是否删除成功：
                            - 若操作成功，返回 `nil`。
                            - 若操作失败，返回错误原因，例如参数错误或数据库操作失败。
 *
 *  \~english
 *  Deletes messages sent or received in a certain period from the local database.
 *
 *  @param aStartTimestamp  The starting UNIX timestamp for message deletion. The unit is millisecond.
 *  @param aEndTimestamp    The end UNIX timestamp for message deletion. The unit is millisecond.
 *  @return EMError         Whether the message deletion succeeds:
 *                          - If the operation succeeds, the SDK returns `nil`.
 *                          - If the operation fails, the SDK returns the failure reason such as the parameter error or database operation failure.
 *
 */
- (EMError* _Nullable)removeMessagesStart:(NSInteger)aStartTimestamp
                                       to:(NSInteger)aEndTimestamp;

/**
 * \~chinese
 * 获取本地会话指定时间段内的消息数量。
 * @param aStartTimestamp 起始时间戳(包含)，单位为毫秒。
 * @param aEndTimestamp 结束时间戳(包含)，单位为毫秒。
 * @return 返回会话指定时间段内的消息数量。
 *
 *
 * \~english
 * Gets the number of messages in a conversation within a certain period of time.
 * @param aStartTimestamp The starting timestamp for query. The unit is millisecond.
 * @param aEndTimestamp The ending timestamp for query. The unit is millisecond.
 * @return The number of messages in a conversation within a certain period of time.
 *
 */
- (NSInteger)getMessageCountStart:(NSInteger)aStartTimestamp
                               to:(NSInteger)aEndTimestamp;
@end
