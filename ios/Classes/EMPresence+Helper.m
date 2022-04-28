//
//  EMPresence+Helper.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2022/4/27.
//

#import "EMPresence+Helper.h"

@implementation EMPresence (Helper)

- (nonnull NSDictionary *)toJson {
    NSMutableArray *details = [NSMutableArray array];
    for (id<EaseModeToJson> detail in self.statusDetails) {
        [details addObject:[detail toJson]];
    }
    return @{
        @"publisher": self.publisher,
        @"statusDetails": details,
        @"statusDescription": self.statusDescription,
        @"lastTime": @(self.lastTime),
        @"expirytime": @(self.expirytime)
    };
}

@end

@interface EMPresenceStatusDetail (Helper)  <EaseModeToJson>

@end


@implementation EMPresenceStatusDetail (Helper)

- (nonnull NSDictionary *)toJson {
    return @{
        @"device": self.device,
        @"statue": @(self.status)
    };
}

@end

