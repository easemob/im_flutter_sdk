//
//  EMChatroomManagerWrapper.m
//  im_flutter_sdk
//
//  Created by easemob-DN0164 on 2019/10/18.
//

#import "ChatroomManagerWrapper.h"
#import "MethodKeys.h"

#import "CursorResultHelper.h"
#import "PageResultHelper.h"
#import "ChatroomHelper.h"
#import "ListenerHandle.h"

@interface ChatroomManagerWrapper () <EMChatroomManagerDelegate>

@end

@implementation ChatroomManagerWrapper

- (instancetype)initWithChannelName:(NSString *)aChannelName
                          registrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    if(self = [super initWithChannelName:aChannelName
                               registrar:registrar]) {
        
        [EMClient.sharedClient.roomManager addDelegate:self delegateQueue:nil];
    }
    return self;
}

- (void)unRegisterEaseListener {
    [EMClient.sharedClient.roomManager removeDelegate:self];
}

#pragma mark - FlutterPlugin

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([ChatJoinChatRoom isEqualToString:call.method])
    {
        [self joinChatroom:call.arguments
               channelName:call.method
                    result:result];
    }
    else if ([ChatLeaveChatRoom isEqualToString:call.method]) {
        [self leaveChatroom:call.arguments
                channelName:call.method
                     result:result];
    }
    else if ([ChatGetChatroomsFromServer isEqualToString:call.method]) {
        [self getChatroomsFromServer:call.arguments
                         channelName:call.method
                              result:result];
    }
    else if ([ChatCreateChatRoom isEqualToString:call.method]) {
        [self createChatroom:call.arguments
                 channelName:call.method
                      result:result];
    }
    else if ([ChatDestroyChatRoom isEqualToString:call.method]) {
        [self destroyChatRoom:call.arguments
                  channelName:call.method
                       result:result];
    }
    else if ([ChatFetchChatRoomFromServer isEqualToString:call.method]) {
        [self fetchChatroomInfoFromServer:call.arguments
                              channelName:call.method
                                   result:result];
    }
    else if ([ChatGetChatRoom isEqualToString:call.method]) {
        [self getChatroom:call.arguments
              channelName:call.method
                   result:result];
    }
    else if ([ChatGetAllChatRooms isEqualToString:call.method]) {
        [self getAllChatrooms:call.arguments
                  channelName:call.method
                       result:result];
    }
    else if ([ChatGetChatroomMemberListFromServer isEqualToString:call.method]) {
        [self getChatroomMemberListFromServer:call.arguments
                                  channelName:call.method
                                       result:result];
    }
    else if ([ChatFetchChatroomBlockListFromServer isEqualToString:call.method]) {
        [self fetchChatroomBlockListFromServer:call.arguments
                                   channelName:call.method
                                        result:result];
    }
    else if ([ChatGetChatroomMuteListFromServer isEqualToString:call.method]) {
        [self getChatroomMuteListFromServer:call.arguments
                                channelName:call.method
                                     result:result];
    }
    else if ([ChatFetchChatroomAnnouncement isEqualToString:call.method]) {
        [self fetchChatroomAnnouncement:call.arguments
                            channelName:call.method
                                 result:result];
    }
    else if ([ChatChatRoomUpdateSubject isEqualToString:call.method]) {
        [self chatRoomUpdateSubject:call.arguments
                        channelName:call.method
                             result:result];
    }
    else if ([ChatChatRoomUpdateDescription isEqualToString:call.method]) {
        [self chatRoomUpdateDescription:call.arguments
                            channelName:call.method
                                 result:result];
    }
    else if ([ChatChatRoomRemoveMembers isEqualToString:call.method]) {
        [self chatRoomRemoveMembers:call.arguments
                        channelName:call.method
                             result:result];
    }
    else if ([ChatChatRoomBlockMembers isEqualToString:call.method]) {
        [self chatRoomBlockMembers:call.arguments
                       channelName:call.method
                            result:result];
    }
    else if ([ChatChatRoomUnblockMembers isEqualToString:call.method]) {
        [self chatRoomUnblockMembers:call.arguments
                         channelName:call.method
                              result:result];
    }
    else if ([ChatChangeChatRoomOwner isEqualToString:call.method]) {
        [self chatRoomChangeOwner:call.arguments
                      channelName:call.method
                           result:result];
    }
    else if ([ChatChatRoomAddAdmin isEqualToString:call.method]) {
        [self chatRoomAddAdmin:call.arguments
                   channelName:call.method
                        result:result];
    }
    else if ([ChatChatRoomRemoveAdmin isEqualToString:call.method]) {
        [self chatRoomRemoveAdmin:call.arguments
                      channelName:call.method
                           result:result];
    }
    else if ([ChatChatRoomMuteMembers isEqualToString:call.method]) {
        [self chatRoomMuteMembers:call.arguments
                      channelName:call.method
                           result:result];
    }
    else if ([ChatChatRoomUnmuteMembers isEqualToString:call.method]) {
        [self chatRoomUnmuteMembers:call.arguments
                        channelName:call.method
                             result:result];
    }
    else if ([ChatUpdateChatRoomAnnouncement isEqualToString:call.method]) {
        [self updateChatroomAnnouncement:call.arguments
                             channelName:call.method
                                  result:result];
    }
    else if ([ChatAddMembersToChatRoomWhiteList isEqualToString:call.method]) {
        [self addMembersToChatRoomWhiteList:call.arguments
                                channelName:call.method
                                     result:result];
    }
    else if ([ChatRemoveMembersFromChatRoomWhiteList isEqualToString:call.method]) {
        [self removeMembersFromChatRoomWhiteList:call.arguments
                                     channelName:call.method
                                          result:result];
    }
    else if ([ChatFetchChatRoomWhiteListFromServer isEqualToString:call.method]) {
        [self fetchChatRoomWhiteListFromServer:call.arguments
                                   channelName:call.method
                                        result:result];
    }
    else if ([ChatIsMemberInChatRoomWhiteListFromServer isEqualToString:call.method]) {
        [self isMemberInChatRoomWhiteListFromServer:call.arguments
                                        channelName:call.method
                                             result:result];
    }
    else if ([ChatMuteAllChatRoomMembers isEqualToString:call.method]) {
        [self muteAllChatRoomMembers:call.arguments
                         channelName:call.method
                              result:result];
    }
    else if ([ChatUnMuteAllChatRoomMembers isEqualToString:call.method]) {
        [self unMuteAllChatRoomMembers:call.arguments
                           channelName:call.method
                                result:result];
    }
    else if ([ChatFetchChatRoomAttributes isEqualToString:call.method]) {
        [self fetchChatRoomAttributes:call.arguments channelName:call.method result:result];
    }
    else if ([ChatSetChatRoomAttributes isEqualToString:call.method]) {
        [self setChatRoomAttributes:call.arguments channelName:call.method result:result];
    }
    else if ([ChatRemoveChatRoomAttributes isEqual: call.method]) {
        [self removeChatRoomAttributes:call.arguments channelName:call.method result:result];
    }
    else if ([isMemberInChatRoomMuteList isEqual: call.method]) {
        [self isMemberInChatRoomMuteList:call.arguments channelName:call.method result:result];
    }
    else if ([ChatFetchChatRoomAllAttributesFromServer isEqualToString:call.method]) {
        [self fetchChatRoomAllAttributesFromServer:call.arguments channelName:call.method result:result];
    } else if ([ChatSetChatroomAttribute isEqualToString:call.method]) {
        [self setChatroomAttribute:call.arguments channelName:call.method result:result];
    } else if ([ChatSetChatroomAttributeForced isEqualToString:call.method]) {
        [self setChatroomAttributeForced:call.arguments channelName:call.method result:result];
    } else if ([ChatRemoveChatRoomAttributeFromServer isEqualToString:call.method]) {
        [self removeChatRoomAttributeFromServer:call.arguments channelName:call.method result:result];
    } else if ([ChatRemoveChatRoomAttributeFromServerForced isEqualToString:call.method]) {
        [self removeChatRoomAttributeFromServerForced:call.arguments channelName:call.method result:result];
    }
    else if ([ChatJoinChatRoom isEqualToString:call.method]) {
        [self joinChatRoom:call.arguments channelName:call.method result:result];
    } else if ([ChatLeaveChatRoom isEqualToString:call.method]) {
        [self leaveChatRoom:call.arguments channelName:call.method result:result];
    } else if ([ChatUpdateChatRoomAnnouncement isEqualToString:call.method]) {
        [self updateChatRoomAnnouncement:call.arguments channelName:call.method result:result];
    }
    else {
        [super handleMethodCall:call result:result];
    }
}

