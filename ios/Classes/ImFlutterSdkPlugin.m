#import "ImFlutterSdkPlugin.h"

#import "EMChatManagerWrapper.h"
#import "EMClientWrapper.h"
#import "EMContactManagerWrapper.h"
#import "EMConversationWrapper.h"
#import "EMGroupManagerWrapper.h"
#import "EMChatroomManagerWrapper.h"
#import <HyphenateChat/HyphenateChat.h>
#import <UserNotifications/UserNotifications.h>


@implementation ImFlutterSdkPlugin


+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    [[EMClientWrapper alloc] initWithChannelName:EMChannelName(@"chat_client") registrar:registrar];
}


- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
}

@end

