// 5.0 兼容辅助类：给 4.x wrapper 提供 5.0 移除/改名的方法（类方法形式，block 参数与 4.x 调用一致）
#import <HyphenateChat/HyphenateChat.h>

@interface ChatCompat5 : NSObject

+ (void)sendMessageReadAck:(id)chatManager msgId:(NSString *)msgId toUser:(NSString *)to completion:(void (^)(EMError * _Nullable))completion;
+ (void)sendGroupMessageReadAck:(id)chatManager msgId:(NSString *)msgId toGroup:(NSString *)groupId content:(NSString *)content completion:(void (^)(EMError * _Nullable))completion;
+ (void)ackConversationRead:(id)chatManager conversationId:(NSString *)conversationId completion:(void (^)(EMError * _Nullable))completion;
+ (void)markAllConversationsAsRead:(id)chatManager;
+ (void)asyncFetchGroupMessageAcks:(id)chatManager msgId:(NSString *)msgId groupId:(NSString *)groupId startAckId:(NSString *)startAckId pageSize:(int)pageSize completion:(void (^)(EMCursorResult * _Nullable, EMError * _Nullable, int))completion;
+ (void)asyncFetchHistoryMessages:(id)chatManager conversationId:(NSString *)conversationId type:(EMConversationType)type startMsgId:(NSString *)startMsgId direction:(int)direction pageSize:(int)pageSize completion:(void (^)(EMCursorResult<EMChatMessage *> * _Nullable, EMError * _Nullable))completion;
+ (void)getConversationsFromServer:(id)chatManager completion:(void (^)(NSArray * _Nullable, EMError * _Nullable))completion;
+ (void)getConversationsFromServerByPage:(id)chatManager pageNum:(int)pageNum pageSize:(int)pageSize completion:(void (^)(NSArray<EMConversation *> * _Nullable, EMError * _Nullable))completion;
+ (void)getConversationsFromServerWithCursor:(id)chatManager cursor:(NSString *)cursor pageSize:(int)pageSize completion:(void (^)(EMCursorResult * _Nullable, EMError * _Nullable))completion;
+ (void)getConversationsFromServerWithCursor:(id)chatManager cursor:(NSString *)cursor filter:(id)filter completion:(void (^)(EMCursorResult * _Nullable, EMError * _Nullable))completion;
+ (void)getPinnedConversationsFromServerWithCursor:(id)chatManager cursor:(NSString *)cursor pageSize:(int)pageSize completion:(void (^)(EMCursorResult * _Nullable, EMError * _Nullable))completion;
+ (void)reportMessage:(id)chatManager msgId:(NSString *)msgId tag:(NSString *)tag reason:(NSString *)reason completion:(void (^)(EMError * _Nullable))completion;
+ (void)resendMessage:(id)chatManager message:(EMChatMessage *)message progress:(void (^)(int))progress completion:(void (^)(EMChatMessage * _Nullable, EMError * _Nullable))completion;
+ (void)notSupported:(void (^)(EMError * _Nullable))completion;

@end
