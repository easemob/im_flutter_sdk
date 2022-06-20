//
//  EMDeviceConfig+Flutter.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2020/10/12.
//

#import "EMDeviceConfig+Helper.h"

@implementation EMDeviceConfig (Helper)
- (NSDictionary *)toJson {
    return @{
        @"resource": self.resource,
        @"deviceUUID":self.deviceUUID,
        @"deviceName":self.deviceName,
    };
}
@end
