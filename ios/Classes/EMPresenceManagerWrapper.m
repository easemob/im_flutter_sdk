//
//  EMPresenceManagerWrapper.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2022/4/27.
//

#import "EMPresenceManagerWrapper.h"
#import <HyphenateChat/HyphenateChat.h>
#import "EMSDKMethod.h"
#import "NSArray+Helper.h"

@interface EMPresenceManagerWrapper () <EMPresenceManagerDelegate>

@end

@implementation EMPresenceManagerWrapper

- (instancetype)initWithChannelName:(NSString *)aChannelName registrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    
    if(self = [super initWithChannelName:aChannelName registrar:registrar]) {
        [EMClient.sharedClient.presenceManager addDelegate:self delegateQueue:nil];
    }
    
    return self;
}



#pragma mark - FlutterPlugin

- (void)handleMethodCall:(FlutterMethodCall*)call
                  result:(FlutterResult)result {
    [super handleMethodCall:call result:result];
}
- (void)publishPresenceWithDescription:(NSDictionary *)param
                           channelName:(NSString *)aChannelName
                                result:(FlutterResult)result
{
    NSString *desc = param[@"desc"];
    
    __weak typeof(self)weakSelf = self;
    [EMClient.sharedClient.presenceManager publishPresenceWithDescription:desc
                                                               completion:^(EMError *error)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:error
                           object:nil];
    }];
}


- (void)subscribe:(NSDictionary *)param
      channelName:(NSString *)aChannelName
           result:(FlutterResult)result
{
    NSArray *members = param[@"members"];
    NSInteger expiry = [param[@"expiry"] integerValue];

    __weak typeof(self)weakSelf = self;
    [EMClient.sharedClient.presenceManager subscribe:members
                                              expiry:expiry
                                          completion:^(NSArray<EMPresence *> *presences, EMError *error)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:error
                           object:[presences toJsonArray]];
    }];
}

- (void)unsubscribe:(NSDictionary *)param
      channelName:(NSString *)aChannelName
           result:(FlutterResult)result
{
    NSArray *members = param[@"members"];

    __weak typeof(self)weakSelf = self;
    [EMClient.sharedClient.presenceManager unsubscribe:members
                                            completion:^(EMError *error)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:error
                           object:nil];
    }];
}


- (void)fetchSubscribedMembersWithPageNum:(NSDictionary *)param
      channelName:(NSString *)aChannelName
           result:(FlutterResult)result
{
    int pageNum = [param[@"pageNum"] intValue];
    int pageSize = [param[@"pageSize"] intValue];
    
    __weak typeof(self)weakSelf = self;
    [EMClient.sharedClient.presenceManager fetchSubscribedMembersWithPageNum:pageNum
                                                                    pageSize:pageSize
                                                                  Completion:^(NSArray<NSString *> *members, EMError *error)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:error
                           object:members];
    }];
}


- (void)fetchPresenceStatus:(NSDictionary *)param
                channelName:(NSString *)aChannelName
                     result:(FlutterResult)result
{
    NSArray *members = param[@"members"];

    __weak typeof(self)weakSelf = self;
    [EMClient.sharedClient.presenceManager fetchPresenceStatus:members
                                                    completion:^(NSArray<EMPresence *> *presences, EMError *error)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:error
                           object:[presences toJsonArray]];
    }];
}


#pragma mark - EMPresenceManagerDelegate
- (void)presenceStatusDidChanged:(NSArray<EMPresence*>*)presences {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"presences"] = [presences toJsonArray];
    [self.channel invokeMethod:ChatOnPresenceStatusChanged arguments:data];
}

@end
