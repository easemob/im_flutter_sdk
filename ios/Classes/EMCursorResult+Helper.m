//
//  EMCursorResult+Flutter.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2020/9/27.
//

#import "EMCursorResult+Helper.h"

@implementation EMCursorResult (Helper)
- (NSDictionary *)toJson {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    NSMutableArray *dataList = [NSMutableArray array];
    
    for (id obj in self.list) {
        if ([obj respondsToSelector:@selector(toJson)]) {
            [dataList addObject:[obj toJson]];
        }else if ([obj isKindOfClass:[NSString class]]){
            [dataList addObject:obj]; 
        }
    }
    
    data[@"list"] = dataList;
    data[@"cursor"] = self.cursor;
    
    return data;
}
@end
