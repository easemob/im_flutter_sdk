//
//  EMHelper.m
//  
//
//  Created by 杜洁鹏 on 2019/10/8.
//

#import "EMHelper.h"
#import <Hyphenate/EMOptions+PrivateDeploy.h>

@implementation EMHelper

#pragma mark - EMOptions
+ (EMOptions *)dictionaryToEMOptions:(NSDictionary *)aDictionary
{
    EMOptions *options = [EMOptions optionsWithAppkey:aDictionary[@"appKey"]];
    if (aDictionary[@"acceptInvitationAlways"]) {
        options.isAutoAcceptFriendInvitation = [aDictionary[@"acceptInvitationAlways"] boolValue];
    }
    
    if (aDictionary[@"autoAcceptGroupInvitation"]) {
        options.isAutoAcceptGroupInvitation = [aDictionary[@"autoAcceptGroupInvitation"] boolValue];
    }
    
    if (aDictionary[@"requireDeliveryAck"]) {
        options.enableDeliveryAck = [aDictionary[@"requireDeliveryAck"] boolValue];
    }
    
    if (aDictionary[@"deleteMessagesAsExitGroup"]) {
        options.isDeleteMessagesWhenExitGroup = [aDictionary[@"deleteMessagesAsExitGroup"] boolValue];
    }
    
    if (aDictionary[@"isChatRoomOwnerLeaveAllowed"]) {
        options.isChatroomOwnerLeaveAllowed = [aDictionary[@"isChatRoomOwnerLeaveAllowed"] boolValue];
    }
    
    if (aDictionary[@"autoLogin"]) {
        options.isAutoLogin = [aDictionary[@"autoLogin"] boolValue];
    }
    
    if (aDictionary[@"sortMessageByServerTime"]) {
        options.sortMessageByServerTime = [aDictionary[@"sortMessageByServerTime"] boolValue];
    }
    
    if (aDictionary[@"enableDNSConfig"]) {
        options.enableDnsConfig = [aDictionary[@"enableDNSConfig"] boolValue];
    }
    
    if (aDictionary[@"dnsUrl"]) {
        options.dnsURL = aDictionary[@"dnsUrl"];
    }
    
    if (aDictionary[@"restServer"]) {
        options.restServer = aDictionary[@"restServer"];
    }
    
    if (aDictionary[@"imServer"]) {
        options.chatServer = aDictionary[@"imServer"];
    }
    
    if (aDictionary[@"imPort"]) {
        options.chatPort = [aDictionary[@"imPort"] intValue];
    }
    
    if (aDictionary[@"usingHttpsOnly"]) {
        options.usingHttpsOnly = [aDictionary[@"usingHttpsOnly"] boolValue];
    }
    
    if (aDictionary[@"serverTransfer"]) {
        options.isAutoTransferMessageAttachments = [aDictionary[@"serverTransfer"] boolValue];
    }
    
    if (aDictionary[@"isAutoDownload"]) {
        options.isAutoDownloadThumbnail = [aDictionary[@"isAutoDownload"] boolValue];
    }

    return options;
}

#pragma mark - Message

