//
//  EMGroupManagerWrapper.m
//  FlutterTest
//
//  Created by 杜洁鹏 on 2019/10/17.
//  Copyright © 2019 Easemob. All rights reserved.
//

#import "EMGroupManagerWrapper.h"

#import "EMGroup+Flutter.h"
#import "EMCursorResult+Flutter.h"

#import "EMSDKMethod.h"

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
    
    if([EMMethodKeyGetGroupWithId isEqualToString:call.method]) {
        [self getGroupWithId:call.arguments
                      channelName:call.method
                      result:result];
    }
    else if ([EMMethodKeyGetJoinedGroups isEqualToString:call.method])
    {
        [self getJoinedGroups:call.arguments
                  channelName:call.method
                       result:result];
    }
    else if ([EMMethodKeyGetGroupsWithoutPushNotification isEqualToString:call.method])
    {
        [self getGroupsWithoutPushNotification:call.arguments
                                   channelName:call.method
                                        result:result];
    }
    else if ([EMMethodKeyGetJoinedGroupsFromServer isEqualToString:call.method])
    {
        [self getJoinedGroupsFromServer:call.arguments
                            channelName:call.method
                                 result:result];
    }
    else if ([EMMethodKeyGetPublicGroupsFromServer isEqualToString:call.method])
    {
        [self getPublicGroupsFromServer:call.arguments
                            channelName:call.method
                                 result:result];
    }
    else if ([EMMethodKeyCreateGroup isEqualToString:call.method])
    {
        [self createGroup:call.arguments
              channelName:call.method
                   result:result];
    }
    else if ([EMMethodKeyGetGroupSpecificationFromServer isEqualToString:call.method])
    {
        [self getGroupSpecificationFromServer:call.arguments
                                  channelName:call.method
                                       result:result];
    }
    else if ([EMMethodKeyGetGroupMemberListFromServer isEqualToString:call.method])
    {
        [self getGroupMemberListFromServer:call.arguments
                               channelName:call.method
                                    result:result];
    }
    else if ([EMMethodKeyGetGroupBlockListFromServer isEqualToString:call.method])
    {
        [self getGroupBlockListFromServer:call.arguments
                              channelName:call.method
                                   result:result];
    }
    else if ([EMMethodKeyGetGroupMuteListFromServer isEqualToString:call.method])
    {
        [self getGroupMuteListFromServer:call.arguments
                             channelName:call.method
                                  result:result];
    }
    else if ([EMMethodKeyGetGroupWhiteListFromServer isEqualToString:call.method])
    {
        [self getGroupWhiteListFromServer:call.arguments
                              channelName:call.method
                                   result:result];
    }
    else if ([EMMethodKeyIsMemberInWhiteListFromServer isEqualToString:call.method])
    {
        [self isMemberInWhiteListFromServer:call.arguments
                                channelName:call.method
                                     result:result];
    }
    else if ([EMMethodKeyGetGroupFileListFromServer isEqualToString:call.method])
    {
        [self getGroupFileListFromServer:call.arguments
                             channelName:call.method
                                  result:result];
    }
    else if ([EMMethodKeyGetGroupAnnouncementFromServer isEqualToString:call.method])
    {
        [self getGroupAnnouncementFromServer:call.arguments
                                 channelName:call.method
                                      result:result];
    }
    else if ([EMMethodKeyAddMembers isEqualToString:call.method])
    {
        [self addMembers:call.arguments
             channelName:call.method
                  result:result];
    }
    else if ([EMMethodKeyInviterUser isEqualToString:call.method]){
        [self inviterUsers:call.arguments
               channelName:call.method
                    result:result];
    }
    else if ([EMMethodKeyRemoveMembers isEqualToString:call.method])
    {
        [self removeMembers:call.arguments
                channelName:call.method
                     result:result];
    }
    else if ([EMMethodKeyBlockMembers isEqualToString:call.method])
    {
        [self blockMembers:call.arguments
               channelName:call.method
                    result:result];
    }
    else if ([EMMethodKeyUnblockMembers isEqualToString:call.method])
    {
        [self unblockMembers:call.arguments
                 channelName:call.method
                      result:result];
    }
    else if([EMMethodKeyUpdateGroupSubject isEqualToString:call.method])
    {
        [self updateGroupSubject:call.arguments
                     channelName:call.method
                          result:result];
    }
    else if([EMMethodKeyUpdateDescription isEqualToString:call.method])
    {
        [self updateDescription:call.arguments
                    channelName:call.method
                         result:result];
    }
    else if([EMMethodKeyLeaveGroup isEqualToString:call.method])
    {
        [self leaveGroup:call.arguments
             channelName:call.method
                  result:result];
    }
    else if([EMMethodKeyDestroyGroup isEqualToString:call.method])
    {
        [self destroyGroup:call.arguments
               channelName:call.method
                    result:result];
    }
    else if([EMMethodKeyBlockGroup isEqualToString:call.method])
    {
        [self blockGroup:call.arguments
             channelName:call.method
                  result:result];
    }
    else if([EMMethodKeyUnblockGroup isEqualToString:call.method])
    {
        [self unblockGroup:call.arguments
               channelName:call.method
                    result:result];
    }
    else if([EMMethodKeyUpdateGroupOwner isEqualToString:call.method])
    {
        [self updateGroupOwner:call.arguments
                   channelName:call.method
                        result:result];
    }
    else if([EMMethodKeyAddAdmin isEqualToString:call.method])
    {
        [self addAdmin:call.arguments
           channelName:call.method
                result:result];
    }
    else if([EMMethodKeyRemoveAdmin isEqualToString:call.method])
    {
        [self removeAdmin:call.arguments
              channelName:call.method
                   result:result];
    }
    else if([EMMethodKeyMuteMembers isEqualToString:call.method])
    {
        [self muteMembers:call.arguments
              channelName:call.method
                   result:result];
    }
    else if([EMMethodKeyUnMuteMembers isEqualToString:call.method])
    {
        [self unMuteMembers:call.arguments
                channelName:call.method
                     result:result];
    }
    else if([EMMethodKeyMuteAllMembers isEqualToString:call.method])
    {
        [self muteAllMembers:call.arguments
                 channelName:call.method
                      result:result];
    }
    else if([EMMethodKeyUnMuteAllMembers isEqualToString:call.method])
    {
        [self unMuteAllMembers:call.arguments
                   channelName:call.method
                        result:result];
    }
    else if([EMMethodKeyAddWhiteList isEqualToString:call.method])
    {
        [self addWhiteList:call.arguments
               channelName:call.method
                    result:result];
    }
    else if([EMMethodKeyRemoveWhiteList isEqualToString:call.method])
    {
        [self removeWhiteList:call.arguments
                  channelName:call.method
                       result:result];
    }
    else if([EMMethodKeyUploadGroupSharedFile isEqualToString:call.method])
    {
        [self uploadGroupSharedFile:call.arguments
                        channelName:call.method
                             result:result];
    }
    else if([EMMethodKeyDownloadGroupSharedFile isEqualToString:call.method])
    {
        [self downloadGroupSharedFile:call.arguments
                          channelName:call.method
                               result:result];
    }
    else if([EMMethodKeyRemoveGroupSharedFile isEqualToString:call.method])
    {
        [self removeGroupSharedFile:call.arguments
                        channelName:call.method
                             result:result];
    }
    else if([EMMethodKeyUpdateGroupAnnouncement isEqualToString:call.method])
    {
        [self updateGroupAnnouncement:call.arguments
                          channelName:call.method
                               result:result];
    }
    else if([EMMethodKeyUpdateGroupExt isEqualToString:call.method])
    {
        [self updateGroupExt:call.arguments
                 channelName:call.method
                      result:result];
    }
    else if([EMMethodKeyJoinPublicGroup isEqualToString:call.method])
    {
        [self joinPublicGroup:call.arguments
                  channelName:call.method
                       result:result];
    }
    else if([EMMethodKeyRequestToJoinPublicGroup isEqualToString:call.method])
    {
        [self requestToJoinPublicGroup:call.arguments
                           channelName:call.method
                                result:result];
    }
    else if([EMMethodKeyAcceptJoinApplication isEqualToString:call.method])
    {
        [self acceptJoinApplication:call.arguments
                        channelName:call.method
                             result:result];
    }
    else if([EMMethodKeyDeclineJoinApplication isEqualToString:call.method])
    {
        [self declineJoinApplication:call.arguments
                         channelName:call.method
                              result:result];
    }
    else if([EMMethodKeyAcceptInvitationFromGroup isEqualToString:call.method])
    {
        [self acceptInvitationFromGroup:call.arguments
                            channelName:call.method
                                 result:result];
    }
    else if([EMMethodKeyDeclineInvitationFromGroup isEqualToString:call.method])
    {
        [self declineInvitationFromGroup:call.arguments
                             channelName:call.method
                                  result:result];
    }
    else if([EMMethodKeyIgnoreGroupPush isEqualToString:call.method])
    {
        [self ignoreGroupPush:call.arguments
                  channelName:call.method
                       result:result];
    }
    else
    {
        [super handleMethodCall:call result:result];
    }
}

