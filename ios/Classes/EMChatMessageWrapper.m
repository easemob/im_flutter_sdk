//
//  EMChatMessageWrapper.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2022/5/5.
//

#import <Flutter/Flutter.h>
#import <HyphenateChat/HyphenateChat.h>
#import "EMChatMessageWrapper.h"
#import "EMSDKMethod.h"

#import "EMMessageReaction+Helper.h"
#import "EMChatThread+Helper.h"


@implementation EMChatMessageWrapper
- (instancetype)initWithChannelName:(NSString *)aChannelName
                          registrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    if(self = [super initWithChannelName:aChannelName
                               registrar:registrar]) {
    }
    return self;
}


#pragma mark - FlutterPlugin

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    
    if([ChatGetReactionList isEqualToString:call.method]){
        [self getReactionList:call.arguments channelName:call.method result:result];
    } else if([ChatGroupAckCount isEqualToString:call.method]) {
        [self getGroupAckCount:call.arguments channelName:call.method result:result];
    } else if([ChatThread isEqualToString:call.method]) {
        [self getChatThread:call.arguments channelName:call.method result:result];
    }
    else {
        [super handleMethodCall:call result:result];
    }
}


- (void)getReaction:(NSDictionary *)param
        channelName:(NSString *)aChannelName
             result:(FlutterResult)result {
    NSString *msgId = param[@"msgId"];
    NSString *reaction = param[@"reaction"];
    EMChatMessage *msg = [self getMessageWithId:msgId];
    EMMessageReaction *msgReaction = [msg getReaction:reaction];
    [self wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:[msgReaction toJson]];
}

- (void)getReactionList:(NSDictionary *)param
        channelName:(NSString *)aChannelName
                 result:(FlutterResult)result {
    NSString *msgId = param[@"msgId"];
    EMChatMessage *msg = [self getMessageWithId:msgId];
    NSMutableArray *list = [NSMutableArray array];
    for (EMMessageReaction *reaction in msg.reactionList) {
        [list addObject:[reaction toJson]];
    }
    
    [self wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                   object:list.count > 0 ? list : nil];
}

- (void)getGroupAckCount:(NSDictionary *)param
        channelName:(NSString *)aChannelName
                 result:(FlutterResult)result {
    NSString *msgId = param[@"msgId"];
    EMChatMessage *msg = [self getMessageWithId:msgId];
    [self wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:@(msg.groupAckCount)];
    
}

- (void)getChatThread:(NSDictionary *)param
          channelName:(NSString *)aChannelName
               result:(FlutterResult)result {
    NSString *msgId = param[@"msgId"];
    EMChatMessage *msg = [self getMessageWithId:msgId];
    [self wrapperCallBack:result
              channelName:aChannelName
                    error:nil
                   object:[msg.chatThread toJson]] ;
}

- (EMChatMessage *)getMessageWithId:(NSString *)aMessageId {
    return [EMClient.sharedClient.chatManager getMessageWithMessageId:aMessageId];
}

@end
