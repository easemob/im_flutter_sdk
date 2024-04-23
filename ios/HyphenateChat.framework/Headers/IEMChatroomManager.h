/**
 *  \~chinese
 *  @header IEMChatroomManager.h
 *  @abstract 聊天室相关操作协议类。
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header IEMChatroomManager.h
 *  @abstract This protocol defines the chat room operations.
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>

#import "EMCommonDefs.h"
#import "EMChatroomManagerDelegate.h"
#import "EMChatroomOptions.h"
#import "EMChatroom.h"
#import "EMPageResult.h"

#import "EMCursorResult.h"

@class EMError;

/**
 *  \~chinese
 *  管理聊天室的类。
 *
 *  \~english
 *  A class that manages the chatrooms.
 */
@protocol IEMChatroomManager <NSObject>

@required

#pragma mark - Delegate

/**
 *  \~chinese
 *  添加回调代理。
 *
 *  @param aDelegate  要添加的代理。
 *  @param aQueue     代理执行的队列。
 *
 *  \~english
 *  Adds the SDK delegate.
 *
 *  @param aDelegate  The delegate that you want to add: ChatroomManagerDelegate.
 *  @param aQueue     (Optional) The queue of calling the delegate methods. To run the app on the main thread, set this parameter as nil.
 */
- (void)addDelegate:(id<EMChatroomManagerDelegate> _Nonnull)aDelegate
      delegateQueue:(dispatch_queue_t _Nullable)aQueue;

/**
 *  \~chinese
 *  移除回调代理。
 *
 *  @param aDelegate  要移除的代理。
 *
 *  \~english
 *  Removes the delegate.
 *
 *  @param aDelegate  The delegate that you want to remove.
 */
- (void)removeDelegate:(id<EMChatroomManagerDelegate> _Nonnull)aDelegate;

#pragma mark - Fetch Chatrooms

/**
 *  \~chinese
 *  从服务器获取指定数目的聊天室。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param aPageNum         获取第几页。
 *  @param aPageSize        获取多少条。
 *  @param pError           出错信息。
 *
 *  @result 获取的聊天室列表，详见 EMPageResult。
 *
 *  \~english
 *  Gets the specified number of chat rooms from the server.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aPageNum         The page number.
 *  @param aPageSize        The page size.
 *  @param pError           The error information if the method fails: Error.
 *
 *  @result The chat room list. See EMPageResult.
 */
- (EMPageResult<EMChatroom*> *_Nullable)getChatroomsFromServerWithPage:(NSInteger)aPageNum
                                                 pageSize:(NSInteger)aPageSize
                                                    error:(EMError **_Nullable)pError;

/**
 *  \~chinese
 *  从服务器获取指定数目的聊天室。
 * 
 *  异步方法。
 *
 *  @param aPageNum             获取第几页。
 *  @param aPageSize            获取多少条。
 *  @param aCompletionBlock      该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Gets the specified number of chat rooms from the server.
 * 
 *  This is an asynchronous method.
 *
 *  @param aPageNum         The page number.
 *  @param aPageSize        The page size.
 *  @param aCompletionBlock     The completion block, which contains the error message if the method call fails.
 *
 */

- (void)getChatroomsFromServerWithPage:(NSInteger)aPageNum
                              pageSize:(NSInteger)aPageSize
                            completion:(void (^_Nullable)(EMPageResult<EMChatroom*> *_Nullable aResult, EMError *_Nullable aError))aCompletionBlock;

#pragma mark - Create

/**
 *  \~chinese
 *  创建聊天室。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param aSubject             聊天室主题。
 *  @param aDescription         聊天室描述。
 *  @param aInvitees            聊天室的成员，不包括聊天室创建者自己。
 *  @param aMessage             加入聊天室的邀请内容。
 *  @param aMaxMembersCount     聊天室最大成员数。
 *  @param pError               出错信息。
 *
 *  @result    创建的聊天室，详见 EMChatroom。
 *
 *  \~english
 *  Creates a chatroom.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aSubject             The subject of the chatroom.
 *  @param aDescription         The description of the chatroom.
 *  @param aInvitees            The members of the chatroom. Do not include the creator.
 *  @param aMessage             The invitation message.
 *  @param aMaxMembersCount     The maximum number of members in the chatroom.
 *  @param pError               The error information if the method fails: Error.
 *
 *  @result    The create chatroom. See EMChatroom.
 */
- (EMChatroom *_Nullable)createChatroomWithSubject:(NSString *_Nullable)aSubject
                                       description:(NSString *_Nullable)aDescription
                                          invitees:(NSArray<NSString *> *_Nullable)aInvitees
                                           message:(NSString *_Nullable)aMessage
                                   maxMembersCount:(NSInteger)aMaxMembersCount
                                             error:(EMError **_Nullable)pError;

/**
 *  \~chinese
 *  创建一个聊天室。
 * 
 *  异步方法。
 *
 *  @param aSubject                 聊天室主题。
 *  @param aDescription             聊天室描述。
 *  @param aInvitees                聊天室的成员，不包括聊天室创建者自己。
 *  @param aMessage                 加入聊天室的邀请内容。
 *  @param aMaxMembersCount         聊天室最大成员数。
 *  @param aCompletionBlock         该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *
 *  \~english
 *  Creates a chatroom.
 * 
 *  This is an asynchronous method.
 *
 *  @param aSubject                 The subject of the chatroom.
 *  @param aDescription             The description of the chatroom.
 *  @param aInvitees                The members of the chatroom. Do not include the creator.
 *  @param aMessage                 The invitation message.
 *  @param aMaxMembersCount         The maximum number of members in the chatroom.
 *  @param aCompletionBlock         The completion block, which contains the error message if the method call fails.
 *
 */
- (void)createChatroomWithSubject:(NSString *_Nullable)aSubject
                      description:(NSString *_Nullable)aDescription
                         invitees:(NSArray<NSString *> *_Nullable)aInvitees
                          message:(NSString *_Nullable)aMessage
                  maxMembersCount:(NSInteger)aMaxMembersCount
                       completion:(void (^_Nullable)(EMChatroom *_Nullable aChatroom, EMError *_Nullable aError))aCompletionBlock;

#pragma mark - Edit Chatroom

/**
 *  \~chinese
 *  加入一个聊天室。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param aChatroomId  聊天室的 ID。
 *  @param pError       返回的错误信息。
 *
 *  @result  所加入的聊天室，详见 EMChatroom。
 *
 *  \~english
 *  Joins a chatroom.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aChatroomId  The chatroom ID.
 *  @param pError       The error information if the method fails: Error.
 *
 *  @result  The chatroom instance.
 */
- (EMChatroom *)joinChatroom:(NSString * _Nonnull)aChatroomId
                       error:(EMError ** _Nullable)pError;

/**
 *  \~chinese
 *  加入聊天室。
 * 
 *  异步方法。
 *
 *  @param aChatroomId           聊天室的 ID。
 *  @param aCompletionBlock      该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *
 *  \~english
 *  Joins a chatroom.
 * 
 *  This is an asynchronous method.
 *
 *  @param aChatroomId          The chatroom ID.
 *  @param aCompletionBlock     The completion block, which contains the error message if the method call fails.
 *
 */
