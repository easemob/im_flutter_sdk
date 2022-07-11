//
//  EMSilentModeResult+Helper.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2022/7/11.
//

#import "EMSilentModeResult+Helper.h"
#import "EMSilentModeTime+Helper.h"
#import "EMSilentModeParam+Helper.h"
#import "EMConversation+Helper.h"

@implementation EMSilentModeResult (Helper)
- (NSDictionary *)toJson {
    NSMutableDictionary *ret = [[NSMutableDictionary alloc] init];
    ret[@"expireTs"] = @(self.expireTimestamp);
    ret[@"startTime"] = [self.silentModeStartTime toJson];
    ret[@"endTime"] = [self.silentModeEndTime toJson];
    ret[@"remindType"] = @([EMSilentModeParam remindTypeToInt:self.remindType]);
    ret[@"conversationId"] = self.conversationID;
    ret[@"conversationType"] = @([EMConversation typeToInt:self.conversationType]);
    return ret;
}
@end
