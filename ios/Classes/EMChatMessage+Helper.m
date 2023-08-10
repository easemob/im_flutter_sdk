//
//  EMChatMessage+Flutter.m
//  Pods
//
//  Created by 杜洁鹏 on 2020/9/11.
//

#import "EMChatMessage+Helper.h"
#import "EMChatThread+Helper.h"


@implementation EMChatMessage (Helper)

+ (EMChatMessage *)fromJson:(NSDictionary *)aJson
{
    EMMessageBody *body = [EMMessageBody fromJson:aJson[@"body"]];
    if (!body) {
        return nil;
    }
    
    
    NSString *from = aJson[@"from"];
    if (from.length == 0) {
        from = EMClient.sharedClient.currentUsername;
    }
    
    NSString *to = aJson[@"to"];
    NSString *conversationId = aJson[@"conversationId"];
    

    EMChatMessage *msg = [[EMChatMessage alloc] initWithConversationID:conversationId
                                                          from:from
                                                            to:to
                                                          body:body
                                                           ext:nil];
    if (aJson[@"msgId"]) {
        msg.messageId = aJson[@"msgId"];
    }
    
    msg.direction = ({
        [aJson[@"direction"] isEqualToString:@"send"] ? EMMessageDirectionSend : EMMessageDirectionReceive;
    });
    
    
    msg.chatType = [EMChatMessage chatTypeFromInt:[aJson[@"chatType"] intValue]];
    msg.status = [msg statusFromInt:[aJson[@"status"] intValue]];
    msg.localTime = [aJson[@"localTime"] longLongValue];
    msg.timestamp = [aJson[@"serverTime"] longLongValue];
    msg.isReadAcked = [aJson[@"hasReadAck"] boolValue];
    msg.isDeliverAcked = [aJson[@"hasDeliverAck"] boolValue];
    msg.isRead = [aJson[@"hasRead"] boolValue];
    msg.isNeedGroupAck = [aJson[@"needGroupAck"] boolValue];
    msg.deliverOnlineOnly = [aJson[@"deliverOnlineOnly"] boolValue];
    // read only
    // msg.groupAckCount = [aJson[@"groupAckCount"] intValue]
    // msg.chatThread = [EMChatThread forJson:aJson[@"thread"]];
    msg.isChatThreadMessage = [aJson[@"isThread"] boolValue];
    msg.ext = aJson[@"attributes"];
    if (aJson[@"chatroomMessagePriority"]) {
        msg.priority = [aJson[@"chatroomMessagePriority"] integerValue];
    }
    
    if(aJson[@"receiverList"]) {
        msg.receiverList = aJson[@"receiverList"];
    }
    
    return msg;
}

- (NSDictionary *)toJson
{
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    ret[@"from"] = self.from;
    ret[@"msgId"] = self.messageId;
    ret[@"to"] = self.to;
    ret[@"conversationId"] = self.conversationId;
    ret[@"hasRead"] = @(self.isRead);
    ret[@"hasDeliverAck"] = @(self.isDeliverAcked);
    ret[@"hasReadAck"] = @(self.isReadAcked);
    ret[@"needGroupAck"] = @(self.isNeedGroupAck);
    ret[@"serverTime"] = @(self.timestamp);
    ret[@"groupAckCount"] = @(self.groupAckCount);
    ret[@"attributes"] = self.ext;
    ret[@"localTime"] = @(self.localTime);
    ret[@"status"] = @([self statusToInt:self.status]);
    ret[@"chatType"] = @([EMChatMessage chatTypeToInt:self.chatType]);
    ret[@"isThread"] = @(self.isChatThreadMessage);
    ret[@"direction"] = self.direction == EMMessageDirectionSend ? @"send" : @"rec";
    ret[@"body"] = [self.body toJson];
    ret[@"onlineState"] = @(self.onlineState);
    ret[@"deliverOnlineOnly"] = @(self.deliverOnlineOnly);
    ret[@"receiverList"] = self.receiverList;
    return ret;
}

