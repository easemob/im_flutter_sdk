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

static EMClientWrapper *wrapper;

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    wrapper = [[EMClientWrapper alloc] initWithChannelName:EMChannelName(@"chat_client") registrar:registrar];
}

+ (void)clearWrapper{
    wrapper = nil;
}

+ (void)sendDataToFlutter:(NSDictionary *)aData {
    if (wrapper) {
        [wrapper sendDataToFlutter:aData];
    }
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
}

@end