#pragma mark - Actions

- (void)getChatroomsFromServer:(NSDictionary *)param
                   channelName:(NSString *)aChannelName
                        result:(FlutterResult)result {
    NSInteger page = [param[@"pageNum"] integerValue];
    NSInteger pageSize = [param[@"pageSize"] integerValue];
    
    __weak typeof(self) weakSelf = self;
    
    [EMClient.sharedClient.roomManager getChatroomsFromServerWithPage:page
                                                             pageSize:pageSize
                                                           completion:^(EMPageResult *aResult, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[aResult toJson]];
    }];
}

- (void)createChatroom:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    // 5.0 移除聊天室创建/销毁 API
    // 注意：必须用 EMError（wrapperCallBack 调 [error toJson]，NSError 无该方法会崩溃）
    EMError *err = [EMError errorWithDescription:@"not supported in iOS 5.0" code:110];
    [self wrapperCallBack:result channelName:aChannelName error:err object:nil];
}

- (void)joinChatroom:(NSDictionary *)param
         channelName:(NSString *)aChannelName
              result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    NSString *chatroomId = param[@"roomId"];
    NSString *ext = param[@"ext"];
    BOOL leaveOtherRooms = [param[@"leaveOtherRooms"] boolValue];
    [EMClient.sharedClient.roomManager joinChatroom:chatroomId
     ext:ext leaveOtherRooms:leaveOtherRooms completion:^(EMChatroom *aChatroom, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:(aChatroom ? [aChatroom toJson] : nil)];
    }];
}

