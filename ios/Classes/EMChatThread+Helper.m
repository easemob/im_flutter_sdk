//
//  EMChatThread+Helper.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2022/5/29.
//

#import "EMChatThread+Helper.h"
#import "EMChatMessage+Helper.h"

@implementation EMChatThread (Helper)
- (nonnull NSDictionary *)toJson {
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    ret[@"threadId"] = self.threadId;
    ret[@"threadName"] = self.threadName;
    ret[@"owner"] = self.owner;
    ret[@"msgId"] = self.messageId;
    ret[@"parentId"] = self.parentId;
    ret[@"memberCount"] = @(self.membersCount);
    ret[@"messageCount"] = @(self.messageCount);
    ret[@"createAt"] = @(self.createAt);
    if (self.lastMessage) {
        ret[@"lastMessage"] = [self.lastMessage toJson];
    }
    return ret;
}

@end
