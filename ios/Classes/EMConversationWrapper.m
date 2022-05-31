//
//  EMConversationWrapper.m
//  
//
//  Created by 杜洁鹏 on 2019/10/8.
//

#import "EMConversationWrapper.h"
#import "EMSDKMethod.h"

#import "EMMessage+Flutter.h"
#import "EMConversation+Flutter.h"

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
    
    
    if ([EMMethodKeyLoadMsgWithId isEqualToString:call.method]) {
        [self loadMsgWithId:call.arguments result:result];
    } else if([EMMethodKeyLoadMsgWithStartId isEqualToString:call.method]){
        [self loadMsgWithStartId:call.arguments result:result];
    } else if([EMMethodKeyLoadMsgWithKeywords isEqualToString:call.method]){
        [self loadMsgWithKeywords:call.arguments result:result];
    } else if([EMMethodKeyLoadMsgWithMsgType isEqualToString:call.method]){
        [self loadMsgWithMsgType:call.arguments result:result];
    } else if([EMMethodKeyLoadMsgWithTime isEqualToString:call.method]){
        [self loadMsgWithTime:call.arguments result:result];
    } else if ([EMMethodKeyGetUnreadMsgCount isEqualToString:call.method]) {
        [self getUnreadMsgCount:call.arguments result:result];
    } else if ([EMMethodKeyMarkAllMsgsAsRead isEqualToString:call.method]) {
        [self markAllMessagesAsRead:call.arguments result:result];
    } else if ([EMMethodKeyMarkMsgAsRead isEqualToString:call.method]) {
        [self markMessageAsRead:call.arguments result:result];
    } else if ([EMMethodKeySyncConversationExt isEqualToString:call.method]){
        [self syncConversationExt:call.arguments result:result];
    } else if ([EMMethodKeySyncConversationName isEqualToString:call.method]){
        [self syncConversationName:call.arguments result:result];
    } else if ([EMMethodKeyRemoveMsg isEqualToString:call.method]) {
        [self removeMessage:call.arguments result:result];
    } else if ([EMMethodKeyGetLatestMsg isEqualToString:call.method]) {
        [self getLatestMessage:call.arguments result:result];
    } else if ([EMMethodKeyGetLatestMsgFromOthers isEqualToString:call.method]) {
        [self getLatestMessageFromOthers:call.arguments result:result];
    } else if ([EMMethodKeyClearAllMsg isEqualToString:call.method]) {
        [self clearAllMessages:call.arguments result:result];
    } else if ([EMMethodKeyInsertMsg isEqualToString:call.method]) {
        [self insertMessage:call.arguments result:result];
    } else if ([EMMethodKeyAppendMsg isEqualToString:call.method]) {
        [self appendMessage:call.arguments result:result];
    } else if ([EMMethodKeyUpdateConversationMsg isEqualToString:call.method]) {
        [self updateConversationMessage:call.arguments result:result];
    } else {
        [super handleMethodCall:call result:result];
    }
}


#pragma mark - Private
- (void)getConversationWithParam:(NSDictionary *)param
                  completion:(void(^)(EMConversation *conversation))aCompletion
{
    __weak NSString *conversationId = param[@"con_id"];
    EMConversationType type = [EMConversation typeFromInt:[param[@"type"] intValue]];
    EMConversation *conversation = [EMClient.sharedClient.chatManager getConversation:conversationId
                                                                                 type:type
                                                                     createIfNotExist:YES];
    if (aCompletion) {
        aCompletion(conversation);
    }
}

#pragma mark - Actions
- (void)getUnreadMsgCount:(NSDictionary *)param result:(FlutterResult)result
{
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation) {
        [weakSelf wrapperCallBack:result
                      channelName:EMMethodKeyGetUnreadMsgCount
                            error:nil
                           object:@(conversation.unreadMessagesCount)];
    }];
}

- (void)getLatestMessage:(NSDictionary *)param result:(FlutterResult)result
{
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation)
    {
        EMChatMessage *msg = conversation.latestMessage;
        [weakSelf wrapperCallBack:result
                      channelName:EMMethodKeyGetLatestMsg
                            error:nil
                           object:[msg toJson]];
    }];
}

- (void)getLatestMessageFromOthers:(NSDictionary *)param result:(FlutterResult)result
{
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation)
    {
        EMChatMessage *msg = conversation.lastReceivedMessage;
        [weakSelf wrapperCallBack:result
                      channelName:EMMethodKeyGetLatestMsgFromOthers
                            error:nil
                           object:[msg toJson]];
    }];
}

- (void)markMessageAsRead:(NSDictionary *)param result:(FlutterResult)result
{
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation)
    {
        NSString *msgId = param[@"msg_id"];
        EMError *error = nil;
        [conversation markMessageAsReadWithId:msgId error:&error];
        
        [weakSelf wrapperCallBack:result
                      channelName:EMMethodKeyMarkMsgAsRead
                            error:nil
                           object:@(YES)];
    }];
}