- (void)leaveChatroom:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager leaveChatroom:chatroomId
                                          completion:^(EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:nil];
    }];
}

- (void)destroyChatRoom:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    // 5.0 移除聊天室创建/销毁 API
    // 注意：必须用 EMError（wrapperCallBack 调 [error toJson]，NSError 无该方法会崩溃）
    EMError *err = [EMError errorWithDescription:@"not supported in iOS 5.0" code:110];
    [self wrapperCallBack:result channelName:aChannelName error:err object:nil];
}

- (void)fetchChatroomInfoFromServer:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSString *chatroomId = param[@"roomId"];
    id v = param[@"fetchMembers"];
    BOOL fetchMembers = [v isKindOfClass:[NSNumber class]] ? [v boolValue] : NO;
    
    [EMClient.sharedClient.roomManager getChatroomSpecificationFromServerWithId:chatroomId fetchMembers:fetchMembers completion:^(EMChatroom *aChatroom, EMError *aError) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[aChatroom toJson]];
    }];
}

- (void)getChatroom:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    
    __weak typeof(self)weakSelf = self;
    EMChatroom *chatroom = [EMChatroom chatroomWithId:param[@"roomId"]];
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:[chatroom toJson]];
}

- (void)getAllChatrooms:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    
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
                      channelName:aChannelName
                            error:aError
                           object:list];
    }];
}

- (void)getChatroomMemberListFromServer:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    
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
                      channelName:aChannelName
                            error:aError
                           object:[aResult toJson]];

    }];
}

- (void)fetchChatroomBlockListFromServer:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    
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
                      channelName:aChannelName
                            error:aError
                           object:aList];
    }];
}

- (void)getChatroomMuteListFromServer:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    
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
                      channelName:aChannelName
                            error:aError
                           object:aList];
    }];
}

- (void)fetchChatroomAnnouncement:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager getChatroomAnnouncementWithId:chatroomId
                                                          completion:^(NSString *aAnnouncement, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:aAnnouncement];
    }];
}

- (void)chatRoomUpdateSubject:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSString *subject = param[@"subject"];
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager updateSubject:subject
                                         forChatroom:chatroomId
                                          completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:(aChatroom ? [aChatroom toJson] : nil)];
    }];
}