- (EMMessageStatus)statusFromInt:(int)aStatus {
    EMMessageStatus status = EMMessageStatusPending;
    switch (aStatus) {
        case 0:
        {
            status = EMMessageStatusPending;
        }
            break;
        case 1:
        {
            status = EMMessageStatusDelivering;
        }
            break;
        case 2:
        {
            status = EMMessageStatusSucceed;
        }
            break;
        case 3:
        {
            status = EMMessageStatusFailed;
        }
            break;
    }
    
    return status;
}

- (int)statusToInt:(EMMessageStatus)aStatus {
    int status = 0;
    switch (aStatus) {
        case EMMessageStatusPending:
        {
            status = 0;
        }
            break;
        case EMMessageStatusDelivering:
        {
            status = 1;
        }
            break;
        case EMMessageStatusSucceed:
        {
            status = 2;
        }
            break;
        case EMMessageStatusFailed:
        {
            status = 3;
        }
            break;
    }
    
    return status;
}

+ (EMChatType)chatTypeFromInt:(int)aType {
    EMChatType type = EMChatTypeChat;
    switch (aType) {
        case 0:
            type = EMChatTypeChat;
            break;
        case 1:
            type = EMChatTypeGroupChat;
            break;
        case 2:
            type = EMChatTypeChatRoom;
            break;
    }
    
    return type;
}

+ (int)chatTypeToInt:(EMChatType)aType {
    int type;
    switch (aType) {
        case EMChatTypeChat:
            type = 0;
            break;
        case EMChatTypeGroupChat:
            type = 1;
            break;
        case EMChatTypeChatRoom:
            type = 2;
            break;
    }
    return type;
}

@end

@implementation EMMessageBody (Helper)

+ (EMMessageBody *)fromJson:(NSDictionary *)bodyJson {
    EMMessageBody *ret = nil;
    NSString *type = bodyJson[@"type"];
    if ([type isEqualToString:@"txt"]) {
        ret = [EMTextMessageBody fromJson:bodyJson];
    } else if ([type isEqualToString:@"img"]) {
        ret = [EMImageMessageBody fromJson:bodyJson];
    } else if ([type isEqualToString:@"loc"]) {
        ret = [EMLocationMessageBody fromJson:bodyJson];
    } else if ([type isEqualToString:@"video"]) {
        ret = [EMVideoMessageBody fromJson:bodyJson];
    } else if ([type isEqualToString:@"voice"]) {
        ret = [EMVoiceMessageBody fromJson:bodyJson];
    } else if ([type isEqualToString:@"file"]) {
        ret = [EMFileMessageBody fromJson:bodyJson];
    } else if ([type isEqualToString:@"cmd"]) {
        ret = [EMCmdMessageBody fromJson:bodyJson];
    } else if ([type isEqualToString:@"custom"]) {
        ret = [EMCustomMessageBody fromJson:bodyJson];
    } else if ([type isEqualToString:@"combine"]) {
        ret = [EMCombineMessageBody fromJson:bodyJson];
    }
    return ret;
}

- (NSDictionary *)toJson {
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    NSString *type = @"";
    switch (self.type) {
        case EMMessageBodyTypeText:
            type = @"txt";
            break;
        case EMMessageBodyTypeLocation:
            type = @"loc";
            break;
        case EMMessageBodyTypeCmd:
            type = @"cmd";
            break;
        case EMMessageBodyTypeCustom:
            type = @"custom";
            break;
        case EMMessageBodyTypeFile:
            type = @"file";
            break;
        case EMMessageBodyTypeImage:
            type = @"img";
            break;
        case EMMessageBodyTypeVideo:
            type = @"video";
            break;
        case EMMessageBodyTypeVoice:
            type = @"voice";
            break;
        case EMMessageBodyTypeCombine:
            type = @"combine";
            break;
        default:
            break;
    }
    ret[@"type"] = type;
    if(self.operatorId && self.operatorId.length > 0) {
        ret[@"operatorId"] = self.operatorId;
    }
    if(self.operationTime > 0) {
        ret[@"operatorTime"] = @(self.operationTime);
    }
    if(self.operatorCount > 0) {
        ret[@"operatorCount"] = @(self.operatorCount);
    }
    
    return ret;
}

