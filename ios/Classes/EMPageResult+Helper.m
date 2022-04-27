//
//  EMPageResult+Flutter.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2020/9/27.
//

#import "EMPageResult+Helper.h"

@implementation EMPageResult (Helper)
- (NSDictionary *)toJson {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    NSMutableArray *dataList = [NSMutableArray array];
    for (id<EaseModeToJson> obj in self.list) {
        [dataList addObject:[obj toJson]];
    }
    
    data[@"list"] = dataList;
    data[@"count"] = @(self.count);
    
    return data;
}
@end