+ (EMMessage *)dictionaryToMessage:(NSDictionary *)aDictionary {
    NSLog(@"convertDataMapToMessage -- %@", aDictionary);
    
    EMMessage *ret = nil;
    EMMessageBody *body = nil;
    
    int type = [aDictionary[@"type"] intValue];
    EMChatType chatType = (EMChatType)[aDictionary[@"chatType"] intValue];
    NSString *to = aDictionary[@"to"];
    NSString *from = EMClient.sharedClient.currentUsername;
    NSDictionary *ext = aDictionary[@"attributes"];
    
    NSDictionary *msgBodyDict = aDictionary[@"body"];
    switch (type) {
        case 0:
        {
            NSString *content = msgBodyDict[@"message"];
            body = [[EMTextMessageBody alloc] initWithText:content];
            
        }
            break;
        case 1:
        {
            // TODO: size ?
            NSString *localUrl = msgBodyDict[@"localUrl"];
            long long fileLength = [msgBodyDict[@"fileLength"] longLongValue];
            body = [[EMImageMessageBody alloc] initWithLocalPath:localUrl
                                                     displayName:@""];
            ((EMImageMessageBody *)body).fileLength = fileLength;
        }
            break;
        case 2:
        {
            NSString *localUrl = msgBodyDict[@"localUrl"];
            int videoDuration = [msgBodyDict[@"videoDuration"] intValue];
            long long fileLength = [msgBodyDict[@"fileLength"] longLongValue];
            body = [[EMVideoMessageBody alloc] initWithLocalPath:localUrl
                                                     displayName:@""];
            ((EMVideoMessageBody *)body).fileLength = fileLength;
            ((EMVideoMessageBody *)body).duration = videoDuration;
        }
            break;
        case 3:
        {
            NSString *address = msgBodyDict[@"address"];
            double latitude = [msgBodyDict[@"latitude"] doubleValue];
            double longitude = [msgBodyDict[@"longitude"] doubleValue];
            body = [[EMLocationMessageBody alloc] initWithLatitude:latitude
                                                         longitude:longitude
                                                           address:address];
        }
            break;
        case 4:
        {
            NSString *localUrl = msgBodyDict[@"localUrl"];
            int voiceDuration = [msgBodyDict[@"voiceDuration"] intValue];
            long long fileLength = [msgBodyDict[@"fileLength"] longLongValue];
            body = [[EMVoiceMessageBody alloc] initWithLocalPath:localUrl displayName:@""];
            ((EMVoiceMessageBody *)body).duration = voiceDuration;
            ((EMVoiceMessageBody *)body).fileLength = fileLength;
        }
            break;
        case 5:
        {
            NSString *localUrl = msgBodyDict[@"localUrl"];
            long long fileLength = [msgBodyDict[@"fileLength"] longLongValue];
            body = [[EMFileMessageBody alloc] initWithLocalPath:localUrl displayName:@""];
            ((EMFileMessageBody *)body).fileLength = fileLength;
        }
            break;
        case 6:
        {
            NSString *action = msgBodyDict[@"action"];
            body = [[EMCmdMessageBody alloc] initWithAction:action];
        }
            break;
            
        default:
            break;
    }
    
    ret = [[EMMessage alloc] initWithConversationID:to
                                               from:from
                                                 to:to
                                               body:body
                                                ext:ext];
    ret.chatType = chatType;
    
    return nil;
}

+ (NSDictionary *)messageToDictionary:(EMMessage *)aMessage {
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    ret[@"attributes"] = aMessage.ext;
    ret[@"conversationId"] = aMessage.conversationId;
    ret[@"type"] = @([self getMessageType:aMessage]);
    ret[@"acked"] = @(aMessage.isReadAcked);
    ret[@"body"] = [self messageBodyToDictionary:aMessage.body];
    ret[@"chatType"] = @(aMessage.chatType);
    ret[@"delivered"] = @(aMessage.isDeliverAcked);
    ret[@"direction"] = @([self getMessageDirect:aMessage]);
    ret[@"from"] = aMessage.from;
    ret[@"localTime"] = [@(aMessage.localTime) stringValue];
    ret[@"msgId"] = aMessage.messageId;
    ret[@"msgTime"] = [@(aMessage.timestamp) stringValue];
    ret[@"status"] = @([self getMessageStatus:aMessage]);
    ret[@"to"] = aMessage.to;
    ret[@"unread"] = [NSNumber numberWithBool:!aMessage.isRead];
    
    return ret;
}

