//
//  EMConversationWrapper.m
//  
//
//  Created by 杜洁鹏 on 2019/10/8.
//

#import "ConversationWrapper.h"
#import "MethodKeys.h"

#import "MessageHelper.h"
#import "SilentModeParamHelper.h"
#import "ConversationHelper.h"
#import "EnumTools.h"
#import "Helper.h"

@interface ConversationWrapper ()

@end

@implementation ConversationWrapper
- (instancetype)initWithChannelName:(NSString *)aChannelName
                          registrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    if(self = [super initWithChannelName:aChannelName
                               registrar:registrar]) {
    }
    return self;
}

#pragma mark - FlutterPlugin

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    
    
    if ([ChatLoadMsgWithId isEqualToString:call.method]) {
        [self loadMsgWithId:call.arguments
                channelName:call.method
                     result:result];
    } else if([ChatLoadMsgWithStartId isEqualToString:call.method]){
        [self loadMsgWithStartId:call.arguments
                     channelName:call.method
                          result:result];
    } else if([ChatLoadMsgWithKeywords isEqualToString:call.method]){
        [self loadMsgWithKeywords:call.arguments
                      channelName:call.method
                           result:result];
    } else if([ChatLoadMsgWithMsgType isEqualToString:call.method]){
        [self loadMsgWithMsgType:call.arguments
                     channelName:call.method
                          result:result];
    } else if([ChatLoadMsgWithTime isEqualToString:call.method]){
        [self loadMsgWithTime:call.arguments
                  channelName:call.method
                       result:result];
    } else if ([ChatGetUnreadMsgCount isEqualToString:call.method]) {
        [self getUnreadMsgCount:call.arguments
                    channelName:call.method
                         result:result];
    } else if ([ChatMarkAllMsgsAsRead isEqualToString:call.method]) {
        [self markAllMessagesAsRead:call.arguments
                        channelName:call.method
                             result:result];
    } else if ([ChatMarkMsgAsRead isEqualToString:call.method]) {
        [self markMessageAsRead:call.arguments
                    channelName:call.method
                         result:result];
    } else if ([ChatSyncConversationExt isEqualToString:call.method]){
        [self syncConversationExt:call.arguments
                      channelName:call.method
                           result:result];
    } else if ([ChatRemoveMsg isEqualToString:call.method]) {
        [self removeMessage:call.arguments
                channelName:call.method
                     result:result];
    } 
    else if ([ChatDeleteMessageByIds isEqualToString:call.method]) {
        [self deleteMessageByIds:call.arguments
                channelName:call.method
                     result:result];
    }
    else if ([ChatGetLatestMsg isEqualToString:call.method]) {
        [self getLatestMessage:call.arguments
                   channelName:call.method
                        result:result];
    } else if ([ChatGetLatestMsgFromOthers isEqualToString:call.method]) {
        [self getLatestMessageFromOthers:call.arguments
                             channelName:call.method
                                  result:result];
    } else if ([ChatClearAllMsg isEqualToString:call.method]) {
        [self clearAllMessages:call.arguments
                   channelName:call.method
                        result:result];
    } else if ([ChatDeleteMessagesWithTs isEqualToString:call.method]) {
        [self deleteMessagesWithTs:call.arguments
                   channelName:call.method
                        result:result];
    } else if ([ChatInsertMsg isEqualToString:call.method]) {
        [self insertMessage:call.arguments
                channelName:call.method
                     result:result];
    } else if ([ChatAppendMsg isEqualToString:call.method]) {
        [self appendMessage:call.arguments
                channelName:call.method
                     result:result];
    } else if ([ChatUpdateConversationMsg isEqualToString:call.method]) {
        [self updateConversationMessage:call.arguments
                            channelName:call.method
                                 result:result];
    } else if ([ChatConversationMessageCount isEqualToString:call.method]) {
        [self messageCount:call.arguments
               channelName:call.method
                    result:result];
    } else if ([ChatRemoveMsgFromServerWithMsgList isEqualToString:call.method]) {
        [self removeMsgFromServerWithMsgList:call.arguments
                                 channelName:call.method
                                      result:result];
    } else if ([ChatRemoveMsgFromServerWithTimeStamp isEqualToString:call.method]) {
        [self removeMsgFromServerWithTimeStamp:call.arguments
                                   channelName:call.method
                                        result:result];
    }
    // 450
    else if ([pinnedMessages isEqualToString:call.method]) {
        [self pinnedMessages:call.arguments
                 channelName:call.method
                      result:result];
    }
    // 481
    else if ([ChatConversationRemindType isEqualToString:call.method]) {
        [self remindType:call.arguments
                 channelName:call.method
                      result:result];
    }
    else if ([ChatConversationSearchMsgsByOptions isEqualToString:call.method]) {
        [self searchMessageByOptions:call.arguments
                         channelName:call.method
                              result:result];
    }
    else if ([ChatConversationGetLocalMessageCount isEqualToString:call.method]) {
        [self getLocalMessageCount:call.arguments
                         channelName:call.method
                              result:result];
    }
    else if ([ChatConversationDeleteServerMessageWithIds isEqualToString:call.method]) {
        [self deleteServerMessages:call.arguments
                         channelName:call.method
                              result:result];
    }
    else if ([ChatConversationDeleteServerMessageWithTime isEqualToString:call.method]) {
        [self deleteServerMessagesByTime:call.arguments
                         channelName:call.method
                              result:result];
    }
    
    
    
    else {
        [super handleMethodCall:call result:result];
    }
}


