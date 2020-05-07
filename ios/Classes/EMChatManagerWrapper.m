//
//  EMChatManagerWrapper.m
//  
//
//  Created by 杜洁鹏 on 2019/10/8.
//

#import "EMChatManagerWrapper.h"
#import "EMSDKMethod.h"
#import "EMHelper.h"

@interface EMChatManagerWrapper () <EMChatManagerDelegate> {
    FlutterEventSink _progressEventSink;
    FlutterEventSink _resultEventSink;
}

@end

@implementation EMChatManagerWrapper
- (instancetype)initWithChannelName:(NSString *)aChannelName
                          registrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    if(self = [super initWithChannelName:aChannelName
                               registrar:registrar]) {
        [EMClient.sharedClient.chatManager addDelegate:self delegateQueue:nil];
    }
    return self;
}

#pragma mark - FlutterPlugin

- (void)handleMethodCall:(FlutterMethodCall*)call
                  result:(FlutterResult)result {
    if ([EMMethodKeySendMessage isEqualToString:call.method]) {
        [self sendMessage:call.arguments result:result];
    } else if ([EMMethodKeyAckMessageRead isEqualToString:call.method]) {
        [self ackMessageRead:call.arguments result:result];
    } else if ([EMMethodKeyRecallMessage isEqualToString:call.method]) {
        [self recallMessage:call.arguments result:result];
    } else if ([EMMethodKeyGetMessage isEqualToString:call.method]) {
        [self getMessage:call.arguments result:result];
    } else if ([EMMethodKeyGetConversation isEqualToString:call.method]) {
        [self getConversation:call.arguments result:result];
    } else if ([EMMethodKeyMarkAllChatMsgAsRead isEqualToString:call.method]) {
        [self markAllMessagesAsRead:call.arguments result:result];
    } else if ([EMMethodKeyGetUnreadMessageCount isEqualToString:call.method]) {
        [self getUnreadMessageCount:call.arguments result:result];
    } else if ([EMMethodKeySaveMessage isEqualToString:call.method]) {
        [self saveMessage:call.arguments result:result];
    } else if ([EMMethodKeyUpdateChatMessage isEqualToString:call.method]) {
        [self updateChatMessage:call.arguments result:result];
    } else if ([EMMethodKeyDownloadAttachment isEqualToString:call.method]) {
        [self downloadAttachment:call.arguments result:result];
    } else if ([EMMethodKeyDownloadThumbnail isEqualToString:call.method]) {
        [self downloadThumbnail:call.arguments result:result];
    } else if ([EMMethodKeyImportMessages isEqualToString:call.method]) {
        [self importMessages:call.arguments result:result];
    } else if ([EMMethodKeyGetConversationsByType isEqualToString:call.method]) {
        [self getConversationsByType:call.arguments result:result];
    } else if ([EMMethodKeyDownloadFile isEqualToString:call.method]) {
        [self downloadFile:call.arguments result:result];
    } else if ([EMMethodKeyGetAllConversations isEqualToString:call.method]) {
        [self getAllConversations:call.arguments result:result];
    } else if ([EMMethodKeyLoadAllConversations isEqualToString:call.method]) {
        [self loadAllConversations:call.arguments result:result];
    } else if ([EMMethodKeyDeleteConversation isEqualToString:call.method]) {
        [self deleteConversation:call.arguments result:result];
    } else if ([EMMethodKeySetVoiceMessageListened isEqualToString:call.method]) {
        [self setVoiceMessageListened:call.arguments result:result];
    } else if ([EMMethodKeyUpdateParticipant isEqualToString:call.method]) {
        [self updateParticipant:call.arguments result:result];
    } else if ([EMMethodKeyFetchHistoryMessages isEqualToString:call.method]) {
        [self fetchHistoryMessages:call.arguments result:result];
    } else if ([EMMethodKeySearchChatMsgFromDB isEqualToString:call.method]) {
        [self searchChatMsgFromDB:call.arguments result:result];
    } else if ([EMMethodKeyGetCursor isEqualToString:call.method]) {
        [self getCursor:call.arguments result:result];
    } else if ([EMMethodKeyAddMessageListener isEqualToString:call.method]) {
        [self addMessageListener:call.arguments result:result];
    } else {
        [super handleMethodCall:call result:result];
    }
}

+ (void)registerWithRegistrar:(nonnull NSObject<FlutterPluginRegistrar> *)registrar {
    
}


#pragma mark - Actions

- (void)sendMessage:(NSDictionary *)param result:(FlutterResult)result {
    
    EMMessage *msg = [EMHelper dictionaryToMessage:param];
    
    __block void (^progress)(int progress) = ^(int progress) {
        [self.channel invokeMethod:EMMethodKeyOnMessageStatusOnProgress
                         arguments:@{@"progress":@(progress)}];
    };
    
    __block void (^completion)(EMMessage *message, EMError *error) = ^(EMMessage *message, EMError *error) {
        [self wrapperCallBack:result
                        error:error
                     userInfo:@{@"message":[EMHelper messageToDictionary:message]}];
    };
    
    
    [EMClient.sharedClient.chatManager sendMessage:msg
                                          progress:progress
                                        completion:completion];
}

