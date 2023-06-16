//
//  EMGroupManagerWrapper.m
//  FlutterTest
//
//  Created by 杜洁鹏 on 2019/10/17.
//  Copyright © 2019 Easemob. All rights reserved.
//

#import "EMGroupManagerWrapper.h"

#import "EMGroup+Helper.h"
#import "EMCursorResult+Helper.h"
#import "EMListenerHandle.h"
#import "EMSDKMethod.h"
#import "EMClientWrapper.h"

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

- (void)unRegisterEaseListener {
    [EMClient.sharedClient.groupManager removeDelegate:self];
}


#pragma mark - FlutterPlugin

- (void)handleMethodCall:(FlutterMethodCall*)call
                  result:(FlutterResult)result {
    
    if([ChatGetGroupWithId isEqualToString:call.method]) {
        [self getGroupWithId:call.arguments
                      channelName:call.method
                      result:result];
    }
    else if ([ChatGetJoinedGroups isEqualToString:call.method])
    {
        [self getJoinedGroups:call.arguments
                  channelName:call.method
                       result:result];
    }

    else if ([ChatGetJoinedGroupsFromServer isEqualToString:call.method])
    {
        [self getJoinedGroupsFromServer:call.arguments
                            channelName:call.method
                                 result:result];
    }
    else if ([ChatGetPublicGroupsFromServer isEqualToString:call.method])
    {
        [self getPublicGroupsFromServer:call.arguments
                            channelName:call.method
                                 result:result];
    }
    else if ([ChatCreateGroup isEqualToString:call.method])
    {
        [self createGroup:call.arguments
              channelName:call.method
                   result:result];
    }
    else if ([ChatGetGroupSpecificationFromServer isEqualToString:call.method])
    {
        [self getGroupSpecificationFromServer:call.arguments
                                  channelName:call.method
                                       result:result];
    }
    else if ([ChatGetGroupMemberListFromServer isEqualToString:call.method])
    {
        [self getGroupMemberListFromServer:call.arguments
                               channelName:call.method
                                    result:result];
    }
    else if ([ChatGetGroupBlockListFromServer isEqualToString:call.method])
    {
        [self getGroupBlockListFromServer:call.arguments
                              channelName:call.method
                                   result:result];
    }
    else if ([ChatGetGroupMuteListFromServer isEqualToString:call.method])
    {
        [self getGroupMuteListFromServer:call.arguments
                             channelName:call.method
                                  result:result];
    }
    else if ([ChatGetGroupWhiteListFromServer isEqualToString:call.method])
    {
        [self getGroupWhiteListFromServer:call.arguments
                              channelName:call.method
                                   result:result];
    }
    else if ([ChatIsMemberInWhiteListFromServer isEqualToString:call.method])
    {
        [self isMemberInWhiteListFromServer:call.arguments
                                channelName:call.method
                                     result:result];
    }
    else if ([ChatGetGroupFileListFromServer isEqualToString:call.method])
    {
        [self getGroupFileListFromServer:call.arguments
                             channelName:call.method
                                  result:result];
    }
    else if ([ChatGetGroupAnnouncementFromServer isEqualToString:call.method])
    {
        [self getGroupAnnouncementFromServer:call.arguments
                                 channelName:call.method
                                      result:result];
    }
    else if ([ChatAddMembers isEqualToString:call.method])
    {
        [self addMembers:call.arguments
             channelName:call.method
                  result:result];
    }
    else if ([ChatInviterUser isEqualToString:call.method]){
        [self inviterUsers:call.arguments
               channelName:call.method
                    result:result];
    }
    else if ([ChatRemoveMembers isEqualToString:call.method])
    {
        [self removeMembers:call.arguments
                channelName:call.method
                     result:result];
    }
    else if ([ChatBlockMembers isEqualToString:call.method])
    {
        [self blockMembers:call.arguments
               channelName:call.method
                    result:result];
    }
    else if ([ChatUnblockMembers isEqualToString:call.method])
    {
        [self unblockMembers:call.arguments
                 channelName:call.method
                      result:result];
    }
    else if([ChatUpdateGroupSubject isEqualToString:call.method])
    {
        [self updateGroupSubject:call.arguments
                     channelName:call.method
                          result:result];
    }
    else if([ChatUpdateDescription isEqualToString:call.method])
    {
        [self updateDescription:call.arguments
                    channelName:call.method
                         result:result];
    }
    else if([ChatLeaveGroup isEqualToString:call.method])
    {
        [self leaveGroup:call.arguments
             channelName:call.method
                  result:result];
    }
    else if([ChatDestroyGroup isEqualToString:call.method])
    {
        [self destroyGroup:call.arguments
               channelName:call.method
                    result:result];
    }
    else if([ChatBlockGroup isEqualToString:call.method])
    {
        [self blockGroup:call.arguments
             channelName:call.method
                  result:result];
    }
    else if([ChatUnblockGroup isEqualToString:call.method])
    {
        [self unblockGroup:call.arguments
               channelName:call.method
                    result:result];
    }
    else if([ChatUpdateGroupOwner isEqualToString:call.method])
    {
        [self updateGroupOwner:call.arguments
                   channelName:call.method
                        result:result];
    }
    else if([ChatAddAdmin isEqualToString:call.method])
    {
        [self addAdmin:call.arguments
           channelName:call.method
                result:result];
    }
    else if([ChatRemoveAdmin isEqualToString:call.method])
    {
        [self removeAdmin:call.arguments
              channelName:call.method
                   result:result];
    }
    else if([ChatMuteMembers isEqualToString:call.method])
    {
        [self muteMembers:call.arguments
              channelName:call.method
                   result:result];
    }
    else if([ChatUnMuteMembers isEqualToString:call.method])
    {
        [self unMuteMembers:call.arguments
                channelName:call.method
                     result:result];
    }
    else if([ChatMuteAllMembers isEqualToString:call.method])
    {
        [self muteAllMembers:call.arguments
                 channelName:call.method
                      result:result];
    }
    else if([ChatUnMuteAllMembers isEqualToString:call.method])
    {
        [self unMuteAllMembers:call.arguments
                   channelName:call.method
                        result:result];
    }
    else if([ChatAddWhiteList isEqualToString:call.method])
    {
        [self addWhiteList:call.arguments
               channelName:call.method
                    result:result];
    }
    else if([ChatRemoveWhiteList isEqualToString:call.method])
    {
        [self removeWhiteList:call.arguments
                  channelName:call.method
                       result:result];
    }
    else if([ChatUploadGroupSharedFile isEqualToString:call.method])
    {
        [self uploadGroupSharedFile:call.arguments
                        channelName:call.method
                             result:result];
    }
    else if([ChatDownloadGroupSharedFile isEqualToString:call.method])
    {
        [self downloadGroupSharedFile:call.arguments
                          channelName:call.method
                               result:result];
    }
    else if([ChatRemoveGroupSharedFile isEqualToString:call.method])
    {
        [self removeGroupSharedFile:call.arguments
                        channelName:call.method
                             result:result];
    }
    else if([ChatUpdateGroupAnnouncement isEqualToString:call.method])
    {
        [self updateGroupAnnouncement:call.arguments
                          channelName:call.method
                               result:result];
    }
    else if([ChatUpdateGroupExt isEqualToString:call.method])
    {
        [self updateGroupExt:call.arguments
                 channelName:call.method
                      result:result];
    }
    else if([ChatJoinPublicGroup isEqualToString:call.method])
    {
        [self joinPublicGroup:call.arguments
                  channelName:call.method
                       result:result];
    }
    else if([ChatRequestToJoinPublicGroup isEqualToString:call.method])
    {
        [self requestToJoinPublicGroup:call.arguments
                           channelName:call.method
                                result:result];
    }
    else if([ChatAcceptJoinApplication isEqualToString:call.method])
    {
        [self acceptJoinApplication:call.arguments
                        channelName:call.method
                             result:result];
    }
    else if([ChatDeclineJoinApplication isEqualToString:call.method])
    {
        [self declineJoinApplication:call.arguments
                         channelName:call.method
                              result:result];
    }
    else if([ChatAcceptInvitationFromGroup isEqualToString:call.method])
    {
        [self acceptInvitationFromGroup:call.arguments
                            channelName:call.method
                                 result:result];
    }
    else if([ChatDeclineInvitationFromGroup isEqualToString:call.method])
    {
        [self declineInvitationFromGroup:call.arguments
                             channelName:call.method
                                  result:result];
    }
    else if ([ChatSetMemberAttributesFromGroup isEqualToString:call.method]) {
        [self setMemberAttributes:call.arguments channelName:call.method result:result];
    }
    else if ([ChatRemoveMemberAttributesFromGroup isEqualToString:call.method]) {
        [self removeMemberAttributes:call.arguments channelName:call.method result:result];
    }
    else if ([ChatFetchMemberAttributesFromGroup isEqualToString:call.method]) {
        [self fetchMemberAttributes:call.arguments channelName:call.method result:result];
    }
    else if ([ChatFetchMembersAttributesFromGroup isEqualToString:call.method]) {
        [self fetchMembersAttributes:call.arguments channelName:call.method result:result];
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

- (void)getJoinedGroupsFromServer:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    
    int pageNum = [param[@"pageNum"] intValue];
    int pageSize = [param[@"pageSize"] intValue];
    BOOL needRole = [param[@"needRole"] boolValue];
    BOOL needMemberCount = [param[@"needMemberCount"] boolValue];
    
    [EMClient.sharedClient.groupManager getJoinedGroupsFromServerWithPage:pageNum
                                                                 pageSize:pageSize
                                                          needMemberCount:needMemberCount
                                                                 needRole:needRole
                                                               completion:^(NSArray<EMGroup *> *aList, EMError * _Nullable aError)
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
    NSString *groupId = param[@"groupId"];
    BOOL fetchMembers = [param[@"fetchMembers"] boolValue];
    [EMClient.sharedClient.groupManager getGroupSpecificationFromServerWithId:groupId
                                                                 fetchMembers:fetchMembers
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
    
    [EMClient.sharedClient.groupManager fetchGroupMuteListFromServerWithId:param[@"groupId"]
                                                                pageNumber:[param[@"pageNum"] intValue]
                                                                  pageSize:[param[@"pageSize"] intValue]
                                                                completion:^(NSDictionary<NSString *,NSNumber *> *aDict, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:aDict];
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
    __block NSString *fileId = param[@"fileId"];
    __block NSString *savePath = param[@"savePath"];
    [EMClient.sharedClient.groupManager downloadGroupSharedFileWithId:param[@"groupId"]
                                                             filePath:savePath
                                                         sharedFileId:fileId
                                                             progress:^(int progress)
     {
        [self.clientWrapper.progressManager sendDownloadProgressToFlutter:fileId progress:progress];
    } completion:^(EMGroup *aGroup, EMError *aError)
     {
        if (aError) {
            [self.clientWrapper.progressManager sendDownloadErrorToFlutter:fileId error:aError];
        }else {
            [self.clientWrapper.progressManager sendDownloadSuccessToFlutter:fileId path:savePath];
        }
    }];
    [self wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:@(YES)];
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

- (void)setMemberAttributes:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    
    NSString *groupId = param[@"groupId"];
    NSString *userId = param[@"userId"];
    if(userId == nil){
        userId = EMClient.sharedClient.currentUsername;
    }
    NSDictionary *attributes = param[@"attributes"];
    
    [EMClient.sharedClient.groupManager setMemberAttribute:groupId
                                                    userId:userId
                                                attributes:attributes
                                                completion:^(EMError * _Nullable error)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:error
                           object:nil];
    }];
}

- (void)removeMemberAttributes:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    
    NSString *groupId = param[@"groupId"];
    NSString *userId = param[@"userId"];
    if(userId == nil){
        userId = EMClient.sharedClient.currentUsername;
    }
    NSArray *keys = param[@"keys"];
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    for (NSString *key in keys) {
        attrs[key] = @"";
    }
    
    [EMClient.sharedClient.groupManager setMemberAttribute:groupId
                                                    userId:userId
                                                attributes:attrs
                                                completion:^(EMError * _Nullable error)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:error
                           object:nil];
    }];
}

