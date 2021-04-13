//
//  EMChatroomManagerWrapper.m
//  im_flutter_sdk
//
//  Created by easemob-DN0164 on 2019/10/18.
//

#import "EMChatroomManagerWrapper.h"
#import "EMSDKMethod.h"

#import "EMCursorResult+Flutter.h"
#import "EMPageResult+Flutter.h"
#import "EMChatroom+Flutter.h"


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
    if ([EMMethodKeyJoinChatRoom isEqualToString:call.method])
    {
        [self joinChatroom:call.arguments result:result];
    }
    else if ([EMMethodKeyLeaveChatRoom isEqualToString:call.method]) {
        [self leaveChatroom:call.arguments result:result];
    }
    else if ([EMMethodKeyGetChatroomsFromServer isEqualToString:call.method]) {
        [self getChatroomsFromServer:call.arguments result:result];
    }
    else if ([EMMethodKeyCreateChatRoom isEqualToString:call.method]) {
        [self createChatroom:call.arguments result:result];
    }
    else if ([EMMethodKeyDestroyChatRoom isEqualToString:call.method]) {
        [self destroyChatRoom:call.arguments result:result];
    }
    else if ([EMMethodKeyFetchChatRoomFromServer isEqualToString:call.method]) {
        [self fetchChatroomInfoFromServer:call.arguments result:result];
    }
    else if ([EMMethodKeyGetChatRoom isEqualToString:call.method]) {
        [self getChatroom:call.arguments result:result];
    }
    else if ([EMMethodKeyGetAllChatRooms isEqualToString:call.method]) {
        [self getAllChatrooms:call.arguments result:result];
    }
    else if ([EMMethodKeyGetChatroomMemberListFromServer isEqualToString:call.method]) {
        [self getChatroomMemberListFromServer:call.arguments result:result];
    }
    else if ([EMMethodKeyFetchChatroomBlockListFromServer isEqualToString:call.method]) {
        [self fetchChatroomBlockListFromServer:call.arguments result:result];
    }
    else if ([EMMethodKeyGetChatroomMuteListFromServer isEqualToString:call.method]) {
        [self getChatroomMuteListFromServer:call.arguments result:result];
    }
    else if ([EMMethodKeyFetchChatroomAnnouncement isEqualToString:call.method]) {
        [self fetchChatroomAnnouncement:call.arguments result:result];
    }
    else if ([EMMethodKeyChatRoomUpdateSubject isEqualToString:call.method]) {
        [self chatRoomUpdateSubject:call.arguments result:result];
    }
    else if ([EMMethodKeyChatRoomUpdateDescription isEqualToString:call.method]) {
        [self chatRoomUpdateDescription:call.arguments result:result];
    }
    else if ([EMMethodKeyChatRoomRemoveMembers isEqualToString:call.method]) {
        [self chatRoomRemoveMembers:call.arguments result:result];
    }
    else if ([EMMethodKeyChatRoomBlockMembers isEqualToString:call.method]) {
        [self chatRoomBlockMembers:call.arguments result:result];
    }
    else if ([EMMethodKeyChatRoomUnblockMembers isEqualToString:call.method]) {
        [self chatRoomUnblockMembers:call.arguments result:result];
    }
    else if ([EMMethodKeyChangeChatRoomOwner isEqualToString:call.method]) {
        [self chatRoomChangeOwner:call.arguments result:result];
    }
    else if ([EMMethodKeyChatRoomAddAdmin isEqualToString:call.method]) {
        [self chatRoomAddAdmin:call.arguments result:result];
    }
    else if ([EMMethodKeyChatRoomRemoveAdmin isEqualToString:call.method]) {
        [self chatRoomRemoveAdmin:call.arguments result:result];
    }
    else if ([EMMethodKeyChatRoomMuteMembers isEqualToString:call.method]) {
        [self chatRoomMuteMembers:call.arguments result:result];
    }
    else if ([EMMethodKeyChatRoomUnmuteMembers isEqualToString:call.method]) {
        [self chatRoomUnmuteMembers:call.arguments result:result];
    }
    else if ([EMMethodKeyUpdateChatRoomAnnouncement isEqualToString:call.method]) {
        [self updateChatroomAnnouncement:call.arguments result:result];
    }
    else {
        [super handleMethodCall:call result:result];
    }
}

