//
//  EMMessageReactionChange+Helper.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2022/5/18.
//

#import "MessageReactionChangeHelper.h"
#import "MessageReactionHelper.h"
#import "MessageReactionOperationHelper.h"

@implementation EMMessageReactionChange (Helper)

- (nonnull NSDictionary *)toJson {
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    ret[@"conversationId"] = self.conversationId;
    ret[@"messageId"] = self.messageId;
    NSMutableArray *reactions = [NSMutableArray array];
    for (EMMessageReaction *reaction in self.reactions) {
        [reactions addObject:[reaction toJson]];
    }
    ret[@"reactions"] = reactions;
    
    NSMutableArray *operations = [NSMutableArray array];
    for (EMMessageReactionOperation *operation in self.operations) {
        [operations addObject:[operation toJson]];
    };
    ret[@"operations"] = operations;
    return ret;
}

@end
