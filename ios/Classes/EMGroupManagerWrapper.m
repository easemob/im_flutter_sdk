//
//  EMGroupManagerWrapper.m
//  FlutterTest
//
//  Created by 杜洁鹏 on 2019/10/17.
//  Copyright © 2019 Easemob. All rights reserved.
//

#import "EMGroupManagerWrapper.h"
#import "EMSDKMethod.h"
#import "EMHelper.h"

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

- (void)handleMethodCall:(FlutterMethodCall*)call
                  result:(FlutterResult)result {
    if ([EMMethodKeyGetJoinedGroups isEqualToString:call.method]) {
        [self getJoinedGroups:call.arguments result:result];
    } else if ([EMMethodKeyGetGroupsWithoutPushNotification isEqualToString:call.method]) {
        [self getGroupsWithoutPushNotification:call.arguments result:result];
    } else if ([EMMethodKeyGetGroup isEqualToString:call.method]) {
        [self getGroup:call.arguments result:result];
    } else if ([EMMethodKeyGetJoinedGroupsFromServer isEqualToString:call.method]) {
        [self getJoinedGroupsFromServer:call.arguments result:result];
    } else if ([EMMethodKeyLoadAllGroups isEqualToString:call.method]) {
        [self loadAllGroups:call.arguments result:result];
    } else if ([EMMethodKeyGetPublicGroupsFromServer isEqualToString:call.method]) {
        [self getPublicGroupsFromServer:call.arguments result:result];
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
    } else if ([EMMethodKeyAddOccupants isEqualToString:call.method]) {
        [self addOccupants:call.arguments result:result];
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
    } else if ([EMMethodKeyRemoveGroupSharedFile isEqualToString:call.method]) {
        [self removeGroupSharedFile:call.arguments result:result];
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

#pragma mark - Actions

- (void)getJoinedGroups:(NSDictionary *)param result:(FlutterResult)result {
    NSArray *joinedGroups = [EMClient.sharedClient.groupManager getJoinedGroups];
    [self wrapperCallBack:result
                    error:nil
                 userInfo:@{@"value":[EMHelper groupsToDictionaries:joinedGroups]}];
}
// 有疑议
- (void)getGroupsWithoutPushNotification:(NSDictionary *)param result:(FlutterResult)result {
    EMError *aError;
    NSArray *pushGroups = [EMClient.sharedClient.groupManager getGroupsWithoutPushNotification:&aError];
    [self wrapperCallBack:result
                    error:nil
                 userInfo:@{@"value":[EMHelper groupsToDictionaries:pushGroups]}];
}

- (void)getGroup:(NSDictionary *)param result:(FlutterResult)result {
    NSString *groupId = param[@"groupId"];
    EMGroup *aGroup = [EMGroup groupWithId:groupId];
    [self wrapperCallBack:result
                    error:nil
                 userInfo:@{@"value":[EMHelper groupToDictionary:aGroup]}];
}


- (void)getJoinedGroupsFromServer:(NSDictionary *)param result:(FlutterResult)result {
    [EMClient.sharedClient.groupManager getJoinedGroupsFromServerWithPage:0
                                                                 pageSize:-1
                                                               completion:^(NSArray *aList, EMError *aError)
     {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:@{@"value":[EMHelper groupsToDictionaries:aList]}];
    }];
}

- (void)loadAllGroups:(NSDictionary *)param result:(FlutterResult)result {
    
}

- (void)getPublicGroupsFromServer:(NSDictionary *)param result:(FlutterResult)result {
    NSString *cursor = param[@"cursor"];
    NSInteger pageSize = [param[@"pageSize"] integerValue];
    [EMClient.sharedClient.groupManager getPublicGroupsFromServerWithCursor:cursor
                                                                   pageSize:pageSize
                                                                 completion:^(EMCursorResult *aResult, EMError *aError)
     {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:@{@"value":[self dictionaryWithCursorResult:aResult isGroupList:YES]}];
    }];
}


- (void)createGroup:(NSDictionary *)param result:(FlutterResult)result {
    NSString *subject = param[@"groupName"];
    NSString *description = param[@"desc"];
    NSArray *invitees = param[@"members"];
    NSString *message = param[@"reason"];
    EMGroupOptions *options = [[EMGroupOptions alloc] init];
    options.maxUsersCount = [param[@"maxUsers"] integerValue];
    options.style = [param[@"groupStyle"] intValue];
    [EMClient.sharedClient.groupManager createGroupWithSubject:subject
                                                   description:description
                                                      invitees:invitees
                                                       message:message
                                                       setting:options
                                                    completion:^(EMGroup *aGroup, EMError *aError)
     {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:@{@"value":[EMHelper groupToDictionary:aGroup]}];
    }];
}

