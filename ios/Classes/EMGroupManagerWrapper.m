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
    if (![call.arguments isKindOfClass:[NSDictionary class]]) {
            NSLog(@"wrong type");
            return;
        }
        if ([EMMethodKeyGetJoinedGroups isEqualToString:call.method]) {
            [self getJoinedGroups:call.arguments result:result];
        } else if ([EMMethodKeyGetGroupsWithoutPushNotification isEqualToString:call.method]) {
            [self getGroupsWithoutPushNotification :call.arguments result:result];
        } else if ([EMMethodKeyGetJoinedGroupsFromServer isEqualToString:call.method]) {
            [self getJoinedGroupsFromServer:call.arguments result:result];
        } else if ([EMMethodKeyGetPublicGroupsFromServer isEqualToString:call.method]) {
            [self getPublicGroupsFromServer:call.arguments result:result];
        } else if ([EMMethodKeySearchPublicGroup isEqualToString:call.method]) {
            [self searchPublicGroup:call.arguments result:result];
        } else if ([EMMethodKeyCreateGroup isEqualToString:call.method]) {
            [self createGroup:call.arguments result:result];
        } else if ([EMMethodKeyGetGroupSpecificationFromServer isEqualToString:call.method]) {
            [self getGroupSpecificationFromServer:call.arguments result:result];
        } else if ([EMMethodKeyGetGroupMemberListFromServer isEqualToString:call.method]) {
            [self getGroupMemberListFromServer:call.arguments result:result];
        } else if ([EMMethodKeyGetGroupBlacklistFromServer isEqualToString:call.method]) {
            [self getGroupBlacklistFromServer:call.arguments result:result];
        } else if ([EMMethodKeyGetGroupMuteListFromServer isEqualToString:call.method]) {
            [self getGroupMuteListFromServer:call.arguments result:result];
        } else if ([EMMethodKeyGetGroupFileList isEqualToString:call.method]) {
            [self getGroupFileList:call.arguments result:result];
        } else if ([EMMethodKeyGetGroupAnnouncement isEqualToString:call.method]) {
            [self getGroupAnnouncement:call.arguments result:result];
        } else if ([EMMethodKeyAddMembers isEqualToString:call.method]) {
            [self addMembers:call.arguments result:result];
        } else if ([EMMethodKeyRemoveMembers isEqualToString:call.method]) {
            [self removeMembers:call.arguments result:result];
        } else if ([EMMethodKeyBlockMembers isEqualToString:call.method]) {
            [self blockMembers:call.arguments result:result];
        } else if ([EMMethodKeyUnblockMembers isEqualToString:call.method]) {
            [self unblockMembers:call.arguments result:result];
        } else if ([EMMethodKeyUpdateGroupSubject isEqualToString:call.method]) {
            [self updateGroupSubject:call.arguments result:result];
        } else if ([EMMethodKeyUpdateDescription isEqualToString:call.method]) {
            [self updateDescription:call.arguments result:result];
        } else if ([EMMethodKeyLeaveGroup isEqualToString:call.method]) {
            [self leaveGroup:call.arguments result:result];
        } else if ([EMMethodKeyDestroyGroup isEqualToString:call.method]) {
            [self destroyGroup:call.arguments result:result];
        } else if ([EMMethodKeyBlockGroup isEqualToString:call.method]) {
            [self blockGroup:call.arguments result:result];
        } else if ([EMMethodKeyUnblockGroup isEqualToString:call.method]) {
            [self unblockGroup:call.arguments result:result];
        } else if ([EMMethodKeyUpdateGroupOwner isEqualToString:call.method]) {
            [self updateGroupOwner:call.arguments result:result];
        } else if ([EMMethodKeyAddAdmin isEqualToString:call.method]) {
            [self addAdmin:call.arguments result:result];
        } else if ([EMMethodKeyRemoveAdmin isEqualToString:call.method]) {
            [self removeAdmin:call.arguments result:result];
        } else if ([EMMethodKeyMuteMembers isEqualToString:call.method]) {
            [self muteMembers:call.arguments result:result];
        } else if ([EMMethodKeyUnmuteMembers isEqualToString:call.method]) {
            [self unmuteMembers:call.arguments result:result];
        } else if ([EMMethodKeyUploadGroupSharedFile isEqualToString:call.method]) {
            [self uploadGroupSharedFile:call.arguments result:result];
        } else if ([EMMethodKeyDownloadGroupSharedFile isEqualToString:call.method]) {
            [self downloadGroupSharedFile:call.arguments result:result];
        } else if ([EMMethodKeyUpdateGroupAnnouncement isEqualToString:call.method]) {
            [self updateGroupAnnouncement:call.arguments result:result];
        } else if ([EMMethodKeyUpdateGroupExt isEqualToString:call.method]) {
            [self updateGroupExt:call.arguments result:result];
        } else if ([EMMethodKeyJoinPublicGroup isEqualToString:call.method]) {
            [self joinPublicGroup:call.arguments result:result];
        } else if ([EMMethodKeyRequestToJoinPublicGroup isEqualToString:call.method]) {
            [self requestToJoinPublicGroup:call.arguments result:result];
        } else if ([EMMethodKeyApproveJoinGroupRequest isEqualToString:call.method]) {
            [self approveJoinGroupRequest:call.arguments result:result];
        } else if ([EMMethodKeyDeclineJoinGroupRequest isEqualToString:call.method]) {
            [self declineJoinGroupRequest:call.arguments result:result];
        } else if ([EMMethodKeyAcceptInvitationFromGroup isEqualToString:call.method]) {
            [self acceptInvitationFromGroup:call.arguments result:result];
        } else if ([EMMethodKeyDeclineGroupInvitation isEqualToString:call.method]) {
            [self declineGroupInvitation:call.arguments result:result];
        } else if ([EMMethodKeyUpdatePushServiceForGroup isEqualToString:call.method]) {
            [self updatePushServiceForGroup:call.arguments result:result];
        } else if ([EMMethodKeyUpdatePushServiceForGroups isEqualToString:call.method]) {
            [self updatePushServiceForGroups:call.arguments result:result];
        } else {
            [super handleMethodCall:call result:result];
        }
}