+ (NSDictionary *)messageBodyToDictionary:(EMMessageBody *)aBody {
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    ret[@"type"] = @([self messageBodyTypeToInt:aBody.type]);
    switch (aBody.type) {
        case EMMessageBodyTypeText:
        {
            ret[@"message"] = ((EMTextMessageBody *)aBody).text;
        }
            break;
        case EMMessageBodyTypeImage:
        {
            ret[@"displayName"] = ((EMImageMessageBody *)aBody).displayName;
            ret[@"downloadStatus"] = @(((EMImageMessageBody *)aBody).downloadStatus);
            ret[@"localUrl"] = ((EMImageMessageBody *)aBody).localPath;
            ret[@"remoteUrl"] = ((EMImageMessageBody *)aBody).remotePath;
            ret[@"fileLength"] = @(((EMImageMessageBody *)aBody).fileLength);
            
            ret[@"height"] = @(((EMImageMessageBody *)aBody).size.height);
            ret[@"width"] = @(((EMImageMessageBody *)aBody).size.width);
            ret[@"thumbnailLocalPath"] = ((EMImageMessageBody *)aBody).thumbnailLocalPath;
            ret[@"thumbnailUrl"] = ((EMImageMessageBody *)aBody).thumbnailRemotePath;
        }
            break;
        case EMMessageBodyTypeVideo:
        {
            ret[@"displayName"] = ((EMVideoMessageBody *)aBody).displayName;
            ret[@"downloadStatus"] = @(((EMVideoMessageBody *)aBody).downloadStatus);
            ret[@"localUrl"] = ((EMVideoMessageBody *)aBody).localPath;
            ret[@"remoteUrl"] = ((EMVideoMessageBody *)aBody).remotePath;
            ret[@"fileLength"] = @(((EMVideoMessageBody *)aBody).fileLength);
            
            ret[@"videoDuration"] = @(((EMVideoMessageBody *)aBody).duration);
            ret[@"localThumb"] = ((EMVideoMessageBody *)aBody).thumbnailLocalPath;
            ret[@"thumbnailHeight"] = @(((EMVideoMessageBody *)aBody).thumbnailSize.height);
            ret[@"thumbnailWidth"] = @(((EMVideoMessageBody *)aBody).thumbnailSize.width);
            ret[@"thumbnailUrl"] = ((EMVideoMessageBody *)aBody).thumbnailRemotePath;
        }
            break;
        case EMMessageBodyTypeLocation:
        {
            ret[@"address"] = ((EMLocationMessageBody *)aBody).address;
            ret[@"latitude"] = @(((EMLocationMessageBody *)aBody).latitude);
            ret[@"longitude"] = @(((EMLocationMessageBody *)aBody).longitude);
        }
            break;
        case EMMessageBodyTypeVoice:
        {
            ret[@"displayName"] = ((EMVoiceMessageBody *)aBody).displayName;
            ret[@"downloadStatus"] = @(((EMVoiceMessageBody *)aBody).downloadStatus);
            ret[@"localUrl"] = ((EMVoiceMessageBody *)aBody).localPath;
            ret[@"remoteUrl"] = ((EMVoiceMessageBody *)aBody).remotePath;
            ret[@"fileLength"] = @(((EMVoiceMessageBody *)aBody).fileLength);
            
            ret[@"voiceDuration"] = @(((EMVoiceMessageBody *)aBody).duration);
        }
            break;
        case EMMessageBodyTypeFile:
        {
            ret[@"displayName"] = ((EMFileMessageBody *)aBody).displayName;
            ret[@"downloadStatus"] = @(((EMFileMessageBody *)aBody).downloadStatus);
            ret[@"localUrl"] = ((EMFileMessageBody *)aBody).localPath;
            ret[@"remoteUrl"] = ((EMFileMessageBody *)aBody).remotePath;
            ret[@"fileLength"] = @(((EMFileMessageBody *)aBody).fileLength);
        }
            break;
        case EMMessageBodyTypeCmd:
        {
            ret[@"action"] = ((EMCmdMessageBody *)aBody).action;
            ret[@"isDeliverOnlineOnly"] = @(((EMCmdMessageBody *)aBody).isDeliverOnlineOnly);
        }
            break;
            
        default:
            break;
    }
    return ret;
}

+ (NSArray *)dictionariesToMessages:(NSArray *)dicts {
    NSMutableArray *ret = [NSMutableArray array];
    for (NSDictionary *dict in dicts) {
        [ret addObject:[self dictionaryToMessage:dict]];
    }
    return ret;
}

+ (NSArray *)messagesToDictionaries:(NSArray *)messages {
    NSMutableArray *ret = [NSMutableArray array];
    for (EMMessage *msg in messages) {
        [ret addObject:[self messageToDictionary:msg]];
    }
    return ret;
}


#pragma mark - Conversation

+ (NSDictionary *)conversationToDictionary:(EMConversation *)aConversation {
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    ret[@"id"] = aConversation.conversationId;
    ret[@"type"] = @([self conversationTypeToInt:aConversation.type]);
    ret[@"ext"] = aConversation.ext;
    return ret;
}


