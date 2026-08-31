//
//  EMChatManagerWrapper.m
//
//
//  Created by 杜洁鹏 on 2019/10/8.
//

#import "ChatManagerWrapper.h"
#import "MethodKeys.h"
#import "NSArray+Helper.h"
#import "MessageHelper.h"
#import "ConversationHelper.h"
#import "GroupMessageAckHelper.h"
#import "ErrorHelper.h"
#import "CursorResultHelper.h"
#import "MessageReactionHelper.h"
#import "MessageReactionChangeHelper.h"
#import "FetchServerMessagesOptionHelper.h"
#import "MessagePinInfoHelper.h"
#import "ConversationFilterHelper.h"
#import "RecallInfoHelper.h"
#import "EnumTools.h"
#import "Helper.h"

@interface ChatManagerWrapper () <EMChatManagerDelegate>
@property (nonatomic, strong) FlutterMethodChannel *messageChannel;

@end

@implementation ChatManagerWrapper
- (instancetype)initWithChannelName:(NSString *)aChannelName
                          registrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    if(self = [super initWithChannelName:aChannelName
                               registrar:registrar]) {
        [EMClient.sharedClient.chatManager addDelegate:self delegateQueue:nil];
        FlutterJSONMethodCodec *codec = [FlutterJSONMethodCodec sharedInstance];
        self.messageChannel = [FlutterMethodChannel methodChannelWithName:@"com.chat.im/chat_message"
                                                          binaryMessenger:[registrar messenger]
                                                                    codec:codec];
        
    }
    return self;
}


- (void)unRegisterEaseListener {
    [EMClient.sharedClient.chatManager removeDelegate:self];
}

#pragma mark - FlutterPlugin


