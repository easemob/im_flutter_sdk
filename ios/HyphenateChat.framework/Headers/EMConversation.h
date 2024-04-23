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

/**
 *  \~chinese
 *  会话枚举类型。
 *
 *  \~english
 *  The conversation type.
 */
typedef NS_ENUM(NSInteger, EMConversationType) {
    EMConversationTypeChat = 0,    /** \~chinese 单聊会话类型。  \~english The one-to-one chat type. */
    EMConversationTypeGroupChat,    /** \~chinese 群聊会话类型。  \~english The group chat type.*/
    EMConversationTypeChatRoom,      /** \~chinese 聊天室会话类型。 \~english The chat room type.*/
};

/**
 *  \~chinese
 *  消息搜索方向枚举类型。
 *
 *  \~english
 *  The message search direction type.
 */
typedef NS_ENUM(NSInteger, EMMessageSearchDirection) {
    EMMessageSearchDirectionUp  = 0,    /** \~chinese 向上搜索类型。  \~english The search older messages type.*/
    EMMessageSearchDirectionDown        /** \~chinese 向下搜索类型。 \~english The search newer messages type.*/
};

@class EMChatMessage;
@class EMError;

/**
 *  \~chinese
 *  聊天会话类。
 *
 *  \~english
 *  The chat conversation.
 */
@interface EMConversation : NSObject

/**
 *  \~chinese
 *  会话 ID。
 *  对于单聊类型，会话 ID 同时也是对方用户的名称。
 *  对于群聊类型，会话 ID 同时也是对方群组的 ID，并不同于群组的名称。
 *  对于聊天室类型，会话 ID 同时也是聊天室的 ID，并不同于聊天室的名称。
 *  对于 HelpDesk 类型，会话 ID 与单聊类型相同，是对方用户的名称。
 *
 *  \~english
 *  The conversation ID.
 *  For one-to-one chat，conversation ID is to chat user's name.
 *  For group chat, conversation ID is groupID(), different with getGroupName().
 *  For chat room, conversation ID is chatroom ID, different with chat room name().
 *  For help desk, it is same with one-to-one chat, conversation ID is also chat user's name.
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
 *  对话中未读取的消息数量。
 *
 *  \~english
 *  The number of unread messages.
 */
@property (nonatomic, assign, readonly) int unreadMessagesCount;

/**
 *  \~chinese
 *  对话中的消息数量
 *
 *  \~english
 *  Message count
 */
@property (nonatomic, assign, readonly) int messagesCount;

/**
 *  \~chinese
 *  会话扩展属性 子区功能目前版本暂不可设置
 *
 *  \~english
 *  The conversation extension property.
 */
@property (nonatomic, copy) NSDictionary *ext;

/*!
 *  \~chinese
 *  判断是否是thread会话。
 *
 *  \~english
 *  The latest message in the conversation.
 */
@property (nonatomic, assign) BOOL isChatThread;

/*!
 *  \~chinese
 *  会话最新一条消息。
 *
 *  \~english
 *  The latest message in the conversation.
 */
@property (nonatomic, strong, readonly) EMChatMessage *latestMessage;

/**
 *  \~chinese
 *  收到的对方发送的最后一条消息，也是会话里的最新消息。
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
 *  插入一条消息在 SDK 本地数据库，消息的 conversation ID 应该和会话的 conversation ID 一致，消息会根据消息里的时间戳被插入 SDK 本地数据库，并且更新会话的 latestMessage 等属性。
 * 
 *  insertMessage 会更新对应 Conversation 里的 latestMessage。
 * 
 *  Method EMConversation insertMessage:error: = EMChatManager importMsessage:completion: + update conversation latest message
 *
 *  @param aMessage 消息实例。
 *  @param pError   错误信息。
 *
 *  \~english
 *  Inserts a message to a conversation in local database and SDK will update the last message automatically.
 * 
 *  The conversation ID of the message should be the same as conversation ID of the conversation in order to insert the message into the conversation correctly. The inserting message will be inserted based on timestamp.
 * 
 *  Method EMConversation insertMessage:error: = EMChatManager importMsessage:completion: + update conversation latest message
 *
 *  @param aMessage The message instance.
 *  @param pError   The error information if the method fails: Error.
 */
