//
//  EMChatManagerWrapper.m
//
//
//  Created by 杜洁鹏 on 2019/10/8.
//

#import "EMChatManagerWrapper.h"
#import "EMSDKMethod.h"

#import "EMMessage+Flutter.h"
#import "EMConversation+Flutter.h"
#import "EMGroupMessageAck+Flutter.h"
#import "EMError+Flutter.h"
#import "EMCursorResult+Flutter.h"


@interface EMChatManagerWrapper () <EMChatManagerDelegate,EMLocalNotificationDelegate>
@property (nonatomic, strong) FlutterMethodChannel *messageChannel;
@end

@implementation EMChatManagerWrapper
- (instancetype)initWithChannelName:(NSString *)aChannelName
                          registrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    if(self = [super initWithChannelName:aChannelName
                               registrar:registrar]) {
        [EMClient.sharedClient.chatManager addDelegate:self delegateQueue:nil];
        
        FlutterJSONMethodCodec *codec = [FlutterJSONMethodCodec sharedInstance];
        self.messageChannel = [FlutterMethodChannel methodChannelWithName:@"com.easemob.im/em_message"
                                                          binaryMessenger:[registrar messenger]
                                                                    codec:codec];
        
    }
    return self;
}


#pragma mark - FlutterPlugin

- (void)handleMethodCall:(FlutterMethodCall*)call
                  result:(FlutterResult)result {
    if ([EMMethodKeySendMessage isEqualToString:call.method]) {
        [self sendMessage:call.arguments
              channelName:EMMethodKeySendMessage
                   result:result];
    } else if ([EMMethodKeyResendMessage isEqualToString:call.method]) {
        [self resendMessage:call.arguments
                channelName:EMMethodKeyResendMessage
                     result:result];
    } else if ([EMMethodKeyAckMessageRead isEqualToString:call.method]) {
        [self ackMessageRead:call.arguments
                 channelName:EMMethodKeyAckMessageRead
                      result:result];
    } else if ([EMMethodKeyAckGroupMessageRead isEqualToString:call.method]) {
        [self ackGroupMessageRead:call.arguments
                 channelName:EMMethodKeyAckMessageRead
                      result:result];
    } else if ([EMMethodKeyAckConversationRead isEqualToString:call.method]) {
        [self ackConversationRead:call.arguments
                      channelName:EMMethodKeyAckConversationRead
                           result:result];
    }
    else if ([EMMethodKeyRecallMessage isEqualToString:call.method]) {
        [self recallMessage:call.arguments
                channelName:EMMethodKeyRecallMessage
                     result:result];
    } else if ([EMMethodKeyGetConversation isEqualToString:call.method]) {
        [self getConversation:call.arguments
                  channelName:EMMethodKeyGetConversation
                       result:result];
    } else if ([EMMethodKeyGetMessage isEqualToString:call.method]) {
        [self getMessageWithMessageId:call.arguments
                          channelName:EMMethodKeyGetMessage
                               result:result];
    }  else if ([EMMethodKeyMarkAllChatMsgAsRead isEqualToString:call.method]) {
        [self markAllMessagesAsRead:call.arguments
                        channelName:EMMethodKeyMarkAllChatMsgAsRead
                             result:result];
    } else if ([EMMethodKeyGetUnreadMessageCount isEqualToString:call.method]) {
        [self getUnreadMessageCount:call.arguments
                        channelName:EMMethodKeyGetUnreadMessageCount
                             result:result];
    } else if ([EMMethodKeyUpdateChatMessage isEqualToString:call.method]) {
        [self updateChatMessage:call.arguments
                    channelName:EMMethodKeyUpdateChatMessage
                         result:result];
    } else if ([EMMethodKeyDownloadAttachment isEqualToString:call.method]) {
        [self downloadAttachment:call.arguments
                     channelName:EMMethodKeyDownloadAttachment
                          result:result];
    } else if ([EMMethodKeyDownloadThumbnail isEqualToString:call.method]) {
        [self downloadThumbnail:call.arguments
                    channelName:EMMethodKeyDownloadThumbnail
                         result:result];
    } else if ([EMMethodKeyImportMessages isEqualToString:call.method]) {
        [self importMessages:call.arguments
                 channelName:EMMethodKeyImportMessages
                      result:result];
    } else if ([EMMethodKeyLoadAllConversations isEqualToString:call.method]) {
        [self loadAllConversations:call.arguments
                       channelName:EMMethodKeyLoadAllConversations
                            result:result];
    } else if ([EMMethodKeyGetConversationsFromServer isEqualToString:call.method]) {
        [self getConversationsFromServer:call.arguments
                             channelName:EMMethodKeyGetConversationsFromServer
                                  result:result];
    } else if ([EMMethodKeyDeleteConversation isEqualToString:call.method]) {
        [self deleteConversation:call.arguments
                     channelName:EMMethodKeyDeleteConversation
                          result:result];
    } else if ([EMMethodKeyFetchHistoryMessages isEqualToString:call.method]) {
        [self fetchHistoryMessages:call.arguments
                       channelName:EMMethodKeyFetchHistoryMessages
                            result:result];
    } else if ([EMMethodKeySearchChatMsgFromDB isEqualToString:call.method]) {
        [self searchChatMsgFromDB:call.arguments
                      channelName:EMMethodKeySearchChatMsgFromDB
                           result:result];
    } else if ([EMMethodKeyUpdateConversationsName isEqualToString:call.method]) {
        [self updateConversationsName:call.arguments
                          channelName:EMMethodKeyUpdateConversationsName
                               result:result];
    } else if ([EMMethodKeyAsyncFetchGroupAcks isEqualToString:call.method]) {
        [self fetchGroupReadAck:call.arguments
                    channelName:EMMethodKeyAsyncFetchGroupAcks
                         result:result];
    }
    else {
        [super handleMethodCall:call result:result];
    }
}

