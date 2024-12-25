#import "ImFlutterSdkPlugin.h"

#import "ChatManagerWrapper.h"
#import "ClientWrapper.h"
#import "ContactManagerWrapper.h"
#import "ConversationWrapper.h"
#import "GroupManagerWrapper.h"
#import "ChatroomManagerWrapper.h"
#import "ChatHeaders.h"
#import <UserNotifications/UserNotifications.h>


@implementation ImFlutterSdkPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    ClientWrapper *wrapper = [[ClientWrapper alloc] initWithChannelName:EMChannelName(@"chat_client") registrar:registrar];
    [registrar publish:wrapper];
}

@end

@implementation FlutterAppDelegate (Category)
- (void)applicationDidEnterBackground:(UIApplication *)application {
    [EMClient.sharedClient applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [EMClient.sharedClient applicationWillEnterForeground:application];
}
@end