- (void)fetchMemberAttributes:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    
    NSString *groupId = param[@"groupId"];
    NSString *userId = param[@"userId"];
    if(userId == nil){
        userId = EMClient.sharedClient.currentUsername;
    }
    [EMClient.sharedClient.groupManager fetchMemberAttribute:groupId
                                                       userId:userId
                                                   completion:^(NSDictionary<NSString *,NSString *> * properties, EMError * aError)
      {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:properties];
    }];
}

- (void)fetchMembersAttributes:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    
    NSString *groupId = param[@"groupId"];
    NSArray *userIds = param[@"userIds"];
    NSArray *keys = param[@"keys"];
    if(!keys) {
        keys = [NSArray new];
    }

    [EMClient.sharedClient.groupManager fetchMembersAttributes:groupId userIds:userIds keys:keys completion:^(NSDictionary<NSString *,NSDictionary<NSString *,NSString *> *> * _Nullable attributes, EMError * _Nullable error) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:error
                           object:attributes];
    }];
}



#pragma mark - EMGroupManagerDelegate

- (void)groupInvitationDidReceive:(NSString *)aGroupId
                        groupName:(NSString * _Nonnull)aGroupName
                          inviter:(NSString * _Nonnull)aInviter
                          message:(NSString * _Nullable)aMessage
{

    
    __weak typeof(self) weakSelf = self;
    [EMListenerHandle.sharedInstance addHandle:^{
        NSDictionary *map = @{
            @"type":@"onGroupInvitationReceived",
            @"groupId":aGroupId,
            @"groupName": aGroupName,
            @"inviter":aInviter,
            @"message":aMessage
        };
        [weakSelf.channel invokeMethod:ChatOnGroupChanged
                         arguments:map];
    }];
    
}