+ (void)registerWithRegistrar:(nonnull NSObject<FlutterPluginRegistrar> *)registrar {
    
}


#pragma mark - Actions

- (void)sendMessage:(NSDictionary *)param
        channelName:(NSString *)aChannelName
             result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    __block EMChatMessage *msg = [EMChatMessage fromJson:param];
    
    [EMClient.sharedClient.chatManager sendMessage:msg
                                          progress:^(int progress) {
        [weakSelf.messageChannel invokeMethod:EMMethodKeyOnMessageProgressUpdate
                                    arguments:@{
            @"progress":@(progress),
            @"localTime":@(msg.localTime)
        }];
    } completion:^(EMChatMessage *message, EMError *error) {
        if (error) {
            [weakSelf.messageChannel invokeMethod:EMMethodKeyOnMessageError
                                        arguments:@{
                @"error":[error toJson],
                @"localTime":@(msg.localTime),
                @"message":[message toJson]
            }];
        }else {
            [weakSelf.messageChannel invokeMethod:EMMethodKeyOnMessageSuccess
                                        arguments:@{
                @"message":[message toJson],
                @"localTime":@(msg.localTime)
            }];
        }
    }];
    
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:[msg toJson]];
}

- (void)resendMessage:(NSDictionary *)param
          channelName:(NSString *)aChannelName
               result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    __block EMChatMessage *msg = [EMChatMessage fromJson:param];
    
    [EMClient.sharedClient.chatManager resendMessage:msg
                                            progress:^(int progress) {
        [weakSelf.messageChannel invokeMethod:EMMethodKeyOnMessageProgressUpdate
                                    arguments:@{
            @"progress":@(progress),
            @"localTime":@(msg.localTime)
        }];
    } completion:^(EMChatMessage *message, EMError *error) {
        if (error) {
            [weakSelf.messageChannel invokeMethod:EMMethodKeyOnMessageError
                                        arguments:@{
                @"error":[error toJson],
                @"localTime":@(msg.localTime),
                @"message":[message toJson]
            }];
        }else {
            [weakSelf.messageChannel invokeMethod:EMMethodKeyOnMessageSuccess
                                        arguments:@{
                @"message":[message toJson],
                @"localTime":@(msg.localTime)
            }];
        }
    }];
    
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:[msg toJson]];
}


