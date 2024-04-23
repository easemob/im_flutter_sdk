//
//  IEMPushManager.h
//  HyphenateSDK
//
//  Created by 杜洁鹏 on 2020/10/26.
//  Copyright © 2020 easemob.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMCommonDefs.h"
#import "EMPushOptions.h"
#import "EMError.h"
#import "EMCursorResult.h"
#import "EMSilentModeResult.h"

NS_ASSUME_NONNULL_BEGIN
/**
 *  \~chinese
 *  @header IEMPushManager.h
 *  @abstract 推送相关的管理协议类。
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header IEMPushManager.h
 *  @abstract The push related management protocol class.
 *  @author Hyphenate
 *  @version 3.00
 */

@protocol IEMPushManager <NSObject>

/**
 *  \~chinese
 *  消息推送配置选项。
 *
 *  \~english
 *  The message push configuration options.
 *
 */
@property (nonatomic, strong, readonly) EMPushOptions *_Nullable pushOptions;

/**
 *  \~chinese
 *  从内存中获取屏蔽了推送的用户 ID 列表。
 *  已废弃，使用getSilentModeForConversations:completion:精确批量获取代替。
 *
 *  \~english
 *  Gets the list of user ID which have blocked the push notification.
 *  Deprecated. Please use  -getSilentModeForConversations:completion: instead.
 */
@property (nonatomic, strong, readonly) NSArray *noPushUIds
EM_DEPRECATED_IOS(3_8_4, 3_9_1, "Use -getSilentModeForConversations:completion: instead");

/**
 *  \~chinese
 *  从内存中获取屏蔽了推送的群组 ID 列表。
 *  已废弃，使用getSilentModeForConversations:completion:精确获取批量会话推送设置。
 *
 *
 *  \~english
 *  Gets the list of groups which have blocked the push notification.
 *  Deprecated. Please use  -getSilentModeForConversations:completion: instead.
 */
@property (nonatomic, strong, readonly) NSArray *noPushGroups
EM_DEPRECATED_IOS(3_7_4, 3_9_1, "Use -getSilentModeForConversations:completion: instead");

/**
 *  \~chinese
 *  开启离线推送。
 *  已废弃，使用 -setSilentModeForAll:completion: 代替。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @result  错误信息，详见 EMError。
 *
 *  \~english
 *  Turns on the push notification.
 *  Deprecated. Please use  -setSilentModeForAll:completion:  instead.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @result   The error information if the method fails: Error.
 */
- (EMError *)enableOfflinePush
EM_DEPRECATED_IOS(3_7_3, 3_9_1, "Use -setSilentModeForAll:completion: instead");


/**
 *  \~chinese
 *  关闭离线推送。
 *  已废弃，使用 -setSilentModeForAll:completion: 代替。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param aStartHour    开始时间。
 *  @param aEndHour      结束时间。
 *
 *  @result  错误信息，详见 EMError。
 *
 *  \~english
 *  Turns off the push notification.
 *  Deprecated. Please use  -setSilentModeForAll:completion:  instead.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aStartHour    The begin time.
 *  @param aEndHour      The end time.
 *
 *  @result     The error information if the method fails: Error.
 */

- (EMError *)disableOfflinePushStart:(int)aStartHour end:(int)aEndHour
EM_DEPRECATED_IOS(3_7_3, 3_9_1, "Use -setSilentModeForAll:completion: instead");

/**
 *  \~chinese
 *  设置群组是否接收推送。
 *  已废弃，使用 -setSilentModeForConversation:conversationType: params:completion:代替。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param aGroupIds    群组 ID。
 *  @param disable      是否接收推送。
 *
 *  @result      错误信息，详见 EMError。
 *
 *  \~english
 *  Sets wether to turn on or turn off the push notification.
 *  Deprecated. Please use  -setSilentModeForConversation:conversationType: params:completion:  instead.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aGroupIds    The group IDs.
 *  @param disable      Turn off.
 *
 *  @result    The error information if the method fails: Error.
 */
- (EMError *)updatePushServiceForGroups:(NSArray *)aGroupIds
                            disablePush:(BOOL)disable
