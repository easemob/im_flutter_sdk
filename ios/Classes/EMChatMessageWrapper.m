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
    
    if ([ChatGetReaction isEqualToString:call.method]) {
        
    }else {
        [super handleMethodCall:call result:result];
    }
}


- (void)getReaction:(NSDictionary *)param
        channelName:(NSString *)aChannelName
             result:(FlutterResult)result {
    NSString *msgId = param[@"msgId"];
    EMChatMessage *msg = [self getMessageWithId:msgId];
    // TODO: getReaction
}



- (EMChatMessage *)getMessageWithId:(NSString *)aMessageId {
    return [EMClient.sharedClient.chatManager getMessageWithMessageId:aMessageId];
}
@end
