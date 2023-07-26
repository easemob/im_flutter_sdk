//
//  EMPushManagerWrapper.m
//  im_flutter_sdk
//
//  Created by 东海 on 2020/5/7.
//

#import "EMPushManagerWrapper.h"
#import "EMSDKMethod.h"
#import "EMPushOptions+Helper.h"
#import "EMConversation+Helper.h"
#import "EMGroup+Helper.h"
#import "EMSilentModeParam+Helper.h"
#import "EMSilentModeResult+Helper.h"

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
    if ([ChatGetImPushConfig isEqualToString:call.method]) {
        [self getImPushConfig:call.arguments
                  channelName:call.method
                       result:result];
    } else if ([ChatGetImPushConfigFromServer isEqualToString:call.method]) {
        [self getImPushConfigFromServer:call.arguments
                            channelName:call.method
                                 result:result];
    } else if ([ChatUpdatePushNickname isEqualToString:call.method]) {
        [self updatePushNickname:call.arguments
                     channelName:call.method
                          result:result];
    } else if ([ChatUpdateImPushStyle isEqualToString:call.method]) {
        [self updateImPushStyle:call.arguments
                    channelName:call.method
                         result:result];
    } else if ([ChatUpdateGroupPushService isEqualToString:call.method]) {
        [self updateGroupPushService:call.arguments
                         channelName:call.method
                              result:result];
    } else if ([ChatBindDeviceToken isEqualToString:call.method] || [UpdateFCMPushToken isEqualToString:call.method]) {
        [self  bindDeviceToken:call.arguments
                   channelName:call.method
                        result:result];
    } else if ([ChatEnablePush isEqualToString:call.method]) {
        [self enablePush:call.arguments
             channelName:call.method
                  result:result];
    } else if ([ChatDisablePush isEqualToString:call.method]) {
        [self disablePush:call.arguments
              channelName:call.method
                   result:result];
    } else if ([ChatGetNoPushGroups isEqualToString:call.method]) {
        [self getNoPushGroups:call.arguments
                  channelName:call.method
                       result:result];
    } else if ([ChatUpdateUserPushService isEqualToString:call.method]){
        [self updateUserPushService:call.arguments
                        channelName:call.method
                             result:result];
    } else if ([ChatGetNoPushUsers isEqualToString:call.method]){
        [self getNoPushUsers:call.arguments
                 channelName:call.method
                      result:result];
    } else if ([ChatReportPushAction isEqualToString:call.method]){
        [self reportPushAction:call.arguments
                   channelName:call.method
                        result:result];
    } else if ([ChatSetConversationSilentMode isEqualToString:call.method]){
        [self setConversationSilentMode:call.arguments
                            channelName:call.method
                                 result:result];
    } else if ([ChatRemoveConversationSilentMode isEqualToString:call.method]){
        [self removeConversationSilentMode:call.arguments
                               channelName:call.method
                                    result:result];
    } else if ([ChatFetchConversationSilentMode isEqualToString:call.method]){
        [self fetchConversationSilentMode:call.arguments
                              channelName:call.method
                                   result:result];
    } else if ([ChatSetSilentModeForAll isEqualToString:call.method]){
        [self setSilentModeForAll:call.arguments
                      channelName:call.method
                           result:result];
    } else if ([ChatFetchSilentModeForAll isEqualToString:call.method]){
        [self fetchSilentModeForAll:call.arguments
                        channelName:call.method
                             result:result];
    } else if ([ChatFetchSilentModeForConversations isEqualToString:call.method]){
        [self fetchSilentModeForConversations:call.arguments
                                  channelName:call.method
                                       result:result];
    } else if ([ChatSetPreferredNotificationLanguage isEqualToString:call.method]){
        [self setPreferredNotificationLanguage:call.arguments
                                   channelName:call.method
                                        result:result];
    } else if ([ChatFetchPreferredNotificationLanguage isEqualToString:call.method]){
        [self fetchPreferredNotificationLanguage:call.arguments
                                     channelName:call.method
                                          result:result];
    } else if ([ChatSetPushTemplate isEqualToString:call.method]) {
        [self setPushTemplate:call.arguments channelName:call.method result:result];
    } else if ([ChatGetPushTemplate isEqualToString:call.method]) {
        [self getPushTemplate:call.arguments channelName:call.method result:result];
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
    NSArray *groupIds = param[@"group_ids"];
    bool noPush = [param[@"noPush"] boolValue];
    
    [EMClient.sharedClient.pushManager updatePushServiceForGroups:groupIds
                                                      disablePush:noPush
                                                       completion:^(EMError * _Nonnull aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:nil];
    }];
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


- (void)enablePush:(NSDictionary *)param
       channelName:(NSString *)aChannelName
            result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *error = [EMClient.sharedClient.pushManager enableOfflinePush];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf wrapperCallBack:result
                          channelName:aChannelName
                                error:error
                               object:nil];
        });
    });
}

- (void)disablePush:(NSDictionary *)param
        channelName:(NSString *)aChannelName
             result:(FlutterResult)result {
    int startTime = [param[@"start"] intValue];
    int endTime = [param[@"end"] intValue];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *error = [EMClient.sharedClient.pushManager disableOfflinePushStart:startTime end:endTime];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf wrapperCallBack:result
                          channelName:aChannelName
                                error:error
                               object:nil];
        });
    });
}

- (void)getNoPushGroups:(NSDictionary *)param
            channelName:(NSString *)aChannelName
                 result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray<NSString *>* groups = [EMClient.sharedClient.pushManager noPushGroups];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf wrapperCallBack:result
                          channelName:aChannelName
                                error:nil
                               object:groups];
        });
    });
}


