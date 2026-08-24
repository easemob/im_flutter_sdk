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
 *  从服务器获取所有会话免打扰。
 *
 *  @param completionBlock 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。回调`EMError`为空则可以调用`IEMChatManager#getAllConversations`方法重新获取会话列表刷新UI
 *
 *  \~english
 *  Get all conversations mute info from server.
 *
 *  @param completionBlock The method completes the callback called. If the method call fails, the reason for the failure will be included. If the callback `EMError` is empty, you can call the `IEMChatManager#getAllConversations` method to re-obtain the session list and refresh the UI..
 */
- (void)syncSilentModeConversationsFromServerCompletion:(void (^_Nullable )(EMError *_Nullable error))completionBlock;



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
