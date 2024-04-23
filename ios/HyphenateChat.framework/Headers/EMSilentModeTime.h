//
//  EMSilentModeTime.h
//  HyphenateChat
//
//  Created by hxq on 2022/3/30.
//  Copyright © 2022 easemob.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  \~chinese
 *  消息免打扰的时间设置
 *
 *  \~english
 *  The silent message time object
 */
@interface EMSilentModeTime : NSObject <NSCopying,NSCoding>
/*!
 *  \~chinese
 *  时间点的小时数（0-24的数值）。
 *
 *  \~english
 *  The number of hours at a time point (The values of 0 to 24).
 *
 */
@property (nonatomic, assign, readonly) int hours;
/*!
 *  \~chinese
 *  时间点的分钟数（0-60的数值）。
 *
 *  \~english
 *  The number of minutes at a time point (The values of 0 to 60).
 *
 */
@property (nonatomic, assign, readonly) int minutes;

/**
 *  \~chinese
 *  初始化时间点。
 *
 *  @param aHours        小时。
 *  @param aMinutes  分钟。
 *
 *  @result 时间点实例。
 *
 *  \~english
 *  Initializes a time point instance.
 *
 *  @param aHours  The  time point hours.
 *  @param aMinutes  The  time point minutes.
 *
 *  @Result The  time point  instance.
 */
- (instancetype)initWithHours:(int)aHours minutes:(int)aMinutes;
@end

NS_ASSUME_NONNULL_END
