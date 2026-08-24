//
//  EMMessageReaction+Helper.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2022/5/18.
//

#import "MessageReactionHelper.h"

@implementation EMMessageReaction (Helper)

- (nonnull NSDictionary *)toJson {
    return @{
        @"reaction": self.reaction,
        @"count": @(self.count),
        @"isAddedBySelf": @(self.isAddedBySelf),
        @"userList": self.userList,
    };
}


@end