- (void)groupInvitationDidAccept:(EMGroup *)aGroup
                         invitee:(NSString *)aInvitee {

    
    __weak typeof(self) weakSelf = self;
    [EMListenerHandle.sharedInstance addHandle:^{
        NSDictionary *map = @{
            @"type":@"onGroupInvitationAccepted",
            @"groupId":aGroup.groupId,
            @"invitee":aInvitee
        };
        [weakSelf.channel invokeMethod:ChatOnGroupChanged
                         arguments:map];
    }];
    
}

- (void)groupInvitationDidDecline:(EMGroup *)aGroup
                          invitee:(NSString *)aInvitee
                           reason:(NSString *)aReason {

    
    __weak typeof(self) weakSelf = self;
    [EMListenerHandle.sharedInstance addHandle:^{
        NSDictionary *map = @{
            @"type":@"onGroupInvitationDeclined",
            @"groupId":aGroup.groupId,
            @"invitee":aInvitee,
            @"reason":aReason
        };
        [weakSelf.channel invokeMethod:ChatOnGroupChanged
                         arguments:map];
    }];
}

- (void)didJoinGroup:(EMGroup *)aGroup
             inviter:(NSString *)aInviter
             message:(NSString *)aMessage {

    
    __weak typeof(self) weakSelf = self;
    [EMListenerHandle.sharedInstance addHandle:^{
        NSDictionary *map = @{
            @"type":@"onGroupAutoAcceptInvitation",
            @"groupId":aGroup.groupId,
            @"message":aMessage,
            @"inviter":aInviter
        };
        [weakSelf.channel invokeMethod:ChatOnGroupChanged
                         arguments:map];
    }];
}