- (void)handleMethodCall:(FlutterMethodCall*)call
                  result:(FlutterResult)result {
    if ([ChatSendMessage isEqualToString:call.method]) {
        [self sendMessage:call.arguments
              channelName:call.method
                   result:result];
    } else if ([ChatResendMessage isEqualToString:call.method]) {
        [self resendMessage:call.arguments
                channelName:call.method
                     result:result];
    } else if ([ChatAckMessageRead isEqualToString:call.method]) {
        [self ackMessageRead:call.arguments
                 channelName:call.method
                      result:result];
    } else if ([ChatAckGroupMessageRead isEqualToString:call.method]) {
        [self ackGroupMessageRead:call.arguments
                      channelName:call.method
                           result:result];
    } else if ([ChatAckConversationRead isEqualToString:call.method]) {
        [self ackConversationRead:call.arguments
                      channelName:call.method
                           result:result];
    } else if ([ChatRecallMessage isEqualToString:call.method]) {
        [self recallMessage:call.arguments
                channelName:call.method
                     result:result];
    } else if ([ChatGetConversation isEqualToString:call.method]) {
        [self getConversation:call.arguments
                  channelName:call.method
                       result:result];
    } else if ([ChatGetThreadConversation isEqualToString:call.method]) {
        [self getThreadConversation:call.arguments
                        channelName:call.method
                             result:result];
    } else if ([ChatGetMessage isEqualToString:call.method]) {
        [self getMessageWithMessageId:call.arguments
                          channelName:call.method
                               result:result];
    }  else if ([ChatMarkAllChatMsgAsRead isEqualToString:call.method]) {
        [self markAllMessagesAsRead:call.arguments
                        channelName:call.method
                             result:result];
    } else if ([ChatGetUnreadMessageCount isEqualToString:call.method]) {
        [self getUnreadMessageCount:call.arguments
                        channelName:call.method
                             result:result];
    } else if ([ChatUpdateChatMessage isEqualToString:call.method]) {
        [self updateChatMessage:call.arguments
                    channelName:call.method
                         result:result];
    } else if ([ChatDownloadAttachment isEqualToString:call.method]) {
        [self downloadAttachment:call.arguments
                     channelName:call.method
                          result:result];
    } else if ([ChatDownloadBigImage isEqualToString:call.method]) {
        [self downloadBigImage:call.arguments
                   channelName:call.method
                        result:result];
    } else if ([ChatDownloadThumbnail isEqualToString:call.method]) {
        [self downloadThumbnail:call.arguments
                    channelName:call.method
                         result:result];
    } else if ([ChatDownloadMessageAttachmentInCombine isEqualToString:call.method]) {
        [self downloadMessageAttachmentInCombine:call.arguments
                                     channelName:call.method
                                          result:result];
    } else if ([ChatDownloadMessageThumbnailInCombine isEqualToString:call.method]) {
        [self downloadMessageThumbnailInCombine:call.arguments
                                    channelName:call.method
                                         result:result];
    } else if ([ChatImportMessages isEqualToString:call.method]) {
        [self importMessages:call.arguments
                 channelName:call.method
                      result:result];
    } else if ([ChatLoadAllConversations isEqualToString:call.method]) {
        [self loadAllConversations:call.arguments
                       channelName:call.method
                            result:result];
    } else if ([ChatGetConversationsFromServer isEqualToString:call.method]) {
        [self getConversationsFromServer:call.arguments
                             channelName:call.method
                                  result:result];
    } else if ([ChatDeleteConversation isEqualToString:call.method]) {
        [self deleteConversation:call.arguments
                     channelName:call.method
                          result:result];
    } else if ([ChatFetchHistoryMessages isEqualToString:call.method]) {
        [self fetchHistoryMessages:call.arguments
                       channelName:call.method
                            result:result];
    } else if ([ChatFetchHistoryMessagesByOptions isEqualToString:call.method]) {
        [self fetchHistoryMessagesByOptions:call.arguments
                                channelName:call.method
                                     result:result];
    } else if ([ChatSearchChatMsgFromDB isEqualToString:call.method]) {
        [self searchChatMsgFromDB:call.arguments
                      channelName:call.method
                           result:result];
    } else if ([ChatAsyncFetchGroupAcks isEqualToString:call.method]) {
        [self fetchGroupReadAck:call.arguments
                    channelName:call.method
                         result:result];
    } else if ([ChatDeleteRemoteConversation isEqualToString:call.method]){
        [self deleteRemoteConversation:call.arguments
                           channelName:call.method
                                result:result];
    } else if ([ChatDeleteMessagesBeforeTimestamp isEqualToString:call.method]){
        [self deleteMessagesBeforeTimestamp:call.arguments
                                channelName:call.method
                                     result:result];
    } else if ([ChatTranslateMessage isEqualToString:call.method]) {
        [self translateMessage:call.arguments
                   channelName:call.method
                        result:result];
    } else if ([ChatFetchSupportedLanguages isEqualToString:call.method]) {
        [self fetchSupportLanguages:call.arguments
                        channelName:call.method
                             result:result];
    } else if ([ChatAddReaction isEqualToString:call.method]) {
        [self addReaction:call.arguments
              channelName:call.method
                   result:result];
    } else if ([ChatRemoveReaction isEqualToString:call.method]) {
        [self removeReaction:call.arguments
                 channelName:call.method
                      result:result];
    } else if ([ChatFetchReactionList isEqualToString:call.method]) {
        [self fetchReactionList:call.arguments
                    channelName:call.method
                         result:result];
    } else if ([ChatFetchReactionDetail isEqualToString:call.method]) {
        [self fetchReactionDetail:call.arguments
                      channelName:call.method
                           result:result];
    } else if ([ChatReportMessage isEqualToString:call.method]) {
        [self reportMessage:call.arguments
                channelName:call.method
                     result:result];
    } else if ([ChatFetchConversationsFromServerWithPage isEqualToString: call.method]) {
        [self fetchConversationsFromServerWithPage:call.arguments
                                       channelName:call.method
                                            result:result];
    } else if ([ChatRemoveMessagesFromServerWithMsgIds isEqualToString: call.method]) {
        [self removeMessagesFromServerWithMsgIds:call.arguments
                                     channelName:call.method
                                          result:result];
    } else if ([ChatRemoveMessagesFromServerWithTs isEqualToString: call.method]) {
        [self removeMessagesFromServerWithTs:call.arguments
                                 channelName:call.method
                                      result:result];
    } else if ([GetConversationsFromServerWithCursor isEqualToString:call.method]) {
        [self getConversationsFromServerWithCursor:call.arguments channelName:call.method result:result];
    } else if ([GetPinnedConversationsFromServerWithCursor isEqualToString:call.method]) {
        [self getPinnedConversationsFromServerWithCursor:call.arguments channelName:call.method result:result];
    } else if ([PinConversation isEqualToString:call.method]) {
        [self pinConversation:call.arguments channelName:call.method result:result];
    } else if ([modifyMessage isEqualToString:call.method]) {
        [self modifyMessage:call.arguments channelName:call.method result:result];
    } else if ([downloadAndParseCombineMessage isEqualToString:call.method]) {
        [self downloadAndParseCombineMessage:call.arguments channelName:call.method result:result];
    }
    // 450
    else if([addRemoteAndLocalConversationsMark isEqualToString:call.method]) {
        [self addRemoteAndLocalConversationsMark:call.arguments channelName:call.method result:result];
    }
    else if([deleteRemoteAndLocalConversationsMark isEqualToString:call.method]) {
        [self deleteRemoteAndLocalConversationsMark:call.arguments channelName:call.method result:result];
    }
    else if([fetchConversationsByOptions isEqualToString:call.method]) {
        [self fetchConversationsByOptions:call.arguments channelName:call.method result:result];
    }
    else if([deleteAllMessageAndConversation isEqualToString:call.method]) {
        [self deleteAllMessageAndConversation:call.arguments channelName:call.method result:result];
    }
    else if([pinMessage isEqualToString:call.method]) {
        [self pinMessage:call.arguments channelName:call.method result:result];
    }
    else if([unpinMessage isEqualToString:call.method]) {
        [self unpinMessage:call.arguments channelName:call.method result:result];
    }
    else if([fetchPinnedMessages isEqualToString:call.method]) {
        [self fetchPinnedMessages:call.arguments channelName:call.method result:result];
    }
    // 481
    else if ([ChatSearchMsgsByOptions isEqualToString:call.method]) {
        [self searchMsgsByOptions:call.arguments channelName:call.method result:result];
    }
    // 4.10
    else if ([getMessageCount isEqualToString:call.method]) {
        [self getMessageCount:call.arguments channelName:call.method result:result];
    }
    // 4.15.2
    else if ([loadConversationMessagesWithKeyword isEqualToString:call.method]) {
        [self loadConversationMessagesWithKeyword:call.arguments channelName:call.method result:result];
    }
    else if ([ChatLoadMessagesWithIds isEqualToString:call.method]) {
        [self loadMessagesWithIds:call.arguments channelName:call.method result:result];
    } else if ([ChatCleanConversationsMemoryCache isEqualToString:call.method]) {
        [self cleanConversationsMemoryCache:call.arguments channelName:call.method result:result];
    } else if ([ChatFilterConversationsFromDB isEqualToString:call.method]) {
        [self filterConversationsFromDB:call.arguments channelName:call.method result:result];
    } else if ([ChatVoiceMessageToText isEqualToString:call.method]) {
        [self voiceMessageToText:call.arguments channelName:call.method result:result];
    } else if ([ChatVoiceFileToText isEqualToString:call.method]) {
        [self voiceFileToText:call.arguments channelName:call.method result:result];
    } else if ([ChatSearchMessagesFromServer isEqualToString:call.method]) {
        [self searchMessagesFromServer:call.arguments channelName:call.method result:result];
    } else if ([ChatDeleteConversations isEqualToString:call.method]) {
        [self deleteConversations:call.arguments channelName:call.method result:result];
    } else if ([ChatGetGroupMessageReadReceipts isEqualToString:call.method]) {
        [self getGroupMessageReadReceipts:call.arguments channelName:call.method result:result];
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
    __block NSString *msgId = msg.messageId;
    
    [EMClient.sharedClient.chatManager sendMessage:msg
                                          progress:^(int progress) {
        [weakSelf.messageChannel invokeMethod:ChatOnMessageProgressUpdate
                                    arguments:@{
            @"progress":@(progress),
            @"localId":msgId
        }];
    } completion:^(EMChatMessage *message, EMError *error) {
        if (error) {
            [weakSelf.messageChannel invokeMethod:ChatOnMessageError
                                        arguments:@{
                @"error":[error toJson],
                @"localId":msgId,
                @"message":[message toJson]
            }];
        }else {
            [weakSelf.messageChannel invokeMethod:ChatOnMessageSuccess
                                        arguments:@{
                @"message":[message toJson],
                @"localId":msgId
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
    __block NSString *msgId = msg.messageId;
    [ChatCompat5 resendMessage:EMClient.sharedClient.chatManager message:msg progress:^(int progress) {
        [weakSelf.messageChannel invokeMethod:ChatOnMessageProgressUpdate
                                    arguments:@{
            @"progress":@(progress),
            @"localId":msgId
        }];
    } completion:^(EMChatMessage *message, EMError *error) {
        if (error) {
            [weakSelf.messageChannel invokeMethod:ChatOnMessageError
                                        arguments:@{
                @"error":[error toJson],
                @"localId":msgId,
                @"message":[message toJson]
            }];
        }else {
            [weakSelf.messageChannel invokeMethod:ChatOnMessageSuccess
                                        arguments:@{
                @"message":[message toJson],
                @"localId":msgId
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
    NSString *msgId = param[@"msgId"];
    NSString *to = param[@"to"];
    [ChatCompat5 sendMessageReadAck:EMClient.sharedClient.chatManager msgId:msgId toUser:to completion:^(EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:(aError == nil ? @YES : @NO)];
    }];
}

- (void)ackGroupMessageRead:(NSDictionary *)param
                channelName:(NSString *)aChannelName
                     result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSString *msgId = param[@"msgId"];
    NSString *groupId = param[@"group_id"];
    NSString *content = param[@"content"];
    [ChatCompat5 sendGroupMessageReadAck:EMClient.sharedClient.chatManager msgId:msgId toGroup:groupId content:content completion:^(EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:(aError == nil ? @YES : @NO)];
    }];
}


- (void)ackConversationRead:(NSDictionary *)param
                channelName:(NSString *)aChannelName
                     result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSString *conversationId = param[@"convId"];
    [ChatCompat5 ackConversationRead:EMClient.sharedClient.chatManager conversationId:conversationId completion:^(EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:(aError == nil ? @YES : @NO)];
    }];
}

- (void)recallMessage:(NSDictionary *)param
          channelName:(NSString *)aChannelName
               result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSString *msgId = param[@"msgId"];
    NSString *ext = param[@"ext"];
    // 【透传原生】不本地拦截（无效消息也调原生）
    EMChatMessage *msg = [EMClient.sharedClient.chatManager getMessageWithMessageId:msgId];
    [EMClient.sharedClient.chatManager recallMessageWithMessageId:msgId
                                                              ext:ext
                                                       completion:^(EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:(aError == nil ? @YES : @NO)];
    }];
}

- (void)getMessageWithMessageId:(NSDictionary *)param
                    channelName:(NSString *)aChannelName
                         result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSString *msgId = param[@"msgId"];
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
    NSString *conId = param[@"convId"];
    EMConversationType type = [EnumTools conversationTypeFromInt:[param[@"type"] intValue]];
    BOOL needCreate = [param[@"createIfNeed"] boolValue];
    EMConversation *con = [EMClient.sharedClient.chatManager getConversation:conId
                                                                        type:type
                                                            createIfNotExist:needCreate];
    
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:[con toJson]];
}

- (void)getThreadConversation:(NSDictionary *)param
                  channelName:(NSString *)aChannelName
                       result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSString *conId = param[@"convId"];
    EMConversation *conversation = [EMClient.sharedClient.chatManager getConversation:conId
                                                                                 type:EMConversationTypeGroupChat
                                                                     createIfNotExist:YES
                                                                             isThread:YES];
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:[conversation toJson]];
}

