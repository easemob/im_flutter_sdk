//
//  EMChatroomManagerWrapper.m
//  im_flutter_sdk
//
//  Created by easemob-DN0164 on 2019/10/18.
//

#import "EMChatroomManagerWrapper.h"
#import <Hyphenate/Hyphenate.h>
#import "EMSDKMethod.h"

@interface EMChatroomManagerWrapper () <EMChatroomManagerDelegate>

@end

@implementation EMChatroomManagerWrapper

- (instancetype)initWithChannelName:(NSString *)aChannelName
                          registrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    if(self = [super initWithChannelName:aChannelName
                               registrar:registrar]) {
        
        [EMClient.sharedClient.roomManager addDelegate:self delegateQueue:nil];
    }
    return self;
}

#pragma mark - FlutterPlugin

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {

    if ([EMMethodKeyGetChatroomsFromServer isEqualToString:call.method]) {
        [self getChatroomsFromServer:call.arguments result:result];
    } else if ([EMMethodKeyCreateChatRoom isEqualToString:call.method]) {
        [self createChatroom:call.arguments result:result];
    } else if ([EMMethodKeyJoinChatRoom isEqualToString:call.method]) {
        [self joinChatroom:call.arguments result:result];
    } else if ([EMMethodKeyLeaveChatRoom isEqualToString:call.method]) {
        [self leaveChatroom:call.arguments result:result];
    } else if ([EMMethodKeyDestroyChatRoom isEqualToString:call.method]) {
        [self destroyChatRoom:call.arguments result:result];
    } else if ([EMMethodKeyGetChatroomSpecificationFromServer isEqualToString:call.method]) {
        [self getChatroomSpecificationFromServer:call.arguments result:result];
    } else if ([EMMethodKeyGetChatRoom isEqualToString:call.method]) {
        [self getChatroom:call.arguments result:result];
    } else if ([EMMethodKeyGetAllChatRooms isEqualToString:call.method]) {
        [self getAllChatrooms:call.arguments result:result];
    }  else if ([EMMethodKeyGetChatroomMemberListFromServer isEqualToString:call.method]) {
        [self getChatroomMemberListFromServer:call.arguments result:result];
    } else if ([EMMethodKeyGetChatroomBlacklistFromServer isEqualToString:call.method]) {
        [self getChatroomBlacklistFromServer:call.arguments result:result];
    } else if ([EMMethodKeyGetChatroomMuteListFromServer isEqualToString:call.method]) {
        [self getChatroomMuteListFromServer:call.arguments result:result];
    } else if ([EMMethodKeyGetChatroomAnnouncement isEqualToString:call.method]) {
        [self getChatroomAnnouncement:call.arguments result:result];
    } else if ([EMMethodKeyuChatRoomUpdateSubject isEqualToString:call.method]) {
        [self chatRoomUpdateSubject:call.arguments result:result];
    } else if ([EMMethodKeyChatRoomUpdateDescription isEqualToString:call.method]) {
        [self chatRoomUpdateDescription:call.arguments result:result];
    } else if ([EMMethodKeyChatRoomRemoveMembers isEqualToString:call.method]) {
        [self chatRoomRemoveMembers:call.arguments result:result];
    } else if ([EMMethodKeyChatRoomBlockMembers isEqualToString:call.method]) {
           [self chatRoomBlockMembers:call.arguments result:result];
    } else if ([EMMethodKeyChatRoomUnblockMembers isEqualToString:call.method]) {
        [self chatRoomUnblockMembers:call.arguments result:result];
    } else if ([EMMethodKeyChatRoomUpdateChatroomOwner isEqualToString:call.method]) {
        [self chatRoomUpdateChatroomOwner:call.arguments result:result];
    } else if ([EMMethodKeyChatRoomAddAdmin isEqualToString:call.method]) {
        [self chatRoomAddAdmin:call.arguments result:result];
    } else if ([EMMethodKeyChatRoomRemoveAdmin isEqualToString:call.method]) {
        [self chatRoomRemoveAdmin:call.arguments result:result];
    } else if ([EMMethodKeyChatRoomMuteMembers isEqualToString:call.method]) {
        [self chatRoomMuteMembers:call.arguments result:result];
    } else if ([EMMethodKeyChatRoomUnmuteMembers isEqualToString:call.method]) {
        [self chatRoomUnmuteMembers:call.arguments result:result];
    } else if ([EMMethodKeyUpdateChatroomAnnouncement isEqualToString:call.method]) {
        [self updateChatroomAnnouncement:call.arguments result:result];
    } else {
        [super handleMethodCall:call result:result];
    }
}