#pragma mark - Actions

- (void)getGroupWithId:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    EMGroup *group = [EMGroup groupWithId:param[@"groupId"]];
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:[group toJson]];
}


- (void)getJoinedGroups:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSArray *joinedGroups = [EMClient.sharedClient.groupManager getJoinedGroups];
    NSMutableArray *list = [NSMutableArray array];
    for (EMGroup *group in joinedGroups) {
        [list addObject:[group toJson]];
    }
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:list];
}

- (void)getGroupsWithoutPushNotification:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    EMError *error = nil;
    NSArray *groups = [EMClient.sharedClient.groupManager getGroupsWithoutPushNotification:&error];
    NSMutableArray *list = [NSMutableArray array];
    for (EMGroup *group in groups) {
        [list addObject:[group toJson]];
    }
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:error
                       object:list];
}

- (void)getJoinedGroupsFromServer:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.groupManager getJoinedGroupsFromServerWithPage:[param[@"pageNum"] intValue]
                                                                 pageSize:[param[@"pageSize"] intValue]
                                                               completion:^(NSArray *aList, EMError *aError)
     {
        NSMutableArray *list = [NSMutableArray array];
        for (EMGroup *group in aList) {
            [list addObject:[group toJson]];
        }
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:list];
        
    }];
}

- (void)getPublicGroupsFromServer:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.groupManager getPublicGroupsFromServerWithCursor:param[@"cursor"]
                                                                   pageSize:[param[@"pageSize"] integerValue]
                                                                 completion:^(EMCursorResult *aResult, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[aResult toJson]];
    }];
}

