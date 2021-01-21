//
//  EMCallManagerWrapper.m
//  device_info
//
//  Created by easemob-DN0164 on 2020/1/14.
//

#import "EMCallManagerWrapper.h"
#import "EMCallMethods.h"
#import "DemoCallManager.h"
#import "EMCallHelper.h"


@interface EMCallManagerWrapper () <EMCallManagerDelegate>
@property (nonatomic, strong) EMCallSession *callSession;
@end

@implementation EMCallManagerWrapper
- (instancetype)initWithChannelName:(NSString *)aChannelName
                          registrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    if(self = [super initWithChannelName:aChannelName
                               registrar:registrar]) {
        [EMClient.sharedClient.callManager addDelegate:self delegateQueue:nil];
    }
    return self;
}

#pragma mark - FlutterPlugin

- (void)handleMethodCall:(FlutterMethodCall*)call
                  result:(FlutterResult)result {
    if ([EMMethodKeyStartCall isEqualToString:call.method]) {
        [self startCall:call.arguments result:result];
    } else if ([EMMethodKeySetCallOptions isEqualToString:call.method]) {
        [self setCallOptions:call.arguments result:result];
    } else if ([EMMethodKeyRegisterCallReceiver isEqualToString:call.method]) {
        [self registerCallReceiver:call.arguments result:result];
    }else if ([EMMethodKeyRegisterCallSharedManager isEqualToString:call.method]) {
        [self registerCallSharedManager:call.arguments result:result];
    }else {
        [super handleMethodCall:call result:result];
    }
}

#pragma mark - Actions

- (void)startCall:(NSDictionary *)param result:(FlutterResult)result {
    EMCallType callType = [param[@"callType"] intValue];
    NSString *remoteName = param[@"remoteName"];
    BOOL isRecord = [param[@"record"] boolValue];
    BOOL isMerge = [param[@"mergeStream"] boolValue];
    NSString *ext = param[@"ext"];
    
    [[DemoCallManager sharedManager] _makeCallWithUsername:remoteName
                                                      type:callType
                                                    record:isRecord
                                               mergeStream:isMerge
                                                       ext:ext
                                         isCustomVideoData:NO
                                                completion:^(EMCallSession *aCallSession, EMError *aError)
     {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:@{@"callId": aCallSession.callId ?: @""}];
    }];
}

- (void)setCallOptions:(NSDictionary *)param result:(FlutterResult)result {
    [[EMClient sharedClient].callManager setCallOptions:[EMCallHelper callOptionsDictionaryToEMCallOptions:param]];
    [self wrapperCallBack:result
                    error:nil
                 userInfo:nil];
}

- (void)registerCallReceiver:(NSDictionary *)param result:(FlutterResult)result {
    [self wrapperCallBack:result
                    error:nil
                 userInfo:nil];
}

- (void)registerCallSharedManager:(NSDictionary *)param result:(FlutterResult)result {
    [DemoCallManager sharedManager];
    [self wrapperCallBack:result
                    error:nil
                 userInfo:nil];
}

- (EMError *)noSessionError {
    return [EMError errorWithDescription:@"no call session" code:EMErrorGeneral];
}

#pragma mark - EMCallManagerDelegate

- (void)callDidReceive:(EMCallSession *)aSession {
    self.callSession = aSession;
    
    NSMutableDictionary *map = [NSMutableDictionary dictionaryWithObject:@"connecting" forKey:@"type"];
    if (aSession.localName && aSession.localName.length > 0) {
        map[@"localName"] = aSession.localName;
    }
    
    if (aSession.remoteName && aSession.remoteName.length > 0) {
        map[@"remoteName"] = aSession.remoteName;
    }
    
    if (aSession.serverVideoId && aSession.serverVideoId.length > 0) {
        map[@"serverVideoId"] = aSession.serverVideoId;
    }
    
    if (aSession.callId && aSession.callId.length > 0) {
        map[@"callId"] = aSession.callId;
    }
    
    if (aSession.ext && aSession.ext.length > 0) {
        map[@"callExt"] = aSession.ext;
    }
    
    if (aSession.type == EMCallTypeVoice) {
        map[@"callType"] = @(0);
    }else {
        map[@"callType"] = @(1);
    }
    
    map[@"isRecordOnServer"] = @(aSession.willRecord);
    
    [self.channel invokeMethod:EMMethodKeyOnCallChanged
                     arguments:map];
}

- (void)callDidConnect:(EMCallSession *)aSession {
    NSDictionary *map = @{@"type":@"connected"};
    [self.channel invokeMethod:EMMethodKeyOnCallChanged
                     arguments:map];
}

- (void)callDidAccept:(EMCallSession *)aSession {
    NSMutableDictionary *map = [NSMutableDictionary dictionaryWithObject:@"accepted" forKey:@"type"];
    
    if (aSession.serverVideoId && aSession.serverVideoId.length > 0) {
        map[@"serverVideoId"] = aSession.serverVideoId;
    }
    [self.channel invokeMethod:EMMethodKeyOnCallChanged
                     arguments:map];
}

- (void)callDidEnd:(EMCallSession *)aSession
            reason:(EMCallEndReason)aReason
             error:(EMError *)aError {
    NSDictionary *map = @{
        @"type":@"disconnected",
        @"reason":[NSNumber numberWithInt:[self callEndReasonToInt:aReason]],
    };
    [self.channel invokeMethod:EMMethodKeyOnCallChanged
                     arguments:map];
}

- (void)callStateDidChange:(EMCallSession *)aSession
                      type:(EMCallStreamingStatus)aType {
    NSString *type;
    if (aType == EMCallStreamStatusVoicePause) {
        type = @"netVoicePause";
    } else if (aType == EMCallStreamStatusVoiceResume) {
        type = @"netVoiceResume";
    } else if (aType == EMCallStreamStatusVideoPause) {
        type = @"netVideoPause";
    } else {
        type = @"netVideoResume";
    }
    NSDictionary *map = @{@"type":type};
    [self.channel invokeMethod:EMMethodKeyOnCallChanged
                     arguments:map];
}

- (void)callNetworkDidChange:(EMCallSession *)aSession
                      status:(EMCallNetworkStatus)aStatus {
    NSString *type;
    if (aStatus == EMCallNetworkStatusNormal) {
        type = @"networkNormal";
    } else if (aStatus == EMCallNetworkStatusUnstable) {
        type = @"networkUnstable";
    } else {
        type = @"networkDisconnected";
    }
    
    NSDictionary *map = @{@"type":type};
    [self.channel invokeMethod:EMMethodKeyOnCallChanged
                     arguments:map];
}

// 通话结束原因
- (int)callEndReasonToInt:(EMCallEndReason)aReason {
    int reason;
    if (aReason == EMCallEndReasonHangup) {
        reason = 0;
    } else if (aReason == EMCallEndReasonNoResponse) {
        reason = 1;
    } else if (aReason == EMCallEndReasonDecline) {
        reason = 2;
    } else if (aReason == EMCallEndReasonBusy) {
        reason = 3;
    } else if (aReason == EMCallEndReasonFailed) {
        reason = 4;
    } else if (aReason == EMCallEndReasonRemoteOffline) {
        reason = 5;
    } else if (aReason == EMCallEndReasonNotEnable) {
        reason = 101;
    } else if (aReason == EMCallEndReasonServiceArrearages) {
        reason = 102;
    } else if (aReason == EMCallEndReasonServiceForbidden) {
        reason = 103;
    } else {
        reason = -1;
    }
    return reason;
}

@end
