//
//  EMConversationWrapper.m
//  
//
//  Created by 杜洁鹏 on 2019/10/8.
//

#import "EMConversationWrapper.h"
#import "EMSDKMethod.h"
#import "EMHelper.h"

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
    } else if ([EMMethodKeyRemoveMsg isEqualToString:call.method]) {
        [self removeMessage:call.arguments result:result];
    } else if ([EMMethodKeyGetLatestMsg isEqualToString:call.method]) {
        [self getLatestMessage:call.arguments result:result];
    } else if ([EMMethodKeyGetLatestMsgFromOthers isEqualToString:call.method]) {
        [self getLatestMessageFromOthers:call.arguments result:result];
    } else if ([EMMethodKeyClear isEqualToString:call.method]) {
        [self clear:call.arguments result:result];
    } else if ([EMMethodKeyClearAllMsg isEqualToString:call.method]) {
        [self clearAllMessages:call.arguments result:result];
    } else if ([EMMethodKeyInsertMsg isEqualToString:call.method]) {
        [self insertMessage:call.arguments result:result];
    } else if ([EMMethodKeyAppendMsg isEqualToString:call.method]) {
        [self appendMessage:call.arguments result:result];
    } else if ([EMMethodKeyUpdateConversationMsg isEqualToString:call.method]) {
        [self updateConversationMessage:call.arguments result:result];
    } else if ([EMMethodKeyGetMsgAttachmentPath isEqualToString:call.method]) {
        [self getMessageAttachmentPath:call.arguments result:result];
    } else if ([EMMethodKeyGetMessage isEqualToString:call.method]) {
        [self getMessage:call.arguments result:result];
    } else {
        [super handleMethodCall:call result:result];
    }
}


#pragma mark - Private
- (void)getConversationWithParam:(NSDictionary *)param
                  completion:(void(^)(EMConversation *conversation))aCompletion
{
    NSString *conversationId = param[@"con_id"];
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
                           object:nil];
    }];
}


- (void)markMessageAsRead:(NSDictionary *)param result:(FlutterResult)result
{
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation)
    {
        NSString *msgId = param[@"msgId"];
        EMError *error = nil;
        [conversation markMessageAsReadWithId:msgId error:&error];
        
        [weakSelf wrapperCallBack:result
                      channelName:EMMethodKeyMarkMsgAsRead
                            error:error
                           object:nil];
    }];
}

- (void)removeMessage:(NSDictionary *)param result:(FlutterResult)result
{
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation)
    {
        NSString *msgId = param[@"msgId"];
        EMError *error = nil;
        [conversation deleteMessageWithId:msgId error:&error];
        
        [weakSelf wrapperCallBack:result
                      channelName:EMMethodKeyRemoveMsg
                            error:error
                           object:nil];
    }];
}

- (void)getLatestMessage:(NSDictionary *)param result:(FlutterResult)result
{
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation)
    {
        EMMessage *msg = conversation.latestMessage;
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
        EMMessage *msg = conversation.lastReceivedMessage;
        [weakSelf wrapperCallBack:result
                      channelName:EMMethodKeyGetLatestMsgFromOthers
                            error:nil
                           object:[msg toJson]];
    }];
}

- (void)clear:(NSDictionary *)param result:(FlutterResult)result
{
    
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
                           object:nil];
    }];
}

- (void)insertMessage:(NSDictionary *)param result:(FlutterResult)result
{
    
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation)
    {
        NSDictionary *msgDict = param[@"msg"];
        EMMessage *msg = [EMMessage fromJson:msgDict];
        
        EMError *error = nil;
        [conversation insertMessage:msg error:&error];
        [weakSelf wrapperCallBack:result
                      channelName:EMMethodKeyInsertMsg
                            error:error
                           object:nil];
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
        EMMessage *msg = [EMMessage fromJson:msgDict];
        
        EMError *error = nil;
        [conversation insertMessage:msg error:&error];
        [weakSelf wrapperCallBack:result
                      channelName:EMMethodKeyAppendMsg
                            error:error
                           object:nil];
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
        EMMessage *msg = [EMMessage fromJson:msgDict];
        
        EMError *error = nil;
        [conversation insertMessage:msg error:&error];
        [weakSelf wrapperCallBack:result
                      channelName:EMMethodKeyUpdateConversationMsg
                            error:error
                           object:nil];
    }];
}

