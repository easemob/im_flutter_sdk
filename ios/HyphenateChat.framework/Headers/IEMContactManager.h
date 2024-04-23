/**
 *  \~chinese
 *  @header IEMContactManager.h
 *  @abstract 联系人相关操作协议类。
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header IEMContactManager.h
 *  @abstract The protocol defines the operations of contact.
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>
#import "EMCommonDefs.h"
#import "EMContactManagerDelegate.h"

@class EMError;

/**
 *  \~chinese
 *  好友相关操作。
 *
 *  \~english
 *  The contact management.
 */
@protocol IEMContactManager <NSObject>

@required

#pragma mark - Delegate

/**
 *  \~chinese
 *  添加回调代理。
 *
 *  @param aDelegate  要添加的代理。
 *  @param aQueue     aQueue 是指定执行代理方法的运行队列，如果传入 nil，则运行在主队列；传入指定的运行队列则在子线程运行。
 *
 *  \~english
 *  Adds delegate.
 *
 *  @param aDelegate  The delegate to be added.
 *  @param aQueue     (optional) The queue of calling delegate methods. You need to set this parameter as nil to run on main thread.
 */
- (void)addDelegate:(id<EMContactManagerDelegate> _Nonnull)aDelegate
      delegateQueue:(dispatch_queue_t)aQueue;

/**
 *  \~chinese
 *  移除回调代理。
 *
 *  @param aDelegate  要移除的代理。
 *
 *  \~english
 *  Removes delegate.
 *
 *  @param aDelegate  The delegate to be removed.
 */
- (void)removeDelegate:(id _Nonnull)aDelegate;


#pragma mark - Contact Operations

/**
 *  \~chinese
 *  获取本地存储的所有好友。
 * 
 *  同步方法。
 *
 *  @result 好友列表。
 *
 *  \~english
 *  Gets all contacts from the local database.
 * 
 *  This is a synchronous method and blocks the current thread.
 *
 *  @result The contact NSArray. 
 */
- (NSArray<NSString *> *_Nullable )getContacts;

/**
 *  \~chinese
 *  从服务器获取所有的好友。
 * 
 *  异步方法。
 *
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Gets all contacts from the server.
 * 
 *  This is an asynchronous method.
 *
 *  @param aCompletionBlock The completion block, which contains the error message if the method fails.
 *
 */
- (void)getContactsFromServerWithCompletion:(void (^)(NSArray<NSString *> *_Nullable aList, EMError *aError_Nullable ))aCompletionBlock;

/**
 *  \~chinese
 *  从服务器获取所有的好友。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param pError 错误信息。
 *
 *  @result 好友列表。
 *
 *  \~english
 *  Gets all the contacts from the server.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param pError The error information if the method fails: Error.
 *
 *  @result The contact NSArray.
 */
- (NSArray<NSString *> *_Nullable )getContactsFromServerWithError:(EMError **_Nullable )pError;

/**
 *  \~chinese
 *  添加好友。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param aUsername  要添加的用户。
 *  @param aMessage   邀请信息。
 *
 *  @result 错误信息。
 *
 *  \~english
 *  Adds a contact with invitation message.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aUsername  The user to add contact.
 *  @param aMessage   (optional) The invitation message. Sets the parameter as nil if you want to ignore the information.
 *
 *  @result The error information if the method fails: Error.
 */
- (EMError *_Nullable )addContact:(NSString *_Nonnull)aUsername
                          message:(NSString *_Nullable )aMessage;

/**
 *  \~chinese
 *  添加好友。
 * 
 *  异步方法。
 *
 *  @param aUsername        要添加的用户。
 *  @param aMessage         邀请信息。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Adds a contact.
 * 
 *  This is an asynchronous method.
 *
 *  @param aUsername        The user to be added as a contact.
 *  @param aMessage         The invitation message. 
 *  @param aCompletionBlock The completion block, which contains the error message if the method fails.
 *
 */
