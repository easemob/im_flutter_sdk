//
//  EMMessageReadReceipt+Helper.m
//  im_flutter_sdk
//

#import "MessageReadReceiptHelper.h"

@implementation EMMessageReadReceipt (Helper)

- (NSDictionary *)toJson {
    return @{
        @"messageId": self.messageId,
        @"conversationId": self.conversationId,
        @"isPeerReceipt": @(self.isPeerReceipt),
        @"readCount": @(self.readCount)
    };
}

@end