- (void)getMessage:(NSDictionary *)param result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation)
    {
        EMError *error = nil;
        EMMessage *msg = [conversation loadMessageWithId:param[@"msgId"] error:&error];
        
        [weakSelf wrapperCallBack:result
                      channelName:EMMethodKeyGetMessage
                            error:error
                           object:[msg toJson]];
    }];
}

// TODO: ?
- (void)getMessageAttachmentPath:(NSDictionary *)param
                          result:(FlutterResult)result
{
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation)
    {

    }];
}



#pragma mark - load messages


- (void)loadMsgWithId:(NSDictionary *)param result:(FlutterResult)result
{
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation)
     {
        EMError *error = nil;
        EMMessage *msg = [conversation loadMessageWithId:param[@"msgId"] error:&error];
        
        [weakSelf wrapperCallBack:result
                      channelName:EMMethodKeyLoadMsgWithId
                            error:error
                           object:[msg toJson]];
        
    }];
}

- (void)loadMsgWithStartId:(NSDictionary *)param result:(FlutterResult)result
{
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                         completion:^(EMConversation *conversation) {
        [conversation loadMessagesStartFromId:param[@"startId"]
                                        count:[param[@"count"] intValue]
                              searchDirection:[self searchDirectionFromString:param[@"direction"]]
                                   completion:^(NSArray *aMessages, EMError *aError)
        {
            NSMutableArray *jsonMsgs = [NSMutableArray array];
            for (EMMessage *msg in aMessages) {
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
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation)
    {
        
        [conversation loadMessagesWithKeyword:param[@"keywords"]
                                    timestamp:[param[@"timestamp"] longLongValue]
                                        count:[param[@"count"] intValue]
                                     fromUser:param[@"sender"]
                              searchDirection:[self searchDirectionFromString:param[@"direction"]]
                                   completion:^(NSArray *aMessages, EMError *aError)
        {
            NSMutableArray *msgJsonAry = [NSMutableArray array];
            for (EMMessage *msg in aMessages) {
                [msgJsonAry addObject:[msg toJson]];
            }
            [weakSelf wrapperCallBack:result
                          channelName:EMMethodKeyLoadMsgWithKeywords
                                error:aError
                               object:msgJsonAry];
        }];
    }];
}

- (void)loadMsgWithMsgType:(NSDictionary *)param result:(FlutterResult)result{
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation)
    {
        
        [conversation loadMessagesWithType:[EMMessageBody typeFromString:param[@"type"]]
                                 timestamp:[param[@"timeStamp"] longLongValue]
                                     count:[param[@"count"] intValue]
                                  fromUser:param[@"sender"]
                           searchDirection:[self searchDirectionFromString:param[@"direction"]]
                                completion:^(NSArray *aMessages, EMError *aError)
        {
            NSMutableArray *msgJsonAry = [NSMutableArray array];
            for (EMMessage *msg in aMessages) {
                [msgJsonAry addObject:[msg toJson]];
            }
            [weakSelf wrapperCallBack:result
                          channelName:EMMethodKeyLoadMsgWithMsgType
                                error:aError
                               object:msgJsonAry];
        }];
    }];
}

- (void)loadMsgWithTime:(NSDictionary *)param result:(FlutterResult)result{
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation)
    {
        
        [conversation loadMessagesFrom:[param[@"startTime"] longLongValue]
                                    to:[param[@"endTime"] longLongValue]
                                 count:[param[@"count"] intValue]
                            completion:^(NSArray *aMessages, EMError *aError)
        {
            NSMutableArray *msgJsonAry = [NSMutableArray array];
            for (EMMessage *msg in aMessages) {
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
