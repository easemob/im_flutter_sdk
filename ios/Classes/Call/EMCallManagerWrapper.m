//
//  EMCallManagerWrapper.m
//  device_info
//
//  Created by easemob-DN0164 on 2020/1/14.
//

#import "EMCallManagerWrapper.h"
#import "EMSDKMethod.h"
#import "EMHelper.h"
#import "EMCallOptions+Flutter.h"
#import "EMCallSession+Flutter.h"
#import "EMError+Flutter.h"
#import "EMFlutterRenderViewFactory.h"

@interface EMCallManagerWrapper () <EMCallManagerDelegate>
{
    NSMutableDictionary *_sessionDict;
    EMFlutterRenderViewFactory *_factory;
}
@property (nonatomic, strong) EMCallSession *callSession;
@property (nonatomic, strong) FlutterMethodChannel *callSessionChannel;
@end

@implementation EMCallManagerWrapper
- (instancetype)initWithChannelName:(NSString *)aChannelName
                          registrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    if(self = [super initWithChannelName:aChannelName
                           registrar:registrar]) {
        [EMClient.sharedClient.callManager addDelegate:self delegateQueue:nil];
        _factory = [[EMFlutterRenderViewFactory alloc] initWithMessenger:registrar.messenger];
        [registrar registerViewFactory:_factory withId:@"com.easemob.rtc/CallView"];
        
        FlutterJSONMethodCodec *codec = [FlutterJSONMethodCodec sharedInstance];
        self.callSessionChannel = [FlutterMethodChannel methodChannelWithName:@"com.easemob.im/em_call_session"
                                                              binaryMessenger:[registrar messenger]
                                                                    codec:codec];
        _sessionDict = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - FlutterPlugin

- (void)handleMethodCall:(FlutterMethodCall*)call
                  result:(FlutterResult)result {
    if ([EMMethodKeySetCallOptions isEqualToString:call.method]) {
        [self setCallOptions:call.arguments channelName:EMMethodKeySetCallOptions result:result];
    } else if ([EMMethodKeyGetCallOptions isEqualToString:call.method]) {
        [self getCallOptions:call.arguments channelName:EMMethodKeyGetCallOptions result:result];
    } else if ([EMMethodKeyStartCall isEqualToString:call.method]) {
        [self startCall:call.arguments channelName:EMMethodKeyStartCall result:result];
    } else if ([EMMethodKeyAnswerComingCall isEqualToString:call.method]) {
        [self answerIncomingCall:call.arguments channelName:EMMethodKeyAnswerComingCall result:result];
    } else if ([EMMethodKeyEndCall isEqualToString:call.method]) {
        [self endCall:call.arguments channelName:EMMethodKeyEndCall result:result];
    } else if ([EMMethodKeyCallSessionPauseVoice isEqualToString:call.method]) {
        [self pauseVoice:call.arguments channelName:EMMethodKeyCallSessionPauseVoice result:result];
    } else if ([EMMethodKeyCallSessionPauseVideo isEqualToString:call.method]) {
        [self pauseVideo:call.arguments channelName:EMMethodKeyCallSessionPauseVideo result:result];
    } else if ([EMMethodKeyCallSessionSwitchCameraPosition isEqualToString:call.method]) {
        [self switchCameraPosition:call.arguments channelName:EMMethodKeyCallSessionSwitchCameraPosition result:result];
    } else if ([EMMethodKeyCallSessionSetLocalView isEqualToString:call.method]) {
        [self setLocalView:call.arguments channelName:EMMethodKeyCallSessionSetLocalView result:result];
    } else if ([EMMethodKeyCallSessionSetRemoteView isEqualToString:call.method]) {
        [self setRemoteView:call.arguments channelName:EMMethodKeyCallSessionSetRemoteView result:result];
    } else if ([EMMethodKeyReleaseView isEqualToString:call.method]) {
        [self releaseVideoView:call.arguments channelName:EMMethodKeyReleaseView result:result];
    } else {
        [super handleMethodCall:call result:result];
    }
}

#pragma mark - Actions
- (void)getCallOptions:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result
{
    __weak typeof(self) weakSelf = self;
    EMCallOptions *options = [EMClient.sharedClient.callManager getCallOptions];
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:[options toJson]];
}

- (void)setCallOptions:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result
{
    __weak typeof(self) weakSelf = self;
    EMCallOptions *options = [EMCallOptions fromJson:param];
    [EMClient.sharedClient.callManager setCallOptions:options];
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:@(YES)];
}

- (void)startCall:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result
{
    __weak typeof(self) weakSelf = self;
    EMCallType callType = [param[@"type"] intValue];
    NSString *remoteName = param[@"remote"];
    BOOL isRecord = [param[@"record"] boolValue];
    BOOL isMerge = [param[@"merge"] boolValue];
    NSString *ext = param[@"ext"];
    
    [EMClient.sharedClient.callManager startCall:callType
                                      remoteName:remoteName
                                          record:isRecord
                                     mergeStream:isMerge
                                             ext:ext
                                      completion:^(EMCallSession *aCallSession, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[aCallSession toJson]];
    }];
}


- (void)answerIncomingCall:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result
{
    __weak typeof(self) weakSelf = self;
    NSString *callId = param[@"callId"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *aError = [EMClient.sharedClient.callManager answerIncomingCall:callId];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf wrapperCallBack:result
                          channelName:aChannelName
                                error:aError
                               object:@(!aError)];
        });
    });
}

