//
//  EMChatroomManagerWrapper.m
//  im_flutter_sdk
//
//  Created by easemob-DN0164 on 2019/10/18.
//

#import "EMChatroomManagerWrapper.h"
#import <Hyphenate/Hyphenate.h>
#import "EMSDKMethod.h"

typedef enum : NSUInteger {
    CHATROOM_USER_JOIN = 0,                      // 有用户加入聊天室
    CHATROOM_USER_LEAVE,                         // 有用户离开聊天室
    CHATROOM_FROM_DISMISS,                       // 被踢出聊天室
    CHATROOM_MUTE_LIST_UPDATE_ADDED,             // 有成员被加入禁言列表
    CHATROOM_MUTE_LIST_UPDATE_REMOVED,           // 有成员被移出禁言列表
    CHATROOM_ADMIN_LIST_UPDATE_ADDED,            // 有成员被加入管理员列表
    CHATROOM_ADMIN_LIST_UPDATE_REMOVED,          // 有成员被移出管理员列表
    CHATROOM_OWNER_UPDATE,                       // 聊天室创建者有更新
    CHATROOM_ANNOUNCEMENT_UPDATE,                // 聊天室公告有更新
} EMChatroomEvent;
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
    if (![call.arguments isKindOfClass:[NSDictionary class]]) {
        NSLog(@"wrong type");
        return;
    }
    if ([EMMethodKeyGetChatroomsFromServer isEqualToString:call.method]) {
        [self getChatroomsFromServer:call.arguments result:result];
    } else if ([EMMethodKeyCreateChatroom isEqualToString:call.method]) {
        [self createChatroom:call.arguments result:result];
    } else if ([EMMethodKeyJoinChatroom isEqualToString:call.method]) {
        [self joinChatroom:call.arguments result:result];
    } else if ([EMMethodKeyLeaveChatroom isEqualToString:call.method]) {
        [self leaveChatroom:call.arguments result:result];
    } else if ([EMMethodKeyGetChatroomSpecificationFromServer isEqualToString:call.method]) {
        [self getChatroomSpecificationFromServer:call.arguments result:result];
    } else if ([EMMethodKeyGetChatroomMemberListFromServer isEqualToString:call.method]) {
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
    NSInteger page = [param[@"page"] integerValue];
    NSInteger pageSize = [param[@"pageSize"] integerValue];
    [EMClient.sharedClient.roomManager getChatroomsFromServerWithPage:page
                                                             pageSize:pageSize
                                                           completion:^(EMPageResult *aResult, EMError *aError)
     {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:@{@"result":aResult}];
        
    }];
}

- (void)createChatroom:(NSDictionary *)param result:(FlutterResult)result {
    NSString *subject = param[@"subject"];
    NSString *description = param[@"description"];
    NSArray *invitees = param[@"invitees"];
    NSString *message = param[@"message"];
    NSInteger maxMembersCount = [param[@"maxMembersCount"] integerValue];
    [EMClient.sharedClient.roomManager createChatroomWithSubject:subject
                                                     description:description
                                                        invitees:invitees
                                                         message:message
                                                 maxMembersCount:maxMembersCount
                                                      completion:^(EMChatroom *aChatroom, EMError *aError)
     {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:@{@"chatroom":aChatroom}];
    }];
}

- (void)joinChatroom:(NSDictionary *)param result:(FlutterResult)result {
    NSString *chatroomId = param[@"chatroomId"];
    [EMClient.sharedClient.roomManager joinChatroom:chatroomId
                                         completion:^(EMChatroom *aChatroom, EMError *aError)
     {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:@{@"chatroom":aChatroom}];
    }];
}

- (void)leaveChatroom:(NSDictionary *)param result:(FlutterResult)result {
    NSString *chatroomId = param[@"chatroomId"];
    [EMClient.sharedClient.roomManager leaveChatroom:chatroomId
                                          completion:^(EMError *aError)
     {
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
                     userInfo:@{@"chatroom":aChatroom}];
    }];
}

- (void)getChatroomMemberListFromServer:(NSDictionary *)param result:(FlutterResult)result {
    NSString *chatroomId = param[@"chatroomId"];
    NSString *cursor = param[@"cursor"];
    NSInteger pageSize = [param[@"pageSize"] integerValue];
    [EMClient.sharedClient.roomManager getChatroomMemberListFromServerWithId:chatroomId
                                                                      cursor:cursor
                                                                    pageSize:pageSize
                                                                  completion:^(EMCursorResult *aResult, EMError *aError)
     {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:@{@"result":aResult}];
    }];
}

- (void)getChatroomBlacklistFromServer:(NSDictionary *)param result:(FlutterResult)result {
    NSString *chatroomId = param[@"chatroomId"];
    NSInteger pageNumber = [param[@"pageNumber"] integerValue];;
    NSInteger pageSize = [param[@"pageSize"] integerValue];
    [EMClient.sharedClient.roomManager getChatroomBlacklistFromServerWithId:chatroomId
                                                                 pageNumber:pageNumber
                                                                   pageSize:pageSize
                                                                 completion:^(NSArray *aList, EMError *aError)
    {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:@{@"list":aList}];
    }];
}

