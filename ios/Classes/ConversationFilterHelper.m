//
//  EMConversationFilter+Helper.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2020/9/28.
//

#import "ConversationFilterHelper.h"


@implementation EMConversationFilter (Helper)
// 不需要提供toJson
//- (NSDictionary *)toJson {
//    NSMutableDictionary *ret = [NSMutableDictionary new];
//    ret[@"mark"] = @(self.mark);
//    ret[@"pageSize"] = @(self.pageSize);
//    return ret;
//}

+ (EMConversationFilter *)fromJson:(NSDictionary *)dict {
    EMConversationFilter *filter = [[EMConversationFilter alloc] init];
    filter.mark = (EMMarkType)[dict[@"mark"] integerValue];
    filter.pageSize = [dict[@"pageSize"] intValue];
    return filter;
}

+ (NSString *)getCursor:(NSDictionary *)dict {
    return dict[@"cursor"];
}

+ (BOOL)getPinned:(NSDictionary *)dict {
    return [dict[@"pinned"] boolValue];
}

+ (BOOL)hasMark:(NSDictionary *)dict {
    return dict[@"mark"] != nil;
}

+ (NSInteger)pageSize:(NSDictionary *)dict {
    return [dict[@"pageSize"] intValue];
}

@end

