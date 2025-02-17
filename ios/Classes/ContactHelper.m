//
//  EMContact+Helper.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2023/11/13.
//

#import "ContactHelper.h"

@implementation EMContact (Helper)
+ (EMContact *)fromJson:(NSDictionary *)aJson {
    EMContact *contact = [[EMContact alloc] initWithUserId:aJson[@"userId"]
                                                    remark:aJson[@"remark"]];
    return contact;
}
- (NSDictionary *)toJson {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"userId"] = self.userId;
    data[@"remark"] = self.remark;
    return data;
}
@end
