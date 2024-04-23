/**
 *  \~chinese
 *  @header IEMChatManager.h
 *  @abstract 聊天相关操作代理协议。
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header IEMChatManager.h
 *  @abstract This protocol defines the operations of chat.
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>

#import "EMCommonDefs.h"
#import "EMChatManagerDelegate.h"
#import "EMConversation.h"

#import "EMChatMessage.h"
#import "EMTextMessageBody.h"
#import "EMLocationMessageBody.h"
#import "EMCmdMessageBody.h"
#import "EMFileMessageBody.h"
#import "EMImageMessageBody.h"
#import "EMVoiceMessageBody.h"
#import "EMVideoMessageBody.h"
#import "EMCustomMessageBody.h"
#import "EMCursorResult.h"

#import "EMGroupMessageAck.h"
#import "EMTranslateLanguage.h"

/**
 *  \~chinese
 *  拉取漫游消息方向枚举类型。
 *
 *  \~english
 *  The message search direction type.
 */
typedef NS_ENUM(NSUInteger, EMMessageFetchHistoryDirection) {
    EMMessageFetchHistoryDirectionUp  = 0,    /** \~chinese 向上搜索类型。  \~english The  older messages type.*/
    EMMessageFetchHistoryDirectionDown        /** \~chinese 向下搜索类型。 \~english The  newer messages type.*/
};


@class EMError;

/**
 *  \~chinese
 *  聊天相关操作代理协议。
 *  消息都是从本地数据库中加载，不是从服务端加载。
 *
 *  \~english
 *  This protocol defines the operations of chat.
 *  The current messages are loaded from the local database, not from the server.
 */
@protocol IEMChatManager <NSObject>

@required

#pragma mark - Delegate

/**
 *  \~chinese
 *  添加回调代理。
 *
 *  @param aDelegate  实现代理协议的对象。
 *  @param aQueue     执行代理方法的队列。
 *
 *  \~english
 *  Adds a delegate.
 *
 *  @param aDelegate  The object that implements the protocol.
 *  @param aQueue     (optional) The queue of calling delegate methods. If you want to run the app on the main thread, set this parameter as nil.
 */
- (void)addDelegate:(id<EMChatManagerDelegate> _Nullable)aDelegate
      delegateQueue:(dispatch_queue_t _Nullable)aQueue;

/**
 *  \~chinese
 *  移除回调代理。
 *
 *  @param aDelegate  要移除的代理。
 *
 *  \~english
 *  Removes a delegate.
 *
 *  @param aDelegate  The delegate to be removed.
 */
- (void)removeDelegate:(id<EMChatManagerDelegate> _Nonnull)aDelegate;

#pragma mark - Conversation

/**
 *  \~chinese
 *  获取所有会话，如果缓存中不存在会从本地数据库中加载。
 *
 *  @result 会话列表。
 *
 *  \~english
 *  Gets all conversations in the local database. The SDK loads the conversations from the cache first. If no conversation is in the cache, the SDK loads from the local database.
 *
 *  @result The conversation NSArray.
 */
- (NSArray<EMConversation *> * _Nullable)getAllConversations;

/**
 *  \~chinese
 *  从服务器获取所有会话。
 * 
 *  @param aCompletionBlock     该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Gets all conversations from the server.
 * 
 *  @param aCompletionBlock     The completion block, which contains the error message if the method fails.
 */
