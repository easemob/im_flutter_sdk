//
//  Helper.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2025/2/17.
//

#import "Helper.h"

@implementation Helper
+ (void)mergeMessage:(EMChatMessage *)msg withDBMessage:(EMChatMessage *)dbMsg {
    dbMsg.timestamp = msg.timestamp;
    dbMsg.localTime = msg.localTime;
    dbMsg.status = msg.status;
    dbMsg.isReadAcked = msg.isReadAcked;
    dbMsg.isChatThreadMessage = msg.isChatThreadMessage;
    dbMsg.isNeedGroupAck = msg.isNeedGroupAck;
    dbMsg.isDeliverAcked = msg.isDeliverAcked;
    dbMsg.isRead = msg.isRead;
    dbMsg.isListened = msg.isListened;
    dbMsg.receiverList = msg.receiverList;
    dbMsg.priority = msg.priority;
    dbMsg.deliverOnlineOnly = msg.deliverOnlineOnly;
    dbMsg.ext = msg.ext;
    dbMsg.body = msg.body;
}

@end
