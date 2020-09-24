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
    
    if ([EMMethodKeyGetUnreadMsgCount isEqualToString:call.method]) {
        [self getUnreadMsgCount:call.arguments result:result];
    } else if ([EMMethodKeyMarkAllMessagesAsRead isEqualToString:call.method]) {
        [self markAllMessagesAsRead:call.arguments result:result];
    } else if ([EMMethodKeyLoadMoreMsgFromDB isEqualToString:call.method]) {
        [self loadMoreMsgFromDB:call.arguments result:result];
    } else if ([EMMethodKeySearchConversationMsgFromDB isEqualToString:call.method]) {
        [self searchConversationMsgFromDB:call.arguments result:result];
    } else if ([EMMethodKeySearchConversationMsgFromDBByType isEqualToString:call.method]) {
        [self searchConversationMsgFromDBByType:call.arguments result:result];
    } else if ([EMMethodKeyLoadMessages isEqualToString:call.method]) {
        [self loadMessages:call.arguments result:result];
    } else if ([EMMethodKeyMarkMessageAsRead isEqualToString:call.method]) {
        [self markMessageAsRead:call.arguments result:result];
    } else if ([EMMethodKeyRemoveMessage isEqualToString:call.method]) {
        [self removeMessage:call.arguments result:result];
    } else if ([EMMethodKeyGetLastMessage isEqualToString:call.method]) {
        [self getLastMessage:call.arguments result:result];
    } else if ([EMMethodKeyGetLatestMessageFromOthers isEqualToString:call.method]) {
        [self getLatestMessageFromOthers:call.arguments result:result];
    } else if ([EMMethodKeyClear isEqualToString:call.method]) {
        [self clear:call.arguments result:result];
    } else if ([EMMethodKeyClearAllMessages isEqualToString:call.method]) {
        [self clearAllMessages:call.arguments result:result];
    } else if ([EMMethodKeyInsertMessage isEqualToString:call.method]) {
        [self insertMessage:call.arguments result:result];
    } else if ([EMMethodKeyAppendMessage isEqualToString:call.method]) {
        [self appendMessage:call.arguments result:result];
    } else if ([EMMethodKeyUpdateConversationMessage isEqualToString:call.method]) {
        [self updateConversationMessage:call.arguments result:result];
    } else if ([EMMethodKeyGetMessageAttachmentPath isEqualToString:call.method]) {
        [self getMessageAttachmentPath:call.arguments result:result];
    } else {
        [super handleMethodCall:call result:result];
    }
}


#pragma mark - Private
- (void)getConversationWithParam:(NSDictionary *)param
                  completion:(void(^)(EMConversation *conversation))aCompletion
{
    NSString *conversationId = param[@"id"];
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
                   result:(FlutterResult)result
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

- (void)markAllMessagesAsRead:(NSDictionary *)param
                       result:(FlutterResult)result
{
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation) {
        EMError *error = nil;
        [conversation markAllMessagesAsRead:&error];
        [weakSelf wrapperCallBack:result
                      channelName:EMMethodKeyMarkAllMessagesAsRead
                            error:error
                           object:nil];
    }];
}

- (void)loadMoreMsgFromDB:(NSDictionary *)param
                   result:(FlutterResult)result
{
//    EMMethodKeyLoadMoreMsgFromDB
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                         completion:^(EMConversation *conversation) {
        [conversation loadMessagesStartFromId:param[@"startId"]
                                        count:[param[@"count"] intValue]
                              searchDirection:EMMessageSearchDirectionUp
                                   completion:^(NSArray *aMessages, EMError *aError)
        {
            NSMutableArray *jsonMsgs = [NSMutableArray array];
            for (EMMessage *msg in aMessages) {
                [jsonMsgs addObject:[msg toJson]];
            }
            
            [weakSelf wrapperCallBack:result
                          channelName:EMMethodKeyLoadMoreMsgFromDB
                                error:aError
                               object:jsonMsgs];
        }];
    }];
}

- (void)searchConversationMsgFromDB:(NSDictionary *)param
                             result:(FlutterResult)result
{
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation)
    {
        NSString *keywords = param[@"keywords"];
        NSString *from = param[@"from"];
        long long timeStamp = [param[@"timeStamp"] longLongValue];
        int maxCount = [param[@"maxCount"] intValue];
        EMMessageSearchDirection direction = (EMMessageSearchDirection)[param[@"direction"] intValue];
        [conversation loadMessagesWithKeyword:keywords
                                    timestamp:timeStamp
                                        count:maxCount
                                     fromUser:from
                              searchDirection:direction
                                   completion:^(NSArray *aMessages, EMError *aError)
        {
            [weakSelf wrapperCallBack:result
                                error:aError
                             userInfo:@{@"messages":[EMHelper messagesToDictionaries:aMessages]}];
        }];
    }];
}