- (void)getGroupSpecificationFromServer:(NSDictionary *)param result:(FlutterResult)result {
    NSString *groupId = param[@"groupId"];
    [EMClient.sharedClient.groupManager getGroupSpecificationFromServerWithId:groupId
                                                                   completion:^(EMGroup *aGroup, EMError *aError)
     {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:@{@"value":[EMHelper groupToDictionary:aGroup]}];
    }];
}

- (void)getGroupMemberListFromServer:(NSDictionary *)param result:(FlutterResult)result {
    NSString *groupId = param[@"groupId"];
    NSString *cursor = param[@"cursor"];
    NSInteger pageSize = [param[@"pageSize"] integerValue];
    [EMClient.sharedClient.groupManager getGroupMemberListFromServerWithId:groupId
                                                                    cursor:cursor
                                                                  pageSize:pageSize
                                                                completion:^(EMCursorResult *aResult, EMError *aError)
     {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:@{@"value":[self dictionaryWithCursorResult:aResult isGroupList:NO]}];
    }];
}

- (void)getGroupBlacklistFromServer:(NSDictionary *)param result:(FlutterResult)result {
    NSString *groupId = param[@"groupId"];
    NSInteger pageNum = [param[@"pageNum"] integerValue];
    NSInteger pageSize = [param[@"pageSize"] integerValue];
    [EMClient.sharedClient.groupManager getGroupBlacklistFromServerWithId:groupId
                                                               pageNumber:pageNum
                                                                 pageSize:pageSize
                                                               completion:^(NSArray *aList, EMError *aError)
     {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:@{@"value":aList}];
    }];
}

- (void)getGroupMuteListFromServer:(NSDictionary *)param result:(FlutterResult)result {
    NSString *groupId = param[@"groupId"];
    NSInteger pageNum = [param[@"pageNum"] integerValue];
    NSInteger pageSize = [param[@"pageSize"] integerValue];
    [EMClient.sharedClient.groupManager getGroupMuteListFromServerWithId:groupId
                                                              pageNumber:pageNum
                                                                pageSize:pageSize
                                                              completion:^(NSArray *aList, EMError *aError)
     {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:@{@"value":aList}];
    }];
}

- (void)getGroupFileList:(NSDictionary *)param result:(FlutterResult)result {
    NSString *groupId = param[@"groupId"];
    NSInteger pageNum = [param[@"pageNum"] integerValue];
    NSInteger pageSize = [param[@"pageSize"] integerValue];
    [EMClient.sharedClient.groupManager getGroupFileListWithId:groupId
                                                    pageNumber:pageNum
                                                      pageSize:pageSize
                                                    completion:^(NSArray *aList, EMError *aError)
     {
        
        [self wrapperCallBack:result
                        error:aError
                     userInfo:@{@"value":[EMHelper groupFileListToDictionaries:aList]}];
    }];
}

- (void)getGroupAnnouncement:(NSDictionary *)param result:(FlutterResult)result {
    NSString *groupId = param[@"groupId"];
    [EMClient.sharedClient.groupManager getGroupAnnouncementWithId:groupId
                                                        completion:^(NSString *aAnnouncement, EMError *aError)
     {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:@{@"value":aAnnouncement}];
    }];
}

- (void)addOccupants:(NSDictionary *)param result:(FlutterResult)result {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *groupId = param[@"groupId"];
        NSArray *members = param[@"members"];
        NSString *message = param[@"reason"];
        EMError *aError;
        EMGroup *group = [EMClient.sharedClient.groupManager addOccupants:members toGroup:groupId welcomeMessage:message error:&aError];
        [self wrapperCallBack:result
                        error:aError
                     userInfo:@{@"value":[EMHelper groupToDictionary:group]}];
    });
    
}


