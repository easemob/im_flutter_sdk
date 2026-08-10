/**
 *  \~chinese
 *  @header EMChatManagerDelegate.h
 *  @abstract 聊天相关代理协议类。
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header EMChatManagerDelegate.h
 *  @abstract This protocol defines chat related callbacks.
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>
#import "EMRecallMessageInfo.h"

@class EMChatMessage;
@class EMError;
@class EMMessageReactionChange;
@class EMGroupMessageAck;
@class EMConversation;

/**
 *  \~chinese
 *  聊天相关回调的协议类。
 *
 *  \~english
 *  The chat related callbacks.
 */
@protocol EMChatManagerDelegate <NSObject>

@optional

#pragma mark - Conversation

/**
 *  \~chinese
 *  会话列表发生变化的回调。
 *
 *  @param aConversationList  会话列表。 <EMConversation>
 *
 *  \~english
 *  Occurs when the conversation list changes.
 *
 *  @param aConversationList  The conversation NSArray. <EMConversation>
 */
- (void)conversationListDidUpdate:(NSArray<EMConversation *> * _Nonnull)aConversationList;

#pragma mark - Message

/**
 *  \~chinese
 *  收到流式消息的回调。
 *
 *  @param aMessages  消息列表。
 *
 *  \~english
 *  Occurs when the SDK receives new messages.
 *
 *  @param aMessages  The received stream messages. An NSArray of the <EMChatMessage> objects.
 */
- (void)onStreamMessagesReceived:(NSArray<EMChatMessage *> * _Nonnull)messages;

/**
 *  \~chinese
 *  收到消息的回调。
 *
 *  @param aMessages  消息列表。
 *
 *  \~english
 *  Occurs when the SDK receives new messages.
 *
 *  @param aMessages  The received messages. An NSArray of the <EMChatMessage> objects.
 */
- (void)messagesDidReceive:(NSArray<EMChatMessage *> * _Nonnull)aMessages;

/**
 *  \~chinese
 *  收到 CMD 消息代理。
 *
 *  @param aCmdMessages  CMD 消息列表。
 *
 *  \~english
 *  Occurs when receiving command messages.
 *
 *  @param aCmdMessages  The command message NSArray.
 */
- (void)cmdMessagesDidReceive:(NSArray<EMChatMessage *> * _Nonnull)aCmdMessages;

/**
 *  \~chinese
 *  收到已读回执代理。
 *
 *  @param aMessages  已读消息列表。
 *
 *  \~english
 *  Occurs when receiving read acknowledgement in message list.
 *
 *  @param aMessages  The read messages.
 */
- (void)messagesDidRead:(NSArray<EMChatMessage *> * _Nonnull)aMessages;

/**
 *  \~chinese
 *  收到群消息已读回执代理。
 *
 *  @param aMessage  已读消息。
 *  @param aGroupAcks 消息的已读回执列表。
 *
 *  \~english
 *  Occurs when the SDK receives read receipts for group messages.
 *
 *  @param aMessage  The acknowledged message.
 *  @param aGroupAcks The read acks of the message.
 *
 */
- (void)groupMessageDidRead:(EMChatMessage * _Nonnull)aMessage
                  groupAcks:(NSArray<EMGroupMessageAck *> * _Nonnull)aGroupAcks;

/**
 *  \~chinese
 *  当前用户所在群已读消息数量发生变化的回调。
 *
 *  \~english
 *  Occurs when the current group read messages count changed.
 *
 */
- (void)groupMessageAckHasChanged;

/**
 * \~chinese
 * 收到会话已读回调代理。
 *
 * @param from  会话已读回执的发送方。
 * @param to    CHANNEL_ACK 接收方。
 *
 *  发送会话已读的是我方多设备：
 *     则 from 参数值是“我方登录” ID，to 参数值是“会话方”会话 ID，此会话“会话方”发送的消息会全部置为已读 isRead 为 YES。
 *  发送会话已读的是会话方：
 *     则 from 参数值是“会话方”会话 ID，to 参数值是“我方登录” ID，此会话“我方”发送的消息的 isReadAck 会全部置为 YES。
 *  注：此会话既会话方 ID 所代表的会话。
 *
 * \~english
 * Occurs when a conversation read receipt is received.
 * @param from  The username who send channel_ack.
 * @param to    The username who receive channel_ack.
 *
 *  If the conversaion readack is from the current login ID's multiple devices:
 *       The value of the "FROM" parameter is current login ID, and the value of the "to" parameter is the conversation ID. All the messages sent by the conversation are set to read： "isRead" is set to YES.
 *  If the send conversation readack is from the conversation ID's device:
 *       The value of the "FROM" parameter is the conversation ID, and the value of the "to" parameter is current login ID. The "isReaAck" of messages sent by login ID in this session will all be set to YES.
 *  Note: This conversation is the conversation represented by the conversation ID.
 *
 *
 */