- (void)ackMessageRead:(NSDictionary *)param result:(FlutterResult)result {
    
}

- (void)recallMessage:(NSDictionary *)param result:(FlutterResult)result {
    
}

- (void)getMessage:(NSDictionary *)param result:(FlutterResult)result {
    
}

- (void)getConversation:(NSDictionary *)param result:(FlutterResult)result {
    NSString *conversationId = param[@"id"];
    EMConversationType type;
    if ([param[@"type"] isKindOfClass:[NSNull class]]){
        type = EMConversationTypeChat;
    }else {
        type = (EMConversationType)[param[@"type"] intValue];
    }
    BOOL isCreateIfNotExists = [param[@"createIfNotExists"] boolValue];
    
    EMConversation *conversation = [EMClient.sharedClient.chatManager getConversation:conversationId
                                                                                 type:type
                                                                     createIfNotExist:isCreateIfNotExists];
    [self wrapperCallBack:result
                    error:nil
                 userInfo:@{@"conversation":[EMHelper conversationToDictionary:conversation]}];
}

// TODO: ios需调添加该实现
- (void)markAllMessagesAsRead:(NSDictionary *)param result:(FlutterResult)result {
    
}

// TODO: ios需调添加该实现
- (void)getUnreadMessageCount:(NSDictionary *)param result:(FlutterResult)result {
    
}

// TODO: 目前这种方式实现后，消息id不一致，考虑如何处理。
- (void)saveMessage:(NSDictionary *)param result:(FlutterResult)result {
    
}

// TODO: 目前这种方式实现后，消息id不一致，考虑如何处理。
- (void)updateChatMessage:(NSDictionary *)param result:(FlutterResult)result {
    
}

- (void)downloadAttachment:(NSDictionary *)param result:(FlutterResult)result {
    [EMClient.sharedClient.chatManager downloadMessageAttachment:[EMHelper dictionaryToMessage:param]
                                                        progress:^(int progress)
     {
        
    } completion:^(EMMessage *message, EMError *error)
     {
        
    }];
}

- (void)downloadThumbnail:(NSDictionary *)param result:(FlutterResult)result {
    [EMClient.sharedClient.chatManager downloadMessageThumbnail:[EMHelper dictionaryToMessage:param]
                                                       progress:^(int progress)
     {
        
    } completion:^(EMMessage *message, EMError *error)
     {
        
    }];
}

- (void)importMessages:(NSDictionary *)param result:(FlutterResult)result {
    
    NSArray *messageArr = param[@"messages"];
    NSMutableArray *messages;
    for (NSDictionary *messageDict in messageArr) {
        EMMessage *msg = [EMHelper dictionaryToMessage:messageDict];
        [messages addObject:msg];
    }
    [[EMClient sharedClient].chatManager importMessages:messages completion:^(EMError *aError) {
    }];
}

// TODO: ios需调添加该实现
- (void)getConversationsByType:(NSDictionary *)param result:(FlutterResult)result {
    //    EMConversationType type = (EMConversationType)[param[@"type"] intValue];
    //    EMClient.sharedClient.chatManager
}

// TODO: ios需调添加该实现
- (void)downloadFile:(NSDictionary *)param result:(FlutterResult)result {
    
}


- (void)getAllConversations:(NSDictionary *)param result:(FlutterResult)result {
    NSArray *conversations = [EMClient.sharedClient.chatManager getAllConversations];
    NSMutableArray *conversationDictList = [NSMutableArray array];
    for (EMConversation *conversation in conversations) {
        [conversationDictList addObject:[EMHelper conversationToDictionary:conversation]];
    }
    [self wrapperCallBack:result error:nil userInfo:@{@"conversations" : conversationDictList}];
}


- (void)loadAllConversations:(NSDictionary *)param result:(FlutterResult)result {
    [self getAllConversations:param result:result];
}

- (void)deleteConversation:(NSDictionary *)param result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSString *conversationId = param[@"userName"];
    BOOL deleteMessages = [param[@"deleteMessages"] boolValue];
    [EMClient.sharedClient.chatManager deleteConversation:conversationId
                                         isDeleteMessages:deleteMessages
                                               completion:^(NSString *aConversationId, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                            error:aError
                         userInfo:@{@"status" : [NSNumber numberWithBool:(aError == nil)]}];
    }];
}

// ??
- (void)setVoiceMessageListened:(NSDictionary *)param result:(FlutterResult)result {
    
}

// ??
- (void)updateParticipant:(NSDictionary *)param result:(FlutterResult)result {
    
}


