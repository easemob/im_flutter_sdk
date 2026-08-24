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

@end