- (void)endCall:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result
{
    __weak typeof(self) weakSelf = self;
    NSString *callId = param[@"callId"];
    EMCallEndReason reason = [param[@"reason"] intValue];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *aError = [EMClient.sharedClient.callManager endCall:callId reason:reason];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf wrapperCallBack:result
                          channelName:aChannelName
                                error:aError
                               object:@(!aError)];
        });
    });
}

- (void)pauseVoice:(NSDictionary *)param
       channelName:(NSString *)aChannelName
            result:(FlutterResult)result
{
    __weak typeof(self) weakSelf = self;
    NSString *callId = param[@"callId"];
    BOOL pauseVoice = [param[@"pause"] boolValue];
    
    EMError *aError = nil;
    EMCallSession *session = _sessionDict[callId];
    if (pauseVoice) {
        aError = [session pauseVoice];
    }else {
        aError = [session resumeVoice];
    }
    
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:aError
                       object:@(!aError)];

}

- (void)pauseVideo:(NSDictionary *)param
       channelName:(NSString *)aChannelName
            result:(FlutterResult)result
{
    __weak typeof(self) weakSelf = self;
    NSString *callId = param[@"callId"];
    BOOL pauseVoice = [param[@"pause"] boolValue];

    EMError *aError = nil;
    EMCallSession *session = _sessionDict[callId];
    if (pauseVoice) {
        aError = [session pauseVideo];
    }else {
        aError = [session resumeVideo];
    }
    
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:aError
                       object:@(!aError)];
}

- (void)switchCameraPosition:(NSDictionary *)param
                 channelName:(NSString *)aChannelName
                      result:(FlutterResult)result
{
    __weak typeof(self) weakSelf = self;
    NSString *callId = param[@"callId"];
    BOOL isFront = [param[@"isFront"] intValue];
    
    EMCallSession *session = _sessionDict[callId];
    [session switchCameraPosition:isFront];
    
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:@(YES)];
}

- (void)setLocalView:(NSDictionary *)param
         channelName:(NSString *)aChannelName
              result:(FlutterResult)result
{
    __weak typeof(self) weakSelf = self;
    NSString *callId = param[@"callId"];
    int viewId = [param[@"viewId"] intValue];
    int type = [param[@"type"] intValue];
    EMCallSession *session = _sessionDict[callId];
    EMFlutterRenderView *renderView = [_factory getViewWithId:viewId andType:type];
    session.localVideoView = (EMCallLocalVideoView *)renderView.previewView;
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:@(YES)];
}

- (void)setRemoteView:(NSDictionary *)param
          channelName:(NSString *)aChannelName
               result:(FlutterResult)result
{
    __weak typeof(self) weakSelf = self;
    NSString *callId = param[@"callId"];
    int viewId = [param[@"viewId"] intValue];
    int type = [param[@"type"] intValue];
    EMCallSession *session = _sessionDict[callId];
    EMFlutterRenderView *renderView = [_factory getViewWithId:viewId andType:type];
    session.remoteVideoView = (EMCallRemoteVideoView *)renderView.previewView;
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:@(YES)];
}

- (void)releaseVideoView:(NSDictionary *)param
             channelName:(NSString *)aChannelName
                  result:(FlutterResult)result{
    __weak typeof(self) weakSelf = self;
    int viewId = [param[@"viewId"] intValue];
    [_factory releaseVideoView:viewId];
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:@(YES)];
}

#pragma mark - EMCallManagerDelegate

- (void)callDidReceive:(EMCallSession *)aSession {
    [self.channel invokeMethod:EMMethodKeyOnCallReceived
                     arguments:@{@"callSession": [aSession toJson]}];
    _sessionDict[aSession.callId] = aSession;
}

- (void)callDidEnd:(EMCallSession *)aSession
            reason:(EMCallEndReason)aReason
             error:(EMError *)aError {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (aSession) {
        dict[@"callSession"] = [aSession toJson];
    }
    
    if (aReason) {
        dict[@"reason"] = @(aReason);
    }
    
    if (aError) {
        dict[@"error"] = [aError toJson];
    }
    
    [self.channel invokeMethod:EMMethodKeyOnCallDidEnd
                     arguments:dict];
    
    [_sessionDict removeObjectForKey:aSession.callId];
}

- (void)callDidAccept:(EMCallSession *)aSession {
    [self.callSessionChannel invokeMethod:EMMethodKeyOnCallDidAccept
                                arguments:@{@"callId": (aSession.callId ?: @"")}];
}

- (void)callDidConnect:(EMCallSession *)aSession {
    [self.callSessionChannel invokeMethod:EMMethodKeyOnDidConnected
                                arguments:@{@"callId": (aSession.callId ?: @"")}];
}

- (void)callStateDidChange:(EMCallSession *)aSession
                      type:(EMCallStreamingStatus)aType {
    [self.callSessionChannel invokeMethod:EMMethodKeyOnCallStateDidChange
                                arguments:@{
                                    @"callId": (aSession.callId ?: @""),
                                    @"status": @(aType)
                                }];
}

- (void)callNetworkDidChange:(EMCallSession *)aSession
                      status:(EMCallNetworkStatus)aStatus {
    [self.callSessionChannel invokeMethod:EMMethodKeyOnCallNetworkDidChange
                                arguments:@{
                                    @"callId": (aSession.callId ?: @""),
                                    @"status": @(aStatus)
                                }];
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
