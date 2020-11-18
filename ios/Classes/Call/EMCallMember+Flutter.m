//
//  EMCallMember+Flutter.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2020/11/18.
//

#import "EMCallMember+Flutter.h"

@implementation EMCallMember (Flutter)
- (NSDictionary *)toJson {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"memberId"] = self.memberId;
    data[@"memberName"] = self.memberName;
    data[@"ext"] = self.ext;
    data[@"nickname"] = self.nickname;
    return data;
}
@end
