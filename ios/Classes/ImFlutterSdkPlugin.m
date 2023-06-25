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
    EMClientWrapper *wrapper = [[EMClientWrapper alloc] initWithChannelName:EMChannelName(@"chat_client") registrar:registrar];
    [registrar publish:wrapper];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[EMClient sharedClient] applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[EMClient sharedClient] applicationWillEnterForeground:application];
}


@end