- (void)fetchHistoryMessages:(NSDictionary *)param result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSString *conversationId = param[@"id"];
    EMConversationType type = (EMConversationType)[param[@"type"] intValue];
    int pageSize = [param[@"pageSize"] intValue];
    NSString *startMsgId = param[@"startMsgId"];
    [EMClient.sharedClient.chatManager asyncFetchHistoryMessagesFromServer:conversationId
                                                          conversationType:type
                                                            startMessageId:startMsgId
                                                                  pageSize:pageSize
                                                                completion:^(EMCursorResult *aResult, EMError *aError)
     {
        NSArray *msgAry = aResult.list;
        NSMutableArray *msgList = [NSMutableArray array];
        for (EMMessage *msg in msgAry) {
            [msgList addObject:[EMHelper messageToDictionary:msg]];
        }
        
        [weakSelf wrapperCallBack:result error:aError userInfo:@{@"messages" : msgList,
                                                                 @"cursor" : aResult.cursor}];
    }];
}

- (void)searchChatMsgFromDB:(NSDictionary *)param result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSString *keywords = param[@"keywords"];
    long long timeStamp = [param[@"timeStamp"] longLongValue];
    int maxCount = [param[@"maxCount"] intValue];
    NSString *from = param[@"from"];
    EMMessageSearchDirection direction = (EMMessageSearchDirection)[param[@"direction"] intValue];
    [EMClient.sharedClient.chatManager loadMessagesWithKeyword:keywords
                                                     timestamp:timeStamp
                                                         count:maxCount
                                                      fromUser:from
                                               searchDirection:direction
                                                    completion:^(NSArray *aMessages, EMError *aError)
     {
        NSMutableArray *msgList = [NSMutableArray array];
        for (EMMessage *msg in aMessages) {
            [msgList addObject:[EMHelper messageToDictionary:msg]];
        }
        
        [weakSelf wrapperCallBack:result error:aError userInfo:@{@"messages":msgList}];
    }];
}

// ??
- (void)getCursor:(NSDictionary *)param result:(FlutterResult)result {
    
}

// 兼容安卓
- (void)addMessageListener:(NSDictionary *)param result:(FlutterResult)result {
    
}

#pragma mark - EMChatManagerDelegate

// TODO: 安卓没有参数，是否参数一起返回？
- (void)conversationListDidUpdate:(NSArray *)aConversationList {
    [self.channel invokeMethod:EMMethodKeyOnConversationUpdate
                     arguments:nil];
}

- (void)messagesDidReceive:(NSArray *)aMessages {
    NSMutableArray *msgList = [NSMutableArray array];
    for (EMMessage *msg in aMessages) {
        [msgList addObject:[EMHelper messageToDictionary:msg]];
    }
    [self.channel invokeMethod:EMMethodKeyOnMessageReceived arguments:@{@"messages":msgList}];
}

- (void)cmdMessagesDidReceive:(NSArray *)aCmdMessages {
    NSMutableArray *cmdMsgList = [NSMutableArray array];
    for (EMMessage *msg in aCmdMessages) {
        [cmdMsgList addObject:[EMHelper messageToDictionary:msg]];
    }
    
    [self.channel invokeMethod:EMMethodKeyOnCmdMessageReceived arguments:@{@"messages":cmdMsgList}];
}

- (void)messagesDidRead:(NSArray *)aMessages {
    NSMutableArray *msgList = [NSMutableArray array];
    for (EMMessage *msg in aMessages) {
        [msgList addObject:[EMHelper messageToDictionary:msg]];
    }
    
    [self.channel invokeMethod:EMMethodKeyOnMessageRead arguments:@{@"messages":msgList}];
}

- (void)messagesDidDeliver:(NSArray *)aMessages {
    NSMutableArray *msgList = [NSMutableArray array];
    for (EMMessage *msg in aMessages) {
        [msgList addObject:[EMHelper messageToDictionary:msg]];
    }
    
    [self.channel invokeMethod:EMMethodKeyOnMessageDelivered arguments:@{@"messages":msgList}];
}

- (void)messagesDidRecall:(NSArray *)aMessages {
    NSMutableArray *msgList = [NSMutableArray array];
    for (EMMessage *msg in aMessages) {
        [msgList addObject:[EMHelper messageToDictionary:msg]];
    }
    
    [self.channel invokeMethod:EMMethodKeyOnMessageRecalled arguments:@{@"messages":msgList}];
}

- (void)messageStatusDidChange:(EMMessage *)aMessage
                         error:(EMError *)aError {
    NSDictionary *msgDict = [EMHelper messageToDictionary:aMessage];
    [self.channel invokeMethod:EMMethodKeyOnMessageChanged arguments:@{@"message":msgDict}];
}

// TODO: 安卓未找到对应回调
- (void)messageAttachmentStatusDidChange:(EMMessage *)aMessage
                                   error:(EMError *)aError {
    
}


@end
