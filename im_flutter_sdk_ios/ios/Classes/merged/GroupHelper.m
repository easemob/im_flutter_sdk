//
//  EMGroup+Flutter.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2020/9/28.
//

#import "GroupHelper.h"
#import "EnumTools.h"

@implementation EMGroup (Helper)


- (NSDictionary *)toJson {
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    ret[@"groupId"] = self.groupId;
    ret[@"name"] = self.groupName;
    ret[@"avatarUrl"] = self.groupAvatar;
    ret[@"desc"] = self.description;
    ret[@"owner"] = self.owner;
    ret[@"announcement"] = self.announcement;
    ret[@"memberCount"] = @(self.occupantsCount);
    ret[@"memberList"] = self.memberList;
    ret[@"adminList"] = self.adminList;
    ret[@"blockList"] = self.blacklist;
    ret[@"muteList"] = self.muteList;
    ret[@"noticeEnable"] = @(NO); // 5.0 移除 isPushNotificationEnabled
    ret[@"messageBlocked"] = @(self.isBlocked);
    ret[@"isAllMemberMuted"] = @(self.isMuteAllMembers);
    ret[@"isDisabled"] = @(self.isDisabled);
    ret[@"permissionType"] = [NSNumber numberWithInteger:[EnumTools groupPermissionTypeToInt:self.permissionType]];
    
    if (self.settings != nil) {
        ret[@"maxUserCount"] = @(self.settings.maxUsers);
        ret[@"isMemberOnly"] = @([self isMemberOnly]);
        ret[@"isMemberAllowToInvite"] = @([self isMemberAllowToInvite]);
        ret[@"ext"] = self.settings.ext;
    }
    
    return ret;
}


- (BOOL)isMemberOnly {
    // 5.0 群类型改为 isPublic / joinApprovalRequired / allowInvites
    return !self.settings.isPublic || self.settings.joinApprovalRequired;
}

- (BOOL)isMemberAllowToInvite {
    return self.settings.allowInvites;
}


@end

@implementation EMGroupConfigs (Helper)
- (NSDictionary *)toJson {
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    ret[@"maxCount"] = @(self.maxUsers);
    ret[@"ext"] = self.ext;
    ret[@"style"] = @(self.isPublic ? 2 : 0);
    ret[@"inviteNeedConfirm"] = @(self.IsInviteNeedConfirm);
    return ret;
}

+ (EMGroupConfigs *)fromJson:(NSDictionary *)dict {
    EMGroupConfigs *options = [[EMGroupConfigs alloc] init];
    options.maxUsers = [dict[@"maxCount"] intValue];
    options.ext = dict[@"ext"];
    options.IsInviteNeedConfirm = [dict[@"inviteNeedConfirm"] boolValue];
    options.isPublic = [dict[@"style"] intValue] >= 2;
    return options;
}

@end


@implementation EMGroupSharedFile (Helper)
- (NSDictionary *)toJson {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"fileId"] = self.fileId;
    data[@"name"] = self.fileName;
    data[@"owner"] = self.fileOwner;
    data[@"createTime"] = @(self.createdAt);
    data[@"fileSize"] = @(self.fileSize);
    return data;
}

@end
