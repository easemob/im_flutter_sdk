//
//  EMChatroom+Flutter.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2020/9/27.
//

#import "ChatroomHelper.h"
#import "EnumTools.h"

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
    ret[@"permissionType"] = [NSNumber numberWithInteger:[EnumTools chatRoomPermissionTypeToInt:self.permissionType]];
    ret[@"muteExpireTimestamp"] = @(self.muteExpireTimestamp);
    ret[@"isInWhitelist"] = @(self.isInWhitelist);
    ret[@"createTimestamp"] = @(self.createTimestamp);
    
    return ret;
}

@end