- (void)getConversationsFromServer:(void (^_Nullable)(NSArray<EMConversation *> * _Nullable aConversations, EMError * _Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  从本地数据库中获取一个已存在的会话。
 *
 *  @param aConversationId  会话 ID。
 *
 *  @result 会话对象。
 *
 *  \~english
 *  Gets a conversation from the local database.
 *
 *  @param aConversationId  The conversation ID.
 *
 *  @result The conversation object.
 */
- (EMConversation *_Nullable)getConversationWithConvId:(NSString * _Nullable)aConversationId;

/**
 *  \~chinese
 *  获取一个会话。
 *
 *  @param aConversationId  会话 ID。
 *  @param aType            会话类型。
 *  @param aIfCreate        如果不存在是否创建。
 *
 *  @result 会话对象。
 *
 *  \~english
 *  Gets a conversation from the local database.
 *
 *  @param aConversationId  The conversation ID.
 *  @param aType            The conversation type (Must be specified).
 *  @param aIfCreate        Whether to create the conversation if it does not exist.
 *
 *  @result The conversation.
 */
- (EMConversation *_Nullable)getConversation:(NSString *_Nonnull)aConversationId
                               type:(EMConversationType)aType
                   createIfNotExist:(BOOL)aIfCreate;

/**
 *  \~chinese
 *  获取一个会话。
 *
 *  @param aConversationId  会话 ID。
 *  @param aType            会话类型。
 *  @param aIfCreate        如果不存在是否创建。
 *  @param isThread 是否是threadChat类型的会话
 *  @result 会话对象。
 *
 *  \~english
 *  Gets a conversation from the local database.
 *
 *  @param aConversationId  The conversation ID.
 *  @param aType            The conversation type (Must be specified).
 *  @param aIfCreate        Whether to create the conversation if it does not exist.
 *  @param isThread  Whether it is a threadChat type of session
 *  @result The conversation.
 */
- (EMConversation *_Nullable)getConversation:(NSString *_Nonnull)aConversationId
                               type:(EMConversationType)aType
                   createIfNotExist:(BOOL)aIfCreate isThread:(BOOL)isThread;

/**
 *  \~chinese
 *  从本地数据库中删除一个会话。
 *
 *  @param aConversationId      会话 ID。
 *  @param aIsDeleteMessages    是否删除会话中的消息。
 * - `YES`: 是；
 * - `NO`: 否。
 *  @param aCompletionBlock     该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Deletes a conversation from the local database.
 *  @param aConversationId      The conversation ID.
 *  @param aIsDeleteMessages    Whether to delete the messages in the conversation.
 *  - `Yes`: Yes;
 *  - `No`: No.
 *  @param aCompletionBlock     The completion block, which contains the error message if the method call fails.
 *
 */
- (void)deleteConversation:(NSString * _Nonnull)aConversationId
          isDeleteMessages:(BOOL)aIsDeleteMessages
                completion:(void (^_Nullable)(NSString * _Nullable aConversationId, EMError *_Nullable aError))aCompletionBlock;

/*!
  *  \~chinese
  *  删除服务器会话。
  *
  *  @param aConversationId      会话 ID。
  *  @param aConversationType    会话类型。
  *  @param aIsDeleteMessages    是否同时删除会话中的消息。
  *   - `YES`: 是；
  *   - `NO`: 否。
  *  @param aCompletionBlock     该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
  *
  *  \~english
  *  Deletes a conversation from the server.
  *
  *  @param aConversationId      The conversation ID.
  *  @param aConversationType    The conversation type.
  *  @param aIsDeleteMessages    Whether to delete the related messages with the conversation.
  *                          - `Yes`: Yes;
  *                          - `No`: No.
  *  @param aCompletionBlock     The completion block, which contains the error message if the method call fails.
  *
  */
 - (void)deleteServerConversation:(NSString * _Nonnull)aConversationId
                 conversationType:(EMConversationType)aConversationType
           isDeleteServerMessages:(BOOL)aIsDeleteServerMessages
                       completion:(void (^_Nullable)(NSString * _Nullable aConversationId, EMError * _Nullable aError))aCompletionBlock;

/*!
 *  \~chinese
 *  删除一组会话。
 *
 *  @param aConversations       会话列表。
 *  @param aIsDeleteMessages    是否删除会话中的消息。
 *   - `YES`: 是；
 *   - `NO`: 否。
 *  @param aCompletionBlock     该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Deletes multiple conversations.
 *
 *  @param aConversations       The conversation list.
 *  @param aIsDeleteMessages    Whether to delete the messages.
 *  - `Yes`: Yes;
 *  - `No`: No.
 *  @param aCompletionBlock     The completion block, which contains the error message if the method fails.
 *
 */
- (void)deleteConversations:(NSArray<EMConversation *> * _Nullable)aConversations
           isDeleteMessages:(BOOL)aIsDeleteMessages
                 completion:(void (^_Nullable)(EMError * _Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  导入一组会话到本地数据库。
 *
 *  @param aConversations   会话列表。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *
 *  \~english
 *  Imports multiple conversations to the local database.
 *
 *  @param aConversations       The conversation list.
 *  @param aCompletionBlock     The completion block, which contains the error message if the method fails.
 *
 */
- (void)importConversations:(NSArray<EMConversation *> * _Nullable)aConversations
                 completion:(void (^ _Nullable)(EMError * _Nullable aError))aCompletionBlock;

#pragma mark - Message

/**
 *  \~chinese
 *  获取指定的消息。
 * 
 *  @param  aMessageId   消息 ID。
 * 
 *  @result   获取到的消息。
 *
 *  \~english
 *  Gets the specified message.
 *
 *  @param aMessageId    The message ID.
 *  @result EMChatMessage     The message content.
 */
- (EMChatMessage * _Nullable)getMessageWithMessageId:(NSString * _Nonnull)aMessageId;

/**
 *  \~chinese
 *  获取一个会话中消息附件的本地路径。
 *  
 *  删除会话时，会话中的消息附件也会被删除。
 *
 *  @param aConversationId  会话 ID。
 *
 *  @result 附件路径。
 *
 *  \~english
 *  Gets the local path of message attachments in a conversation. Delete the conversation will also delete the files under the file path.
 *
 *  @param aConversationId  The conversation ID.
 *
 *  @result The attachment path.
 */
- (NSString * _Nullable)getMessageAttachmentPath:(NSString * _Nonnull)aConversationId;

/**
 *  \~chinese
 *  导入一组消息到本地数据库。
 *
 *  @param aMessages        消息列表。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Imports multiple messages to the local database.
 *
 *  @param aMessages            The message NSArray.
 *  @param aCompletionBlock     The completion block, which contains the error message if the method fails.
 *
 */
- (void)importMessages:(NSArray<EMChatMessage *> * _Nonnull)aMessages
            completion:(void (^_Nullable)(EMError *_Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  更新消息到本地数据库，会话中最新的消息会先更新，消息 ID 不会更新。
 *
 *  @param aMessage         消息。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Updates a message in the local database. Latest Message of the conversation and other properties will be updated accordingly. MessageId of the message cannot be updated.
 *
 *  @param aMessage             The message instance.
 *  @param aCompletionBlock     The completion block, which contains the error message if the method fails.
 *
 */
- (void)updateMessage:(EMChatMessage *_Nonnull)aMessage
           completion:(void (^_Nullable)(EMChatMessage * _Nullable aMessage, EMError * _Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  发送消息已读回执。
 *
 *  异步方法。
 *
 *  @param aMessage             消息 ID。
 *  @param aUsername            已读接收方。
 *  @param aCompletionBlock     该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Sends the read receipt for a message.
 * 
 *  This is an asynchronous method.
 *
 *  @param aMessageId           The message ID.
 *  @param aUsername            The receiver of the read receipt.
 *  @param aCompletionBlock     The completion block, which contains the error message if the method fails.
 *
 */
- (void)sendMessageReadAck:(NSString * _Nonnull)aMessageId
                    toUser:(NSString * _Nonnull)aUsername
                completion:(void (^_Nullable)(EMError *_Nullable aError))aCompletionBlock;


/**
 *  \~chinese
 *  发送群消息已读回执。
 *
 *  异步方法。
 *
 *  @param aMessageId           消息 ID。
 *  @param aGroupId             群组 ID。
 *  @param aContent             消息内容。
 *  @param aCompletionBlock     该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Sends the read receipt for a group message.
 * 
 *  This is an asynchronous method.
 *
 *  @param aMessageId           The message ID.
 *  @param aGroupId             The group receiver ID.
 *  @param aContent             The message content.
 *  @param aCompletionBlock     The completion block, which contains the error message if the method fails.
 *
 */
- (void)sendGroupMessageReadAck:(NSString * _Nonnull)aMessageId
                        toGroup:(NSString * _Nonnull)aGroupId
                        content:(NSString * _Nullable)aContent
                     completion:(void (^_Nullable)(EMError *_Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  发送会话已读回执。
 *  
 *  该方法仅适用于单聊会话。
 *  
 *  发送会话已读回执会通知服务器将指定的会话未读消息数置为 0。调用该方法后对方会收到 onConversationRead 回调。
 *  对话方（包含多端多设备）将会在回调方法 EMChatManagerDelegate onConversationRead(String, String) 中接收到回调。
 *
 *  为了减少调用次数，我们建议在进入聊天页面有大量未读消息时调用该方法，在聊天过程中调用 sendMessageReadAck 方法发送消息已读回执。
 *  
 *
 *  异步方法。
 *
 *  @param conversationId         会话 ID。
 *  @param aCompletionBlock       该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Sends the conversation read receipt to the server.
 * 
 *  This method applies to one-to-one chats only.
 * 
 *  This method call notifies the server to set the number of unread messages of the specified conversation as 0, and triggers the onConversationRead callback on the receiver's client.
 *
 *  To reduce the number of method calls, we recommend that you call this method when the user enters a conversation with many unread messages, and call sendMessageReadAck during a conversation to send the message read receipts.
 * 
 *  This is an asynchronous method.
 * 
 *  @param conversationId          The conversation ID.
 *  @param aCompletionBlock        The completion block, which contains the error message if the method fails.
 * 
 */
- (void)ackConversationRead:(NSString * _Nonnull)conversationId
                 completion:(void (^_Nullable)(EMError *_Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  撤回一条消息。
 *
 *  异步方法。
 *
 *  @param aMessageId           消息 ID。
 *  @param aCompletionBlock     该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Recalls a message.
 *
 *  This is an asynchronous method.
 *
 *  @param aMessageId           The message ID
 *  @param aCompletionBlock     The completion block, which contains the error message if the method fails.
 *
 */
- (void)recallMessageWithMessageId:(NSString *_Nonnull)aMessageId
                        completion:(void (^_Nullable)(EMError *_Nullable aError))aCompletionBlock;


/**
 *  \~chinese
 *  发送消息。
 * 
 *  异步方法。
 *
 *  @param aMessage         消息。
 *  @param aProgressBlock   附件上传进度回调。如果该方法调用失败，会包含调用失败的原因。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Sends a message.
 * 
 *  This is an asynchronous method.
 *
 *  @param aMessage             The message instance.
 *  @param aProgressBlock       The block of attachment upload progress in percentage, 0~100.
 *  @param aCompletionBlock     The completion block, which contains the error message if the method fails.
 */
- (void)sendMessage:(EMChatMessage *_Nonnull)aMessage
           progress:(void (^_Nullable)(int progress))aProgressBlock
         completion:(void (^_Nullable)(EMChatMessage *_Nullable message, EMError *_Nullable error))aCompletionBlock;

/**
 *  \~chinese
 *  重新发送消息。
 *
 *  @param aMessage         消息对象。
 *  @param aProgressBlock   附件上传进度回调 block。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Resends a message.
 *
 *  @param aMessage             The message object.
 *  @param aProgressBlock       The callback block of attachment upload progress.
 *  @param aCompletionBlock     The completion block, which contains the error message if the method fails.
 */
- (void)resendMessage:(EMChatMessage *_Nonnull)aMessage
             progress:(void (^_Nullable)(int progress))aProgressBlock
           completion:(void (^_Nullable)(EMChatMessage *_Nullable message, EMError *_Nullable error))aCompletionBlock;

/**
 *  \~chinese
 *  下载缩略图（图片消息的缩略图或视频消息的第一帧图片）。
 * 
 *  SDK 会自动下载缩略图。如果自动下载失败，你可以调用该方法下载缩略图。
 *
 *  @param aMessage            消息对象。
 *  @param aProgressBlock      附件下载进度回调 block。
 *  @param aCompletionBlock    该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Downloads the message thumbnail (the thumbnail of an image message or the first frame of a video message).
 * 
 *  The SDK automatically downloads the thumbnail. If the auto-download fails, you can call this method to manually download the thumbnail.
 *
 *  @param aMessage             The message object.
 *  @param aProgressBlock       The callback block of attachment download progress.
 *  @param aCompletionBlock     The completion block, which contains the error message if the method fails.
 */
- (void)downloadMessageThumbnail:(EMChatMessage *_Nonnull)aMessage
                        progress:(void (^_Nullable)(int progress))aProgressBlock
                      completion:(void (^_Nullable)(EMChatMessage *_Nullable message, EMError *_Nullable error))aCompletionBlock;

/**
 *  \~chinese
 *  下载消息附件（语音、视频、图片原图、文件）。
 * 
 *  SDK 会自动下载语音消息。如果自动下载失败，你可以调用该方法。
 *
 *  异步方法。
 *
 *  @param aMessage            消息。
 *  @param aProgressBlock      附件下载进度回调 block。
 *  @param aCompletionBlock    该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Downloads message attachment (voice, video, image or file). 
 *  
 *  SDK handles attachment downloading automatically. If automatic download failed, you can download attachment manually.
 *
 *  This is an asynchronous method.
 * 
 *  @param aMessage             The message object.
 *  @param aProgressBlock       The callback block of attachment download progress.
 *  @param aCompletionBlock     The completion block, which contains the error message if the method fails.
 */
- (void)downloadMessageAttachment:(EMChatMessage *_Nonnull)aMessage
                         progress:(void (^_Nullable)(int progress))aProgressBlock
                       completion:(void (^_Nullable)(EMChatMessage *_Nullable message, EMError *_Nullable error))aCompletionBlock;



/**
 *  \~chinese
 *  从服务器获取指定会话的消息。
 *
 *  @param  aConversationId     要获取消息的 Conversation ID。
 *  @param  aConversationType   要获取消息的 Conversation type。
 *  @param  aStartMessageId     起始消息的 ID。
 *  @param  direction      EMMessageFetchHistoryDirection 根据某条消息向上或者向下
 *  @param  aPageSize           获取消息条数。
 *  @param  pError              错误信息。
 *
 *  @result     获取的消息内容列表。
 *
 *
 *  \~english
 *  Fetches conversation messages from server.
 
 *  @param aConversationId      The conversation id which select to fetch message.
 *  @param aConversationType    The conversation type which select to fetch message.
 *  @param aStartMessageId      The start message id, if empty, start from the server‘s last message.
 *  @param direction      EMMessageFetchHistoryDirection up or down
 *  @param aPageSize            The page size.
 *  @param pError               The error information if the method fails: Error.
 *
 *  @result    The messages list.
 */
- (EMCursorResult<EMChatMessage*> *_Nullable)fetchHistoryMessagesFromServer:(NSString *_Nonnull)aConversationId
                                  conversationType:(EMConversationType)aConversationType
                                    startMessageId:(NSString *_Nullable)aStartMessageId
                                       fetchDirection:(EMMessageFetchHistoryDirection)direction
                                          pageSize:(int)aPageSize
                                             error:(EMError **_Nullable)pError;
/**
 *  \~chinese
 *  从服务器获取指定会话的消息。
 *
 *  @param  aConversationId     要获取消息的 Conversation ID。
 *  @param  aConversationType   要获取消息的 Conversation type。
 *  @param  aStartMessageId     起始消息的 ID。
 *  @param  aPageSize           获取消息条数。
 *  @param  pError              错误信息。
 *
 *  @result     获取的消息内容列表。
 *
 *
 *  \~english
 *  Fetches conversation messages from server.
 
 *  @param aConversationId      The conversation id which select to fetch message.
 *  @param aConversationType    The conversation type which select to fetch message.
 *  @param aStartMessageId      The start message id, if empty, start from the server‘s last message.
 *  @param aPageSize            The page size.
 *  @param pError               The error information if the method fails: Error.
 *
 *  @result    The messages list.
 */
- (EMCursorResult<EMChatMessage*> *_Nullable)fetchHistoryMessagesFromServer:(NSString *_Nonnull)aConversationId
                                  conversationType:(EMConversationType)aConversationType
                                    startMessageId:(NSString *_Nullable)aStartMessageId
                                          pageSize:(int)aPageSize
                                             error:(EMError **_Nullable)pError;


/**
 *  \~chinese
 *  从服务器获取指定会话的消息。
 *
 *  异步方法。
 *
 *  @param  aConversationId     要获取消息的 Conversation ID。
 *  @param  aConversationType   要获取消息的 Conversation type。
 *  @param  aStartMessageId     起始消息的 ID。
 *  @param  aPageSize           获取消息条数。
 *  @param  aCompletionBlock    获取消息结束的 callback。
 *
 *
 *  \~english
 *  Fetches conversation messages from server.
 * 
 *  This is an asynchronous method.
 * 
 *  @param aConversationId      The conversation id which select to fetch message.
 *  @param aConversationType    The conversation type which select to fetch message.
 *  @param aStartMessageId      The start message id, if empty, start from the server last message.
 *  @param aPageSize            The page size.
 *  @param aCompletionBlock     The callback block of fetch complete, which contains the error message if the method fails.
 */
- (void)asyncFetchHistoryMessagesFromServer:(NSString *_Nonnull)aConversationId
                           conversationType:(EMConversationType)aConversationType
                             startMessageId:(NSString *_Nullable)aStartMessageId
                                   pageSize:(int)aPageSize
                                 completion:(void (^_Nullable)(EMCursorResult<EMChatMessage*> *_Nullable aResult, EMError *_Nullable aError))aCompletionBlock;
/**
 *  \~chinese
 *  从服务器获取指定会话的消息。
 *
 *  异步方法。
 *
 *  @param  aConversationId     要获取消息的 Conversation ID。
 *  @param  aConversationType   要获取消息的 Conversation type。
 *  @param  aStartMessageId     起始消息的 ID。
 *  @param direction      EMMessageFetchHistoryDirection 向上或者向下
 *  @param  aPageSize           获取消息条数。（单次限制最大50条）
 *  @param  aCompletionBlock    获取消息结束的 callback。
 *
 *
 *  \~english
 *  Fetches conversation messages from server.
 *
 *  This is an asynchronous method.
 *
 *  @param aConversationId      The conversation id which select to fetch message.
 *  @param aConversationType    The conversation type which select to fetch message.
 *  @param aStartMessageId      The start message id, if empty, start from the server last message.
 *  @param direction      EMMessageFetchHistoryDirection up or down
 *  @param aPageSize            The page size. limit 50
 *  @param aCompletionBlock     The callback block of fetch complete, which contains the error message if the method fails.
 */
- (void)asyncFetchHistoryMessagesFromServer:(NSString *_Nonnull)aConversationId
                           conversationType:(EMConversationType)aConversationType
                             startMessageId:(NSString *_Nullable)aStartMessageId
                             fetchDirection:(EMMessageFetchHistoryDirection)direction
                                   pageSize:(int)aPageSize
                                 completion:(void (^_Nullable)(EMCursorResult<EMChatMessage*> *_Nullable aResult, EMError *_Nullable aError))aCompletionBlock;

 


/**
 *  \~chinese
 *  从服务器获取指定群消息的已读回执，即指定的群消息有多少人已读。
 *
 *  异步方法。
 *
 *  @param  aMessageId           要获取的消息 ID。
 *  @param  aGroupId             要获取回执对应的群 ID。
 *  @param  aGroupAckId          要获取的群回执 ID。
 *  @param  aPageSize            获取消息条数。
 *  @param  aCompletionBlock     该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *
 *  \~english
 *  Fetches the read back receipt of specified group messages from the server.
 * 
 *  This is an asynchronous method.
 * 
 *  @param  aMessageId           The message ID which select to fetch.
 *  @param  aGroupId             The group ID which select to fetch.
 *  @param  aGroupAckId          The group ack ID which select to fetch.
 *  @param  aPageSize            The page size.
 *  @param  aCompletionBlock     The callback block of fetch complete, which contains the error message if the method fails.
 */
- (void)asyncFetchGroupMessageAcksFromServer:(NSString *_Nonnull)aMessageId
                                     groupId:(NSString *_Nonnull)aGroupId
                             startGroupAckId:(NSString *_Nonnull)aGroupAckId
                                    pageSize:(int)aPageSize
                                  completion:(void (^_Nullable)(EMCursorResult<EMGroupMessageAck *> *_Nullable aResult, EMError *_Nullable error, int totalCount))aCompletionBlock;

/**
 *  \~chinese
 *  举报违规消息
 *
 *  异步方法
 *
 *  @param  aMessageId           违规消息id
 *  @param  aTag                         举报类型
 *  @param  aReason                  举报原因
 *  @param  aCompletion         执行上报结果
 *
 *
 *  \~english
 *  Report violation message
 
 *  @param  aMessageId              Violation Message ID
 *  @param  aTag                            Report tag
 *  @param  aReason                     Report reasons
 *  @param  aCompletion            The callback block of fetch complete
 */
- (void)reportMessageWithId:(NSString *_Nonnull )aMessageId
                        tag:(NSString *_Nonnull)aTag
                     reason:(NSString *_Nonnull)aReason
                 completion:(void(^_Nullable)(EMError* _Nullable error))aCompletion;

/*!
 *  \~chinese
 *  删除某个时间点之前的消息。
 *
 *  异步方法。
 *
 *  @param aTimestamp            指定的时间点，Unix 时间戳，单位为毫秒。
 *  @param aCompletion           该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Deletes messages with timestamp that is before the specified one.
 *
 *  @param aTimestamp            The specified Unix timestamp(miliseconds).
 *  @param aCompletion           The completion block, which contains the error message if the method fails.
 *
 */
- (void)deleteMessagesBefore:(NSUInteger)aTimestamp
                  completion:(void(^)(EMError*error))aCompletion;



/**
 *  \~chinese
 *  从会话中删除消息（包括本地存储和服务器存储）。
 *  @param conversation 会话对象EMConversation
 *  @param messageIds   要删除消息id字符串数组。
 *  @param completion   接口回调成功或者失败
 *
 *  \~english
 *  Delete messages from the session (both local storage and server storage).
 *  @param conversation EMConversation object.
 *  @param messageIds   Array<String> that you want delete form current conversation.
 *  @param completion   Callback result from server.
 *
 */
- (void)removeMessagesFromServerWithConversation:(EMConversation *_Nonnull)conversation messageIds:(NSArray <__kindof NSString*>*_Nonnull)messageIds completion:(void (^ _Nullable)(EMError * _Nullable aError))aCompletionBlock;
/**
 *  \~chinese
 *  从会话中删除消息（包括本地存储和服务器存储）。
 *  @param conversation 会话对象EMConversation
 *  @param beforeTimeStamp   要删除哪一条消息之前的消息时间戳。
 *  @param completion   接口回调成功或者失败
 *
 *  \~english
 *  Delete messages from the session (both local storage and server storage).
 *
 *  @param conversation EMConversation object.
 *  @param messageIds   The message timestamp before which message to delete form current conversation.
 *  @param completion   Callback result from server.
 *
 */
- (void)removeMessagesFromServerWithConversation:(EMConversation *_Nonnull)conversation timeStamp:(NSTimeInterval)beforeTimeStamp completion:(void (^ _Nullable)(EMError * _Nullable aError))aCompletionBlock;


/*!
 *  \~chinese
 *  翻译消息。
 *
 *  @param aMessage         消息对象。
 *  @param aLanguages       目标语言.
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Translate a message.
 *
 *  @param aMessage             The message object.
 *  @param aLanguages           The target languages.
 *  @param aCompletionBlock     The completion block, which contains the error message if the method fails.
 */
- (void)translateMessage:(EMChatMessage * _Nonnull)aMessage
         targetLanguages:(NSArray<NSString*>* _Nonnull)aLanguages
              completion:(void (^_Nullable)(EMChatMessage * _Nullable message, EMError * _Nullable error))aCompletionBlock;

/*!
 *  \~chinese
 *  获取翻译服务支持的语言。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *
 *  Gets the list of supported languages for translation.
 *
 *  @param aCompletionBlock The completion block, which contains the error message if the method fails.
 */
- (void)fetchSupportedLanguages:(void(^_Nullable)(NSArray<EMTranslateLanguage*>* _Nullable languages,EMError* _Nullable error))aCompletionBlock;

/**
 *  \~chinese
 *  通过关键词从数据库获取消息。
 * 
 *  该方法返回的消息按时间顺序排列。
 * 
 *  同步方法，会阻塞当前线程。
 *
 *  @param aType            消息类型。
 *  @param aTimestamp       参考时间戳。如果该参数设置的时间戳为负数，则从最新消息向前获取。
 *  @param aCount           获取的消息条数。如果设为小于等于 0，SDK 会将该参数作 1 处理。
 *  @param aUsername        消息发送方。设为 nil 表示忽略该参数。
 *  @param aDirection       消息搜索方向，详见 {@link MessageSearchDirection}。
 *                          - `UP`：按时间逆序。
 *                          - `DOWN`：按时间顺序。
 *
 *  @result 消息列表。 <EMChatMessage>
 *
 *  \~english
 *  Loads messages with the specified keyword from the local database.
 * 
 *  This method returns messages in the sequence of the timestamp when they are received.
 * 
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aType            The message type to load.
 *  @param aTimestamp       The reference timestamp for the messages to be loaded. If you set this parameter as a negative value, the SDK loads messages from the latest.
 *  @param aCount           The number of messages to load. If you set this parameter less than 1, it will be handled as count=1.
 *  @param aUsername        Message sender (optional). Use aUsername=nil to ignore.
 *  @param aDirection       The message search directions: {@link MessageSearchDirection}.
 *                          - `UP`: In the reverse chronological order.
 *                          - `DOWN`：In the chronological order.
 *
 *  @result EMChatMessage NSArray.
 *
 */
- (NSArray<EMChatMessage *> * _Nullable)loadMessagesWithType:(EMMessageBodyType)aType
                                                   timestamp:(long long)aTimestamp
                                                       count:(int)aCount
                                                    fromUser:(NSString* _Nullable)aUsername
                                             searchDirection:(EMMessageSearchDirection)aDirection;

/**
 *  \~chinese
 *  通过关键词从数据库获取消息。
 * 
 *  该方法返回的消息按时间顺序排列。
 *
 *  @param aType            消息类型。
 *  @param aTimestamp       参考时间戳。如果该参数设置的时间戳为负数，则从最新消息向前获取。
 *  @param aCount           获取的消息条数。如果设为小于等于 0，SDK 会将该参数作 1 处理。
 *  @param aUsername        消息发送方。设为 nil 表示忽略该参数。
 *  @param aDirection       消息搜索方向，详见 {@link MessageSearchDirection}。
 *                          - `UP`：按时间逆序。
 *                          - `DOWN`：按时间顺序。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Loads messages with the specified keyword from the local database.
 * 
 *  This method returns messages in the sequence of the timestamp when they are received.
 *
 *  @param aType            The message type to load.
 *  @param aTimestamp       The reference timestamp for the messages to be loaded. If you set this parameter as a negative value, the SDK loads messages from the latest.
 *  @param aCount           The number of messages to load. If you set this parameter less than 1, it will be handled as count=1
 *  @param aUsername        The user that sends the message. Setting it as nil means that the SDK ignores this parameter.
 *  @param aDirection       The message search directions: {@link MessageSearchDirection}.
 *                          - `UP`: In the reverse chronological order.
 *                          - `DOWN`：In the chronological order.
 *  @param aCompletionBlock The completion block, which contains the error message if the method fails.
 *
 */
- (void)loadMessagesWithType:(EMMessageBodyType)aType
                   timestamp:(long long)aTimestamp
                       count:(int)aCount
                    fromUser:(NSString*)aUsername
             searchDirection:(EMMessageSearchDirection)aDirection
                  completion:(void (^)(NSArray<EMChatMessage *> *aMessages, EMError *aError))aCompletionBlock;

/**
 *  \~chinese
 *  通过关键词从数据库获取消息。
 * 
 *  该方法返回的消息按时间顺序排列。
 * 
 *  同步方法，会阻塞当前线程。
 *
 *  @param aKeywords        关键词。设为 nil 表示忽略该参数。
 *  @param aTimestamp       参考时间戳。如果该参数设置的时间戳为负数，则从最新消息向前获取。
 *  @param aCount           获取的消息条数。如果设为小于等于 0，SDK 会将该参数作 1 处理。
 *  @param aSender          消息发送方。设为 nil 表示忽略该参数。
 *  @param aDirection       消息搜索方向，详见 {@link MessageSearchDirection}。
 *                          - `UP`：按时间逆序。
 *                          - `DOWN`：按时间顺序。
 *
 *  @result 消息列表。
 *
 *  \~english
 *  Loads messages with the specified keyword from the local database.
 *
 *  This method returns messages in the sequence of the timestamp when they are received.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aKeyword         The keyword for searching the messages. Setting it as nil means that the SDK ignores this parameter.
 *  @param aTimestamp       The reference timestamp for the messages to be loaded. If you set this parameter as a negative value, the SDK loads messages from the latest.
 *  @param aCount           The number of messages to load. If you set this parameter less than 1, it will be handled as count=1.
 *  @param aSender          The user that sends the message.
 *  @param aDirection       The message search directions: {@link MessageSearchDirection}.
 *                          - `UP`: In the reverse chronological order.
 *                          - `DOWN`：In the chronological order.
 *
 *  @result EMChatMessage NSArray. <EMChatMessage>
 *
 */
- (NSArray<EMChatMessage *> *)loadMessagesWithKeyword:(NSString*)aKeywords
                      timestamp:(long long)aTimestamp
                          count:(int)aCount
                       fromUser:(NSString*)aSender
                searchDirection:(EMMessageSearchDirection)aDirection;

/**
 *  \~chinese
 *  通过关键词从数据库获取消息。
 * 
 *  该方法返回的消息按时间逆序返回排列。
 *
 *  @param aKeywords        搜索关键词，设为 nil 表示忽略该参数。
 *  @param aTimestamp       参考时间戳。如果该参数设置的时间戳为负数，则从最新消息向前获取。
 *  @param aCount           获取的消息条数。如果设为小于等于 0，SDK 会将该参数作 1 处理。
 *  @param aSender          消息发送方。设为 nil 表示忽略该参数。
 *  @param aDirection       消息搜索方向，详见 {@link MessageSearchDirection}。
 *                          - `UP`：按时间逆序。
 *                          - `DOWN`：按时间顺序。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Loads messages with the specified keyword from the local database.
 * 
 *  This method returns messages in the sequence of the timestamp when they are received.
 *
 *  @param aKeyword         The keyword for searching the messages. Setting it as nil means that the SDK ignores this parameter.
 *  @param aTimestamp       The reference timestamp for the messages to be loaded. If you set this parameter as a negative value, the SDK loads messages from the latest.
 *  @param aCount           The number of messages to load. If you set this parameter less than 1, it will be handled as count=1.
 EMMessageSearchDirectionDown: get aCount of messages after aMessageId *  ----
 *  @param aSender          The sender of the message. Setting it as nil means that the SDK ignores this parameter.
 *  @param aDirection       The message search directions: {@link MessageSearchDirection}.
 *                          - `UP`: In the reverse chronological order.
 *                          - `DOWN`：In the chronological order.
 *  @param aCompletionBlock  The completion block which contains the error code and error information if the method fails.
 */
- (void)loadMessagesWithKeyword:(NSString*)aKeywords
                      timestamp:(long long)aTimestamp
                          count:(int)aCount
                       fromUser:(NSString*)aSender
                searchDirection:(EMMessageSearchDirection)aDirection
                     completion:(void (^)(NSArray<EMChatMessage *> *aMessages, EMError *aError))aCompletionBlock;

NS_ASSUME_NONNULL_BEGIN
/*!
 *  \~chinese
 *  添加 Reaction。
 *
 *  @param reaction  Reaction 内容。
 *  @param messageId  消息 ID。
 *  @param completion  该方法完成的回调。如果有错误会包含错误信息。
 *
 *  \~english
 *  Adds a Reaction.
 *
 *  @param reaction  The Reaction content.
 *  @param messageId  The message ID.
 *  @param completion  The completion block which contains the error code and error information if the method fails.
 */
- (void)addReaction:(NSString *)reaction toMessage:(NSString *)messageId completion:(nullable void(^)(EMError * _Nullable))completion;

/*!
 *  \~chinese
 *  删除 Reaction。
 *
 *  @param reaction  Reaction 内容。
 *  @param messageId  消息 ID。
 *  @param completion  该方法完成的回调。如果有错误会包含错误信息。
 *
 *  \~english
 *  Removes a Reaction.
 *
 *  @param reaction  The Reaction content.
 *  @param messageId  The message ID.
 *  @param completion  The completion block which contains the error code and error information if the method fails.
 */
- (void)removeReaction:(NSString *)reaction fromMessage:(NSString *)messageId completion:(nullable void(^)(EMError * _Nullable))completion;

/*!
 *  \~chinese
 *  获取消息的 Reaction 列表。
 *
 *  @param messageId  消息 ID。
 *  @param groupId  群组 ID，该参数只在群聊生效。
 *  @param chatType  会话类型，仅支持单聊（ {@link EMChatTypeChat} ）和群聊（{@link EMChatTypeGroupChat}）。
 *  @param completion  该方法完成的回调。如果有错误会包含错误信息。
 *
 *  \~english
 *  Gets the Reaction list.
 *
 *  @param messageId  The message ID.
 *  @param groupId  The group ID. This parameter is invalid only for group chat.
 *  @param chatType  The chat type. Only one-to-one chat ({@link EMChatTypeChat} and group chat ({@link EMChatTypeGroupChat}) are allowed.
 *  @param completion The completion block which contains the error code and error information if the method fails.
 */
- (void)getReactionList:(NSArray <NSString *>*)messageIds
                groupId:(nullable NSString *)groupId
               chatType:(EMChatType)chatType
             completion:(void (^)(NSDictionary <NSString *, NSArray<EMMessageReaction *> *> *, EMError * _Nullable))completion;

/*!
 *  \~chinese
 *  分页获取群聊消息的 Reaction 详细列表。
 *
 *  @param messageId  消息 ID。
 *  @param reaction  Reaction 内容。
 *  @param cursor  查询的开始位置。首次调用该方法可传 `nil` 或 `@""` 以 Reaction 创建时间的正序获取。
 *  @param pageSize  每页期望返回的 Reaction 数量。该值不能超过 100。
 *  @param completion  该方法完成的回调，返回 Reaction 列表和用于继续获取数据的 cursor。当 cursor 为 `nil` 时表示已获取全部数据。
 *
 *  \~english
 *  Gets the Reaction detail list of a chat group message with pagination.
 *
 *  @param messageId  The message ID.
 *  @param reaction  The Reaction content.
 *  @param cursor  The cursor that specifies where to start to get data. If it is `nil` or `@""`, the SDK retrieves Reactions in the chronological order of their creation time.
 *  @param pageSize   The number of Reactions that you expect to get on each page. The value cannot exceed 100.
 *  @param completion  The completion block, which contains the Reaction list and the cursor for the next query. When the cursor is `nil`, all data is fetched.
 */
- (void)getReactionDetail:(NSString *)messageId
                 reaction:(NSString *)reaction
                    cursor:(nullable NSString *)cursor
                 pageSize:(uint64_t)pageSize
               completion:(void (^)(EMMessageReaction *, NSString * _Nullable cursor, EMError * _Nullable))completion;

NS_ASSUME_NONNULL_END

@end