- (void)didLeaveGroup:(EMGroup *)aGroup
               reason:(EMGroupLeaveReason)aReason {

    
    __weak typeof(self) weakSelf = self;
    [EMListenerHandle.sharedInstance addHandle:^{
        NSString *type;
        if (aReason == EMGroupLeaveReasonBeRemoved) {
            type = @"onGroupUserRemoved";
        } else if (aReason == EMGroupLeaveReasonDestroyed) {
            type = @"onGroupDestroyed";
        }
        NSDictionary *map = @{
            @"type":type,
            @"groupId":aGroup.groupId,
            @"groupName":aGroup.groupName
        };
        [weakSelf.channel invokeMethod:ChatOnGroupChanged
                         arguments:map];
    }];
    
}

- (void)joinGroupRequestDidReceive:(EMGroup *)aGroup
                              user:(NSString *)aUsername
                            reason:(NSString *)aReason {

    
    __weak typeof(self) weakSelf = self;
    [EMListenerHandle.sharedInstance addHandle:^{
        NSDictionary *map = @{
            @"type":@"onGroupRequestToJoinReceived",
            @"groupId":aGroup.groupId,
            @"applicant":aUsername,
            @"reason":aReason
        };
        [weakSelf.channel invokeMethod:ChatOnGroupChanged
                         arguments:map];
    }];
}

- (void)joinGroupRequestDidDecline:(NSString *)aGroupId
                            reason:(NSString *)aReason {

    
    __weak typeof(self) weakSelf = self;
    [EMListenerHandle.sharedInstance addHandle:^{
        NSDictionary *map = @{
            @"type":@"onGroupRequestToJoinDeclined",
            @"groupId":aGroupId,
            @"reason":aReason
        };
        [weakSelf.channel invokeMethod:ChatOnGroupChanged
                         arguments:map];
    }];
}

- (void)joinGroupRequestDidApprove:(EMGroup *)aGroup {

    
    __weak typeof(self) weakSelf = self;
    [EMListenerHandle.sharedInstance addHandle:^{
        NSDictionary *map = @{
            @"type":@"onGroupRequestToJoinAccepted",
            @"groupId":aGroup.groupId,
            @"groupName":aGroup.groupName,
            @"accepter":aGroup.owner,
        };
        [weakSelf.channel invokeMethod:ChatOnGroupChanged
                         arguments:map];
    }];
}

