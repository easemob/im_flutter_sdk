//
//  EMPushOptions+Flutter.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2020/10/15.
//

#import "EMPushOptions+Flutter.h"

@implementation EMPushOptions (Flutter)
- (NSDictionary *)toJson{
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"noDisturb"] = @(self.isNoDisturbEnable);
    data[@"pushStyle"] = @(self.displayStyle != EMPushDisplayStyleSimpleBanner);
    data[@"noDisturbStartHour"] = @(self.noDisturbingStartH);
    data[@"noDisturbEndHour"] = @(self.noDisturbingEndH);
    return data;
}

@end
