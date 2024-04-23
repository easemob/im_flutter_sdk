/**
 *  @header EMClient.h
 *  @abstract SDK Client
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>

#import "EMClientDelegate.h"
#import "EMError.h"
#import "EMMultiDevicesDelegate.h"
#import "EMOptions.h"
#import "EMPushOptions.h"

#import "IEMChatManager.h"
#import "IEMChatroomManager.h"
#import "IEMContactManager.h"
#import "IEMGroupManager.h"
#import "IEMThreadManager.h"
#import "IEMPushManager.h"
#import "IEMUserInfoManager.h"
#import "IEMTranslateManager.h"
#import "IEMPresenceManager.h"
#import "IEMStatisticsManager.h"

#import "EMDeviceConfig.h"
#import "EMLocalNotificationManager.h"
#import "EMTranslationResult.h"
#import "EMLogDelegate.h"

/**
 *  \~chinese
 *  检查类型的枚举。
 *  开发者可以根据需求来调用 `serviceCheckWithUsername` 方法进行检查。该方法为异步方法，如果出现报错，可以确认错误信息。
 *
 *  \~english
 *  This enum lists the server diagnostic tests which are run for the current user when you call EMClient::serviceCheckWithUsername. This is an asynchronous method. If there is an error, check the error code to know the error information.
 */
typedef NS_ENUM(NSInteger, EMServerCheckType) {
  EMServerCheckAccountValidation = 0, /** \~chinese 账号检查类型，账号是否有效的检查。  \~english The check of the account validity. */
  EMServerCheckGetDNSListFromServer,  /** \~chinese 获取服务列表检查类型  \~english The check of getting DNS from the server. */
  EMServerCheckGetTokenFromServer,    /** \~chinese 获取 token 检查类型  \~english The check of getting the token from the server. */
  EMServerCheckDoLogin,               /** \~chinese 登录检查类型  \~english The check of the login mode. */
  EMServerCheckDoLogout,              /** \~chinese 登出检查类型  \~english The check of the logout mode. */
};

/**
 * \~chinese
 *  该类为 SDK 的入口类，负责登录登出及连接管理等，由此可以获得其他模块的入口，例如：群组模块。
 *  [EMClient sharedClient].groupManager;
 *
 * \~english
 *  The EMClient, which is the entry point of the Chat SDK. You can log in, log out, and access other functionalities such as group and chatroom with this class.
 *  [EMClient sharedClient].groupManager;
 */
@interface EMClient : NSObject
{
  EMPushOptions *_pushOptions;
}

/**
 *  \~chinese
 *  SDK 版本号。
 *
 *  \~english
 *  The SDK version number.
 */
@property(nonatomic, strong, readonly) NSString * _Nonnull version;

/**
 *  \~chinese
 *  当前登录账号。
 *
 *  \~english
 *  The ID of the user currently logged into your chat app.
 */
@property(nonatomic, strong, readonly) NSString * _Nullable currentUsername;

/**
 *  \~chinese
 *  SDK 的设置选项。
 *
 *  \~english
 *  The SDK setting options. For example, whether to use https by default.
 */
@property(nonatomic, strong, readonly) EMOptions * _Nonnull options;

/**
 *  \~chinese
 *  聊天模块。
 *
 *  \~english
 *  The chat manager module.
 */
@property(nonatomic, strong, readonly) id<IEMChatManager> _Nullable chatManager;

/**
 *  \~chinese
 *  好友模块。
 *
 *  \~english
 *  The contact manager module.
 */
@property(nonatomic, strong, readonly) id<IEMContactManager> _Nullable contactManager;

/**
 *  \~chinese
 *  群组模块。
 *
 *  \~english
 *  The group manager module.
 */
@property(nonatomic, strong, readonly) id<IEMGroupManager> _Nullable groupManager;

/**
 *  \~chinese
 *  聊天室模块。
 *  thread模块
 *
 *  \~english
 *  Thread Management
 */
@property (nonatomic, strong, readonly) id<IEMThreadManager> _Nullable threadManager;

/*!
 *  \~chinese
 *  聊天室模块
 *
 *  \~english
 *  The chat room manager module.
 */
@property(nonatomic, strong, readonly) id<IEMChatroomManager> _Nullable roomManager;

/**
 *  \~chinese
 *  推送模块。
 *
 *  \~english
 *   The push manager module.
 */
@property (nonatomic, strong, readonly) id<IEMPushManager> _Nullable pushManager;

/**
 *  \~chinese
 *  是否让用户自动使用上次登录的账号登录。如果因密码错误或账号异常等原因登录失败，则该参数会被重置为 NO；如果你想使用自动登录，则需要重新将该参数设为 YES。
 *
 *  \~english
 *  Whether to let a user automatically log in to the chat server with the username used in the previous session. If the login fails, for example, because of a wrong password or the username deactivated, the isAutoLogin parameter is reset to NO, and you need to set it back to YES to allow automatic login.
 *
 */
@property(nonatomic, readonly) BOOL isAutoLogin;

