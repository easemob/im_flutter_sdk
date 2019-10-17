#import "ImFlutterSdkPlugin.h"

#import "EMChatManagerWrapper.h"
#import "EMClientWrapper.h"
#import "EMContactManagerWrapper.h"
#import "EMConversationWrapper.h"

#define EMChannelName(name) [NSString stringWithFormat:@"com.easemob.im/%@",name]

@implementation ImFlutterSdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    [[EMClientWrapper alloc] initWithChannelName:EMChannelName(@"em_client") registrar:registrar];
    [[EMChatManagerWrapper alloc] initWithChannelName:EMChannelName(@"em_chat_manager") registrar:registrar];
    [[EMContactManagerWrapper alloc] initWithChannelName:EMChannelName(@"em_contact_manager") registrar:registrar];
    [[EMConversationWrapper alloc] initWithChannelName:EMChannelName(@"em_conversation") registrar:registrar];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
}
@end

