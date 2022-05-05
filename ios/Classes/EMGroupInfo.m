//
//  EMGroupInfo.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2022/5/5.
//

#import "EMGroupInfo.h"

@implementation EMGroupInfo
- (NSDictionary *)toJson {
    return @{
        @"groupName": self.groupName,
        @"groupId":self.groupId
    };
}
@end