/**
 *  \~chinese
 *  用户是否已登录。
 *
 *  \~english
 *  Returns `true` if the current user is logged in.
 */
@property(nonatomic, readonly) BOOL isLoggedIn;

/**
 *  \~chinese
 *  SDK 是否连上聊天服务器。
 *
 *  \~english
 *  Whether the SDK is connected to the chat server.
 */
@property(nonatomic, readonly) BOOL isConnected;

/**
 *  \~chinese
 *  当前用户访问聊天服务器使用的 token。用户第一次登陆的时候需要用用户 ID 和密码登陆，成功时返回 token，以后即可用 token 登陆。
 *
 *  \~english
 *  The token for accessing the current chat.
 */
@property(nonatomic, readonly) NSString * _Nullable accessUserToken;

/**
 *  \~chinese
 *  用户属性模块。
 *
 *  \~english
 *  The user attributes manager module.
 */
@property(nonatomic, strong, readonly) id<IEMUserInfoManager> _Nullable userInfoManager;

/**
 *  \~chinese
 *  在线状态管理模块。
 *
 *  \~english
 *  The presence  manager module.
 */
@property (nonatomic, strong, readonly) id<IEMPresenceManager> _Nullable presenceManager;

/**
 *  \~chinese
 *  消息流量管理模块。
 *
 *  \~english
 *  The message statistics  manager module.
 */
@property (nonatomic, strong, readonly) id<IEMStatisticsManager> _Nullable statisticsManager;

/**
 *  \~chinese
 *  Client 类是 chat 的入口，在调用任何其他方法前，需要先调用该方法创建一个 Client 实例。
 *
 *  \~english
 *  Creates a Client instance. The Client class is the entry to the Chat SDK. You need to call this method to create a Client instance before calling any other method.
 */
+ (instancetype _Nonnull )sharedClient;


/**
 *  \~chinese
 *  SDK 版本号。
 *
 *  \~english
 *  The SDK version number.
 */
- (NSString *)version;

#pragma mark - Delegate

/**
 *  \~chinese
 *  添加回调代理。
 *
 *  @param aDelegate  要添加的代理。
 *  @param aQueue     执行代理方法的队列。
 *
 *  \~english
 *  Add the EMClientDelegate, so when the delegate event occurs, the delegate will call the methods automatically in <EMClientDelegate>.
 *
 *  @param aDelegate  The delegate that you want to add: ClientDelegate.
 *  @param aQueue     (optional) The queue of calling delegate methods. If you want to run the app on the main thread, set this parameter as nil. */
- (void)addDelegate:(id<EMClientDelegate>_Nonnull)aDelegate
      delegateQueue:(dispatch_queue_t _Nullable )aQueue;

/**
 *  \~chinese
 *  移除回调代理。
 *
 *  @param aDelegate  要移除的代理。
 *
 *  \~english
 *  Remove the delegate.
 *
 *  @param aDelegate  The delegate that you want to remove.
 */
- (void)removeDelegate:(id _Nonnull )aDelegate;

/**
 *  \~chinese
 *  添加多设备回调代理。
 *
 *  @param aDelegate  要添加的代理。
 *  @param aQueue     执行代理方法的队列。
 *
 *  \~english
 *  Add the multi-device delegate.
 *
 *  @param aDelegate  The delegate that you want to add: MultiDevicesDelegate.
 *  @param aQueue     The queue of calling delegate methods.
 */
- (void)addMultiDevicesDelegate:(id<EMMultiDevicesDelegate>_Nonnull)aDelegate
                  delegateQueue:(dispatch_queue_t _Nullable )aQueue NS_SWIFT_NAME(addMultiDevices(delegate:queue:));

/**
 *  \~chinese
 *  移除多设备回调代理。
 *
 *  @param aDelegate  要移除的代理。
 *
 *  \~english
 *  Remove the multi-device delegate.
 *
 *  @param aDelegate  The multi-device delegate that you want to delete.
 */
- (void)removeMultiDevicesDelegate:(id<EMMultiDevicesDelegate>_Nonnull)aDelegate;

#pragma mark - Initialize SDK

/**
 *  \~chinese
 *  初始化 SDK。
 *
 *  @param aOptions  SDK 配置项。
 *
 *  @result EMError 错误信息，包含调用失败的原因。
 *
 *  \~english
 *  Initialize the SDK.
 *
 *  @param aOptions   The SDK setting options: Options..
 *
 *  @Result EMError   A description of the issue that caused this call to fail.
 */
- (EMError *_Nullable)initializeSDKWithOptions:(EMOptions * _Nonnull )aOptions;

#pragma mark - Change AppKey

/**
 *  \~chinese
 *  修改 app key，注意只有在未登录状态才能修改 app key。修改 app key 是为了方便你切换其他 app key，切换后可以使用切换后的 app key 测试，除了登出外，没有其他的限制。
 *
 *  @param aAppkey   The app key.
 *
 *  @result EMError  错误信息，包含调用失败的原因。
 *
 *  \~english
 *  Update the unique identifier used to access server.
 *
 *  You retrieve the new app key from server. As this key controls all access to server for your app, you can only update the key when the current user is logged out.
 *
 *  @param aAppkey  The app key.
 *
 *  @Result A description of the issue that caused this call to fail.
 */
