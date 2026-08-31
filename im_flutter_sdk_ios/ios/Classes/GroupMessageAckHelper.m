//
//  EMGroupMessageAck+Flutter.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2021/11/25.
//

#import "GroupMessageAckHelper.h"

@implementation EMGroupReadReceipt (Helper)
- (NSDictionary *)toJson{
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"msgId"] = self.messageId;
    data[@"ack_id"] = self.readReceiptId;
    data[@"from"] = self.from.userId;
    data[@"count"] = @(self.readCount);
    data[@"timestamp"] = @(self.timestamp);
    return data;
}
@end
