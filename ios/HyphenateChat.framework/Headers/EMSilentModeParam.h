//
//  EMSilentModeParam.h
//  HyphenateChat
//
//  Created by hxq on 2022/3/30.
//  Copyright © 2022 easemob.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSilentModeTime.h"

/**
 *  \~chinese
 *  免打扰设置的参数类型。
 *
 *  \~english
 *  Parameter type to no-disturbing mode.
 */
typedef NS_ENUM(NSInteger, EMSilentModeParamType) {
    EMSilentModeParamTypeRemindType = 0 , /*!
                                            *  \~chinese
                                            *  设置消息提醒类型
                                            *
                                            *  \~english
                                            * Set push remind type, Single chat not support.
                                            */
    EMSilentModeParamTypeDuration   , /*!
                                            *  \~chinese
                                            *  设置免打扰时间值。
                                            *
                                            *  \~english
                                            * Set silent message duraation.
                                            *
                                            */
    
    EMSilentModeParamTypeInterval,/*!
                                      *  \~chinese
                                      *  设置免打扰时间段 仅全局设置有效。
                                      *
                                      *  \~english
                                      * Set silent message time Interval.
                                      *
                                      */
   

};

/**
 *  \~chinese
 *  离线推送的提醒类型。
 *
 *  \~english
 *  The remind type of push message.
 */
typedef NS_ENUM(NSInteger, EMPushRemindType) {
    
    EMPushRemindTypeAll   , /*!
                                            *  \~chinese
                                            *  所有消息都提醒。
                                            *
                                            *  \~english
                                            * All messages are remind.
                                            */
    EMPushRemindTypeMentionOnly,/*!
                                      *  \~chinese
                                      *  只有@我的消息才提醒。
                                      *
                                      *  \~english
                                      * Only @me messages are remind.
                                      */
  
    EMPushRemindTypeNone,/*!
                               *  \~chinese
                               *  所有消息都不提醒。
                               *
                               *  \~english
                               * All messages are not remind.
                               */

} ;

/**
 *  \~chinese
 *  消息免打扰设置的参数设置类
 *
 *  \~english
 *  The silent message params object
 */
@interface EMSilentModeParam : NSObject
/**
 *  \~chinese
 *  消息免打扰设置的参数类型。
 *
 *  如果parmType 为EMSilentModeParamTypeRemindType时，只需设置remindType这个参数。
 *  如果parmType 为EMSilentModeParamTypeDuration时，只需设置silentModeDuration这个参数。
 *  如果parmType 为EMSilentModeParamTypeInterval时，只需设置silentModeStartTime和silentModeEndTime这两个参数。这两个参数的hours和minutes都为0时候表明关闭时间段设置
 *
 *  \~english
 *  Parameter type for silent messages.
 *
 *  If parmType is EMSilentModeParamTypeRemindType，only the remindType parameter is set.
 *  If parmType is EMSilentModeParamTypeDuration，only the silentModeDuration parameter is set.
 *  If parmType is EMSilentModeParamTypeInterval，only the silentModeStartTime and silentModeEndTime  parameters are set.
 */
@property (nonatomic, assign, readonly) EMSilentModeParamType paramType;
/**
 *  \~chinese
 *  消息免打扰时长（单位分钟）。
 *  为0表示关闭消息免打扰，最长只能设置7*24*60分钟。返回的是过期时间戳，关闭时候返回0。
 *
 *  \~english
 *  The duration for silent messages (in minute).
 *  A value of 0 indicates that silent messages is disabled，A maximum of 7 x 24 x 60 minutes can be set.An expiration timestamp is returned， disabled return 0.
 */
@property (nonatomic, assign) int silentModeDuration;
/**
 *  \~chinese
 *  离线推送提醒类型。
 *
 *  \~english
 *   The remind type for push messages.
 */
@property (nonatomic, assign) EMPushRemindType remindType;
/**
 *  \~chinese
 *  消息免打扰时段的开始时间。
 *
 *  注意：开始时间和结束时间必须都有才可以设置。当开始时间和结束时间的hours和minutes都为0时候表示关闭免打扰时间段
 *
 *  \~english
 *  The start time of interval type for silent messages.
 *
 *  Note: The start time and end time must be both specified.
 *
 */
@property (nonatomic, strong) EMSilentModeTime *_Nullable silentModeStartTime;
/**
 *  \~chinese
 *  消息免打扰时段的结束时间。
 *
 *  注意：开始时间和结束时间必须都有才可以设置。
 *
 *  \~english
 *  The end time of interval type for silent messages.
 *
 *  Note: The start time and end time must be both specified.
 *
 */
@property (nonatomic, strong) EMSilentModeTime *_Nullable silentModeEndTime;

- (instancetype _Nonnull)initWithParamType:(EMSilentModeParamType)aParamType;
@end

