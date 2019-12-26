#import "ImFlutterSdkPlugin.h"

#import "EMChatManagerWrapper.h"
#import "EMClientWrapper.h"
#import "EMContactManagerWrapper.h"
#import "EMConversationWrapper.h"
#import "EMGroupManagerWrapper.h"
#import "EMChatroomManagerWrapper.h"


@implementation ImFlutterSdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
    EMClientWrapper *wrapper =  [[EMClientWrapper alloc] initWithChannelName:EMChannelName(@"em_client") registrar:registrar];
#pragma clang diagnostic pop
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
}

+(void)setDeviceToken:(NSData *)aDeviceToken {
    [EMClientWrapper setDeviceToken:aDeviceToken];
}
@end