#pragma mark - Private
- (void)getConversationWithParam:(NSDictionary *)param
                      completion:(void(^)(EMConversation *conversation))aCompletion
{
    __weak NSString *conversationId = param[@"convId"];
    EMConversationType type = [EnumTools conversationTypeFromInt:[param[@"type"] intValue]];
    BOOL isThread = [param[@"isThread"] boolValue];
    EMConversation *conversation = [EMClient.sharedClient.chatManager getConversation:conversationId
                                                                                 type:type
                                                                     createIfNotExist:YES
                                                                             isThread:isThread];
    if (aCompletion) {
        aCompletion(conversation);
    }
}

#pragma mark - Actions
- (void)getUnreadMsgCount:(NSDictionary *)param
              channelName:(NSString *)aChannelName
                   result:(FlutterResult)result
{
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:nil
                           object:@(conversation.unreadMessagesCount)];
    }];
}

- (void)getLatestMessage:(NSDictionary *)param
             channelName:(NSString *)aChannelName
                  result:(FlutterResult)result
{
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation)
     {
        EMChatMessage *msg = conversation.latestMessage;
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:nil
                           object:[msg toJson]];
    }];
}

- (void)getLatestMessageFromOthers:(NSDictionary *)param
                       channelName:(NSString *)aChannelName
                            result:(FlutterResult)result
{
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation)
     {
        EMChatMessage *msg = conversation.lastReceivedMessage;
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:nil
                           object:[msg toJson]];
    }];
}

- (void)markMessageAsRead:(NSDictionary *)param
              channelName:(NSString *)aChannelName
                   result:(FlutterResult)result
{
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation)
     {
        NSString *msgId = param[@"msg_id"];
        EMError *error = nil;
        [conversation markMessageAsReadWithId:msgId error:&error];
        
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:error
                           object:@(!error)];
    }];
}

- (void)syncConversationExt:(NSDictionary *)param
                channelName:(NSString *)aChannelName
                     result:(FlutterResult)result
{
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation)
     {
        NSDictionary *ext = param[@"ext"];
        conversation.ext = ext;
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:nil
                           object:@(YES)];
    }];
}

