//
//  EMLoginExtensionInfo+Helper.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2024/8/22.
//

#import "LoginExtensionInfoHelper.h"

@implementation EMLoginExtensionInfo (Helper)
- (NSDictionary *)toJson{
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"deviceName"] = self.deviceName;
    data[@"ext"] = self.extensionInfo;
    
    return data;
}
@end