- (void)createGroup:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.groupManager createGroupWithSubject:param[@"groupName"]
                                                   description:param[@"desc"]
                                                      invitees:param[@"inviteMembers"]
                                                       message:param[@"inviteReason"]
                                                       setting:[EMGroupOptions formJson:param[@"options"]]
                                                    completion:^(EMGroup *aGroup, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[aGroup toJson]];
    }];
}

- (void)getGroupSpecificationFromServer:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.groupManager getGroupSpecificationFromServerWithId:param[@"groupId"]
                                                                   completion:^(EMGroup *aGroup, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[aGroup toJson]];
    }];
}

- (void)getGroupMemberListFromServer:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.groupManager getGroupMemberListFromServerWithId:param[@"groupId"]
                                                                    cursor:param[@"cursor"]
                                                                  pageSize:[param[@"pageSize"] intValue]
                                                                completion:^(EMCursorResult *aResult, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[aResult toJson]];
    }];
}

- (void)getGroupBlockListFromServer:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.groupManager getGroupBlacklistFromServerWithId:param[@"groupId"]
                                                               pageNumber:[param[@"pageNum"] intValue]
                                                                 pageSize:[param[@"pageSize"] intValue]
                                                               completion:^(NSArray *aList, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:aList];
    }];
}

- (void)getGroupMuteListFromServer:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.groupManager getGroupMuteListFromServerWithId:param[@"groupId"]
                                                              pageNumber:[param[@"pageNum"] intValue]
                                                                pageSize:[param[@"pageSize"] intValue]
                                                              completion:^(NSArray *aList, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:aList];
    }];
}

- (void)getGroupWhiteListFromServer:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.groupManager getGroupWhiteListFromServerWithId:param[@"groupId"]
                                                               completion:^(NSArray *aList, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:aList];
    }];
}

- (void)isMemberInWhiteListFromServer:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.groupManager isMemberInWhiteListFromServerWithGroupId:param[@"groupId"]
                                                                      completion:^(BOOL inWhiteList, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:@(inWhiteList)];
    }];
}

- (void)getGroupFileListFromServer:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.groupManager getGroupFileListWithId:param[@"groupId"]
                                                    pageNumber:[param[@"pageNum"] intValue]
                                                      pageSize:[param[@"pageSize"] intValue]
                                                    completion:^(NSArray *aList, EMError *aError)
     {
        
        NSMutableArray *array = [NSMutableArray array];
        for (EMGroupSharedFile *file in aList) {
            [array addObject:[file toJson]];
        }
        
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:array];
    }];
}
- (void)getGroupAnnouncementFromServer:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.groupManager getGroupAnnouncementWithId:param[@"groupId"]
                                                        completion:^(NSString *aAnnouncement, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:aAnnouncement];
    }];
}

- (void)addMembers:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.groupManager addMembers:param[@"members"]
                                           toGroup:param[@"groupId"]
                                           message:param[@"welcome"]
                                        completion:^(EMGroup *aGroup, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[aGroup toJson]];
    }];
}

