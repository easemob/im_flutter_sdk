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
    ret[@"desc"] = self.description;
    ret[@"owner"] = self.owner;
    ret[@"announcement"] = self.announcement;
    ret[@"memberCount"] = @(self.occupantsCount);
    ret[@"memberList"] = self.memberList;
    ret[@"adminList"] = self.adminList;
    ret[@"blockList"] = self.blacklist;
    ret[@"muteList"] = self.muteList;
    ret[@"noticeEnable"] = @(self.isPushNotificationEnabled);
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
    
    if (self.settings.style == EMGroupStylePrivateOnlyOwnerInvite ||
        self.settings.style == EMGroupStylePrivateMemberCanInvite ||
        self.settings.style == EMGroupStylePublicJoinNeedApproval) {
        return YES;
    }

    return NO;
}

- (BOOL)isMemberAllowToInvite {
    return self.settings.style == EMGroupStylePrivateMemberCanInvite;
}


@end

@implementation EMGroupOptions (Helper)
- (NSDictionary *)toJson {
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    ret[@"maxCount"] = @(self.maxUsers);
    ret[@"ext"] = self.ext;
    ret[@"style"] = @([EMGroupOptions styleToInt:self.style]);
    ret[@"inviteNeedConfirm"] = @(self.IsInviteNeedConfirm);
    return ret;
}

+ (EMGroupOptions *)fromJson:(NSDictionary *)dict {
    EMGroupOptions *options = [[EMGroupOptions alloc] init];
    options.maxUsers = [dict[@"maxCount"] intValue];
    options.ext = dict[@"ext"];
    options.IsInviteNeedConfirm = [dict[@"inviteNeedConfirm"] boolValue];
    options.style = [EMGroupOptions styleFromInt:[dict[@"style"] intValue]];
    return options;
}

+ (EMGroupStyle)styleFromInt:(int)style {
    EMGroupStyle ret = EMGroupStylePrivateOnlyOwnerInvite;
    switch (style) {
        case 0:{
            ret = EMGroupStylePrivateOnlyOwnerInvite;
        }
            break;
        case 1:{
            ret = EMGroupStylePrivateMemberCanInvite;
        }
            break;
        case 2:{
            ret = EMGroupStylePublicJoinNeedApproval;
        }
            break;
        case 3:{
            ret = EMGroupStylePublicOpenJoin;
        }
            break;
        default:
            break;
    }
    
    return ret;
}

+ (int)styleToInt:(EMGroupStyle)style {
    int ret = 0;
    switch (style) {
        case EMGroupStylePrivateOnlyOwnerInvite:{
            ret = 0;
        }
            break;
        case EMGroupStylePrivateMemberCanInvite:{
            ret = 1;
        }
            break;
        case EMGroupStylePublicJoinNeedApproval:{
            ret = 2;
        }
            break;
        case EMGroupStylePublicOpenJoin:{
            ret = 3;
        }
            break;
        default:
            break;
    }
    
    return ret;
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
