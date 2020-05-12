//
//  NSObject+Alert.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/2/22.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Alert)

- (void)showAlertWithMessage:(NSString *)aMsg;

- (void)showAlertWithTitle:(NSString *)aTitle
                   message:(NSString *)aMsg;

@end

NS_ASSUME_NONNULL_END
