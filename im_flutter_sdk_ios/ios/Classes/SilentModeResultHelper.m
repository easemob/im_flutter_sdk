//
//  EMSilentModeResult+Helper.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2022/7/11.
//

#import "SilentModeResultHelper.h"
#import "SilentModeTimeHelper.h"
#import "SilentModeParamHelper.h"
#import "ConversationHelper.h"
#import "EnumTools.h"

@implementation EMSilentModeResult (Helper)
- (NSDictionary *)toJson {
    NSMutableDictionary *ret = [[NSMutableDictionary alloc] init];
    ret[@"expireTs"] = @(self.expireTimestamp);
    ret[@"startTime"] = [self.silentModeStartTime toJson];
    ret[@"endTime"] = [self.silentModeEndTime toJson];
    ret[@"remindType"] = @([EMSilentModeParam remindTypeToInt:self.remindType]);
    ret[@"conversationId"] = self.conversationID;
    ret[@"conversationType"] = [NSNumber numberWithInteger:[EnumTools conversationTypeToInt:self.conversationType]];
    return ret;
}
@end
