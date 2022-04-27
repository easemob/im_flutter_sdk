//
//  EMChatroom+Flutter.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2020/9/27.
//

#import "EMChatroom+Helper.h"

@implementation EMChatroom (Helper)
- (NSDictionary *)toJson {
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    ret[@"roomId"] = self.chatroomId;
    ret[@"name"] = self.subject;
    ret[@"desc"] = self.description;
    ret[@"owner"] = self.owner;
    ret[@"maxUsers"] = @(self.maxOccupantsCount);
    ret[@"memberCount"] = @(self.occupantsCount);
    ret[@"adminList"] = self.adminList;
    ret[@"memberList"] = self.memberList;
    ret[@"blockList"] = self.blacklist;
    ret[@"muteList"] = self.muteList;
    ret[@"isAllMemberMuted"] = @(self.isMuteAllMembers);
    ret[@"announcement"] = self.announcement;
    ret[@"permissionType"] = @([self premissionTypeToInt:self.permissionType]);
    
    return ret;
}

- (int)premissionTypeToInt:(EMChatroomPermissionType)type {
    int ret = -1;
    switch (type) {
        case EMChatroomPermissionTypeNone:
        {
            ret = -1;
        }
            break;
        case EMChatroomPermissionTypeMember:
        {
            ret = 0;
        }
            break;
        case EMChatroomPermissionTypeAdmin:
        {
            ret = 1;
        }
            break;
        case EMChatroomPermissionTypeOwner:
        {
            ret = 2;
        }
            break;
        default:
            break;
    }
    return ret;
}
@end
