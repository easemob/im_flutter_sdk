//
//  NSArray+Helper.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2022/4/28.
//

#import "NSArray+Helper.h"
#import "EaseModeToJson.h"

@implementation NSArray (Helper)
- (NSArray *)toJsonArray {
    NSMutableArray *ary = nil;
    for (id<EaseModeToJson> item in self) {
        if (ary == nil) {
            ary = [NSMutableArray array];
        }
        [ary addObject:[item toJson]];
    }
    return ary;
}
@end
