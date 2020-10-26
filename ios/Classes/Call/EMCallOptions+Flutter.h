//
//  EMCallOptions+Flutter.h
//  Runner
//
//  Created by 杜洁鹏 on 2020/10/19.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

#import <Hyphenate/Hyphenate.h>
#import "EaseToFlutterJson.h"
NS_ASSUME_NONNULL_BEGIN

@interface EMCallOptions (Flutter) <EaseToFlutterJson>

+ (EMCallOptions *)fromJson:(NSDictionary *)aJson;
- (NSDictionary *)toJson;

@end

NS_ASSUME_NONNULL_END
