//
//  IEMThreadManager.h
//  HyphenateChat
//
//  Created by 朱继超 on 2022/3/1.
//  Copyright © 2022 easemob.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMThreadManagerDelegate.h"
#import "EMChatThread.h"
#import "EMCursorResult.h"
@class EMChatMessage;
NS_ASSUME_NONNULL_BEGIN
@protocol IEMThreadManager <NSObject>
@required

#pragma mark - Delegate

/*!
 *  \~chinese
 *  添加回调代理
 *
 *  @param aDelegate  要添加的子区正常的增删改查的代理
 *  @param aQueue     代理执行的队列，如果是nil，则在主线程
 *
 *  \~english
 *  Add delegate
 *
 *  @param aDelegate  Delegate is kindof protocol EMThreadManagerDelegate
 *  @param aQueue     (optional) The queue of calling delegate methods. Pass in nil to run on main thread.
 */
- (void)addDelegate:(id<EMThreadManagerDelegate>)aDelegate
      delegateQueue:(_Nullable dispatch_queue_t)aQueue;

/*!
 *  \~chinese
 *  移除回调代理
 *
 *  @param aDelegate  要移除的代理
 *
 *  \~english
 *  Remove delegate
 *
 *  @param aDelegate   Delegate is kindof protocol EMThreadManagerDelegate
 */
- (void)removeDelegate:(id<EMThreadManagerDelegate>)aDelegate;


#pragma mark - Get Thread
/*!
 *  \~chinese
 *  获取thread详情
 *
 *  @param threadId 要获取的子区的id
 *  @param aCompletionBlock 返回回调，包含一个EMChatThread对象跟一个EMError的错误对象
 *  \~english
 *  Get the thread detail
 *  @param threadId The id of the subarea to get
 *  @param aCompletionBlock Returns the callback, containing an EMChatThread object and an EMError error object
 */
- (void)getChatThreadFromSever:(NSString *)threadId completion:(void (^)(EMChatThread *_Nullable  thread, EMError * _Nullable aError))aCompletionBlock;
/*!
 *  \~chinese
 *  从服务器获取用户已加入的子区
 *
 *  @param aCursor cursor 上一次取数的位置游标
 *  @param pageSize 单次请求数量(单次请求限制最大50)
 *  @param aCompletionBlock 返回回调，包含一个EMCursorResult对象跟一个EMError的错误对象
 *  \~english
 *  Get the subzones the user has joined from the server
 *  @param aCursor cursor The position cursor of the last fetch
 *  @param pageSize Number of single requests limit 50
 *  @param aCompletionBlock Returns the callback, containing an EMCursorResult object and an EMError error object
 */
- (void)getJoinedChatThreadsFromServerWithCursor:(NSString *)aCursor
                                 pageSize:(NSInteger)aPageSize
                               completion:(void (^)(EMCursorResult<EMChatThread*>* _Nullable result, EMError * _Nullable aError))aCompletionBlock;
/*!
 *  \~chinese
 *  从服务器获取一个群组下的子区
 *
 *  @param parentId 子区的上一级所属会话id
 *  @param aCursor cursor 上一次取数的位置游标
 *  @param pageSize 单次请求数量(最大不超过50)
 *  @param aCompletionBlock 返回回调，包含一个EMCursorResult对象跟一个EMError的错误对象
 *  \~english
 *  Get the subareas under a group from the server
 *  @param parentId The session id of the upper level of the sub-area
 *  @param aCursor The position cursor of the last fetch
 *  @param pageSize Number of single requests limit 50
 *  @param aCompletionBlock Returns the callback, containing an EMCursorResult object and an EMError error object
 */
- (void)getChatThreadsFromServerWithParentId:(NSString *)parentId cursor:(NSString *)aCursor pageSize:(NSInteger)aPageSize completion:(void (^)(EMCursorResult<EMChatThread*> * _Nullable result, EMError * _Nullable aError))aCompletionBlock;
/*!
 *  \~chinese
 *  从服务器获取一个群组下我加入的子区
 *
 *  @param parentId 子区的上一级所属会话id
 *  @param aCursor cursor 上一次取数的位置游标
 *  @param pageSize 单次请求数量(最大不超过50)
 *  @param aCompletionBlock 返回回调，包含一个EMCursorResult对象跟一个EMError的错误对象
 *  \~english
 *  Get the mine subareas  under a group from the server
 *  @param parentId The session id of the upper level of the sub-area
 *  @param aCursor The position cursor of the last fetch
 *  @param pageSize Number of single requests limit 50
 *  @param aCompletionBlock Returns the callback, containing an EMCursorResult object and an EMError error object
 */
- (void)getJoinedChatThreadsFromServerWithParentId:(NSString *)parentId cursor:(NSString *)aCursor pageSize:(NSInteger)aPageSize completion:(void (^)(EMCursorResult<EMChatThread*> * _Nullable result, EMError * _Nullable aError))aCompletionBlock;
/*!
 *  \~chinese
 *  从服务器获取一个子区的成员列表
 *
 *  @param threadId 要获取成员的子区的id
 *  @param aCursor cursor 上一次取数的位置游标
 *  @param pageSize 单次请求数量
 *  @param aCompletionBlock 返回回调，包含一个EMCursorResult对象跟一个EMError的错误对象
 *  \~english
 *  Get a list of members in a subsection
 *  @param threadId The id of the subarea to get members
 *  @param aCursor cursor The position cursor of the last fetch
 *  @param pageSize Number of single requests limit 50
 *  @param aCompletionBlock Returns the callback, containing an EMCursorResult object and an EMError error object
 */
