//
//  IEMPresenceManager.h
//  HyphenateChat
//
//  Created by lixiaoming on 2022/1/14.
//  Copyright © 2022 easemob.com. All rights reserved.
//

/*!
 *  \~chinese
 *  @header IEMPresenceManager.h
 *  @abstract 在线状态管理类，负责发布自定义在线状态、管理在线状态订阅、查询指定用户的在线状态以及添加和移除回调代理。
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header IEMPresenceManager.h
 *  @abstract The presence management class, responsible for publishing a custom presence state, managing presence subscriptions, querying the current presence state of a user, and adding and removing a delegate.
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>
#import "EMPresenceManagerDelegate.h"
#import "EMError.h"

/*!
 *  \~chinese
 *  在线状态管理协议，提供在线状态管理功能。
 *
 *  \~english
 *  The presence management protocol that defines how to manage presence states.
 */
@protocol IEMPresenceManager <NSObject>
/*!
 *  \~chinese
 *  发布自定义在线状态。
 *
 *  @param aDescription     在线状态详细信息，建议不超过64字节。
 *  @param aCompletion 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Publishes a custom presence state.
 *
 *  @param aDescription The extension information of the presence state. It can be set as nil.
 *  @param aCompletion The completion block, which contains the error message if this method fails.
 */
- (void) publishPresenceWithDescription:(NSString*_Nullable )aDescription
                             completion:(void(^_Nullable )(EMError*_Nullable error))aCompletion;
/*!
 *  \~chinese
 *  订阅指定用户的在线状态。订阅成功后，在线状态变更时订阅者会收到回调通知。
 *
 *  @param members  要订阅Presence的用户 ID 数组，数组长度不能超过100。
 *  @param expiry   订阅持续时间，单位为秒，最大不超过30*24*3600。
 *  @param aCompletion 该方法完成调用的回调。如果该方法调用成功，会返回订阅用户的当前状态，调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Subscribes to a user's presence states. If the subscription succeeds, the subscriber will receive the callback when the user's presence state changes.
 *
 *  @param members The array of IDs of users whose presence states you want to subscribe to.
    @param expiry The expiration time of the presence subscription.
 *  @param aCompletion The completion block, which contains the error message if the method fails.
 */
- (void) subscribe:(NSArray<NSString*>*_Nonnull)members
            expiry:(NSInteger)expiry
        completion:(void(^_Nullable )(NSArray<EMPresence*>*_Nullable presences,EMError*_Nullable error))aCompletion;

/*!
 *  \~chinese
 *  取消订阅指定用户的在线状态。
 *
 *  @param members  要取消订阅Presence的用户 ID 数组，数组长度不能超过100。
 *  @param aCompletion 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Unsubscribes from a user's presence states.
 *
 *  @param members The array of IDs of users whose presence states you want to unsubscribe from.
 *  @param aCompletion The completion block, which contains the error message if the method fails.
 */
- (void) unsubscribe:(NSArray<NSString*>*_Nonnull) members
          completion:(void(^_Nullable )(EMError*_Nullable error))aCompletion;

/*!
 *  \~chinese
 *  分页查询当前用户订阅了哪些用户的在线状态。
 *
 *  @param pageNum 当前页码，从 1 开始。
 *  @param pageSize 每页的订阅用户的数量，最大不能超过500。
 *  @param aCompletion 完成回调，返回订阅的在线状态所属的用户 ID。若当前未订阅任何用户的在线状态，返回空值。
 *
 *  \~english
 *  Uses pagination to get a list of users whose presence states you have subscribed to.
 *
 *  @param pageNum The current page number, starting from 1.
 *  @param pageSize  The number of subscribed users on each page.
 *  @param aCompletion The completion block, which contains IDs of users whose presence states you have subscribed to. Returns nil if you subscribe to no user's presence state.
 */
- (void) fetchSubscribedMembersWithPageNum:(NSUInteger)pageNum
                                  pageSize:(NSUInteger)pageSize
                                Completion:(void(^_Nullable )(NSArray<NSString*>*_Nullable  members,EMError*_Nullable error))aCompletion;
/*!
 *  \~chinese
 *  查询指定用户的当前在线状态。
 *
 *  @param members  用户 ID 数组，指定要查询哪些用户的在线状态。
 *  @param aCompletion 完成回调，返回用户的在线状态。
 *
 *  \~english
 *  Gets the current presence state of users.
 *
 *  @param members The array of IDs of users whose current presence state you want to check.
 *  @param aCompletion The completion block, which contains the users whose presence state you have subscribed to.
 */
- (void) fetchPresenceStatus:(NSArray<NSString*>*_Nonnull )members
                  completion:(void(^_Nullable )(NSArray<EMPresence*>* _Nullable presences,EMError*_Nullable error))aCompletion;
/*!
 *  \~chinese
 *  添加回调代理。
 *
 *  @param aDelegate  要添加的代理。
 *  @param aQueue     执行代理方法的队列。若要在主线程上运行应用，需将该参数设置为空。
 *
 *  \~english
 *  Adds a delegate.
 *
 *  @param aDelegate  The delegate to be added.
 *  @param aQueue     (optional) The queue of calling delegate methods. If you want to run the app on the main thread, set this parameter as nil.
 */
- (void) addDelegate:(id<EMPresenceManagerDelegate> _Nonnull)aDelegate
       delegateQueue:(dispatch_queue_t _Nullable )aQueue;
/*!
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
- (void) removeDelegate:(id<EMPresenceManagerDelegate> _Nonnull)aDelegate;
@end
/* IEMPresenceManager_h */


