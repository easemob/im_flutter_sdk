//
//  EMLocalNotificationManager.h
//  LocalNotification
//
//  Created by lixiaoming on 2021/8/24.
//

#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, EMNotificationState) {
     EMWillPresentNotification = 0,
     EMDidReceiveNotificationResponse
 };

/**
 *  \~chinese
 *  本地消息通知相关的代理协议。
 *
 *  \~english
 *  The callbacks of chat message notification.
 */
@protocol EMLocalNotificationDelegate <NSObject>
@optional
/**
 *  \~chinese
 *  当应用在前台收到推送通知，此方法会被调用
 *  通过completionHandle(UNNotificationPresentationOptions options)回调展示样式，必须回调
 *
 *
 *  \~english
 *
 *  This method will be called  when  application receives  notification in the foreground.
 *  By completionHandle (UNNotificationPresentationOptions options) callback display style, must be the callback.
 *
 */
- (void)emuserNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler;
/**
 *  \~chinese
 *  当用户打开应用推送通知时，此方法会被调用
 *  completionHandler必须回调
 *
 *  \~english
 *
 *  This method will be called when user open application notification.
 *  CompletionHandler must be called back
 *
 */
- (void)emuserNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler;
/**
 *  \~chinese
 *  在应用启动时被调用，以响应用户查看应用内通知设置的请求
 *
 *  \~english
 *
 *  The method will be called on the delegate when the application is launched in response to the user's request to view in-app notification settings
 *
 */
- (void)emuserNotificationCenter:(UNUserNotificationCenter *)center openSettingsForNotification:(UNNotification *)notification;

/**
 *  \~chinese
 *  获取推送消息  可只实现这个代理方法统一获取推送通知消息
 *
 *  \~english
 *
 *  Getting push messages can be implemented only with this delegate method to uniformly get notification messages
 *
 */
- (void)emGetNotificationMessage:(UNNotification*)notification state:(EMNotificationState)state;

/**
 *  \~chinese
 *   当应用收到环信推送透传消息时，此方法会被调用
 *
 *  \~english
 *
 *  This method is called when the application  received easemob push silent message
 *
 */
- (void)emDidRecivePushSilentMessage:(NSDictionary *)messageDic;

@end

/**
 *  \~chinese
 *  管理本地消息通知的类。
 *
 *  \~english
 *  A class that manages the chat message notification.
 */
@interface EMLocalNotificationManager : NSObject
/**
 *  \~chinese
 *  分配内存。
 *
 *  \~english
 *  Allocs. 
 */ 
 
+(instancetype _Nonnull ) alloc __attribute__((unavailable("call sharedManager instead")));
/**
 *  \~chinese
 *  创建实例。
 *
 *  \~english
 *  Create an instance. 
 */ 
 
+(instancetype _Nonnull ) new __attribute__((unavailable("call sharedManager instead")));
/**
 *  \~chinese
 *  复制实例。
 *
 *  \~english
 *  Copy an instance. 
 */ 
 
-(instancetype _Nonnull ) copy __attribute__((unavailable("call sharedManager instead")));
/**
 *  \~chinese
 *  复制并生成新的实例。
 *
 *  \~english
 *  Copy and generate a new instance. 
 */ 
 
-(instancetype _Nonnull ) mutableCopy __attribute__((unavailable("call sharedManager instead")));
/**
 *  \~chinese
 *  创建当前类的实例。
 *
 *  \~english
 *  Create an instance. 
 */
 
+  (instancetype _Nonnull )sharedManager;

/**
 *  \~chinese
 *  启用本地消息通知功能。
 *
 *  启用后该功能后，新消息会出现在通知栏中，方便用户即时阅读，提升用户体验。
 *
 *  \~english
 *
 *  Enables the chat message notification service.
 * 
 *  Once you enable this service, the new message is reported in the notification bar so that users can read them in time.
 *
 */
- (void)launchWithDelegate:(id<EMLocalNotificationDelegate>)aDelegate;

/**
 *  \~chinese
 *  如果用户在app层设置了UNUserNotificationCenterDelegate，需要在delegate实现中调用此方法
 *  如果不想sdk执行回调，则不传completionHandler
 *
 *  \~english
 *
 *  User should call this method in the implementation of  UNUserNotificationCenterDelegate if they have override UNUserNotificationCenterDelegate  in-app.
 *  If you don't want the SDK to execute the callback, don't pass the completionHandler
 *
 */
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler;
/**
 *  \~chinese 
 *  系统收到推送通知时，点击通知栏时触发的回调方法。
 *  如果用户在 app 层设置了 UNUserNotificationCenterDelegate，需要在 delegate 实现中调用此方法。
 *
 *
 *  \~english
 *  When the system receives a push notification, the callback method is triggered when the notification bar is clicked.
 *  User should call this method in the implementation of UNUserNotificationCenterDelegate if they have override UNUserNotificationCenterDelegate in-app.
 *
 */
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler;
@end

NS_ASSUME_NONNULL_END