- (void)insertMessage:(EMChatMessage *_Nonnull)aMessage
                error:(EMError ** _Nullable)pError;

/**
 *  \~chinese
 *  插入一条消息到 SDK 本地数据库会话尾部，消息的 conversationId 应该和会话的 conversationId 一致，消息会被插入 SDK 本地数据库，并且更新会话的 latestMessage 等属性。
 *
 *  @param aMessage 消息实例。
 *  @param pError   错误信息。
 *
 *  \~english
 *  Inserts a message to the end of a conversation in local database. The conversationId of the message should be the same as the conversationId of the conversation in order to insert the message into the conversation correctly.
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
 *  @param aMessageId   要删除消失的 ID。
 *  @param pError       错误信息。
 *
 *  \~english
 *  Deletes a message.
 *
 *  @param aMessageId   The ID of the message to be deleted.
 *  @param pError       The error information if the method fails: Error.
 *
 */
- (void)deleteMessageWithId:(NSString *_Nonnull)aMessageId
                      error:(EMError ** _Nullable)pError;

/**
 *  \~chinese
 *  删除 SDK 本地数据库中该会话所有消息，清除 SDK 本地数据库中的消息。
 *
 *  @param pError       错误信息。
 *
 *  \~english
 *  Deletes all messages of the conversation from memory cache and local database.
 *
 *  @param pError       The error information if the method fails: Error.
 */
- (void)deleteAllMessages:(EMError ** _Nullable)pError;


/**
 *  \~chinese
 *  从会话中删除消息（包括本地存储和服务器存储）。
 *  @param messageIds   要删除消息id字符串数组。
 *  @param completion   接口回调成功或者失败
 *
 *  \~english
 *  Delete messages from the session (both local storage and server storage).
 *  @param messageIds   Array<String> that you want delete form current conversation.
 *  @param completion   Callback result from server.
 *
 */
- (void)removeMessagesFromServerMessageIds:(NSArray <__kindof NSString*>*_Nonnull)messageIds completion:(void (^ _Nullable)(EMError * _Nullable aError))aCompletionBlock;
/**
 *  \~chinese
 *  从会话中删除消息（包括本地存储和服务器存储）。
 *  @param beforeTimeStamp   要删除哪一条消息之前的消息时间戳。
 *  @param completion   接口回调成功或者失败
 *
 *  \~english
 *  Delete messages from the session (both local storage and server storage).
 *
 *  @param messageIds   The message timestamp before which message to delete form current conversation.
 *  @param completion   Callback result from server.
 *
 */