- (void)markAllMessagesAsRead:(NSDictionary *)param
                  channelName:(NSString *)aChannelName
                       result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    EMError *error = nil;
    [ChatCompat5 markAllConversationsAsRead:EMClient.sharedClient.chatManager];
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:error
                       object:@YES];
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
    EMChatMessage *dbMsg = [EMClient.sharedClient.chatManager getMessageWithMessageId:msg.messageId];
    // 【透传原生】不本地拦截（dbMsg nil 也继续）
    [Helper mergeMessage:msg withDBMessage:dbMsg];
    [EMClient.sharedClient.chatManager updateMessage:dbMsg
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
                           object:(aError == nil ? @YES : @NO)];
    }];
}


- (void)downloadMessageAttachmentInCombine:(NSDictionary *)param
                               channelName:(NSString *)aChannelName
                                    result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    __block EMChatMessage *msg = [EMChatMessage fromJson:param[@"message"]];
    [EMClient.sharedClient.chatManager downloadMessageAttachment:msg
                                                        progress:^(int progress)
     {
        [weakSelf.messageChannel invokeMethod:ChatOnMessageProgressUpdate
                                    arguments:@{
            @"progress":@(progress),
            @"localId": msg.messageId
        }];
    } completion:^(EMChatMessage *message, EMError *error)
     {
        if (error) {
            NSDictionary *msgDict = [self updateDownloadStatus:EMDownloadStatusFailed message:message thumbnail:NO];
            [weakSelf.messageChannel invokeMethod:ChatOnMessageError
                                        arguments:@{
                @"error":[error toJson],
                @"localId":msg.messageId,
                @"message":msgDict
            }];
        }else {
            NSDictionary *msgDict = [self updateDownloadStatus:EMDownloadStatusSucceed message:message thumbnail:NO];
            [weakSelf.messageChannel invokeMethod:ChatOnMessageSuccess
                                        arguments:@{
                @"message": msgDict,
                @"localId": msg.messageId
            }];
        }
    }];
    
    NSDictionary *msgDict = [self updateDownloadStatus:EMDownloadStatusDownloading message:msg thumbnail:NO];
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:msgDict];
}

- (void)downloadMessageThumbnailInCombine:(NSDictionary *)param
                              channelName:(NSString *)aChannelName
                                   result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    __block EMChatMessage *msg = [EMChatMessage fromJson:param[@"message"]];
    [EMClient.sharedClient.chatManager downloadMessageThumbnail:msg
                                                       progress:^(int progress)
     {
        [weakSelf.messageChannel invokeMethod:ChatOnMessageProgressUpdate
                                    arguments:@{
            @"progress":@(progress),
            @"localId":msg.messageId
        }];
    } completion:^(EMChatMessage *message, EMError *error)
     {
        if (error) {
            NSDictionary *msgDict = [self updateDownloadStatus:EMDownloadStatusFailed message:message thumbnail:YES];
            [weakSelf.messageChannel invokeMethod:ChatOnMessageError
                                        arguments:@{
                @"error":[error toJson],
                @"localId":msg.messageId,
                @"message":msgDict
            }];
        }else {
            NSDictionary *msgDict = [self updateDownloadStatus:EMDownloadStatusSucceed message:message thumbnail:YES];
            [weakSelf.messageChannel invokeMethod:ChatOnMessageSuccess
                                        arguments:@{
                @"message":msgDict,
                @"localId":msg.messageId
            }];
        }
    }];
    NSDictionary *msgDict = [self updateDownloadStatus:EMDownloadStatusDownloading message:msg thumbnail:YES];
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:msgDict];
}

- (void)downloadAttachment:(NSDictionary *)param
               channelName:(NSString *)aChannelName
                    result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    __block EMChatMessage *msg = [EMChatMessage fromJson:param[@"message"]];
    EMChatMessage *tmpMsg = [EMClient.sharedClient.chatManager getMessageWithMessageId:msg.messageId];
    NSLog(@"downloadAttachment msg: %@", tmpMsg);
    [EMClient.sharedClient.chatManager downloadMessageAttachment:tmpMsg
                                                        progress:^(int progress)
     {
        [weakSelf.messageChannel invokeMethod:ChatOnMessageProgressUpdate
                                    arguments:@{
            @"progress":@(progress),
            @"localId": msg.messageId
        }];
    } completion:^(EMChatMessage *message, EMError *error)
     {
        if (error) {
            NSDictionary *msgDict = [self updateDownloadStatus:EMDownloadStatusFailed message:message thumbnail:NO];
            [weakSelf.messageChannel invokeMethod:ChatOnMessageError
                                        arguments:@{
                @"error":[error toJson],
                @"localId": msg.messageId,
                @"message":msgDict
            }];
        }else {
            NSDictionary *msgDict = [self updateDownloadStatus:EMDownloadStatusSucceed message:message thumbnail:NO];
            [weakSelf.messageChannel invokeMethod:ChatOnMessageSuccess
                                        arguments:@{
                @"message":msgDict,
                @"localId": msg.messageId
            }];
        }
    }];
    
    NSDictionary *msgDict = [self updateDownloadStatus:EMDownloadStatusDownloading message:msg thumbnail:NO];
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:msgDict];
}

