//
//  EMChatManagerWrapper.m
//  
//
//  Created by 杜洁鹏 on 2019/10/8.
//

#import "EMChatManagerWrapper.h"
#import "EMSDKMethod.h"
#import <Hyphenate/Hyphenate.h>
#import "EMHelper.h"

@interface EMChatManagerWrapper () <EMChatManagerDelegate>
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
    if (![call.arguments isKindOfClass:[NSDictionary class]]) {
        NSLog(@"wrong type");
        return;
    }
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
        [self markAllChatMsgAsRead:call.arguments result:result];
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
    } else if ([EMMethodKeySetMessageListened isEqualToString:call.method]) {
        [self setMessageListened:call.arguments result:result];
    } else if ([EMMethodKeySetVoiceMessageListened isEqualToString:call.method]) {
        [self setVoiceMessageListened:call.arguments result:result];
    } else if ([EMMethodKeyUpdateParticipant isEqualToString:call.method]) {
        [self updateParticipant:call.arguments result:result];
    } else if ([EMMethodKeyFetchHistoryMessages isEqualToString:call.method]) {
        [self fetchHistoryMessages:call.arguments result:result];
    } else if ([EMMethodKeySearchChatMsgFromDB isEqualToString:call.method]) {
        [self SearchChatMsgFromDB:call.arguments result:result];
    } else if ([EMMethodKeyGetCursor isEqualToString:call.method]) {
        [self GetCursor:call.arguments result:result];
    } else if ([EMMethodKeyOnMessageReceived isEqualToString:call.method]) {
        [self onMessageRecalled:call.arguments result:result];
    } else if ([EMMethodKeyOnCmdMessageReceived isEqualToString:call.method]) {
        [self onCmdMessageReceived:call.arguments result:result];
    } else if ([EMMethodKeyOnMessageRead isEqualToString:call.method]) {
        [self onMessageRead:call.arguments result:result];
    } else if ([EMMethodKeyOnMessageDelivered isEqualToString:call.method]) {
        [self onCmdMessageReceived:call.arguments result:result];
    } else if ([EMMethodKeyOnMessageRecalled isEqualToString:call.method]) {
        [self onCmdMessageReceived:call.arguments result:result];
    } else if ([EMMethodKeyOnMessageChanged isEqualToString:call.method]) {
        [self onMessageChanged:call.arguments result:result];
    } else if ([EMMethodKeyOnConversationUpdate isEqualToString:call.method]) {
        [self onConversationUpdate:call.arguments result:result];
    } else {
        [super handleMethodCall:call result:result];
    }
}

#pragma mark - Actions

- (void)sendMessage:(NSDictionary *)param result:(FlutterResult)result {
    EMMessage *msg = [EMHelper dictionaryToMessage:param];
    [EMClient.sharedClient.chatManager sendMessage:msg
                                          progress:^(int progress)
    {
        
    } completion:^(EMMessage *message, EMError *error)
    {
        [self wrapperCallBack:result
                        error:error
                     userInfo:[EMHelper messageToDictionary:message]];
    }];
}

- (void)ackMessageRead:(NSDictionary *)param result:(FlutterResult)result {
    EMClient.sharedClient.chatManager sendMessageReadAck:<#(EMMessage *)#> completion:<#^(EMMessage *aMessage, EMError *aError)aCompletionBlock#>
}

- (void)recallMessage:(NSDictionary *)param result:(FlutterResult)result {
    
}

- (void)getMessage:(NSDictionary *)param result:(FlutterResult)result {
    
}

- (void)getConversation:(NSDictionary *)param result:(FlutterResult)result {
    
}

- (void)markAllChatMsgAsRead:(NSDictionary *)param result:(FlutterResult)result {
    
}

- (void)getUnreadMessageCount:(NSDictionary *)param result:(FlutterResult)result {
    
}

- (void)saveMessage:(NSDictionary *)param result:(FlutterResult)result {
    
}

- (void)updateChatMessage:(NSDictionary *)param result:(FlutterResult)result {
    
}

- (void)downloadAttachment:(NSDictionary *)param result:(FlutterResult)result {
    
}

- (void)downloadThumbnail:(NSDictionary *)param result:(FlutterResult)result {
    
}

- (void)importMessages:(NSDictionary *)param result:(FlutterResult)result {
    
}

- (void)getConversationsByType:(NSDictionary *)param result:(FlutterResult)result {
    
}

- (void)downloadFile:(NSDictionary *)param result:(FlutterResult)result {
    
}

- (void)getAllConversations:(NSDictionary *)param result:(FlutterResult)result {
    
}

- (void)loadAllConversations:(NSDictionary *)param result:(FlutterResult)result {
    
}

- (void)deleteConversation:(NSDictionary *)param result:(FlutterResult)result {
    
}

// ??
- (void)setMessageListened:(NSDictionary *)param result:(FlutterResult)result {
    
}

// ??
- (void)setVoiceMessageListened:(NSDictionary *)param result:(FlutterResult)result {
    
}

- (void)updateParticipant:(NSDictionary *)param result:(FlutterResult)result {
    
}

- (void)fetchHistoryMessages:(NSDictionary *)param result:(FlutterResult)result {
    
}

- (void)SearchChatMsgFromDB:(NSDictionary *)param result:(FlutterResult)result {
    
}

- (void)GetCursor:(NSDictionary *)param result:(FlutterResult)result {
    
}

// ??
- (void)OnMessageReceived:(NSDictionary *)param result:(FlutterResult)result {
    
}

// ??
- (void)onCmdMessageReceived:(NSDictionary *)param result:(FlutterResult)result {
    
}

// ??
- (void)onMessageRead:(NSDictionary *)param result:(FlutterResult)result {
    
}

// ??
- (void)onMessageDelivered:(NSDictionary *)param result:(FlutterResult)result {
    
}

// ??
- (void)onMessageRecalled:(NSDictionary *)param result:(FlutterResult)result {
    
}

// ??
- (void)onMessageChanged:(NSDictionary *)param result:(FlutterResult)result {

}

// ??
- (void)onConversationUpdate:(NSDictionary *)param result:(FlutterResult)result {

}


#pragma mark - EMChatManagerDelegate

- (void)conversationListDidUpdate:(NSArray *)aConversationList {
    
}

- (void)messagesDidReceive:(NSArray *)aMessages {
    
}

- (void)cmdMessagesDidReceive:(NSArray *)aCmdMessages {
    
}

- (void)messagesDidRead:(NSArray *)aMessages {
    
}

- (void)messagesDidDeliver:(NSArray *)aMessages {
    
}

- (void)messagesDidRecall:(NSArray *)aMessages {
    
}

- (void)messageStatusDidChange:(EMMessage *)aMessage
                         error:(EMError *)aError {
    
}

- (void)messageAttachmentStatusDidChange:(EMMessage *)aMessage
                                   error:(EMError *)aError {
    
}


@end