- (void)ackMessageRead:(NSDictionary *)param
           channelName:(NSString *)aChannelName
                result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSString *msgId = param[@"msg_id"];
    NSString *to = param[@"to"];
    [EMClient.sharedClient.chatManager sendMessageReadAck:msgId
                                                   toUser:to
                                               completion:^(EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:@(!aError)];
    }];
}

- (void)ackGroupMessageRead:(NSDictionary *)param
                channelName:(NSString *)aChannelName
                     result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSString *msgId = param[@"msg_id"];
    NSString *groupId = param[@"group_id"];
    NSString *content = param[@"content"];
    [EMClient.sharedClient.chatManager sendGroupMessageReadAck:msgId
                                                       toGroup:groupId
                                                       content:content
                                                    completion:^(EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:@(!aError)];
    }];
}


- (void)ackConversationRead:(NSDictionary *)param
                channelName:(NSString *)aChannelName
                     result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSString *conversationId = param[@"con_id"];
    [EMClient.sharedClient.chatManager ackConversationRead:conversationId
                                                completion:^(EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:@(!aError)];
    }];
}

- (void)recallMessage:(NSDictionary *)param
          channelName:(NSString *)aChannelName
               result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSString *msgId = param[@"msg_id"];
    EMChatMessage *msg = [EMClient.sharedClient.chatManager getMessageWithMessageId:msgId];
    if (!msg) {
        EMError *error = [EMError errorWithDescription:@"The message was not found" code:EMErrorMessageInvalid];
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:error
                           object:@(!error)];
        return;
    }
    [EMClient.sharedClient.chatManager recallMessageWithMessageId:msgId
                                                       completion:^(EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:@(!aError)];
    }];
}

- (void)getMessageWithMessageId:(NSDictionary *)param
                    channelName:(NSString *)aChannelName
                         result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSString *msgId = param[@"msg_id"];
    EMChatMessage *msg = [EMClient.sharedClient.chatManager getMessageWithMessageId:msgId];
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:[msg toJson]];
}

- (void)getConversation:(NSDictionary *)param
            channelName:(NSString *)aChannelName
                 result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSString *conId = param[@"con_id"];
    EMConversationType type = [EMConversation typeFromInt:[param[@"type"] intValue]];
    BOOL needCreate = [param[@"createIfNeed"] boolValue];
    EMConversation *con = [EMClient.sharedClient.chatManager getConversation:conId
                                                                        type:type
                                                            createIfNotExist:needCreate];
    
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:[con toJson]];
}

- (void)markAllMessagesAsRead:(NSDictionary *)param
                  channelName:(NSString *)aChannelName
                       result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSArray *conList = [EMClient.sharedClient.chatManager getAllConversations];
    EMError *error = nil;
    for (EMConversation *con in conList) {
        [con markAllMessagesAsRead:&error];
        if (error) {
            break;
        }
    }
    
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:error
                       object:@(!error)];
}

- (void)getUnreadMessageCount:(NSDictionary *)param
                  channelName:(NSString *)aChannelName
                       result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSArray *conList = [EMClient.sharedClient.chatManager getAllConversations];
    int unreadCount = 0;
    EMError *error = nil;
    for (EMConversation *con in conList) {
        unreadCount += con.unreadMessagesCount;
    }
    
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:error
                       object:@(unreadCount)];
}

- (void)updateChatMessage:(NSDictionary *)param
              channelName:(NSString *)aChannelName
                   result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    EMChatMessage *msg = [EMChatMessage fromJson:param[@"message"]];
    [EMClient.sharedClient.chatManager updateMessage:msg
                                          completion:^(EMChatMessage *aMessage, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[aMessage toJson]];
    }];
}

- (void)importMessages:(NSDictionary *)param
           channelName:(NSString *)aChannelName
                result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSArray *dictAry = param[@"messages"];
    NSMutableArray *messages = [NSMutableArray array];
    for (NSDictionary *dict in dictAry) {
        [messages addObject:[EMChatMessage fromJson:dict]];
    }
    [[EMClient sharedClient].chatManager importMessages:messages
                                             completion:^(EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:@(!aError)];
    }];
}