- (void)chatRoomUpdateDescription:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSString *description = param[@"description"];
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager updateDescription:description
                                             forChatroom:chatroomId
                                              completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:(aChatroom ? [aChatroom toJson] : nil)];
    }];
}

- (void)chatRoomRemoveMembers:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    
    NSArray *members = param[@"members"];
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager removeMembers:members
                                        fromChatroom:chatroomId
                                          completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:(aChatroom ? [aChatroom toJson] : nil)];
    }];
}

- (void)chatRoomBlockMembers:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    
    NSArray *members = param[@"members"];
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager blockMembers:members
                                       fromChatroom:chatroomId
                                         completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:(aChatroom ? [aChatroom toJson] : nil)];
    }];
}

- (void)chatRoomUnblockMembers:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    
    NSArray *members = param[@"members"];
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager unblockMembers:members
                                         fromChatroom:chatroomId
                                           completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:(aChatroom ? [aChatroom toJson] : nil)];
    }];
}

- (void)chatRoomChangeOwner:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    
    NSString *chatroomId = param[@"roomId"];
    NSString *newOwner = param[@"newOwner"];
    [EMClient.sharedClient.roomManager updateChatroomOwner:chatroomId
                                                  newOwner:newOwner
                                                completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:(aChatroom ? [aChatroom toJson] : nil)];
    }];
}

- (void)chatRoomAddAdmin:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    
    NSString *admin = param[@"admin"];
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager addAdmin:admin
                                     toChatroom:chatroomId
                                     completion:^(EMChatroom *aChatroomp, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:(aChatroomp ? [aChatroomp toJson] : nil)];
    }];
}

- (void)chatRoomRemoveAdmin:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    
    NSString *admin = param[@"admin"];
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager removeAdmin:admin
                                      fromChatroom:chatroomId
                                        completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:(aChatroom ? [aChatroom toJson] : nil)];
    }];
}

- (void)chatRoomMuteMembers:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    
    NSArray *muteMembers = param[@"muteMembers"];
    long muteMilliseconds = [param[@"duration"] longValue];
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager muteMembers:muteMembers
                                  muteMilliseconds:muteMilliseconds
                                      fromChatroom:chatroomId
                                        completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:(aChatroom ? [aChatroom toJson] : nil)];
    }];
}

- (void)chatRoomUnmuteMembers:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    
    NSArray *unMuteMembers = param[@"unMuteMembers"];
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager unmuteMembers:unMuteMembers
                                        fromChatroom:chatroomId
                                          completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:(aChatroom ? [aChatroom toJson] : nil)];
    }];
}

- (void)updateChatroomAnnouncement:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    
    NSString *chatroomId = param[@"roomId"];
    NSString *announcement = param[@"announcement"];
    [EMClient.sharedClient.roomManager updateChatroomAnnouncementWithId:chatroomId
                                                           announcement:announcement
                                                             completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:(aError == nil ? @YES : @NO)];
    }];
}


- (void)addMembersToChatRoomWhiteList:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    NSString *roomId = param[@"roomId"];
    NSArray *ary = param[@"members"];
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.roomManager addWhiteListMembers:ary
                                               fromChatroom:roomId
                                                 completion:^(EMChatroom *aChatroom, EMError *aError)
      {
        // 对齐 Android（updateObject(null)）：白名单操作成功返回 null（非 room）
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:nil];
    }] ;
}

- (void)removeMembersFromChatRoomWhiteList:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    NSString *roomId = param[@"roomId"];
    NSArray *ary = param[@"members"];
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.roomManager removeWhiteListMembers:ary fromChatroom:roomId completion:^(EMChatroom *aChatroom, EMError *aError) {
        // 对齐 Android（updateObject(null)）：白名单操作成功返回 null（非 room）
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:nil];
    }];
}

- (void)isMemberInChatRoomWhiteListFromServer:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    NSString *roomId = param[@"roomId"];
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.roomManager isMemberInWhiteListFromServerWithChatroomId:roomId
                                                                        completion:^(BOOL inWhiteList, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:@(inWhiteList)];
    }];
}