- (void)onConversationRead:(NSString * _Nonnull)from to:(NSString * _Nonnull)to;

/**
 *  \~chinese
 *  发送方收到消息已送达的回调。
 *
 *  @param aMessages  送达消息列表。
 *
 *  \~english
 *  Occurs when receiving delivered acknowledgement in message list.
 *
 *  @param aMessages  The acknowledged message NSArray.
 */
- (void)messagesDidDeliver:(NSArray<EMChatMessage *> * _Nonnull)aMessages;

/**
 *  \~chinese
 *  收到消息撤回代理。如果撤回的是离线期间的消息，``EMRecallMessageInfo``对象中的recallMessage会变为空对象。
 *
 *  @param aRecallMessagesInfo  撤回消息列表。
 *
 *  \~english
 *  Occurs when a message is recalled. If the recalled message is offline, the ``EMRecallMessageInfo`` object will be an empty object.
 *
 *  @param aRecallMessagesInfo  The list of recalled messages.
 */
- (void)messagesInfoDidRecall:(NSArray<EMRecallMessageInfo *> * _Nonnull)aRecallMessagesInfo;

/**
 *  \~chinese
 *  消息状态发生变化的回调。消息状态包括消息创建，发送，发送成功，发送失败。
 *
 *  需要给发送消息的 callback 参数传入 nil，此回调才会生效。
 *
 *  @param aMessage  状态发生变化的消息。
 *  @param aError    出错信息。
 *
 *  \~english
 *  Occurs when message status has changed. You need to set the parameter as nil.
 *
 *  @param aMessage  The message whose status has changed.
 *  @param aError    The error information.
 */
- (void)messageStatusDidChange:(EMChatMessage * _Nonnull)aMessage
                         error:(EMError * _Nullable)aError;

/**
 *  \~chinese
 *  消息附件状态发生改变代理。
 *
 *  @param aMessage  附件状态发生变化的消息。
 *  @param aError    错误信息。
 *
 *  \~english
 *  Occurs when the message attachment status changed.
 *
 *  @param aMessage  The message whose attachment status has changed.
 *  @param aError    The error information.
 */
- (void)messageAttachmentStatusDidChange:(EMChatMessage * _Nonnull)aMessage
                                   error:(EMError * _Nullable)aError;
/**
 *  \~chinese
 *  收到消息内容变化。
 *
 *  @param message  修改的消息对象，其中的 message body 包含消息修改次数、最后一次修改的操作者、最后一次修改时间等信息。
 *  @param operatorId    最后一次修改消息的用户。
 *  @param operationTime    消息的最后一次修改时间戳，单位为毫秒。
 *
 *  \~english
 *  Occurs when the message content is modified.
 *
 *  @param message  The modified message object, where the message body contains the information such as the number of message modifications, the operator of the last modification, and the last modification time.Also, you can get the operator of the last message modification and the last modification time via the `onMessageContentChanged` method.
 *  @param operatorId    The user ID of the operator that modified the message last time.
 *  @param operationTime   The last message modification time. It is a UNIX timestamp in milliseconds.
 */
- (void)onMessageContentChanged:(EMChatMessage *_Nonnull)message operatorId:(NSString *_Nonnull)operatorId operationTime:(NSUInteger)operationTime;

/**
 * \~chinese
 * 收到消息置顶状态变更回调。
 *
 * @param messageId 置顶状态变更的消息 ID。
 * @param conversationId 消息所在会话 ID。
 * @param pinOperation 消息置顶或取消置顶操作。
 * @param pinInfo 置顶或取消置顶操作信息，包括操作时间，操作者的用户 ID。
 *
 * \~english
 * Occurs when the message pinning status changed.
 *
 * @param messageId The ID of the message with the changed pinning status.
 * @param conversationId The ID of the conversation that contains the message.
 * @param pinOperation The message pinning or unpinning operation.
 * @param pinInfo The information about message pinning or unpinning, including the operation time and the user ID of the operater.
 */
- (void)onMessagePinChanged:(NSString* _Nonnull)messageId conversationId:(NSString* _Nonnull)conversationId operation:(EMMessagePinOperation)pinOperation pinInfo:(EMMessagePinInfo* _Nonnull)pinInfo;

/*!
 *  \~chinese
 *  Reaction 数据发生改变事件回调。
 *
 *  @param changes  发生改变的 Reaction。
 *
 *  \~english
 *  Occurs when the Reaction data changes.
 *
 *  @param changes The Reaction which is changed.
 */
- (void)messageReactionDidChange:(NSArray<EMMessageReactionChange *>* _Nonnull)changes;
@end
