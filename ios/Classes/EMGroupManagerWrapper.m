//
//  EMGroupManagerWrapper.m
//  FlutterTest
//
//  Created by 杜洁鹏 on 2019/10/17.
//  Copyright © 2019 Easemob. All rights reserved.
//

#import "EMGroupManagerWrapper.h"
#import <Hyphenate/Hyphenate.h>
#import "EMSDKMethod.h"

typedef enum : NSUInteger {
    GROUP_INVITATION_RECEIVE = 0,       // 用户A邀请用户B入群,用户B接收到该回调
    GROUP_INVITATION_ACCEPT,            // 用户B同意用户A的入群邀请后，用户A接收到该回调
    GROUP_INVITATION_DECLINE,           // 用户B拒绝用户A的入群邀请后，用户A接收到该回调
    GROUP_AUTOMATIC_AGREE_JOIN,         // SDK自动同意了用户A的加B入群邀请后，用户B接收到该回调，需要设置EMOptions的isAutoAcceptGroupInvitation为YES
    GROUP_LEAVE,                        // 离开群组回调
    GROUP_JOIN_GROUP_REQUEST_RECEIVE,   // 群组的群主收到用户的入群申请，群的类型是EMGroupStylePublicJoinNeedApproval
    GROUP_JOIN_GROUP_REQUEST_DECLINE,   // 群主拒绝用户A的入群申请后，用户A会接收到该回调，群的类型是EMGroupStylePublicJoinNeedApproval
    GROUP_JOIN_GROUP_REQUEST_APPROVE,   // 群主同意用户A的入群申请后，用户A会接收到该回调，群的类型是EMGroupStylePublicJoinNeedApproval
    GROUP_LIST_UPDATE,                  // 群组列表发生变化
    GROUP_MUTE_LIST_UPDATE_ADDED,       // 有成员被加入禁言列表
    GROUP_MUTE_LIST_UPDATE_REMOVED,     // 有成员被移出禁言列表
    GROUP_ADMIN_LIST_UPDATE_ADDED,      // 有成员被加入管理员列表
    GROUP_ADMIN_LIST_UPDATE_REMOVED,    // 有成员被移出管理员列表
    GROUP_OWNER_UPDATE,                 // 群组创建者有更新
    GROUP_USER_JOIN,                    // 有用户加入群组
    GROUP_USER_LEAVE,                   // 有用户离开群组
    GROUP_ANNOUNCEMENT_UPDATE,          // 群公告有更新
    GROUP_FILE_LIST_UPDATE_ADDED,       // 有用户上传群共享文件
    GROUP_FILE_LIST_UPDATE_REMOVED,     // 有用户删除群共享文件
} EMGroupEvent;
@interface EMGroupManagerWrapper () <EMGroupManagerDelegate>

@end

@implementation EMGroupManagerWrapper

- (instancetype)initWithChannelName:(NSString *)aChannelName
                          registrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    if(self = [super initWithChannelName:aChannelName
                                   registrar:registrar]) {
        
        [EMClient.sharedClient.groupManager addDelegate:self delegateQueue:nil];
    }
    return self;
}


#pragma mark - FlutterPlugin

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    
    result(FlutterMethodNotImplemented);
}

#pragma mark - EMGroupManagerDelegate


- (void)groupInvitationDidReceive:(NSString *)aGroupId
                          inviter:(NSString *)aInviter
                          message:(NSString *)aMessage {
    NSDictionary *map = @{
            @"type":@(GROUP_INVITATION_RECEIVE),
            @"groupId":aGroupId,
            @"inviter":aInviter,
            @"message":aMessage
        };
    [self.channel invokeMethod:EMMethodKeyOnGroupChanged
                         arguments:map];

}