- (void)fetchChatRoomWhiteListFromServer:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    NSString *roomId = param[@"roomId"];
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.roomManager getChatroomWhiteListFromServerWithId:roomId
                                                                 completion:^(NSArray *aList, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:aList];
    }];
}

- (void)muteAllChatRoomMembers:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    NSString *roomId = param[@"roomId"];
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.roomManager muteAllMembersFromChatroom:roomId
                                                       completion:^(EMChatroom *aChatroom, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:(aChatroom ? [aChatroom toJson] : nil)];
    }];
}

- (void)unMuteAllChatRoomMembers:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    NSString *roomId = param[@"roomId"];
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.roomManager unmuteAllMembersFromChatroom:roomId
                                                       completion:^(EMChatroom *aChatroom, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:(aChatroom ? [aChatroom toJson] : nil)];
    }];
}

- (void)fetchChatRoomAttributes:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    NSString *roomId = param[@"roomId"];
    NSArray *keys = param[@"keys"];
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.roomManager fetchChatroomAttributes:roomId
                                                          keys:keys
                                                    completion:^(EMError * _Nullable aError, NSDictionary<NSString *,NSString *> * _Nullable properties) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:properties];
    }];
}


- (void)setChatRoomAttributes:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    NSString *roomId = param[@"roomId"];
    NSDictionary *attributes = param[@"attributes"];
    BOOL autoDelete = [param[@"autoDelete"] boolValue];
    BOOL forced = [param[@"forced"] boolValue];
    __weak typeof(self) weakSelf = self;
    
    void (^block)(EMError *, NSDictionary <NSString *, EMError *>*) = ^(EMError *error, NSDictionary <NSString *, EMError *> *failureKeys) {
        NSMutableDictionary *tmp = [NSMutableDictionary dictionary];
        for (NSString *key in failureKeys) {
            tmp[key] = @(failureKeys[key].code);
        }
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:tmp.count == 0 ? error : nil 
                           object:tmp];
    };
    
    if (forced) {
        [EMClient.sharedClient.roomManager setChatroomAttributesForced:roomId attributes:attributes autoDelete:autoDelete completionBlock:^(EMError * _Nullable aError, NSDictionary<NSString *,EMError *> * _Nullable failureKeys) {
            block(aError, failureKeys);
        }];
    }else {
        [EMClient.sharedClient.roomManager setChatroomAttributes:roomId attributes:attributes autoDelete:autoDelete completionBlock:^(EMError * _Nullable aError, NSDictionary<NSString *,EMError *> * _Nullable failureKeys) {
            block(aError, failureKeys);
        }];
    }
}

- (void)removeChatRoomAttributes:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    NSString *roomId = param[@"roomId"];
    NSArray *keys = param[@"keys"];
    BOOL forced = [param[@"forced"] boolValue];
    __weak typeof(self) weakSelf = self;
    
    
    void (^block)(EMError *, NSDictionary<NSString *, EMError*> *) = ^(EMError *error, NSDictionary <NSString * ,EMError *> *failureKeys) {
        NSMutableDictionary *tmp = [NSMutableDictionary dictionary];
        for (NSString *key in failureKeys.allKeys) {
            tmp[key] = @(failureKeys[key].code);
        }
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:tmp.count == 0 ? error : nil
                           object:tmp];
    };
    
    if (forced) {
        [EMClient.sharedClient.roomManager removeChatroomAttributesForced:roomId
                                                               attributes:keys
                                                          completionBlock:^(EMError * _Nullable aError, NSDictionary<NSString *,EMError *> * _Nullable failureKeys) {
            block(aError, failureKeys);
        }];
    } else {
        [EMClient.sharedClient.roomManager removeChatroomAttributes:roomId
                                                         attributes:keys
                                                    completionBlock:^(EMError * _Nullable aError, NSDictionary<NSString *,EMError *> * _Nullable failureKeys) {
            block(aError, failureKeys);
        }];
    }
}


#pragma mark - EMChatroomManagerWrapper

