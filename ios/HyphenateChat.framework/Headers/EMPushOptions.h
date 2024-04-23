/**
 *  \~chinese
 *  @header EMPushOptions.h
 *  @abstract 消息推送的设置选项。
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header EMPushOptions.h
 *  @abstract The setting options of Apple Push Notification.
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>
#import "EMCommonDefs.h"

#define kPushNickname @"nickname"
#define kPushDisplayStyle @"notification_display_style"
#define kPushNoDisturbing @"notification_no_disturbing"
#define kPushNoDisturbingStartH @"notification_no_disturbing_start"
#define kPushNoDisturbingStartM @"notification_no_disturbing_startM"
#define kPushNoDisturbingEndH @"notification_no_disturbing_end"
#define kPushNoDisturbingEndM @"notification_no_disturbing_endM"

/**
 *  \~chinese 
 *  推送消息的显示风格类型。
 *
 *  \~english 
 *  The display style of push message.
 */
typedef NS_ENUM(NSInteger, EMPushDisplayStyle) {
    EMPushDisplayStyleSimpleBanner = 0, /**
                                         *  \~chinese
                                         *  简单显示"您有一条新消息"。
                                         *
                                         *  \~english
                                         *  A simple banner that displays "You have a new message".
                                         */
    EMPushDisplayStyleMessageSummary,   /**
                                         *  \~chinese 
                                         *  显示消息内容。
                                         * 
                                         *  \~english 
                                         *  Displays the message's content.
                                         */
};

/**
 *  \~chinese 
 *  推送通知服务（APNs）的设置。
 *
 *  \~english 
 *  The options for Apple Push Notification service (APNs).
 */
@interface EMPushOptions : NSObject

/**
 *  \~chinese 
 *  推送消息显示的昵称。
 *
 *  \~english 
 *  The user's nickname to be displayed in the notification.
 */
@property (nonatomic, strong, readonly) NSString * _Nullable displayName;

/**
 *  \~chinese 
 *  推送消息显示的类型。
 *
 *  \~english 
 *  The display style of the notification.
 */
@property (nonatomic, readonly) EMPushDisplayStyle displayStyle;


/**
 *  \~chinese 
 *  消息推送免打扰开始时间，小时，暂时只支持整点（小时），24 小时制。
 *  已废弃，使用EMSilentModeResult的属性silentModeStartTime替代。
 *
 *  \~english 
 *  The no-disturbing mode start time (in hour).
 *  Deprecated. Please use EMSilentModeResult property silentModeStartTime instead.
 */
@property (nonatomic, readonly) NSInteger silentModeStart
EM_DEPRECATED_IOS(3_8_8, 3_9_1, "Use EMSilentModeResult property silentModeStartTime instead");

/**
 *  \~chinese 
 *  消息推送免打扰结束时间，小时，暂时只支持整点（小时）。
 *  已废弃，使用EMSilentModeResult的属性silentModeEndTime替代。
 *
 *  \~english 
 *  The no-disturbing mode end time (in hour).
 *  Deprecated. Please use EMSilentModeResult property silentModeEndTime instead.
 */
@property (nonatomic, readonly) NSInteger silentModeEnd
EM_DEPRECATED_IOS(3_8_8, 3_9_1, "Use EMSilentModeResult property silentModeEndTime instead");

/**
 *  \~chinese
 *  是否开启消息免打扰。
 *  已废弃，使用EMSilentModeResult的属性expireTimestamp和silentModetTime做判断。
 *
 *  \~english
 *  Whether to enable the Do Not Disturb mode. expireTimestamp
 *  Deprecated. Please use EMSilentModeResult property expireTimestamp and silentModeTime determine whether to enable
 */

@property (nonatomic, readonly) BOOL silentModeEnabled
EM_DEPRECATED_IOS(3_8_8, 3_9_1, "Use EMSilentModeResult property expireTimestamp and silentModeTime determine whether to enable");


#pragma mark - EM_DEPRECATED_IOS 3.8.8
/**
 *  \~chinese
 *  消息推送免打扰开始时间，小时，暂时只支持整点（小时）
 *
 *  \~english
 *  No disturbing mode start time (in hour)
 */
@property (nonatomic, readonly) NSInteger noDisturbingStartH
__deprecated_msg("Use silentModeStart instead");

/**
 *  \~chinese
 *  消息推送免打扰结束时间，小时，暂时只支持整点（小时）
 *
 *  \~english
 *  No disturbing mode end time (in hour)
 */
@property (nonatomic, readonly) NSInteger noDisturbingEndH
__deprecated_msg("Use silentModeEnd instead");

/**
 *  \~chinese
 *  是否开启消息免打扰
 *
 *  \~english
 *  Whether enable messages do not disturb
 */

@property (nonatomic, readonly) BOOL isNoDisturbEnable
__deprecated_msg("Use silentModeEnabled instead");




@end