- (void)updateUserPushService:(NSDictionary *)param
                  channelName:(NSString *)aChannelName
                       result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSArray *userIds = param[@"user_ids"];
    bool noPush = [param[@"noPush"] boolValue];
    
    [EMClient.sharedClient.pushManager updatePushServiceForUsers:userIds disablePush:noPush completion:^(EMError * _Nonnull aError) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:nil];
    }];
}

- (void)getNoPushUsers:(NSDictionary *)param
           channelName:(NSString *)aChannelName
                result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray<NSString *>* userIds = [EMClient.sharedClient.pushManager noPushUIds];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf wrapperCallBack:result
                          channelName:aChannelName
                                error:nil
                               object:userIds];
        });
    });
}

- (void)reportPushAction:(NSDictionary *)param
             channelName:(NSString *)aChannelName
                  result:(FlutterResult)result {
    
}

- (void)setConversationSilentMode:(NSDictionary *)param
                      channelName:(NSString *)aChannelName
                           result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSString *conversaionId = param[@"conversationId"];
    EMConversationType type = [EMConversation typeFromInt:[param[@"conversationType"] intValue]];
    EMSilentModeParam *silmentParam = [EMSilentModeParam formJson:param[@"param"]];
    [EMClient.sharedClient.pushManager setSilentModeForConversation:conversaionId
                                                   conversationType:type
                                                             params:silmentParam
                                                         completion:^(EMSilentModeResult * _Nullable aResult, EMError * _Nullable aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:nil];
    }];
}

- (void)removeConversationSilentMode:(NSDictionary *)param
                         channelName:(NSString *)aChannelName
                              result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSString *conversaionId = param[@"conversationId"];
    EMConversationType type = [EMConversation typeFromInt:[param[@"conversationType"] intValue]];
    [EMClient.sharedClient.pushManager clearRemindTypeForConversation:conversaionId
                                                     conversationType:type
                                                           completion:^(EMSilentModeResult * _Nullable aResult, EMError * _Nullable aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:nil];
    }];
}
- (void)fetchConversationSilentMode:(NSDictionary *)param
                        channelName:(NSString *)aChannelName
                             result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSString *conversaionId = param[@"conversationId"];
    EMConversationType type = [EMConversation typeFromInt:[param[@"conversationType"] intValue]];
    [EMClient.sharedClient.pushManager getSilentModeForConversation:conversaionId
                                                   conversationType:type
                                                         completion:^(EMSilentModeResult * _Nullable aResult, EMError * _Nullable aError) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[aResult toJson]];
    }];
}

- (void)setSilentModeForAll:(NSDictionary *)param
                channelName:(NSString *)aChannelName
                     result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    EMSilentModeParam *silmentParam = [EMSilentModeParam formJson:param[@"param"]];
    [EMClient.sharedClient.pushManager setSilentModeForAll:silmentParam
                                                completion:^(EMSilentModeResult * _Nullable aResult, EMError * _Nullable aError) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:nil];
    }];
}

- (void)fetchSilentModeForAll:(NSDictionary *)param
                  channelName:(NSString *)aChannelName
                       result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.pushManager getSilentModeForAllWithCompletion:^(EMSilentModeResult * _Nullable aResult, EMError * _Nullable aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[aResult toJson]];
    }];
}

- (void)fetchSilentModeForConversations:(NSDictionary *)param
                            channelName:(NSString *)aChannelName
                                 result:(FlutterResult)result {
    NSMutableArray *conversations = [NSMutableArray array];
    for (NSString *conversaitonId in param.allKeys) {
        EMConversationType type = [EMConversation typeFromInt:[param[conversaitonId] intValue]];
        EMConversation *conversation = [EMClient.sharedClient.chatManager getConversation:conversaitonId type:type createIfNotExist:YES];
        [conversations addObject:conversation];
    }
    
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.pushManager getSilentModeForConversations:conversations
                                                          completion:^(NSDictionary<NSString *,EMSilentModeResult *> * _Nullable aResult, EMError * _Nullable aError)
     {
        
        NSMutableDictionary *tmpDict = [NSMutableDictionary dictionary];
        for (NSString *conversationId in aResult.allKeys) {
            tmpDict[conversationId] = [aResult[conversationId] toJson];
        }
        
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:tmpDict];
    }];
}

- (void)setPreferredNotificationLanguage:(NSDictionary *)param
                             channelName:(NSString *)aChannelName
                                  result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSString *code = param[@"code"];
    [EMClient.sharedClient.pushManager setPreferredNotificationLanguage:code completion:^(EMError * _Nullable aError) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:nil];
    }];
}

- (void)fetchPreferredNotificationLanguage:(NSDictionary *)param
                               channelName:(NSString *)aChannelName
                                    result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.pushManager getPreferredNotificationLanguageCompletion:^(NSString * _Nullable aLaguangeCode, EMError * _Nullable aError) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:aLaguangeCode];
    }];
}

- (void)setPushTemplate:(NSDictionary *)param
                               channelName:(NSString *)aChannelName
                                    result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSString *pushTemplateName = param[@"pushTemplateName"];
    [EMClient.sharedClient.pushManager setPushTemplate:pushTemplateName completion:^(EMError * _Nullable aError) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:nil];
    }];
}

- (void)getPushTemplate:(NSDictionary *)param
                               channelName:(NSString *)aChannelName
                                    result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.pushManager getPushTemplate:^(NSString * _Nullable aPushTemplateName, EMError * _Nullable aError) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:aPushTemplateName];
    }];
}

@end