- (void)removeMessagesFromServerWithTimeStamp:(NSTimeInterval)beforeTimeStamp completion:(void (^ _Nullable)(EMError * _Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  更新 SDK 本地数据库的消息。
 * 
 *  不能更新消息 ID，消息更新后，会话的 latestMessage 等属性进行相应更新。
 *
 *  @param aMessage 要更新的消息。
 *  @param pError   错误信息。
 *
 *  \~english
 *  Uses this method to update a message in local database. Changing properties will affect data in database.
 * 
 *  The latestMessage of the conversation and other properties will be updated accordingly. The messageID of the message cannot be updated.
 *
 *  @param aMessage The message to be updated.
 *  @param pError   The error information if the method fails: Error.
 *
 */
- (void)updateMessageChange:(EMChatMessage *_Nonnull)aMessage
                      error:(EMError ** _Nullable)pError;

/**
 *  \~chinese
 *  将 SDK 本地数据库消息设置为已读。
 *
 *  @param aMessageId   要设置消息的 ID。
 *  @param pError       错误信息。
 *
 *  \~english
 *  Marks a message as read.
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
 *  Marks all messages as read.
 *
 *  @param pError   The error information if the method fails: Error.
 *
 */
- (void)markAllMessagesAsRead:(EMError ** _Nullable)pError;


#pragma mark - Load Messages Methods

/**
 *  \~chinese
 *  从 SDK 本地数据库获取指定 ID 的消息。
 *
 *  @param aMessageId       消息 ID。
 *  @param pError           错误信息。
 *
 *  \~english
 *  Gets a message with the ID.
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
 *  取到的消息按时间排序，并且不包含参考的消息，如果传入消息的 ID 为空，则从最新消息取。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param aMessageId       传入消息的 ID。
 *  @param aCount           获取的消息条数。如果设为小于等于 0，SDK 会将该参数作 1 处理。
 *  @param aDirection       消息搜索方向，详见 EMMessageSearchDirection。
 *
 *  @result 消息列表。
 *
 *  \~english
 *  Loads messages starting from the specified message id from local database. 
 * 
 *  This method returns messages in the sequence of the timestamp when they are received.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aMessageId       The specified message ID.
 *  @param aCount           The number of messages to load. If you set this parameter less than 1, it will be handled as count=1.
 *  @param aDirection       The message search direction: EMMessageSearchDirection.
                            EMMessageSearchDirectionUp: get aCount of messages before aMessageId;
                            EMMessageSearchDirectionDown: get aCount of messages after aMessageId
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
 *  该方法返回的消息按时间顺序排列。
 *
 *  @param aMessageId       参考消息的 ID。
 *  @param aCount           获取的消息条数。如果设为小于等于 0，SDK 会将该参数作 1 处理。
 *  @param aDirection       消息搜索方向，详见 EMMessageSearchDirection。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Loads messages starting from the specified message ID from local database.
 * 
 *  Returning messages are sorted by receiving timestamp based on EMMessageSearchDirection. If the aMessageId is nil, will return starting from the latest message.
 *
 *  @param aMessageId       The specified message ID loading messages start from.
 *  @param aCount           The number of messages to load. If you set this parameter less than 1, it will be handled as count=1.
 *  @param aDirection       The message search direction: EMMessageSearchDirection. 
                            EMMessageSearchDirectionUp: get aCount of messages before the timestamp of the specified message ID; 
                            EMMessageSearchDirectionDown: get aCount of messages after the timestamp of the specified message ID.
 *  @param aCompletionBlock The completion block, which contains the error message if the method fails.
 *
 */
- (void)loadMessagesStartFromId:(NSString * _Nullable)aMessageId
                          count:(int)aCount
                searchDirection:(EMMessageSearchDirection)aDirection
                     completion:(void (^ _Nullable)(NSArray<EMChatMessage *> * _Nullable aMessages, EMError * _Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  从 SDK 本地数据库获取指定类型的消息。
 * 
 *  该方法返回的消息按时间顺序排列。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param aType            消息类型，txt:文本消息，img：图片消息，loc：位置消息，audio：语音消息，video：视频消息，file：文件消息，cmd: 透传消息。
 *  @param aTimestamp       当前传入消息的设备时间戳，单位为毫秒。如果该参数设置的时间戳为负数，则从最新消息向前获取。
 *  @param aCount           获取的消息条数。如果设为小于等于 0，SDK 会将该参数作 1 处理。
 *  @param aUsername        消息发送方。设为 NIL 表示忽略该参数。
 *  @param aDirection       消息搜索方向，详见 EMMessageSearchDirection。
 *
 *  @result 消息列表。
 *
 *  \~english
 *  Loads messages with specified message type from local database. Returning messages are sorted by receiving timestamp based on EMMessageSearchDirection.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aType            The message type to load. Type includes txt : text msg, img : image msg, loc: location msg, audio: audio msg, video: video msg, file: file msg, cmd:  command msg.
 *  @param aTimestamp       The reference timestamp for the messages to be loaded. If you set this parameter as a negative value, the SDK loads messages from the latest.
 *  @param aCount           The number of messages to load. If you set this parameter less than 1, it will be handled as count=1.
 *  @param aUsername        The user that sends the message. Setting it as NIL means that the SDK ignores this parameter.
 *  @param aDirection       The message search direction: EMMessageSearchDirection.
                            EMMessageSearchDirectionUp: get aCount of messages before aMessageId;
                            EMMessageSearchDirectionDown: get aCount of messages after aMessageId
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
 *  从 SDK 本地数据库获取指定类型的消息，取到的消息按时间排序，如果参考的时间戳为负数，则从最新消息取，如果 aCount 小于等于 0 当作 1 处理。
 *
 *  @param aType            消息类型，txt:文本消息，img：图片消息，loc：位置消息，audio：语音消息，video：视频消息，file：文件消息，cmd: 透传消息。
 *  @param aTimestamp       当前传入消息的设备时间戳，单位为毫秒。如果该参数设置的时间戳为负数，则从最新消息向前获取。
 *  @param aCount           获取的消息条数。如果设为小于等于 0，SDK 会将该参数作 1 处理。
 *  @param aUsername        消息发送方。设为 NIL 表示忽略该参数。
 *  @param aDirection       消息搜索方向，详见 EMMessageSearchDirection。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Loads messages with specified message type from local database. Returning messages are sorted by receiving timestamp based on EMMessageSearchDirection.
 *
 *  @param aType            The message type to load. Type includes txt : text msg, img : image msg, loc: location msg, audio: audio msg, video: video msg, file: file msg, cmd:  command msg.
 *  @param aTimestamp       The reference timestamp for the messages to be loaded. If you set this parameter as a negative value, the SDK loads messages from the latest.
 *  @param aCount           The number of messages to load. If you set this parameter less than 1, it will be handled as count=1.
 *  @param aUsername        The message sender (optional). If the parameter is nil, ignore.
 *  @param aDirection       The message search direction.
                            EMMessageSearchDirectionUp: get aCount of messages before aMessageId;
                            EMMessageSearchDirectionDown: get aCount of messages after aMessageId
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
 *  从 SDK 本地数据库获取包含指定内容的全部类型的消息，取到的消息按时间排序，如果参考的时间戳为负数，则从最新消息向前取，如果 aCount 小于等于 0 当作 1 处理。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param aKeywords        搜索关键词，设为 NIL 表示忽略该参数。
 *  @param aTimestamp       传入的时间戳，单位为毫秒。如果该参数设置的时间戳为负数，则从最新消息向前获取。
 *  @param aCount           获取的消息条数。如果设为小于等于 0，SDK 会将该参数作 1 处理。
 *  @param aSender          消息发送方，设为 NIL 表示忽略该参数。
 *  @param aDirection       消息搜索方向，详见 EMMessageSearchDirection。
 *
 *  @result 消息列表。
 *
 *  \~english
 *  Loads messages with specified keyword from local database, returning messages are sorted by receiving timestamp based on EMMessageSearchDirection. If reference timestamp is negative, load from the latest messages; if message count is negative, will be handled as count=1
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aKeyword         The keyword for searching the messages. Setting it as NIL means that the SDK ignores this parameter.
 *  @param aTimestamp       The reference timestamp for the messages to be loaded. If you set this parameter as a negative value, the SDK loads messages from the latest.
 *  @param aCount           The number of messages to load. If you set this parameter less than 1, it will be handled as count=1.
 *  @param aSender          The message sender (optional). If the parameter is nil, ignore.
 *  @param aDirection       The message search direction: EMMessageSearchDirection.
                            EMMessageSearchDirectionUp: get aCount of messages before aMessageId;
                            EMMessageSearchDirectionDown: get aCount of messages after aMessageId *  ----
 *
 *  @result EMChatMessage  The message list.
 *
 */
- (NSArray<EMChatMessage *> * _Nullable)loadMessagesWithKeyword:(NSString* _Nullable)aKeyword
                      timestamp:(long long)aTimestamp
                          count:(int)aCount
                       fromUser:(NSString* _Nullable)aSender
                searchDirection:(EMMessageSearchDirection)aDirection;

/**
 *  \~chinese
 *  从 SDK 本地数据库获取包含指定内容的全部类型的消息，取到的消息按时间排序，如果参考的时间戳为负数，则从最新消息向前取，如果 aCount 小于等于 0 当作 1 处理。
 *
 *  @param aKeywords        关键词。设为 NIL 表示忽略该参数。
 *  @param aTimestamp       传入的 Unix 时间戳，单位为毫秒。如果该参数设置的时间戳为负数，则从最新消息向前获取。
 *  @param aCount           获取的消息条数。如果设为小于等于 0，SDK 会将该参数作 1 处理。
 *  @param aSender          消息发送方。设为 NIL 表示忽略该参数。
 *  @param aDirection       消息搜索方向，详见 EMMessageSearchDirection。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Loads messages with specified keyword from local database. Returning messages are sorted by receiving timestamp based on EMMessageSearchDirection. If reference timestamp is negative, load from the latest messages; if message count is negative, will be handled as count=1
 *
 *  @param aKeyword         The search keyword. If aKeyword=nil, ignore.
 *  @param aTimestamp       The load based on reference timestamp. If aTimestamp=-1, will load from the most recent (the latest) message
 *  @param aCount           The number of messages to load. If you set this parameter less than 1, it will be handled as count=1.
 *  @param aSender          The message sender (optional). If the parameter is nil, ignore.
 *  @param aDirection       The message search direction.
                            EMMessageSearchDirectionUp: get aCount of messages before aMessageId;
                            EMMessageSearchDirectionDown: get aCount of messages after aMessageId *  ----
 *  @param aCompletionBlock The completion block, which contains the error message if the method fails.
 *
 */
- (void)loadMessagesWithKeyword:(NSString* _Nullable)aKeyword
                      timestamp:(long long)aTimestamp
                          count:(int)aCount
                       fromUser:(NSString* _Nullable)aSender
                searchDirection:(EMMessageSearchDirection)aDirection
                     completion:(void (^ _Nullable)(NSArray<EMChatMessage *> * _Nullable aMessages, EMError * _Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  从 SDK 本地数据库获取包含指定内容的自定义类型消息，如果参考的时间戳为负数，则从最新消息向前取，如果 aCount 小于等于 0 当作 1 处理。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param aKeywords        关键词。设为 NIL 表示忽略该参数。
 *  @param aTimestamp       传入的时间戳，单位为毫秒。如果该参数设置的时间戳为负数，则从最新消息向前获取。
 *  @param aCount           获取的消息条数。如果设为小于等于 0，SDK 会将该参数作 1 处理。
 *  @param aSender          消息发送方。设为 NIL 表示忽略该参数。
 *  @param aDirection       消息搜索方向，详见 EMMessageSearchDirection。
 *
 *  @result 消息列表。
 *
 *
 *  \~english
 *  Loads custom messages with specified keyword from local database. The returning messages are sorted by receiving timestamp based on EMMessageSearchDirection. If the reference timestamp is negative, load from the latest messages; if message count is negative, will be handled as count=1.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aKeyword         The search keyword. If aKeyword=nil, ignore.
 *  @param aTimestamp       The load based on reference timestamp. If aTimestamp=-1, will load from the most recent (the latest) message
 *  @param aCount           The number of messages to load. If you set this parameter less than 1, it will be handled as count=1.
 *  @param aSender          The user that sends the message. Setting it as NIL means that the SDK ignores this parameter.
 *  @param aDirection       The message search direction.
                            EMMessageSearchDirectionUp: get aCount of messages before aMessageId;
                            EMMessageSearchDirectionDown: get aCount of messages after aMessageId *  ----
 *
 *  @result EMChatMessage  The message list.
 *
 */
- (NSArray<EMChatMessage *> * _Nullable)loadCustomMsgWithKeyword:(NSString*)aKeyword
                       timestamp:(long long)aTimestamp
                           count:(int)aCount
                        fromUser:(NSString* _Nullable)aSender
                 searchDirection:(EMMessageSearchDirection)aDirection;

/**
 *  \~chinese
 *  从 SDK 本地数据库获取包含指定内容的自定义类型消息，如果参考的时间戳为负数，则从最新消息向前取，如果 aCount 小于等于 0 当作 1 处理。
 *
 *  @param aKeywords        关键词。设为 NIL 表示忽略该参数。
 *  @param aTimestamp       传入的 Unix 时间戳，单位为毫秒。如果该参数设置的时间戳为负数，则从最新消息向前获取。
 *  @param aCount           获取的消息条数。如果设为小于等于 0，SDK 会将该参数作 1 处理。
 *  @param aSender          消息发送方。设为 NIL 表示忽略该参数。
 *  @param aDirection       消息搜索方向，详见 EMMessageSearchDirection。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Loads custom messages with specified keyword from local database. returning messages are sorted by receiving timestamp based on EMMessageSearchDirection. If reference timestamp is negative, load from the latest messages; if message count is negative, will be handled as count=1
 *
 *  @param aKeyword         The keyword for searching the messages. Setting it as NIL means that the SDK ignores this parameter.
 *  @param aTimestamp       The reference Unix timestamp for the messages to be loaded. If you set this parameter as a negative value, the SDK loads messages from the latest.
 *  @param aCount           The number of messages to load. If you set this parameter less than 1, it will be handled as count=1.
 *  @param aSender          The user that sends the message. Setting it as NIL means that the SDK ignores this parameter.
 *  @param aDirection       The message search direction: EMMessageSearchDirection.
                            EMMessageSearchDirectionUp: get aCount of messages before aMessageId;
                            EMMessageSearchDirectionDown: get aCount of messages after aMessageId *  ----
 *  @param aCompletionBlock The completion block, which contains the error message if the method fails.
 *
 */
- (void)loadCustomMsgWithKeyword:(NSString* _Nullable)aKeyword
                       timestamp:(long long)aTimestamp
                           count:(int)aCount
                        fromUser:(NSString* _Nullable)aSender
                 searchDirection:(EMMessageSearchDirection)aDirection
                      completion:(void (^ _Nullable)(NSArray<EMChatMessage *> * _Nullable aMessages, EMError * _Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  从 SDK 本地数据库获取指定时间段内的消息，取到的消息按时间排序，为了防止占用太多内存，建议你指定加载消息的最大数。
 * 
 *  该方法返回的消息按时间顺序排列。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param aStartTimestamp  毫秒级开始时间。
 *  @param aEndTimestamp    结束时间。
 *  @param aCount           获取的消息条数。如果设为小于等于 0，SDK 会将该参数作 1 处理。
 *
 *  @result 消息列表。
 *
 *
 *  \~english
 *  Loads messages within specified time range from local database. Returning messages are sorted by sending timestamp.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aStartTimestamp  The starting timestamp in miliseconds.
 *  @param aEndTimestamp    The ending timestamp in miliseconds.
 *  @param aCount           The number of messages to load. If you set this parameter less than 1, it will be handled as count=1.
 *
 *  @result EMChatMessage       The message list.
 *
 */
- (NSArray<EMChatMessage *> * _Nullable)loadMessagesFrom:(long long)aStartTimestamp
                      to:(long long)aEndTimestamp
                   count:(int)aCount;

/**
 *  \~chinese
 *  从 SDK 本地数据库获取指定时间段内的消息，取到的消息按时间排序，为了防止占用太多内存，建议你指定加载消息的最大数。
 *
 *  @param aStartTimestamp  毫秒级开始时间。
 *  @param aEndTimestamp    结束时间。
 *  @param aCount           获取的消息条数。如果设为小于等于 0，SDK 会将该参数作 1 处理。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Loads messages within specified time range from local database. Returning messages are sorted by sending timestamp.
 *
 *  @param aStartTimestamp  The starting timestamp in miliseconds.
 *  @param aEndTimestamp    The ending timestamp in miliseconds.
 *  @param aCount           The number of messages to load. If you set this parameter less than 1, it will be handled as count=1.
 *  @param aCompletionBlock The completion block, which contains the error message if the method fails.
 *
 */
- (void)loadMessagesFrom:(long long)aStartTimestamp
                      to:(long long)aEndTimestamp
                   count:(int)aCount
              completion:(void (^ _Nullable)(NSArray<EMChatMessage *> * _Nullable aMessages, EMError * _Nullable aError))aCompletionBlock;

@end