- (void)syncConversationName:(NSDictionary *)param result:(FlutterResult)result
{
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation)
    {
        NSString *name = param[@"con_name"];
        NSMutableDictionary *ext = [conversation.ext mutableCopy];
        if (!ext) {
            ext = [NSMutableDictionary dictionary];
        }
        ext[@"con_name"] = name;
        conversation.ext = ext;
        [weakSelf wrapperCallBack:result
                      channelName:EMMethodKeySyncConversationName
                            error:nil
                           object:@(YES)];
    }];
}

- (void)syncConversationExt:(NSDictionary *)param result:(FlutterResult)result
{
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation)
    {
        NSDictionary *ext = param[@"ext"];
        conversation.ext = ext;
        [weakSelf wrapperCallBack:result
                      channelName:EMMethodKeySyncConversationExt
                            error:nil
                           object:@(YES)];
    }];
}

- (void)markAllMessagesAsRead:(NSDictionary *)param result:(FlutterResult)result
{
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation) {
        EMError *error = nil;
        [conversation markAllMessagesAsRead:&error];
        [weakSelf wrapperCallBack:result
                      channelName:EMMethodKeyMarkAllMsgsAsRead
                            error:error
                           object:@(!error)];
    }];
}

- (void)insertMessage:(NSDictionary *)param result:(FlutterResult)result
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
                      channelName:EMMethodKeyInsertMsg
                            error:error
                           object:@(!error)];
    }];
}

- (void)appendMessage:(NSDictionary *)param
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
                      channelName:EMMethodKeyAppendMsg
                            error:error
                           object:@(!error)];
    }];
}

- (void)updateConversationMessage:(NSDictionary *)param
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
                      channelName:EMMethodKeyUpdateConversationMsg
                            error:error
                           object:@(!error)];
    }];
}

- (void)removeMessage:(NSDictionary *)param result:(FlutterResult)result
{
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation)
    {
        NSString *msgId = param[@"msg_id"];
        EMError *error = nil;
        [conversation deleteMessageWithId:msgId error:&error];
        
        [weakSelf wrapperCallBack:result
                      channelName:EMMethodKeyRemoveMsg
                            error:error
                           object:@(!error)];
    }];
}

- (void)clearAllMessages:(NSDictionary *)param result:(FlutterResult)result
{
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation){
        EMError *error = nil;
        [conversation deleteAllMessages:&error];
        [weakSelf wrapperCallBack:result
                      channelName:EMMethodKeyClearAllMsg
                            error:error
                           object:@(!error)];
    }];
}

#pragma mark - load messages
- (void)loadMsgWithId:(NSDictionary *)param result:(FlutterResult)result
{
    __weak typeof(self) weakSelf = self;
    NSString *msgId = param[@"msg_id"];
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation)
     {
        EMError *error = nil;
        EMChatMessage *msg = [conversation loadMessageWithId:msgId error:&error];
        
        [weakSelf wrapperCallBack:result
                      channelName:EMMethodKeyLoadMsgWithId
                            error:error
                           object:[msg toJson]];
        
    }];
}

- (void)loadMsgWithMsgType:(NSDictionary *)param result:(FlutterResult)result{
    __weak typeof(self) weakSelf = self;
    
    EMMessageBodyType type = [EMMessageBody typeFromString:param[@"type"]];
    long long timeStamp = [param[@"timeStamp"] longLongValue];
    int count = [param[@"count"] intValue];
    NSString *sender = param[@"sender"];
    EMMessageSearchDirection direction = [self searchDirectionFromString:param[@"direction"]];
    
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation)
    {
        
        [conversation loadMessagesWithType:type
                                 timestamp:timeStamp
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
                          channelName:EMMethodKeyLoadMsgWithMsgType
                                error:aError
                               object:msgJsonAry];
        }];
    }];
}

- (void)loadMsgWithStartId:(NSDictionary *)param result:(FlutterResult)result
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
                          channelName:EMMethodKeyLoadMsgWithStartId
                                error:aError
                               object:jsonMsgs];
        }];
    }];
}

- (void)loadMsgWithKeywords:(NSDictionary *)param result:(FlutterResult)result
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
                          channelName:EMMethodKeyLoadMsgWithKeywords
                                error:aError
                               object:msgJsonAry];
        }];
    }];
}

- (void)loadMsgWithTime:(NSDictionary *)param result:(FlutterResult)result{
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
                          channelName:EMMethodKeyLoadMsgWithTime
                                error:aError
                               object:msgJsonAry];
        }];
    }];
}

- (EMMessageSearchDirection)searchDirectionFromString:(NSString *)aDirection {
    return [aDirection isEqualToString:@"up"] ? EMMessageSearchDirectionUp : EMMessageSearchDirectionDown;
}


@end