EM_DEPRECATED_IOS(3_7_4, 3_9_1, "Use -setSilentModeForConversation:conversationType:params:completion: instead");


/**
 *  \~chinese
 *  设置群组是否接收推送。
 *  已废弃，使用 -setSilentModeForConversation:conversationType: params:completion:代替。
 * 
 *  异步方法。
 *
 *  @param aGroupIds            群组 ID。
 *  @param disable              是否接收推送。
 *  @param aCompletionBlock     该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Sets the display style for the push notification.
 *  Deprecated. Please use  -setSilentModeForConversation:conversationType: params:completion:  instead.
 * 
 *  This is an asynchronous method.
 *
 *  @param aGroupIds            The group IDs.
 *  @param disable              Turn off.
 *  @param aCompletionBlock     The completion block, which contains the error message if the method fails..
 */
- (void)updatePushServiceForGroups:(NSArray *)aGroupIds
                       disablePush:(BOOL)disable
                        completion:(nonnull void (^)(EMError * aError))aCompletionBlock
EM_DEPRECATED_IOS(3_7_4, 3_9_1, "Use -setSilentModeForConversation:conversationType: params:completion: instead");

/**
 *  \~chinese
 *  设置是否接收联系人消息推送。
 *  已废弃，使用 -setSilentModeForConversation:conversationType: params:completion:代替。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param aUIds        用户 ID。
 *  @param disable      是否不接收推送。默认值是 NO，表示接收推送；设置 YES，表示不接收推送。
 *
 *  @result             错误信息。
 *
 *  \~english
 *  Sets whether to receive push notification of the specific contacts.
 *  Deprecated. Please use  -setSilentModeForConversation:conversationType: params:completion:  instead.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aUIds        The user IDs of the contacts.
 *  @param disable      Whether to receive the push notification.// to do
 *
 *  @result    The error information if the method fails: Error.
 */
- (EMError *)updatePushServiceForUsers:(NSArray *)aUIds
                            disablePush:(BOOL)disable
EM_DEPRECATED_IOS(3_8_4, 3_9_1, "Use -setSilentModeForConversation:conversationType: params:completion: instead");

 /**
  *  \~chinese
  *  设置是否接收联系人消息推送。
  *  已废弃，使用 -setSilentModeForConversation:conversationType: params:completion:代替。
  * 
  *  异步方法。
  *
  *  @param aUIds                用户 ID。
  *  @param disable              是否不接收推送。默认值是 NO，表示接收推送；设置 YES，表示不接收推送。
  *  @param aCompletionBlock     该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
  *
  *  \~english
  *  Sets whether to receive the push notification of the contacts.
  *  Deprecated. Please use  -setSilentModeForConversation:conversationType: params:completion:  instead.
  * 
  *  This is an asynchronous method.
  *
  *  @param aUIds                The user IDs of the contacts.
  *  @param disable              Whether to receive the push notification.
  *  @param aCompletionBlock     The completion block, which contains the error message if the method fails.
  */
- (void)updatePushServiceForUsers:(NSArray *)aUIds
                        disablePush:(BOOL)disable
                        completion:(nonnull void (^)(EMError * aError))aCompletionBlock
EM_DEPRECATED_IOS(3_8_4, 3_9_1, "Use -setSilentModeForConversation:conversationType: params:completion: instead");

/**
 *  \~chinese
 *  设置推送消息显示的样式。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param pushDisplayStyle  要设置的推送样式。
 *
 *  @result  错误信息，详见 EMError。
 *
 *  \~english
 *  Sets the display style for the push notification.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param pushDisplayStyle  The display style of the push notification.
 *
 *  @result    The error information if the method fails: Error.
 */
- (EMError *)updatePushDisplayStyle:(EMPushDisplayStyle)pushDisplayStyle;


/**
 *  \~chinese
 *  设置推送的显示名。
 * 
 *  异步方法。
 *
 *  @param pushDisplayStyle     推送显示样式。
 *  @param aCompletionBlock     该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Sets the display style for the push notification.
 * 
 *  This is an asynchronous method.
 *
 *  @param pushDisplayStyle     The display style of the push notification.
 *  @param aCompletionBlock     The completion block, which contains the error message if the method fails.
 */