- (void)getChatThreadMemberListFromServerWithId:(NSString *)threadId cursor:(NSString *)aCursor pageSize:(NSInteger)pageSize completion:(void (^)(EMCursorResult<NSString*> * _Nullable aResult, EMError * _Nullable aError))aCompletionBlock;

/*!
 *  \~chinese
 *  从服务器批量获取子区的最后一条消息
 *
 *  @param threadIds 要获取的子区的id数组（单次请求不超过20个id）
 *  @param aCompletionBlock 返回回调，包含一个字典key是子区id，value是EMChatMessage对象
 *  \~english
 *  Get the thread detail
 *  @param threadIds The ids of the subarea to get(No more than 20 ids for a single request)
 *  @param aCompletionBlock Return the callback, including a dictionary key is the sub-area id, value is the EMChatMessage object
 */
- (void)getLastMessageFromSeverWithChatThreads:(NSArray <NSString *>*)threadIds completion:(void (^)(NSDictionary<NSString*,EMChatMessage*>* _Nullable messageMap, EMError * _Nullable aError))aCompletionBlock;
/*!
 *  \~chinese
 *  移除子区成员（仅群管理可用）
 *
 *  @param aUser 要移除用户的环信id
 *  @param threadId 要操作的子区id
 *  @param aCompletionBlock 返回回调，成功或者失败
 *  \~english
 *  Remove sub-zone members (only available for group management)
 *  @param aUser To remove the user's ease id
 *  @param threadId subarea id to operate
 *  @param aCompletionBlock return callback, success or failure
 */
- (void)removeMemberFromChatThread:(NSString *)aUser
             threadId:(NSString *)athreadId
           completion:(void (^)(EMError * _Nullable aError))aCompletionBlock;
/*!
 *  \~chinese
 *  更新子区名称（仅群管理或创建者可用）
 *
 *  @param subject 你想要修改的名称（限制64个字符）
 *  @param threadId 要操作的子区id
 *  @param aCompletionBlock 返回回调，成功或者失败
 *  \~english
 *  Update subzone name (only available for group managers or creators)
 *  @param name the name you want to change（limit 64 character）
 *  @param threadId subarea id to operate
 *  @param aCompletionBlock return callback, success or failure
 */
- (void)updateChatThreadName:(NSString *)name
                  threadId:(NSString *)athreadId
                 completion:(void (^)(EMError * _Nullable aError))aCompletionBlock;
/*!
 *  \~chinese
 *  Create a subsection
 *
 *  @param threadName 要创建的子区的名称（限制64个字符）
 *  @param messageId 操作创建子区那一条消息id
 *  @param parentId 操作创建子区那一条消息所在的会话id也就是那条消息的to
 *  @param completion 返回回调，包含一个EMChatThread对象跟一个EMError的错误对象
 *  \~english
 *  Create a subsection
 *  @param threadName The id of the subarea to get（limit 64 character）
 *  @param messageId The message id of the operation to create the sub-area
 *  @param parentId The session id where the message of the operation creates the sub-area is also the to of that message
 *  @param completion Returns the callback, containing an EMChatThread object and an EMError error object
 */
- (void)createChatThread:(NSString *)threadName messageId:(NSString *)messageId parentId:(NSString *)parentId completion:(void (^)(EMChatThread *_Nullable  thread,EMError * _Nullable aError))aCompletionBlock;
/*!
 *  \~chinese
 *  加入一个子区
 *
 *  @param threadId 要加入的子区的id
 *  @param aCompletionBlock 返回回调，成功或者失败
 *  \~english
 *  join a subsection
 *  @param threadId The id of the subzone to join
 *  @param aCompletionBlock return callback, success or failure
 */
- (void)joinChatThread:(NSString *)threadId completion:(void (^)(EMChatThread *_Nullable  thread,EMError * _Nullable aError))aCompletionBlock;

/*!
 *  \~chinese
 *  离开一个子区
 *
 *  @param threadId 要离开的子区的id
 *  @param aCompletionBlock 返回回调，成功或者失败
 *  \~english
 *  leave a subsection
 *  @param threadId The id of the subzone to leave
 *  @param aCompletionBlock return callback, success or failure
 */
- (void)leaveChatThread:(NSString *)athreadId completion:(void (^)(EMError * _Nullable aError))aCompletionBlock;

/*!
 *  \~chinese
 *  销毁一个子区(群管理员及其以上级别可调用)
 *
 *  @param threadId 要销毁的子区的id
 *  @param aCompletionBlock 返回回调，成功或者失败
 *  \~english
 *  destroy a subsection
 *  @param threadId The id of the subzone to destroy
 *  @param aCompletionBlock return callback, success or failure
 */
- (void)destroyChatThread:(NSString *)athreadId completion:(void (^)(EMError * _Nullable aError))aCompletionBlock;

@end
NS_ASSUME_NONNULL_END
