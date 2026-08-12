// 5.0 兼容辅助类实现
#import "ChatManagerCompat5.h"
#import "ConversationHelper.h"

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
    // 对齐 names 表：分页获取群消息已读回执（asyncFetchGroupMessageReadUsersFromServer ↔ Android asyncFetchGroupMessageReadReceipts）
    [chatManager asyncFetchGroupMessageReadUsersFromServer:msgId
                                                   groupId:groupId
                                             readReceiptId:startAckId
                                                  pageSize:pageSize
                                                completion:^(EMCursorResult<EMGroupReadReceipt *> * _Nullable aResult, EMError * _Nullable aError, int totalCount) {
        if (completion) completion(aResult, aError, totalCount);
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
    // 5.0 移除拉取接口，改用本地会话列表（与 Android 一致：getAllConversationsBySort）
    if (completion) completion([chatManager getAllConversations], nil);
}

+ (void)getConversationsFromServerByPage:(id)chatManager pageNum:(int)pageNum pageSize:(int)pageSize completion:(void (^)(NSArray<EMConversation *> * _Nullable, EMError * _Nullable))completion {
    // 5.0 移除拉取接口，改用本地会话列表（与 Android 一致）
    if (completion) completion([chatManager getAllConversations], nil);
}

+ (void)getConversationsFromServerWithCursor:(id)chatManager cursor:(NSString *)cursor pageSize:(int)pageSize completion:(void (^)(NSArray * _Nullable, EMError * _Nullable))completion {
    // 5.0 移除拉取接口，改用本地会话列表（与 Android 一致：返回纯 list，无 cursor 语义）
    if (completion) completion([self localConversationsToJson:chatManager], nil);
}

+ (void)getConversationsFromServerWithCursor:(id)chatManager cursor:(NSString *)cursor filter:(id)filter completion:(void (^)(NSArray * _Nullable, EMError * _Nullable))completion {
    // 5.0 移除拉取接口，改用本地会话列表（与 Android 一致）
    if (completion) completion([self localConversationsToJson:chatManager], nil);
}

+ (void)getPinnedConversationsFromServerWithCursor:(id)chatManager cursor:(NSString *)cursor pageSize:(int)pageSize completion:(void (^)(NSArray * _Nullable, EMError * _Nullable))completion {
    // 5.0 移除拉取接口，改用本地会话列表（与 Android 一致）
    if (completion) completion([self localConversationsToJson:chatManager], nil);
}

// 本地会话 → JSON dict 列表（供桥接序列化；原生 EMConversation 对象无法直接过 JSON 序列化）
+ (NSArray *)localConversationsToJson:(id)chatManager {
    NSArray *list = [chatManager getAllConversations];
    NSMutableArray *result = [NSMutableArray array];
    for (EMConversation *conv in list) {
        [result addObject:[conv toJson]];
    }
    return result;
}

+ (void)reportMessage:(id)chatManager msgId:(NSString *)msgId tag:(NSString *)tag reason:(NSString *)reason completion:(void (^)(EMError * _Nullable))completion {
    [self notSupported:completion];
}

+ (void)resendMessage:(id)chatManager message:(EMChatMessage *)message progress:(void (^)(int))progress completion:(void (^)(EMChatMessage * _Nullable, EMError * _Nullable))completion {
    [chatManager sendMessage:message progress:progress completion:completion];
}

@end