#pragma mark - Actions

- (void)getChatroomsFromServer:(NSDictionary *)param result:(FlutterResult)result {
    NSInteger page = [param[@"pageNum"] integerValue];
    NSInteger pageSize = [param[@"pageSize"] integerValue];
    [EMClient.sharedClient.roomManager getChatroomsFromServerWithPage:page
                                                             pageSize:pageSize
                                                           completion:^(EMPageResult *aResult, EMError *aError)
     {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:[self dictionaryWithPageResult:aResult]];
        
    }];
}

- (void)createChatroom:(NSDictionary *)param result:(FlutterResult)result {
    NSString *subject = param[@"subject"];
    NSString *description = param[@"description"];
    NSArray *invitees = param[@"members"];
    NSString *message = param[@"welcomeMessage"];
    NSInteger maxMembersCount = [param[@"maxUserCount"] integerValue];
    [EMClient.sharedClient.roomManager createChatroomWithSubject:subject
                                                     description:description
                                                        invitees:invitees
                                                         message:message
                                                 maxMembersCount:maxMembersCount
                                                      completion:^(EMChatroom *aChatroom, EMError *aError)
     {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:[self dictionaryWithChatroom:aChatroom]];
    }];
}

- (void)joinChatroom:(NSDictionary *)param result:(FlutterResult)result {
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager joinChatroom:chatroomId
                                         completion:^(EMChatroom *aChatroom, EMError *aError)
     {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:[self dictionaryWithChatroom:aChatroom]];
    }];
}

- (void)leaveChatroom:(NSDictionary *)param result:(FlutterResult)result {
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager leaveChatroom:chatroomId
                                          completion:^(EMError *aError)
     {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:nil];
    }];
}

- (void)destroyChatRoom:(NSDictionary *)param result:(FlutterResult)result {
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager destroyChatroom:chatroomId completion:^(EMError *aError) {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:nil];
    }];
}


- (void)getChatroomSpecificationFromServer:(NSDictionary *)param result:(FlutterResult)result {
    NSString *chatroomId = param[@"chatroomId"];
    [EMClient.sharedClient.roomManager getChatroomSpecificationFromServerWithId:chatroomId
                                                                     completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:[self dictionaryWithChatroom:aChatroom]];
    }];
}

- (void)getChatroom:(NSDictionary *)param result:(FlutterResult)result {
    NSString *chatroomId = param[@"chatroomId"];
    EMChatroom *chatroom = [EMChatroom chatroomWithId:chatroomId];
    [self wrapperCallBack:result
                    error:nil
                 userInfo:[self dictionaryWithChatroom:chatroom]];
}

- (void)getAllChatrooms:(NSDictionary *)param result:(FlutterResult)result {
    [EMClient.sharedClient.roomManager getChatroomsFromServerWithPage:0
                                                             pageSize:-1
                                                           completion:^(EMPageResult *aResult, EMError *aError)
     {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:[self dictionaryWithPageResult:aResult]];
        
    }];
}

- (void)getChatroomMemberListFromServer:(NSDictionary *)param result:(FlutterResult)result {
    NSString *chatroomId = param[@"roomId"];
    NSString *cursor = param[@"cursor"];
    NSInteger pageSize = [param[@"pageSize"] integerValue];
    [EMClient.sharedClient.roomManager getChatroomMemberListFromServerWithId:chatroomId
                                                                      cursor:cursor
                                                                    pageSize:pageSize
                                                                  completion:^(EMCursorResult *aResult, EMError *aError)
     {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:[self dictionaryWithCursorResult:aResult]];
    }];
}

