//
//  GroupMemberInfoHelper.m
//  im_flutter_sdk_ios
//
//  Created by 杜洁鹏 on 2025/5/7.
//

#import "GroupMemberInfoHelper.h"
#import "EnumTools.h"

@implementation EMGroupMemberInfo (Helper)
- (NSDictionary *)toJson {
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    ret[@"userId"] = self.userId;
    ret[@"joinedTs"] = @(self.joinedTimestamp);
    ret[@"role"] = [NSNumber numberWithInteger:[EnumTools groupPermissionTypeToInt:self.role]];
    ret[@"namecard"] = self.namecard;
    ret[@"nickname"] = self.nickname;
    ret[@"avatarUrl"] = self.avatarUrl;
    return ret;
}
@end