- (void)downloadBigImage:(NSDictionary *)param
             channelName:(NSString *)aChannelName
                  result:(FlutterResult)result {
    // 对齐 names 表：下载大图 = downloadBigImageAttachment（不是普通 downloadMessageAttachment）
    __weak typeof(self) weakSelf = self;
    __block EMChatMessage *msg = [EMChatMessage fromJson:param[@"message"]];
    EMChatMessage *tmpMsg = [EMClient.sharedClient.chatManager getMessageWithMessageId:msg.messageId];
    [EMClient.sharedClient.chatManager downloadBigImageAttachment:tmpMsg
                                                         progress:^(int progress)
     {
        [weakSelf.messageChannel invokeMethod:ChatOnMessageProgressUpdate
                                    arguments:@{
            @"progress":@(progress),
            @"localId": msg.messageId
        }];
    } completion:^(EMChatMessage *message, EMError *error)
     {
        if (error) {
            NSDictionary *msgDict = [self updateDownloadStatus:EMDownloadStatusFailed message:message thumbnail:NO];
            [weakSelf.messageChannel invokeMethod:ChatOnMessageError
                                        arguments:@{
                @"error":[error toJson],
                @"localId": msg.messageId,
                @"message":msgDict
            }];
        }else {
            NSDictionary *msgDict = [self updateDownloadStatus:EMDownloadStatusSucceed message:message thumbnail:NO];
            [weakSelf.messageChannel invokeMethod:ChatOnMessageSuccess
                                        arguments:@{
                @"message":msgDict,
                @"localId": msg.messageId
            }];
        }
    }];
    
    NSDictionary *msgDict = [self updateDownloadStatus:EMDownloadStatusDownloading message:msg thumbnail:NO];
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:msgDict];
}

- (void)downloadThumbnail:(NSDictionary *)param
              channelName:(NSString *)aChannelName
                   result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    __block EMChatMessage *msg = [EMChatMessage fromJson:param[@"message"]];
    EMChatMessage *tmpMsg = [EMClient.sharedClient.chatManager getMessageWithMessageId:msg.messageId];
    [EMClient.sharedClient.chatManager downloadMessageThumbnail:tmpMsg
                                                       progress:^(int progress)
     {
        [weakSelf.messageChannel invokeMethod:ChatOnMessageProgressUpdate
                                    arguments:@{
            @"progress":@(progress),
            @"localId":msg.messageId
        }];
    } completion:^(EMChatMessage *message, EMError *error)
     {
        if (error) {
            NSDictionary *msgDict = [self updateDownloadStatus:EMDownloadStatusFailed message:message thumbnail:YES];
            [weakSelf.messageChannel invokeMethod:ChatOnMessageError
                                        arguments:@{
                @"error":[error toJson],
                @"localId":msg.messageId,
                @"message":msgDict
            }];
        }else {
            NSDictionary *msgDict = [self updateDownloadStatus:EMDownloadStatusSucceed message:message thumbnail:YES];
            [weakSelf.messageChannel invokeMethod:ChatOnMessageSuccess
                                        arguments:@{
                @"message":msgDict,
                @"localId":msg.messageId
            }];
        }
    }];
    NSDictionary *msgDict = [self updateDownloadStatus:EMDownloadStatusDownloading message:msg thumbnail:YES];
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:msgDict];
}

// 用于修改下载状态。
- (NSDictionary *)updateDownloadStatus:(EMDownloadStatus)status
                               message:(EMChatMessage *)msg
                             thumbnail:(BOOL)isThumbnail
{
    BOOL canUpdate = NO;
    switch(msg.body.type){
        case EMMessageBodyTypeFile:
        case EMMessageBodyTypeVoice:{
            if(isThumbnail) {
                break;
            }
        }
        case EMMessageBodyTypeVideo:
        case EMMessageBodyTypeImage:{
            canUpdate = YES;
        }
            break;
        default:
            break;
    }
    
    if(canUpdate) {
        EMMessageBody *body = msg.body;
        if(msg.body.type == EMMessageBodyTypeFile) {
            EMFileMessageBody *tmpBody = (EMFileMessageBody *)body;
            tmpBody.downloadStatus = status;
            body = tmpBody;
        }else if(msg.body.type == EMMessageBodyTypeVoice) {
            EMVoiceMessageBody *tmpBody = (EMVoiceMessageBody *)body;
            tmpBody.downloadStatus = status;
            body = tmpBody;
        }else if(msg.body.type == EMMessageBodyTypeImage) {
            EMImageMessageBody *tmpBody = (EMImageMessageBody *)body;
            if(isThumbnail) {
                tmpBody.thumbnailDownloadStatus = status;
            }else {
                tmpBody.downloadStatus = status;
            }
            body = tmpBody;
        }else if(msg.body.type == EMMessageBodyTypeVideo) {
            EMVideoMessageBody *tmpBody = (EMVideoMessageBody *)body;
            if(isThumbnail) {
                tmpBody.thumbnailDownloadStatus = status;
            }else {
                tmpBody.downloadStatus = status;
            }
            body = tmpBody;
        }
        msg.body = body;
    }
    return [msg toJson];
}

- (void)loadAllConversations:(NSDictionary *)param
                 channelName:(NSString *)aChannelName
                      result:(FlutterResult)result {
    NSArray *conversations = [EMClient.sharedClient.chatManager getAllConversations:YES];
    
    NSMutableArray *conList = [NSMutableArray array];
    for (EMConversation *conversation in conversations) {
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
    [ChatCompat5 getConversationsFromServer:EMClient.sharedClient.chatManager completion:^(NSArray *aCoversations, EMError *aError) {
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
    NSString *conversationId = param[@"convId"];
    BOOL isDeleteMsgs = [param[@"deleteMessages"] boolValue];
    [EMClient.sharedClient.chatManager deleteConversation:conversationId
                                         isDeleteMessages:isDeleteMsgs
                                               completion:^(NSString *aConversationId, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:(aError == nil ? @YES : @NO)];
    }];
}

- (void)fetchHistoryMessages:(NSDictionary *)param
                 channelName:(NSString *)aChannelName
                      result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSString *conversationId = param[@"convId"];
    EMConversationType type = [EnumTools conversationTypeFromInt:[param[@"type"] intValue]];
    int pageSize = [param[@"pageSize"] intValue];
    NSString *startMsgId = param[@"startMsgId"];
    EMMessageFetchHistoryDirection direction = [param[@"direction"] intValue] == 0 ? EMMessageFetchHistoryDirectionUp : EMMessageFetchHistoryDirectionDown;
    [ChatCompat5 asyncFetchHistoryMessages:EMClient.sharedClient.chatManager conversationId:conversationId type:type startMsgId:startMsgId direction:(int)direction pageSize:pageSize completion:^(EMCursorResult<EMChatMessage *> * _Nullable aResult, EMError * _Nullable aError) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[aResult toJson]];
    }];
}

