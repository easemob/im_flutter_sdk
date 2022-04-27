//
//  EMPresenceManagerWrapper.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2022/4/27.
//

#import "EMPresenceManagerWrapper.h"
#import <HyphenateChat/HyphenateChat.h>

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


- (void)subscribe:(NSArray<NSString*>*)members
            expiry:(NSInteger)expiry
        completion:(void(^)(NSArray<EMPresence*>*presences,EMError*error))aCompletion {
    
}

- (void)unsubscribe:(NSArray<NSString*>*)members
          completion:(void(^)(EMError*error))aCompletion {
    
}

- (void)fetchSubscribedMembersWithPageNum:(NSUInteger)pageNum
                                  pageSize:(NSUInteger)pageSize
                                Completion:(void(^)(NSArray<NSString*>* members,EMError*error))aCompletion
{
    
}

- (void)fetchPresenceStatus:(NSArray<NSString*>*)members
                  completion:(void(^)(NSArray<EMPresence*>* presences,EMError*error))aCompletion
{
    
}


- (void) presenceStatusDidChanged:(NSArray<EMPresence*>*)presences {
    
}

@end