- (void)groupInvitationDidAccept:(EMGroup *)aGroup
                         invitee:(NSString *)aInvitee {
    NSDictionary *map = @{
            @"type":@(GROUP_INVITATION_ACCEPT),
            @"group":aGroup,
            @"invitee":aInvitee
        };
    [self.channel invokeMethod:EMMethodKeyOnGroupChanged
                         arguments:map];

}

- (void)groupInvitationDidDecline:(EMGroup *)aGroup
                          invitee:(NSString *)aInvitee
                           reason:(NSString *)aReason {
    NSDictionary *map = @{
                @"type":@(GROUP_INVITATION_DECLINE),
                @"group":aGroup,
                @"invitee":aInvitee,
                @"reason":aReason
            };
    [self.channel invokeMethod:EMMethodKeyOnGroupChanged
                             arguments:map];
}

- (void)didJoinGroup:(EMGroup *)aGroup
                inviter:(NSString *)aInviter
                message:(NSString *)aMessage {
    NSDictionary *map = @{
                @"type":@(GROUP_AUTOMATIC_AGREE_JOIN),
                @"group":aGroup,
                @"inviter":aInviter
            };
    [self.channel invokeMethod:EMMethodKeyOnGroupChanged
                             arguments:map];
}

- (void)didLeaveGroup:(EMGroup *)aGroup
               reason:(EMGroupLeaveReason)aReason {
    NSString *reason;
    if (aReason == EMGroupLeaveReasonBeRemoved) {
       reason = @"被移除出群组";
    } else if (aReason == EMGroupLeaveReasonUserLeave) {
       reason = @"自己主动离开群组";
    } else {
       reason = @"群组销毁";
    }
    NSDictionary *map = @{
                    @"type":@(GROUP_LEAVE),
                    @"reason":reason
                };
    [self.channel invokeMethod:EMMethodKeyOnGroupChanged
                                 arguments:map];
}

- (void)joinGroupRequestDidReceive:(EMGroup *)aGroup
                              user:(NSString *)aUsername
                            reason:(NSString *)aReason {
    NSDictionary *map = @{
                    @"type":@(GROUP_JOIN_GROUP_REQUEST_RECEIVE),
                    @"group":aGroup,
                    @"user":aUsername,
                    @"reason":aReason
                };
    [self.channel invokeMethod:EMMethodKeyOnGroupChanged
                                 arguments:map];
}

- (void)joinGroupRequestDidDecline:(NSString *)aGroupId
                            reason:(NSString *)aReason {
    NSDictionary *map = @{
                    @"type":@(GROUP_JOIN_GROUP_REQUEST_DECLINE),
                    @"groupId":aGroupId,
                    @"reason":aReason
                };
    [self.channel invokeMethod:EMMethodKeyOnGroupChanged
                                 arguments:map];
}

- (void)joinGroupRequestDidApprove:(EMGroup *)aGroup {
    NSDictionary *map = @{
                    @"type":@(GROUP_JOIN_GROUP_REQUEST_APPROVE),
                    @"group":aGroup
                };
    [self.channel invokeMethod:EMMethodKeyOnGroupChanged
                                 arguments:map];
}

- (void)groupListDidUpdate:(NSArray *)aGroupList {
    NSDictionary *map = @{
                    @"type":@(GROUP_LIST_UPDATE),
                    @"groupList":aGroupList
                };
    [self.channel invokeMethod:EMMethodKeyOnGroupChanged
                                 arguments:map];
}

- (void)groupMuteListDidUpdate:(EMGroup *)aGroup
             addedMutedMembers:(NSArray *)aMutedMembers
                    muteExpire:(NSInteger)aMuteExpire {
    NSDictionary *map = @{
                    @"type":@(GROUP_MUTE_LIST_UPDATE_ADDED),
                    @"group":aGroup,
                    @"mutedMembers":aMutedMembers,
                    @"muteExpire":[NSNumber numberWithInteger:aMuteExpire]
                };
    [self.channel invokeMethod:EMMethodKeyOnGroupChanged
                                 arguments:map];
}

