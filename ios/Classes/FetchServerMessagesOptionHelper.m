//
//  EMFetchServerMessagesOption+Helper.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2023/5/15.
//

#import "FetchServerMessagesOptionHelper.h"
#import "ConversationHelper.h"
#import "EnumTools.h"

@implementation EMFetchServerMessagesOption (Helper)
+ (EMFetchServerMessagesOption *)fromJson:(NSDictionary *)dict {
    EMFetchServerMessagesOption *options = [[EMFetchServerMessagesOption alloc] init];
    options.direction = [EnumTools searchDirectionFromInt:[dict[@"direction"] integerValue]];
    options.startTime = [dict[@"startTs"] longValue];
    options.endTime = [dict[@"endTs"] longValue];
    options.from = dict[@"from"];
    options.isSave = [dict[@"needSave"] boolValue];
    NSArray *types = dict[@"msgTypes"];
    NSMutableArray<NSNumber*> *list = [NSMutableArray new];
    if(types) {
        for (int i = 0; i < types.count; i++) {
           EMMessageBodyType type = [EnumTools messageBodyTypeFromInt:[types[i] integerValue]];
            [list addObject: [NSNumber numberWithInteger:type]];
        }
    }
    
    if(list.count > 0) {
        options.msgTypes = list;
    }
    
    return options;
}
@end