- (void)getChatroomBlacklistFromServer:(NSDictionary *)param result:(FlutterResult)result {
    NSString *chatroomId = param[@"roomId"];
    NSInteger pageNumber = [param[@"pageNum"] integerValue];;
    NSInteger pageSize = [param[@"pageSize"] integerValue];
    [EMClient.sharedClient.roomManager getChatroomBlacklistFromServerWithId:chatroomId
                                                                 pageNumber:pageNumber
                                                                   pageSize:pageSize
                                                                 completion:^(NSArray *aList, EMError *aError)
    {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:[self dictionaryArrayWithChatroomsArray:aList]];
    }];
}

- (void)getChatroomMuteListFromServer:(NSDictionary *)param result:(FlutterResult)result {
    NSString *chatroomId = param[@"roomId"];
    NSInteger pageNumber = [param[@"pageNum"] integerValue];
    NSInteger pageSize = [param[@"pageSize"] integerValue];
    [EMClient.sharedClient.roomManager getChatroomMuteListFromServerWithId:chatroomId
                                                                pageNumber:pageNumber
                                                                  pageSize:pageSize
                                                                completion:^(NSArray *aList, EMError *aError)
    {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:[self dictionaryArrayWithChatroomsArray:aList]];
    }];
}

- (void)getChatroomAnnouncement:(NSDictionary *)param result:(FlutterResult)result {
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager getChatroomAnnouncementWithId:chatroomId
                                                          completion:^(NSString *aAnnouncement, EMError *aError)
    {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:aAnnouncement];
    }];
}

- (void)chatRoomUpdateSubject:(NSDictionary *)param result:(FlutterResult)result {
    NSString *subject = param[@"newSubject"];
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager updateSubject:subject
                                         forChatroom:chatroomId
                                          completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:[self dictionaryWithChatroom:aChatroom]];
    }];
}

- (void)chatRoomUpdateDescription:(NSDictionary *)param result:(FlutterResult)result {
    NSString *description = param[@"newDescription"];
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager updateDescription:description
                                             forChatroom:chatroomId
                                              completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:[self dictionaryWithChatroom:aChatroom]];
    }];
}

- (void)chatRoomRemoveMembers:(NSDictionary *)param result:(FlutterResult)result {
    NSArray *members = param[@"members"];
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager removeMembers:members
                                        fromChatroom:chatroomId
                                          completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:[self dictionaryWithChatroom:aChatroom]];
    }];
}

- (void)chatRoomBlockMembers:(NSDictionary *)param result:(FlutterResult)result {
    NSArray *members = param[@"members"];
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager blockMembers:members
                                       fromChatroom:chatroomId
                                         completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:[self dictionaryWithChatroom:aChatroom]];
    }];
}

- (void)chatRoomUnblockMembers:(NSDictionary *)param result:(FlutterResult)result {
    NSArray *members = param[@"members"];
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager unblockMembers:members
                                         fromChatroom:chatroomId
                                           completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:[self dictionaryWithChatroom:aChatroom]];
    }];
}

- (void)chatRoomUpdateChatroomOwner:(NSDictionary *)param result:(FlutterResult)result {
    NSString *chatroomId = param[@"roomId"];
    NSString *newOwner = param[@"newOwner"];
    [EMClient.sharedClient.roomManager updateChatroomOwner:chatroomId
                                                  newOwner:newOwner
                                                completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:[self dictionaryWithChatroom:aChatroom]];
    }];
}

- (void)chatRoomAddAdmin:(NSDictionary *)param result:(FlutterResult)result {
    NSString *admin = param[@"admin"];
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager addAdmin:admin
                                     toChatroom:chatroomId
                                     completion:^(EMChatroom *aChatroomp, EMError *aError)
    {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:[self dictionaryWithChatroom:aChatroomp]];
    }];
}

- (void)chatRoomRemoveAdmin:(NSDictionary *)param result:(FlutterResult)result {
    NSString *admin = param[@"admin"];
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager removeAdmin:admin
                                      fromChatroom:chatroomId
                                        completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:[self dictionaryWithChatroom:aChatroom]];
    }];
}