- (void)markAllMessagesAsRead:(NSDictionary *)param
                  channelName:(NSString *)aChannelName
                       result:(FlutterResult)result
{
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation) {
        EMError *error = nil;
        [conversation markAllMessagesAsRead:&error];
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:error
                           object:@(!error)];
    }];
}

- (void)insertMessage:(NSDictionary *)param
          channelName:(NSString *)aChannelName
               result:(FlutterResult)result
{
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation)
     {
        NSDictionary *msgDict = param[@"msg"];
        EMChatMessage *msg = [EMChatMessage fromJson:msgDict];
        
        EMError *error = nil;
        [conversation insertMessage:msg error:&error];
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:error
                           object:@(!error)];
    }];
}

- (void)appendMessage:(NSDictionary *)param
          channelName:(NSString *)aChannelName
               result:(FlutterResult)result
{
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation)
     {
        NSDictionary *msgDict = param[@"msg"];
        EMChatMessage *msg = [EMChatMessage fromJson:msgDict];
        
        EMError *error = nil;
        [conversation appendMessage:msg error:&error];
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:error
                           object:@(!error)];
    }];
}

- (void)updateConversationMessage:(NSDictionary *)param
                      channelName:(NSString *)aChannelName
                           result:(FlutterResult)result
{
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation)
     {
        NSDictionary *msgDict = param[@"msg"];
        EMChatMessage *msg = [EMChatMessage fromJson:msgDict];
        
        EMError *error = nil;
        EMChatMessage *dbMsg = [EMClient.sharedClient.chatManager getMessageWithMessageId:msg.messageId];
       [Helper mergeMessage:msg withDBMessage:dbMsg];
       [conversation updateMessageChange:dbMsg error:&error];
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:error
                           object:@(!error)];
    }];
}

- (void)messageCount:(NSDictionary *)param
         channelName:(NSString *)aChannelName
              result:(FlutterResult)result
{
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:nil
                           object:@(conversation.messagesCount)];
    }];
}

- (void)getPinnedMessages:(NSDictionary *)param
             channelName:(NSString *)aChannelName
                  result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation) {
        NSArray<EMChatMessage *> *aMessages = conversation.pinnedMessages;
        NSMutableArray *msgJsonAry = [NSMutableArray array];
        for (EMChatMessage *msg in aMessages) {
            [msgJsonAry addObject:[msg toJson]];
        }
        
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:nil
                           object:msgJsonAry];
    }];
}

- (void)removeMessage:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result
{
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation)
     {
        NSString *msgId = param[@"msg_id"];
        EMError *error = nil;
        [conversation deleteMessageWithId:msgId error:&error];
        
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:error
                           object:@(!error)];
    }];
}

- (void)deleteMessageByIds:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result
{
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation)
     {
        NSArray *msgIds = param[@"messageIds"];
        EMError *error = nil;
        for (NSString *msgId in msgIds) {
            [conversation deleteMessageWithId:msgId error:nil];
        }
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:nil
                           object:@(!error)];
    }];
}


- (void)clearAllMessages:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result
{
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation){
        EMError *error = nil;
        [conversation deleteAllMessages:&error];
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:error
                           object:@(!error)];
    }];
}

- (void)deleteMessagesWithTs:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result
{
    __weak typeof(self) weakSelf = self;
    long startTs = [param[@"startTs"] longValue];
    long endTs = [param[@"endTs"] longValue];
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation){
        EMError *error = [conversation removeMessagesStart:startTs to:endTs];
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:error
                           object:@(!error)];
    }];
}

- (void)removeMsgFromServerWithMsgList:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result
{
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation){
        NSArray *msgIds = param[@"msgIds"];
        [conversation removeMessagesFromServerMessageIds:msgIds completion:^(EMError * _Nullable aError) {
            [weakSelf wrapperCallBack:result
                          channelName:aChannelName
                                error:aError
                               object:nil];
        }];
    }];
}