- (void)addMembers:(NSDictionary *)param result:(FlutterResult)result {
    NSArray *members = param[@"members"];
    NSString *groupId = param[@"groupId"];
    [EMClient.sharedClient.groupManager addMembers:members
                                           toGroup:groupId
                                           message:@"邀请您加入群组"
                                        completion:^(EMGroup *aGroup, EMError *aError)
     {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:@{@"value":[EMHelper groupToDictionary:aGroup]}];
    }];
}

- (void)removeMembers:(NSDictionary *)param result:(FlutterResult)result {
    NSString *userName = param[@"userName"];
    NSString *groupId = param[@"groupId"];
    [EMClient.sharedClient.groupManager removeMembers:@[userName]
                                            fromGroup:groupId
                                           completion:^(EMGroup *aGroup, EMError *aError)
     {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:[EMHelper groupToDictionary:aGroup]];
    }];
}

- (void)blockMembers:(NSDictionary *)param result:(FlutterResult)result {
    NSString *members = param[@"userName"];
    NSString *groupId = param[@"groupId"];
    [EMClient.sharedClient.groupManager blockMembers:@[members]
                                           fromGroup:groupId
                                          completion:^(EMGroup *aGroup, EMError *aError)
     {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:@{@"value":[EMHelper groupToDictionary:aGroup]}];
    }];
}

- (void)unblockMembers:(NSDictionary *)param result:(FlutterResult)result {
    NSString *members = param[@"userName"];
    NSString *groupId = param[@"groupId"];
    [EMClient.sharedClient.groupManager unblockMembers:@[members]
                                             fromGroup:groupId
                                            completion:^(EMGroup *aGroup, EMError *aError)
     {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:@{@"value":[EMHelper groupToDictionary:aGroup]}];
    }];
}

- (void)updateGroupSubject:(NSDictionary *)param result:(FlutterResult)result {
    NSString *subject = param[@"groupName"];
    NSString *groupId = param[@"groupId"];
    [EMClient.sharedClient.groupManager updateGroupSubject:subject
                                                  forGroup:groupId
                                                completion:^(EMGroup *aGroup, EMError *aError)
     {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:[EMHelper groupToDictionary:aGroup]];
    }];
}

- (void)updateDescription:(NSDictionary *)param result:(FlutterResult)result {
    NSString *description = param[@"desc"];
    NSString *groupId = param[@"groupId"];
    [EMClient.sharedClient.groupManager updateDescription:description
                                                 forGroup:groupId
                                               completion:^(EMGroup *aGroup, EMError *aError)
     {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:@{@"value":[EMHelper groupToDictionary:aGroup]}];
    }];
}

- (void)leaveGroup:(NSDictionary *)param result:(FlutterResult)result {
    NSString *groupId = param[@"groupId"];
    [EMClient.sharedClient.groupManager leaveGroup:groupId
                                        completion:^(EMError *aError)
     {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:nil];
    }];
}

- (void)destroyGroup:(NSDictionary *)param result:(FlutterResult)result {
    NSString *groupId = param[@"groupId"];
    [EMClient.sharedClient.groupManager destroyGroup:groupId
                                    finishCompletion:^(EMError *aError)
     {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:nil];
    }];
}

- (void)blockGroup:(NSDictionary *)param result:(FlutterResult)result {
    NSString *groupId = param[@"groupId"];
    [EMClient.sharedClient.groupManager blockGroup:groupId
                                        completion:^(EMGroup *aGroup, EMError *aError)
     {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:@{@"value":[EMHelper groupToDictionary:aGroup]}];
    }];
}

- (void)unblockGroup:(NSDictionary *)param result:(FlutterResult)result {
    NSString *groupId = param[@"groupId"];
    [EMClient.sharedClient.groupManager unblockGroup:groupId
                                          completion:^(EMGroup *aGroup, EMError *aError)
     {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:@{@"value":[EMHelper groupToDictionary:aGroup]}];
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
                     userInfo:@{@"value":[EMHelper groupToDictionary:aGroup]}];
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
                     userInfo:@{@"value":[EMHelper groupToDictionary:aGroup]}];
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
                     userInfo:@{@"value":[EMHelper groupToDictionary:aGroup]}];
    }];
}

- (void)muteMembers:(NSDictionary *)param result:(FlutterResult)result {
    NSArray *members = param[@"members"];
    NSString *muteMilliseconds = param[@"duration"];
    NSString *groupId = param[@"groupId"];
    [EMClient.sharedClient.groupManager muteMembers:members
                                   muteMilliseconds:[muteMilliseconds integerValue]
                                          fromGroup:groupId
                                         completion:^(EMGroup *aGroup, EMError *aError)
     {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:@{@"value":[EMHelper groupToDictionary:aGroup]}];
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
                     userInfo:@{@"value":[EMHelper groupToDictionary:aGroup]}];
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
                     userInfo:nil];
    }];
}