#pragma mark - Actions

- (void)getChatroomsFromServer:(NSDictionary *)param result:(FlutterResult)result {
    NSInteger page = [param[@"pageNum"] integerValue];
    NSInteger pageSize = [param[@"pageSize"] integerValue];
    
    __weak typeof(self) weakSelf = self;
    
    [EMClient.sharedClient.roomManager getChatroomsFromServerWithPage:page
                                                             pageSize:pageSize
                                                           completion:^(EMPageResult *aResult, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:EMMethodKeyGetChatroomsFromServer
                            error:aError
                           object:[aResult toJson]];
    }];
}

- (void)createChatroom:(NSDictionary *)param result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    
    NSString *subject = param[@"subject"];
    NSString *description = param[@"desc"];
    NSArray *invitees = param[@"members"];
    NSString *message = param[@"welcomeMsg"];
    NSInteger maxMembersCount = [param[@"maxUserCount"] integerValue];
    [EMClient.sharedClient.roomManager createChatroomWithSubject:subject
                                                     description:description
                                                        invitees:invitees
                                                         message:message
                                                 maxMembersCount:maxMembersCount
                                                      completion:^(EMChatroom *aChatroom, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:EMMethodKeyCreateChatRoom
                            error:aError
                           object:[aChatroom toJson]];
    }];
}

- (void)joinChatroom:(NSDictionary *)param result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager joinChatroom:chatroomId
                                         completion:^(EMChatroom *aChatroom, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:EMMethodKeyJoinChatRoom
                            error:aError
                           object:@(!!aChatroom)];
    }];
}

- (void)leaveChatroom:(NSDictionary *)param result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager leaveChatroom:chatroomId
                                          completion:^(EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:EMMethodKeyLeaveChatRoom
                            error:aError
                           object:nil];
    }];
}

- (void)destroyChatRoom:(NSDictionary *)param result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager destroyChatroom:chatroomId completion:^(EMError *aError) {
        [weakSelf wrapperCallBack:result
                      channelName:EMMethodKeyDestroyChatRoom
                            error:aError
                           object:nil];
    }];
}

- (void)fetchChatroomInfoFromServer:(NSDictionary *)param result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager getChatroomSpecificationFromServerWithId:chatroomId
                                                                     completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:EMMethodKeyFetchChatRoomFromServer
                            error:aError
                           object:[aChatroom toJson]];
        
    }];
}

- (void)getChatroom:(NSDictionary *)param result:(FlutterResult)result {
    
    __weak typeof(self)weakSelf = self;
    EMChatroom *chatroom = [EMChatroom chatroomWithId:param[@"roomId"]];
    [weakSelf wrapperCallBack:result
                  channelName:EMMethodKeyGetChatRoom
                        error:nil
                       object:[chatroom toJson]];
}

- (void)getAllChatrooms:(NSDictionary *)param result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.roomManager getChatroomsFromServerWithPage:0
                                                             pageSize:-1
                                                           completion:^(EMPageResult *aResult, EMError *aError)
     {
        NSMutableArray *list = [NSMutableArray array];
        for (EMChatroom *room in aResult.list) {
            [list addObject:[room toJson]];
        }
        
        [weakSelf wrapperCallBack:result
                      channelName:EMMethodKeyGetAllChatRooms
                            error:aError
                           object:list];
    }];
}