- (void)fetchHistoryMessagesByOptions:(NSDictionary *)param
                          channelName:(NSString *)aChannelName
                               result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSString *conversationId = param[@"convId"];
    EMConversationType type = [EnumTools conversationTypeFromInt:[param[@"type"] intValue]];
    int pageSize = [param[@"pageSize"] intValue];
    NSString *cursor = param[@"cursor"];
    EMFetchServerMessagesOption *options;
    if(param[@"options"]) {
        options = [EMFetchServerMessagesOption fromJson:param[@"options"]];
    }
    [EMClient.sharedClient.chatManager fetchMessagesFromServerBy:conversationId conversationType:type cursor:cursor pageSize:pageSize option:options completion:^(EMCursorResult<EMChatMessage *> * _Nullable aResult, EMError * _Nullable aError) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[aResult toJson]];
    }];
}


- (void)fetchGroupReadAck:(NSDictionary *)param
              channelName:(NSString *)aChannelName
                   result:(FlutterResult) result {
    NSString *msgId = param[@"msgId"];
    int pageSize = [param[@"pageSize"] intValue];
    NSString *ackId = param[@"ack_id"];
    __weak typeof(self) weakSelf = self;
    // 【透传原生】不本地校验（无效消息/非群也调原生）
    EMChatMessage *msg = [EMClient.sharedClient.chatManager getMessageWithMessageId:msgId];
    EMError *e = nil;
    do {
        e = nil;
    } while (NO);
    if (e != nil) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:e
                           object:nil];
        return;
    }
    [ChatCompat5 asyncFetchGroupMessageAcks:EMClient.sharedClient.chatManager msgId:msgId groupId:msg.conversationId startAckId:ackId pageSize:pageSize completion:^(EMCursorResult *aResult, EMError *aError, int totalCount)
     {
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
    long long timestamp = [param[@"timestamp"] longLongValue];
    int maxCount = [param[@"count"] intValue];
    NSString *from = param[@"from"];
    EMMessageSearchScope scope = (EMMessageSearchScope)[param[@"searchScope"] integerValue];
    EMMessageSearchDirection direction = [EnumTools searchDirectionFromInt:[param[@"direction"] integerValue]];
    
    
    [EMClient.sharedClient.chatManager loadMessagesWithKeyword:keywords timestamp:timestamp count:maxCount fromUser:from searchDirection:direction scope:scope completion:^(NSArray<EMChatMessage *> *aMessages, EMError *aError) {
        NSMutableArray *msgList = [NSMutableArray array];
        for (EMChatMessage *msg in aMessages) {
            [msgList addObject:[msg toJson]];
        }
        
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:msgList];
    }] ;
}


- (void)deleteRemoteConversation:(NSDictionary *)param
                     channelName:(NSString *)aChannelName
                          result:(FlutterResult)result
{
    __weak typeof(self) weakSelf = self;
    NSString *conversationId = param[@"convId"];
    EMConversationType type = [EnumTools conversationTypeFromInt:[param[@"conversationType"] intValue]];
    BOOL isDeleteRemoteMessage = [param[@"isDeleteRemoteMessage"] boolValue];
    
    [EMClient.sharedClient.chatManager deleteServerConversation:conversationId
                                               conversationType:type
                                         isDeleteServerMessages:isDeleteRemoteMessage
                                                     completion:^(NSString *aConversationId, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:nil];
    }];
}

- (void)deleteMessagesBeforeTimestamp:(NSDictionary *)param
                          channelName:(NSString *)aChannelName
                               result:(FlutterResult)result
{
    long timestamp = [param[@"timestamp"] longValue];
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.chatManager deleteMessagesBefore:timestamp completion:^(EMError *error) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:error
                           object:nil];
    }];
}

- (void)translateMessage:(NSDictionary *)param
             channelName:(NSString *)aChannelName
                  result:(FlutterResult)result{
    EMChatMessage *msg = [EMChatMessage fromJson:param[@"message"]];
    
    NSArray *languages = param[@"languages"];
    
    EMChatMessage *dbMsg = [EMClient.sharedClient.chatManager getMessageWithMessageId:msg.messageId];
    
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.chatManager translateMessage:dbMsg
                                        targetLanguages:languages completion:^(EMChatMessage *message, EMError *error)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:error
                           object:[message toJson]];
    }];
}

- (void)fetchSupportLanguages:(NSDictionary *)param
                  channelName:(NSString *)aChannelName
                       result:(FlutterResult)result{
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.chatManager fetchSupportedLanguages:^(NSArray<EMTranslateLanguage *> * _Nullable languages, EMError * _Nullable error) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:error
                           object:[languages toJsonArray]];
    }];
}

- (void)addReaction:(NSDictionary *)param
        channelName:(NSString *)aChannelName
             result:(FlutterResult)result {
    NSString *reaction = param[@"reaction"];
    NSString *msgId = param[@"msgId"];
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.chatManager addReaction:reaction
                                         toMessage:msgId
                                        completion:^(EMError * error)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:error
                           object:nil];
    }];
}

- (void)removeReaction:(NSDictionary *)param
           channelName:(NSString *)aChannelName
                result:(FlutterResult)result {
    NSString *reaction = param[@"reaction"];
    NSString *msgId = param[@"msgId"];
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.chatManager removeReaction:reaction fromMessage:msgId completion:^(EMError * error) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:error
                           object:nil];
    }];
}

- (void)fetchReactionList:(NSDictionary *)param
              channelName:(NSString *)aChannelName
                   result:(FlutterResult)result {
    NSArray *msgIds = param[@"msgIds"];
    NSString *groupId = param[@"groupId"];
    EMChatType type = [EnumTools chatTypeFromInt:[param[@"chatType"] integerValue]];
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.chatManager getReactionList:msgIds
                                               groupId:groupId
                                              chatType:type
                                            completion:^(NSDictionary<NSString *,NSArray *> * dic, EMError * error)
     {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        for (NSString *key in dic.allKeys) {
            NSArray *ary = dic[key];
            NSMutableArray *list = [NSMutableArray array];
            for (EMMessageReaction *reaction in ary) {
                [list addObject:[reaction toJson]];
            }
            dictionary[key] = list;
        }
        
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:error
                           object:dictionary];
    }];
}

- (void)fetchReactionDetail:(NSDictionary *)param
                channelName:(NSString *)aChannelName
                     result:(FlutterResult)result {
    NSString *msgId = param[@"msgId"];
    NSString *reaction = param[@"reaction"];
    NSString *cursor = param[@"cursor"];
    int pageSize = [param[@"pageSize"] intValue];
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.chatManager getReactionDetail:msgId
                                                reaction:reaction
                                                  cursor:cursor
                                                pageSize:pageSize
                                              completion:^(EMMessageReaction * reaction, NSString * _Nullable cursor, EMError * error)
     {
        EMCursorResult *cursorResult = nil;
        if (error == nil && reaction != nil) {
            cursorResult = [EMCursorResult cursorResultWithList:@[reaction] andCursor:cursor];
        } else if (error == nil) {
            // invalid 但成功（原生无 error、reaction nil）→ 空结果（对齐 Android {list:[], cursor:''}）
            cursorResult = [EMCursorResult cursorResultWithList:@[] andCursor:@""];
        }
        
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:error
                           object:[cursorResult toJson]];
    }];
}

