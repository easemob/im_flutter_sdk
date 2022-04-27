//
//  EMError+Flutter.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2020/9/23.
//

#import "EMError+Helper.h"

@implementation EMError (Helper)
- (NSDictionary *)toJson {
    return @{
        @"code": @(self.code),
        @"description":self.errorDescription,
    };
}
@end
