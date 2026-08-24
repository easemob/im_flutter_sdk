//
//  NSObject+Coding.h
//  chat-uikit
//
//  Created by 朱继超 on 2022/4/2.
//

#import <Foundation/Foundation.h>

@interface NSObject (Coding)

- (void)ease_decodeWithCoder:(NSCoder *)decoder;

- (void)ease_encodeWithCoder:(NSCoder *)code;

- (id)ease_copyWithZone:(NSZone *)zone;

- (id)ease_mutableCopyWithZone:(NSZone *)zone;

@end