- (void)searchConversationMsgFromDBByType:(NSDictionary *)param
                                   result:(FlutterResult)result
{
    __weak typeof(self) weakSelf = self;
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation)
    {
        NSString *from = param[@"from"];
        EMMessageBodyType type = (EMMessageBodyType)[param[@"type"] intValue];
        long long timeStamp = [param[@"timeStamp"] longLongValue];
        int maxCount = [param[@"maxCount"] intValue];
        EMMessageSearchDirection direction = (EMMessageSearchDirection)[param[@"direction"] intValue];
        [conversation loadMessagesWithType:type
                                 timestamp:timeStamp
                                     count:maxCount
                                  fromUser:from
                           searchDirection:direction
                                completion:^(NSArray *aMessages, EMError *aError)
        {
            [weakSelf wrapperCallBack:result
               error:aError
            userInfo:@{@"messages":[EMHelper messagesToDictionaries:aMessages]}];
        }];
    }];
}

- (void)loadMessages:(NSDictionary *)param
              result:(FlutterResult)result
{
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation)
     {
        NSArray *msgIds = param[@"messages"];
        NSMutableArray *ret = [NSMutableArray array];
        for (NSString *msgId in msgIds) {
            EMMessage *msg = [conversation loadMessageWithId:msgId error:nil];
            if (msg) {
                [ret addObject:[EMHelper messageToDictionary:msg]];
            }
        }
        [self wrapperCallBack:result
                        error:nil
                     userInfo:@{@"messages":ret}];
    }];
}

- (void)markMessageAsRead:(NSDictionary *)param
                   result:(FlutterResult)result
{
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation)
    {
        NSString *msgId = param[@"messageId"];
        [conversation markMessageAsReadWithId:msgId error:nil];
    }];
}

- (void)removeMessage:(NSDictionary *)param
               result:(FlutterResult)result
{
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation)
    {
        NSString *msgId = param[@"messageId"];
        [conversation deleteMessageWithId:msgId error:nil];
    }];
}

- (void)getLastMessage:(NSDictionary *)param
                result:(FlutterResult)result
{
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation)
    {
        EMMessage *msg = conversation.latestMessage;
        [self wrapperCallBack:result
                        error:nil
                     userInfo: msg ? @{@"message":[msg toJson]} : nil];
    }];
}

- (void)getLatestMessageFromOthers:(NSDictionary *)param
                            result:(FlutterResult)result
{
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation)
    {
        EMMessage *msg = conversation.lastReceivedMessage;
        [self wrapperCallBack:result
                        error:nil
                     userInfo:@{@"message":[EMHelper messageToDictionary:msg]}];
    }];
}

- (void)clear:(NSDictionary *)param
       result:(FlutterResult)result
{
    
}

- (void)clearAllMessages:(NSDictionary *)param
                  result:(FlutterResult)result
{
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation){
        EMError *error = nil;
        [conversation deleteAllMessages:&error];
        [self wrapperCallBack:result
                  channelName:EMMethodKeyClearAllMessages
                        error:error
                       object:nil];
    }];
}

- (void)insertMessage:(NSDictionary *)param
               result:(FlutterResult)result
{
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation)
    {
        NSDictionary *msgDict = param[@"msg"];
        EMMessage *msg = [EMHelper dictionaryToMessage:msgDict];
        [conversation insertMessage:msg
                              error:nil];
    }];
}

- (void)appendMessage:(NSDictionary *)param
               result:(FlutterResult)result
{
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation)
    {
        NSDictionary *msgDict = param[@"msg"];
        [conversation appendMessage:[EMHelper dictionaryToMessage:msgDict]
                              error:nil];
    }];
}

- (void)updateConversationMessage:(NSDictionary *)param
                           result:(FlutterResult)result
{
    [self getConversationWithParam:param
                        completion:^(EMConversation *conversation)
    {
        NSDictionary *msgDict = param[@"msg"];
        [conversation updateMessageChange:[EMHelper dictionaryToMessage:msgDict]
                              error:nil];
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



@end