- (void)getJoinedGroups:(NSDictionary *)param result:(FlutterResult)result {
    NSArray *groups = [[EMClient.sharedClient.groupManager getJoinedGroups];
    [self wrapperCallBack:result
                            error:NULL
                         userInfo:@{@"groups":groups}];
}

- (void)getGroupsWithoutPushNotification:(NSDictionary *)param result:(FlutterResult)result {
    EMError *aError;
    NSArray *groups = [EMClient.sharedClient.groupManager getGroupsWithoutPushNotification:&aError];
    [self wrapperCallBack:result
                            error:NULL
                         userInfo:@{@"groups":groups}];
}

- (void)getJoinedGroupsFromServer:(NSDictionary *)param result:(FlutterResult)result {
     NSInteger page = param[@"page"];
     NSInteger pageSize = param[@"pageSize"];
     [EMClient.sharedClient.groupManager getJoinedGroupsFromServerWithPage:page
                                                                  pageSize:pageSize
                                                                completion:^(NSArray *aList, EMError *aError)
        {
             [self wrapperCallBack:result
                                     error:aError
                                  userInfo:@{@"list":aList}];
        }];
}

- (void)getPublicGroupsFromServer:(NSDictionary *)param result:(FlutterResult)result {
     NSString *cursor = param[@"cursor"];
     NSInteger pageSize = param[@"pageSize"];
     [EMClient.sharedClient.groupManager getPublicGroupsFromServerWithCursor:cursor
                                                                    pageSize:pageSize
                                                                  completion:^(EMCursorResult *aResult, EMError *aError)
        {
             [self wrapperCallBack:result
                                     error:aError
                                  userInfo:@{@"result":aResult}];
        }];
}

- (void)searchPublicGroup:(NSDictionary *)param result:(FlutterResult)result {
     NSString *groupId = param[@"groupId"];
     [EMClient.sharedClient.groupManager searchPublicGroupWithId:groupId
                                                      completion:^(EMGroup *aGroup, EMError *aError)
        {
             [self wrapperCallBack:result
                                     error:aError
                                  userInfo:@{@"group":aGroup}];
        }];
}

- (void)createGroup:(NSDictionary *)param result:(FlutterResult)result {
     NSString *subject = param[@"subject"];
     NSString *description = param[@"description"];
     NSArray *invitees = param[@"invitees"];
     NSString *message = param[@"message"];
     EMGroupOptions *options = param[@"options"];
     [EMClient.sharedClient.groupManager createGroupWithSubject:subject
                                                    description:description
                                                       invitees:invitees
                                                        message:message
                                                        setting:options
                                                     completion:^(EMGroup *aGroup, EMError *aError)
        {
             [self wrapperCallBack:result
                                     error:aError
                                  userInfo:@{@"group":aGroup}];
        }];
}

- (void)getGroupSpecificationFromServer:(NSDictionary *)param result:(FlutterResult)result {
     NSString *groupId = param[@"groupId"];
     [EMClient.sharedClient.groupManager getGroupSpecificationFromServerWithId:groupId
                                                                    completion:^(EMGroup *aGroup, EMError *aError)
        {
             [self wrapperCallBack:result
                                     error:aError
                                  userInfo:@{@"group":aGroup}];
        }];
}

- (void)getGroupMemberListFromServer:(NSDictionary *)param result:(FlutterResult)result {
     NSString *groupId = param[@"groupId"];
     NSString *cursor = param[@"cursor"];
     NSInteger pageSize = param[@"pageSize"];
     [EMClient.sharedClient.groupManager getGroupMemberListFromServerWithId:groupId
                                                                     cursor:cursor
                                                                   pageSize:pageSize
                                                                 completion:^(EMCursorResult *aResult, EMError *aError)
        {
             [self wrapperCallBack:result
                                     error:aError
                                  userInfo:@{@"result":aResult}];
        }];
}

- (void)getGroupBlacklistFromServer:(NSDictionary *)param result:(FlutterResult)result {
      NSString *groupId = param[@"groupId"];
      NSInteger pageNumber = param[@"pageNumber"];
      NSInteger pageSize = param[@"pageSize"];
      [EMClient.sharedClient.groupManager getGroupBlacklistFromServerWithId:groupId
                                                                 pageNumber:pageNumber
                                                                   pageSize:pageSize
                                                                 completion:^(NSArray *aList, EMError *aError)
        {
             [self wrapperCallBack:result
                                     error:aError
                                  userInfo:@{@"list":aList}];
        }];
}

- (void)getGroupMuteListFromServer:(NSDictionary *)param result:(FlutterResult)result {
      NSString *groupId = param[@"groupId"];
      NSInteger pageNumber = param[@"pageNumber"];
      NSInteger pageSize = param[@"pageSize"];
      [EMClient.sharedClient.groupManager getGroupMuteListFromServerWithId:groupId
                                                                pageNumber:pageNumber
                                                                  pageSize:pageSize
                                                                completion:^(NSArray *aList, EMError *aError)
        {
             [self wrapperCallBack:result
                                     error:aError
                                  userInfo:@{@"list":aList}];
        }];
}

- (void)getGroupFileList:(NSDictionary *)param result:(FlutterResult)result {
      NSString *groupId = param[@"groupId"];
      NSInteger pageNumber = param[@"pageNumber"];
      NSInteger pageSize = param[@"pageSize"];
      [EMClient.sharedClient.groupManager getGroupFileListWithId:groupId
                                                      pageNumber:pageNumber
                                                        pageSize:pageSize
                                                      completion:^(NSArray *aList, EMError *aError)
        {
             [self wrapperCallBack:result
                                     error:aError
                                  userInfo:@{@"list":aList}];
        }];
}

- (void)getGroupAnnouncement:(NSDictionary *)param result:(FlutterResult)result {
      NSString *groupId = param[@"groupId"];
      [EMClient.sharedClient.groupManager getGroupAnnouncementWithId:groupId
                                                          completion:^(NSString *aAnnouncement, EMError *aError)
        {
             [self wrapperCallBack:result
                                     error:aError
                                  userInfo:@{@"announcement":aAnnouncement}];
        }];
}

- (void)addMembers:(NSDictionary *)param result:(FlutterResult)result {
 {
      NSArray *members = param[@"members"];
      NSString *groupId = param[@"groupId"];
      NSString *message = param[@"message"];
      [EMClient.sharedClient.groupManager addMembers:members
                                             toGroup:groupId
                                             message:message
                                          completion:^(EMGroup *aGroup, EMError *aError)
        {
             [self wrapperCallBack:result
                                     error:aError
                                  userInfo:@{@"group":aGroup}];
        }];
}

- (void)removeMembers:(NSDictionary *)param result:(FlutterResult)result {
      NSArray *members = param[@"members"];
      NSString *groupId = param[@"groupId"];
      [EMClient.sharedClient.groupManager removeMembers:members
                                              fromGroup:groupId
                                             completion:^(EMGroup *aGroup, EMError *aError)
        {
             [self wrapperCallBack:result
                                     error:aError
                                  userInfo:@{@"group":aGroup}];
        }];
}

- (void)blockMembers:(NSDictionary *)param result:(FlutterResult)result {
      NSArray *members = param[@"members"];
      NSString *groupId = param[@"groupId"];
      [EMClient.sharedClient.groupManager blockMembers:members
                                             fromGroup:groupId
                                            completion:^(EMGroup *aGroup, EMError *aError)
        {
             [self wrapperCallBack:result
                                     error:aError
                                  userInfo:@{@"group":aGroup}];
        }];
}

- (void)unblockMembers:(NSDictionary *)param result:(FlutterResult)result {
      NSArray *members = param[@"members"];
      NSString *groupId = param[@"groupId"];
      [EMClient.sharedClient.groupManager unblockMembers:members
                                               fromGroup:groupId
                                              completion:^(EMGroup *aGroup, EMError *aError)
        {
             [self wrapperCallBack:result
                                     error:aError
                                  userInfo:@{@"group":aGroup}];
        }];
}

- (void)updateGroupSubject:(NSDictionary *)param result:(FlutterResult)result {
      NSString *subject = param[@"subject"];
      NSString *groupId = param[@"groupId"];
      [EMClient.sharedClient.groupManager updateGroupSubject:members
                                                    forGroup:groupId
                                                  completion:^(EMGroup *aGroup, EMError *aError)
        {
             [self wrapperCallBack:result
                                     error:aError
                                  userInfo:@{@"group":aGroup}];
        }];
}

- (void)updateDescription:(NSDictionary *)param result:(FlutterResult)result {
      NSString *description = param[@"description"];
      NSString *groupId = param[@"groupId"];
      [EMClient.sharedClient.groupManager updateDescription:members
                                                   forGroup:groupId
                                                 completion:^(EMGroup *aGroup, EMError *aError)
        {
             [self wrapperCallBack:result
                                     error:aError
                                  userInfo:@{@"group":aGroup}];
        }];
}

- (void)leaveGroup:(NSDictionary *)param result:(FlutterResult)result {
      NSString *groupId = param[@"groupId"];
      [EMClient.sharedClient.groupManager leaveGroup:groupId
                                          completion:^(EMError *aError)
        {
             [self wrapperCallBack:result
                                     error:aError
                                  userInfo:NULL];
        }];
}

- (void)destroyGroup:(NSDictionary *)param result:(FlutterResult)result {
      NSString *groupId = param[@"groupId"];
      [EMClient.sharedClient.groupManager destroyGroup:groupId
                                      finishCompletion:^(EMError *aError)
        {
             [self wrapperCallBack:result
                                     error:aError
                                  userInfo:NULL];
        }];
}

- (void)blockGroup:(NSDictionary *)param result:(FlutterResult)result {
      NSString *groupId = param[@"groupId"];
      [EMClient.sharedClient.groupManager blockGroup:groupId
                                          completion:^(EMGroup *aGroup, EMError *aError)
        {
             [self wrapperCallBack:result
                                     error:aError
                                  userInfo:@{@"group":aGroup}];
        }];
}

- (void)unblockGroup:(NSDictionary *)param result:(FlutterResult)result {
      NSString *groupId = param[@"groupId"];
      [EMClient.sharedClient.groupManager unblockGroup:groupId
                                            completion:^(EMGroup *aGroup, EMError *aError)
        {
             [self wrapperCallBack:result
                                     error:aError
                                  userInfo:@{@"group":aGroup}];
        }];
}

- (void)updateGroupOwner:(NSDictionary *)param result:(FlutterResult)result {
      NSString *groupId = param[@"groupId"];
      NSString *newOwner = param[@"newOwner"];
      [EMClient.sharedClient.groupManager updateGroupOwner:groupId
                                                  newOwner:newOwner
                                                completion:^(EMGroup *aGroup, EMError *aError)
        {
             [self wrapperCallBack:result
                                     error:aError
                                  userInfo:@{@"group":aGroup}];
        }];
}

- (void)addAdmin:(NSDictionary *)param result:(FlutterResult)result {
      NSString *admin = param[@"admin"];
      NSString *groupId = param[@"groupId"];
      [EMClient.sharedClient.groupManager addAdmin:admin
                                           toGroup:groupId
                                        completion:^(EMGroup *aGroup, EMError *aError)
        {
             [self wrapperCallBack:result
                                     error:aError
                                  userInfo:@{@"group":aGroup}];
        }];
}

- (void)removeAdmin:(NSDictionary *)param result:(FlutterResult)result {
      NSString *admin = param[@"admin"];
      NSString *groupId = param[@"groupId"];
      [EMClient.sharedClient.groupManager removeAdmin:admin
                                            fromGroup:groupId
                                           completion:^(EMGroup *aGroup, EMError *aError)
        {
             [self wrapperCallBack:result
                                     error:aError
                                  userInfo:@{@"group":aGroup}];
        }];
}

- (void)muteMembers:(NSDictionary *)param result:(FlutterResult)result {
      NSArray *members = param[@"members"];
      NSInteger muteMilliseconds = param[@"muteMilliseconds"];
      NSString *groupId = param[@"groupId"];
      [EMClient.sharedClient.groupManager muteMembers:members
                                     muteMilliseconds:muteMilliseconds
                                            fromGroup:groupId
                                           completion:^(EMGroup *aGroup, EMError *aError)
        {
             [self wrapperCallBack:result
                                     error:aError
                                  userInfo:@{@"group":aGroup}];
        }];
}

- (void)unmuteMembers:(NSDictionary *)param result:(FlutterResult)result {
      NSArray *members = param[@"members"];
      NSString *groupId = param[@"groupId"];
      [EMClient.sharedClient.groupManager unmuteMembers:members
                                              fromGroup:groupId
                                             completion:^(EMGroup *aGroup, EMError *aError)
        {
             [self wrapperCallBack:result
                                     error:aError
                                  userInfo:@{@"group":aGroup}];
        }];
}

- (void)uploadGroupSharedFile:(NSDictionary *)param result:(FlutterResult)result {
    NSString *groupId = param[@"groupId"];
    NSString *filePath = param[@"filePath"];
    [EMClient.sharedClient.groupManager uploadGroupSharedFileWithId:groupId
                                                           filePath:filePath
                                                           progress:^(int progress)
       {

       } completion:^(EMGroupSharedFile *aSharedFile, EMError *aError)
       {
             [self wrapperCallBack:result
                                     error:aError
                                  userInfo:@{@"sharedFile":aSharedFile}];
       }];
}

- (void)downloadGroupSharedFile:(NSDictionary *)param result:(FlutterResult)result {
    NSString *groupId = param[@"groupId"];
    NSString *filePath = param[@"filePath"];
    NSString *sharedFileId = param[@"sharedFileId"];
    [EMClient.sharedClient.groupManager downloadGroupSharedFileWithId:groupId
                                                             filePath:filePath
                                                         sharedFileId:sharedFileId
                                                             progress:^(int progress)
       {

       } completion:^(EMGroup *aGroup, EMError *aError)
       {
             [self wrapperCallBack:result
                                     error:aError
                                  userInfo:@{@"group":aGroup}];
       }];
}

- (void)updateGroupAnnouncement:(NSDictionary *)param result:(FlutterResult)result {
    NSString *groupId = param[@"groupId"];
    NSString *announcement = param[@"announcement"];
    [EMClient.sharedClient.groupManager updateGroupAnnouncementWithId:groupId
                                                         announcement:announcement
                                                           completion:^(EMGroup *aGroup, EMError *aError)
       {
             [self wrapperCallBack:result
                                     error:aError
                                  userInfo:@{@"group":aGroup}];
       }];
}

- (void)updateGroupExt:(NSDictionary *)param result:(FlutterResult)result {
    NSString *groupId = param[@"groupId"];
    NSString *ext = param[@"ext"];
    [EMClient.sharedClient.groupManager updateGroupExtWithId:groupId
                                                         ext:ext
                                                  completion:^(EMGroup *aGroup, EMError *aError)
       {
             [self wrapperCallBack:result
                                     error:aError
                                  userInfo:@{@"group":aGroup}];
       }];
}

- (void)joinPublicGroup:(NSDictionary *)param result:(FlutterResult)result {
    NSString *groupId = param[@"groupId"];
    [EMClient.sharedClient.groupManager joinPublicGroup:groupId
                                             completion:^(EMGroup *aGroup, EMError *aError)
       {
             [self wrapperCallBack:result
                                     error:aError
                                  userInfo:@{@"group":aGroup}];
       }];
}

- (void)requestToJoinPublicGroup:(NSDictionary *)param result:(FlutterResult)result {
    NSString *groupId = param[@"groupId"];
    NSString *message = param[@"message"];
    [EMClient.sharedClient.groupManager requestToJoinPublicGroup:groupId
                                                         message:message
                                                      completion:^(EMGroup *aGroup, EMError *aError)
       {
             [self wrapperCallBack:result
                                     error:aError
                                  userInfo:@{@"group":aGroup}];
       }];
}

- (void)approveJoinGroupRequest:(NSDictionary *)param result:(FlutterResult)result {
    NSString *groupId = param[@"groupId"];
    NSString *username = param[@"username"];
    [EMClient.sharedClient.groupManager approveJoinGroupRequest:groupId
                                                         sender:username
                                                     completion:^(EMGroup *aGroup, EMError *aError)
       {
             [self wrapperCallBack:result
                                     error:aError
                                  userInfo:@{@"group":aGroup}];
       }];
}

- (void)declineJoinGroupRequest:(NSDictionary *)param result:(FlutterResult)result {
    NSString *groupId = param[@"groupId"];
    NSString *username = param[@"username"];
    NSString *reason = param[@"reason"];
    [EMClient.sharedClient.groupManager declineJoinGroupRequest:groupId
                                                         sender:username
                                                         reason:reason
                                                     completion:^(EMGroup *aGroup, EMError *aError)
       {
             [self wrapperCallBack:result
                                     error:aError
                                  userInfo:@{@"group":aGroup}];
       }];
}

- (void)acceptInvitationFromGroup:(NSDictionary *)param result:(FlutterResult)result {
    NSString *groupId = param[@"groupId"];
    NSString *username = param[@"username"];
    [EMClient.sharedClient.groupManager acceptInvitationFromGroup:groupId
                                                          inviter:username
                                                       completion:^(EMGroup *aGroup, EMError *aError)
       {
             [self wrapperCallBack:result
                                     error:aError
                                  userInfo:@{@"group":aGroup}];
       }];
}

- (void)declineGroupInvitation:(NSDictionary *)param result:(FlutterResult)result {
    NSString *groupId = param[@"groupId"];
    NSString *inviter = param[@"inviter"];
    NSString *reason = param[@"reason"];
    [EMClient.sharedClient.groupManager declineGroupInvitation:groupId
                                                       inviter:inviter
                                                        reason:reason
                                                    completion:^(EMError *aError)
       {
             [self wrapperCallBack:result
                                     error:aError
                                  userInfo:NULL];
       }];
}

- (void)updatePushServiceForGroup:(NSDictionary *)param result:(FlutterResult)result {
    NSString *groupId = param[@"groupId"];
    BOOL isEnable = param[@"isEnable"];
    [EMClient.sharedClient.groupManager updatePushServiceForGroup:groupId
                                                         isPushEnabled:isEnable
                                                      completion:^(EMGroup *aGroup, EMError *aError)
       {
             [self wrapperCallBack:result
                                     error:aError
                                  userInfo:@{@"group":aGroup}];
       }];
}

- (void)updatePushServiceForGroups:(NSDictionary *)param result:(FlutterResult)result {
    NSString *groupId = param[@"groupId"];
    BOOL isEnable = param[@"isEnable"];
    [EMClient.sharedClient.groupManager updatePushServiceForGroups:groupId
                                                         isPushEnabled:isEnable
                                                      completion:^(EMGroup *aGroup, EMError *aError)
       {
             [self wrapperCallBack:result
                                     error:aError
                                  userInfo:@{@"group":aGroup}];
       }];
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