+ (int)conversationTypeToInt:(EMConversationType)aType {
    int ret = 0;
    switch (aType) {
        case EMConversationTypeChat:
            ret = 0;
            break;
        case EMConversationTypeGroupChat:
            ret = 1;
            break;
        case EMConversationTypeChatRoom:
            ret = 2;
            break;
        default:
            break;
    }
    return ret;
}

#pragma mark - Group

+ (NSDictionary *)groupToDictionary:(EMGroup *)aGroup {
     EMGroupOptions *options = aGroup.setting;
       EMGroupStyle style = options.style;
       BOOL isMemberAllowToInvite;
       BOOL isMemberOnly;
       if (style == EMGroupStylePrivateOnlyOwnerInvite) {
           isMemberAllowToInvite = NO;
           isMemberOnly = NO;
       } else if (style == EMGroupStylePrivateMemberCanInvite) {
           isMemberAllowToInvite = YES;
           isMemberOnly = NO;
       } else if (style == EMGroupStylePublicJoinNeedApproval) {
           isMemberAllowToInvite = NO;
           isMemberOnly = YES;
       } else {
           isMemberAllowToInvite = NO;
           isMemberOnly = NO;
       }

       EMGroupPermissionType permissionType = aGroup.permissionType;
       int type;
       if (permissionType == EMGroupPermissionTypeNone) {
           type = -1;
       } else if (permissionType == EMGroupPermissionTypeMember) {
           type = 0;
       } else if (permissionType == EMGroupPermissionTypeAdmin) {
           type = 1;
       } else {
           type = 2;
       }
       
       NSDictionary *groupDict = @{@"groupId":aGroup.groupId,
                                   @"groupName":aGroup.subject,
                                   @"description":aGroup.description,
                                   @"announcement":aGroup.announcement,
                                   @"isMemberAllowToInvite":[NSNumber numberWithBool:isMemberAllowToInvite],
                                   @"isMemberOnly":[NSNumber numberWithBool:isMemberOnly],
                                   @"maxUserCount":[NSNumber numberWithInteger:options.maxUsersCount],
                                   @"owner":aGroup.owner,
                                   @"adminList":aGroup.adminList,
                                   @"members":aGroup.memberList,
                                   @"blackList":aGroup.blacklist,
                                   @"muteList":aGroup.muteList,
                                   @"extension":options.ext,
                                   @"sharedFileList":[self groupFileListToDictionaries:aGroup.sharedFileList],
                                   @"isPushNotificationEnabled":[NSNumber numberWithBool:aGroup.isPushNotificationEnabled],
                                   @"isPublic":[NSNumber numberWithBool:aGroup.isPublic],
                                   @"isMsgBlocked":[NSNumber numberWithBool:aGroup.isBlocked],
                                   @"permissionType":[NSNumber numberWithInt:type],
                                   @"occupants":aGroup.occupants,
                                   @"memberCount":[NSNumber numberWithInteger:aGroup.occupantsCount]
                                  };
       
       return groupDict;
}

+ (NSArray *)groupsToDictionaries:(NSArray *)groups {
    NSMutableArray *ret = [NSMutableArray array];
    for (EMGroup *group in groups) {
        NSDictionary *dict = [self groupToDictionary:group];
        [ret addObject:dict];
    }
    return ret;
}

+ (NSDictionary *)groupSharedFileToDictionary:(EMGroupSharedFile *)sharedFile
{
    NSDictionary *sharedFileDict = @{@"fileId":sharedFile.fileId,
                                     @"fileName":sharedFile.fileName,
                                     @"fileOwner":sharedFile.fileOwner,
                                     @"createTime":[NSNumber numberWithLongLong:sharedFile.createTime],
                                     @"fileSize":[NSNumber numberWithLongLong:sharedFile.fileSize]
                                    };
    return sharedFileDict;
}

+ (NSArray *)groupFileListToDictionaries:(NSArray *)groupFileList
{
    NSMutableArray *sharedFileMutableArray = [NSMutableArray array];
    for (EMGroupSharedFile *sharedFile in groupFileList) {
        [sharedFileMutableArray addObject:[self groupSharedFileToDictionary:sharedFile]];
    }
    return [NSArray arrayWithArray:sharedFileMutableArray];
}

