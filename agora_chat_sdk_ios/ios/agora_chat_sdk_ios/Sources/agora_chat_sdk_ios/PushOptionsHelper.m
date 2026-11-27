//
//  EMPushOptions+Flutter.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2020/10/15.
//

#import "PushOptionsHelper.h"

@implementation EMPushOptions (Helper)
- (NSDictionary *)toJson{
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"pushStyle"] = @(self.displayStyle != EMPushDisplayStyleSimpleBanner);
    data[@"displayName"] = self.displayName;
    return data;
}

@end
