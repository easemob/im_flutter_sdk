//
//  EMConversation+Flutter.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2020/9/21.
//

#import "EMConversation+Helper.h"
#import "EMChatMessage+Helper.h"

@implementation EMConversation (Helper)
- (NSDictionary *)toJson {
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    ret[@"convId"] = self.conversationId;
    ret[@"type"] = @([self.class typeToInt:self.type]);
    ret[@"ext"] = self.ext;
    ret[@"isThread"] = @(self.isChatThread);
    ret[@"isPinned"] = @(self.isPinned);
    ret[@"pinnedTime"] = @(self.pinnedTime);
    return ret;
}


+ (int)typeToInt:(EMConversationType)aType {
    int ret = 0;
    switch (aType) {
        case EMConversationTypeChat:
            ret = 0;
            break;
        case EMConversationTypeGroupChat:
            ret = 1;
            break;
        case EMConversationTypeChatRoom:
            ret = 2;
            break;
        default:
            break;
    }
    return ret;
}

+ (EMConversationType)typeFromInt:(int)aType {
    EMConversationType ret = EMConversationTypeChat;
    switch (aType) {
        case 0:
            ret = EMConversationTypeChat;
            break;
        case 1:
            ret = EMConversationTypeGroupChat;
            break;
        case 2:
            ret = EMConversationTypeChatRoom;
            break;
        default:
            break;
    }
    return ret;
}

@end
