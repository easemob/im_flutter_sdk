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
    if ([EMMethodKeyGetImPushConfigs isEqualToString:call.method]) {
        [self getImPushConfigs:call.arguments
                   channelName:EMMethodKeyGetImPushConfigs
                        result:result];
    } else if ([EMMethodKeyGetImPushConfigsFromServer isEqualToString:call.method]) {
        [self getImPushConfigsFromServer:call.arguments
                             channelName:EMMethodKeyGetImPushConfigsFromServer
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
    } else{
        [super handleMethodCall:call result:result];
    }
}

- (void)getImPushConfigs:(NSDictionary *)param
             channelName:(NSString *)aChannelName
                  result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    EMPushOptions *options = EMClient.sharedClient.pushOptions;
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:[options toJson]];
}

- (void)getImPushConfigsFromServer:(NSDictionary *)param
                       channelName:(NSString *)aChannelName
                            result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient getPushNotificationOptionsFromServerWithCompletion:^(EMPushOptions *aOptions, EMError *aError) {
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
    [EMClient.sharedClient updatePushNotifiationDisplayName:nickname
                                                 completion:^(NSString *aDisplayName, EMError *aError)
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
    
    EMPushOptions *options = EMClient.sharedClient.pushOptions;
    if (noDisturb) {
        options.noDisturbStatus = EMPushNoDisturbStatusCustom;
    }else {
        options.noDisturbStatus = EMPushNoDisturbStatusClose;
    }
    options.noDisturbingStartH = startTime;
    options.noDisturbingEndH = endTime;
    [EMClient.sharedClient updatePushNotificationOptionsToServerWithCompletion:^(EMError *aError) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:@(!aError)];
    }];
}

- (void)updateImPushStyle:(NSDictionary *)param
              channelName:(NSString *)aChannelName
                   result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    
    EMPushDisplayStyle pushStyle = [param[@"pushStyle"] intValue];
    EMPushOptions *options = EMClient.sharedClient.pushOptions;
    options.displayStyle = pushStyle;
    
    [EMClient.sharedClient updatePushNotificationOptionsToServerWithCompletion:^(EMError *aError) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:@(!aError)];
    }];
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
        NSArray *list = [EMClient.sharedClient.groupManager  getGroupsWithoutPushNotification:&aError];
        NSMutableArray *groups = [NSMutableArray array];
        for (EMGroup *group in list) {
            [groups addObject:[group toJson]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf wrapperCallBack:result
                          channelName:aChannelName
                                error:aError
                               object:groups];
        });
    });
}

@end
