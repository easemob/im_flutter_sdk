//
//  EMGroupMessageAck+Flutter.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2021/11/25.
//

#import "EMGroupMessageAck+Flutter.h"

@implementation EMGroupMessageAck (Flutter)
- (NSDictionary *)toJson{
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"msg_id"] = self.messageId;
    data[@"from"] = self.from;
    data[@"content"] = self.content;
    data[@"count"] = @(self.readCount);
    data[@"ack_id"] = self.readAckId;
    data[@"timestamp"] = @(self.timestamp);
    return data;
}
@end