- (void)reportMessage:(NSDictionary *)param
          channelName:(NSString *)aChannelName
               result:(FlutterResult)result {
    NSString *msgId = param[@"msgId"];
    NSString *tag = param[@"tag"];
    NSString *reason = param[@"reason"];
    __weak typeof(self) weakSelf = self;
    [ChatCompat5 reportMessage:EMClient.sharedClient.chatManager msgId:msgId tag:tag reason:reason completion:^(EMError *error)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:error
                           object:(error == nil ? @YES : @NO)];
    }];
}

- (void)fetchConversationsFromServerWithPage:(NSDictionary *)param
                                 channelName:(NSString *)aChannelName
                                      result:(FlutterResult)result {
    int pageSize = [param[@"pageSize"] intValue];
    int pageNum = [param[@"pageNum"] intValue];
    
    __weak typeof(self) weakSelf = self;
    
    [ChatCompat5 getConversationsFromServerByPage:EMClient.sharedClient.chatManager pageNum:pageNum pageSize:pageSize completion:^(NSArray<EMConversation *> * _Nullable aConversations, EMError * _Nullable aError)
     {
        NSArray *sortedList = [aConversations sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
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
        
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:conList];
    }];
}

- (void)removeMessagesFromServerWithMsgIds:(NSDictionary *)param
                               channelName:(NSString *)aChannelName
                                    result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSArray *msgIds = param[@"msgIds"];
    NSString *convId = param[@"convId"];
    EMConversationType type = [EnumTools conversationTypeFromInt:[param[@"type"] intValue]];
    
    // 【透传原生】不本地检查登录（原生处理）
    
    
    // 【透传原生】不本地参数校验（原生处理）
    
    
    EMConversation *conversation = [EMClient.sharedClient.chatManager getConversation:convId type:type createIfNotExist:YES];
    
    [conversation removeMessagesFromServerMessageIds:msgIds completion:^(EMError * _Nullable aError) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:nil];
    }];
}

- (void)removeMessagesFromServerWithTs:(NSDictionary *)param
                           channelName:(NSString *)aChannelName
                                result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSString *convId = param[@"convId"];
    EMConversationType type = [EnumTools conversationTypeFromInt:[param[@"type"] intValue]];
    long timestamp = [param[@"timestamp"] longValue];
    
    // 【透传原生】不本地检查登录（原生处理）
    
    // 【透传原生】不本地参数校验（原生处理）
    
    EMConversation *conversation = [EMClient.sharedClient.chatManager getConversation:convId type:type createIfNotExist:YES];
    [conversation removeMessagesFromServerWithTimeStamp:timestamp completion:^(EMError * _Nullable aError) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:nil];
    }];
}

- (void)getConversationsFromServerWithCursor:(NSDictionary *)param
                                 channelName:(NSString *)aChannelName
                                      result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSString *cursor = param[@"cursor"];
    int pageSize = [param[@"pageSize"] intValue];
    [ChatCompat5 getConversationsFromServerWithCursor:EMClient.sharedClient.chatManager cursor:cursor pageSize:pageSize completion:^(NSArray * _Nullable ret, EMError * _Nullable error) {
        // 5.0 返回纯 list（与 Android 一致，无 cursor 语义）
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:error
                           object:ret];
    }];
}

- (void)getPinnedConversationsFromServerWithCursor:(NSDictionary *)param
                                       channelName:(NSString *)aChannelName
                                            result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSString *cursor = param[@"cursor"];
    int pageSize = [param[@"pageSize"] intValue];
    [ChatCompat5 getPinnedConversationsFromServerWithCursor:EMClient.sharedClient.chatManager cursor:cursor pageSize:pageSize completion:^(NSArray * _Nullable ret, EMError * _Nullable error) {
        // 5.0 返回纯 list（与 Android 一致）
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:error
                           object:ret];
    }];
}

- (void)pinConversation:(NSDictionary *)param
            channelName:(NSString *)aChannelName
                 result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSString *convId = param[@"convId"];
    BOOL isPinned = [param[@"isPinned"] boolValue];
    [EMClient.sharedClient.chatManager pinConversation:convId isPinned:isPinned completionBlock:^(EMError * _Nullable error) {
        [weakSelf wrapperCallBack:result channelName:aChannelName error:error object:nil];
    }];
}

- (void)modifyMessage:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSString *msgId = param[@"msgId"];
    EMMessageBody *body = (param[@"msgBody"] && ![param[@"msgBody"] isKindOfClass:[NSNull class]])
    ? [EMMessageBody fromJson:param[@"msgBody"]]
    : nil;
    NSDictionary *ext = param[@"attributes"];
    [EMClient.sharedClient.chatManager modifyMessage:msgId
                                                body:body
                                                 ext:ext
                                          completion:^(EMError * _Nullable error, EMChatMessage * _Nullable message)
     {
        if(error) {
            [weakSelf wrapperCallBack:result
                          channelName:aChannelName
                                error:error
                               object:nil];
        }else {
            [weakSelf wrapperCallBack:result
                          channelName:aChannelName
                                error:error
                               object:[message toJson]];
        }
        
    }];
}

- (void)downloadAndParseCombineMessage:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    EMChatMessage *msg = [EMChatMessage fromJson:param[@"message"]];
    
    [EMClient.sharedClient.chatManager downloadAndParseCombineMessage:msg
                                                           completion:^(NSArray<EMChatMessage *> * _Nullable messages, EMError * _Nullable error)
     {
        NSMutableArray *msgJsonAry = [NSMutableArray array];
        for (EMChatMessage *msg in messages) {
            [msgJsonAry addObject:[msg toJson]];
        }
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:error
                           object:msgJsonAry];
    }];
}

#pragma mark - 450
- (void)addRemoteAndLocalConversationsMark:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSArray *conversationIds = param[@"convIds"];
    EMMarkType mark = (EMMarkType)[param[@"mark"] integerValue];
    [EMClient.sharedClient.chatManager addConversationMark:conversationIds mark:mark completion:^(EMError * _Nullable aError) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:nil];
    }];
}


- (void)deleteRemoteAndLocalConversationsMark:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSArray *conversationIds = param[@"convIds"];
    EMMarkType mark = (EMMarkType)[param[@"mark"] integerValue];
    [EMClient.sharedClient.chatManager removeConversationMark:conversationIds mark:mark completion:^(EMError * _Nullable aError) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:nil];
    }];
}