- (EMError *_Nullable)changeAppkey:(NSString * _Nonnull)aAppkey;

#pragma mark - User Registeration

/**
 *  \~chinese
 *  注册用户。不推荐使用，建议后台通过 REST 注册。
 *
 *  同步方法，会阻塞当前线程.
 *
 *  @param aUsername  用户名，长度不超过 64 个字符。请确保你对该参数设值。支持的字符包括英文字母（a-z），数字（0-9），下划线（_），英文横线（-），英文句号（.）。该参数不区分大小写，大写字母会被自动转为小写字母。如果使用正则表达式设置该参数，则可以将表达式写为：^[a-zA-Z0-9_-]+$。
 *  @param aPassword  密码，长度不超过 64 个字符。请确保你对该参数设值。
 *
 *  @result EMError 错误信息，包含调用失败的原因。
 *
 *  \~english
 *  Register a new user with your chat network.
 *
 *  This method is not recommended and you are advised to call the Restful API.
 *
 *  After you call `initializeSDKWithOptions` and register your app in console, the app has access to all the features registered inside your chat network. You add and remove users inside your chat network; depending on how you implement your app, you control the people each user can see inside your network.
 *
 *  This is a synchronous method and blocks the current thread. To ensure registration reliability, we recommend using the REST API to register new chat users.
 *
 *  @param aUsername  The username. The maximum length is 64 characters. Ensure that you set this parameter. Supported characters include the 26 English letters (a-z), the ten numbers (0-9), the underscore (_), the hyphen (-), and the English period (.). This parameter is case insensitive, and upper-case letters are automatically changed to low-case ones. If you want to set this parameter as a regular expression, set it as ^[a-zA-Z0-9_-]+$.
 *  @param aPassword   The password. The maximum length is 64 characters. Ensure that you set this parameter.
 *
 *  @result A description of the issue that caused this call to fail.
 */
- (EMError *_Nullable)registerWithUsername:(NSString * _Nonnull)aUsername
                                  password:(NSString * _Nonnull)aPassword;

/**
 *  \~chinese
 *  注册用户。
 *
 *  不推荐使用，建议后台通过 REST 注册。
 *
 *  异步方法。
 *
 *  @param aUsername  用户名，长度不超过 64 个字符。请确保你对该参数设值。支持的字符包括英文字母（a-z），数字（0-9），下划线（_），英文横线（-），英文句号（.）。该参数不区分大小写，大写字母会被自动转为小写字母。如果使用正则表达式设置该参数，则可以将表达式写为：^[a-zA-Z0-9_-]+$。
 *  @param aPassword  密码，长度不超过 64 个字符。请确保你对该参数设值。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Register a new user with your chat network.
 *
 *  This is an asynchronous method.
 *
 *  This method is not recommended and you are advised to call the Restful API.
 *
 *  After you call `initializeSDKWithOptions` and register your app in console, the app has access to all the features registered inside your chat network. You add and remove users inside your chat network; depending on how you implement your app, you control the people each user can see inside your network.
 *
 *  To ensure registration reliability, we recommend using the REST API to register new chat users.
 *
 *  @param aUsername        The username. The maximum length is 64 characters. Ensure that you set this parameter. Supported characters include the 26 English letters (a-z), the ten numbers (0-9), the underscore (_), the hyphen (-), and the English period (.). This parameter is case insensitive, and upper-case letters are automatically changed to low-case ones. If you want to set this parameter as a regular expression, set it as ^[a-zA-Z0-9_-]+$.
 *  @param aPassword        The password. The maximum length is 64 characters. Ensure that you set this parameter.
 *  @param aCompletionBlock The completion block, which contains the username and the error message if the method fails.
 *
 */
- (void)registerWithUsername:(NSString *_Nonnull)aUsername
                    password:(NSString *_Nonnull)aPassword
                  completion:(void (^_Nullable)(NSString * _Nonnull aUsername, EMError * _Nullable aError))aCompletionBlock;

#pragma mark - Login

/**
 *  \~chinese
 *  从服务器获取 token。
 *
 *  异步方法。
 *
 *  @param aUsername        用户名。
 *  @param aPassword        密码。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Fetches the token from the server.
 *
 *  This is an asynchronous method.
 *
 *  @param aUsername     The username.
 *  @param aPassword     The password.
 *  @param aCompletionBlock The completion block, which contains the token and the error message if the method fails.
 *
 */