- (void)joinChatroom:(NSString *_Nonnull)aChatroomId
          completion:(void (^_Nullable)(EMChatroom *_Nullable aChatroom, EMError *_Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  退出聊天室。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param aChatroomId  聊天室 ID。
 *  @param pError       错误信息。
 *
 *
 *  \~english
 *  Leaves a chatroom.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aChatroomId  The chatroom ID.
 *  @param pError       The error information if the method fails: Error.
 *
 */
- (void)leaveChatroom:(NSString *_Nonnull)aChatroomId
                error:(EMError **_Nullable)pError;

/**
 *  \~chinese
 *  退出聊天室。
 * 
 *  异步方法。
 *
 *  @param aChatroomId          聊天室 ID。
 *  @param aCompletionBlock     该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *
 *  \~english
 *  Leaves a chatroom.
 * 
 *  This is an asynchronous method.
 *
 *  @param aChatroomId          The chatroom ID.
 *  @param aCompletionBlock     The completion block, which contains the error message if the method call fails.
 *
 */
- (void)leaveChatroom:(NSString *_Nonnull)aChatroomId
           completion:(void (^_Nullable)(EMError *_Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  解散聊天室。
 * 
 *  仅聊天室所有者可以解散聊天室。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param aChatroomId  聊天室 ID。
 *
 *  @result   - 如果方法调用成功，返回 nil。
 *            - 如果方法调用失败，返回错误信息。详见 EMError。
 *
 *  \~english
 *  Dismisses a chatroom. 
 * 
 *  Only the owner of a chatroom has the privilege to dismiss it.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aChatroomId  The chatroom ID.
 *
 *  @result  - `nil` if the method call succeeds. 
 *           - Error information if the method call fails. See EMError.
 */
- (EMError *_Nullable)destroyChatroom:(NSString *_Nonnull)aChatroomId;

/**
 *  \~chinese
 *  解散聊天室。
 * 
 *  仅聊天室所有者可以解散聊天室。
 * 
 *  异步方法。
 *
 *  @param aChatroomId      聊天室 ID。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Dismisses a chatroom.
 * 
 *  Only the owner of a chatroom has the privilege to dismiss it.
 * 
 *  This is an asynchronous method.
 *
 *  @param aChatroomId      The chatroom ID.
 *  @param aCompletionBlock The completion block, which contains the error message if the method call fails.
 *
 */
- (void)destroyChatroom:(NSString *_Nonnull)aChatroomId
             completion:(void (^_Nullable)(EMError * _Nullable aError))aCompletionBlock;

#pragma mark - Fetch

/**
 *  \~chinese
 *  获取指定的聊天室。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param aChatroomId           聊天室 ID。
 *  @param pError                错误信息。
 *
 *  @result  聊天室实例，详见 EMChatroom。
 *
 *  \~english
 *  Fetches the specific chatroom.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aChatroomId           The chatroom ID.
 *  @param pError                The error information if the method fails: Error.
 *
 *  @result The chatroom instance. See EMChatroom.
 */
- (EMChatroom *_Nullable)getChatroomSpecificationFromServerWithId:(NSString *_Nonnull)aChatroomId
                                                            error:(EMError *_Nullable*)pError;

/**
 *  \~chinese
 *  获取聊天室详情。
 *
 *  异步方法。
 * 
 *  @param aChatroomId           聊天室 ID
 *  @param aCompletionBlock      该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Fetches the chat room specifications.
 * 
 *  This is an asynchronous method.
 *
 *  @param aChatroomId           The chatroom ID.
 *  @param aCompletionBlock      The completion block, which contains the error message if the method call fails.
 *
 */
- (void)getChatroomSpecificationFromServerWithId:(NSString *_Nonnull)aChatroomId
                                      completion:(void (^_Nullable)(EMChatroom *_Nullable aChatroom, EMError *_Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  获取聊天室详情。
 *
 *  异步方法。
 *
 *  @param aChatroomId           聊天室 ID
 *  @param aFetchMembers         是否获取聊天室成员，为 YES 时，一次性返回 200 个以内成员。
 *  @param aCompletionBlock      该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Fetches the chat room specifications.
 *
 *  This is an asynchronous method.
 *
 *  @param aChatroomId           The chatroom ID.
 *  @param aFetchMembers         Whether to get the member list. If you set the parameter as YES, it will return no more than 200 members.
 *  @param aCompletionBlock      The completion block, which contains the error message if the method call fails.
 *
 */
- (void)getChatroomSpecificationFromServerWithId:(NSString *_Nonnull)aChatroomId
                                    fetchMembers:(bool)aFetchMembers
                                      completion:(void (^_Nullable)(EMChatroom *_Nullable aChatroom, EMError *_Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  获取聊天室成员列表。
 * 
 *  同步方法，会阻塞当前线程。
 *
 *  @param aChatroomId      聊天室 ID。
 *  @param aCursor          游标，首次调用传空。
 *  @param aPageSize        获取多少条。
 *  @param pError           错误信息。
 *
 *  @result   聊天室成员列表和游标。
 *
 *  \~english
 *  Gets the list of chatroom members from the server.
 * 
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aChatroomId      The chatroom ID.
 *  @param aCursor          The cursor. Set this parameter as nil when you call this method for the first time.
 *  @param aPageSize        The page size.
 *  @param pError           The error information if the method fails: Error.
 *
 *  @result    The list of chatroom members and the cursor.
 *
 */
- (EMCursorResult<NSString*> *_Nullable)getChatroomMemberListFromServerWithId:(NSString *_Nonnull)aChatroomId
                                                            cursor:(NSString *_Nullable)aCursor
                                                          pageSize:(NSInteger)aPageSize
                                                             error:(EMError **_Nullable)pError;

/**
 *  \~chinese
 *  获取聊天室成员列表。
 * 
 *  异步方法。
 *
 *  @param aChatroomId      聊天室 ID。
 *  @param aCursor          游标，首次调用传空。
 *  @param aPageSize        获取多少条。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *
 *  \~english
 *  Gets the list of chatroom members from the server.
 * 
 *  This is an asynchronous method.
 *
 *  @param aChatroomId      The chatroom ID.
 *  @param aCursor          The cursor. Set this parameter as nil when you call this method for the first time.
 *  @param aPageSize        The page size.
 *  @param aCompletionBlock The completion block, which contains the error message if the method call fails.
 *
 */
- (void)getChatroomMemberListFromServerWithId:(NSString *_Nonnull)aChatroomId
                                       cursor:(NSString *_Nullable)aCursor
                                     pageSize:(NSInteger)aPageSize
                                   completion:(void (^_Nullable)(EMCursorResult<NSString*> *_Nullable aResult, EMError *_Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  获取聊天室黑名单列表。
 * 
 *  仅聊天室所有者或者管理员可以获取黑名单。
 * 
 *  同步方法，会阻塞当前线程。
 *
 *  @param aChatroomId      聊天室 ID。
 *  @param aPageNum         获取第几页。
 *  @param aPageSize        获取多少条。
 *  @param pError           错误信息。
 *
 *
 *  \~english
 *  Gets the blocklist of chatroom from the server. 
 * 
 *  Only the chatroom owner or admin can call this method.
 * 
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aChatroomId      The chatroom ID.
 *  @param aPageNum         The page number.
 *  @param aPageSize        The page size.
 *  @param pError           The error information if the method fails: Error.
 *
 */
- (NSArray<NSString *> *_Nullable)getChatroomBlacklistFromServerWithId:(NSString *_Nonnull)aChatroomId
                                                            pageNumber:(NSInteger)aPageNum
                                                              pageSize:(NSInteger)aPageSize
                                                                 error:(EMError **_Nullable)pError;

/**
 *  \~chinese
 *  获取聊天室黑名单列表。
 * 
 *  仅聊天室所有者或者管理员可以获取黑名单。
 * 
 *  异步方法。
 *
 *  @param aChatroomId      聊天室 ID。
 *  @param aPageNum         获取第几页。
 *  @param aPageSize        获取多少条。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *
 *  \~english
 *  Gets the chatroom's blocklist. 
 * 
 *  Only the chatroom owner or admin can call this method.
 * 
 *  This is an asynchronous method.
 *
 *  @param aChatroomId      The chatroom ID.
 *  @param aPageNum         The page number.
 *  @param aPageSize        The page size.
 *  @param aCompletionBlock The completion block, which contains the error message if the method call fails.
 *
 */
- (void)getChatroomBlacklistFromServerWithId:(NSString *_Nonnull)aChatroomId
                                  pageNumber:(NSInteger)aPageNum
                                    pageSize:(NSInteger)aPageSize
                                  completion:(void (^_Nullable)(NSArray<NSString *> *_Nullable aList, EMError *_Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  获取聊天室被禁言列表。
 *
 *  仅聊天室所有者和管理员可调用此方法。
 * 
 *  同步方法，会阻塞当前线程。
 *
 *  @param aChatroomId      聊天室 ID。
 *  @param aPageNum         获取第几页。
 *  @param aPageSize        获取多少条。
 *  @param pError           错误信息。
 *
 *
 *  \~english
 *  Gets the list of members who are muted in the chatroom from the server.
 *
 *  Only the chatroom owner or admin can call this method.
 * 
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aChatroomId      The chatroom ID.
 *  @param aPageNum         The page number.
 *  @param aPageSize        The page size.
 *  @param pError           The error information if the method fails: Error.
 *
 */
- (NSArray<NSString *> *_Nullable)getChatroomMuteListFromServerWithId:(NSString *_Nonnull)aChatroomId
                                                           pageNumber:(NSInteger)aPageNum
                                                             pageSize:(NSInteger)aPageSize
                                                                error:(EMError **_Nullable)pError;

/**
 *  \~chinese
 *  获取聊天室被禁言列表。
 *
 *  仅聊天室所有者和管理员可调用此方法。
 * 
 *  异步方法。
 *
 *  @param aChatroomId      聊天室 ID。
 *  @param aPageNum         获取第几页。
 *  @param aPageSize        获取多少条。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *
 *  \~english
 *  Gets the list of members who were muted in the chatroom from the server.
 *
 *  Only the chatroom owner or admin can call this method.
 * 
 *  This is an asynchronous method.
 *
 *  @param aChatroomId      The chatroom ID.
 *  @param aPageNum         The page number.
 *  @param aPageSize        The page size.
 *  @param aCompletionBlock The completion block, which contains the error message if the method call fails.
 *
 */
- (void)getChatroomMuteListFromServerWithId:(NSString *_Nonnull)aChatroomId
                                 pageNumber:(NSInteger)aPageNum
                                   pageSize:(NSInteger)aPageSize
                                 completion:(void (^_Nullable)(NSArray<NSString *> *_Nullable aList, EMError *_Nullable aError))aCompletionBlock;


/**
 *  \~chinese
 *  获取聊天室白名单列表。
 * 
 *  仅聊天室所有者和管理员可调用此方法。
 * 
 *  同步方法，会阻塞当前线程。
 *
 *  @param aChatroomId      聊天室 ID。
 *  @param pError           错误信息。
 *
 *
 *  \~english
 *  Gets the allowlist of a chatroom from the server.
 * 
 *  Only the chatroom owner or admin can call this method.
 * 
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aChatroomId      The chatroom ID.
 *  @param pError           The error information if the method fails: Error.
 *
 */
- (NSArray<NSString *> *_Nullable)getChatroomWhiteListFromServerWithId:(NSString *_Nonnull)aChatroomId
                                                                 error:(EMError **_Nullable)pError;


/**
 *  \~chinese
 *  获取聊天室白名单列表。
 * 
 *  仅聊天室所有者和管理员可调用此方法。
 * 
 *  异步方法。
 *
 *  @param aChatroomId      聊天室 ID。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *
 *  \~english
 *  Gets the allowlist of a chatroom from the server.
 * 
 *  Only the chatroom owner or admin can call this method.
 * 
 *  This is an asynchronous method.
 *
 *  @param aChatroomId      The chatroom ID.
 *  @param aCompletionBlock The completion block, which contains the error message if the method call fails.
 *
 */
- (void)getChatroomWhiteListFromServerWithId:(NSString *_Nonnull)aChatroomId
                                  completion:(void (^_Nullable)(NSArray<NSString *> *_Nullable aList, EMError *_Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  查看当前用户是否在聊天室白名单中。
 * 
 *  同步方法，会阻塞当前线程。
 *
 *  @param aChatroomId      聊天室 ID。
 *  @param pError           错误信息。
 *
 *
 *  \~english
 *  Checks whether the current user is on the allowlist.
 * 
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aChatroomId      The chatroom ID.
 *  @param pError           The error information if the method fails: Error.
 *
 */
- (BOOL)isMemberInWhiteListFromServerWithChatroomId:(NSString *_Nonnull)aChatroomId
                                              error:(EMError **_Nullable )pError;

/**
 *  \~chinese
 *  查看当前用户是否在聊天室白名单中。
 * 
 *  异步方法。
 *
 *  @param aChatroomId      聊天室 ID。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *
 *  \~english
 *  Checks whether the current user is on the allowlist.
 * 
 *  This is an asynchronous method.
 *
 *  @param aChatroomId      The chatroom ID.
 *  @param aCompletionBlock The completion block, which contains the error message if the method call fails.
 *
 */
- (void)isMemberInWhiteListFromServerWithChatroomId:(NSString *_Nonnull)aChatroomId
                                         completion:(void (^_Nullable)(BOOL inWhiteList, EMError *_Nullable aError))aCompletionBlock;
/**
 *  \~chinese
 *  获取聊天室公告。
 * 
 *  同步方法，会阻塞当前线程。
 *
 *  @param aChatroomId      聊天室 ID。
 *  @param pError           错误信息。
 *
 *  @result    聊天室公告。
 *
 *  \~english
 *  Gets the announcement of a chatroom from the server.
 * 
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aChatroomId      The chatroom ID.
 *  @param pError           The error information if the method fails: Error.
 *
 *  @result    The announcement of chatroom.
 */
- (NSString *_Nullable)getChatroomAnnouncementWithId:(NSString *_Nonnull)aChatroomId
                                               error:(EMError **_Nullable )pError;

/**
 *  \~chinese
 *  获取聊天室公告。
 * 
 *  异步方法。
 *
 *  @param aChatroomId      聊天室 ID。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Gets the announcement of a chatroom from the server.
 * 
 *  This is an asynchronous method.
 *
 *  @param aChatroomId      The chatroom ID.
 *  @param aCompletionBlock The completion block, which contains the error message if the method call fails.
 *
 */
- (void)getChatroomAnnouncementWithId:(NSString *_Nonnull)aChatroomId
                           completion:(void (^_Nullable)(NSString *_Nullable aAnnouncement, EMError *_Nullable aError))aCompletionBlock;

#pragma mark - Edit

/**
 *  \~chinese
 *  更改聊天室主题。
 * 
 *  仅聊天室所有者有权限调用此方法。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param aSubject     新聊天室主题。
 *  @param aChatroomId  聊天室 ID。
 *  @param pError       错误信息。
 *
 *  @result    聊天室实例。
 *
 *  \~english
 *  Changes the chatroom‘s subject. 
 * 
 *  Only the chatroom owner can call this method.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aSubject     The new subject of the chatroom.
 *  @param aChatroomId  The chatroom ID.
 *  @param pError       The error information if the method fails: Error.
 *
 *  @result    The chatroom instance.
 */
- (EMChatroom *)updateSubject:(NSString *_Nullable )aSubject
                  forChatroom:(NSString *_Nonnull)aChatroomId
                        error:(EMError **_Nullable )pError;

/**
 *  \~chinese
 *  更改聊天室主题。
 * 
 *  仅聊天室所有者有权限调用此方法。
 * 
 *  异步方法。
 *
 *  @param aSubject         聊天室新主题。
 *  @param aChatroomId      聊天室 ID。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *
 *  \~english
 *  Changes the chatroom subject. 
 * 
 *  Only the chatroom owner can call this method.
 * 
 *  This is an asynchronous method.
 *
 *  @param aSubject         The new subject of the chatroom.
 *  @param aChatroomId      The chatroom ID.
 *  @param aCompletionBlock The completion block, which contains the error message if the method call fails.
 *
 */
- (void)updateSubject:(NSString *_Nullable )aSubject
          forChatroom:(NSString *_Nonnull)aChatroomId
           completion:(void (^_Nullable )(EMChatroom *_Nullable aChatroom, EMError *_Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  更改聊天室说明信息。
 * 
 *  仅聊天室所有者有权限调用此方法。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param aDescription 说明信息。
 *  @param aChatroomId  聊天室 ID。
 *  @param pError       错误信息。
 *
 *  @result    聊天室实例。
 *
 *  \~english
 *  Changes chatroom description. 
 * 
 *  Only the chatroom owner can call this method.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aDescription The new description.
 *  @param aChatroomId  The chatroom ID.
 *  @param pError       The error information if the method fails: Error.
 *
 *  @result    The chatroom instance.
 */
- (EMChatroom *_Nullable )updateDescription:(NSString *_Nullable )aDescription
                                forChatroom:(NSString *_Nonnull)aChatroomId
                                      error:(EMError **_Nullable )pError;

/**
 *  \~chinese
 *  更改聊天室说明信息。
 * 
 *  仅聊天室所有者有权限调用此方法。
 * 
 *  异步方法。
 *
 *  @param aDescription     说明信息。
 *  @param aChatroomId      聊天室 ID。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *
 *  \~english
 *  Changes the chatroom's description. 
 * 
 *  Only the chatroom owner can call this method.
 * 
 *  This is an asynchronous method.
 *
 *  @param aDescription     The new description.
 *  @param aChatroomId      The chatroom ID.
 *  @param aCompletionBlock The completion block, which contains the error message if the method call fails.
 *
 */
- (void)updateDescription:(NSString *_Nullable )aDescription
              forChatroom:(NSString *_Nonnull)aChatroomId
               completion:(void (^_Nullable )(EMChatroom *_Nullable aChatroom, EMError *_Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  将成员移出聊天室。
 * 
 *  仅聊天室所有者和管理员可调用此方法。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param aMembers     要移出的用户列表。
 *  @param aChatroomId  聊天室 ID。
 *  @param pError       错误信息。
 *
 *  @result    聊天室实例。
 *
 *  \~english
 *  Removes members from a chatroom. 
 * 
 *  Only the chatroom owner or admin can call this method.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aMembers     The users to be removed from the chatroom.
 *  @param aChatroomId  The chatroom ID.
 *  @param pError       The error information if the method fails: Error.
 *
 *  @result    The chatroom instance.
 */
- (EMChatroom *_Nullable )removeMembers:(NSArray<NSString *> *_Nonnull)aMembers
                           fromChatroom:(NSString *_Nonnull)aChatroomId
                                  error:(EMError **_Nullable )pError;

/**
 *  \~chinese
 *  将成员移出聊天室。
 * 
 *  仅聊天室所有者和管理员可调用此方法。
 * 
 *  异步方法。
 *
 *  @param aMembers         要移出的用户列表。
 *  @param aChatroomId      聊天室 ID。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *
 *  \~english
 *  Removes members from a chatroom. 
 * 
 *  Only the chatroom owner or admin can call this method.
 * 
 *  This is an asynchronous method. 
 *
 *  @param aMembers         The users to be removed from the chatroom.
 *  @param aChatroomId      The chatroom ID.
 *  @param aCompletionBlock The completion block, which contains the error message if the method call fails.
 *
 */
- (void)removeMembers:(NSArray<NSString *> *_Nonnull)aMembers
         fromChatroom:(NSString *_Nonnull)aChatroomId
           completion:(void (^_Nullable )(EMChatroom *_Nullable aChatroom, EMError *_Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  将用户加入聊天室黑名单。
 * 
 *  仅聊天室所有者有权限调用此方法。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param aMembers     要加入黑名单的用户。
 *  @param aChatroomId  聊天室 ID。
 *  @param pError       错误信息。
 *
 *  @result    聊天室实例。
 *
 *  \~english
 *  Adds users to the chatroom's blocklist. 
 * 
 *  Only the chatroom owner can call this method.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aMembers     The users to be added to the blocklist.
 *  @param aChatroomId  The chatroom ID.
 *  @param pError       The error information if the method fails: Error.
 *
 *  @result    The chatroom instance.
 */
- (EMChatroom *_Nullable )blockMembers:(NSArray<NSString *> *_Nonnull)aMembers
                          fromChatroom:(NSString *_Nonnull)aChatroomId
                                 error:(EMError **_Nullable )pError;

/**
 *  \~chinese
 *  将用户加入聊天室黑名单。
 * 
 *  仅聊天室所有者有权限调用此方法。
 * 
 *  异步方法。
 *
 *  @param aMembers         要加入黑名单的用户。
 *  @param aChatroomId      聊天室 ID。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *
 *  \~english
 *  Adds users to the chatroom's blocklist. 
 * 
 *  Only the chatroom owner can call this method.
 * 
 *  This is an asynchronous method.
 *
 *  @param aMembers         The users to be added to the chatroom.
 *  @param aChatroomId      The chatroom ID.
 *  @param aCompletionBlock The completion block, which contains the error message if the method call fails.
 *
 */
- (void)blockMembers:(NSArray<NSString *> *_Nonnull)aMembers
        fromChatroom:(NSString *_Nonnull)aChatroomId
          completion:(void (^_Nullable )(EMChatroom *_Nullable aChatroom, EMError *_Nullable aError))aCompletionBlock;


/**
 *  \~chinese
 *  从聊天室黑名单中移除用户。
 * 
 *  仅聊天室所有者有权限调用此方法。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param aMembers     要从黑名单中移除的用户名列表。
 *  @param aChatroomId  聊天室 ID。
 *  @param pError       错误信息
 *
 *  @result    聊天室实例。
 *
 *  \~english
 *  Removes users from chatroom blocklist.
 * 
 *  Only the chatroom owner can call this method.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aMembers     The users to be removed from the blocklist.
 *  @param aChatroomId  The chatroom ID.
 *  @param pError       The error information if the method fails: Error.
 *
 *  @result    The chatroom instance.
 */
- (EMChatroom *_Nullable )unblockMembers:(NSArray<NSString *> *_Nonnull)aMembers
                            fromChatroom:(NSString *_Nonnull)aChatroomId
                                   error:(EMError **_Nullable )pError;

/**
 *  \~chinese
 *  从聊天室黑名单中移除。
 * 
 *  仅聊天室所有者有权限调用此方法。
 * 
 *  异步方法。
 *
 *  @param aMembers         要从黑名单中移除的用户名列表。
 *  @param aChatroomId      聊天室 ID。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *
 *  \~english
 *  Removes users from the chatroom blocklist. 
 * 
 *  Only the chatroom owner can call this method.
 * 
 *  This is an asynchronous method.
 * 
 *  @param aMembers         The users to be removed from the blocklist.
 *  @param aChatroomId      The chatroom ID.
 *  @param aCompletionBlock The completion block, which contains the error message if the method call fails.
 *
 */
- (void)unblockMembers:(NSArray<NSString *> *_Nonnull)aMembers
          fromChatroom:(NSString *_Nonnull)aChatroomId
            completion:(void (^_Nullable )(EMChatroom *_Nullable aChatroom, EMError *_Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  变更聊天室所有者。
 * 
 *  仅聊天室所有者可调用此方法。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param aChatroomId  聊天室 ID。
 *  @param aNewOwner    新聊天室所有者。
 *  @param pError       错误信息。
 *
 *  @result    聊天室实例。
 *
 *  \~english
 *  Changes the chatroom owner. 
 * 
 *  Only the chatroom owner can call this method.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aChatroomId  The chatroom ID.
 *  @param aNewOwner    The new owner.
 *  @param pError       The error information if the method fails: Error.
 *
 *  @result The chatroom instance. See EMChatroom.
 */
- (EMChatroom *_Nullable )updateChatroomOwner:(NSString *_Nonnull)aChatroomId
                                     newOwner:(NSString *_Nonnull)aNewOwner
                                        error:(EMError **_Nullable )pError;

/**
 *  \~chinese
 *  变更聊天室所有者。
 * 
 *  仅聊天室所有者可调用此方法。
 * 
 *  异步方法。
 *
 *  @param aChatroomId      聊天室 ID。
 *  @param aNewOwner        新聊天室所有者。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *
 *  \~english
 *  Changes the chatroom owner. 
 * 
 *  Only the chatroom owner can call this method.
 * 
 *  This is an asynchronous method.
 *
 *  @param aChatroomId      The chatroom ID.
 *  @param aNewOwner        The new owner.
 *  @param aCompletionBlock The completion block, which contains the error message if the method call fails.
 *
 */
- (void)updateChatroomOwner:(NSString *_Nonnull)aChatroomId
                   newOwner:(NSString *_Nonnull)aNewOwner
                 completion:(void (^_Nullable )(EMChatroom *_Nullable aChatroom, EMError *_Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  添加聊天室管理员。
 * 
 *  仅聊天室所有者可调用此方法。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param aAdmin       要添加的管理员。
 *  @param aChatroomId  聊天室 ID。
 *  @param pError       错误信息。
 *
 *  @result    聊天室实例，详见 EMChatroom。
 *
 *  \~english
 *  Adds a chatroom admin. 
 * 
 *  Only the chatroom owner can call this method.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aAdmin       The new admin.
 *  @param aChatroomId  The chatroom ID.
 *  @param pError       The error information if the method fails: Error.
 *
 *  @result  The chatroom instance. See EMChatroom.
 */
- (EMChatroom *_Nullable )addAdmin:(NSString *_Nonnull)aAdmin
                        toChatroom:(NSString *_Nonnull)aChatroomId
                             error:(EMError **_Nullable )pError;

/**
 *  \~chinese
 *  添加聊天室管理员。
 * 
 *  仅聊天室所有者可调用此方法。
 * 
 *  异步方法。
 *
 *  @param aAdmin           要添加的聊天室管理员。
 *  @param aChatroomId      聊天室 ID。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *
 *  \~english
 *  Adds a chatroom admin. 
 * 
 *  Only the chatroom owner can call this method.
 * 
 *  This is an asynchronous method.
 *
 *  @param aAdmin           The new admin.
 *  @param aChatroomId      The chatroom ID.
 *  @param aCompletionBlock The completion block, which contains the error message if the method call fails.
 *
 */
- (void)addAdmin:(NSString *_Nonnull)aAdmin
      toChatroom:(NSString *_Nonnull)aChatroomId
      completion:(void (^_Nullable )(EMChatroom *_Nullable aChatroomp, EMError *_Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  移除聊天室管理员。
 * 
 *  仅聊天室所有者可调用此方法。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param aAdmin       要移除的聊天室管理员。
 *  @param aChatroomId  聊天室 ID。
 *  @param pError       错误信息
 *
 *  @result  聊天室实例，详见 EMChatroom。
 *
 *  \~english
 *  Removes a chatroom admin. 
 * 
 *  Only the chatroom owner can call this method.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aAdmin       The admin to be removed.
 *  @param aChatroomId  The chatroom ID.
 *  @param pError       The error information if the method fails: Error.
 *
 *  @result The chatroom instance. See EMChatroom.
 */
- (EMChatroom *_Nullable )removeAdmin:(NSString *_Nonnull)aAdmin
                         fromChatroom:(NSString *_Nonnull)aChatroomId
                                error:(EMError **_Nullable )pError;

/**
 *  \~chinese
 *  移除聊天室管理员。
 * 
 *  仅聊天室所有者可调用此方法。
 * 
 *  异步方法。
 *
 *  @param aAdmin           要添加的聊天室管理员。
 *  @param aChatroomId      聊天室 ID。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *
 *  \~english
 *  Removes a chatroom admin. 
 * 
 *  Only the chatroom owner and admin can call this method.
 * 
 *  This is an asynchronous method.
 *
 *  @param aAdmin           The admin to be removed.
 *  @param aChatroomId      The chatroom ID.
 *  @param aCompletionBlock The completion block, which contains the error message if the method call fails.
 *
 */
- (void)removeAdmin:(NSString *_Nonnull)aAdmin
       fromChatroom:(NSString *_Nonnull)aChatroomId
         completion:(void (^_Nullable )(EMChatroom *_Nullable aChatroom, EMError *_Nullable aError))aCompletionBlock;


/**
 *  \~chinese
 *  将一组成员禁言。
 * 
 *  仅聊天室所有者和管理员可调用此方法。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param aMuteMembers         要禁言的成员列表。
 *  @param aMuteMilliseconds    禁言时长
 *  @param aChatroomId          聊天室 ID。
 *  @param pError               错误信息
 *
 *  @result  聊天室实例，详见 EMChatroom。
 *
 *  \~english
 *  Mutes chatroom members.
 * 
 *  Only the chatroom owner or admin can call this method.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aMuteMembers         The list of members to mute.
 *  @param aMuteMilliseconds    Muted time duration in millisecond.
 *  @param aChatroomId          The chatroom ID.
 *  @param pError               The error information if the method fails: Error.
 *
 *  @result  The chatroom instance. See EMChatroom.
 */
- (EMChatroom *_Nullable )muteMembers:(NSArray<NSString *> *_Nonnull)aMuteMembers
                     muteMilliseconds:(NSInteger)aMuteMilliseconds
                         fromChatroom:(NSString *_Nonnull)aChatroomId
                                error:(EMError **_Nullable )pError;

/**
 *  \~chinese
 *  将一组成员禁言。
 * 
 *  仅聊天室所有者和管理员可调用此方法。
 * 
 *  异步方法。
 *
 *  @param aMuteMembers         要禁言的成员列表。
 *  @param aMuteMilliseconds    禁言时长
 *  @param aChatroomId          聊天室 ID。
 *  @param aCompletionBlock     该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Mutes chatroom members.
 * 
 *  Only the chatroom owner or admin can call this method.
 *
 *  This is an asynchronous method.
 *
 *  @param aMuteMembers         The list of mute.
 *  @param aMuteMilliseconds    Muted time duration in millisecond
 *  @param aChatroomId          The chatroom ID.
 *  @param aCompletionBlock     The completion block, which contains the error message if the method call fails.
 *
 */
- (void)muteMembers:(NSArray<NSString *> *_Nonnull)aMuteMembers
   muteMilliseconds:(NSInteger)aMuteMilliseconds
       fromChatroom:(NSString *_Nonnull)aChatroomId
         completion:(void (^_Nullable )(EMChatroom *_Nullable aChatroom, EMError *_Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  解除禁言。
 * 
 *  仅聊天室所有者和管理员可调用此方法。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param aMuteMembers     解除禁言的用户列表。
 *  @param aChatroomId      聊天室 ID。
 *  @param pError           错误信息
 *
 *  @result 聊天室实例，详见 EMChatroom。
 *
 *  \~english
 *  Unmutes chatroom members.
 * 
 *  Only the chatroom owner or admin can call this method.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aMembers         The list of members to unmute.
 *  @param aChatroomId      The chatroom ID.
 *  @param pError           The error information if the method fails: Error.
 *
 *  @result The chatroom instance. See EMChatroom.
 */
- (EMChatroom *_Nullable )unmuteMembers:(NSArray<NSString *> *_Nonnull)aMembers
                           fromChatroom:(NSString *_Nonnull)aChatroomId
                                  error:(EMError **_Nullable )pError;

/**
 *  \~chinese
 *  解除禁言。
 * 
 *  仅聊天室所有者和管理员可调用此方法。
 * 
 *  异步方法。
 *
 *  @param aMuteMembers     被解除的列表
 *  @param aChatroomId      聊天室 ID。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Unmutes chatroom members.
 * 
 *  Only the chatroom owner or admin can call this method.
 *
 *  This is an asynchronous method.
 *
 *  @param aMembers         The list of unmute.
 *  @param aChatroomId      The chatroom ID.
 *  @param aCompletionBlock The completion block, which contains the error message if the method call fails.
 *
 */
- (void)unmuteMembers:(NSArray<NSString *> *_Nonnull)aMembers
         fromChatroom:(NSString *_Nonnull)aChatroomId
           completion:(void (^_Nullable )(EMChatroom *_Nullable aChatroom, EMError *_Nullable aError))aCompletionBlock;



/**
 *  \~chinese
 *  设置全员禁言。
 * 
 *  仅聊天室所有者和管理员可调用此方法。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param aChatroomId      聊天室 ID。
 *  @param pError           错误信息
 *
 *  @result 聊天室实例，详见 EMChatroom。
 *
 *  \~english
 *  Mutes all members.
 * 
 *  Only the chatroom owner or admin can call this method.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aChatroomId      The chatroom ID.
 *  @param pError           The error information if the method fails: Error.
 *
 *  @result The chatroom instance. See EMChatroom.
 */
- (EMChatroom *_Nullable )muteAllMembersFromChatroom:(NSString *_Nonnull)aChatroomId
                                               error:(EMError **_Nullable )pError;

/**
 *  \~chinese
 *  设置全员禁言。
 * 
 *  仅聊天室所有者和管理员可调用此方法。
 * 
 *  异步方法。
 *
 *  @param aChatroomId      聊天室 ID。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Mutes all members. 
 * 
 *  Only the chatroom owner or admin can call this method.
 * 
 *  This is an asynchronous method.
 * 
 *  @param aChatroomId      The chatroom ID.
 *  @param aCompletionBlock The completion block, which contains the error message if the method call fails.
 *
 */
- (void)muteAllMembersFromChatroom:(NSString *_Nonnull)aChatroomId
                        completion:(void(^_Nullable )(EMChatroom *_Nullable aChatroom, EMError *_Nullable aError))aCompletionBlock;


/**
 *  \~chinese
 *  解除全员禁言。
 * 
 *  仅聊天室所有者和管理员可调用此方法。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param aChatroomId      聊天室 ID。
 *  @param pError           错误信息
 *
 *  @result 聊天室实例，详见 EMChatroom。
 *
 *  \~english
 *  Unmute all members.
 * 
 *  Only the chatroom owner or admin can call this method.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aChatroomId      The chatroom ID.
 *  @param pError           The error information if the method fails: Error.
 *
 *  @result The chatroom instance. See EMChatroom.
 */
- (EMChatroom *_Nullable )unmuteAllMembersFromChatroom:(NSString *_Nonnull)aChatroomId
                                                 error:(EMError **_Nullable )pError;


/**
 *  \~chinese
 *  解除全员禁言。
 * 
 *  仅聊天室所有者和管理员可调用此方法。
 * 
 *  异步方法。
 *
 *  @param aChatroomId      聊天室 ID。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Unmute all members.
 * 
 *  Only the chatroom owner or admin can call this method.
 * 
 *  This is an asynchronous method.
 *
 *  @param aChatroomId      The chatroom ID.
 *  @param aCompletionBlock The completion block, which contains the error message if the method call fails.
 *
 */
- (void)unmuteAllMembersFromChatroom:(NSString *_Nonnull)aChatroomId
                          completion:(void(^_Nullable )(EMChatroom *_Nullable aChatroom, EMError *_Nullable aError))aCompletionBlock;


/**
 *  \~chinese
 *  添加白名单。
 * 
 *  仅聊天室所有者和管理员可调用此方法。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param aMembers         被添加的列表。
 *  @param aChatroomId      聊天室 ID。
 *  @param pError           错误信息
 *
 *  @result 聊天室实例，详见 EMChatroom。
 *
 *  \~english
 *  Adds users to the allowlist.
 * 
 *  Only the chatroom owner and admin can call this method.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aMembers         The members to be added to the allowlist.
 *  @param aChatroomId      The chatroom ID.
 *  @param pError           The error information if the method fails: Error.
 *
 *  @result The chatroom instance. See EMChatroom.
 */
- (EMChatroom *_Nullable )addWhiteListMembers:(NSArray<NSString *> *_Nonnull)aMembers
                                 fromChatroom:(NSString *_Nonnull)aChatroomId
                                        error:(EMError **_Nullable )pError;

/**
 *  \~chinese
 *  添加白名单。
 * 
 *  仅聊天室所有者和管理员可调用此方法。
 * 
 *  异步方法。
 *
 *  @param aMembers         被添加的列表。
 *  @param aChatroomId      聊天室 ID。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Adds members to the allowlist.
 * 
 *  Only the chatroom owner and admin can call this method.
 * 
 *  This is an asynchronous method.
 *
 *  @param aMembers         The members to be added to the allowlist.
 *  @param aChatroomId      The chatroom ID.
 *  @param aCompletionBlock The completion block, which contains the error message if the method call fails.
 *
 */
- (void)addWhiteListMembers:(NSArray<NSString *> *_Nonnull)aMembers
               fromChatroom:(NSString *_Nonnull)aChatroomId
                 completion:(void (^_Nullable )(EMChatroom *_Nullable aChatroom, EMError *_Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  移除白名单。
 * 
 *  仅聊天室所有者和管理员可调用此方法。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param aMuteMembers     被移除的列表。
 *  @param aChatroomId      聊天室 ID。
 *  @param pError           错误信息。
 *
 *  @result 聊天室实例，详见 EMChatroom。
 *
 *  \~english
 *  Removes the members of the allowlist.
 * 
 *  Only the chatroom owner or admin can call this method.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aMembers         The members to be removed from the allowlist.
 *  @param aChatroomId      The chatroom ID.
 *  @param pError           The error information if the method fails: Error.
 *
 *  @result   The chatroom instance. See EMChatroom.
 */
- (EMChatroom *_Nullable )removeWhiteListMembers:(NSArray<NSString *> *_Nonnull)aMembers
                                    fromChatroom:(NSString *_Nonnull)aChatroomId
                                           error:(EMError **_Nullable )pError;

/**
 *  \~chinese
 *  移除白名单。
 * 
 *  仅聊天室所有者和管理员可调用此方法。
 * 
 *  异步方法。
 *
 *  @param aMembers         被移除的列表。
 *  @param aChatroomId      聊天室 ID。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Removes members from the allowlist.
 * 
 *  Only the chatroom owner or admin can call this method.
 * 
 *  This is an asynchronous method.
 *
 *  @param aMembers         The members to be removed from the allowlist.
 *  @param aChatroomId      The chatroom ID.
 *  @param aCompletionBlock The completion block, which contains the error message if the method call fails.
 *
 */
- (void)removeWhiteListMembers:(NSArray<NSString *> *_Nonnull)aMembers
                  fromChatroom:(NSString *_Nonnull)aChatroomId
                    completion:(void (^_Nullable )(EMChatroom *_Nullable aChatroom, EMError *_Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  修改聊天室公告。
 * 
 *  仅聊天室所有者和管理员可调用此方法。
 * 
 *  同步方法，会阻塞当前线程。
 *
 *  @param aChatroomId      聊天室 ID。
 *  @param aAnnouncement    群公告。
 *  @param pError           错误信息。
 *
 *  @result   聊天室实例，详见 EMChatroom。
 *
 *  \~english
 *  Changes the announcement of the chatroom.
 * 
 *  Only the chatroom owner or admin can call this method.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aChatroomId      The chatroom ID.
 *  @param aAnnouncement    The announcement of the chatroom.
 *  @param pError           The error information if the method fails: Error.
 *
 *  @result  The chatroom instance. See EMChatroom.
 */
- (EMChatroom *_Nullable )updateChatroomAnnouncementWithId:(NSString *_Nonnull)aChatroomId
                                              announcement:(NSString *_Nullable )aAnnouncement
                                                     error:(EMError **_Nullable )pError;

/**
 *  \~chinese
 *  修改聊天室公告。
 * 
 *  仅聊天室所有者和管理员可调用此方法。
 * 
 *  异步方法。
 *
 *  @param aChatroomId      聊天室 ID。
 *  @param aAnnouncement    群公告。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Changes the announcement of chatroom.
 * 
 *  Only the chatroom owner or admin can call this method.
 * 
 *  This is an asynchronous method.
 *
 *  @param aChatroomId      The chatroom ID.
 *  @param aAnnouncement    The announcement of the chatroom.
 *  @param aCompletionBlock The completion block, which contains the error message if the method call fails.
 *
 */
- (void)updateChatroomAnnouncementWithId:(NSString *_Nonnull)aChatroomId
                            announcement:(NSString *_Nullable)aAnnouncement
                              completion:(void (^_Nullable)(EMChatroom *_Nullable aChatroom, EMError *_Nullable aError))aCompletionBlock;
/**
 *  \~chinese
 *  设置多个聊天室自定义属性。
 * 
 *  @note
 *  该方法不允许覆盖其他成员设置的属性。
 * 
 *  异步方法。
 *
 *  @param roomId        聊天室 ID。
 *  @param attributes    聊天室自定义属性，为键值对（key-value）格式，key 为属性名称，value 为属性值。
 *  @param autoDelete    当前成员退出聊天室后是否自动删除该聊天室中其设置的所有聊天室自定义属性。
 * - （默认）`YES`:是。
 * - `NO`:否。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。如果有部分 Key 失败，会返回 `failureKeys map`，`value` 是失败原因。
 *
 *  \~english
 *  Sets custom attributes of the chat room.
 * 
 *  @note
 *  This method does not overwrite attributes set by others.
 * 
 *  This is an asynchronous method.
 *
 *  @param roomId      The chat room ID.
 *  @param attributes  The custom chat room attributes in key-value pairs, where the key is the attribute name and the value is the attribute value.
 *  @param autoDelete  Whether to delete the chat room attributes set by the member when he or she exits the chat room.
      * - (Default)`YES`: Yes;
      * - `NO`: No.
 *  @param aCompletionBlock The completion block, which contains the error message if the method call fails. If certain attribute keys fail to be added, the SDK returns `failureKeys map` in key-value format, where the key is the attribute key, and the value is the reason for the failure.
 *
 */
- (void)setChatroomAttributes:(NSString *_Nonnull)roomId attributes:(NSDictionary<NSString*,NSString*> *_Nonnull)keyValues autoDelete:(BOOL)autoDelete completionBlock:(void (^_Nullable)(EMError *_Nullable aError,NSDictionary<NSString*,EMError*> *_Nullable failureKeys))completionBlock ;
/**
 *  \~chinese
 *  设置聊天室单个自定义属性。
 * 
 *  @note
 *  该方法不允许覆盖其他成员设置的属性。
 * 
 *  异步方法。
 *
 *  @param roomId      聊天室 ID。
 *  @param key         聊天室属性 key，指定属性名。属性名不能超过 128 字符。每个聊天室最多可有 100 个属性。Key 支持以下字符集：
 * • 26 个小写英文字母 a-z；
 * • 26 个大写英文字母 A-Z；
 * • 10 个数字 0-9；
 * • “_”, “-”, “.”。
 *  @param value       聊天室属性值。每个属性值不超过 4096 字符，每个应用的聊天室属性总大小不能超过 10 GB。
 *  @param autoDelete  成员离开聊天室后是否自动删除该聊天室中其设置的所有聊天室自定义属性。
 * - （默认）`YES`:是。
 * - `NO`:否。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。如果有部分 Key 失败，会返回 `failureKeys map`，`value` 是失败原因。
 *
 *  \~english
 *  Sets a custom chat room attribute.
 * 
 *  @note
 *  This method does not overwrite attributes set by others.
 * 
 *  This is an asynchronous method.
 *
 *  @param roomId    The chat room ID.
 *  @param key       The chat room attribute key that specifies the attribute name. The attribute name can contain 128 characters at most. 
	 *               A chat room can have a maximum of 100 custom attributes. The following character sets are supported:
      * - 26 lowercase English letters (a-z)
      * - 26 uppercase English letters (A-Z)
      * - 10 numbers (0-9)
      * - "_", "-", "."
 *  @param value     The chat room attribute value. The attribute value can contain a maximum of 4096 characters. The total length of custom chat room attributes cannot exceed 10 GB for each app.
 *  @param autoDelete  Whether to delete the custom chat room attributes set by the member when he or she exits the chat room.
      * - (Default)`YES`: Yes;
      * - `NO`: No.
 *  @param aCompletionBlock The completion block, which contains the error message if the method call fails. If certain attribute keys fail to be added, the SDK returns `failureKeys map` in key-value format, where the key is the attribute key, and the value is the reason for the failure.
 *
 */
- (void)setChatroomAttribute:(NSString *_Nonnull)roomId key:(NSString *_Nonnull)key value:(NSString *_Nonnull)value autoDelete:(BOOL)autoDelete completionBlock:(void (^_Nullable)(EMError *_Nullable aError))completionBlock;
/**
 *  \~chinese
 *  强制设置多个聊天室自定义属性。
 *
 *  @note
 *  该方法可覆盖其他成员已设置的自定义属性。
 * 
 *  异步方法。
 *
 *  @param roomId      聊天室 ID。
 *  @param attributes    聊天室自定义属性，为键值对（key-value）格式，key 为属性名称，value 为属性值。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。如果有部分 Key 失败，会返回 `failureKeys map`，`value` 是失败原因。
 *  \~english
 *  Sets custom chat room attributes forcibly.
 * 
 *  @note
 *  This method overwrites attributes set by others.
 * 
 *  This is an asynchronous method.
 *
 *  @param roomId      The chat room ID.
 *  @param attributes    The custom chat room attributes in key-value pairs, where the key is the attribute name and the value is the attribute value.
 *  @param aCompletionBlock The completion block, which contains the error message if the method call fails. If certain attribute keys fail to be added, the SDK returns `failureKeys map` in key-value format, where the key is the attribute key, and the value is the reason for the failure.
 *
 */
- (void)setChatroomAttributesForced:(NSString *_Nonnull)roomId attributes:(NSDictionary<NSString*,NSString*> *_Nonnull)keyValues autoDelete:(BOOL)autoDelete completionBlock:(void (^_Nullable)(EMError *_Nullable aError,NSDictionary<NSString*,EMError*> *_Nullable failureKeys))completionBlock;

/**
 *  \~chinese
 *  强制设置单个聊天室自定义属性。
 * 
 *  @note
 *  该方法可覆盖其他成员已设置的自定义属性。
 *
 *  异步方法。
 *
 *  @param roomId      聊天室 ID。
 *  @param key         聊天室属性 Key。属性名不能超过 128 字符。每个聊天室最多可有 100 个属性。Key 支持以下字符集：
 * - 26 个小写英文字母 a-z；
 * - 26 个大写英文字母 A-Z；
 * - 10 个数字 0-9；
 * - “_”, “-”, “.”。
 *  @param value       聊天室属性 value，属性值。每个属性值不超过 4096 字符，每个应用的聊天室属性总大小不能超过 10 GB。
 *  @param autoDelete  成员离开聊天室后是否自动删除该聊天室中其设置的所有聊天室自定义属性。
 * - （默认）`YES`:是。
 * - `NO`:否。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。如果该方法调用失败，会包含调用失败的原因。如果有部分 Key 失败，会返回 `failureKeys map`，`value` 是失败原因。
 *
 *  \~english
 *  Sets a custom chat room attribute forcibly.
 * 
 *  @note
 *  This method overwrites attributes set by others.
 * 
 *  This is an asynchronous method.
 *
 *  @param roomId      The chat room ID.
 *  @param key         The chat room attribute key that specifies the attribute name. The attribute name can contain 128 characters at most. 
 *                 A chat room can have a maximum of 100 custom attributes. The following character sets are supported:
 * - 26 lowercase English letters (a-z)
 * - 26 uppercase English letters (A-Z)
 * - 10 numbers (0-9)
 * - "_", "-", "."
 *  @param value       The attribute value to set. A single Value can not exceed 4096 characters. The total attribute can not exceed 10 GB.
 *  @param autoDelete  Whether to delete the chat room attributes set by the member when he or she exits the chat room.
 * - (Default)`YES`: Yes;
 * - `NO`: No.
 *  @param aCompletionBlock The completion block, which contains the error message if the method call fails. If certain attribute keys fail to be added, the SDK returns `failureKeys map` in key-value format, where the key is the attribute key, and the value is the reason for the failure.
 *
 */
- (void)setChatroomAttributeForced:(NSString *_Nonnull)roomId key:(NSString *_Nonnull)key value:(NSString *_Nonnull)value autoDelete:(BOOL)autoDelete completionBlock:(void (^_Nullable)(EMError *_Nullable aError))completionBlock;

/**
 *  \~chinese
 *  删除多个聊天室自定义属性。
 * 
 *  @note
 *  该方法不删除其他成员设置的属性。
 * 
 *  异步方法。
 *
 *  @param aChatroomId      聊天室 ID。
 *  @param attributes       要删除的聊天室自定义属性的 key 列表。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。如果该方法调用失败，会包含调用失败的原因。如果有部分 Key 失败，会返回 `failureKeys map`，`value` 是失败原因。
 *
 *  \~english
 *  Removes custom chat room attributes.
 * 
 *  @note
 *  This method does not remove attributes set by other members.
 * 
 *  This is an asynchronous method.
 *
 *  @param aChatroomId      The chat room ID.
 *  @param attributes       The keys of the chat room attributes to remove. 
 *  @param aCompletionBlock The completion block, which contains the error message if the method call fails. If certain attribute keys fail to be added, the SDK returns `failureKeys map` in key-value format, where the key is the attribute key, and the value is the reason for the failure.
 *
 */
- (void)removeChatroomAttributes:(NSString *_Nonnull)roomId attributes:(NSArray <__kindof NSString*> * _Nonnull)keyValues completionBlock:(void (^_Nullable)(EMError *_Nullable aError,NSDictionary<NSString*,EMError*> *_Nullable failureKeys))completionBlock;
/**
 *  \~chinese
 *  删除单个聊天室自定义属性。
 * 
 *  @note
 *  该方法不删除其他成员设置的属性。
 * 
 *  异步方法。
 *
 *  @param aChatroomId      聊天室 ID。
 *  @param key              要删除聊天室自定义属性键值对的 key。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。如果有部分 Key 失败，会返回 `failureKeys map`，`value` 是失败原因。
 *
 *  \~english
 *  Removes a custom chat room attribute.
 * 
 *  @note
 *  This method does not remove attributes set by other members.
 * 
 *  This is an asynchronous method.
 *
 *  @param aChatroomId      The chat room ID.
 *  @param key              The key of the chat room attribute to remove. 
 *  @param aCompletionBlock The completion block, which contains the error message if the method call fails. If certain attribute keys fail to be added, the SDK returns `failureKeys map` in key-value format, where the key is the attribute key, and the value is the reason for the failure.
 *
 */
- (void)removeChatroomAttribute:(NSString *_Nonnull)roomId key:(NSString * _Nonnull)key completionBlock:(void (^_Nullable)(EMError *_Nullable aError))completionBlock;
/**
 *  \~chinese
 *  强制删除多个聊天室自定义属性。
 * 
 *  @note
 *  该方法支持删除其他成员设置的属性。
 * 
 *  异步方法。
 *
 *  @param aChatroomId      聊天室 ID。
 *  @param keyValues        要删除聊天室自定义属性的 key 数组。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Removes custom chat room attributes forcibly.
 * 
 *  @note
 *  This method removes attributes set by other members.
 * 
 *  This is an asynchronous method.
 *
 *  @param aChatroomId      The chat room ID.
 *  @param keyValues        The array of chat room attribute keys. 
 *  @param aCompletionBlock The completion block, which contains the error message if the method call fails.
 *
 */
- (void)removeChatroomAttributesForced:(NSString *_Nonnull)roomId attributes:(NSArray <__kindof NSString*> * _Nonnull)keyValues completionBlock:(void (^_Nullable)(EMError *_Nullable aError,NSDictionary<NSString*,EMError*> *_Nullable failureKeys))completionBlock;

/**
 *  \~chinese
 *  强制删除聊天室自定义属性。
 * 
 *  @note
 *  该方法支持删除其他成员设置的属性。
 * 
 *  异步方法。
 *
 *  @param aChatroomId      聊天室 ID。
 *  @param key              要删除聊天室自定义属性键值对的 key。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。如果有部分 Key 失败，会返回 `failureKeys map`，`value` 是失败原因。
 *
 *  \~english
 *  Removes custom chat room attributes forcibly.
 * 
 *  @note
 *  This method removes attributes set by other members.
 * 
 *  This is an asynchronous method.
 *
 *  @param aChatroomId      The chat room ID.
 *  @param key              The keys of the custom chat room attributes to remove.
 *  @param aCompletionBlock The completion block, which contains the error message if the method call fails. If certain attribute keys fail to be added, the SDK returns `failureKeys map` in key-value format, where the key is the attribute key and the value is the reason for the failure.
 *
 */
- (void)removeChatroomAttributeForced:(NSString *_Nonnull)roomId key:(NSString * _Nonnull)key completionBlock:(void (^_Nullable)(EMError *_Nullable aError))completionBlock;
/**
 *  \~chinese
 *  获取所有聊天室属性。
 *  异步方法。
 *
 *  @param roomId      聊天室 ID。
 *  @param keys      聊天室的属性keys。传nil会返回全部
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因，成功返回所有键值对。
 *
 *  \~english
 *  Fetch the properties of chatroom form sever.
 *  This is an asynchronous method.
 *
 *  @param roomId      The chatroom ID.
 *  @param keys      Chat room attribute keys.Empty callback all.
 *  @param aCompletionBlock The completion block, which contains keyValues and the error message if the method call fails.
 *
 */
- (void)fetchChatroomAttributes:(NSString *_Nonnull)roomId keys:(NSArray <__kindof NSString *> * _Nullable)keys completion:(void (^_Nullable)(EMError *_Nullable aError,NSDictionary<NSString*,NSString*> *_Nullable properties ))completionBlock;
/**
 *  \~chinese
 *  获取所有聊天室属性。
 *  异步方法。
 *
 *  @param roomId      聊天室 ID。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因，成功返回所有键值对。
 *
 *  \~english
 *  Fetch the properties of chatroom form sever.
 *  This is an asynchronous method.
 *
 *  @param roomId      The chatroom ID.
 *  @param aCompletionBlock The completion block, which contains keyValues and the error message if the method call fails.
 *
 */
- (void)fetchChatroomAllAttributes:(NSString * _Nonnull)roomId completion:(void (^ _Nullable)(EMError * _Nullable error,NSDictionary<NSString*,NSString*> * _Nullable properties))completionBlock;

#pragma mark - EM_DEPRECATED_IOS 3.3.0

/**
 *  \~chinese
 *  获取聊天室详情。
 * 
 *  已废弃，请用 {@link IEMChatroomManager getChatroomSpecificationFromServerWithId:error:} 代替。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param aChatroomId           聊天室 ID。
 *  @param aIncludeMembersList   是否获取成员列表，为 YES 时，一次性返回 200 个以内成员。
 *  @param pError                错误信息。
 *
 *  @result 聊天室实例，详见 EMChatroom。
 *
 *  \~english
 *  Fetches the chatroom's specification.
 * 
 *  Deprecated, please use  {@link IEMChatroomManager getChatroomSpecificationFromServerWithId:error:}  instead.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aChatroomId           The chatroom ID.
 *  @param aIncludeMembersList   Whether to get the member list. If you set the parameter as YES, it will return no more than 200 members. 
 *  @param pError                The error information if the method fails: Error.
 *
 *  @result The chatroom instance. See EMChatroom.
 */
- (EMChatroom *)fetchChatroomInfo:(NSString *)aChatroomId
               includeMembersList:(BOOL)aIncludeMembersList
                            error:(EMError **)pError EM_DEPRECATED_IOS(3_1_0, 3_3_0, "Use -IEMChatroomManager getChatroomSpecificationFromServerWithId:error: instead");

/**
 *  \~chinese
 *  获取聊天室详情。
 * 
 *  已废弃，请用 {@link IEMChatroomManager getChatroomSpecificationFromServerWithId:completion:} 代替。
 *
 *  @param aChatroomId           聊天室 ID。
 *  @param aIncludeMembersList   是否获取成员列表，为 YES 时，返回 200 个成员
 *  @param aCompletionBlock      该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Fetches chat room specifications.
 * 
 *  Deprecated, please use  {@link IEMChatroomManager getChatroomSpecificationFromServerWithId:completion:}  instead.
 *
 *  @param aChatroomId           The chatroom ID.
 *  @param aIncludeMembersList   Whether to get the member list. If you set the parameter as YES, it will return 200 members.
 *  @param aCompletionBlock      The completion block, which contains the error message if the method call fails.
 *
 */
- (void)getChatroomSpecificationFromServerByID:(NSString *)aChatroomId
                            includeMembersList:(BOOL)aIncludeMembersList
                                    completion:(void (^)(EMChatroom *aChatroom, EMError *aError))aCompletionBlock EM_DEPRECATED_IOS(3_1_0, 3_3_0, "Use -IEMChatroomManager getChatroomSpecificationFromServerWithId:completion: instead");

#pragma mark - EM_DEPRECATED_IOS 3.2.3

/**
 *  \~chinese
 *  添加回调代理。
 *
 *  已废弃，请用 {@link IEMChatroomManager addDelegate:delegateQueue:} 代替。
 * 
 *  @param aDelegate  要添加的代理。
 *
 *  \~english
 *  Adds delegate.
 * 
 *  Deprecated, please use  {@link IEMChatroomManager addDelegate:delegateQueue:}  instead.
 *
 *  @param aDelegate  The delegate you want to add.
 */
- (void)addDelegate:(id<EMChatroomManagerDelegate>)aDelegate EM_DEPRECATED_IOS(3_1_0, 3_2_2, "Use -IEMChatroomManager addDelegate:delegateQueue: instead");

#pragma mark - EM_DEPRECATED_IOS < 3.2.3

/**
 *  \~chinese
 *  从服务器获取所有的聊天室。
 *
 *  已废弃，请用 {@link getChatroomsFromServerWithPage} 代替。
 * 
 *  同步方法，会阻塞当前线程。
 *
 *  @param pError   出错信息。
 *
 *  @result 聊天室列表，详见 <EMChatroom>。
 *
 *  \~english
 *  Gets all the chatrooms from the server.
 *
 *  Deprecated, please use  {@link getChatroomsFromServerWithPage}  instead.
 * 
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param pError   The error information if the method fails: Error.
 *
 *  @result         The chat room list.
 */
- (NSArray *)getAllChatroomsFromServerWithError:(EMError **)pError __deprecated_msg("Use -getChatroomsFromServerWithPage instead");

/**
 *  \~chinese
 *  从服务器获取所有的聊天室。
 * 
 *  已废弃，请用 {@link getChatroomsFromServerWithPage} 代替。
 *
 *  @param aCompletionBlock      该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Gets all the chatrooms from server.
 * 
 *  Deprecated, please use  {@link getChatroomsFromServerWithPage}  instead.
 *
 *  @param aCompletionBlock     The completion block, which contains the error message if the method call fails.
 *
 */
- (void)getAllChatroomsFromServerWithCompletion:(void (^)(NSArray *aList, EMError *aError))aCompletionBlock __deprecated_msg("Use -getChatroomsFromServerWithPage instead");

/**
 *  \~chinese
 *  从服务器获取所有的聊天室。
 * 
 *  已废弃，请用 {@link getAllChatroomsFromServerWithCompletion} 代替。
 *
 *  @param aSuccessBlock         成功的回调。
 *  @param aFailureBlock         失败的回调。
 *
 *  \~english
 *  Gets all the chatrooms from the server.
 *
 *  Deprecated, please use  {@link getAllChatroomsFromServerWithCompletion}  instead.
 * 
 *  @param aSuccessBlock         The callback block of success.
 *  @param aFailureBlock         The callback block of failure, which contains the error message if the method fails.
 *
 */
- (void)asyncGetAllChatroomsFromServer:(void (^)(NSArray *aList))aSuccessBlock
                               failure:(void (^)(EMError *aError))aFailureBlock __deprecated_msg("Use -getAllChatroomsFromServerWithCompletion: instead");

/**
 *  \~chinese
 *  加入一个聊天室。
 * 
 *  已废弃，请用 {@link joinChatroom:completion:} 代替。
 *
 *  @param aChatroomId      聊天室的 ID。
 *  @param aSuccessBlock    成功的回调。
 *  @param aFailureBlock    失败的回调。
 *
 *
 *  \~english
 *  Joins a chatroom.
 * 
 *  Deprecated, please use  {@link joinChatroom:completion:}  instead.
 *
 *  @param aChatroomId      The chatroom ID.
 *  @param aSuccessBlock    The callback block of success.
 *  @param aFailureBlock    The callback block of failure, which contains the error message if the method fails.
 *
 */
- (void)asyncJoinChatroom:(NSString *)aChatroomId
                  success:(void (^)(EMChatroom *aRoom))aSuccessBlock
                  failure:(void (^)(EMError *aError))aFailureBlock __deprecated_msg("Use -joinChatroom:completion: instead");

/**
 *  \~chinese
 *  退出聊天室。
 * 
 *  已废弃，请用 {@link leaveChatroom:completion:} 代替。
 *
 *  @param aChatroomId          聊天室 ID。
 *  @param aSuccessBlock        成功的回调。
 *  @param aFailureBlock        失败的回调。
 *
 *  @result 退出的聊天室。
 *
 *  \~english
 *  Leaves a chatroom.
 * 
 *  Deprecated, please use  {@link leaveChatroom:completion:}  instead.
 *
 *  @param aChatroomId      The chatroom ID.
 *  @param aSuccessBlock    The callback block of success.
 *  @param aFailureBlock    The callback block of failure, which contains the error message if the method fails.
 *
 *  @result Leaved chatroom
 */
- (void)asyncLeaveChatroom:(NSString *)aChatroomId
                   success:(void (^)(EMChatroom *aRoom))aSuccessBlock
                   failure:(void (^)(EMError *aError))aFailureBlock __deprecated_msg("Use -leaveChatroom:completion: instead");

/**
 *  \~chinese
 *  获取聊天室详情。
 * 
 *  已废弃，请用 {@link getChatroomSpecificationFromServerByID:includeMembersList:completion:} 代替。
 *
 *  @param aChatroomId           聊天室 ID。
 *  @param aIncludeMembersList   是否获取成员列表。
 *  @param aSuccessBlock         成功的回调。
 *  @param aFailureBlock         失败的回调。
 *
 *  \~english
 *  Fetches chatroom's specification.
 * 
 *  Deprecated, please use  {@link getChatroomSpecificationFromServerByID:includeMembersList:completion:}  instead.
 *
 *  @param aChatroomId           The chatroom ID.
 *  @param aIncludeMembersList   Whether to get member list.
 *  @param aSuccessBlock         The callback block of success.
 *  @param aFailureBlock         The callback block of failure, which contains the error message if the method fails.
 *
 */
- (void)asyncFetchChatroomInfo:(NSString *)aChatroomId
            includeMembersList:(BOOL)aIncludeMembersList
                       success:(void (^)(EMChatroom *aChatroom))aSuccessBlock
                       failure:(void (^)(EMError *aError))aFailureBlock __deprecated_msg("Use -getChatroomSpecificationFromServerByID:includeMembersList:completion: instead");
@end
