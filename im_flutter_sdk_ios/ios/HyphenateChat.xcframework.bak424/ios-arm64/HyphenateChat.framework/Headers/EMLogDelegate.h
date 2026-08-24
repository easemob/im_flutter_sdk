//
//  EMLogDelegate.h
//  HyphenateChat
//
//  Created by li xiaoming on 2022/7/29.
//  Copyright © 2022 easemob.com. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  \~chinese
 *  日志回调相关协议
 *
 *  \~english
 *  The delegate protocol of log callback.
 */
@protocol EMLogDelegate <NSObject>
@optional

/*!
 *  \~chinese
 *  sdk 日志输出回调。
 *
 *  @param log    输出的日志。
 *
 *  \~english
 *  Occurs when the sdk output logs.
 *
 *  @param log  The log to output.
 */
- (void) logDidOutput:(NSString* _Nonnull)log;

@end