- (void)downloadGroupSharedFile:(NSDictionary *)param result:(FlutterResult)result {
    NSString *groupId = param[@"groupId"];
    NSString *savePath = param[@"savePath"];
    NSString *fileId = param[@"fileId"];
    [EMClient.sharedClient.groupManager downloadGroupSharedFileWithId:groupId
                                                             filePath:savePath
                                                         sharedFileId:fileId
                                                             progress:^(int progress)
     {
        
    } completion:^(EMGroup *aGroup, EMError *aError)
     {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:nil];
    }];
}

- (void)removeGroupSharedFile:(NSDictionary *)param result:(FlutterResult)result {
    NSString *groupId = param[@"groupId"];
    NSString *fileId = param[@"fileId"];
    [EMClient.sharedClient.groupManager removeGroupSharedFileWithId:groupId sharedFileId:fileId completion:^(EMGroup *aGroup, EMError *aError) {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:nil];
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
                     userInfo:nil];
    }];
}

- (void)updateGroupExt:(NSDictionary *)param result:(FlutterResult)result {
    NSString *groupId = param[@"groupId"];
    NSString *ext = param[@"extension"];
    [EMClient.sharedClient.groupManager updateGroupExtWithId:groupId
                                                         ext:ext
                                                  completion:^(EMGroup *aGroup, EMError *aError)
     {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:@{@"value":[EMHelper groupToDictionary:aGroup]}];
    }];
}

- (void)joinPublicGroup:(NSDictionary *)param result:(FlutterResult)result {
    NSString *groupId = param[@"groupId"];
    [EMClient.sharedClient.groupManager joinPublicGroup:groupId
                                             completion:^(EMGroup *aGroup, EMError *aError)
     {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:nil];
    }];
}

- (void)requestToJoinPublicGroup:(NSDictionary *)param result:(FlutterResult)result {
    NSString *groupId = param[@"groupId"];
    NSString *message = param[@"reason"];
    [EMClient.sharedClient.groupManager requestToJoinPublicGroup:groupId
                                                         message:message
                                                      completion:^(EMGroup *aGroup, EMError *aError)
     {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:nil];
    }];
}

- (void)approveJoinGroupRequest:(NSDictionary *)param result:(FlutterResult)result {
    NSString *groupId = param[@"groupId"];
    NSString *userName = param[@"userName"];
    [EMClient.sharedClient.groupManager approveJoinGroupRequest:groupId
                                                         sender:userName
                                                     completion:^(EMGroup *aGroup, EMError *aError)
     {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:nil];
    }];
}

- (void)declineJoinGroupRequest:(NSDictionary *)param result:(FlutterResult)result {
    NSString *groupId = param[@"groupId"];
    NSString *userName = param[@"userName"];
    NSString *reason = param[@"reason"];
    [EMClient.sharedClient.groupManager declineJoinGroupRequest:groupId
                                                         sender:userName
                                                         reason:reason
                                                     completion:^(EMGroup *aGroup, EMError *aError)
     {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:nil];
    }];
}

- (void)acceptInvitationFromGroup:(NSDictionary *)param result:(FlutterResult)result {
    NSString *groupId = param[@"groupId"];
    NSString *username = param[@"inviter"];
    [EMClient.sharedClient.groupManager acceptInvitationFromGroup:groupId
                                                          inviter:username
                                                       completion:^(EMGroup *aGroup, EMError *aError)
     {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:@{@"value":[EMHelper groupToDictionary:aGroup]}];
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
                     userInfo:nil];
    }];
}
// 有疑议
- (void)updatePushServiceForGroup:(NSDictionary *)param result:(FlutterResult)result {
    NSString *groupId = param[@"groupId"];
    BOOL isEnable = param[@"isEnable"];
    [EMClient.sharedClient.groupManager updatePushServiceForGroup:groupId
                                                    isPushEnabled:isEnable
                                                       completion:^(EMGroup *aGroup, EMError *aError)
     {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:@{@"value":[EMHelper groupToDictionary:aGroup]}];
    }];
}
// 有疑议
- (void)updatePushServiceForGroups:(NSDictionary *)param result:(FlutterResult)result {
    NSArray *groupIDs = param[@"groupIDs"];
    BOOL isEnable = [param[@"isEnable"] boolValue];
    [EMClient.sharedClient.groupManager updatePushServiceForGroups:groupIDs
                                                     isPushEnabled:isEnable
                                                        completion:^(NSArray *groups, EMError *aError)
     {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:@{@"value":[EMHelper groupsToDictionaries:groups]}];
    }];
}