- (void)getChatroomMemberListFromServer:(NSDictionary *)param result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    
    NSString *chatroomId = param[@"roomId"];
    NSString *cursor = param[@"cursor"];
    NSInteger pageSize = [param[@"pageSize"] integerValue];
    [EMClient.sharedClient.roomManager getChatroomMemberListFromServerWithId:chatroomId
                                                                      cursor:cursor
                                                                    pageSize:pageSize
                                                                  completion:^(EMCursorResult *aResult, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:EMMethodKeyGetChatroomMemberListFromServer
                            error:aError
                           object:[aResult toJson]];

    }];
}

- (void)fetchChatroomBlockListFromServer:(NSDictionary *)param result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    
    NSString *chatroomId = param[@"roomId"];
    NSInteger pageNumber = [param[@"pageNum"] integerValue];;
    NSInteger pageSize = [param[@"pageSize"] integerValue];
    [EMClient.sharedClient.roomManager getChatroomBlacklistFromServerWithId:chatroomId
                                                                 pageNumber:pageNumber
                                                                   pageSize:pageSize
                                                                 completion:^(NSArray *aList, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:EMMethodKeyFetchChatroomBlockListFromServer
                            error:aError
                           object:aList];
    }];
}

- (void)getChatroomMuteListFromServer:(NSDictionary *)param result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    
    NSString *chatroomId = param[@"roomId"];
    NSInteger pageNumber = [param[@"pageNum"] integerValue];
    NSInteger pageSize = [param[@"pageSize"] integerValue];
    [EMClient.sharedClient.roomManager getChatroomMuteListFromServerWithId:chatroomId
                                                                pageNumber:pageNumber
                                                                  pageSize:pageSize
                                                                completion:^(NSArray *aList, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:EMMethodKeyGetChatroomMuteListFromServer
                            error:aError
                           object:aList];
    }];
}

- (void)fetchChatroomAnnouncement:(NSDictionary *)param result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager getChatroomAnnouncementWithId:chatroomId
                                                          completion:^(NSString *aAnnouncement, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:EMMethodKeyFetchChatroomAnnouncement
                            error:aError
                           object:aAnnouncement];
    }];
}

- (void)chatRoomUpdateSubject:(NSDictionary *)param result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSString *subject = param[@"subject"];
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager updateSubject:subject
                                         forChatroom:chatroomId
                                          completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        
        [weakSelf wrapperCallBack:result
                      channelName:EMMethodKeyChatRoomUpdateSubject
                            error:aError
                           object:nil];
    }];
}

- (void)chatRoomUpdateDescription:(NSDictionary *)param result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSString *description = param[@"description"];
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager updateDescription:description
                                             forChatroom:chatroomId
                                              completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:EMMethodKeyChatRoomUpdateDescription
                            error:aError
                           object:nil];
    }];
}

- (void)chatRoomRemoveMembers:(NSDictionary *)param result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    
    NSArray *members = param[@"members"];
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager removeMembers:members
                                        fromChatroom:chatroomId
                                          completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:EMMethodKeyChatRoomRemoveMembers
                            error:aError
                           object:nil];
    }];
}

- (void)chatRoomBlockMembers:(NSDictionary *)param result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    
    NSArray *members = param[@"members"];
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager blockMembers:members
                                       fromChatroom:chatroomId
                                         completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:EMMethodKeyChatRoomBlockMembers
                            error:aError
                           object:nil];
    }];
}

- (void)chatRoomUnblockMembers:(NSDictionary *)param result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    
    NSArray *members = param[@"members"];
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager unblockMembers:members
                                         fromChatroom:chatroomId
                                           completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:EMMethodKeyChatRoomUnblockMembers
                            error:aError
                           object:nil];
    }];
}

- (void)chatRoomChangeOwner:(NSDictionary *)param result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    
    NSString *chatroomId = param[@"roomId"];
    NSString *newOwner = param[@"newOwner"];
    [EMClient.sharedClient.roomManager updateChatroomOwner:chatroomId
                                                  newOwner:newOwner
                                                completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:EMMethodKeyChangeChatRoomOwner
                            error:aError
                           object:nil];
    }];
}

