//
//  EMPushOptions+Flutter.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2020/10/15.
//

#import "EMPushOptions+Helper.h"

@implementation EMPushOptions (Helper)
- (NSDictionary *)toJson{
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"noDisturb"] = @(self.isNoDisturbEnable);
    data[@"pushStyle"] = @(self.displayStyle != EMPushDisplayStyleSimpleBanner);
    data[@"noDisturbStartHour"] = @(self.noDisturbingStartH);
    data[@"noDisturbEndHour"] = @(self.noDisturbingEndH);
    data[@"displayName"] = self.displayName;
    return data;
}

@end
