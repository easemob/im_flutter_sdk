/**
 *  \~chinese
 *  @header EMClientDelegate.h
 *  @abstract 协议提供了与账号登录状态相关的回调。
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header EMClientDelegate.h
 *  @abstract The protocol provides callbacks related to account login status
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>
#import "EMErrorCode.h"

/**
 *  \~chinese 
 *  网络连接状态。
 *
 *  \~english 
 *  The connection state.
 */
typedef NS_ENUM(NSInteger, EMConnectionState) {
    EMConnectionConnected = 0,  /**
                                 * \~chinese 服务器已连接。
                                 * \~english The SDK is connected to the chat server.
                                 */
    EMConnectionDisconnected,   /**
                                 * \~chinese 服务器未连接。
                                 * \~english The SDK is disconnected from the chat server.
                                 */
};

@class EMError;

/**
 *  \~chinese 
 *  @abstract EMClientDelegate 提供与账号登录状态相关的回调。
 *
 *  \~english 
 *  @abstract This protocol provides a number of utility classes callback
 */
@protocol EMClientDelegate <NSObject>

@optional

/**
 *  \~chinese
 *  SDK 连接服务器的状态变化时会接收到该回调。
 *
 *  SDK 会在以下情况下触发该回调：
 *  1.登录成功后，设备无法上网时。
 *  2.登录成功后，连接状态发生变化时。
 *
 *  @param aConnectionState 当前的连接状态。
 *
 *  \~english
 *  Occurs when the connection state between the SDK and the server changes.
 * 
 *  The SDK triggers this callback in any of the following situations:
 *   - After login, the device is disconnected from the internet.
 *   - After login, the network status changes.
 *
 *  @param aConnectionState  The current connection state.
 */
- (void)connectionStateDidChange:(EMConnectionState)aConnectionState;

/**
 *  \~chinese
 *  自动登录完成时的回调。
 *
 *  @param aError 错误信息，包含失败原因。
 *
 *  \~english
 *  Occurs when the auto login is completed.
 *
 *  @param aError Error   A description of the issue that caused this call to fail.
 */
- (void)autoLoginDidCompleteWithError:(EMError * _Nullable)aError;

/**
 *  \~chinese
 *  当前登录账号在其它设备登录时会接收到此回调。
 *
 *  \~english
 *  Occurs when the current user account is logged in to another device.
 */
- (void)userAccountDidLoginFromOtherDevice;

/**
 *  \~chinese
 *  当前登录账号已经被从服务器端删除时会收到该回调。
 *
 *  \~english
 *  Occurs when the current chat user is removed from the server.
 */
- (void)userAccountDidRemoveFromServer;

/**
 *  \~chinese
 *  当前用户账号被禁用时会收到该回调。
 *
 *  \~english
 *  The delegate method will be invoked when the User account is forbidden.
 */
- (void)userDidForbidByServer;

/**
 *  \~chinese
 *  当前登录账号被强制退出时会收到该回调，有以下原因：
 *    - 密码被修改；
 *    - 登录设备数过多；
 *    - 服务被封禁;
 *    - 被强制下线;
 *
 *  \~english
 *  The delegate method will be invoked when current IM account is forced to logout with the following reasons:
 *    1. The password is modified;
 *    2. Logged in too many devices;
 *    3. User for forbidden;
 *    4. Forced offline.
 */
- (void)userAccountDidForcedToLogout:(EMError *_Nullable)aError;

/**
 *  \~chinese
 *  token 即将过期 （使用声网 token 即 Agora Chat user token 登录）。
 *
 *  \~english
 *  token will expire (log in using agoraToken)
 */
- (void)tokenWillExpire:(EMErrorCode)aErrorCode;

/**
 *  \~chinese
 *  token已经过期 （使用声网token agoraToken 登录）
 *
 *  \~english
 *  token did expire (log in using agoraToken)
 */
- (void)tokenDidExpire:(EMErrorCode)aErrorCode;

@end
