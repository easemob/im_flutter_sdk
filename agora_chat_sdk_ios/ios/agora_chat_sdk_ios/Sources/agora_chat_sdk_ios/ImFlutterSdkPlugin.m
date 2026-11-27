#import "ImFlutterSdkPlugin.h"

#import "ChatManagerWrapper.h"
#import "ClientWrapper.h"
#import "ContactManagerWrapper.h"
#import "ConversationWrapper.h"
#import "GroupManagerWrapper.h"
#import "ChatroomManagerWrapper.h"
#import "ChatHeaders.h"
#import "OSLogForwarder.h"
#import <UserNotifications/UserNotifications.h>


@implementation ImFlutterSdkPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    // Install before any SDK init so the init-window logs are captured too.
    [OSLogForwarder install];
    ClientWrapper *wrapper = [[ClientWrapper alloc] initWithChannelName:EMChannelName(@"chat_client") registrar:registrar];
    [registrar publish:wrapper];
}

@end
