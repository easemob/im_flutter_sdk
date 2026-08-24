/**
 *  \~chinese
 *  @header     EMContactManagerDelegate.h
 *  @abstract   联系人相关的代理协议
 *  @author     Hyphenate
 *  @version    3.00
 *
 *  \~english
 *  @header     EMContactManagerDelegate.h
 *  @abstract   The protocol of contact callbacks definitions
 *  @author     Hyphenate
 *  @version    3.00
 */

#import <Foundation/Foundation.h>

@class EMContact;
@class EMError;

/**
 *  \~chinese
 *  联系人相关的代理协议。
 *
 *  \~english
 *  The contact related callbacks.
 */
@protocol EMContactManagerDelegate <NSObject>

@optional

/**
 *  \~chinese
 *  用户 B 同意用户 A 的加好友请求后，用户 A 会收到该回调
 *
 *  @param aUsername   用户 B 的 user ID
 *
 *  \~english
 *  Occurs when a friend request is approved, user A will receive this callback after user B approved user A's friend request.
 *
 *  @param aUsername    The user ID who approves a friend's request.
 */
- (void)friendRequestDidApproveByUser:(NSString * _Nonnull)aUsername;

/**
 *  \~chinese
 *  用户 B 拒绝用户 A 的加好友请求后，用户 A 会收到该回调。
 *
 *  @param aUsername   用户 B 的 user ID
 *
 *  \~english
 *  Occurs when a friend request is declined.
 *
 *  User A will receive this callback after user B declined user A's friend request.
 *
 *  @param aUsername   The user ID who declined a friend request.
 */
- (void)friendRequestDidDeclineByUser:(NSString * _Nonnull)aUsername;

/**
 *  \~chinese
 *  用户 B 删除与用户 A 的好友关系后，用户 A，B 会收到该回调。
 *
 *  @param aUsername   用户 B 的用户 ID。
 *
 *  \~english
 *  Occurs when a user is removed as a contact by another user.
 *
 *  User A and B both will receive this callback after User B unfriended User A.
 *
 *  @param aUsername   The user who unfriended the current user
 */
- (void)friendshipDidRemoveByUser:(NSString * _Nonnull)aUsername;

/**
 *  \~chinese
 *  用户 B 同意用户 A 的好友申请后，用户 A 和用户 B 都会收到该回调。
 *
 *  @param aUsername   对端用户的用户 ID。
 *
 *  \~english
 *  Occurs when the user is added as a contact by another user.
 *
 *  Both user A and B will receive this callback after User B agreed user A's add-friend invitation.
 *
 *  @param aUsername   The user ID of the peer user.
 */
- (void)friendshipDidAddByUser:(NSString *_Nonnull)aUsername;

/**
 *  \~chinese
 *  用户 B 申请加 A 为好友后，用户 A 会收到该回调。
 *
 *  @param aUsername   用户 B 的用户 ID。
 *  @param aMessage    好友邀请信息。
 *
 *  \~english
 *  Occurs when a user receives a friend request.
 *
 *  User A will receive this callback when receiving a friend request from User B.
 *
 *  @param aUsername   Friend request sender user ID
 *  @param aMessage    Friend request message
 */
- (void)friendRequestDidReceiveFromUser:(NSString *_Nonnull)aUsername
                                message:(NSString *_Nullable)aMessage;
/**
 * \~chinese
 *  从服务器同步好友列表与好友信息开始的回调。
 *
 * \~english
 * Occurs when the synchronization of the contact list and contact information from the server starts.
 */
- (void)onFriendStartSync;
/**
 * \~chinese
 * 从服务器同步好友列表与好友信息完成的回调。
 * 
 * @param error 同步结果。若同步成功，error 为 nil；若同步失败，error 包含错误信息。
 *
 * \~english
 *  Occurs when the synchronization of the contact list and contact information from the server finishes.
 * 
 *  @param error The synchronization result. It is `nil` if the synchronization succeeds; otherwise, it contains an error describing the failure.
 */
- (void)onFriendSyncFinished:(EMError * _Nullable)error;

/**
 * \~chinese
 * 好友信息变更回调。
 * 
 * @param contact 好友对象，其中包括好友信息对象 `EMUserInfo`。
 *
 * \~english
 *  Occurs when the contact information changes.
 * 
 *  @param contact The contact object which contains the contact information object `EMUserInfo`.
 */
- (void)onFriendInfoChanged:(EMContact * _Nonnull)contact;

@end