- (void)removeMsgFromServerWithTimeStamp:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result
{
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation){
        long timestamp = [param[@"timestamp"] longValue];
        [conversation removeMessagesFromServerWithTimeStamp:timestamp completion:^(EMError * _Nullable aError) {
            [weakSelf wrapperCallBack:result
                          channelName:aChannelName
                                error:aError
                               object:nil];
        }];
    }];
}

#pragma mark - load messages
- (void)loadMsgWithId:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result
{
    __weak typeof(self) weakSelf = self;
    NSString *msgId = param[@"msg_id"];
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation)
     {
        EMError *error = nil;
        EMChatMessage *msg = [conversation loadMessageWithId:msgId error:&error];
        
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:error
                           object:[msg toJson]];
        
    }];
}

- (void)loadMsgWithMsgType:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result{
    __weak typeof(self) weakSelf = self;
    
    EMMessageBodyType type = [EnumTools messageBodyTypeFromInt:[param[@"msgType"] integerValue]];
    long long timestamp = [param[@"timestamp"] longLongValue];
    int count = [param[@"count"] intValue];
    NSString *sender = param[@"sender"];
    EMMessageSearchDirection direction = [EnumTools searchDirectionFromInt:[param[@"direction"] integerValue]];
    
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation)
     {
        
        [conversation loadMessagesWithType:type
                                 timestamp:timestamp
                                     count:count
                                  fromUser:sender
                           searchDirection:direction
                                completion:^(NSArray *aMessages, EMError *aError)
         {
            NSMutableArray *msgJsonAry = [NSMutableArray array];
            for (EMChatMessage *msg in aMessages) {
                [msgJsonAry addObject:[msg toJson]];
            }
            [weakSelf wrapperCallBack:result
                          channelName:aChannelName
                                error:aError
                               object:msgJsonAry];
        }];
    }];
}

- (void)loadMsgWithStartId:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result
{
    __weak typeof(self) weakSelf = self;
    NSString *startId = param[@"startId"];
    int count = [param[@"count"] intValue];
    EMMessageSearchDirection direction = [EnumTools searchDirectionFromInt:[param[@"direction"] integerValue]];
    
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation) {
        [conversation loadMessagesStartFromId:startId
                                        count:count
                              searchDirection:direction
                                   completion:^(NSArray *aMessages, EMError *aError)
         {
            NSMutableArray *jsonMsgs = [NSMutableArray array];
            for (EMChatMessage *msg in aMessages) {
                [jsonMsgs addObject:[msg toJson]];
            }
            
            [weakSelf wrapperCallBack:result
                          channelName:aChannelName
                                error:aError
                               object:jsonMsgs];
        }];
    }];
}

- (void)loadMsgWithKeywords:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result
{
    __weak typeof(self) weakSelf = self;
    NSString * keywords = param[@"keywords"];
    long long timestamp = [param[@"timestamp"] longLongValue];
    int count = [param[@"count"] intValue];
    NSString *sender = param[@"from"];
    EMMessageSearchScope scope = (EMMessageSearchScope)[param[@"searchScope"] intValue];
    EMMessageSearchDirection direction = [EnumTools searchDirectionFromInt:[param[@"direction"] integerValue]];
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation)
     {
        
        [conversation loadMessagesWithKeyword:keywords
                                    timestamp:timestamp
                                        count:count
                                     fromUser:sender
                              searchDirection:direction
                                        scope:scope
                                   completion:^(NSArray *aMessages, EMError *aError)
         {
            NSMutableArray *msgJsonAry = [NSMutableArray array];
            for (EMChatMessage *msg in aMessages) {
                [msgJsonAry addObject:[msg toJson]];
            }
            [weakSelf wrapperCallBack:result
                          channelName:aChannelName
                                error:aError
                               object:msgJsonAry];
        }];
    }];
}