+ (EMMessageBodyType)typeFromString:(NSString *)aStrType {
   
    EMMessageBodyType ret = EMMessageBodyTypeText;
    
    if([aStrType isEqualToString:@"txt"]){
        ret = EMMessageBodyTypeText;
    } else if ([aStrType isEqualToString:@"loc"]) {
        ret = EMMessageBodyTypeLocation;
    } else if ([aStrType isEqualToString:@"cmd"]) {
        ret = EMMessageBodyTypeCmd;
    } else if ([aStrType isEqualToString:@"custom"]) {
        ret = EMMessageBodyTypeCustom;
    } else if ([aStrType isEqualToString:@"file"]) {
        ret = EMMessageBodyTypeFile;
    } else if ([aStrType isEqualToString:@"img"]) {
        ret = EMMessageBodyTypeImage;
    } else if ([aStrType isEqualToString:@"video"]) {
        ret = EMMessageBodyTypeVideo;
    } else if ([aStrType isEqualToString:@"voice"]) {
        ret = EMMessageBodyTypeVoice;
    } else if ([aStrType isEqualToString:@"combine"]) {
        ret = EMMessageBodyTypeCombine;
    }
    return ret;
}


+ (EMDownloadStatus)downloadStatusFromInt:(int)aStatus {
    EMDownloadStatus ret = EMDownloadStatusPending;
    switch (aStatus) {
        case 0:
            ret = EMDownloadStatusDownloading;
            break;
        case 1:
            ret = EMDownloadStatusSucceed;
            break;
        case 2:
            ret = EMDownloadStatusFailed;
            break;
        case 3:
            ret = EMDownloadStatusPending;
            break;
        default:
            break;
    }
    
    return ret;
}

+ (int)downloadStatusToInt:(EMDownloadStatus)aStatus {
    int ret = 0;
    switch (aStatus) {
        case EMDownloadStatusDownloading:
            ret = 0;
            break;
        case EMDownloadStatusSucceed:
            ret = 1;
            break;
        case EMDownloadStatusFailed:
            ret = 2;
            break;
        case EMDownloadStatusPending:
            ret = 3;
            break;
        default:
            break;
    }
    return ret;
}


@end

#pragma mark - txt

@interface EMTextMessageBody (Helper)
+ (EMMessageBody *)fromJson:(NSDictionary *)aJson;
- (NSDictionary *)toJson;
@end


@implementation EMTextMessageBody (Helper)

+ (EMMessageBody *)fromJson:(NSDictionary *)aJson {
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:aJson[@"content"]];
    body.targetLanguages = aJson[@"targetLanguages"];
    return body;
}

- (NSDictionary *)toJson {
    NSMutableDictionary *ret = [[super toJson] mutableCopy];
    ret[@"content"] = self.text;
    ret[@"targetLanguages"] = self.targetLanguages;
    ret[@"translations"] = self.translations;
    return ret;
}

@end

#pragma mark - loc

@interface EMLocationMessageBody (Helper)
+ (EMMessageBody *)fromJson:(NSDictionary *)aJson;
- (NSDictionary *)toJson;
@end


@implementation EMLocationMessageBody (Helper)

+ (EMMessageBody *)fromJson:(NSDictionary *)aJson {
    double latitude = [aJson[@"latitude"] doubleValue];
    double longitude = [aJson[@"longitude"] doubleValue];
    NSString *address = aJson[@"address"];
    NSString *buildingName = aJson[@"buildingName"];
    
    EMLocationMessageBody *ret  = [[EMLocationMessageBody alloc] initWithLatitude:latitude
                                                                        longitude:longitude
                                                                          address:address buildingName:buildingName];
    return ret;
}