- (void)downloadAttachment:(NSDictionary *)param
               channelName:(NSString *)aChannelName
                    result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    __block EMChatMessage *msg = [EMChatMessage fromJson:param[@"message"]];
    EMChatMessage *needDownMSg = [EMClient.sharedClient.chatManager getMessageWithMessageId:msg.messageId];
    [EMClient.sharedClient.chatManager downloadMessageAttachment:needDownMSg
                                                        progress:^(int progress)
     {
        [weakSelf.messageChannel invokeMethod:EMMethodKeyOnMessageProgressUpdate
                                    arguments:@{
            @"progress":@(progress),
            @"localTime":@(msg.localTime)
        }];
    } completion:^(EMChatMessage *message, EMError *error)
     {
        if (error) {
            [weakSelf.messageChannel invokeMethod:EMMethodKeyOnMessageError
                                        arguments:@{
                @"error":[error toJson],
                @"localTime":@(msg.localTime),
                @"message":[message toJson]
            }];
        }else {
            [weakSelf.messageChannel invokeMethod:EMMethodKeyOnMessageSuccess
                                        arguments:@{
                @"message":[message toJson],
                @"localTime":@(msg.localTime)
            }];
        }
    }];
    
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:[msg toJson]];
}

- (void)downloadThumbnail:(NSDictionary *)param
              channelName:(NSString *)aChannelName
                   result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    __block EMChatMessage *msg = [EMChatMessage fromJson:param[@"message"]];
    EMChatMessage *needDownMSg = [EMClient.sharedClient.chatManager getMessageWithMessageId:msg.messageId];
    [EMClient.sharedClient.chatManager downloadMessageThumbnail:needDownMSg
                                                       progress:^(int progress)
     {
        [weakSelf.messageChannel invokeMethod:EMMethodKeyOnMessageProgressUpdate
                                    arguments:@{
            @"progress":@(progress),
            @"localTime":@(msg.localTime)
        }];
    } completion:^(EMChatMessage *message, EMError *error)
     {
        if (error) {
            [weakSelf.messageChannel invokeMethod:EMMethodKeyOnMessageError
                                        arguments:@{
                @"error":[error toJson],
                @"localTime":@(msg.localTime),
                @"message":[message toJson]
            }];
        }else {
            [weakSelf.messageChannel invokeMethod:EMMethodKeyOnMessageSuccess
                                        arguments:@{
                @"message":[message toJson],
                @"localTime":@(msg.localTime)
            }];
        }
    }];
    
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:[msg toJson]];
}

- (void)loadAllConversations:(NSDictionary *)param
                 channelName:(NSString *)aChannelName
                      result:(FlutterResult)result {
    NSArray *conversations = [EMClient.sharedClient.chatManager getAllConversations];
    NSArray *sortedList = [conversations sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if (((EMConversation *)obj1).latestMessage.timestamp > ((EMConversation *)obj2).latestMessage.timestamp) {
            return NSOrderedAscending;
        }else {
            return NSOrderedDescending;
        }
    }];
    NSMutableArray *conList = [NSMutableArray array];
    for (EMConversation *conversation in sortedList) {
        [conList addObject:[conversation toJson]];
    }
    
    [self wrapperCallBack:result
              channelName:aChannelName
                    error:nil
                   object:conList];
}

- (void)getConversationsFromServer:(NSDictionary *)param
                       channelName:(NSString *)aChannelName
                            result:(FlutterResult)result {
    [EMClient.sharedClient.chatManager getConversationsFromServer:^(NSArray *aCoversations, EMError *aError) {
        NSArray *sortedList = [aCoversations sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            if (((EMConversation *)obj1).latestMessage.timestamp > ((EMConversation *)obj2).latestMessage.timestamp) {
                return NSOrderedAscending;
            }else {
                return NSOrderedDescending;
            }
        }];
        NSMutableArray *conList = [NSMutableArray array];
        for (EMConversation *conversation in sortedList) {
            [conList addObject:[conversation toJson]];
        }
        
        [self wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:conList];
    }];
}