- (void)addContact:(NSString *_Nonnull)aUsername
           message:(NSString *_Nullable )aMessage
        completion:(void (^_Nullable )(NSString *_Nullable aUsername, EMError *_Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  删除好友。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param aUsername 要删除的好友。
 *  @param aIsDeleteConversation 是否删除会话。YES：删除好友，会同步删除与好友的会话，NO：仅删除好友，不删除会话。
 *
 *  @result 错误信息。
 *
 *  \~english
 *  Deletes a contact.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aUsername                The contact to be deleted.
 *  @param aIsDeleteConversation    Whether to keep the associated conversation and messages. Yes means delete the contact and synchronisely delete the conversations between the contact and the user. No means don't delete the conversations when deleting the contact.
 *
 *  @result The error information if the method fails: Error.
 */
- (EMError *_Nullable )deleteContact:(NSString *_Nonnull)aUsername
                isDeleteConversation:(BOOL)aIsDeleteConversation;

/**
 *  \~chinese
 *  删除好友。
 * 
 *  异步方法。
 *
 *  @param aUsername                要删除的好友。
 *  @param aIsDeleteConversation    是否删除会话。YES：删除好友，会同步删除与好友的会话，NO：仅删除好友，不删除会话。
 *  @param aCompletionBlock         该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Deletes a contact.
 * 
 *  This is an asynchronous method.
 *
 *  @param aUsername                The contact to be deleted.
 *  @param aIsDeleteConversation    Whether to delete the related conversation. Yes means delete the contact and synchronisely delete the conversations between the contact and the user. No means don't delete the conversations when deleting the contact.
 *  @param aCompletionBlock         The completion block, which contains the error message if the method fails.
 *
 */
- (void)deleteContact:(NSString *_Nonnull)aUsername
 isDeleteConversation:(BOOL)aIsDeleteConversation
           completion:(void (^_Nullable )(NSString *_Nullable aUsername, EMError *_Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  同意好友申请。
 * 
 *  异步方法。
 *
 *  @param aUsername        申请者。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Approves a friend request.
 * 
 *  This is an asynchronous method.
 *
 *  @param aUsername        The user who initiated the friend request.
 *  @param aCompletionBlock The completion block, which contains the error message if the method fails.
 *
 */
- (void)approveFriendRequestFromUser:(NSString *_Nonnull)aUsername
                          completion:(void (^_Nullable )(NSString *_Nullable aUsername, EMError *_Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  拒绝好友申请。
 * 
 *  异步方法。
 *
 *  @param aUsername        申请者。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Declines a friend request.
 * 
 *  This is an asynchronous method.
 *
 *  @param aUsername        The user who initiated the friend request.
 *  @param aCompletionBlock The completion block, which contains the error message if the method fails.
 *
 */
- (void)declineFriendRequestFromUser:(NSString *_Nonnull)aUsername
                          completion:(void (^_Nullable )(NSString *aUsername, EMError *_Nullable aError))aCompletionBlock;


#pragma mark - Blacklist Operations

/**
 *  \~chinese
 *  从本地获取黑名单列表。
 * 
 *  同步方法，会阻塞当前线程。
 *
 *  @result 黑名单列表。
 *
 *  \~english
 *  Gets the list of blocked users from local database.
 * This is a synchronous method and blocks the current thread.
 *  @result  The blocklist usernames NSArray. See <NSString>.
 */
- (NSArray<NSString *> *_Nullable )getBlackList;

/**
 *  \~chinese
 *  从服务器获取黑名单列表。
 * 
 *  异步方法。
 *
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Gets the blocklist from the server.
 * 
 *  This is an asynchronous method.
 *
 *  @param aCompletionBlock The completion block, which contains the error message if the method fails.
 *
 */
- (void)getBlackListFromServerWithCompletion:(void (^_Nullable )(NSArray<NSString *> *_Nullable aList, EMError *_Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  从服务器获取黑名单列表。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param pError 错误信息。
 *
 *  @result 黑名单列表。
 *
 *  \~english
 *  Gets the blocklist from the server.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param pError    The error information if the method fails: Error.
 *
 *  @result          The blocklist NSArray.
 */
- (NSArray<NSString *> *_Nullable )getBlackListFromServerWithError:(EMError **_Nullable )pError;


/**
 *  \~chinese
 *  将用户加入黑名单。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param aUsername 要加入黑名单的用户。
 *
 *  @result 错误信息。
 *
 *  \~english
 *  Adds a user to the blocklist.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aUsername The user to be added into the blocklist.
 *
 *  @result The error information if the method fails: Error.
 */
- (EMError *_Nullable )addUserToBlackList:(NSString *_Nonnull)aUsername;


/**
 *  \~chinese
 *  将用户加入黑名单。
 * 
 *  异步方法。
 *
 *  @param aUsername        要加入黑名单的用户。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Adds a user to the blocklist.
 * 
 *  This is an asynchronous method.
 *
 *  @param aUsername        The user to be added into the blocklist.
 *  @param aCompletionBlock The completion block, which contains the error message if the method fails.
 *
 */
- (void)addUserToBlackList:(NSString *_Nonnull)aUsername
                completion:(void (^_Nullable )(NSString *_Nullable aUsername, EMError *_Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  将用户移出黑名单。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param aUsername 要移出黑名单的用户。
 *
 *  @result 错误信息。
 *
 *  \~english
 *  Removes the user out of the blocklist.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aUsername The user to be removed from the blocklist.
 *
 *  @result The error information if the method fails: Error.
 */
- (EMError *_Nullable )removeUserFromBlackList:(NSString *_Nonnull)aUsername;

/**
 *  \~chinese
 *  将用户移出黑名单。
 * 
 *  异步方法。
 *
 *  @param aUsername        要移出黑名单的用户。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Removes the user from the blocklist.
 * 
 *  This is an asynchronous method.
 *
 *  @param aUsername        The user to be removed from the blocklist.
 *  @param aCompletionBlock The completion block, which contains the error message if the method fails.
 *
 */
- (void)removeUserFromBlackList:(NSString *_Nonnull)aUsername
                     completion:(void (^_Nullable )(NSString *_Nullable aUsername, EMError *_Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  同意加好友的申请。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param aUsername 申请者。
 *
 *  @result 错误信息。
 *
 *  \~english
 *  Accepts a friend request.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aUsername The user who initiated the friend request.
 *
 *  @result The error information if the method fails: Error.
 */
- (EMError *_Nullable )acceptInvitationForUsername:(NSString *_Nonnull)aUsername;

/**
 *  \~chinese
 *  拒绝加好友的申请。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param aUsername 申请者。
 *
 *  @result 错误信息。
 *
 *  \~english
 *  Declines a friend request.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aUsername The user who initiates the friend request.
 *
 *  @result The error information if the method fails: Error.
 *
 *  Please use this new method.
 * 
 * - (void)declineFriendRequestFromUser:(NSString *)aUsername
 *                           completion:(void (^)(NSString *aUsername, EMError *aError))aCompletionBlock;
 */
- (EMError *_Nullable )declineInvitationForUsername:(NSString *_Nonnull)aUsername;

#pragma mark - Other platform

/**
 *  \~chinese
 *  获取当前账号在其他平台(Windows 或者 Web)登录的 ID 列表。
 *  ID 使用方法类似于好友 username。
 * 
 *  同步方法，会阻塞当前线程。
 *
 *  @param pError   错误信息。
 *
 *  @result     ID 列表。
 *
 *  \~english
 *  Gets the ID list of the current account on another platform (Windows or Web)
 *  The ID usage is similar to friend username.
 * 
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param pError    The error information if the method fails: Error.
 *
 *  @result The ID NSArray. See <NSString>.
 *
 */
- (NSArray<NSString *> *_Nullable )getSelfIdsOnOtherPlatformWithError:(EMError **_Nullable )pError;

/**
 *  \~chinese
 *  获取当前账号在其他平台(Windows 或者 Web)登录的 ID 列表。
 *  ID 使用方法类似于好友 username。
 * 
 *  异步方法。
 *
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Gets the ID list of the current account on another platform (Windows or Web)
 *  The ID usage is similar to friend username.
 * 
 *  This is an asynchronous method.
 *
 *  @param aCompletionBlock The completion block, which contains the error message if the method fails.
 *
 */
- (void)getSelfIdsOnOtherPlatformWithCompletion:(void (^_Nullable)(NSArray<NSString *> *_Nullable aList, EMError *_Nullable aError))aCompletionBlock;

@end
