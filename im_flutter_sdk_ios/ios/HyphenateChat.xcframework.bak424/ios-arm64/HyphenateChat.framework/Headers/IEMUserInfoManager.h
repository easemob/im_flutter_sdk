//
//  IEMUserInfoManager.h
//  HyphenateSDK
//
//  Created by lixiaoming on 2021/3/17.
//  Copyright © 2021 easemob.com. All rights reserved.
//

/**
 *  \~chinese
 *  @header IEMUserInfoManager.h
 *  @abstract 用户属性操作类。
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header IEMUserInfoManager.h
 *  @abstract The user information operation class.
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>
#import "EMUserInfo.h"
#import "EMError.h"
#import "EMUserInfoManagerDelegate.h"

@protocol IEMUserInfoManager <NSObject>

#pragma mark - Delegate

/**
 *  \~chinese
 *  添加回调代理。
 *
 *  @param aDelegate  实现代理协议的对象。
 *  @param aQueue     执行代理方法的队列。若在主线程上运行 app，将该参数设置为空。
 *
 *  \~english
 *  Adds a delegate.
 *
 *  @param aDelegate  The object that implements the protocol.
 *  @param aQueue     (optional) The queue of calling delegate methods. If you want to run the app on the main thread, set this parameter as nil.
 */
- (void)addDelegate:(id<EMUserInfoManagerDelegate> _Nullable)aDelegate
      delegateQueue:(dispatch_queue_t _Nullable)aQueue;

/**
 *  \~chinese
 *  移除回调代理。
 *
 *  @param aDelegate  要移除的代理。
 *
 *  \~english
 *  Removes a delegate.
 *
 *  @param aDelegate  The delegate to be removed.
 */
- (void)removeDelegate:(id<EMUserInfoManagerDelegate> _Nonnull)aDelegate;

#pragma mark - User Info

/**
 *  \~chinese
 *  设置自己的所有用户属性。
 *
 *  @param aUserData            要设置的用户属性信息。
 *  @param aCompletionBlock     该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Sets all of the user's information.
 *
 *  @param aUserData           The user information data to set.
 *  @param aCompletionBlock    The completion block, which contains the error message if the method fails.
 */
- (void)updateOwnUserInfo:(EMUserInfo*_Nonnull)aUserData
               completion:(void (^_Nullable)(EMUserInfo*_Nullable aUserInfo,EMError *_Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  设置自己的指定用户属性。
 *
 *  @param aValue        要设置的用户属性信息。
 *  @param aType         要设置的用户属性类型。
 *  @param aCompletionBlock     该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Sets a specific user information of the user.
 *
 *  @param aValue       The user information data to set.
 *  @param aType         The user information type to set.
 *  @param aCompletionBlock   The completion block, which contains the error message if the method fails.
 */
- (void)updateOwnUserInfo:(NSString*_Nullable )aValue
                 withType:(EMUserInfoType)aType
               completion:(void (^_Nullable )(EMUserInfo*_Nullable aUserInfo,EMError * _Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  根据用户 ID 获取用户属性。
 *
 *  @param aUserIds  要获取用户属性的的用户 ID 列表。
 *  @param aCompletionBlock     该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Gets the user information by user ID.
 *
 *  @param aUserIds            The user ID list.
 *  @param aCompletionBlock    The completion block, which contains the error message if the method fails.
 */
- (void)fetchUserInfoById:(NSArray<NSString*>*_Nonnull)aUserIds
               completion:(void (^_Nullable)(NSDictionary<NSString*,EMUserInfo*> *_Nullable aUserDatas,EMError *_Nullable aError))aCompletionBlock;
/**
 *  \~chinese
 *  根据用户 ID 列表及属性类型列表获取用户指定属性。
 *
 *  @param aUserIds      要获取用户属性的的用户 ID 列表。
 *  @param aType         要获取哪些类型的用户属性列表。
 *  @param aCompletionBlock     该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Gets the specific user information by user ID.
 *
 *  @param aUserIds              The user ID list.
 *  @param aType                 The user information type list.
 *  @param aCompletionBlock      The completion block, which contains the error message if the method fails.
 */
- (void)fetchUserInfoById:(NSArray<NSString*>* _Nonnull)aUserIds
                     type:(NSArray<NSNumber*>*_Nonnull)aType
               completion:(void (^_Nullable)(NSDictionary<NSString*,EMUserInfo*> *_Nullable aUserDatas,EMError *_Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  根据用户 ID 从本地获取用户属性。
 *
 *  @param aUserIds  要获取用户属性的的用户 ID 列表。
 *  @param aCompletionBlock     该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Gets the user information from local memory by user ID.
 *
 *  @param aUserIds            The user ID list.
 *  @param aCompletionBlock    The completion block, which contains the error message if the method fails.
 */
- (NSDictionary<NSString*,EMUserInfo*> *_Nullable)getUserInfoByIds:(NSArray<NSString*>*_Nonnull)aUserIds;

/**
 *  \~chinese
 *  根据用户 ID 订阅非好友用户的信息更新事件。
 *
 *  @param userIds  要订阅的用户 ID 数组。
 *  @param completionBlock     该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Subscribes to user attribute update events of non-friend users by user ID.
 *
 *  @param userIds            The array of user IDs to subscribe to.
 *  @param completionBlock    The completion block, which contains the error message if the method fails.
 */
- (void)subscribeUsersInfo:(NSArray<NSString*>*_Nonnull)userIds
                       completion:(void (^_Nullable)(EMError *_Nullable error))completionBlock;
/**
 *  \~chinese
 *  根据用户 ID 取消订阅非好友用户的用户属性变更事件。
 *
 *  @param userIds  要取消订阅的用户 ID 数组。
 *  @param completionBlock     该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Unsubscribes from user attribute update events of non-friend users by user ID.
 *
 *  @param userIds            The array of user IDs to unsubscribe from.
 *  @param completionBlock    The completion block, which contains the error message if the method fails.
 */
- (void)unsubscribeUsersInfo:(NSArray<NSString*>*_Nonnull)userIds
                         completion:(void (^_Nullable)(EMError *_Nullable error))completionBlock;
/**
 *  \~chinese
 *  获取已被订阅属性更新事件的非好友用户的用户属性。
 *
 *  @param completionBlock     该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Gets user attributes of non-friend users whose attribute update events are subscribed to.
 * 
 *  @param completionBlock    The completion block, which contains the error message if the method fails.
 */
- (void)fetchSubscribedUsers:(void (^_Nullable)(NSArray<EMUserInfo*> *_Nullable users,EMError *_Nullable error))completionBlock;
@end

