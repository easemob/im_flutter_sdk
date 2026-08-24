//
//  EMLoginInfo.h
//  HyphenateChat
//
//  Created by 朱继超 on 2024/5/23.
//  Copyright © 2024 easemob.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMLoginExtensionInfo : NSObject

/**
 *  \~chinese
 *  设备名称。
 *
 *  \~english
 *  The device name.
 */
@property (nonatomic, copy) NSString *deviceName;

/**
 *  \~chinese
 *  设备 B 登录时，将设备 A 踢下线携带的扩展信息。
 *
 *  \~english
 * The extension information contained in the notification sent to device A that is kicked offline due to the user's login to device B.
 */
@property (nonatomic, copy) NSString *extensionInfo;

@end

NS_ASSUME_NONNULL_END
