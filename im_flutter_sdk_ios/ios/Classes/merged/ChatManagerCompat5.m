// 5.0 兼容辅助类实现
#import "ChatManagerCompat5.h"

@implementation ChatCompat5

+ (void)notSupported:(void (^)(EMError * _Nullable))completion {
    if (completion) completion([EMError errorWithDescription:@"not supported in iOS 5.0" code:110]);
}

+ (void)sendMessageReadAck:(id)chatManager msgId:(NSString *)msgId toUser:(NSString *)to completion:(void (^)(EMError * _Nullable))completion {
    EMChatMessage *msg = [chatManager getMessageWithMessageId:msgId];
    [chatManager sendMessageReadReceipts:msg ? @[msg] : @[] completion:completion];
}

+ (void)sendGroupMessageReadAck:(id)chatManager msgId:(NSString *)msgId toGroup:(NSString *)groupId content:(NSString *)content completion:(void (^)(EMError * _Nullable))completion {
    EMChatMessage *msg = [chatManager getMessageWithMessageId:msgId];
    [chatManager sendMessageReadReceipts:msg ? @[msg] : @[] completion:completion];
}

+ (void)ackConversationRead:(id)chatManager conversationId:(NSString *)conversationId completion:(void (^)(EMError * _Nullable))completion {
    [chatManager clearConversationUnreadMessageCount:conversationId completion:completion];
}

+ (void)markAllConversationsAsRead:(id)chatManager {
    [chatManager clearAllConversationUnreadMessageCount:^(EMError * _Nullable aError) {}];
}

+ (void)asyncFetchGroupMessageAcks:(id)chatManager msgId:(NSString *)msgId groupId:(NSString *)groupId startAckId:(NSString *)startAckId pageSize:(int)pageSize completion:(void (^)(EMCursorResult * _Nullable, EMError * _Nullable, int))completion {
    EMChatMessage *msg = [chatManager getMessageWithMessageId:msgId];
    [chatManager getGroupMessageReadReceipts:msg ? @[msg] : @[]
                                  completion:^(NSArray<EMMessageReadReceipt *> * _Nullable aReceipts, EMError * _Nullable aError) {
        EMCursorResult *result = [[EMCursorResult alloc] init];
        result.list = aReceipts;
        if (completion) completion(result, aError, (int)aReceipts.count);
    }];
}

+ (void)asyncFetchHistoryMessages:(id)chatManager conversationId:(NSString *)conversationId type:(EMConversationType)type startMsgId:(NSString *)startMsgId direction:(int)direction pageSize:(int)pageSize completion:(void (^)(EMCursorResult<EMChatMessage *> * _Nullable, EMError * _Nullable))completion {
    EMFetchServerMessagesOption *option = [[EMFetchServerMessagesOption alloc] init];
    option.direction = (EMMessageSearchDirection)(direction == 0 ? EMMessageSearchDirectionUp : EMMessageSearchDirectionDown);
    [chatManager fetchMessagesFromServerBy:conversationId
                          conversationType:type
                                    cursor:startMsgId
                                  pageSize:pageSize
                                    option:option
                                completion:completion];
}

+ (void)getConversationsFromServer:(id)chatManager completion:(void (^)(NSArray * _Nullable, EMError * _Nullable))completion {
    if (completion) completion([chatManager getAllConversations], nil);
}

+ (void)getConversationsFromServerByPage:(id)chatManager pageNum:(int)pageNum pageSize:(int)pageSize completion:(void (^)(NSArray<EMConversation *> * _Nullable, EMError * _Nullable))completion {
    if (completion) completion([chatManager getAllConversations], nil);
}

+ (void)getConversationsFromServerWithCursor:(id)chatManager cursor:(NSString *)cursor pageSize:(int)pageSize completion:(void (^)(EMCursorResult * _Nullable, EMError * _Nullable))completion {
    [self notSupported:^(EMError *e) { if (completion) completion(nil, e); }];
}

+ (void)getConversationsFromServerWithCursor:(id)chatManager cursor:(NSString *)cursor filter:(id)filter completion:(void (^)(EMCursorResult * _Nullable, EMError * _Nullable))completion {
    [self notSupported:^(EMError *e) { if (completion) completion(nil, e); }];
}

+ (void)getPinnedConversationsFromServerWithCursor:(id)chatManager cursor:(NSString *)cursor pageSize:(int)pageSize completion:(void (^)(EMCursorResult * _Nullable, EMError * _Nullable))completion {
    [self notSupported:^(EMError *e) { if (completion) completion(nil, e); }];
}

+ (void)reportMessage:(id)chatManager msgId:(NSString *)msgId tag:(NSString *)tag reason:(NSString *)reason completion:(void (^)(EMError * _Nullable))completion {
    [self notSupported:completion];
}

+ (void)resendMessage:(id)chatManager message:(EMChatMessage *)message progress:(void (^)(int))progress completion:(void (^)(EMChatMessage * _Nullable, EMError * _Nullable))completion {
    [chatManager sendMessage:message progress:progress completion:completion];
}

@end