- (void)inviterUsers:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.groupManager addMembers:param[@"members"]
                                            toGroup:param[@"groupId"]
                                            message:param[@"reason"]
                                         completion:^(EMGroup *aGroup, EMError *aError) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[aGroup toJson]];
    }];
    
}

- (void)removeMembers:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.groupManager removeMembers:param[@"members"]
                                            fromGroup:param[@"groupId"]
                                           completion:^(EMGroup *aGroup, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[aGroup toJson]];
    }];
    
}

- (void)blockMembers:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.groupManager blockMembers:param[@"members"]
                                           fromGroup:param[@"groupId"]
                                          completion:^(EMGroup *aGroup, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[aGroup toJson]];
    }];
}

- (void)unblockMembers:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.groupManager unblockMembers:param[@"members"]
                                             fromGroup:param[@"groupId"]
                                            completion:^(EMGroup *aGroup, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[aGroup toJson]];
    }];
}

- (void)updateGroupSubject:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.groupManager updateGroupSubject:param[@"name"]
                                                  forGroup:param[@"groupId"]
                                                completion:^(EMGroup *aGroup, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[aGroup toJson]];
    }];
}

- (void)updateDescription:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.groupManager updateDescription:param[@"desc"]
                                                 forGroup:param[@"groupId"]
                                               completion:^(EMGroup *aGroup, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[aGroup toJson]];
    }];
}

- (void)leaveGroup:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.groupManager leaveGroup:param[@"groupId"]
                                        completion:^(EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:nil];
    }];
}

- (void)destroyGroup:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.groupManager destroyGroup:param[@"groupId"]
                                    finishCompletion:^(EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:nil];
        
    }];
}

- (void)blockGroup:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.groupManager blockGroup:param[@"groupId"]
                                        completion:^(EMGroup *aGroup, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[aGroup toJson]];
        
    }];
}

- (void)unblockGroup:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.groupManager unblockGroup:param[@"groupId"]
                                          completion:^(EMGroup *aGroup, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[aGroup toJson]];
    }];
}

- (void)updateGroupOwner:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.groupManager updateGroupOwner:param[@"groupId"]
                                                newOwner:param[@"owner"]
                                              completion:^(EMGroup *aGroup, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[aGroup toJson]];
    }];
}

- (void)addAdmin:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.groupManager addAdmin:param[@"admin"]
                                         toGroup:param[@"groupId"]
                                      completion:^(EMGroup *aGroup, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[aGroup toJson]];
    }];
}

- (void)removeAdmin:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.groupManager removeAdmin:param[@"admin"]
                                          fromGroup:param[@"groupId"]
                                         completion:^(EMGroup *aGroup, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[aGroup toJson]];
    }];
}

- (void)muteMembers:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.groupManager muteMembers:param[@"members"]
                                   muteMilliseconds:[param[@"duration"] integerValue]
                                          fromGroup:param[@"groupId"]
                                         completion:^(EMGroup *aGroup, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[aGroup toJson]];
    }];
}

- (void)unMuteMembers:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.groupManager unmuteMembers:param[@"members"]
                                            fromGroup:param[@"groupId"]
                                           completion:^(EMGroup *aGroup, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[aGroup toJson]];
    }];
}

- (void)muteAllMembers:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.groupManager muteAllMembersFromGroup:param[@"groupId"]
                                                     completion:^(EMGroup *aGroup, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[aGroup toJson]];
    }];
}

- (void)unMuteAllMembers:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.groupManager unmuteAllMembersFromGroup:param[@"groupId"]
                                                       completion:^(EMGroup *aGroup, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[aGroup toJson]];
    }];
}

- (void)addWhiteList:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.groupManager addWhiteListMembers:param[@"members"]
                                                  fromGroup:param[@"groupId"]
                                                 completion:^(EMGroup *aGroup, EMError *aError) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[aGroup toJson]];
    }];
}

- (void)removeWhiteList:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
        __weak typeof(self) weakSelf = self;
        [EMClient.sharedClient.groupManager removeWhiteListMembers:param[@"members"]
                                                         fromGroup:param[@"groupId"]
                                                        completion:^(EMGroup *aGroup, EMError *aError) {
            [weakSelf wrapperCallBack:result
                          channelName:aChannelName
                                error:aError
                               object:[aGroup toJson]];
        }];
}


- (void)uploadGroupSharedFile:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.groupManager uploadGroupSharedFileWithId:param[@"groupId"]
                                                           filePath:param[@"filePath"]
                                                           progress:^(int progress)
     {
        
    } completion:^(EMGroupSharedFile *aSharedFile, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:@(!aError)];
    }];
}

