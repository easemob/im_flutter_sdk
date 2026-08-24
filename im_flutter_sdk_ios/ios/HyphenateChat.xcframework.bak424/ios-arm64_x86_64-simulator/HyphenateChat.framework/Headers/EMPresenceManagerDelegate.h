//
//  EMPresenceManagerDelegate.h
//  HyphenateChat
//
//  Created by lixiaoming on 2022/1/14.
//  Copyright © 2022 easemob.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMPresence.h"

/*!
 *  \~chinese
 *  在线状态相关代理协议，定义了在线状态变更回调。
 *
 *  \~english
 *  The delegate protocol that defines presence callbacks.
 */
@protocol EMPresenceManagerDelegate <NSObject>
@optional

/*!
 *  \~chinese
 *  被订阅用户的在线状态变更回调。
 *
 *  @param presences    用户新的在线状态。
 *
 *  \~english
 *  Occurs when the presence state of a subscribed user changes.
 *
 *  @param presences The new presence state of a subscribed user.
 */
- (void) presenceStatusDidChanged:(NSArray<EMPresence*>* _Nonnull)presences;

@end