- (void)deleteConversation:(NSDictionary *)param
               channelName:(NSString *)aChannelName
                    result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSString *conversationId = param[@"con_id"];
    BOOL isDeleteMsgs = [param[@"deleteMessages"] boolValue];
    [EMClient.sharedClient.chatManager deleteConversation:conversationId
                                         isDeleteMessages:isDeleteMsgs
                                               completion:^(NSString *aConversationId, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:@(!aError)];
    }];
}

- (void)fetchHistoryMessages:(NSDictionary *)param
                 channelName:(NSString *)aChannelName
                      result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSString *conversationId = param[@"con_id"];
    EMConversationType type = (EMConversationType)[param[@"type"] intValue];
    int pageSize = [param[@"pageSize"] intValue];
    NSString *startMsgId = param[@"startMsgId"];
    [EMClient.sharedClient.chatManager asyncFetchHistoryMessagesFromServer:conversationId
                                                          conversationType:type
                                                            startMessageId:startMsgId
                                                                  pageSize:pageSize
                                                                completion:^(EMCursorResult *aResult, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[aResult toJson]];
    }];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
//    if (gMainController) {
//        [gMainController jumpToChatList];
//    }
    [[EMClient sharedClient] application:application didReceiveRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
//    if (gMainController) {
//        [gMainController didReceiveLocalNotification:notification];
//    }
}
- (void)emDidRecivePushSilentMessage:(NSDictionary *)messageDic
{
    NSLog(@"emDidRecivePushSilentMessage : %@",messageDic);
}


- (void)fetchGroupReadAck:(NSDictionary *)param
              channelName:(NSString *)aChannelName
                   result:(FlutterResult) result {
    NSString *msgId = param[@"msg_id"];
    int pageSize = [param[@"pageSize"] intValue];
    NSString *ackId = param[@"ack_id"];
    NSString *groupId = param[@"group_id"];

    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.chatManager asyncFetchGroupMessageAcksFromServer:msgId groupId:groupId startGroupAckId:ackId pageSize:pageSize completion:^(EMCursorResult *aResult, EMError *aError, int totalCount) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[aResult toJson]];
    }];
}


- (void)searchChatMsgFromDB:(NSDictionary *)param
                channelName:(NSString *)aChannelName
                     result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSString *keywords = param[@"keywords"];
    long long timeStamp = [param[@"timeStamp"] longLongValue];
    int maxCount = [param[@"maxCount"] intValue];
    NSString *from = param[@"from"];
    EMMessageSearchDirection direction = [self searchDirectionFromString:param[@"direction"]];
    [EMClient.sharedClient.chatManager loadMessagesWithKeyword:keywords
                                                     timestamp:timeStamp
                                                         count:maxCount
                                                      fromUser:from
                                               searchDirection:direction
                                                    completion:^(NSArray *aMessages, EMError *aError)
     {
        NSMutableArray *msgList = [NSMutableArray array];
        for (EMChatMessage *msg in aMessages) {
            [msgList addObject:[msg toJson]];
        }
        
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:msgList];
    }];
}

- (void)updateConversationsName:(NSDictionary *)param
                    channelName:(NSString *)aChannelName
                         result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSDictionary *namesMap = param[@"name_map"];
    
    NSArray *conversationsList = EMClient.sharedClient.chatManager.getAllConversations;
    for (EMConversation *con in conversationsList) {
        if (namesMap[con.conversationId]) {
            NSMutableDictionary *ext = [con.ext mutableCopy];
            if (!ext) {
                ext = [NSMutableDictionary dictionary];
            }
            NSString *current = ext[@"con_name"] ?: @"";
            if (![current isEqualToString:namesMap[@"con_name"]]) {
                ext[@"con_name"] = namesMap[@"con_name"];
                con.ext = ext;
            }
        }
        
    }
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:@(true)];
}

