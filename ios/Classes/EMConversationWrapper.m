//
//  EMConversationWrapper.m
//  
//
//  Created by 杜洁鹏 on 2019/10/8.
//

#import "EMConversationWrapper.h"
#import "EMSDKMethod.h"

#import "EMChatMessage+Helper.h"
#import "EMConversation+Helper.h"

@interface EMConversationWrapper ()

@end

@implementation EMConversationWrapper
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
    } else if ([ChatGetLatestMsg isEqualToString:call.method]) {
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
    else {
        [super handleMethodCall:call result:result];
    }
}


#pragma mark - Private
- (void)getConversationWithParam:(NSDictionary *)param
                      completion:(void(^)(EMConversation *conversation))aCompletion
{
    __weak NSString *conversationId = param[@"convId"];
    EMConversationType type = [EMConversation typeFromInt:[param[@"type"] intValue]];
    EMConversation *conversation = [EMClient.sharedClient.chatManager getConversation:conversationId
                                                                                 type:type
                                                                     createIfNotExist:YES];
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
        [conversation updateMessageChange:msg error:&error];
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
    
    EMMessageBodyType type = [EMMessageBody typeFromString:param[@"msgType"]];
    long long timestamp = [param[@"timestamp"] longLongValue];
    int count = [param[@"count"] intValue];
    NSString *sender = param[@"sender"];
    EMMessageSearchDirection direction = [self searchDirectionFromString:param[@"direction"]];
    
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
    EMMessageSearchDirection direction = [self searchDirectionFromString:param[@"direction"]];
    
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
    NSString *sender = param[@"sender"];
    EMMessageSearchDirection direction = [self searchDirectionFromString:param[@"direction"]];
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation)
     {
        
        [conversation loadMessagesWithKeyword:keywords
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

- (EMMessageSearchDirection)searchDirectionFromString:(NSString *)aDirection {
    return [aDirection isEqualToString:@"up"] ? EMMessageSearchDirectionUp : EMMessageSearchDirectionDown;
}


@end