#pragma mark - EMGroupManagerDelegate

- (void)groupInvitationDidReceive:(NSString *)aGroupId
                          inviter:(NSString *)aInviter
                          message:(NSString *)aMessage {
    NSDictionary *map = @{
        @"type":@"onInvitationReceived",
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
        @"type":@"onInvitationAccepted",
        @"groupId":aGroup.groupId,
        @"invitee":aInvitee
    };
    [self.channel invokeMethod:EMMethodKeyOnGroupChanged
                     arguments:map];
    
}

- (void)groupInvitationDidDecline:(EMGroup *)aGroup
                          invitee:(NSString *)aInvitee
                           reason:(NSString *)aReason {
    NSDictionary *map = @{
        @"type":@"onInvitationDeclined",
        @"groupId":aGroup.groupId,
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
        @"type":@"onAutoAcceptInvitationFromGroup",
        @"groupId":aGroup.groupId,
        @"message":aMessage,
        @"inviter":aInviter
    };
    [self.channel invokeMethod:EMMethodKeyOnGroupChanged
                     arguments:map];
}

- (void)didLeaveGroup:(EMGroup *)aGroup
               reason:(EMGroupLeaveReason)aReason {
    NSString *type;
    if (aReason == EMGroupLeaveReasonBeRemoved) {
        type = @"onUserRemoved";
    } else if (aReason == EMGroupLeaveReasonDestroyed) {
        type = @"onGroupDestroyed";
    }
    NSDictionary *map = @{
        @"type":type,
        @"groupId":aGroup.groupId,
        @"groupName":aGroup.subject
    };
    [self.channel invokeMethod:EMMethodKeyOnGroupChanged
                     arguments:map];
}

- (void)joinGroupRequestDidReceive:(EMGroup *)aGroup
                              user:(NSString *)aUsername
                            reason:(NSString *)aReason {
    NSDictionary *map = @{
        @"type":@"onRequestToJoinReceived",
        @"groupId":aGroup.groupId,
        @"applicant":aUsername,
        @"reason":aReason
    };
    [self.channel invokeMethod:EMMethodKeyOnGroupChanged
                     arguments:map];
}

- (void)joinGroupRequestDidDecline:(NSString *)aGroupId
                            reason:(NSString *)aReason {
    NSDictionary *map = @{
        @"type":@"onRequestToJoinDeclined",
        @"groupId":aGroupId,
        @"reason":aReason
    };
    [self.channel invokeMethod:EMMethodKeyOnGroupChanged
                     arguments:map];
}

- (void)joinGroupRequestDidApprove:(EMGroup *)aGroup {
    NSDictionary *map = @{
        @"type":@"onRequestToJoinAccepted",
        @"groupId":aGroup.groupId,
        @"groupName":aGroup.subject,
        @"accepter":aGroup.owner,
    };
    [self.channel invokeMethod:EMMethodKeyOnGroupChanged
                     arguments:map];
}

/*
- (void)groupListDidUpdate:(NSArray *)aGroupList {
    NSDictionary *map = @{
        @"type":@(GROUP_LIST_UPDATE),
        @"groupList":[self groupsArrayWithDictionaryArray:aGroupList]
    };
    [self.channel invokeMethod:EMMethodKeyOnGroupChanged
                     arguments:map];
}
*/
- (void)groupMuteListDidUpdate:(EMGroup *)aGroup
             addedMutedMembers:(NSArray *)aMutedMembers
                    muteExpire:(NSInteger)aMuteExpire {
    NSDictionary *map = @{
        @"type":@"onMuteListAdded",
        @"groupId":aGroup.groupId,
        @"mutes":aMutedMembers,
        @"muteExpire":[NSNumber numberWithInteger:aMuteExpire]
    };
    [self.channel invokeMethod:EMMethodKeyOnGroupChanged
                     arguments:map];
}