- (void)getChatroomMuteListFromServer:(NSDictionary *)param result:(FlutterResult)result {
    NSString *chatroomId = param[@"chatroomId"];
    NSInteger pageNumber = [param[@"pageNumber"] integerValue];
    NSInteger pageSize = [param[@"pageSize"] integerValue];
    [EMClient.sharedClient.roomManager getChatroomMuteListFromServerWithId:chatroomId
                                                                pageNumber:pageNumber
                                                                  pageSize:pageSize
                                                                completion:^(NSArray *aList, EMError *aError)
    {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:@{@"list":aList}];
    }];
}

- (void)getChatroomAnnouncement:(NSDictionary *)param result:(FlutterResult)result {
    NSString *chatroomId = param[@"chatroomId"];
    [EMClient.sharedClient.roomManager getChatroomAnnouncementWithId:chatroomId
                                                          completion:^(NSString *aAnnouncement, EMError *aError)
    {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:@{@"announcement":aAnnouncement}];
    }];
}

- (void)chatRoomUpdateSubject:(NSDictionary *)param result:(FlutterResult)result {
    NSString *subject = param[@"subject"];
    NSString *chatroomId = param[@"chatroomId"];
    [EMClient.sharedClient.roomManager updateSubject:subject
                                         forChatroom:chatroomId
                                          completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:@{@"chatroom":aChatroom}];
    }];
}

- (void)chatRoomUpdateDescription:(NSDictionary *)param result:(FlutterResult)result {
    NSString *description = param[@"description"];
    NSString *chatroomId = param[@"chatroomId"];
    [EMClient.sharedClient.roomManager updateDescription:description
                                             forChatroom:chatroomId
                                              completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:@{@"chatroom":aChatroom}];
    }];
}

- (void)chatRoomRemoveMembers:(NSDictionary *)param result:(FlutterResult)result {
    NSArray *members = param[@"members"];
    NSString *chatroomId = param[@"chatroomId"];
    [EMClient.sharedClient.roomManager removeMembers:members
                                        fromChatroom:chatroomId
                                          completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:@{@"chatroom":aChatroom}];
    }];
}

- (void)chatRoomBlockMembers:(NSDictionary *)param result:(FlutterResult)result {
    NSArray *members = param[@"members"];
    NSString *chatroomId = param[@"chatroomId"];
    [EMClient.sharedClient.roomManager blockMembers:members
                                       fromChatroom:chatroomId
                                         completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:@{@"chatroom":aChatroom}];
    }];
}

- (void)chatRoomUnblockMembers:(NSDictionary *)param result:(FlutterResult)result {
    NSArray *members = param[@"members"];
    NSString *chatroomId = param[@"chatroomId"];
    [EMClient.sharedClient.roomManager unblockMembers:members
                                         fromChatroom:chatroomId
                                           completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:@{@"chatroom":aChatroom}];
    }];
}

- (void)chatRoomUpdateChatroomOwner:(NSDictionary *)param result:(FlutterResult)result {
    NSString *chatroomId = param[@"chatroomId"];
    NSString *newOwner = param[@"newOwner"];
    [EMClient.sharedClient.roomManager updateChatroomOwner:chatroomId
                                                  newOwner:newOwner
                                                completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:@{@"chatroom":aChatroom}];
    }];
}

- (void)chatRoomAddAdmin:(NSDictionary *)param result:(FlutterResult)result {
    NSString *admin = param[@"admin"];
    NSString *chatroomId = param[@"chatroomId"];
    [EMClient.sharedClient.roomManager addAdmin:admin
                                     toChatroom:chatroomId
                                     completion:^(EMChatroom *aChatroomp, EMError *aError)
    {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:@{@"chatroom":aChatroomp}];
    }];
}

- (void)chatRoomRemoveAdmin:(NSDictionary *)param result:(FlutterResult)result {
    NSString *admin = param[@"admin"];
    NSString *chatroomId = param[@"chatroomId"];
    [EMClient.sharedClient.roomManager removeAdmin:admin
                                      fromChatroom:chatroomId
                                        completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:@{@"chatroom":aChatroom}];
    }];
}

- (void)chatRoomMuteMembers:(NSDictionary *)param result:(FlutterResult)result {
    NSArray *muteMembers = param[@"muteMembers"];
    NSInteger muteMilliseconds = [param[@"muteMilliseconds"] integerValue];
    NSString *chatroomId = param[@"chatroomId"];
    [EMClient.sharedClient.roomManager muteMembers:muteMembers
                                  muteMilliseconds:muteMilliseconds
                                      fromChatroom:chatroomId
                                        completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:@{@"chatroom":aChatroom}];
    }];
}

