//
//  EMRecallMessageInfo+Helper.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2024/5/7.
//

#import "RecallInfoHelper.h"
#import "MessageHelper.h"

@implementation EMRecallMessageInfo (Helper)
- (NSDictionary *)toJson {
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    ret[@"recallMsgId"] = self.recallMessageId;
    ret[@"recallBy"] = self.recallBy;
    ret[@"ext"] = self.ext;
    ret[@"msg"] = [self.recallMessage toJson];
    // 4.10
    ret[@"conversationId"] = self.conversationId;
    return ret;
}
@end
