//
//  EMChatThreadManagerWrapper.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2022/5/7.
//

#import "EMChatThreadManagerWrapper.h"
#import "EMSDKMethod.h"
#import "EMChatThread+Helper.h"
#import "EMCursorResult+Helper.h"
#import "EMChatMessage+Helper.h"
#import "EMChatThreadEvent+Helper.h"

@interface EMChatThreadManagerWrapper () <EMThreadManagerDelegate>

@end

@implementation EMChatThreadManagerWrapper
- (instancetype)initWithChannelName:(NSString *)aChannelName
                          registrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    if(self = [super initWithChannelName:aChannelName
                               registrar:registrar]) {
        [EMClient.sharedClient.threadManager addDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return self;
}


- (void)unRegisterEaseListener {
    [EMClient.sharedClient.threadManager removeDelegate:self];
}


#pragma mark - FlutterPlugin

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    
    if ([ChatFetchChatThreadDetail isEqualToString:call.method]) {
        [self fetchChatThreadDetail:call.arguments
                        channelName:call.method
                             result:result];
    } else if ([ChatFetchJoinedChatThreads isEqualToString:call.method]) {
        [self fetchJoinedChatThreads:call.arguments
                         channelName:call.method
                              result:result];
    } else if ([ChatFetchChatThreadsWithParentId isEqualToString:call.method]) {
        [self fetchChatThreadsWithParentId:call.arguments
                               channelName:call.method
                                    result:result];
    } else if ([ChatFetchJoinedChatThreadsWithParentId isEqualToString:call.method]) {
        [self fetchJoinedChatThreadsWithParentId:call.arguments
                               channelName:call.method
                                    result:result];
    } else if ([ChatFetchChatThreadMember isEqualToString:call.method]) {
        [self fetchChatThreadMember:call.arguments
                        channelName:call.method
                             result:result];
    } else if ([ChatFetchLastMessageWithChatThreads isEqualToString:call.method]) {
        [self fetchLastMessageWithChatThreads:call.arguments
                                  channelName:call.method
                                       result:result];
    } else if ([ChatRemoveMemberFromChatThread isEqualToString:call.method]) {
        [self removeMemberFromChatThread:call.arguments
                             channelName:call.method
                                  result:result];
    } else if ([ChatUpdateChatThreadSubject isEqualToString:call.method]) {
        [self updateChatThreadSubject:call.arguments
                          channelName:call.method
                               result:result];
    } else if ([ChatCreateChatThread isEqualToString:call.method]) {
        [self createChatThread:call.arguments
                   channelName:call.method
                        result:result];
    } else if ([ChatJoinChatThread isEqualToString:call.method]) {
        [self joinChatThread:call.arguments
                 channelName:call.method
                      result:result];
    } else if ([ChatLeaveChatThread isEqualToString:call.method]) {
        [self leaveChatThread:call.arguments
                  channelName:call.method
                       result:result];
    } else if ([ChatDestroyChatThread isEqualToString:call.method]) {
        [self destroyChatThread:call.arguments
                    channelName:call.method
                         result:result];
    } else {
        [super handleMethodCall:call result:result];
    }
}


- (void)fetchChatThreadDetail:(NSDictionary *)param
                  channelName:(NSString *)aChannelName
                       result:(FlutterResult)result {
    NSString *threadId = param[@"threadId"];
    __weak typeof(self)weakSelf = self;
    [EMClient.sharedClient.threadManager getChatThreadFromSever:threadId completion:^(EMChatThread * _Nonnull thread, EMError * _Nonnull aError) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[thread toJson]];
    }];
}

- (void)fetchJoinedChatThreads:(NSDictionary *)param
                   channelName:(NSString *)aChannelName
                        result:(FlutterResult)result {
    int pageSize = [param[@"pageSize"] intValue];
    NSString *cursor = param[@"cursor"];
    __weak typeof(self)weakSelf = self;
    [EMClient.sharedClient.threadManager getJoinedChatThreadsFromServerWithCursor:cursor pageSize:pageSize completion:^(EMCursorResult * _Nonnull cursorResult, EMError * _Nonnull aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[cursorResult toJson]];
    }];
}

- (void)fetchChatThreadsWithParentId:(NSDictionary *)param
                         channelName:(NSString *)aChannelName
                              result:(FlutterResult)result {
    int pageSize = [param[@"pageSize"] intValue];
    NSString *cursor = param[@"cursor"];
    NSString *parentId = param[@"parentId"];
    __weak typeof(self)weakSelf = self;
    [EMClient.sharedClient.threadManager getChatThreadsFromServerWithParentId:parentId cursor:cursor pageSize:pageSize completion:^(EMCursorResult * _Nonnull cursorResult, EMError * _Nonnull aError) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[cursorResult toJson]];
    }];
}

