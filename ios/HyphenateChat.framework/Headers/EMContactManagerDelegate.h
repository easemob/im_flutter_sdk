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
 *  用户 B 同意用户 A 的加好友请求后，用户 A 会收到这个回调
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
 *  用户 B 拒绝用户 A 的加好友请求后，用户 A 会收到这个回调。
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
 *  用户 B 删除与用户 A 的好友关系后，用户 A，B 会收到这个回调
 *
 *  @param aUsername   用户 B 的 user ID
 *
 *  \~english
 *  Occurs when a user is removed as a contact by another user.
 *
 *  User A and B both will receive this callback after User B unfriended user A.
 *
 *  @param aUsername   The user who unfriended the current user
 */
- (void)friendshipDidRemoveByUser:(NSString * _Nonnull)aUsername;

/**
 *  \~chinese
 *  用户 B 同意用户 A 的好友申请后，用户 A 和用户 B 都会收到这个回调
 *
 *  @param aUsername   用户好友关系的另一方
 *
 *  \~english
 *  Occurs when the user is added as a contact by another user.
 *
 *  Both user A and B will receive this callback after User B agreed user A's add-friend invitation.
 *
 *  @param aUsername   Another user of the user‘s friend relationship.
 */
- (void)friendshipDidAddByUser:(NSString *_Nonnull)aUsername;

/**
 *  \~chinese
 *  用户 B 申请加 A 为好友后，用户 A 会收到这个回调。
 *
 *  @param aUsername   用户 B 的 user ID
 *  @param aMessage    好友邀请信息
 *
 *  \~english
 *  Occurs when a user received a friend request.
 *
 *  User A will receive this callback when received a friend request from user B.
 *
 *  @param aUsername   Friend request sender user ID
 *  @param aMessage    Friend request message
 */
- (void)friendRequestDidReceiveFromUser:(NSString *_Nonnull)aUsername
                                message:(NSString *_Nullable)aMessage;

@end
