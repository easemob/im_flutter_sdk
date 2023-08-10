//
//  EMMessageReactionOperation+Helper.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2023/5/17.
//

#import "EMMessageReactionOperation+Helper.h"

@implementation EMMessageReactionOperation (Helper)
- (NSDictionary *)toJson {
    return @{@"userId": self.userId,
             @"reaction": self.reaction,
             @"operate": @(self.operate)
    };
}
@end
