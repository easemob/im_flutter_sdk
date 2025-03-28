//
//  EMChatMessage+Flutter.m
//  Pods
//
//  Created by 杜洁鹏 on 2020/9/11.
//

#import "MessageHelper.h"
#import "ThreadHelper.h"
#import "MessagePinInfoHelper.h"
#import "EnumTools.h"


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
    
    msg.direction = [EnumTools messageDirectFromInt: [aJson[@"direction"] integerValue]];
    msg.chatType = [EnumTools chatTypeFromInt:[aJson[@"chatType"] integerValue]];
    msg.status = [EnumTools messageStatusFromInt:[aJson[@"status"] integerValue]];
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
    // msg.isContentReplaced = [aJson[@"isContentReplaced"] boolValue];
    // msg.pinnedInfo = [EMMessagaPinInfo forJson:aJson[@"pinnedInfo"]];
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
    ret[@"status"] = [NSNumber numberWithInteger:[EnumTools messageStatusToInt:self.status]];
    ret[@"chatType"] = [NSNumber numberWithInteger:[EnumTools chatTypeToInt:self.chatType]];
    ret[@"direction"] = [NSNumber numberWithInteger:[EnumTools messageDirectToInt:self.direction]];
    ret[@"isThread"] = @(self.isChatThreadMessage);
    ret[@"body"] = [self.body toJson];
    ret[@"onlineState"] = @(self.onlineState);
    ret[@"deliverOnlineOnly"] = @(self.deliverOnlineOnly);
    ret[@"receiverList"] = self.receiverList;
    ret[@"broadcast"] = @(self.broadcast);
    ret[@"isContentReplaced"] = @(self.isContentReplaced);
    // flutter 使用 get 方法获取。
    // ret[@"pinnedInfo"] = [self.pinnedInfo toJson];
    return ret;
}

@end

@implementation EMMessageBody (Helper)

+ (EMMessageBody *)fromJson:(NSDictionary *)bodyJson {
    EMMessageBody *ret = nil;
    EMMessageBodyType type = [EnumTools messageBodyTypeFromInt:[bodyJson[@"type"] integerValue]];
    switch (type) {
        case EMMessageBodyTypeText:
            ret = [EMTextMessageBody fromJson:bodyJson];
            break;
        case EMMessageBodyTypeImage:
            ret = [EMImageMessageBody fromJson:bodyJson];
            break;
        case EMMessageBodyTypeVideo:
            ret = [EMVideoMessageBody fromJson:bodyJson];
            break;
        case EMMessageBodyTypeLocation:
            ret = [EMLocationMessageBody fromJson:bodyJson];
            break;
        case EMMessageBodyTypeVoice:
            ret = [EMVoiceMessageBody fromJson:bodyJson];
            break;
        case EMMessageBodyTypeFile:
            ret = [EMFileMessageBody fromJson:bodyJson];
            break;
        case EMMessageBodyTypeCmd:
            ret = [EMCmdMessageBody fromJson:bodyJson];
            break;
        case EMMessageBodyTypeCustom:
            ret = [EMCustomMessageBody fromJson:bodyJson];
            break;
        case EMMessageBodyTypeCombine:
            ret = [EMCombineMessageBody fromJson:bodyJson];
            break;
        default:
            break;
    }

    return ret;
}

- (NSDictionary *)toJson {
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    ret[@"type"] = [NSNumber numberWithInteger:[EnumTools messageBodyTypeToInt:self.type]];
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


@end

#pragma mark - txt


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
    ret.downloadStatus = [EnumTools downloadStatusFromInt:[aJson[@"fileStatus"] integerValue]];
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
    ret[@"fileStatus"] = @([EnumTools downloadStatusToInt:self.downloadStatus]);
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
    ret.downloadStatus = [EnumTools downloadStatusFromInt:[aJson[@"fileStatus"] integerValue]];
    return ret;
}

- (NSDictionary *)toJson {
    NSMutableDictionary *ret = [[super toJson] mutableCopy];
    ret[@"localPath"] = self.localPath;
    ret[@"displayName"] = self.displayName;
    ret[@"secret"] = self.secretKey;
    ret[@"remotePath"] = self.remotePath;
    ret[@"fileSize"] = @(self.fileLength);
    ret[@"fileStatus"] = [NSNumber numberWithInteger:[EnumTools downloadStatusToInt:self.downloadStatus]];
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

    EMImageMessageBody *ret = [[EMImageMessageBody alloc] initWithLocalPath:path
                                                           displayName:displayName];
    ret.secretKey = aJson[@"secret"];
    ret.remotePath = aJson[@"remotePath"];
    ret.fileLength = [aJson[@"fileSize"] longLongValue];
    ret.downloadStatus = [EnumTools downloadStatusFromInt:[aJson[@"fileStatus"] integerValue]];
    ret.thumbnailLocalPath = aJson[@"thumbnailLocalPath"];
    ret.thumbnailRemotePath = aJson[@"thumbnailRemotePath"];
    ret.thumbnailSecretKey = aJson[@"thumbnailSecret"];
    ret.size = CGSizeMake([aJson[@"width"] floatValue], [aJson[@"height"] floatValue]);
    ret.thumbnailDownloadStatus = [EnumTools downloadStatusFromInt:[aJson[@"thumbnailStatus"] integerValue]];
    ret.compressionRatio = [aJson[@"sendOriginalImage"] boolValue] ? 1.0 : 0.6;
    return ret;
}

- (NSDictionary *)toJson {
    NSMutableDictionary *ret = [[super toJson] mutableCopy];
    ret[@"thumbnailLocalPath"] = self.thumbnailLocalPath;
    ret[@"thumbnailRemotePath"] = self.thumbnailRemotePath;
    ret[@"thumbnailSecret"] = self.thumbnailSecretKey;
    ret[@"thumbnailStatus"] = [NSNumber numberWithInteger:[EnumTools downloadStatusToInt:self.thumbnailDownloadStatus]];
    ret[@"fileStatus"] = [NSNumber numberWithInteger:[EnumTools downloadStatusToInt:self.downloadStatus]];
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
    ret.thumbnailDownloadStatus = [EnumTools downloadStatusFromInt:[aJson[@"thumbnailStatus"] integerValue]];
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
    ret[@"thumbnailStatus"] = [NSNumber numberWithInteger:[EnumTools downloadStatusToInt:self.thumbnailDownloadStatus]];
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
    ret.downloadStatus = [EnumTools downloadStatusFromInt:[aJson[@"fileStatus"] integerValue]];
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
    ret[@"fileStatus"] = [NSNumber numberWithInteger:[EnumTools downloadStatusToInt:self.downloadStatus]];
    return ret;
}

@end