- (void)fetchJoinedChatThreadsWithParentId:(NSDictionary *)param
                         channelName:(NSString *)aChannelName
                              result:(FlutterResult)result {
    int pageSize = [param[@"pageSize"] intValue];
    NSString *cursor = param[@"cursor"];
    NSString *parentId = param[@"parentId"];
    __weak typeof(self)weakSelf = self;
    
    [EMClient.sharedClient.threadManager getJoinedChatThreadsFromServerWithParentId:parentId cursor:cursor pageSize:pageSize completion:^(EMCursorResult * _Nonnull cursorResult, EMError * _Nonnull aError) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[cursorResult toJson]];
    }];
}


- (void)fetchChatThreadMember:(NSDictionary *)param
                  channelName:(NSString *)aChannelName
                       result:(FlutterResult)result {
    int pageSize = [param[@"pageSize"] intValue];
    NSString *cursor = param[@"cursor"];
    NSString *threadId = param[@"threadId"];
    __weak typeof(self)weakSelf = self;
    [EMClient.sharedClient.threadManager getChatThreadMemberListFromServerWithId:threadId cursor:cursor pageSize:pageSize completion:^(EMCursorResult * _Nonnull cursorResult, EMError * _Nonnull aError) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[cursorResult toJson]];
    }];
}

- (void)fetchLastMessageWithChatThreads:(NSDictionary *)param
                            channelName:(NSString *)aChannelName
                                 result:(FlutterResult)result {
    NSArray *threadIds = param[@"threadIds"];
    __weak typeof(self)weakSelf = self;
    [EMClient.sharedClient.threadManager getLastMessageFromSeverWithChatThreads:threadIds completion:^(NSDictionary<NSString *,EMChatMessage *> * _Nonnull messageMap, EMError * _Nonnull aError) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        for (NSString *key in messageMap.allKeys) {
            dict[key] = [messageMap[key] toJson];
        }
        
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:dict];
    }];
}

- (void)removeMemberFromChatThread:(NSDictionary *)param
                       channelName:(NSString *)aChannelName
                            result:(FlutterResult)result {
    NSString *threadId = param[@"threadId"];
    NSString *memberId = param[@"memberId"];
    __weak typeof(self)weakSelf = self;
    [EMClient.sharedClient.threadManager removeMemberFromChatThread:memberId threadId:threadId completion:^(EMError * _Nonnull aError) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:@(YES)];
    }];
}

- (void)updateChatThreadSubject:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    NSString *threadId = param[@"threadId"];
    NSString *name = param[@"name"];
    __weak typeof(self)weakSelf = self;
    [EMClient.sharedClient.threadManager updateChatThreadName:name threadId:threadId completion:^(EMError * _Nonnull aError) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:@(YES)];
    }];
}

- (void)createChatThread:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    NSString *messageId = param[@"messageId"];
    NSString *name = param[@"name"];
    NSString *parentId = param[@"parentId"];
    __weak typeof(self)weakSelf = self;
    [EMClient.sharedClient.threadManager createChatThread:name messageId:messageId parentId:parentId completion:^(EMChatThread * _Nonnull thread, EMError * _Nonnull aError) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[thread toJson]];
    }];
}

- (void)joinChatThread:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    NSString *threadId = param[@"threadId"];
    __weak typeof(self)weakSelf = self;
    [EMClient.sharedClient.threadManager joinChatThread:threadId completion:^(EMChatThread * _Nonnull thread, EMError * _Nonnull aError) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[thread toJson]];
    }];
}

- (void)leaveChatThread:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    NSString *threadId = param[@"threadId"];
    __weak typeof(self)weakSelf = self;
    [EMClient.sharedClient.threadManager leaveChatThread:threadId completion:^(EMError * _Nonnull aError) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:@(YES)];
    }];
}

- (void)destroyChatThread:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    NSString *threadId = param[@"threadId"];
    __weak typeof(self)weakSelf = self;
    
    [EMClient.sharedClient.threadManager destroyChatThread:threadId completion:^(EMError * _Nonnull aError) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:@(YES)];
    }];
}


- (void)onChatThreadCreate:(EMChatThreadEvent *)event {
    [self.channel invokeMethod:onChatThreadCreate arguments:[event toJson]];
}

- (void)onChatThreadUpdate:(EMChatThreadEvent *)event {
    [self.channel invokeMethod:onChatThreadUpdate arguments:[event toJson]];
}

- (void)onChatThreadDestroy:(EMChatThreadEvent *)event {
    [self.channel invokeMethod:onChatThreadDestroy arguments:[event toJson]];
}

- (void)onUserKickOutOfChatThread:(EMChatThreadEvent *)event {
    [self.channel invokeMethod:onUserKickOutOfChatThread arguments:[event toJson]];
}


@end
