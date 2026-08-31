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
        // 5.0 移除 isMemberOnly（4.x 字段）—— 群类型用 isPublic/isJoinApprovalRequired
        ret[@"isPublic"] = @(self.isPublic);
        ret[@"joinApprovalRequired"] = @(self.settings.joinApprovalRequired);
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
    ret[@"inviteNeedConfirm"] = @(self.IsInviteNeedConfirm);
    // iOS 5.0 使用三个布尔字段，与 Android 5.0 GroupOptionsHelper 对齐。
    ret[@"isPublic"] = @(self.isPublic);
    ret[@"joinApprovalRequired"] = @(self.joinApprovalRequired);
    ret[@"allowInvites"] = @(self.allowInvites);
    return ret;
}

+ (EMGroupConfigs *)fromJson:(NSDictionary *)dict {
    EMGroupConfigs *options = [[EMGroupConfigs alloc] init];
    options.maxUsers = [dict[@"maxCount"] intValue];
    options.ext = dict[@"ext"];
    options.IsInviteNeedConfirm = [dict[@"inviteNeedConfirm"] boolValue];
    // iOS 5.0 使用 EMGroupConfigs 三布尔字段；style 仅属于 4.x 协议。
    options.isPublic = [dict[@"isPublic"] boolValue];
    options.joinApprovalRequired = [dict[@"joinApprovalRequired"] boolValue];
    options.allowInvites = [dict[@"allowInvites"] boolValue];
    return options;
}

@end


@implementation EMGroupSharedFile (Helper)
- (NSDictionary *)toJson {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"fileId"] = self.fileId;
    // 共享文件列表和 onGroupSharedFileAdded 事件与 Android 保持一致，字段名为 name。
    data[@"name"] = self.fileName;
    data[@"owner"] = self.fileOwner;
    data[@"createTime"] = @(self.createdAt);
    data[@"fileSize"] = @(self.fileSize);
    return data;
}

@end