- (void)groupMuteListDidUpdate:(EMGroup *)aGroup
             addedMutedMembers:(NSArray *)aMutedMembers
                    muteExpire:(NSInteger)aMuteExpire {

    
    __weak typeof(self) weakSelf = self;
    [EMListenerHandle.sharedInstance addHandle:^{
        NSDictionary *map = @{
            @"type":@"onGroupMuteListAdded",
            @"groupId":aGroup.groupId,
            @"mutes":aMutedMembers,
            @"muteExpire":[NSNumber numberWithInteger:aMuteExpire]
        };
        [weakSelf.channel invokeMethod:ChatOnGroupChanged
                         arguments:map];
    }];
}

- (void)groupMuteListDidUpdate:(EMGroup *)aGroup
           removedMutedMembers:(NSArray *)aMutedMembers {
    __weak typeof(self) weakSelf = self;
    [EMListenerHandle.sharedInstance addHandle:^{
        NSDictionary *map = @{
            @"type":@"onGroupMuteListRemoved",
            @"groupId":aGroup.groupId,
            @"mutes":aMutedMembers
        };
        [weakSelf.channel invokeMethod:ChatOnGroupChanged
                         arguments:map];
    }];
}

- (void)groupWhiteListDidUpdate:(EMGroup *)aGroup
          addedWhiteListMembers:(NSArray *)aMembers {

    
    __weak typeof(self) weakSelf = self;
    [EMListenerHandle.sharedInstance addHandle:^{
        NSDictionary *map = @{
            @"type":@"onGroupWhiteListAdded",
            @"groupId":aGroup.groupId,
            @"whitelist":aMembers
        };
        [weakSelf.channel invokeMethod:ChatOnGroupChanged
                         arguments:map];
    }];
}

- (void)groupWhiteListDidUpdate:(EMGroup *)aGroup
        removedWhiteListMembers:(NSArray *)aMembers {

    
    __weak typeof(self) weakSelf = self;
    [EMListenerHandle.sharedInstance addHandle:^{
        NSDictionary *map = @{
            @"type":@"onGroupWhiteListRemoved",
            @"groupId":aGroup.groupId,
            @"whitelist":aMembers
        };
        [weakSelf.channel invokeMethod:ChatOnGroupChanged
                         arguments:map];
    }];
}

- (void)groupAllMemberMuteChanged:(EMGroup *)aGroup
                 isAllMemberMuted:(BOOL)aMuted {

    
    __weak typeof(self) weakSelf = self;
    [EMListenerHandle.sharedInstance addHandle:^{
        NSDictionary *map = @{
            @"type":@"onGroupAllMemberMuteStateChanged",
            @"groupId":aGroup.groupId,
            @"isMuted":@(aMuted)
        };
        [weakSelf.channel invokeMethod:ChatOnGroupChanged
                         arguments:map];
    }];
}

- (void)groupAdminListDidUpdate:(EMGroup *)aGroup
                     addedAdmin:(NSString *)aAdmin {

    
    __weak typeof(self) weakSelf = self;
    [EMListenerHandle.sharedInstance addHandle:^{
        NSDictionary *map = @{
            @"type":@"onGroupAdminAdded",
            @"groupId":aGroup.groupId,
            @"administrator":aAdmin
        };
        [weakSelf.channel invokeMethod:ChatOnGroupChanged
                         arguments:map];
    }];
}

- (void)groupAdminListDidUpdate:(EMGroup *)aGroup
                   removedAdmin:(NSString *)aAdmin {

    
    __weak typeof(self) weakSelf = self;
    [EMListenerHandle.sharedInstance addHandle:^{
        NSDictionary *map = @{
            @"type":@"onGroupAdminRemoved",
            @"groupId":aGroup.groupId,
            @"administrator":aAdmin
        };
        [weakSelf.channel invokeMethod:ChatOnGroupChanged
                         arguments:map];
    }];
}

- (void)groupOwnerDidUpdate:(EMGroup *)aGroup
                   newOwner:(NSString *)aNewOwner
                   oldOwner:(NSString *)aOldOwner {

    
    __weak typeof(self) weakSelf = self;
    [EMListenerHandle.sharedInstance addHandle:^{
        NSDictionary *map = @{
            @"type":@"onGroupOwnerChanged",
            @"groupId":aGroup.groupId,
            @"newOwner":aNewOwner,
            @"oldOwner":aOldOwner
        };
        [weakSelf.channel invokeMethod:ChatOnGroupChanged
                         arguments:map];
    }];
}