- (void)fetchConversationsByOptions:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSString *cursor = [EMConversationFilter getCursor:param];
    BOOL isPinned = [EMConversationFilter getPinned:param];
    BOOL isMark = [EMConversationFilter hasMark:param];
    NSInteger pageSize = [EMConversationFilter pageSize:param];
    // 如果是获取pin消息，则调用获取pin message 相关api
    if(isPinned) {
        [ChatCompat5 getPinnedConversationsFromServerWithCursor:EMClient.sharedClient.chatManager cursor:cursor pageSize:pageSize completion:^(NSArray * _Nullable ret, EMError * _Nullable error) {
            [weakSelf wrapperCallBack:result
                          channelName:aChannelName
                                error:error
                               object:ret];
        }];
        return;
    }
    
    // 如果是mark相关，则调用mark相关api
    if(isMark){
        EMConversationFilter *filter = [EMConversationFilter fromJson: param];
        [ChatCompat5 getConversationsFromServerWithCursor:EMClient.sharedClient.chatManager cursor:cursor filter:filter completion:^(NSArray * _Nullable ret, EMError * _Nullable error) {
            [weakSelf wrapperCallBack:result
                          channelName:aChannelName
                                error:error
                               object:ret];
        }];
        return;
    }
    
    // 既不是pin，又不是mark，则直接分页获取
    [ChatCompat5 getConversationsFromServerWithCursor:EMClient.sharedClient.chatManager cursor:cursor pageSize:pageSize completion:^(NSArray * _Nullable ret, EMError * _Nullable error) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:error
                           object:ret];
    }];
    
}

- (void)deleteAllMessageAndConversation:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    BOOL clearServerData = [param[@"clearServerData"] boolValue];
    [EMClient.sharedClient.chatManager deleteAllMessagesAndConversations:clearServerData completion:^(EMError * _Nullable aError) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:nil];
    }];
}

- (void)pinMessage:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSString *msgId = param[@"msgId"];
    [EMClient.sharedClient.chatManager pinMessage:msgId
                                       completion:^(EMChatMessage * _Nullable message, EMError * _Nullable aError) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:nil];
    }];
}


- (void)unpinMessage:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSString *msgId = param[@"msgId"];
    [EMClient.sharedClient.chatManager unpinMessage:msgId
                                         completion:^(EMChatMessage * _Nullable message, EMError * _Nullable aError) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:nil];
    }];
}


- (void)fetchPinnedMessages:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSString *conversationId = param[@"convId"];
    [EMClient.sharedClient.chatManager getPinnedMessagesFromServer:conversationId completion:^(NSArray<EMChatMessage *> * _Nullable messages, EMError * _Nullable aError) {
        NSMutableArray *msgList = [NSMutableArray array];
        for (EMChatMessage *msg in messages) {
            [msgList addObject:[msg toJson]];
        }
        
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:msgList];
    }];
}




#pragma mark - EMChatManagerDelegate


- (void)conversationListDidUpdate:(NSArray *)aConversationList {
    [self.channel invokeMethod:ChatOnConversationUpdate
                     arguments:nil];
}

- (void)messagesDidReceive:(NSArray *)aMessages {
    NSMutableArray *msgList = [NSMutableArray array];
    for (EMChatMessage *msg in aMessages) {
        
        [msgList addObject:[msg toJson]];
    }
    [self.channel invokeMethod:ChatOnMessagesReceived
                     arguments:msgList];
}

- (void)onStreamMessagesReceived:(NSArray *)aMessages {
    NSMutableArray *msgList = [NSMutableArray array];
    for (EMChatMessage *msg in aMessages) {
        [msgList addObject:[msg toJson]];
    }
    [self.channel invokeMethod:ChatOnStreamMessagesReceived
                     arguments:msgList];
}

- (void)cmdMessagesDidReceive:(NSArray *)aCmdMessages {
    NSMutableArray *cmdMsgList = [NSMutableArray array];
    for (EMChatMessage *msg in aCmdMessages) {
        [cmdMsgList addObject:[msg toJson]];
    }
    
    [self.channel invokeMethod:ChatOnCmdMessagesReceived
                     arguments:cmdMsgList];
}

- (void)messagesDidRead:(NSArray *)aMessages {
    NSMutableArray *list = [NSMutableArray array];
    for (EMChatMessage *msg in aMessages) {
        NSDictionary *json = [msg toJson];
        [list addObject:json];
        [self.messageChannel invokeMethod:ChatOnMessageReadAck
                                arguments:json];
    }
    
    [self.channel invokeMethod:ChatOnMessagesRead arguments:list];
}

// 5.0 新回调（替代 4.x messagesDidRead）：收到已读回执列表
- (void)onMessageReadReceipts:(NSArray<EMMessageReadReceipt *> *)aReceipts {
    NSMutableArray *list = [NSMutableArray array];
    for (EMMessageReadReceipt *receipt in aReceipts) {
        EMChatMessage *msg = [EMClient.sharedClient.chatManager getMessageWithMessageId:receipt.messageId];
        if (msg) {
            NSDictionary *json = [msg toJson];
            [list addObject:json];
            [self.messageChannel invokeMethod:ChatOnMessageReadAck
                                    arguments:json];
        }
    }
    if (list.count > 0) {
        [self.channel invokeMethod:ChatOnMessagesRead arguments:list];
    }
}

- (void)groupMessageReadReceiptsHasChanged {
    // 5.0 原生 groupMessageReadReceiptsHasChanged → 协议 onReadAckForGroupMessageUpdated（Dart handler 已就绪）
    [self.channel invokeMethod:ChatOnReadAckForGroupMessageUpdated arguments:nil];
}

- (void)messagesDidDeliver:(NSArray *)aMessages {
    NSMutableArray *list = [NSMutableArray array];
    for (EMChatMessage *msg in aMessages) {
        NSDictionary *json = [msg toJson];
        [list addObject:json];
        [self.messageChannel invokeMethod:ChatOnMessageDeliveryAck
                                arguments:@{@"message":json}];
    }
    
    [self.channel invokeMethod:ChatOnMessagesDelivered
                     arguments:list];
}



- (void)groupMessageAckHasChanged {
    [self.channel invokeMethod:ChatOnReadAckForGroupMessageUpdated
                     arguments:nil];
}


- (void)messageReactionDidChange:(NSArray<EMMessageReactionChange *> *)changes {
    NSMutableArray *list = [NSMutableArray array];
    for (EMMessageReactionChange *change in changes) {
        [list addObject:[change toJson]];
    }
    
    [self.channel invokeMethod:ChatOnMessageReactionDidChange
                     arguments:list];
}


- (void)onMessageContentChanged:(EMChatMessage *)message operatorId:(NSString *)operatorId operationTime:(NSUInteger)operationTime {
    NSDictionary *dict = @{
        @"message": [message toJson],
        @"operator": operatorId,
        @"operationTime": @(operationTime)
    };
    
    [self.channel invokeMethod:onMessageContentChanged
                     arguments:dict];
}

- (void)onMessagePinChanged:(NSString *)messageId
             conversationId:(NSString *)conversationId
                  operation:(EMMessagePinOperation)pinOperation
                    pinInfo:(EMMessagePinInfo *)pinInfo{
    NSDictionary *dict = @{
        @"msgId": messageId,
        @"convId": conversationId,
        @"pinOperation": @(pinOperation),
        @"pinInfo": [pinInfo toJson]
    };
    
    [self.channel invokeMethod:onMessagePinChanged
                     arguments:dict];
}