- (void)chatRoomAddAdmin:(NSDictionary *)param result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    
    NSString *admin = param[@"admin"];
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager addAdmin:admin
                                     toChatroom:chatroomId
                                     completion:^(EMChatroom *aChatroomp, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:EMMethodKeyChatRoomAddAdmin
                            error:aError
                           object:nil];
    }];
}

- (void)chatRoomRemoveAdmin:(NSDictionary *)param result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    
    NSString *admin = param[@"admin"];
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager removeAdmin:admin
                                      fromChatroom:chatroomId
                                        completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:EMMethodKeyChatRoomRemoveAdmin
                            error:aError
                           object:nil];
    }];
}

- (void)chatRoomMuteMembers:(NSDictionary *)param result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    
    NSArray *muteMembers = param[@"muteMembers"];
    NSInteger muteMilliseconds = [param[@"duration"] integerValue];
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager muteMembers:muteMembers
                                  muteMilliseconds:muteMilliseconds
                                      fromChatroom:chatroomId
                                        completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:EMMethodKeyChatRoomMuteMembers
                            error:aError
                           object:nil];
    }];
}

- (void)chatRoomUnmuteMembers:(NSDictionary *)param result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    
    NSArray *unMuteMembers = param[@"unMuteMembers"];
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager unmuteMembers:unMuteMembers
                                        fromChatroom:chatroomId
                                          completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:EMMethodKeyChatRoomUnmuteMembers
                            error:aError
                           object:nil];
    }];
}

- (void)updateChatroomAnnouncement:(NSDictionary *)param result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    
    NSString *chatroomId = param[@"roomId"];
    NSString *announcement = param[@"announcement"];
    [EMClient.sharedClient.roomManager updateChatroomAnnouncementWithId:chatroomId
                                                           announcement:announcement
                                                             completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:EMMethodKeyUpdateChatRoomAnnouncement
                            error:aError
                           object:@(!aError)];
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
    if (aReason == EMChatroomBeKickedReasonDestroyed) {
        type = @"onChatRoomDestroyed";
        map = @{
            @"type":type,
            @"roomId":aChatroom.chatroomId,
            @"roomName":aChatroom.subject
        };
    } else if (aReason == EMChatroomBeKickedReasonBeRemoved) {
        type = @"onRemovedFromChatRoom";
        map = @{
            @"type":type,
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
        @"roomId":aChatroom.chatroomId,
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
        @"roomId":aChatroom.chatroomId,
        @"mutes":aMutes
    };
    [self.channel invokeMethod:EMMethodKeyChatroomChanged
                     arguments:map];
}

- (void)chatroomAdminListDidUpdate:(EMChatroom *)aChatroom
                        addedAdmin:(NSString *)aAdmin {
    NSDictionary *map = @{
        @"type":@"onAdminAdded",
        @"roomId":aChatroom.chatroomId,
        @"admin":aAdmin
    };
    [self.channel invokeMethod:EMMethodKeyChatroomChanged
                     arguments:map];
}

- (void)chatroomAdminListDidUpdate:(EMChatroom *)aChatroom
                      removedAdmin:(NSString *)aAdmin {
    NSDictionary *map = @{
        @"type":@"onAdminRemoved",
        @"roomId":aChatroom.chatroomId,
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
        @"roomId":aChatroom.chatroomId,
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
        @"roomId":aChatroom.chatroomId,
        @"announcement":aAnnouncement
    };
    [self.channel invokeMethod:EMMethodKeyChatroomChanged
                     arguments:map];
}

#pragma mark - EMChatroom Pack Method

// 聊天室成员获取结果转字典
- (NSDictionary *)dictionaryWithCursorResult:(EMCursorResult *)cursorResult
{
    NSDictionary *resultDict = @{@"data":cursorResult.list,
                                 @"cursor":cursorResult.cursor
                                };
    return resultDict;
}

@end