- (void)userDidJoinGroup:(EMGroup *)aGroup
                    user:(NSString *)aUsername {

    
    __weak typeof(self) weakSelf = self;
    [EMListenerHandle.sharedInstance addHandle:^{
        NSDictionary *map = @{
            @"type":@"onGroupMemberJoined",
            @"groupId":aGroup.groupId,
            @"member":aUsername
        };
        [weakSelf.channel invokeMethod:ChatOnGroupChanged
                         arguments:map];
    }];
}

- (void)userDidLeaveGroup:(EMGroup *)aGroup
                     user:(NSString *)aUsername {

    
    __weak typeof(self) weakSelf = self;
    [EMListenerHandle.sharedInstance addHandle:^{
        NSDictionary *map = @{
            @"type":@"onGroupMemberExited",
            @"groupId":aGroup.groupId,
            @"member":aUsername
        };
        [weakSelf.channel invokeMethod:ChatOnGroupChanged
                         arguments:map];
    }];
}

- (void)groupAnnouncementDidUpdate:(EMGroup *)aGroup
                      announcement:(NSString *)aAnnouncement {

    
    __weak typeof(self) weakSelf = self;
    [EMListenerHandle.sharedInstance addHandle:^{
        NSDictionary *map = @{
            @"type":@"onGroupAnnouncementChanged",
            @"groupId":aGroup.groupId,
            @"announcement":aAnnouncement
        };
        [weakSelf.channel invokeMethod:ChatOnGroupChanged
                         arguments:map];
    }];
}

- (void)groupFileListDidUpdate:(EMGroup *)aGroup
               addedSharedFile:(EMGroupSharedFile *)aSharedFile {

    
    __weak typeof(self) weakSelf = self;
    [EMListenerHandle.sharedInstance addHandle:^{
        NSDictionary *map = @{
            @"type":@"onGroupSharedFileAdded",
            @"groupId":aGroup.groupId,
            @"sharedFile":[aSharedFile toJson]
        };
        [weakSelf.channel invokeMethod:ChatOnGroupChanged
                         arguments:map];
    }];
}

- (void)groupFileListDidUpdate:(EMGroup *)aGroup
             removedSharedFile:(NSString *)aFileId {
    __weak typeof(self) weakSelf = self;
    [EMListenerHandle.sharedInstance addHandle:^{
        NSDictionary *map = @{
            @"type":@"onGroupSharedFileDeleted",
            @"groupId":aGroup.groupId,
            @"fileId":aFileId
        };
        [weakSelf.channel invokeMethod:ChatOnGroupChanged
                         arguments:map];
    }];
}

- (void)onAttributesChangedOfGroupMember:(NSString *)groupId
                                  userId:(NSString *)userId
                              attributes:(NSDictionary<NSString *,NSString *> *)attributes
                              operatorId:(NSString *)operatorId{
    __weak typeof(self) weakSelf = self;
    [EMListenerHandle.sharedInstance addHandle:^{
        NSDictionary *map = @{
            @"type":@"onGroupAttributesChangedOfMember",
            @"groupId":groupId,
            @"userId":userId,
            @"attributes": attributes,
            @"operatorId": operatorId
        };
        [weakSelf.channel invokeMethod:ChatOnGroupChanged
                         arguments:map];
    }];
}

- (void)groupSpecificationDidUpdate:(EMGroup *)aGroup {
    __weak typeof(self) weakSelf = self;
    [EMListenerHandle.sharedInstance addHandle:^{
        NSDictionary *map = @{
            @"type":@"onGroupSpecificationDidUpdate",
            @"group": [aGroup toJson]
        };
        [weakSelf.channel invokeMethod:ChatOnGroupChanged
                         arguments:map];
    }];
}
- (void)groupStateChanged:(EMGroup *)aGroup
               isDisabled:(BOOL)aDisabled {
    __weak typeof(self) weakSelf = self;
    [EMListenerHandle.sharedInstance addHandle:^{
        NSDictionary *map = @{
            @"type":@"onGroupStateChanged",
            @"groupId":aGroup.groupId,
            @"isDisabled":@(aDisabled)
        };
        [weakSelf.channel invokeMethod:ChatOnGroupChanged
                         arguments:map];
    }];
}

@end
