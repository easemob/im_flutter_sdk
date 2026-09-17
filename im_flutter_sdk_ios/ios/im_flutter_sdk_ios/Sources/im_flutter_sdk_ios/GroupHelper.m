//
//  EMGroup+Helper.m
//  im_flutter_sdk
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
    ret[@"messageBlocked"] = @(self.isBlocked);
    ret[@"isAllMemberMuted"] = @(self.isMuteAllMembers);
    ret[@"isDisabled"] = @(self.isDisabled);
    ret[@"permissionType"] = [NSNumber numberWithInteger:[EnumTools groupPermissionTypeToInt:self.permissionType]];
    ret[@"isPublic"] = @(self.isPublic);

    if (self.settings != nil) {
        ret[@"configs"] = [self.settings toJson];
        ret[@"isJoinApprovalRequired"] = @(self.settings.joinApprovalRequired);
        ret[@"isMemberAllowToInvite"] = @(self.settings.allowInvites);
    }

    return ret;
}

@end

// 5.0.0
@implementation EMGroupConfigs (Helper)

- (NSDictionary *)toJson {
    return @{
        @"maxCount": @(self.maxUsers),
        @"inviteNeedConfirm": @(self.IsInviteNeedConfirm),
        @"ext": self.ext ?: [NSNull null],
        @"isPublic": @(self.isPublic),
        @"joinApprovalRequired": @(self.joinApprovalRequired),
        @"allowInvites": @(self.allowInvites)
    };
}

+ (EMGroupConfigs *)fromJson:(NSDictionary *)dict {
    EMGroupConfigs *configs = [[EMGroupConfigs alloc] init];
    configs.maxUsers = dict[@"maxCount"] ? [dict[@"maxCount"] integerValue] : 200;
    configs.IsInviteNeedConfirm = [dict[@"inviteNeedConfirm"] boolValue];
    id ext = dict[@"ext"];
    configs.ext = [ext isKindOfClass:[NSNull class]] ? nil : ext;
    configs.isPublic = [dict[@"isPublic"] boolValue];
    configs.joinApprovalRequired = [dict[@"joinApprovalRequired"] boolValue];
    configs.allowInvites = [dict[@"allowInvites"] boolValue];
    return configs;
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
