//
//  EMHelper.m
//  
//
//  Created by 杜洁鹏 on 2019/10/8.
//

#import "EMHelper.h"

@implementation EMHelper


#pragma mark - Message

+ (EMMessage *)dictionaryToMessage:(NSDictionary *)aDictionary {
    return nil;
}

+ (NSDictionary *)messageToDictionary:(EMMessage *)aMessage {
    return nil;
}

+ (NSArray *)dictionarysToMessages:(NSArray *)dicts {
    return nil;
}

+ (NSArray *)messagesToDictionarys:(NSArray *)messages {
    return nil;
}

+ (NSDictionary *)messagebodyToDictionary:(NSDictionary *)aDictionary {
    return nil;
}

#pragma mark - Conversation

+ (NSDictionary *)conversationToDictionary:(EMConversation *)aConversation {
    return [NSMutableDictionary dictionary];
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
                                   @"sharedFileList":[self groupFileListToDictionaryList:aGroup.sharedFileList],
                                   @"isPushNotificationEnabled":[NSNumber numberWithBool:aGroup.isPushNotificationEnabled],
                                   @"isPublic":[NSNumber numberWithBool:aGroup.isPublic],
                                   @"isMsgBlocked":[NSNumber numberWithBool:aGroup.isBlocked],
                                   @"permissionType":[NSNumber numberWithInt:type],
                                   @"occupants":aGroup.occupants,
                                   @"memberCount":[NSNumber numberWithInteger:aGroup.occupantsCount]
                                  };
       
       return groupDict;
}

+ (NSArray *)groupsToDictionarys:(NSArray *)groups {
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

+ (NSArray *)groupFileListToDictionaryList:(NSArray *)groupFileList
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

+ (NSArray *)chatRoomsToDictionarys:(NSArray *)chatRooms {
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
        @"data":[self chatRoomsToDictionarys:aPageResult.list],
        @"pageCount":[NSNumber numberWithInteger:aPageResult.count]
    };
    return resultDict;
}


@end
