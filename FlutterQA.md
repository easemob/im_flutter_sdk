iOS如何绑定deviceToken?

```objectivec

#import "AppDelegate.h"
// 引入环信SDK
#import <Hyphenate/Hyphenate.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    // ...
    
    
    // // 获取UNUserNotificationCenter并申请[badge, alert, sound]权限。
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:
     UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // 注册远程推送
                [application registerForRemoteNotifications];
            });
        }
    }];
    
    
    return YES;
}

// 收到系统deviceToken获取成功回调
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    // 将deviceToken传给环信SDK
    [EMClient.sharedClient registerForRemoteNotificationsWithDeviceToken:deviceToken completion:nil];
}



@end

```

```swift

import UIKit
import Flutter
// 引入环信SDK
import HyphenateChat

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      GeneratedPluginRegistrant.register(with: self);
      
      // 获取UNUserNotificationCenter并申请[badge, alert, sound]权限。
      let center = UNUserNotificationCenter.current();
      center.requestAuthorization(options: [.badge, .alert, .sound]) { granted, error in
          if(granted){
              DispatchQueue.main.async {
                  // 注册远程推送
                  application.registerForRemoteNotifications();
              }
          }
      }
      
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    // 收到系统deviceToken获取成功回调
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // 将deviceToken传给环信SDK
        EMClient.share.registerForRemoteNotifications(withDeviceToken: deviceToken, completion: nil)
    }
}




```