- (void)messageAttachmentStatusDidChange:(EMChatMessage *)aMessage error:(EMError *)aError {
    
}


#pragma mark 460
- (void)messagesInfoDidRecall:(NSArray<EMRecallMessageInfo *> *)aRecallMessagesInfo {
    NSMutableArray *list = [NSMutableArray array];
    for (EMRecallMessageInfo *info in aRecallMessagesInfo) {
        [list addObject:[info toJson]];
    }
    
    [self.channel invokeMethod:onMessagesRecalledInfo
                     arguments:list];
}

#pragma mark 481
- (void)searchMsgsByOptions:(NSDictionary *)param
                channelName:(NSString *)aChannelName
                     result:(FlutterResult)result {
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
    [EMClient.sharedClient.chatManager searchMessagesWithTypes:searchTypes
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
}

#pragma mark 4.10

- (void)getMessageCount:(NSDictionary *)param
                channelName:(NSString *)aChannelName
                 result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.chatManager getMessageCountWithCompletion:^(NSInteger count, EMError * _Nullable aError) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:@(count)];
    }];
}

#pragma mark 4.15.2

- (void)loadConversationMessagesWithKeyword:(NSDictionary *)param
                                channelName:(NSString *)aChannelName
                                     result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSString *keyword = ([param[@"keyword"] isKindOfClass:[NSNull class]] || param[@"keyword"] == nil) ? nil : param[@"keyword"];
    long long timestamp = [param[@"timestamp"] longLongValue];
    NSString *sender = ([param[@"sender"] isKindOfClass:[NSNull class]] || param[@"sender"] == nil) ? nil : param[@"sender"];
    EMMessageSearchDirection direction = [EnumTools searchDirectionFromInt:[param[@"direction"] integerValue]];
    EMMessageSearchScope scope = (EMMessageSearchScope)[param[@"scope"] integerValue];

    [EMClient.sharedClient.chatManager loadConversationMessagesWithKeyword:keyword
                                                                timestamp:timestamp
                                                                 fromUser:sender
                                                          searchDirection:direction
                                                                    scope:scope
                                                               completion:^(NSDictionary<NSString *,NSArray<NSString *> *> * _Nullable aConversationMessages, EMError * _Nullable aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:aConversationMessages];
    }];
}

- (void)loadMessagesWithIds:(NSDictionary *)param
                channelName:(NSString *)aChannelName
                     result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSArray *messageIds = param[@"messageIds"];
    NSString *conversationId = param[@"conversationId"];

    [EMClient.sharedClient.chatManager getMessages:messageIds
                              withConversationId:conversationId
                                      completion:^(NSArray<EMChatMessage *> * _Nullable aMessages, EMError * _Nullable aError)
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

- (void)cleanConversationsMemoryCache:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    [EMClient.sharedClient.chatManager cleanConversationsMemoryCache];
    [self wrapperCallBack:result channelName:aChannelName error:nil object:@(YES)];
}

- (void)filterConversationsFromDB:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    // 5.0 同步方法
    NSArray<EMConversation *> *aConversations = [EMClient.sharedClient.chatManager filterConversationsFromDB:[param[@"onlyUnread"] boolValue]
                                                                                                        filter:^BOOL(EMConversation * _Nonnull conversation) {
        return YES;
    }];
    NSMutableArray *list = [NSMutableArray array];
    for (EMConversation *conv in aConversations) {
        [list addObject:[conv toJson]];
    }
    [self wrapperCallBack:result channelName:aChannelName error:nil object:list];
}

- (void)voiceMessageToText:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    EMChatMessage *msg = [EMChatMessage fromJson:param[@"message"]];
    [EMClient.sharedClient.chatManager voiceMessageToText:msg
                                               completion:^(NSString * _Nullable text, EMError * _Nullable error) {
        [weakSelf wrapperCallBack:result channelName:aChannelName error:error object:text];
    }];
}

- (void)voiceFileToText:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSString *filePath = param[@"filePath"];
    EMVoiceParam *voiceParam = [[EMVoiceParam alloc] init];
    [EMClient.sharedClient.chatManager voiceFileToText:filePath
                                            voiceParam:voiceParam
                                            completion:^(NSString * _Nullable text, EMError * _Nullable error) {
        [weakSelf wrapperCallBack:result channelName:aChannelName error:error object:text];
    }];
}



- (void)searchMessagesFromServer:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    EMMessageSearchOption *option = [[EMMessageSearchOption alloc] init];
    option.keywordList = param[@"keywords"] ?: @[];
    if (param[@"convId"]) option.conversationId = param[@"convId"];
    NSInteger pageSize = [param[@"pageSize"] intValue] > 0 ? [param[@"pageSize"] intValue] : 20;
    NSInteger pageNum = [param[@"pageNum"] intValue] > 0 ? [param[@"pageNum"] intValue] : 1;
    [EMClient.sharedClient.chatManager searchMessagesFromServerWithOption:option pageSize:pageSize pageNum:pageNum completion:^(EMPageResult<EMSearchServerMessageResult *> * _Nullable aResult, EMError * _Nullable aError) {
        NSMutableArray *list = [NSMutableArray array];
        for (EMSearchServerMessageResult *r in aResult.list) {
            [list addObject:@{
                @"messageId": r.messageId,
                @"from": r.from,
                @"timestamp": @(r.timestamp),
                @"body": [r.body toJson],
            }];
        }
        [weakSelf wrapperCallBack:result channelName:aChannelName error:aError object:list];
    }];
}


- (void)deleteConversations:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSArray *convIds = param[@"convIds"];
    BOOL deleteMessages = [param[@"deleteMessages"] boolValue];
    NSMutableArray *convs = [NSMutableArray array];
    for (NSString *cid in convIds) {
        EMConversation *conv = [EMClient.sharedClient.chatManager getConversationWithConvId:cid];
        if (conv) [convs addObject:conv];
    }
    [EMClient.sharedClient.chatManager deleteConversations:convs isDeleteMessages:deleteMessages completion:^(EMError * _Nullable aError) {
        [weakSelf wrapperCallBack:result channelName:aChannelName error:aError object:nil];
    }];
}

- (void)getGroupMessageReadReceipts:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    EMChatMessage *msg = [EMClient.sharedClient.chatManager getMessageWithMessageId:param[@"msgId"]];
    [EMClient.sharedClient.chatManager getGroupMessageReadReceipts:msg ? @[msg] : @[]
                                                       completion:^(NSArray<EMMessageReadReceipt *> * _Nullable aReceipts, EMError * _Nullable aError) {
        NSMutableArray *list = [NSMutableArray array];
        for (EMMessageReadReceipt *r in aReceipts) {
            [list addObject:@{@"msgId": r.messageId, @"readCount": @(r.readCount)}];
        }
        [weakSelf wrapperCallBack:result channelName:aChannelName error:aError object:list];
    }];
}

@end
