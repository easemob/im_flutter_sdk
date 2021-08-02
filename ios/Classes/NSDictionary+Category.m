//
//  NSDictionary+Category.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2021/7/31.
//

#import "NSDictionary+Category.h"

@implementation NSDictionary (Category)
- (id)safetyValue:(NSString *)akey {
    id object = self[akey];
    if ([object isKindOfClass:[NSNull class]]) {
        object = nil;
    }
    
    return object;
}
@end