- (void)loadMsgWithTime:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result{
    __weak typeof(self) weakSelf = self;
    long long startTime = [param[@"startTime"] longLongValue];
    long long entTime = [param[@"endTime"] longLongValue];
    int count = [param[@"count"] intValue];
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation)
     {
        
        [conversation loadMessagesFrom:startTime
                                    to:entTime
                                 count:count
                            completion:^(NSArray *aMessages, EMError *aError)
         {
            NSMutableArray *msgJsonAry = [NSMutableArray array];
            for (EMChatMessage *msg in aMessages) {
                [msgJsonAry addObject:[msg toJson]];
            }
            [weakSelf wrapperCallBack:result
                          channelName:aChannelName
                                error:aError
                               object:msgJsonAry];
        }];
    }];
}

- (void)pinnedMessages:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result{
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation)
     {
        NSArray *pinnedMessages = conversation.pinnedMessages;
        NSMutableArray *msgJsonAry = [NSMutableArray array];
        for (EMChatMessage *msg in pinnedMessages) {
            [msgJsonAry addObject:[msg toJson]];
        }
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:nil
                           object:msgJsonAry];
    }];
}


#pragma mark 481
- (void)remindType:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result{
      
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:nil
                           object:@([EMSilentModeParam remindTypeToInt:conversation.disturbType])];
    }];
}

- (void)searchMessageByOptions:(NSDictionary *)param
                   channelName:(NSString *)aChannelName
                        result:(FlutterResult)result
{
    NSArray *types = param[@"types"];
    NSMutableArray *searchTypes = [NSMutableArray array];
    for (int i = 0; i < types.count; i++) {
        EMMessageBodyType type = [EnumTools messageBodyTypeFromInt:[types[i] integerValue]];
        [searchTypes addObject:@(type)];
    }
    
    long long ts = [param[@"ts"] longLongValue];
    int count = [param[@"count"] intValue];
    NSString *from = param[@"from"];
    EMMessageSearchDirection direction = [EnumTools searchDirectionFromInt:[param[@"direction"] integerValue]];
    
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation)
     {
        [conversation searchMessagesWithTypes:searchTypes
                                    timestamp:ts
                                        count:count
                                     fromUser:from
                              searchDirection:direction
                                   completion:^(NSArray<EMChatMessage *> * _Nullable aMessages, EMError * _Nullable aError)
         {
            
            NSMutableArray *msgJsonAry = [NSMutableArray array];
            for (EMChatMessage *msg in aMessages) {
                [msgJsonAry addObject:[msg toJson]];
            }
            
            [weakSelf wrapperCallBack:result
                          channelName:aChannelName
                                error:aError
                               object:msgJsonAry];
        }];
    }];
}

- (void)getLocalMessageCount:(NSDictionary *)param
                   channelName:(NSString *)aChannelName
                        result:(FlutterResult)result{
    NSInteger startMs = [param[@"startMs"] integerValue];
    NSInteger endMs = [param[@"endMs"] longLongValue];
    
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation)
     {
        NSInteger count = [conversation getMessageCountStart:startMs to:endMs];
        
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:nil
                           object:@(count)];
    }];
}

- (void)deleteServerMessages:(NSDictionary *)param
                   channelName:(NSString *)aChannelName
                      result:(FlutterResult)result{
    NSArray *msgIds = param[@"msgIds"];
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation)
     {
        [conversation removeMessagesFromServerMessageIds:msgIds completion:^(EMError * _Nullable aError) {
            [weakSelf wrapperCallBack:result
                          channelName:aChannelName
                                error:aError
                               object:nil];
        }];
    }];
}

- (void)deleteServerMessagesByTime:(NSDictionary *)param
                   channelName:(NSString *)aChannelName
                      result:(FlutterResult)result{
    long long ts = [param[@"beforeMs"] longLongValue];
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation)
     {
        [conversation removeMessagesFromServerWithTimeStamp:ts completion:^(EMError * _Nullable aError) {
            [weakSelf wrapperCallBack:result
                          channelName:aChannelName
                                error:aError
                               object:nil];
        }];
    }];
}


@end