- (void)userDidJoinChatroom:(EMChatroom *)aChatroom
                       user:(NSString *)aUsername
                        ext:(NSString * _Nullable)ext {

    __weak typeof(self) weakSelf = self;
    [ListenerHandle.sharedInstance addHandle:^{
        NSDictionary *map = @{
            @"type":@"onRoomMemberJoined",
            @"roomId":aChatroom.chatroomId,
            @"participant":aUsername,
            @"ext": ext
        };
        [weakSelf.channel invokeMethod:ChatChatroomChanged arguments:map];
    }];
}

- (void)userDidLeaveChatroom:(EMChatroom *)aChatroom
                        user:(NSString *)aUsername {
    
    __weak typeof(self) weakSelf = self;
    [ListenerHandle.sharedInstance addHandle:^{
        NSDictionary *map = @{
            @"type":@"onRoomMemberExited",
            @"roomId":aChatroom.chatroomId,
            @"roomName":aChatroom.subject,
            @"participant":aUsername
        };
        [weakSelf.channel invokeMethod:ChatChatroomChanged arguments:map];
    }];
}

- (void)didDismissFromChatroom:(EMChatroom *)aChatroom
                        reason:(EMChatroomBeKickedReason)aReason {

    __weak typeof(self) weakSelf = self;
    [ListenerHandle.sharedInstance addHandle:^{
        NSString *type;
        NSDictionary *map;
        if (aReason == EMChatroomBeKickedReasonDestroyed) {
            type = @"onRoomDestroyed";
            map = @{
                @"type":type,
                @"roomId":aChatroom.chatroomId,
                @"roomName":aChatroom.subject,
            };
        } else {
            type = @"onRoomRemoved";
            map = @{
                @"type":type,
                @"roomId":aChatroom.chatroomId,
                @"roomName":aChatroom.subject,
                @"participant":[[EMClient sharedClient] currentUsername],
                @"reason": @(aReason)
            };
        }

        [weakSelf.channel invokeMethod:ChatChatroomChanged arguments:map];
    }];
}

- (void)chatroomMuteListDidUpdate:(EMChatroom *)aChatroom
                addedMutedMembers:(NSDictionary<NSString *,NSNumber*> *)aMutes{
    __weak typeof(self) weakSelf = self;
    [ListenerHandle.sharedInstance addHandle:^{
        NSDictionary *map = @{
            @"type":@"onRoomMuteListAdded",
            @"roomId":aChatroom.chatroomId,
            @"mutes":aMutes,
        };
        [weakSelf.channel invokeMethod:ChatChatroomChanged arguments:map];
    }];
}
    

//- (void)chatroomMuteListDidUpdate:(EMChatroom *)aChatroom
//                addedMutedMembers:(NSArray *)aMutes
//                       muteExpire:(NSInteger)aMuteExpire {
//    
//    __weak typeof(self) weakSelf = self;
//    [EMListenerHandle.sharedInstance addHandle:^{
//        NSDictionary *map = @{
//            @"type":@"onRoomMuteListAdded",
//            @"roomId":aChatroom.chatroomId,
//            @"mutes":aMutes,
//            @"expireTime":[NSString stringWithFormat:@"%ld", (long)aMuteExpire]
//        };
//        [weakSelf.channel invokeMethod:ChatChatroomChanged arguments:map];
//    }];
//}

- (void)chatroomMuteListDidUpdate:(EMChatroom *)aChatroom
              removedMutedMembers:(NSArray *)aMutes {
    
    __weak typeof(self) weakSelf = self;
    [ListenerHandle.sharedInstance addHandle:^{
        NSDictionary *map = @{
            @"type":@"onRoomMuteListRemoved",
            @"roomId":aChatroom.chatroomId,
            @"mutes":aMutes
        };
        [weakSelf.channel invokeMethod:ChatChatroomChanged arguments:map];
    }];
}

- (void)chatroomAdminListDidUpdate:(EMChatroom *)aChatroom
                        addedAdmin:(NSString *)aAdmin {
    
    __weak typeof(self) weakSelf = self;
    [ListenerHandle.sharedInstance addHandle:^{
        NSDictionary *map = @{
            @"type":@"onRoomAdminAdded",
            @"roomId":aChatroom.chatroomId,
            @"admin":aAdmin
        };
        [weakSelf.channel invokeMethod:ChatChatroomChanged arguments:map];
    }];
}

