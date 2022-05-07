//
//  EMChatThreadManagerWrapper.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2022/5/7.
//

#import "EMChatThreadManagerWrapper.h"
#import "EMSDKMethod.h"


@implementation EMChatThreadManagerWrapper
- (instancetype)initWithChannelName:(NSString *)aChannelName
                          registrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    if(self = [super initWithChannelName:aChannelName
                               registrar:registrar]) {
        // TODO: add delegate
    }
    return self;
}


#pragma mark - FlutterPlugin

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    
    if ([ChatFetchChatThread isEqualToString:call.method]) {
        [self fetchChatThread:call.arguments
                  channelName:call.method
                       result:result];
    } else if ([ChatFetchChatThreadDetail isEqualToString:call.method]) {
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


- (void)fetchChatThread:(NSDictionary *)param
            channelName:(NSString *)aChannelName
                 result:(FlutterResult)result {
    NSString *threadId = param[@"threadId"];
    // TODO:
}

- (void)fetchChatThreadDetail:(NSDictionary *)param
                  channelName:(NSString *)aChannelName
                       result:(FlutterResult)result {
    NSString *threadId = param[@"threadId"];
    // TODO:
}

- (void)fetchJoinedChatThreads:(NSDictionary *)param
                   channelName:(NSString *)aChannelName
                        result:(FlutterResult)result {
    int pageSize = [param[@"pageSize"] intValue];
    NSString *cursor = param[@"cursor"];
    
    // TODO:
}

- (void)fetchChatThreadsWithParentId:(NSDictionary *)param
                         channelName:(NSString *)aChannelName
                              result:(FlutterResult)result {
    int pageSize = [param[@"pageSize"] intValue];
    NSString *cursor = param[@"cursor"];
    NSString *parentId = param[@"parentId"];
    // TODO:
}

- (void)fetchChatThreadMember:(NSDictionary *)param
                  channelName:(NSString *)aChannelName
                       result:(FlutterResult)result {
    int pageSize = [param[@"pageSize"] intValue];
    NSString *cursor = param[@"cursor"];
    NSString *threadId = param[@"threadId"];
    // TODO:
}

- (void)fetchLastMessageWithChatThreads:(NSDictionary *)param
                            channelName:(NSString *)aChannelName
                                 result:(FlutterResult)result {
    NSArray *threadIds = param[@"threadIds"];
    // TODO:
}

- (void)removeMemberFromChatThread:(NSDictionary *)param
                       channelName:(NSString *)aChannelName
                            result:(FlutterResult)result {
    NSString *threadId = param[@"threadId"];
    NSString *memberId = param[@"memberId"];
    // TODO:
}

- (void)updateChatThreadSubject:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    NSString *threadId = param[@"threadId"];
    NSString *name = param[@"name"];
    // TODO:
}

- (void)createChatThread:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    NSString *messageId = param[@"messageId"];
    NSString *name = param[@"name"];
    NSString *parentId = param[@"parentId"];
    // TODO:
}

- (void)joinChatThread:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    NSString *threadId = param[@"threadId"];
    // TODO:
}

- (void)leaveChatThread:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    NSString *threadId = param[@"threadId"];
    // TODO:
}

- (void)destroyChatThread:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    NSString *threadId = param[@"threadId"];
    // TODO:
}

@end
