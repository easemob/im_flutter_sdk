//
//  EMConversationWrapper.m
//  
//
//  Created by 杜洁鹏 on 2019/10/8.
//

#import "EMConversationWrapper.h"
#import "EMSDKMethod.h"

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
    if (![call.arguments isKindOfClass:[NSDictionary class]]) {
        NSLog(@"wrong type");
        return;
    }
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
- (EMConversation *)getConversation {
    return [EMClient.sharedClient.chatManager getConversation:self.conversationId
                                                         type:self.type
                                             createIfNotExist:YES];
}

#pragma mark - Actions
- (void)getUnreadMsgCount:(NSDictionary *)param result:(FlutterResult)result {
    [[self getConversation] unreadMessagesCount];
}

- (void)markAllMessagesAsRead:(NSDictionary *)param result:(FlutterResult)result {
    
}

- (void)loadMoreMsgFromDB:(NSDictionary *)param result:(FlutterResult)result {
    
}

- (void)searchConversationMsgFromDB:(NSDictionary *)param result:(FlutterResult)result {
    
}

- (void)searchConversationMsgFromDBByType:(NSDictionary *)param result:(FlutterResult)result {
    
}

- (void)loadMessages:(NSDictionary *)param result:(FlutterResult)result {
    
}

- (void)markMessageAsRead:(NSDictionary *)param result:(FlutterResult)result {
    
}

- (void)removeMessage:(NSDictionary *)param result:(FlutterResult)result {
    
}

- (void)getLastMessage:(NSDictionary *)param result:(FlutterResult)result {
    
}

- (void)getLatestMessageFromOthers:(NSDictionary *)param result:(FlutterResult)result {
    
}

- (void)clear:(NSDictionary *)param result:(FlutterResult)result {
    
}

- (void)clearAllMessages:(NSDictionary *)param result:(FlutterResult)result {
    
}

- (void)insertMessage:(NSDictionary *)param result:(FlutterResult)result {
    
}

- (void)appendMessage:(NSDictionary *)param result:(FlutterResult)result {
    
}

- (void)updateConversationMessage:(NSDictionary *)param result:(FlutterResult)result {
    
}

- (void)getMessageAttachmentPath:(NSDictionary *)param result:(FlutterResult)result {
    
}


@end