- (void)updatePushDisplayStyle:(EMPushDisplayStyle)pushDisplayStyle
                    completion:(void (^ _Nullable)(EMError * _Nullable aError))aCompletionBlock;


/**
 *  \~chinese
 *  设置推送消息显示的昵称。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param aNickname  要设置的昵称。
 *
 *  @result  错误信息，详见 EMError。
 *
 *  \~english
 *  Sets the display name of the push notification.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param aNickname  The display name of the push notification.
 *
 *  @result    The error information if the method fails: Error.
 */
- (EMError *_Nullable )updatePushDisplayName:(NSString * _Nonnull)aDisplayName;

/**
 *  \~chinese
 *  设置推送的显示的昵称。
 * 
 *  异步方法。
 *
 *  @param aDisplayName     推送显示的昵称。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Sets the display name of the push notification.
 * 
 *  This is an asynchronous method.
 *
 *  @param aDisplayName     The display name of the push notification.
 *  @param aCompletionBlock The completion block, which contains the error message if the method fails.
 *
 */
- (void)updatePushDisplayName:(NSString * _Nonnull)aDisplayName
                   completion:(void (^_Nullable)(NSString * _Nullable aDisplayName, EMError * _Nullable aError))aCompletionBlock;



/**
 *  \~chinese
 *  从服务器获取推送属性。
 *
 *  同步方法，会阻塞当前线程。
 *
 *  @param pError  错误信息。
 *
 *  @result   推送属性，详见 EMPushOptions。
 *
 *  \~english
 *  Gets the push options from the server.
 *
 *  This is a synchronous method and blocks the current thread.
 *
 *  @param pError  The error information if the method fails: Error.
 *
 *  @result    The push options. See EMPushOptions.
 */
- (EMPushOptions *_Nullable )getPushOptionsFromServerWithError:(EMError *_Nullable *_Nullable)pError;

/**
 *  \~chinese
 *  从服务器获取推送属性。
 * 
 *  异步方法。
 *
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Gets the push options from the server.
 * 
 *  This is an asynchronous method.
 *
 *  @param aCompletionBlock The completion block, which contains the error message if the method fails.
 */
- (void)getPushNotificationOptionsFromServerWithCompletion:(void (^_Nullable )(EMPushOptions *_Nullable aOptions, EMError *_Nullable aError))aCompletionBlock;


/**
 *  \~chinese
 *  设置全局消息免打扰数据。
 *
 *  @param aParam 免打扰数据参数模型，详见EMSilentModeParam。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Set global silent mode  message data.
 *
 *  @param aParam Silent mode data parameter model ,See EMSilentModeParam.
 *  @param aCompletionBlock The completion block, which contains the error message if the method fails.
 *
 */