- (void)groupMuteListDidUpdate:(EMGroup *)aGroup
           removedMutedMembers:(NSArray *)aMutedMembers {
    NSDictionary *map = @{
                    @"type":@(GROUP_MUTE_LIST_UPDATE_REMOVED),
                    @"group":aGroup,
                    @"mutedMembers":aMutedMembers
                };
    [self.channel invokeMethod:EMMethodKeyOnGroupChanged
                                 arguments:map];
}

- (void)groupAdminListDidUpdate:(EMGroup *)aGroup
                     addedAdmin:(NSString *)aAdmin {
    NSDictionary *map = @{
                    @"type":@(GROUP_ADMIN_LIST_UPDATE_ADDED),
                    @"group":aGroup,
                    @"admin":aAdmin
                };
    [self.channel invokeMethod:EMMethodKeyOnGroupChanged
                                 arguments:map];
}

- (void)groupAdminListDidUpdate:(EMGroup *)aGroup
                   removedAdmin:(NSString *)aAdmin {
    NSDictionary *map = @{
                    @"type":@(GROUP_ADMIN_LIST_UPDATE_REMOVED),
                    @"group":aGroup,
                    @"admin":aAdmin
                };
    [self.channel invokeMethod:EMMethodKeyOnGroupChanged
                                 arguments:map];
}

- (void)groupOwnerDidUpdate:(EMGroup *)aGroup
                   newOwner:(NSString *)aNewOwner
                   oldOwner:(NSString *)aOldOwner {
    NSDictionary *map = @{
                    @"type":@(GROUP_OWNER_UPDATE),
                    @"group":aGroup,
                    @"newOwner":aNewOwner,
                    @"oldOwner":aOldOwner
                };
    [self.channel invokeMethod:EMMethodKeyOnGroupChanged
                                 arguments:map];
}

- (void)userDidJoinGroup:(EMGroup *)aGroup
                    user:(NSString *)aUsername {
    NSDictionary *map = @{
                    @"type":@(GROUP_USER_JOIN),
                    @"group":aGroup,
                    @"username":aUsername
                };
    [self.channel invokeMethod:EMMethodKeyOnGroupChanged
                                 arguments:map];
}

- (void)userDidLeaveGroup:(EMGroup *)aGroup
                     user:(NSString *)aUsername {
    NSDictionary *map = @{
                    @"type":@(GROUP_USER_LEAVE),
                    @"group":aGroup,
                    @"username":aUsername
                };
    [self.channel invokeMethod:EMMethodKeyOnGroupChanged
                                 arguments:map];
}

- (void)groupAnnouncementDidUpdate:(EMGroup *)aGroup
                      announcement:(NSString *)aAnnouncement {
    NSDictionary *map = @{
                    @"type":@(GROUP_ANNOUNCEMENT_UPDATE),
                    @"group":aGroup,
                    @"announcement":aAnnouncement
                };
    [self.channel invokeMethod:EMMethodKeyOnGroupChanged
                                 arguments:map];
}

- (void)groupFileListDidUpdate:(EMGroup *)aGroup
               addedSharedFile:(EMGroupSharedFile *)aSharedFile {
    NSDictionary *map = @{
                    @"type":@(GROUP_FILE_LIST_UPDATE_ADDED),
                    @"group":aGroup,
                    @"sharedFile":aSharedFile
                };
    [self.channel invokeMethod:EMMethodKeyOnGroupChanged
                                 arguments:map];
}

- (void)groupFileListDidUpdate:(EMGroup *)aGroup
               removedSharedFile:(NSString *)aFileId {
    NSDictionary *map = @{
                    @"type":@(GROUP_FILE_LIST_UPDATE_REMOVED),
                    @"group":aGroup,
                    @"file":aFileId
                };
    [self.channel invokeMethod:EMMethodKeyOnGroupChanged
                                 arguments:map];
}


@end
