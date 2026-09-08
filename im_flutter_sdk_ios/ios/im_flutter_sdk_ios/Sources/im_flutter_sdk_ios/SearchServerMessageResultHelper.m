//
//  EMSearchServerMessageResult+Flutter.m
//  im_flutter_sdk
//
//  4.24.0
//

#import "SearchServerMessageResultHelper.h"
#import "MessageHelper.h"
#import "EnumTools.h"

@implementation EMSearchServerMessageResult (Helper)
- (NSDictionary *)toJson {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"msgId"] = self.messageId;
    if (self.body) {
        data[@"body"] = [self.body toJson];
    }
    if (self.ext) {
        data[@"attributes"] = self.ext;
    }
    data[@"from"] = self.from;
    data[@"to"] = self.to;
    data[@"convId"] = self.conversationId;
    data[@"chatType"] = @([EnumTools chatTypeToInt:self.chatType]);
    data[@"timestamp"] = @(self.timestamp);
    if (self.highlightTexts) {
        data[@"highlightTexts"] = self.highlightTexts;
    }
    return data;
}
@end
