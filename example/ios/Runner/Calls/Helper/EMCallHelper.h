//
//  EMCallHelper.h
//  Runner
//
//  Created by 杜洁鹏 on 2021/1/21.
//  Copyright © 2021 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Hyphenate/Hyphenate.h>
NS_ASSUME_NONNULL_BEGIN

@interface EMCallHelper : NSObject
#pragma mark - ChatRoom

+ (EMCallOptions *)callOptionsDictionaryToEMCallOptions:(NSDictionary *)options;

#pragma mark - CallConference
+ (NSDictionary *)callConferenceToDictionary:(EMCallConference *)aCall;
@end

NS_ASSUME_NONNULL_END
