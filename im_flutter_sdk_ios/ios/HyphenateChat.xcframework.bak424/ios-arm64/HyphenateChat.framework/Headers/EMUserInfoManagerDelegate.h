/**
 *  \~chinese
 *  @header EMUserInfoManagerDelegate.h
 *  @abstract 用户属性变更回调代理协议。
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header EMUserInfoManagerDelegate.h
 *  @abstract The delegate protocol for user information change callbacks.
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>
#import "EMUserInfo.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  \~chinese
 *  用户属性变更回调代理协议。
 *
 *  \~english
 *  The delegate protocol for user information change callbacks.
 */
@protocol EMUserInfoManagerDelegate <NSObject>

@optional

/**
 *  \~chinese
 *  当前登录用户的用户属性发生变更的回调。
 *
 *  @param aUserInfo  变更后的用户属性。
 *
 *  \~english
 *  Occurs when the current user's information is updated.
 *
 *  @param aUserInfo  The updated user information.
 */
- (void)onSelfUserInfoUpdate:(EMUserInfo * _Nonnull)aUserInfo;

/**
 *  \~chinese
 *  其他用户的用户属性发生变更的批量回调。当收到消息的用户属性更新时间大于本地缓存的更新时间时，SDK回从服务器重取用户属性，并触发该回调。
 *
 *  @param aUserInfos  变更后的用户属性字典，key 为用户 ID，value 为用户属性。
 *
 *  \~english
 *  Occurs when other users' information is updated.
 *
 *  @param aUserInfos  The dictionary of updated user information, where the key is the user ID and the value is the user information. When the user information update time of the received message is greater than the local cached update time, the SDK will re-fetch the user information from the server and trigger this callback.
 */
- (void)onUserInfoUpdate:(NSDictionary<NSString *, EMUserInfo *> * _Nonnull)aUserInfos;

@end

NS_ASSUME_NONNULL_END