- (NSDictionary *)toJson {
    NSMutableDictionary *ret = [[super toJson] mutableCopy];
    ret[@"address"] = self.address;
    ret[@"latitude"] = @(self.latitude);
    ret[@"longitude"] = @(self.longitude);
    ret[@"buildingName"] = self.buildingName;
    return ret;
}

@end

#pragma mark - cmd

@interface EMCmdMessageBody (Helper)
+ (EMCmdMessageBody *)fromJson:(NSDictionary *)aJson;
- (NSDictionary *)toJson;
@end

@implementation EMCmdMessageBody (Helper)

+ (EMCmdMessageBody *)fromJson:(NSDictionary *)aJson {
    EMCmdMessageBody *ret = [[EMCmdMessageBody alloc] initWithAction:aJson[@"action"]];
    ret.isDeliverOnlineOnly = [aJson[@"deliverOnlineOnly"] boolValue];
    return ret;
}

- (NSDictionary *)toJson {
    NSMutableDictionary *ret = [[super toJson] mutableCopy];
    ret[@"action"] = self.action;
    ret[@"deliverOnlineOnly"] = @(self.isDeliverOnlineOnly);
    return ret;
}

@end

#pragma mark - custom

@interface EMCustomMessageBody (Helper)
+ (EMCustomMessageBody *)fromJson:(NSDictionary *)aJson;
- (NSDictionary *)toJson;
@end

@implementation EMCustomMessageBody (Helper)

+ (EMCustomMessageBody *)fromJson:(NSDictionary *)aJson {
    NSDictionary *dic = aJson[@"params"];
    if ([dic isKindOfClass:[NSNull class]]) {
        dic = nil;
    }else if ([dic isKindOfClass:[NSString class]]) {
        NSError *err = nil;
        NSData *jsonData = [(NSString *)dic dataUsingEncoding:NSUTF8StringEncoding];
        id obj = [NSJSONSerialization JSONObjectWithData:jsonData
                                                 options:NSJSONReadingMutableContainers
                                                   error:&err];
        if (err == nil && obj != nil) {
            dic = (NSDictionary *)obj;
        }else {
            dic = nil;
        }
    }
    
    EMCustomMessageBody *ret = [[EMCustomMessageBody alloc] initWithEvent:aJson[@"event"]
                                                                customExt:dic];
    return ret;
}

- (NSDictionary *)toJson {
    NSMutableDictionary *ret = [[super toJson] mutableCopy];
    ret[@"event"] = self.event;
    ret[@"params"] = self.customExt;
    return ret;
}

@end

@interface EMCombineMessageBody (Helper)
+ (EMCombineMessageBody *)fromJson:(NSDictionary *)aJson;
- (NSDictionary *)toJson;
@end

@implementation EMCombineMessageBody (Helper)

+ (EMCombineMessageBody *)fromJson:(NSDictionary *)aJson {

    NSString *title = aJson[@"title"];
    NSString *summary = aJson[@"summary"];
    NSArray *msgList = aJson[@"messageList"];
    NSString *compatibleText = aJson[@"compatibleText"];
    NSString *localPath = aJson[@"localPath"];
    NSString *remotePath = aJson[@"remotePath"];
    NSString *secret = aJson[@"secret"];
    
    EMCombineMessageBody *ret = [[EMCombineMessageBody alloc] initWithTitle:title
                                                                    summary:summary
                                                              compatibleText:compatibleText
                                                               messageIdList:msgList];
    
    ret.remotePath = remotePath;
    ret.secretKey = secret;
    ret.localPath = localPath;
    return ret;
}

- (NSDictionary *)toJson {
    NSMutableDictionary *ret = [[super toJson] mutableCopy];
    ret[@"title"] = self.title;
    ret[@"summary"] = self.summary;
    ret[@"compatibleText"] = self.compatibleText;
    ret[@"localPath"] = self.localPath;
    ret[@"remotePath"] = self.remotePath;
    ret[@"secret"] = self.secretKey;
    return ret;
}

