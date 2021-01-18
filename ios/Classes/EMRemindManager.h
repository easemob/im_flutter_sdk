//
//  EMRemindManager.h
//  EMiOSDemo
//
//  Created by 杜洁鹏 on 2019/8/21.
//  Copyright © 2019 杜洁鹏. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Hyphenate/Hyphenate.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMRemindManager : NSObject
// 消息提醒
+ (void)remindMessage:(EMMessage *)aMessage;

// app角标更新
+ (void)updateApplicationIconBadgeNumber:(NSInteger)aBadgeNumber;

// 播放等待铃声 (默认从听筒播放)
+ (void)playWattingSound;

// 播放铃声 (默认从扬声器播放)
+ (void)playRing:(BOOL)playVibration;

// 停止铃声
+ (void)stopSound;

// 振动
+ (void)playVibration;
@end

NS_ASSUME_NONNULL_END
