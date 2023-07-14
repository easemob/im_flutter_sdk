//
//  EMFetchServerMessagesOption+Helper.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2023/5/15.
//

#import "EMFetchServerMessagesOption+Helper.h"
#import "EMConversation+Helper.h"

@implementation EMFetchServerMessagesOption (Helper)
+ (EMFetchServerMessagesOption *)formJson:(NSDictionary *)dict {
    EMFetchServerMessagesOption *options = [[EMFetchServerMessagesOption alloc] init];
    options.direction = [dict[@"direction"] isEqualToString:@"up"] ? EMMessageSearchDirectionUp : EMMessageSearchDirectionDown;
    options.startTime = [dict[@"startTs"] longValue];
    options.endTime = [dict[@"endTs"] longValue];
    options.from = dict[@"from"];
    options.isSave = [dict[@"needSave"] boolValue];
    NSArray *types = dict[@"msgTypes"];
    NSMutableArray<NSNumber*> *list = [NSMutableArray new];
    if(types) {
        for (int i = 0; i < types.count; i++) {
            NSString *type = types[i];
            if ([type isEqualToString:@"txt"]) {
                [list addObject:@(EMMessageBodyTypeText)];
            } else if ([type isEqualToString:@"img"]) {
                [list addObject:@(EMMessageBodyTypeImage)];
            } else if ([type isEqualToString:@"loc"]) {
                [list addObject:@(EMMessageBodyTypeLocation)];
            } else if ([type isEqualToString:@"video"]) {
                [list addObject:@(EMMessageBodyTypeVideo)];
            } else if ([type isEqualToString:@"voice"]) {
                [list addObject:@(EMMessageBodyTypeVoice)];
            } else if ([type isEqualToString:@"file"]) {
                [list addObject:@(EMMessageBodyTypeFile)];
            } else if ([type isEqualToString:@"cmd"]) {
                [list addObject:@(EMMessageBodyTypeCmd)];
            } else if ([type isEqualToString:@"custom"]) {
                [list addObject:@(EMMessageBodyTypeCustom)];
            } else if ([type isEqualToString:@"combine"]) {
                [list addObject:@(EMMessageBodyTypeCombine)];
            }
        }
    }
    
    if(list.count > 0) {
        options.msgTypes = list;
    }
    
    return options;
}
@end
