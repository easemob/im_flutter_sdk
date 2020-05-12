//
//  EMCallManagerWrapper.m
//  device_info
//
//  Created by easemob-DN0164 on 2020/1/14.
//

#import "EMCallManagerWrapper.h"
#import "EMSDKMethod.h"
#import "DemoCallManager.h"
#import "EMHelper.h"

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
    } else if ([EMMethodKeyGetCallId isEqualToString:call.method]) {
        [self getCallId:call.arguments result:result];
    } else if ([EMMethodKeyGetConnectType isEqualToString:call.method]) {
        [self getConnectType:call.arguments result:result];
    } else if ([EMMethodKeyGetExt isEqualToString:call.method]) {
        [self getExt:call.arguments result:result];
    } else if ([EMMethodKeyGetLocalName isEqualToString:call.method]) {
        [self getLocalName:call.arguments result:result];
    } else if ([EMMethodKeyGetRemoteName isEqualToString:call.method]) {
        [self getRemoteName:call.arguments result:result];
    } else if ([EMMethodKeyGetServerRecordId isEqualToString:call.method]) {
        [self getServerRecordId:call.arguments result:result];
    } else if ([EMMethodKeyGetCallType isEqualToString:call.method]) {
        [self getCallType:call.arguments result:result];
    } else if ([EMMethodKeyIsRecordOnServer isEqualToString:call.method]) {
        [self isRecordOnServer:call.arguments result:result];
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
    
    __weak typeof(self) weakSelf = self;
    [[DemoCallManager sharedManager] _makeCallWithUsername:remoteName type:callType record:isRecord mergeStream:isMerge ext:ext isCustomVideoData:NO completion:^(EMCallSession *aCallSession, EMError *aError) {
        weakSelf.callSession = aCallSession;
    }];
}

- (void)setCallOptions:(NSDictionary *)param result:(FlutterResult)result {
    [[EMClient sharedClient].callManager setCallOptions:[EMHelper callOptionsDictionaryToEMCallOptions:param]];
}

- (void)registerCallReceiver:(NSDictionary *)param result:(FlutterResult)result {
    
}

- (void)getCallId:(NSDictionary *)param result:(FlutterResult)result {
    if (self.callSession) {
        NSString *callId = self.callSession.callId;
        [self wrapperCallBack:result
                        error:nil
                     userInfo:@{@"value":callId}];
    }
}

- (void)getConnectType:(NSDictionary *)param result:(FlutterResult)result {
    if (self.callSession) {
        EMCallConnectType connectType = self.callSession.connectType;
        int type;
        if (connectType == EMCallConnectTypeNone) {
            type = 0;
        } else if (connectType == EMCallConnectTypeDirect) {
            type = 1;
        } else {
            type = 2;
        }
        [self wrapperCallBack:result
                        error:nil
                     userInfo:@{@"value":[NSNumber numberWithInt:type]}];
    }
}

- (void)getExt:(NSDictionary *)param result:(FlutterResult)result {
    if (self.callSession) {
        NSString *ext = self.callSession.ext;
        [self wrapperCallBack:result
                        error:nil
                     userInfo:@{@"value":ext}];
    }
}

- (void)getLocalName:(NSDictionary *)param result:(FlutterResult)result {
    if (self.callSession) {
        NSString *localName = self.callSession.localName;
        [self wrapperCallBack:result
                        error:nil
                     userInfo:@{@"value":localName}];
    }
}

- (void)getRemoteName:(NSDictionary *)param result:(FlutterResult)result {
    if (self.callSession) {
        NSString *remoteName = self.callSession.remoteName;
        [self wrapperCallBack:result
                        error:nil
                     userInfo:@{@"value":remoteName}];
    }
}

- (void)getServerRecordId:(NSDictionary *)param result:(FlutterResult)result {
    if (self.callSession) {
        NSString *serverVideoId = self.callSession.serverVideoId;
        [self wrapperCallBack:result
                        error:nil
                     userInfo:@{@"value":serverVideoId}];
    }
}

- (void)getCallType:(NSDictionary *)param result:(FlutterResult)result {
    if (self.callSession) {
        EMCallType callType = self.callSession.type;
        int type;
        if (callType == EMCallTypeVoice) {
            type = 0;
        } else {
            type = 1;
        }
        [self wrapperCallBack:result
                        error:nil
                     userInfo:@{@"value":[NSNumber numberWithInt:type]}];
    }
}

- (void)isRecordOnServer:(NSDictionary *)param result:(FlutterResult)result {
    if (self.callSession) {
        BOOL willRecord = self.callSession.willRecord;
        [self wrapperCallBack:result
                        error:nil
                     userInfo:@{@"value":[NSNumber numberWithBool:willRecord]}];
    }
}

- (void)registerCallSharedManager:(NSDictionary *)param result:(FlutterResult)result {
    [DemoCallManager sharedManager];
}

#pragma mark - EMCallManagerDelegate

- (void)callDidReceive:(EMCallSession *)aSession {
    NSDictionary *map = @{
        @"type":@"connecting"
    };
    [self.channel invokeMethod:EMMethodKeyOnCallChanged
                     arguments:map];
}

- (void)callDidConnect:(EMCallSession *)aSession {
    NSDictionary *map = @{
        @"type":@"connected"
    };
    [self.channel invokeMethod:EMMethodKeyOnCallChanged
                     arguments:map];
}

- (void)callDidAccept:(EMCallSession *)aSession {
    NSDictionary *map = @{
        @"type":@"accepted"
    };
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
    NSDictionary *map = @{
        @"type":type
    };
    [self.channel invokeMethod:EMMethodKeyOnCallChanged
                     arguments:map];
}

- (void)callNetworkDidChange:(EMCallSession *)aSession
                      status:(EMCallNetworkStatus)aStatus {
    NSString *type;
    if (aStatus == EMCallNetworkStatusNormal) {
        type = @"netWorkNormal";
    } else if (aStatus == EMCallNetworkStatusUnstable) {
        type = @"networkUnstable";
    } else {
        type = @"netWorkDisconnected";
    }
    
    NSDictionary *map = @{
        @"type":type
    };
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
