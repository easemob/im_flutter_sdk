#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
<<<<<<< HEAD
=======
#import <Hyphenate/Hyphenate.h>
>>>>>>> 增加:获取好友列表,添加好友(目前默认自动同意好友请求),删除好友，点击好友进入聊天页面
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
    [ImFlutterSdkPlugin setDeivceToken:deviceToken];
}

@end