- (void)groupMuteListDidUpdate:(EMGroup *)aGroup
           removedMutedMembers:(NSArray *)aMutedMembers {
    NSDictionary *map = @{
        @"type":@"onMuteListRemoved",
        @"groupId":aGroup.groupId,
        @"mutes":aMutedMembers
    };
    [self.channel invokeMethod:EMMethodKeyOnGroupChanged
                     arguments:map];
}

- (void)groupAdminListDidUpdate:(EMGroup *)aGroup
                     addedAdmin:(NSString *)aAdmin {
    NSDictionary *map = @{
        @"type":@"onAdminAdded",
        @"groupId":aGroup.groupId,
        @"administrator":aAdmin
    };
    [self.channel invokeMethod:EMMethodKeyOnGroupChanged
                     arguments:map];
}

- (void)groupAdminListDidUpdate:(EMGroup *)aGroup
                   removedAdmin:(NSString *)aAdmin {
    NSDictionary *map = @{
        @"type":@"onAdminRemoved",
        @"groupId":aGroup.groupId,
        @"administrator":aAdmin
    };
    [self.channel invokeMethod:EMMethodKeyOnGroupChanged
                     arguments:map];
}

- (void)groupOwnerDidUpdate:(EMGroup *)aGroup
                   newOwner:(NSString *)aNewOwner
                   oldOwner:(NSString *)aOldOwner {
    NSDictionary *map = @{
        @"type":@"onOwnerChanged",
        @"groupId":aGroup.groupId,
        @"newOwner":aNewOwner,
        @"oldOwner":aOldOwner
    };
    [self.channel invokeMethod:EMMethodKeyOnGroupChanged
                     arguments:map];
}

- (void)userDidJoinGroup:(EMGroup *)aGroup
                    user:(NSString *)aUsername {
    NSDictionary *map = @{
        @"type":@"onMemberJoined",
        @"groupId":aGroup.groupId,
        @"member":aUsername
    };
    [self.channel invokeMethod:EMMethodKeyOnGroupChanged
                     arguments:map];
}

- (void)userDidLeaveGroup:(EMGroup *)aGroup
                     user:(NSString *)aUsername {
    NSDictionary *map = @{
        @"type":@"onMemberExited",
        @"groupId":aGroup.groupId,
        @"member":aUsername
    };
    [self.channel invokeMethod:EMMethodKeyOnGroupChanged
                     arguments:map];
}

- (void)groupAnnouncementDidUpdate:(EMGroup *)aGroup
                      announcement:(NSString *)aAnnouncement {
    NSDictionary *map = @{
        @"type":@"onAnnouncementChanged",
        @"groupId":aGroup.groupId,
        @"announcement":aAnnouncement
    };
    [self.channel invokeMethod:EMMethodKeyOnGroupChanged
                     arguments:map];
}

- (void)groupFileListDidUpdate:(EMGroup *)aGroup
               addedSharedFile:(EMGroupSharedFile *)aSharedFile {
    NSDictionary *map = @{
        @"type":@"onSharedFileAdded",
        @"groupId":aGroup.groupId,
        @"sharedFile":[EMHelper groupSharedFileToDictionary:aSharedFile]
    };
    [self.channel invokeMethod:EMMethodKeyOnGroupChanged
                     arguments:map];
}

- (void)groupFileListDidUpdate:(EMGroup *)aGroup
             removedSharedFile:(NSString *)aFileId {
    NSDictionary *map = @{
        @"type":@"onSharedFileDeleted",
        @"groupId":aGroup.groupId,
        @"fileId":aFileId
    };
    [self.channel invokeMethod:EMMethodKeyOnGroupChanged
                     arguments:map];
}

// 群组搜索结果转字典,EMCursorResult的list有群组列表和群组成员列表的区分，所以做判断区分
- (NSDictionary *)dictionaryWithCursorResult:(EMCursorResult *)cursorResult isGroupList:(BOOL)isGroupList
{
    NSDictionary *resultDict = nil;
    if (isGroupList) {
        resultDict= @{
            @"data":[EMHelper groupsToDictionaries:cursorResult.list],
            @"cursor":cursorResult.cursor
        };
    } else {
        resultDict= @{
            @"data":cursorResult.list,
            @"cursor":cursorResult.cursor
        };
    }
    
    return resultDict;
}

@end