- (void)chatRoomMuteMembers:(NSDictionary *)param result:(FlutterResult)result {
    NSArray *muteMembers = param[@"muteMembers"];
    NSInteger muteMilliseconds = [param[@"duration"] integerValue];
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager muteMembers:muteMembers
                                  muteMilliseconds:muteMilliseconds
                                      fromChatroom:chatroomId
                                        completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:[self dictionaryWithChatroom:aChatroom]];
    }];
}

- (void)chatRoomUnmuteMembers:(NSDictionary *)param result:(FlutterResult)result {
    NSArray *muteMembers = param[@"muteMembers"];
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager unmuteMembers:muteMembers
                                        fromChatroom:chatroomId
                                          completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:[self dictionaryWithChatroom:aChatroom]];
    }];
}

- (void)updateChatroomAnnouncement:(NSDictionary *)param result:(FlutterResult)result {
    NSString *chatroomId = param[@"roomId"];
    NSString *announcement = param[@"announcement"];
    [EMClient.sharedClient.roomManager updateChatroomAnnouncementWithId:chatroomId
                                                           announcement:announcement
                                                             completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:[self dictionaryWithChatroom:aChatroom]];
    }];
}

#pragma mark - EMChatroomManagerWrapper

- (void)userDidJoinChatroom:(EMChatroom *)aChatroom
                       user:(NSString *)aUsername {
    NSDictionary *map = @{
        @"type":@"onMemberJoined",
        @"roomId":aChatroom.chatroomId,
        @"participant":aUsername
    };
    [self.channel invokeMethod:EMMethodKeyChatroomChanged
                     arguments:map];
    
}

- (void)userDidLeaveChatroom:(EMChatroom *)aChatroom
                        user:(NSString *)aUsername {
    NSDictionary *map = @{
        @"type":@"onMemberExited",
        @"roomId":aChatroom.chatroomId,
        @"roomName":aChatroom.subject,
        @"participant":aUsername
    };
    [self.channel invokeMethod:EMMethodKeyChatroomChanged
                     arguments:map];
}

- (void)didDismissFromChatroom:(EMChatroom *)aChatroom
                        reason:(EMChatroomBeKickedReason)aReason {
    NSString *type;
    NSDictionary *map;
    if (aReason == EMChatroomBeKickedReasonBeRemoved) {
        type = @"onChatRoomDestroyed";
        map = @{
            @"type":type,
            @"roomId":aChatroom.chatroomId,
            @"roomName":aChatroom.subject
        };
    } else if (aReason == EMChatroomBeKickedReasonDestroyed) {
        type = @"onRemovedFromChatRoom";
        map = @{
            @"type":type,
            @"reason":[NSNumber numberWithInt:0],
            @"roomId":aChatroom.chatroomId,
            @"roomName":aChatroom.subject,
            @"participant":[[EMClient sharedClient] currentUsername]
        };
    }
    
    [self.channel invokeMethod:EMMethodKeyChatroomChanged
                     arguments:map];
}

- (void)chatroomMuteListDidUpdate:(EMChatroom *)aChatroom
                addedMutedMembers:(NSArray *)aMutes
                       muteExpire:(NSInteger)aMuteExpire {
    NSDictionary *map = @{
        @"type":@"onMuteListAdded",
        @"chatRoomId":aChatroom.chatroomId,
        @"mutes":aMutes,
        @"expireTime":[NSString stringWithFormat:@"%ld", aMuteExpire]
    };
    [self.channel invokeMethod:EMMethodKeyChatroomChanged
                     arguments:map];
}

- (void)chatroomMuteListDidUpdate:(EMChatroom *)aChatroom
              removedMutedMembers:(NSArray *)aMutes {
    NSDictionary *map = @{
        @"type":@"onMuteListRemoved",
        @"chatRoomId":aChatroom.chatroomId,
        @"mutes":aMutes
    };
    [self.channel invokeMethod:EMMethodKeyChatroomChanged
                     arguments:map];
}

