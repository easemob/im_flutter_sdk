//
//  EMConversation+Flutter.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2020/9/21.
//

#import "ConversationHelper.h"
#import "MessageHelper.h"
#import "EnumTools.h"

@implementation EMConversation (Helper)
- (NSDictionary *)toJson {
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    ret[@"convId"] = self.conversationId;
    ret[@"type"] = [NSNumber numberWithInteger:[EnumTools conversationTypeFromInt:self.type]];
    ret[@"ext"] = self.ext;
    ret[@"isThread"] = @(self.isChatThread);
    ret[@"isPinned"] = @(self.isPinned);
    ret[@"pinnedTime"] = @(self.pinnedTime);
    ret[@"marks"] = self.marks;
    return ret;
}

@end