//注册远程通知
- (void)_registerRemoteNotification
{
    UIApplication *application = [UIApplication sharedApplication];
    application.applicationIconBadgeNumber = 0;
    
    if (NSClassFromString(@"UNUserNotificationCenter")) {
        [[EMLocalNotificationManager sharedManager] launchWithDelegate:self];
        
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert completionHandler:^(BOOL granted, NSError *error) {
            if (granted) {
#if !TARGET_IPHONE_SIMULATOR
                dispatch_async(dispatch_get_main_queue(), ^{
                    [application registerForRemoteNotifications];
                });
#endif
            }
        }];
        return;
    }
    
    if([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    
#if !TARGET_IPHONE_SIMULATOR
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [application registerForRemoteNotifications];
    } else {
        UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:notificationTypes];
    }
#endif
}


#pragma mark - EMChatManagerDelegate


- (void)conversationListDidUpdate:(NSArray *)aConversationList {
    [self.channel invokeMethod:EMMethodKeyOnConversationUpdate
                     arguments:nil];
}

- (void)onConversationRead:(NSString *)from
                        to:(NSString *)to {
    [self.channel invokeMethod:EMMethodKeyOnConversationHasRead
                     arguments:@{@"from":from, @"to": to}];
}

- (void)messagesDidReceive:(NSArray *)aMessages {
    NSMutableArray *msgList = [NSMutableArray array];
    for (EMChatMessage *msg in aMessages) {
        
        [msgList addObject:[msg toJson]];
    }
    [self.channel invokeMethod:EMMethodKeyOnMessagesReceived
                     arguments:msgList];
}

- (void)cmdMessagesDidReceive:(NSArray *)aCmdMessages {
    NSMutableArray *cmdMsgList = [NSMutableArray array];
    for (EMChatMessage *msg in aCmdMessages) {
        [cmdMsgList addObject:[msg toJson]];
    }
    
    [self.channel invokeMethod:EMMethodKeyOnCmdMessagesReceived
                     arguments:cmdMsgList];
}

- (void)messagesDidRead:(NSArray *)aMessages {
    NSMutableArray *list = [NSMutableArray array];
    for (EMChatMessage *msg in aMessages) {
        NSDictionary *json = [msg toJson];
        [list addObject:json];
        [self.messageChannel invokeMethod:EMMethodKeyOnMessageReadAck
                                arguments:json];
    }
    
    [self.channel invokeMethod:EMMethodKeyOnMessagesRead arguments:list];
}

- (void)messagesDidDeliver:(NSArray *)aMessages {
    NSMutableArray *list = [NSMutableArray array];
    for (EMChatMessage *msg in aMessages) {
        NSDictionary *json = [msg toJson];
        [list addObject:json];
        [self.messageChannel invokeMethod:EMMethodKeyOnMessageDeliveryAck
                                arguments:@{@"message":json}];
    }
    
    [self.channel invokeMethod:EMMethodKeyOnMessagesDelivered
                     arguments:list];
}

- (void)messagesDidRecall:(NSArray *)aMessages {
    NSMutableArray *list = [NSMutableArray array];
    for (EMChatMessage *msg in aMessages) {
        [list addObject:[msg toJson]];
    }
    
    [self.channel invokeMethod:EMMethodKeyOnMessagesRecalled
                     arguments:list];
}

- (void)messageStatusDidChange:(EMChatMessage *)aMessage
                         error:(EMError *)aError {
    [self.messageChannel invokeMethod:EMMethodKeyOnMessageStatusChanged
                            arguments:@{@"message":[aMessage toJson]}];
}

// TODO: 安卓未找到对应回调
- (void)messageAttachmentStatusDidChange:(EMChatMessage *)aMessage
                                   error:(EMError *)aError {
    
}

- (void)groupMessageDidRead:(EMChatMessage *)aMessage groupAcks:(NSArray *)aGroupAcks {
    NSMutableArray *list = [NSMutableArray array];
    for (EMGroupMessageAck *ack in aGroupAcks) {
        NSDictionary *json = [ack toJson];
        [list addObject:json];
    }
    
    [self.channel invokeMethod:EMMethodKeyOnGroupMessageRead
                     arguments:list];
}


- (EMMessageSearchDirection)searchDirectionFromString:(NSString *)aDirection {
    return [aDirection isEqualToString:@"up"] ? EMMessageSearchDirectionUp : EMMessageSearchDirectionDown;
}


@end
