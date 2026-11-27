//
//  EMGroupReadReceipt+Helper.m
//  im_flutter_sdk
//

#import "GroupReadReceiptHelper.h"
#import "GroupMemberInfoHelper.h"

@implementation EMGroupReadReceipt (Helper)

- (NSDictionary *)toJson {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"msgId"] = self.messageId;
    data[@"ack_id"] = self.readReceiptId;
    data[@"from"] = [self.from toJson];
    data[@"count"] = @(self.readCount);
    data[@"timestamp"] = @(self.timestamp);
    return data;
}

@end
