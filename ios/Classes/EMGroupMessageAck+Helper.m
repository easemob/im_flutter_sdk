//
//  EMGroupMessageAck+Flutter.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2021/11/25.
//

#import "EMGroupMessageAck+Helper.h"

@implementation EMGroupMessageAck (Helper)
- (NSDictionary *)toJson{
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"msg_id"] = self.messageId;
    data[@"ack_id"] = self.readAckId;
    data[@"from"] = self.from;
    data[@"content"] = self.content;
    data[@"count"] = @(self.readCount);
    data[@"timestamp"] = @(self.timestamp);
    return data;
}
@end