- (void)fetchTokenWithUsername:(NSString *_Nonnull)aUsername
                      password:(NSString *_Nonnull)aPassword
                    completion:(void (^_Nullable)(NSString * _Nullable aToken, EMError * _Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  用户使用密码登录服务器。
 *
 *  推荐使用token登录聊天服务器
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param aUsername  用户名，长度不超过 64 个字符。请确保你对该参数设值。支持的字符包括英文字母（a-z），数字（0-9），下划线（_），英文横线（-），英文句号（.）。该参数不区分大小写，大写字母会被自动转为小写字母。如果使用正则表达式设置该参数，则可以将表达式写为：^[a-zA-Z0-9_-]+$。
 *  @param aPassword  密码，长度不超过 64 个字符。请确保你对该参数设值。
 *
 *  @result EMError 错误信息，包含调用失败的原因。
 *
 *  \~english
 *  A user logs in to the chat server with a password.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  It is recommended that you log in to the chat service with a token.
 *
 *  @param aUsername  The username. The maximum length is 64 characters. Ensure that you set this parameter. Supported characters include the 26 English letters (a-z), the ten numbers (0-9), the underscore (_), the hyphen (-), and the English period (.). This parameter is case insensitive, and upper-case letters are automatically changed to low-case ones. If you want to set this parameter as a regular expression, set it as ^[a-zA-Z0-9_-]+$.
 *  @param aPassword  The password. The maximum length is 64 characters. Ensure that you set this parameter.
 *
 *  @result Returns nil on success, and the description of the issue that cause the call to fail.
 */
- (EMError *_Nullable)loginWithUsername:(NSString *_Nonnull)aUsername
                               password:(NSString *_Nonnull)aPassword;

/**
 *  \~chinese
 *  用户使用密码登录聊天服务器。
 *
 *  异步方法。
 *
 *  推荐使用token登录聊天服务器
 *
 *  @param aUsername        用户名，长度不超过 64 个字符。请确保你对该参数设值。支持的字符包括英文字母（a-z），数字（0-9），下划线（_），英文横线（-），英文句号（.）。该参数不区分大小写，大写字母会被自动转为小写字母。如果使用正则表达式设置该参数，则可以将表达式写为：^[a-zA-Z0-9_-]+$。
 *  @param aPassword        密码，长度不超过 64 个字符。请确保你对该参数设值。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  A user logs in to the chat server with a password.
 *
 *  This is an asynchronous method.
 *
 *  It is recommended that you log in to the chat service with a token.
 *
 *  @param aUsername        The username. The maximum length is 64 characters. Ensure that you set this parameter. Supported characters include the 26 English letters (a-z), the ten numbers (0-9), the underscore (_), the hyphen (-), and the English period (.). This parameter is case insensitive, and upper-case letters are automatically changed to low-case ones. If you want to set this parameter as a regular expression, set it as ^[a-zA-Z0-9_-]+$.
 *  @param aPassword        The password. The maximum length is 64 characters. Ensure that you set this parameter.
 *  @param aCompletionBlock The completion block, which contains the username and the error message if the method fails.
 *
 */
- (void)loginWithUsername:(NSString *_Nonnull)aUsername
                 password:(NSString *_Nonnull)aPassword
               completion:(void (^_Nullable)(NSString * _Nonnull aUsername, EMError *_Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  用户使用 token 登录。该方法支持自动登录。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param aUsername  用户名，长度不超过 64 个字符。请确保你对该参数设值。支持的字符包括英文字母（a-z），数字（0-9），下划线（_），英文横线（-），英文句号（.）。该参数不区分大小写，大写字母会被自动转为小写字母。如果使用正则表达式设置该参数，则可以将表达式写为：^[a-zA-Z0-9_-]+$。
 *  @param aToken     The token。
 *
 *  @result EMError 错误信息，包含调用失败的原因。
 *
 *  \~english
 *  A user logs in to the chat server with a token. This method does not support automatic isLoggedIn.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aUsername  The username. The maximum length is 64 characters. Ensure that you set this parameter. Supported characters include the 26 English letters (a-z), the ten numbers (0-9), the underscore (_), the hyphen (-), and the English period (.). This parameter is case insensitive, and upper-case letters are automatically changed to low-case ones. If you want to set this parameter as a regular expression, set it as ^[a-zA-Z0-9_-]+$.
 *  @param aToken     The token for user logging in to Chat server.
 *
 *  @result Returns nil on success, and the description of the issue that cause the call to fail.
 */
- (EMError *_Nullable)loginWithUsername:(NSString *_Nonnull)aUsername
                                  token:(NSString *_Nonnull)aToken;

/**
 *  \~chinese
 *  用户使用 token 登录。该方法支持自动登录。
 *
 *  异步方法。
 *
 *  @param aUsername        用户名，长度不超过 64 个字符。请确保你对该参数设值。支持的字符包括英文字母（a-z），数字（0-9），下划线（_），英文横线（-），英文句号（.）。该参数不区分大小写，大写字母会被自动转为小写字母。如果使用正则表达式设置该参数，则可以将表达式写为：^[a-zA-Z0-9_-]+$。
 *  @param aToken           The token。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  A user logs in to the chat server with a token. This method support automatic login.
 *
 *  This is an asynchronous method.
 *
 *  @param aUsername        The username. The maximum length is 64 characters. Ensure that you set this parameter. Supported characters include the 26 English letters (a-z), the ten numbers (0-9), the underscore (_), the hyphen (-), and the English period (.). This parameter is case insensitive, and upper-case letters are automatically changed to low-case ones. If you want to set this parameter as a regular expression, set it as ^[a-zA-Z0-9_-]+$.
 *  @param aToken           The token for logging in to the chat server.
 *  @param aCompletionBlock The completion block, which contains the username and the error message if the method fails.
 *
 */
- (void)loginWithUsername:(NSString *_Nonnull)aUsername
                    token:(NSString *_Nonnull)aToken
               completion:(void (^_Nullable)(NSString * _Nonnull aUsername, EMError *_Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  声网 Agora Chat user token 登录。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param aUsername    用户名
 *  @param aAgoraToken  声网 Agora Chat user token。
 *
 *  @result 成功返回 nil，如果有错误会返回错误原因。
 *
 *  \~english
 *  A user logs in to the chat server with Agora Chat user token. Supports automatic login.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aUsername    The username.
 *  @param aAgoraToken  The Agora Chat user token.
 *
 *  @result Returns nil on success, and the description of the issue that cause the call to fail.
 */
- (EMError *_Nullable)loginWithUsername:(NSString *_Nonnull)aUsername
                             agoraToken:(NSString *_Nonnull)aAgoraToken;

/**
 *  \~chinese
 *  声网 Agora Chat user token 登录。
 *
 *  @param aUsername        用户名。
 *  @param aAgoraToken      声网 Agora Chat user token。
 *  @param aCompletionBlock 完成的回调，如果有错误会返回错误原因。
 *
 *  \~english
 *  A user logs in to the chat server with Agora Chat user token. Supports automatic login.
 *
 *
 *  @param aUsername        The username.
 *  @param aAgoraToken      The Agora Chat user token.
 *  @param aCompletionBlock The callback of completion block, which contains the description of the cause to the issue if the method fails.
 *
 */
- (void)loginWithUsername:(NSString *_Nonnull)aUsername
               agoraToken:(NSString *_Nonnull)aAgoraToken
               completion:(void (^_Nullable)(NSString * _Nonnull aUsername, EMError *_Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  当用户在声网 token 登录状态时，且在 EMClientDelegate 回调中收到 token 即将过期/已经过期事件的回调通知，可以调用这个 API 来更新 token，避免因 token 失效产生的未知问题。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param newAgoraToken 新声网 token。
 *
 *  @result 返回结果，如果有错误会返回错误信息。
 *
 *  \~english
 *  Renews the token when the current token expires.
 *
 *  The token expires after a period of time once the token schema is enabled when:
 *  - The SDK triggers the onTokenPrivilegeWillExpire callback, or
 *  - The onConnectionStateChanged callback reports the CONNECTION_CHANGED_TOKEN_EXPIRED(9) error.
 *
 *  The app should retrieve a new token from the server and call this method to renew it. Failure to do so results in the SDK disconnecting from the server.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param newAgoraToken The new Agora Chat token。
 *
 *  @result The result which contains the description of the cause to the failure if call fails.
 */
- (EMError *_Nullable)renewToken:(NSString *_Nonnull)newAgoraToken;

#pragma mark - Logout

/**
 *  \~chinese
 *  用户登出聊天服务器。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param aIsUnbindDeviceToken 是否解除账号与设备绑定。YES 表示解除绑定。成功解绑后，用户登出账号后设备将不再收到消息推送。如果你将该参数设为 YES，但解绑失败，则 SDK 会返回错误信息，包含调用失败的原因。
 *
 *  @result EMError 错误信息，包含失败原因。
 *
 *  \~english
 *  A user logs out of the chat server.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aIsUnbindDeviceToken Whether to unbind the username from the device(Set to YES to unbind the user currently logged into the app from this device). That stops the user device receiving push notifications from the Apple Push Notifications service.
 *
 *  @result A description of the issue that caused this call to fail.
 */
- (EMError *_Nullable)logout:(BOOL)aIsUnbindDeviceToken;

/**
 *  \~chinese
 *  登出聊天服务器。
 *
 *  异步方法。
 *
 *  @param aIsUnbindDeviceToken 是否解除账号与设备绑定。YES 表示解除绑定。成功解绑后，用户登出账号后设备将不再收到消息推送。如果你将该参数设为 YES，但解绑失败，则 SDK 会返回错误信息，包含调用失败的原因。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  A user logs out of the chat server.
 *
 *  This is an asynchronous method.
 *
 *  @param aIsUnbindDeviceToken     Whether to unbind the username from the device. If you unbind the username from the device (setting this parameter as YES) and logs out, the device no longer receives messages from the Apple Push Notification Service.
 *  @param aCompletionBlock         The completion block, which contains the token and the error message if the method fails.
 *
 */
- (void)logout:(BOOL)aIsUnbindDeviceToken
    completion:(void (^_Nullable)(EMError * _Nullable aError))aCompletionBlock;

#pragma mark - PushKit

/**
 *  \~chinese
 *  绑定 PushKit token。
 *
 *  这里是苹果的 PushKit 推送服务，服务于 VOIP 类型的推送。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param aPushToken  要绑定的 token。
 *
 *  @result EMError 错误信息，包含调用失败的原因。
 *
 *  \~english
 *  Use the pushkit token to bind the user and the device, which is required to enable Apple PushKit Service.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aPushToken      The pushkit token to bind.
 *
 *  @result A description of the issue that caused this call to fail.
 */
- (EMError *_Nullable)bindPushKitToken:(NSData *_Nullable)aPushToken;

/**
 *  \~chinese
 *  注册 PushKit token。
 *
 *  这里是苹果的 PushKit 推送服务，服务于 VOIP 类型的推送。
 *
 *  异步方法。
 *
 *  @param aPushToken  要绑定的 token。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Register a pushkit token, this is required to enable Apple PushKit Service, which is for VOIP CALL.
 *
 *  This is an asynchronous method.
 *
 *  @param aPushToken           The pushkit token to bind.
 *  @param aCompletionBlock     The completion block, which contains the error message if the method fails.
 */
- (void)registerPushKitToken:(NSData *_Nullable)aPushToken
                  completion:(void (^_Nullable)(EMError * _Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  解除 PushKit token 绑定，与解除注册 `unRegisterPushKitTokenWithCompletion` 方法作用一致。
 *
 *  这里是苹果的 PushKit 推送服务，服务于 VOIP 类型的推送。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @result EMError 错误信息，包含调用失败的原因。
 *
 *  \~english
 *  Unbind the Apple PushKit token.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @result A description of the issue that caused this call to fail.
 */
- (EMError *_Nullable)unBindPushKitToken;

/**
 *  \~chinese
 *  解除 PushKit token 注册，与解除绑定 `unBindPushKitToken` 方法作用一致。
 *
 *  异步方法。
 *
 *  这里是苹果的 PushKit 推送服务，服务于 VOIP 类型的推送。
 *
 *  \~english
 *  Unregister the Apple PushKit token.
 *
 *  @param aCompletionBlock     The completion block, which contains the error message if the method fails.
 */
- (void)unRegisterPushKitTokenWithCompletion:(void (^_Nullable)(EMError * _Nullable aError))aCompletionBlock;

#pragma mark - APNs

/**
 *  \~chinese
 *  绑定 device token。
 *
 *  Device token 用于苹果 APNS 推送。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param aDeviceToken  要绑定的 token。
 *
 *  @result EMError 错误信息，包含调用失败的原因。
 *
 *  \~english
 *  Device token binding is required to enable Apple Push Notification Service.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aDeviceToken  Device token to bind.
 *
 *  @Result Returns nil on success, and the description of the issue that cause the call to fail.
 */
- (EMError *_Nullable)bindDeviceToken:(NSData *_Nonnull)aDeviceToken;

/**
 *  \~chinese
 *  注册 device token。
 *
 *  Device token 用于苹果 APNS 推送。
 *
 *  异步方法。
 *
 *  @param aDeviceToken     要绑定的 token。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Device token binding is required to enable Apple push notification service.
 *
 *  @param aDeviceToken         The device token to bind.
 *  @param aCompletionBlock     The completion block, which contains the error message if the method fails.
 */
- (void)registerForRemoteNotificationsWithDeviceToken:(NSData *_Nonnull)aDeviceToken
                                           completion:(void (^_Nullable)(EMError *_Nullable aError))aCompletionBlock;

#pragma mark - Log

/**
 *  \~chinese
 *  上传日志到服务器。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @result 成功返回 nil，调用失败返回 error 其中包含调用失败的原因。
 *
 *  \~english
 *  Upload the log to the chat server.
 *  The information in the debug log is used by our engineers to fix errors and improve system performance.
 *  Make sure to use the `EMLog` class.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @result Returns nil on success, and error on failure which contains the description of the issue that cause the call to fail_Nullable.
 */
- (EMError *_Nullable)uploadLogToServer;

/**
 *  \~chinese
 *  上传日志到服务器。
 *
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Upload debugging log to server.
 *
 *  @param aCompletionBlock     The completion block, which contains the token and the error message if the method fails.
 */
- (void)uploadDebugLogToServerWithCompletion:(void (^_Nullable)(EMError *_Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  将日志文件压缩成 .gz 文件，返回 gz 文件路径。强烈建议方法完成之后删除该压缩文件。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param pError 错误信息，包含调用失败的原因。
 *
 *  @result NSString 文件路径。
 *
 *  \~english
 *  Compress the debug log into a gzip archive.
 *  Best practice is to delete this debug archive as soon as it is no longer used.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param pError  A description of the issue that caused this call to fail.
 *
 *  @result NSString The full filepath to the debug archive.
 */
- (NSString *_Nullable)getLogFilesPath:(EMError **_Nullable)pError;

/**
 *  \~chinese
 *  将日志文件压缩成 .gz 文件，返回 gz 文件路径。强烈建议方法完成之后删除该压缩文件。
 *
 *  异步方法。
 *
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Compresses the log files in the format of .gz and returns the path of the compressed file. Recommends deleting the compressed file when it is no longer used.
 *
 *  This is an asynchronous method.
 *
 *  @param aCompletionBlock     The completion block, which contains the token and the error message if the method fails.
 */
- (void)getLogFilesPathWithCompletion:(void (^_Nullable)(NSString *_Nullable aPath, EMError * _Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  输出日志信息到日志文件，需要在 SDK 初始化之后调用。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param aLog 要输出的日志信息。
 *
 *  \~english
 *  Output log info to log file. You can call this method after the SDK has been initialized.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aLog The log info.
 */
- (void)log:(NSString *_Nonnull)aLog;

/**
 *  \~chinese
 *  添加日志回调代理。
 *
 *  @param aDelegate  要添加的代理。
 *  @param aQueue     执行代理方法的队列。
 *
 *  \~english
 *  Add the log callback delegate.
 *
 *  @param aDelegate  The delegate that you want to add: EMLogDelegate.
 *  @param aQueue     The queue of calling delegate methods.
 */
- (void)addLogDelegate:(id<EMLogDelegate>_Nonnull)aDelegate
         delegateQueue:(dispatch_queue_t _Nullable )aQueue NS_SWIFT_NAME(addLog(delegate:queue:));

/**
 *  \~chinese
 *  移除日志回调代理。
 *
 *  @param aDelegate  要移除的代理。
 *
 *  \~english
 *  Remove the log callback delegate.
 *
 *  @param aDelegate  The log callback delegate that you want to delete.
 */
- (void)removeLogDelegate:(id<EMLogDelegate>_Nonnull)aDelegate NS_SWIFT_NAME(removeLog(delegate:));

#pragma mark - Multi Devices

/**
 *  \~chinese
 *  从服务器获取所有已经登录的设备信息。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param aUsername        用户名。
 *  @param aPassword        密码。
 *  @param pError           错误信息，包含调用失败的原因。
 *
 *  @result  所有已经登录的设备信息列表，由 <EMDeviceConfig> 对象组成的数组。
 *
 *  \~english
 *  Retrieve the array of devices the user is currently logged into.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aUsername      The username.
 *  @param aPassword      The password.
 *  @param pError         A description of the issue that caused this call to fail.
 *
 *  @result  The information of the logged in devices, an array of <EMDeviceConfig> objects.
 */
- (NSArray<EMDeviceConfig*> *_Nullable)getLoggedInDevicesFromServerWithUsername:(NSString * _Nonnull)aUsername
                                                                       password:(NSString * _Nonnull)aPassword
                                                                          error:(EMError ** _Nullable)pError;

/**
 *  \~chinese
 *  从服务器获取所有已经登录的设备信息。
 *
 *  异步方法。
 *
 *  @param aUsername        用户名。
 *  @param aPassword        密码。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Get all the device information <EMDeviceConfig> that logged in to the server.
 *
 *  This is an asynchronous method.
 *
 *  @param aUsername     The username.
 *  @param aPassword     The password.
 *  @param aCompletionBlock     The completion block, which contains the list and the error message if the method fails.
 *
 */
- (void)getLoggedInDevicesFromServerWithUsername:(NSString *_Nonnull)aUsername
                                        password:(NSString *_Nonnull)aPassword
                                      completion:(void (^_Nullable)(NSArray<EMDeviceConfig*> * _Nullable aList, EMError *_Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  强制指定的设备登出。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param aUsername        用户名。
 *  @param aPassword        密码。
 *  @param aResource        要登出的设备，可以通过 `getLoggedInDevicesFromServerWithUsername` 方法获取。
 *
 *  @result 返回方法调用结果，如果有错误会返回错误原因。
 *
 *  \~english
 *  Kick a single user from your app installed on a specific device.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aUsername     The username.
 *  @param aPassword     The password.
 *  @param aResource     The device to log `aUsername` out from. Call `getLoggedInDevicesFromServerWithUsername` to retrieve the list of devices `aUsername` is currently logged into.
 *
 *  @result Returns nil on success, and the description of the issue that cause the call to fail.
 */
- (EMError *_Nullable)kickDeviceWithUsername:(NSString *_Nonnull)aUsername
                                    password:(NSString *_Nonnull)aPassword
                                    resource:(NSString *_Nonnull)aResource;

/**
 *  \~chinese
 *  强制指定的设备登出。
 *
 *  异步方法。
 *
 *  @param aUsername        用户名。
 *  @param aPassword        密码。
 *  @param aResource        设备信息。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Kick a single user from your app installed on a specific device.
 *
 *  The device information can be obtained from `getLoggedInDevicesFromServerWithUsername`.
 *
 *  This is an asynchronous method.
 *
 *  @param aUsername     The username.
 *  @param aPassword     The password.
 *  @param aResource     The device to be logged out of. You can get the logged in devices through `getLoggedInDevicesFromServerWithUsername`.
 *  @param aCompletionBlock The completion block, which contains the error message if the method fails.
 */
- (void)kickDeviceWithUsername:(NSString *_Nonnull)aUsername
                      password:(NSString *_Nonnull)aPassword
                      resource:(NSString *_Nonnull)aResource
                    completion:(void (^_Nullable)(EMError *_Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  强制所有的登录设备登出。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param aUsername        用户名。
 *  @param aPassword        密码。
 *
 *  @result 返回结果，如果失败会包含调用失败的原因。
 *
 *  \~english
 *  Kicks a user from your app installed on all the devices.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aUsername     The username.
 *  @param aPassword     The password.
 *
 *  @result  Returns nil on success, and the description of the issue that cause the call to fail.
 */
- (EMError *_Nullable)kickAllDevicesWithUsername:(NSString *_Nonnull)aUsername
                                        password:(NSString *_Nonnull)aPassword;

/**
 *  \~chinese
 *  强制所有的登录设备登出。
 *
 *  异步方法。
 *
 *  @param aUsername        用户名。
 *  @param aPassword        密码。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Kicks a single user from your app installed on all the devices.
 *
 *  This is an asynchronous method.
 *
 *  @param aUsername      The username.
 *  @param aPassword      The password.
 *  @param aCompletionBlock The completion block, which contains the error message if the method fails.
 */
- (void)kickAllDevicesWithUsername:(NSString *_Nonnull)aUsername
                          password:(NSString *_Nonnull)aPassword
                        completion:(void (^_Nullable)(EMError *_Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  获取当前登录的设备信息
 *
 *  @result EMDeviceConfig 当前登录的设备信息
 *
 *  \~english
 *  Get Information of currently logged in device
 *
 *  @result EMDeviceConfig Information of currently logged in device
 */
- (EMDeviceConfig *)getDeviceConfig:(EMError **)pError;

#pragma mark - iOS

/**
 *  \~chinese
 *  iOS 专用，数据迁移到 SDK3.0。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  升级到 SDK3.0 版本需要调用该方法，开发者需要等该方法执行完后再进行数据库相关操作。
 *
 *  @result BOOL 是否迁移成功。
 *
 *  \~english
 *  Migrate the chat database to the latest SDK version.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @result   Returns YES for success and the description of the cause if the method fails.
 */
- (BOOL)migrateDatabaseToLatestSDK;

/**
 *  \~chinese
 *  iOS 专用，程序进入后台时，需要调用此方法断开连接。
 *
 *  @param aApplication  UIApplication
 *
 *  \~english
 *  Disconnects from the chat server when the app is switched to background.
 *
 *  @param aApplication  UIApplication
 */
- (void)applicationDidEnterBackground:(id _Nonnull )aApplication;

/**
 *  \~chinese
 *  iOS 专用，程序进入前台时，需要调用此方法进行重连。
 *
 *  @param aApplication  当前应用程序实例。
 *
 *  \~english
 *  Reconnect to the server when your app returns to foreground mode.
 *
 *  @param aApplication  The current application instance.
 */
- (void)applicationWillEnterForeground:(id _Nonnull )aApplication;

/**
 *  \~chinese
 *  iOS 专用，程序在前台收到 APNS 时，需要调用此方法。
 *
 *  @param application  当前应用程序实例。
 *  @param userInfo     推送内容。
 *
 *  \~english
 *  Occurs when your app is running in the foreground and the device receives an Apple Push Notification (APN).
 *
 *  @param application  The current application instance.
 *  @param userInfo     The push content.
 */
- (void)application:(id _Nonnull)application didReceiveRemoteNotification:(NSDictionary * _Nullable)userInfo;

#pragma mark - Service Check

/**
 *  \~chinese
 *  服务诊断接口，根据 EMServerCheckType 枚举的顺序依次诊断当前服务，并回调给开发者。
 *  如果已经登录，默认使用登录账号。
 *
 *  异步方法。
 *
 *  @param aUsername    用户名。
 *  @param aPassword    密码。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Run the server diagnostic tests for Agora Chat for a specific user.
 *  These tests are run in the order defined by EMServerCheckType.
 *  If the user is logged in, the login account is used by default.
 *
 *  This is an asynchronous method.
 *
 *  @param aUsername    The username.
 *  @param aPassword    The password.
 *  @param aCompletionBlock The completion block, which contains the error message if the method fails.
 */
- (void)serviceCheckWithUsername:(NSString *_Nonnull)aUsername
                        password:(NSString *_Nonnull)aPassword
                      completion:(void (^_Nullable)(EMServerCheckType aType, EMError *_Nullable aError))aCompletionBlock;

@property (nonatomic, strong, readonly) id<IEMTranslateManager> _Nonnull translateManager EM_DEPRECATED_IOS(3_8_9, 3_9_5,"Use -IEMChatManager translateMessage: instead");
@end