@end

#pragma mark - file

@interface EMFileMessageBody (Helper)
+ (EMMessageBody *)fromJson:(NSDictionary *)aJson;
- (NSDictionary *)toJson;
@end

@implementation EMFileMessageBody (Helper)

+ (EMMessageBody *)fromJson:(NSDictionary *)aJson {
    NSString *path = aJson[@"localPath"];
    NSString *displayName = aJson[@"displayName"];
    EMFileMessageBody *ret = [[EMFileMessageBody alloc] initWithLocalPath:path
                                                              displayName:displayName];
    ret.secretKey = aJson[@"secret"];
    ret.remotePath = aJson[@"remotePath"];
    ret.fileLength = [aJson[@"fileSize"] longLongValue];
    ret.downloadStatus = [EMMessageBody downloadStatusFromInt:[aJson[@"fileStatus"] intValue]];
    return ret;
}

- (NSDictionary *)toJson {
    NSMutableDictionary *ret = [[super toJson] mutableCopy];
    ret[@"localPath"] = self.localPath;
    ret[@"displayName"] = self.displayName;
    ret[@"secret"] = self.secretKey;
    ret[@"remotePath"] = self.remotePath;
    ret[@"fileSize"] = @(self.fileLength);
    ret[@"fileStatus"] = @([EMMessageBody downloadStatusToInt:self.downloadStatus]);
    return ret;
}


@end

#pragma mark - img

@interface EMImageMessageBody (Helper)
+ (EMMessageBody *)fromJson:(NSDictionary *)aJson;
- (NSDictionary *)toJson;
@end

@implementation EMImageMessageBody (Helper)

+ (EMMessageBody *)fromJson:(NSDictionary *)aJson {
    NSString *path = aJson[@"localPath"];
    NSString *displayName = aJson[@"displayName"];
    NSData *imageData = [NSData dataWithContentsOfFile:path];
    EMImageMessageBody *ret = [[EMImageMessageBody alloc] initWithData:imageData
                                                           displayName:displayName];
    ret.secretKey = aJson[@"secret"];
    ret.remotePath = aJson[@"remotePath"];
    ret.fileLength = [aJson[@"fileSize"] longLongValue];
    ret.downloadStatus = [EMMessageBody downloadStatusFromInt:[aJson[@"fileStatus"] intValue]];
    ret.thumbnailLocalPath = aJson[@"thumbnailLocalPath"];
    ret.thumbnailRemotePath = aJson[@"thumbnailRemotePath"];
    ret.thumbnailSecretKey = aJson[@"thumbnailSecret"];
    ret.size = CGSizeMake([aJson[@"width"] floatValue], [aJson[@"height"] floatValue]);
    ret.thumbnailDownloadStatus = [EMMessageBody downloadStatusFromInt:[aJson[@"thumbnailStatus"] intValue]];
    ret.compressionRatio = [aJson[@"sendOriginalImage"] boolValue] ? 1.0 : 0.6;
    return ret;
}

- (NSDictionary *)toJson {
    NSMutableDictionary *ret = [[super toJson] mutableCopy];
    ret[@"thumbnailLocalPath"] = self.thumbnailLocalPath;
    ret[@"thumbnailRemotePath"] = self.thumbnailRemotePath;
    ret[@"thumbnailSecret"] = self.thumbnailSecretKey;
    ret[@"thumbnailStatus"] = @([EMMessageBody downloadStatusToInt:self.thumbnailDownloadStatus]);
    ret[@"fileStatus"] = @([EMMessageBody downloadStatusToInt:self.downloadStatus]);
    ret[@"width"] = @(self.size.width);
    ret[@"height"] = @(self.size.height);
    ret[@"fileSize"] = @(self.fileLength);
    ret[@"remotePath"] = self.remotePath;
    ret[@"secret"] = self.secretKey;
    ret[@"displayName"] = self.displayName;
    ret[@"localPath"] = self.localPath;
    ret[@"sendOriginalImage"] = self.compressionRatio == 1.0 ? @(YES) : @(NO);
    return ret;
}
@end