- (void)downloadGroupSharedFile:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.groupManager downloadGroupSharedFileWithId:param[@"groupId"]
                                                             filePath:param[@"savePath"]
                                                         sharedFileId:param[@"fileId"]
                                                             progress:^(int progress)
     {
        
    } completion:^(EMGroup *aGroup, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:@(!aError)];
    }];
}

- (void)removeGroupSharedFile:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.groupManager removeGroupSharedFileWithId:param[@"groupId"]
                                                       sharedFileId:param[@"fileId"]
                                                         completion:^(EMGroup *aGroup, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:@(!aError)];
    }];
}

- (void)updateGroupAnnouncement:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.groupManager updateGroupAnnouncementWithId:param[@"groupId"]
                                                         announcement:param[@"announcement"]
                                                           completion:^(EMGroup *aGroup, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[aGroup toJson]];
    }];
    
}

- (void)updateGroupExt:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.groupManager updateGroupExtWithId:param[@"groupId"]
                                                         ext:param[@"ext"]
                                                  completion:^(EMGroup *aGroup, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[aGroup toJson]];
    }];
}

- (void)joinPublicGroup:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    
    [EMClient.sharedClient.groupManager joinPublicGroup:param[@"groupId"]
                                             completion:^(EMGroup *aGroup, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[aGroup toJson]];
    }];
}

- (void)requestToJoinPublicGroup:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.groupManager requestToJoinPublicGroup:param[@"groupId"]
                                                         message:param[@"reason"]
                                                      completion:^(EMGroup *aGroup, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[aGroup toJson]];
    }];
}

- (void)acceptJoinApplication:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.groupManager approveJoinGroupRequest:param[@"groupId"]
                                                         sender:param[@"username"]
                                                     completion:^(EMGroup *aGroup, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[aGroup toJson]];
    }];
}

- (void)declineJoinApplication:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.groupManager declineJoinGroupRequest:param[@"groupId"]
                                                         sender:param[@"username"]
                                                         reason:param[@"reason"]
                                                     completion:^(EMGroup *aGroup, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[aGroup toJson]];
    }];
}

- (void)acceptInvitationFromGroup:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.groupManager acceptInvitationFromGroup:param[@"groupId"]
                                                          inviter:param[@"inviter"]
                                                       completion:^(EMGroup *aGroup, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[aGroup toJson]];
    }];
}

- (void)declineInvitationFromGroup:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.groupManager declineGroupInvitation:param[@"groupId"]
                                                       inviter:param[@"inviter"]
                                                        reason:param[@"reason"]
                                                    completion:^(EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:nil];
    }];
}

- (void)ignoreGroupPush:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    
    __block NSString *groupId = param[@"groupId"];
    [EMClient.sharedClient.pushManager updatePushServiceForGroups:@[groupId]
                                                      disablePush:[param[@"ignore"] boolValue]
                                                       completion:^(EMError * _Nonnull aError) {
        EMGroup *aGroup = [EMGroup groupWithId:groupId];
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[aGroup toJson]];
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
        @"groupName":aGroup.groupName
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
        @"groupName":aGroup.groupName,
        @"accepter":aGroup.owner,
    };
    [self.channel invokeMethod:EMMethodKeyOnGroupChanged
                     arguments:map];
}

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

- (void)groupWhiteListDidUpdate:(EMGroup *)aGroup
          addedWhiteListMembers:(NSArray *)aMembers {
    NSDictionary *map = @{
        @"type":@"onWhiteListAdded",
        @"groupId":aGroup.groupId,
        @"whitelist":aMembers
    };
    [self.channel invokeMethod:EMMethodKeyOnGroupChanged
                     arguments:map];
}

- (void)groupWhiteListDidUpdate:(EMGroup *)aGroup
        removedWhiteListMembers:(NSArray *)aMembers {
    NSDictionary *map = @{
        @"type":@"onWhiteListRemoved",
        @"groupId":aGroup.groupId,
        @"whitelist":aMembers
    };
    [self.channel invokeMethod:EMMethodKeyOnGroupChanged
                     arguments:map];
}

- (void)groupAllMemberMuteChanged:(EMGroup *)aGroup
                 isAllMemberMuted:(BOOL)aMuted {
    NSDictionary *map = @{
        @"type":@"onAllMemberMuteStateChanged",
        @"groupId":aGroup.groupId,
        @"isMuted":@(aMuted)
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
        @"sharedFile":[aSharedFile toJson]
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


@end
