//
//  EMPushManagerWrapper.m
//  im_flutter_sdk
//
//  Created by 东海 on 2020/5/7.
//

#import "EMPushManagerWrapper.h"
#import "EMSDKMethod.h"
#import "EMHelper.h"

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
    if ([EMMethodKeyEnableOfflinePush isEqualToString:call.method]) {
        [self enableOfflinePush:call.arguments result:result];
    } else if ([EMMethodKeyDisableOfflinePush isEqualToString:call.method]) {
        [self disableOfflinePush:call.arguments result:result];
    } else if ([EMMethodKeyGetPushConfigs isEqualToString:call.method]) {
        [self getPushConfigs:call.arguments result:result];
    } else if ([EMMethodKeyGetPushConfigsFromServer isEqualToString:call.method]) {
        [self getPushConfigsFromServer:call.arguments result:result];
    } else if ([EMMethodKeyUpdatePushOptionServiceForGroup isEqualToString:call.method]) {
        [self updatePushOptionServiceForGroup:call.arguments result:result];
    } else if ([EMMethodKeyGetNoPushGroups isEqualToString:call.method]) {
        [self getNoPushGroups:call.arguments result:result];
    } else if ([EMMethodKeyUpdatePushNickname isEqualToString:call.method]) {
        [self updatePushNickname:call.arguments result:result];
    }else if ([EMMethodKeyUpdatePushDisplayStyle isEqualToString:call.method]) {
        [self updatePushDisplayStyle:call.arguments result:result];
    } else {
        [super handleMethodCall:call result:result];
    }
    
    
}

// 兼容安卓
- (void)enableOfflinePush:(NSDictionary *)param result:(FlutterResult)result {
    
}

- (void)disableOfflinePush:(NSDictionary *)param result:(FlutterResult)result {
    
    NSInteger startTime = [param[@"startTime"] integerValue];
    NSInteger endTime = [param[@"endTime"] integerValue];
    
    EMPushOptions *options = [[EMClient sharedClient] pushOptions];
    options.noDisturbStatus = EMPushNoDisturbStatusCustom;
    options.noDisturbingStartH = startTime;
    options.noDisturbingEndH = endTime;
    [[EMClient sharedClient] updatePushNotificationOptionsToServerWithCompletion:^(EMError *aError) {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:nil];
    }];
    
}

- (void)getPushConfigs:(NSDictionary *)param result:(FlutterResult)result {
    EMPushOptions *options = [[EMClient sharedClient] pushOptions];
    [self wrapperCallBack:result
                    error:nil
                 userInfo:@{@"value":[EMHelper pushOptionsToDictionary:options]}];
}


- (void)getPushConfigsFromServer:(NSDictionary *)param result:(FlutterResult)result {
    [[EMClient sharedClient] getPushNotificationOptionsFromServerWithCompletion:^(EMPushOptions *aOptions, EMError *aError) {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:@{@"value":[EMHelper pushOptionsToDictionary:aOptions]}];
    }];
}

- (void)updatePushOptionServiceForGroup:(NSDictionary *)param result:(FlutterResult)result {
    NSString *groupId = param[@"groupIds"];
    BOOL isPush = [param[@"noPush"] boolValue];
    [[EMClient sharedClient].groupManager updatePushServiceForGroup:groupId isPushEnabled:isPush completion:^(EMGroup *aGroup, EMError *aError) {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:nil];
    }];
}

- (void)getNoPushGroups:(NSDictionary *)param result:(FlutterResult)result {
    EMError *aError;
    NSArray *groupIds = [[EMClient sharedClient].groupManager getGroupsWithoutPushNotification:&aError];
    [self wrapperCallBack:result
                    error:aError
                 userInfo:@{@"value":groupIds}];
}

- (void)updatePushNickname:(NSDictionary *)param result:(FlutterResult)result {
    NSString *nickname = param[@"nickname"];
    [[EMClient sharedClient] setApnsNickname:nickname];
}

- (void)updatePushDisplayStyle:(NSDictionary *)param result:(FlutterResult)result {
    int style = [param[@"pushDisplayStyle"] intValue];
    EMPushOptions *options = [[EMClient sharedClient] pushOptions];
    options.displayStyle = style;
    [[EMClient sharedClient] updatePushNotificationOptionsToServerWithCompletion:^(EMError *aError) {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:nil];
    }];
    
}

@end