- (void)chatroomAdminListDidUpdate:(EMChatroom *)aChatroom
                      removedAdmin:(NSString *)aAdmin {
    
    __weak typeof(self) weakSelf = self;
    [ListenerHandle.sharedInstance addHandle:^{
        NSDictionary *map = @{
            @"type":@"onRoomAdminRemoved",
            @"roomId":aChatroom.chatroomId,
            @"admin":aAdmin
        };
        [weakSelf.channel invokeMethod:ChatChatroomChanged arguments:map];
    }];
}

- (void)chatroomOwnerDidUpdate:(EMChatroom *)aChatroom
                      newOwner:(NSString *)aNewOwner
                      oldOwner:(NSString *)aOldOwner {
    
    __weak typeof(self) weakSelf = self;
    [ListenerHandle.sharedInstance addHandle:^{
        NSDictionary *map = @{
            @"type":@"onRoomOwnerChanged",
            @"roomId":aChatroom.chatroomId,
            @"newOwner":aNewOwner,
            @"oldOwner":aOldOwner
        };
        [weakSelf.channel invokeMethod:ChatChatroomChanged arguments:map];
    }];
}

- (void)chatroomAnnouncementDidUpdate:(EMChatroom *)aChatroom
                         announcement:(NSString *)aAnnouncement {
    __weak typeof(self) weakSelf = self;
    [ListenerHandle.sharedInstance addHandle:^{
        NSMutableDictionary *map = @{
            @"type":@"onRoomAnnouncementChanged",
            @"roomId":aChatroom.chatroomId,
        }.mutableCopy;
        if(aAnnouncement != nil) {
            map[@"announcement"] = aAnnouncement;
        }else {
            map[@"announcement"] = @"";
        }
        [weakSelf.channel invokeMethod:ChatChatroomChanged arguments:map];
    }];
}

- (void)chatroomWhiteListDidUpdate:(EMChatroom *)aChatroom
             addedWhiteListMembers:(NSArray *)aMembers {
    
    __weak typeof(self) weakSelf = self;
    [ListenerHandle.sharedInstance addHandle:^{
        NSDictionary *map = @{
            @"type":@"onRoomWhiteListAdded",
            @"roomId":aChatroom.chatroomId,
            @"whitelist":aMembers
        };
        [weakSelf.channel invokeMethod:ChatChatroomChanged arguments:map];
    }];
}


- (void)chatroomWhiteListDidUpdate:(EMChatroom *)aChatroom
           removedWhiteListMembers:(NSArray *)aMembers {
    
    __weak typeof(self) weakSelf = self;
    [ListenerHandle.sharedInstance addHandle:^{
        NSDictionary *map = @{
            @"type":@"onRoomWhiteListRemoved",
            @"roomId":aChatroom.chatroomId,
            @"whitelist":aMembers
        };
        [weakSelf.channel invokeMethod:ChatChatroomChanged arguments:map];
    }];
}


- (void)chatroomAllMemberMuteChanged:(EMChatroom *)aChatroom
                    isAllMemberMuted:(BOOL)aMuted {
    
    __weak typeof(self) weakSelf = self;
    [ListenerHandle.sharedInstance addHandle:^{
        NSDictionary *map = @{
            @"type":@"onRoomAllMemberMuteStateChanged",
            @"roomId":aChatroom.chatroomId,
            @"isMuted":@(aMuted)
        };
        [weakSelf.channel invokeMethod:ChatChatroomChanged arguments:map];
    }];
}

- (void)chatroomSpecificationDidUpdate:(EMChatroom *)aChatroom {
    __weak typeof(self) weakSelf = self;
    [ListenerHandle.sharedInstance addHandle:^{
        NSDictionary *map = @{
            @"type":@"onRoomSpecificationChanged",
            @"room":[aChatroom toJson]
        };
        [weakSelf.channel invokeMethod:ChatChatroomChanged arguments:map];
    }];
}

