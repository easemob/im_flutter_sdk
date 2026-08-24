//
//  EMContact+Helper.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2023/11/13.
//

#import "ContactHelper.h"

@implementation EMContact (Helper)
+ (EMContact *)fromJson:(NSDictionary *)aJson {
    // Some older HyphenateChat iOS SDKs do not expose the `remark` init or property at compile time.
    // Create with userId only, then set remark via KVC if the setter exists at runtime.
    EMContact *contact = [[EMContact alloc] init];
    @try {
        [contact setValue:aJson[@"userId"] forKey:@"userId"];
    } @catch (__unused NSException *e) {
        // Ignore if key not supported
    }
    id remark = aJson[@"remark"];
    if (remark && remark != [NSNull null]) {
        @try {
            // Use KVC to avoid compile-time dependency on `remark` symbol
            [contact setValue:remark forKey:@"remark"];
        } @catch (__unused NSException *e) {
            // Ignore if key not supported on older SDKs
        }
    }
    return contact;
}
- (NSDictionary *)toJson {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"userId"] = self.userId;
    // Access remark via KVC to be compatible with SDKs without the property
    id remark = nil;
    @try {
        remark = [self valueForKey:@"remark"];
    } @catch (__unused NSException *e) {
        remark = nil;
    }
    if (remark) {
        data[@"remark"] = remark;
    }
    return data;
}
@end