#pragma mark - video

@interface EMVideoMessageBody (Helper)
+ (EMVideoMessageBody *)fromJson:(NSDictionary *)aJson;
- (NSDictionary *)toJson;
@end

@implementation EMVideoMessageBody (Helper)
+ (EMVideoMessageBody *)fromJson:(NSDictionary *)aJson {
    NSString *path = aJson[@"localPath"];
    NSString *displayName = aJson[@"displayName"];
    EMVideoMessageBody *ret = [[EMVideoMessageBody alloc] initWithLocalPath:path displayName:displayName];
    ret.duration = [aJson[@"duration"] intValue];
    ret.secretKey = aJson[@"secret"];
    ret.remotePath = aJson[@"remotePath"];
    ret.fileLength = [aJson[@"fileSize"] longLongValue];
    if (aJson[@"thumbnailLocalPath"]) {
        ret.thumbnailLocalPath = aJson[@"thumbnailLocalPath"];
    }
    ret.thumbnailRemotePath = aJson[@"thumbnailRemotePath"];
    ret.thumbnailSecretKey = aJson[@"thumbnailSecret"];
    ret.thumbnailDownloadStatus = [EMMessageBody downloadStatusFromInt:[aJson[@"thumbnailStatus"] intValue]];
    ret.thumbnailSize = CGSizeMake([aJson[@"width"] floatValue], [aJson[@"height"] floatValue]);
    return ret;
}

- (NSDictionary *)toJson {
    NSMutableDictionary *ret = [[super toJson] mutableCopy];
    ret[@"duration"] = @(self.duration);
    ret[@"thumbnailLocalPath"] = self.thumbnailLocalPath;
    ret[@"secret"] = self.secretKey;
    ret[@"remotePath"] = self.remotePath;
    ret[@"thumbnailRemotePath"] = self.thumbnailRemotePath;
    ret[@"thumbnailSecretKey"] = self.thumbnailSecretKey;
    ret[@"thumbnailStatus"] = @([EMMessageBody downloadStatusToInt:self.thumbnailDownloadStatus]);
    ret[@"width"] = @(self.thumbnailSize.width);
    ret[@"height"] = @(self.thumbnailSize.height);
    ret[@"fileSize"] = @(self.fileLength);
    ret[@"displayName"] = self.displayName;
    ret[@"duration"] = @(self.duration);
    return ret;
}
@end

#pragma mark - voice

@interface EMVoiceMessageBody (Helper)
+ (EMVoiceMessageBody *)fromJson:(NSDictionary *)aJson;
- (NSDictionary *)toJson;
@end

@implementation EMVoiceMessageBody (Helper)
+ (EMVoiceMessageBody *)fromJson:(NSDictionary *)aJson {
    NSString *path = aJson[@"localPath"];
    NSString *displayName = aJson[@"displayName"];
    EMVoiceMessageBody *ret = [[EMVoiceMessageBody alloc] initWithLocalPath:path displayName:displayName];
    ret.secretKey = aJson[@"secret"];
    ret.remotePath = aJson[@"remotePath"];
    ret.duration = [aJson[@"duration"] intValue];
    ret.downloadStatus = [EMMessageBody downloadStatusFromInt:[aJson[@"fileStatus"] intValue]];
    return ret;
}

- (NSDictionary *)toJson {
    NSMutableDictionary *ret = [[super toJson] mutableCopy];
    ret[@"duration"] = @(self.duration);
    ret[@"displayName"] = self.displayName;
    ret[@"localPath"] = self.localPath;
    ret[@"fileSize"] = @(self.fileLength);
    ret[@"secret"] = self.secretKey;
    ret[@"remotePath"] = self.remotePath;
    ret[@"fileStatus"] = @([EMMessageBody downloadStatusToInt:self.downloadStatus]);;
    return ret;
}

@end