- (void)setSilentModeForAll:(EMSilentModeParam*_Nullable )aParam completion:(void (^_Nullable )(EMSilentModeResult *_Nullable aResult, EMError *_Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  获取全局消息免打扰数据。
 *
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Get global silent mode  message data.
 *
 *  @param aCompletionBlock The completion block, which contains the error message if the method fails.
 */
-(void)getSilentModeForAllWithCompletion:(void (^_Nullable )(EMSilentModeResult *_Nullable aResult, EMError *_Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  设置会话消息免打扰数据。
 *
 *  @param aConversationId 会话Id。
 *  @param aConversationType 会话类型。
 *  @param aParam 免打扰数据参数模型，详见EMSilentModeParam。
 *  @param aCompletionBlock
 *  该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Set conversation silent mode  message data.
 *
 *  @param aConversationId  The conversation Id.
 *  @param aConversationType  The conversation type.
 *  @param aParam Silent mode data parameter model ,See EMSilentModeParam.
 *  @param aCompletionBlock  The completion block, which contains the error message if the method fails.
 *
 */
- (void)setSilentModeForConversation:(NSString*_Nonnull)aConversationId
                    conversationType:(EMConversationType)aConversationType
                              params:(EMSilentModeParam*_Nullable )aParam
                          completion:(void (^_Nullable )(EMSilentModeResult *_Nullable aResult, EMError *_Nullable aError))aCompletionBlock;
/**
 *  \~chinese
 *  获取会话消息免打扰数据。
 *
 *  @param aConversationId 会话Id。
 *  @param aConversationType 会话类型。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Get conversation silent mode  message data.
 *
 *  @param aConversationId  The conversation Id.
 *  @param aConversationType  The conversation type.
 *  @param aCompletionBlock  The completion block, which contains the error message if the method fails.
 *
 *
 */
- (void)getSilentModeForConversation:(NSString*_Nonnull)aConversationId
                    conversationType:(EMConversationType)aConversationType
                          completion:(void (^_Nullable )(EMSilentModeResult *_Nullable aResult, EMError *_Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  清除会话离线推送消息提醒类型设置。
 *
 *  @param aConversationId 会话Id。
 *  @param aConversationType 会话类型。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Clear conversation  remind type for push messages.
 *
 *  @param aConversationId  The conversation Id.
 *  @param aConversationType  The conversation type.
 *  @param aCompletionBlock  The completion block, which contains the error message if the method fails.
 *
 *
 */
- (void)clearRemindTypeForConversation:(NSString*_Nonnull)aConversationId
                      conversationType:(EMConversationType)aConversationType
                            completion:(void (^_Nullable )(EMSilentModeResult *_Nullable aResult, EMError *_Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  获取多个会话免打扰数据设置。
 *  注意：一次最多20条数据。如果没设置过或者设置失效，则结果字典中不会返回该条数据
 *
 *  @param aConversationArray 会话数组。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Gets the silent mode data setting for multiple sessions.
 *  Notice:A maximum of 20 pieces of data at a time.If it is not set or set to expire , it will not be returned in the result dictionary
 *
 *  @param aConversationArray The conversations array。
 *  @param aCompletionBlock The completion block, which contains the error message if the method fails.
 *
 */
- (void)getSilentModeForConversations:(NSArray<EMConversation *>*_Nonnull)aConversationArray
                           completion:(void (^_Nullable )(NSDictionary<NSString*,EMSilentModeResult*>*_Nullable aResult, EMError *_Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  设置推送消息的翻译语言。
 *
 *  @param aLaguangeCode 翻译语言代码。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Set the translation language for push messages.
 *
 *  @param aLaguangeCode Translation language code.
 *  @param aCompletionBlock The completion block, which contains the error message if the method fails.
 *
 *
 */
- (void)setPreferredNotificationLanguage:(NSString*_Nullable)aLaguangeCode
                              completion:(void (^_Nullable )(EMError *_Nullable aError))aCompletionBlock;
/**
 *  \~chinese
 *  获取推送消息的翻译语言。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Get the translation language for push messages.
 *
 *  @param aCompletionBlock The completion block, which contains the error message if the method fails.
 *
 *
 */
- (void)getPreferredNotificationLanguageCompletion:(void (^_Nullable )(NSString *_Nullable aLaguangeCode,EMError *_Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  设置离线推送的推送模版。
 *
 *  @param aPushTemplateName 推送模版名称。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Set the push template for offline push.
 *
 *  @param aPushTemplateName push template name.
 *  @param aCompletionBlock The completion block, which contains the error message if the method fails.
 *
 *
 */
- (void)setPushTemplate:(NSString* _Nullable)aPushTemplateName
             completion:(void (^ _Nullable)(EMError *_Nullable aError))aCompletionBlock;
/**
 *  \~chinese
 *  获取设置的离线推送模版。
 *  @param aCompletionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *   Gets the offline push template for Settings.
 *
 *  @param aCompletionBlock The completion block, which contains the error message if the method fails.
 *
 *
 */
- (void)getPushTemplate:(void (^ _Nullable)(NSString *_Nullable aPushTemplateName, EMError *_Nullable aError))aCompletionBlock;



@end

NS_ASSUME_NONNULL_END
