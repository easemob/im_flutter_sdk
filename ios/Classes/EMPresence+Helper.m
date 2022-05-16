//
//  EMPresence+Helper.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2022/4/27.
//

#import "EMPresence+Helper.h"

@implementation EMPresence (Helper)

- (nonnull NSDictionary *)toJson {
    NSMutableDictionary *details = [NSMutableDictionary dictionary];
    for (EMPresenceStatusDetail *detail in self.statusDetails) {
        details[detail.device] = @(detail.status);
    }
    return @{
        @"publisher": self.publisher,
        @"statusDetails": details,
        @"statusDescription": self.statusDescription,
        @"lastTime": @(self.lastTime),
        @"expiryTime": @(self.expirytime)
    };
}

@end