- (void)chatRoomUnmuteMembers:(NSDictionary *)param result:(FlutterResult)result {
    NSArray *muteMembers = param[@"muteMembers"];
    NSString *chatroomId = param[@"chatroomId"];
    [EMClient.sharedClient.roomManager unmuteMembers:muteMembers
                                        fromChatroom:chatroomId
                                          completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:@{@"chatroom":aChatroom}];
    }];
}

- (void)updateChatroomAnnouncement:(NSDictionary *)param result:(FlutterResult)result {
    NSString *chatroomId = param[@"chatroomId"];
    NSString *announcement = param[@"announcement"];
    [EMClient.sharedClient.roomManager updateChatroomAnnouncementWithId:chatroomId
                                                           announcement:announcement
                                                             completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:@{@"chatroom":aChatroom}];
    }];
}

#pragma mark - EMChatroomManagerWrapper

- (void)userDidJoinChatroom:(EMChatroom *)aChatroom
                       user:(NSString *)aUsername {
    NSDictionary *map = @{
        @"type":@(CHATROOM_USER_JOIN),
        @"chatroom":aChatroom,
        @"username":aUsername
    };
    [self.channel invokeMethod:EMMethodKeyChatroomChanged
                     arguments:map];
    
}

- (void)userDidLeaveChatroom:(EMChatroom *)aChatroom
                        user:(NSString *)aUsername {
    NSDictionary *map = @{
        @"type":@(CHATROOM_USER_LEAVE),
        @"chatroom":aChatroom,
        @"username":aUsername
    };
    [self.channel invokeMethod:EMMethodKeyChatroomChanged
                     arguments:map];
}

- (void)didDismissFromChatroom:(EMChatroom *)aChatroom
                        reason:(EMChatroomBeKickedReason)aReason {
    NSString *reason;
    if (aReason == EMChatroomBeKickedReasonBeRemoved) {
        reason = @"被管理员移出聊天室";
    } else if (aReason == EMChatroomBeKickedReasonDestroyed) {
        reason = @"聊天室被销毁";
    } else {
        reason = @"当前账号离线";
    }
    NSDictionary *map = @{
        @"type":@(CHATROOM_FROM_DISMISS),
        @"chatroom":aChatroom,
        @"reason":reason
    };
    [self.channel invokeMethod:EMMethodKeyChatroomChanged
                     arguments:map];
}

- (void)chatroomMuteListDidUpdate:(EMChatroom *)aChatroom
                addedMutedMembers:(NSArray *)aMutes
                       muteExpire:(NSInteger)aMuteExpire {
    NSDictionary *map = @{
        @"type":@(CHATROOM_MUTE_LIST_UPDATE_ADDED),
        @"mutes":aMutes,
        @"muteExpire":[NSNumber numberWithInteger:aMuteExpire]
    };
    [self.channel invokeMethod:EMMethodKeyChatroomChanged
                     arguments:map];
}

- (void)chatroomMuteListDidUpdate:(EMChatroom *)aChatroom
              removedMutedMembers:(NSArray *)aMutes {
    NSDictionary *map = @{
        @"type":@(CHATROOM_MUTE_LIST_UPDATE_REMOVED),
        @"chatroom":aChatroom,
        @"mutes":aMutes
    };
    [self.channel invokeMethod:EMMethodKeyChatroomChanged
                     arguments:map];
}

- (void)chatroomAdminListDidUpdate:(EMChatroom *)aChatroom
                        addedAdmin:(NSString *)aAdmin {
    NSDictionary *map = @{
        @"type":@(CHATROOM_ADMIN_LIST_UPDATE_ADDED),
        @"chatroom":aChatroom,
        @"admin":aAdmin
    };
    [self.channel invokeMethod:EMMethodKeyChatroomChanged
                     arguments:map];
}

- (void)chatroomAdminListDidUpdate:(EMChatroom *)aChatroom
                      removedAdmin:(NSString *)aAdmin {
    NSDictionary *map = @{
        @"type":@(CHATROOM_ADMIN_LIST_UPDATE_REMOVED),
        @"chatroom":aChatroom,
        @"admin":aAdmin
    };
    [self.channel invokeMethod:EMMethodKeyChatroomChanged
                     arguments:map];
}

- (void)chatroomOwnerDidUpdate:(EMChatroom *)aChatroom
                      newOwner:(NSString *)aNewOwner
                      oldOwner:(NSString *)aOldOwner {
    NSDictionary *map = @{
        @"type":@(CHATROOM_OWNER_UPDATE),
        @"newOwner":aNewOwner,
        @"oldOwner":aOldOwner
    };
    [self.channel invokeMethod:EMMethodKeyChatroomChanged
                     arguments:map];
}

- (void)chatroomAnnouncementDidUpdate:(EMChatroom *)aChatroom
                         announcement:(NSString *)aAnnouncement {
    NSDictionary *map = @{
        @"type":@(CHATROOM_ANNOUNCEMENT_UPDATE),
        @"chatroom":aChatroom,
        @"announcement":aAnnouncement
    };
    [self.channel invokeMethod:EMMethodKeyChatroomChanged
                     arguments:map];
}

@end