- (void)chatroomAdminListDidUpdate:(EMChatroom *)aChatroom
                        addedAdmin:(NSString *)aAdmin {
    NSDictionary *map = @{
        @"type":@"onAdminAdded",
        @"chatRoomId":aChatroom.chatroomId,
        @"admin":aAdmin
    };
    [self.channel invokeMethod:EMMethodKeyChatroomChanged
                     arguments:map];
}

- (void)chatroomAdminListDidUpdate:(EMChatroom *)aChatroom
                      removedAdmin:(NSString *)aAdmin {
    NSDictionary *map = @{
        @"type":@"onAdminRemoved",
        @"chatRoomId":aChatroom.chatroomId,
        @"admin":aAdmin
    };
    [self.channel invokeMethod:EMMethodKeyChatroomChanged
                     arguments:map];
}

- (void)chatroomOwnerDidUpdate:(EMChatroom *)aChatroom
                      newOwner:(NSString *)aNewOwner
                      oldOwner:(NSString *)aOldOwner {
    NSDictionary *map = @{
        @"type":@"onOwnerChanged",
        @"chatRoomId":aChatroom.chatroomId,
        @"newOwner":aNewOwner,
        @"oldOwner":aOldOwner
    };
    [self.channel invokeMethod:EMMethodKeyChatroomChanged
                     arguments:map];
}

- (void)chatroomAnnouncementDidUpdate:(EMChatroom *)aChatroom
                         announcement:(NSString *)aAnnouncement {
    NSDictionary *map = @{
        @"type":@"onAnnouncementChanged",
        @"chatRoomId":aChatroom.chatroomId,
        @"announcement":aAnnouncement
    };
    [self.channel invokeMethod:EMMethodKeyChatroomChanged
                     arguments:map];
}

#pragma mark - EMChatroom Pack Method

// 聊天室对象转字典
- (NSDictionary *)dictionaryWithChatroom:(EMChatroom *)chatroom
{
    EMChatroomPermissionType permissionType = chatroom.permissionType;
    int type;
    if (permissionType == EMChatroomPermissionTypeNone) {
        type = -1;
    } else if (permissionType == EMChatroomPermissionTypeMember) {
        type = 0;
    } else if (permissionType == EMChatroomPermissionTypeAdmin) {
        type = 1;
    } else {
        type = 2;
    }
    
    // @"permissionType":[NSNumber numberWithInt:type],
    NSDictionary *groupDict = @{@"roomId":chatroom.chatroomId,
                                @"roomName":chatroom.subject,
                                @"description":chatroom.description,
                                @"owner":chatroom.owner,
                                @"announcement":chatroom.announcement,
                                @"administratorList":chatroom.adminList,
                                @"memberList":chatroom.memberList,
                                @"blockList":chatroom.blacklist,
                                @"muteList":chatroom.muteList,
                                @"maxUserCount":[NSNumber numberWithInteger:chatroom.maxOccupantsCount],
                                @"affiliationsCount":[NSNumber numberWithInteger:chatroom.occupantsCount]
                               };
    
    return groupDict;
}

// 聊天室对象数组转字典数组
- (NSArray *)dictionaryArrayWithChatroomsArray:(NSArray *)chatroomsArray
{
    NSMutableArray *chatroomsMutableArray = [NSMutableArray array];
    for (EMChatroom *chatroom in chatroomsMutableArray) {
        [chatroomsMutableArray addObject:[self dictionaryWithChatroom:chatroom]];
    }
    return [NSArray arrayWithArray:chatroomsMutableArray];
}

// 聊天室查询结果转字典
- (NSDictionary *)dictionaryWithPageResult:(EMPageResult *)pageResult
{
    NSDictionary *resultDict = @{@"data":[self dictionaryArrayWithChatroomsArray:pageResult.list],
                                 @"pageCount":[NSNumber numberWithInteger:pageResult.count]
                                };
    return resultDict;
}

// 聊天室成员获取结果转字典
- (NSDictionary *)dictionaryWithCursorResult:(EMCursorResult *)cursorResult
{
    
    NSDictionary *resultDict = @{@"data":cursorResult.list,
                                 @"cursor":cursorResult.cursor
                                };
    return resultDict;
}

@end
