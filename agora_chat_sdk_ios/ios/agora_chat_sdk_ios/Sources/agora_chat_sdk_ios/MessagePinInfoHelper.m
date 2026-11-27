//
//  EMMessagePinInfo+Helper.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2020/9/28.
//

#import "MessagePinInfoHelper.h"


@implementation EMMessagePinInfo (Helper)
- (NSDictionary *)toJson {
    NSMutableDictionary *ret = [NSMutableDictionary new];
    ret[@"operatorId"] = self.operatorId;
    ret[@"pinTime"] = @(self.pinTime);
    return ret;
}

+ (EMMessagePinInfo *)fromJson:(NSDictionary *)dict {
    EMMessagePinInfo *info = [[EMMessagePinInfo alloc] init];
    info.operatorId = dict[@"operatorId"];
    info.pinTime = [dict[@"pinTime"] integerValue];
    return info;
}

@end

