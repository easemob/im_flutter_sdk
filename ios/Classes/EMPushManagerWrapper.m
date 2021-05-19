//
//  EMPushManagerWrapper.m
//  im_flutter_sdk
//
//  Created by 东海 on 2020/5/7.
//

#import "EMPushManagerWrapper.h"
#import "EMSDKMethod.h"
#import "EMPushOptions+Flutter.h"
#import "EMGroup+Flutter.h"

@implementation EMPushManagerWrapper

- (instancetype)initWithChannelName:(NSString *)aChannelName
                          registrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    if(self = [super initWithChannelName:aChannelName
                               registrar:registrar]) {
    }
    return self;
}

#pragma mark - FlutterPlugin

- (void)handleMethodCall:(FlutterMethodCall*)call
                  result:(FlutterResult)result {
    if ([EMMethodKeyGetImPushConfig isEqualToString:call.method]) {
        [self getImPushConfig:call.arguments
                   channelName:EMMethodKeyGetImPushConfig
                        result:result];
    } else if ([EMMethodKeyGetImPushConfigFromServer isEqualToString:call.method]) {
        [self getImPushConfigFromServer:call.arguments
                             channelName:EMMethodKeyGetImPushConfigFromServer
                                  result:result];
    } else if ([EMMethodKeyUpdatePushNickname isEqualToString:call.method]) {
        [self updatePushNickname:call.arguments
                     channelName:EMMethodKeyUpdatePushNickname
                          result:result];
    } else if ([EMMethodKeyImPushNoDisturb isEqualToString:call.method]) {
        [self setImPushNoDisturb:call.arguments
                     channelName:EMMethodKeyImPushNoDisturb
                          result:result];
    } else if ([EMMethodKeyUpdateImPushStyle isEqualToString:call.method]) {
        [self updateImPushStyle:call.arguments
                    channelName:EMMethodKeyUpdateImPushStyle
                         result:result];
    } else if ([EMMethodKeyUpdateGroupPushService isEqualToString:call.method]) {
        [self updateGroupPushService:call.arguments
                         channelName:EMMethodKeyUpdateGroupPushService
                              result:result];
    } else if ([EMMethodKeyGetNoDisturbGroups isEqualToString:call.method]) {
        [self getNoDisturbGroups:call.arguments
                     channelName:EMMethodKeyGetNoDisturbGroups
                          result:result];
    } else if ([EMMethodKeyBindDeviceToken isEqualToString:call.method]) {
        [self  bindDeviceToken:call.arguments
                   channelName:(NSString *)EMMethodKeyBindDeviceToken
                        result:result];
    }
    else{
        [super handleMethodCall:call result:result];
    }
}

- (void)getImPushConfig:(NSDictionary *)param
             channelName:(NSString *)aChannelName
                  result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    EMPushOptions *options = EMClient.sharedClient.pushManager.pushOptions;
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:[options toJson]];
}

- (void)getImPushConfigFromServer:(NSDictionary *)param
                       channelName:(NSString *)aChannelName
                            result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.pushManager getPushNotificationOptionsFromServerWithCompletion:^(EMPushOptions *aOptions, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[aOptions toJson]];
        
    }];
}

- (void)updatePushNickname:(NSDictionary *)param
               channelName:(NSString *)aChannelName
                    result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSString *nickname = param[@"nickname"];
    [EMClient.sharedClient.pushManager updatePushDisplayName:nickname
                                                  completion:^(NSString * _Nonnull aDisplayName, EMError * _Nonnull aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:aDisplayName];
    }];
    
}

- (void)setImPushNoDisturb:(NSDictionary *)param
               channelName:(NSString *)aChannelName
                    result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    
    bool noDisturb = [param[@"noDisturb"] boolValue];
    int startTime = [param[@"startTime"] intValue];
    int endTime = [param[@"endTime"] intValue];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *aError = nil;
        if (noDisturb) {
            aError = [EMClient.sharedClient.pushManager disableOfflinePushStart:startTime end:endTime];
        }else {
            aError = [EMClient.sharedClient.pushManager enableOfflinePush];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf wrapperCallBack:result
                          channelName:aChannelName
                                error:aError
                               object:@(!aError)];
        });
    });
    
    
}

- (void)updateImPushStyle:(NSDictionary *)param
              channelName:(NSString *)aChannelName
                   result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    
    EMPushDisplayStyle pushStyle = [param[@"pushStyle"] intValue];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *aError = [EMClient.sharedClient.pushManager updatePushDisplayStyle:pushStyle];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf wrapperCallBack:result
                          channelName:aChannelName
                                error:aError
                               object:@(!aError)];
        });
    });
}

- (void)updateGroupPushService:(NSDictionary *)param
                   channelName:(NSString *)aChannelName
                        result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSString *groupId = param[@"group_id"];
    bool noDisturb = [param[@"noDisturb"] boolValue];
    [EMClient.sharedClient.groupManager updatePushServiceForGroup:groupId
                                                    isPushEnabled:!noDisturb
                                                       completion:^(EMGroup *aGroup, EMError *aError) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[aGroup toJson]];
    }];
}

- (void)getNoDisturbGroups:(NSDictionary *)param
               channelName:(NSString *)aChannelName
                    result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *aError = nil;
        NSArray *list = [EMClient.sharedClient.groupManager getGroupsWithoutPushNotification:&aError];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf wrapperCallBack:result
                          channelName:aChannelName
                                error:aError
                               object:list];
        });
    });
}

- (void)bindDeviceToken:(NSDictionary *)param
            channelName:(NSString *)aChannelName
                 result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSString *deviceToken = param[@"token"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *error = [EMClient.sharedClient bindDeviceToken:deviceToken];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf wrapperCallBack:result
                          channelName:aChannelName
                                error:error
                               object:nil];
        });
    });
}


@end