#pragma mark - ChatRoom

+ (NSDictionary *)chatRoomToDictionary:(EMChatroom *)aChatRoom {
    EMChatroomPermissionType permissionType = aChatRoom.permissionType;
    int type;
    if (permissionType == EMChatroomPermissionTypeNone) {
        type = -1;
    } else if (permissionType == EMChatroomPermissionTypeMember) {
        type = 0;
    } else if (permissionType == EMChatroomPermissionTypeAdmin) {
        type = 1;
    } else {
        type = 2;
    }
    
    // @"permissionType":[NSNumber numberWithInt:type],
    NSDictionary *chatRoomDitc = @{@"roomId":aChatRoom.chatroomId,
                                @"roomName":aChatRoom.subject,
                                @"description":aChatRoom.description,
                                @"owner":aChatRoom.owner,
                                @"announcement":aChatRoom.announcement,
                                @"administratorList":aChatRoom.adminList,
                                @"memberList":aChatRoom.memberList,
                                @"blockList":aChatRoom.blacklist,
                                @"muteList":aChatRoom.muteList,
                                @"maxUserCount":[NSNumber numberWithInteger:aChatRoom.maxOccupantsCount],
                                @"affiliationsCount":[NSNumber numberWithInteger:aChatRoom.occupantsCount]
                               };
    
    return chatRoomDitc;
}

+ (NSArray *)chatRoomsToDictionaries:(NSArray *)chatRooms {
    NSMutableArray *ret = [NSMutableArray array];
    for (EMChatroom *chatRoom in chatRooms) {
        NSDictionary *dict = [self chatRoomToDictionary:chatRoom];
        [ret addObject:dict];
    }
    return ret;
}
#pragma mark - Others

+ (NSDictionary *)pageReslutToDictionary:(EMPageResult *)aPageResult {
    NSDictionary *resultDict = @{
        @"data":[self chatRoomsToDictionaries:aPageResult.list],
        @"pageCount":[NSNumber numberWithInteger:aPageResult.count]
    };
    return resultDict;
}

#pragma mark - Private
+ (int)getMessageType:(EMMessage *)aMessage {
    int ret = 0;
    EMMessageBodyType type = aMessage.body.type;
    switch (type) {
        case EMMessageBodyTypeText:
            ret = 0;
            break;
        case EMMessageBodyTypeImage:
            ret = 1;
            break;
        case EMMessageBodyTypeVideo:
            ret = 2;
            break;
        case EMMessageBodyTypeLocation:
            ret = 3;
            break;
        case EMMessageBodyTypeVoice:
            ret = 4;
            break;
        case EMMessageBodyTypeFile:
            ret = 5;
            break;
        case EMMessageBodyTypeCmd:
            ret = 6;
            break;
        default:
            break;
    }
    return ret;
}

+ (int)getMessageDirect:(EMMessage *)aMessage {
    return aMessage.direction == EMMessageDirectionSend ? 0 : 1;
}

+ (int)getMessageStatus:(EMMessage *)aMessage {
    int ret = 0;
    switch (aMessage.status) {
        case EMMessageStatusSucceed:
        {
            ret = 0;
        }
            break;
        case EMMessageStatusFailed:
        {
            ret = 1;
        }
            break;
        case EMMessageStatusPending:
        {
            ret = 2;
        }
            break;
        default:
            ret = 3;
            break;
    }
    return ret;
}

+ (int)messageBodyTypeToInt:(EMMessageBodyType)aType {
    int ret = 0;
    switch (aType) {
        case EMMessageBodyTypeText:
        {
            ret = 0;
        }
            break;
        case EMMessageBodyTypeImage:
        {
            ret = 1;
        }
            break;
        case EMMessageBodyTypeVideo:
        {
            ret = 2;
        }
            break;
        case EMMessageBodyTypeLocation:
        {
            ret = 3;
        }
            break;
        case EMMessageBodyTypeVoice:
        {
            ret = 4;
        }
            break;
        case EMMessageBodyTypeFile:
        {
            ret = 5;
        }
            break;
        case EMMessageBodyTypeCmd:
        {
            ret = 6;
        }
            break;
        default:
            break;
    }
    return ret;
}
@end
