//
//  EMConferenceManagerWrapper.m
//  im_flutter_sdk
//
//  Created by easemob-DN0164 on 2020/4/27.
//

#import "EMConferenceManagerWrapper.h"
#import "EMSDKMethod.h"
#import "DemoConfManager.h"
#import "EMHelper.h"

@implementation EMConferenceManagerWrapper

- (instancetype)initWithChannelName:(NSString *)aChannelName
                          registrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    if(self = [super initWithChannelName:aChannelName
                           registrar:registrar]) {
//        [EMClient.sharedClient.conferenceManager addDelegate:self delegateQueue:nil];
    }
    return self;
}

#pragma mark - FlutterPlugin

- (void)handleMethodCall:(FlutterMethodCall*)call
                  result:(FlutterResult)result {
    if ([EMMethodKeyCreateAndJoinConference isEqualToString:call.method]) {
        [self createAndJoinConference:call.arguments result:result];
    } else if ([EMMethodKeyJoinConference isEqualToString:call.method]) {
        [self joinConference:call.arguments result:result];
    } else if ([EMMethodKeyRegisterConferenceSharedManager isEqualToString:call.method]) {
        [self registerConferenceSharedManager:call.arguments result:result];
    } else {
        [super handleMethodCall:call result:result];
    }
}

- (void)createAndJoinConference:(NSDictionary *)param result:(FlutterResult)result {
    EMConferenceType conferenceType = [param[@"conferenceType"] intValue];
    NSString *password = param[@"password"];
    BOOL isRecord = [param[@"record"] boolValue];
    BOOL isMerge = [param[@"merge"] boolValue];
    NSDictionary *conferenceDict = @{@"type":@(conferenceType),@"password":password,@"record":@(isRecord),@"merge":
    @(isMerge)};
    [[DemoConfManager sharedManager] createAndJoinConference:conferenceDict completion:^(EMCallConference *aCall, EMError *aError) {
        
        NSLog(@"admins -- %@", aCall.adminIds);
        
        [self wrapperCallBack:result
                        error:aError
                     userInfo:@{@"value":[EMHelper callConferenceToDictionary:aCall]}];
    }];
}


- (void)joinConference:(NSDictionary *)param result:(FlutterResult)result {
    NSString *conferenceId = param[@"confId"];
    NSString *password = param[@"password"];
    NSDictionary *conferenceDict = @{@"em_conference_id":conferenceId,@"em_conference_password":password};
    [[DemoConfManager sharedManager] joinCoference:conferenceDict completion:^(EMCallConference *aCall, EMError *aError) {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:@{@"value":[EMHelper callConferenceToDictionary:aCall]}];
    }];
    
}

- (void)registerConferenceSharedManager:(NSDictionary *)param result:(FlutterResult)result {
    [DemoConfManager sharedManager];
}
@end
