#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"

#import <im_flutter_sdk/ImFlutterSdkPlugin.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [GeneratedPluginRegistrant registerWithRegistry:self];
    // Override point for customization after application launch.
    
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge |
                                                                                         UIUserNotificationTypeSound |
                                                                                         UIUserNotificationTypeAlert)
                                                                             categories:nil];
    [application registerUserNotificationSettings:settings];
    
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    // register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [ImFlutterSdkPlugin setDeviceToken:deviceToken];
}

@end