- (void)chatroomAttributesDidUpdated:(NSString *)roomId
                        attributeMap:(NSDictionary<NSString *, NSString *> *)attributeMap
                                from:(NSString *)fromId {
    __weak typeof(self) weakSelf = self;
    [ListenerHandle.sharedInstance addHandle:^{
        NSDictionary *map = @{
            @"type":@"onRoomAttributesDidUpdated",
            @"roomId":roomId,
            @"attributes":attributeMap,
            @"fromId": fromId
        };
        [weakSelf.channel invokeMethod:ChatChatroomChanged arguments:map];
    }];
}
- (void)chatroomAttributesDidRemoved:(NSString *)roomId
                          attributes:(NSArray<NSString *> *)attributes
                                from:(NSString *)fromId {
    __weak typeof(self) weakSelf = self;
    [ListenerHandle.sharedInstance addHandle:^{
        NSDictionary *map = @{
            @"type":@"onRoomAttributesDidRemoved",
            @"roomId":roomId,
            @"keys":attributes,
            @"fromId": fromId
        };
        [weakSelf.channel invokeMethod:ChatChatroomChanged arguments:map];
    }];
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




#pragma mark - 4.12.1
- (void)isMemberInChatRoomMuteList:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.roomManager isMemberInMuteListFromServerWithChatroomId:param[@"roomId"]
                                                                     completion:^(BOOL inMuteList, EMError * _Nullable aError) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:@(inMuteList)];
    }];
}



- (void)fetchChatRoomAllAttributesFromServer:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.roomManager fetchChatroomAllAttributes:param[@"roomId"] completion:^(EMError * _Nullable error, NSDictionary<NSString *,NSString *> * _Nullable properties) {
        [weakSelf wrapperCallBack:result channelName:aChannelName error:error object:properties];
    }];
}

- (void)setChatroomAttribute:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.roomManager setChatroomAttribute:param[@"roomId"] key:param[@"key"] value:param[@"value"] autoDelete:[param[@"autoDelete"] boolValue] completionBlock:^(EMError * _Nullable aError) {
        [weakSelf wrapperCallBack:result channelName:aChannelName error:aError object:nil];
    }];
}

- (void)setChatroomAttributeForced:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.roomManager setChatroomAttributeForced:param[@"roomId"] key:param[@"key"] value:param[@"value"] autoDelete:[param[@"autoDelete"] boolValue] completionBlock:^(EMError * _Nullable aError) {
        [weakSelf wrapperCallBack:result channelName:aChannelName error:aError object:nil];
    }];
}

- (void)removeChatRoomAttributeFromServer:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.roomManager removeChatroomAttribute:param[@"roomId"] key:param[@"key"] completionBlock:^(EMError * _Nullable aError) {
        [weakSelf wrapperCallBack:result channelName:aChannelName error:aError object:nil];
    }];
}

- (void)removeChatRoomAttributeFromServerForced:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.roomManager removeChatroomAttributeForced:param[@"roomId"] key:param[@"key"] completionBlock:^(EMError * _Nullable aError) {
        [weakSelf wrapperCallBack:result channelName:aChannelName error:aError object:nil];
    }];
}

- (void)joinChatRoom:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.roomManager joinChatroom:param[@"roomId"] completion:^(EMChatroom * _Nullable aChatroom, EMError * _Nullable aError) {
        [weakSelf wrapperCallBack:result channelName:aChannelName error:aError object:aChatroom ? [aChatroom toJson] : nil];
    }];
}

- (void)leaveChatRoom:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    // 5.0 同步方法
    EMError *error = nil;
    [EMClient.sharedClient.roomManager leaveChatroom:param[@"roomId"] error:&error];
    [self wrapperCallBack:result channelName:aChannelName error:error object:(error == nil ? @YES : @NO)];
}

- (void)updateChatRoomAnnouncement:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.roomManager updateChatroomAnnouncementWithId:param[@"roomId"] announcement:param[@"announcement"] completion:^(EMChatroom * _Nullable aChatroom, EMError * _Nullable aError) {
        [weakSelf wrapperCallBack:result channelName:aChannelName error:aError object:(aError == nil ? @YES : @NO)];
    }];
}
@end
