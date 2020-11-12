//
//  EMCallManagerWrapper.m
//  device_info
//
//  Created by easemob-DN0164 on 2020/1/14.
//

#import "EMCallManagerWrapper.h"
#import "EMSDKMethod.h"
#import "EMCallOptions+Flutter.h"
#import "EMError+Flutter.h"
#import "EMFlutterRenderViewFactory.h"

@interface EMCallManagerWrapper () <EMCallManagerDelegate>
{
    EMFlutterRenderViewFactory *_factory;
    BOOL _isFront;
}
@property (nonatomic, strong) EMCallSession *callSession;
@end

@implementation EMCallManagerWrapper
- (instancetype)initWithChannelName:(NSString *)aChannelName
                          registrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    if(self = [super initWithChannelName:aChannelName
                           registrar:registrar]) {
        [EMClient.sharedClient.callManager addDelegate:self delegateQueue:nil];
        _factory = [EMFlutterRenderViewFactory factoryWithRegistrar:registrar withId:@"com.easemob.rtc/CallView"];
    }
    return self;
}

#pragma mark - FlutterPlugin

- (void)handleMethodCall:(FlutterMethodCall*)call
                  result:(FlutterResult)result {
    if ([EMMethodKeySetCallOptions isEqualToString:call.method])
    {
        [self setCallOptions:call.arguments channelName:EMMethodKeySetCallOptions result:result];
    }
    else if ([EMMethodKeyGetCallOptions isEqualToString:call.method])
    {
        [self getCallOptions:call.arguments channelName:EMMethodKeyGetCallOptions result:result];
    }
    else if ([EMMethodKeyMakeCall isEqualToString:call.method])
    {
        [self makeCall:call.arguments channelName:EMMethodKeyMakeCall result:result];
    }
    else if ([EMMethodKeyAnswerCall isEqualToString:call.method])
    {
        [self answerCall:call.arguments channelName:EMMethodKeyAnswerCall result:result];
    }
    else if ([EMMethodKeyRejectCall isEqualToString:call.method])
    {
        [self rejectCall:call.arguments channelName:EMMethodKeyRejectCall result:result];
    }
    else if ([EMMethodKeyEndCall isEqualToString:call.method])
    {
        [self endCall:call.arguments channelName:EMMethodKeyEndCall result:result];
    }
    else if ([EMMethodKeyEnableVoiceTransfer isEqualToString:call.method])
    {
        [self enableVoiceTransfer:call.arguments channelName:EMMethodKeyEnableVoiceTransfer result:result];
    }
    else if ([EMMethodKeyEnableVideoTransfer isEqualToString:call.method])
    {
        [self enableVideoTransfer:call.arguments channelName:EMMethodKeyEnableVideoTransfer result:result];
    }
    else if ([EMMethodKeyMuteRemoteAudio isEqualToString:call.method])
    {
        [self muteRemoteAudio:call.arguments channelName:EMMethodKeyMuteRemoteAudio result:result];
    }
    else if ([EMMethodKeyMuteRemoteVideo isEqualToString:call.method])
    {
        [self muteRemoteVideo:call.arguments channelName:EMMethodKeyMuteRemoteVideo result:result];
    }
    else if ([EMMethodKeySwitchCamera isEqualToString:call.method]) {
        [self switchCamera:call.arguments channelName:EMMethodKeySwitchCamera result:result];
    }
    else if ([EMMethodKeySetSurfaceView isEqualToString:call.method]){
        [self setSurfaceView:call.arguments channelName:EMMethodKeySetSurfaceView result:result];
    }
    else if ([EMMethodKeyReleaseView isEqualToString:call.method]){
        [self releaseView:call.arguments channelName:EMMethodKeyReleaseView result:result];
    }
    else
    {
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

- (void)makeCall:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result{
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
           weakSelf.callSession = aCallSession;
           [weakSelf wrapperCallBack:result
                         channelName:aChannelName
                               error:aError
                              object:@(!aError)];
       }];
}

- (void)answerCall:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result{
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            EMError *aError = [EMClient.sharedClient.callManager answerIncomingCall:[weakSelf currentCallId]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf wrapperCallBack:result
                              channelName:aChannelName
                                    error:aError
                                   object:@(!aError)];
            });
        });
}

- (void)rejectCall:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result{
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *aError = [EMClient.sharedClient.callManager endCall:[weakSelf currentCallId] reason:EMCallEndReasonDecline];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf wrapperCallBack:result
                          channelName:aChannelName
                                error:aError
                               object:@(!aError)];
        });
    });
}

- (void)endCall:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *aError = [EMClient.sharedClient.callManager endCall:[weakSelf currentCallId] reason:EMCallEndReasonHangup];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf wrapperCallBack:result
                          channelName:aChannelName
                                error:aError
                               object:@(!aError)];
        });
    });
}

- (void)enableVoiceTransfer:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result{
    BOOL enable = [param[@"enable"] boolValue];
    EMError *aError = nil;
    if (enable) {
        aError = [self.callSession pauseVoice];
    }else{
        aError = [self.callSession resumeVoice];
    }
    [self wrapperCallBack:result
              channelName:aChannelName
                    error:aError
                   object:@(!aError)];
    
}

- (void)enableVideoTransfer:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result{
    BOOL enable = [param[@"enable"] boolValue];
    EMError *aError = nil;
    if (enable) {
        aError = [self.callSession pauseVideo];
    }else{
        aError = [self.callSession resumeVideo];
    }
    [self wrapperCallBack:result
              channelName:aChannelName
                    error:aError
                   object:@(!aError)];
}

- (void)muteRemoteAudio:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result{
//    BOOL enable = [param[@"mute"] boolValue];
   
    [self wrapperCallBack:result
              channelName:aChannelName
                    error:[EMError errorWithDescription:@"unsupport" code:-1]
                   object:@(NO)];
}

- (void)muteRemoteVideo:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result{
//     BOOL enable = [param[@"mute"] boolValue];
    
     [self wrapperCallBack:result
               channelName:aChannelName
                     error:[EMError errorWithDescription:@"unsupport" code:-1]
                    object:@(NO)];
}

- (void)switchCamera:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result{
    _isFront = !_isFront;
    [self.callSession switchCameraPosition:_isFront];
    [self wrapperCallBack:result
              channelName:aChannelName
                    error:nil
                   object:@(YES)];
}

- (void)setSurfaceView:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result{
    __weak typeof(self) weakSelf = self;
    int viewId = [param[@"view_id"] intValue];
    int isLocal = [param[@"isLocal"] boolValue];
    
    if (isLocal) {
        EMFlutterRenderView *renderView = [_factory getLocalViewWithId:viewId];
        _callSession.localVideoView = (EMCallLocalVideoView *)renderView.previewView;
    }else {
        EMFlutterRenderView *renderView = [_factory getRemoteViewWithId:viewId];
        _callSession.remoteVideoView = (EMCallRemoteVideoView *)renderView.previewView;
    }
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:@(YES)];
}

- (void)releaseView:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result{
    int viewId = [param[@"view_id"] intValue];
    [_factory releaseVideoView:viewId];
}


#pragma mark - EMCallManagerDelegate

- (void)callDidReceive:(EMCallSession *)aSession {
    [self.channel invokeMethod:EMMethodKeyOnCallReceived
                     arguments:
     @{
         @"type":aSession.type == EMCallTypeVoice ? @0 : @1 ,
         @"from":aSession.remoteName
     }];
    self.callSession = aSession;
}


// 该方法不论是主动话短还是对方挂断都会回调，所以可以只依赖这个方法来清理sessionDict
- (void)callDidEnd:(EMCallSession *)aSession
            reason:(EMCallEndReason)aReason
             error:(EMError *)aError {
    self.callSession = nil;
    if (aReason == EMCallEndReasonBusy) {
        [self.channel invokeMethod:EMMethodKeyOnCallBusy arguments:nil];
    }
    else if (aReason == EMCallEndReasonDecline) {
        [self.channel invokeMethod:EMMethodKeyRejectCall arguments:nil];
    }
    else {
         [self.channel invokeMethod:EMMethodKeyOnCallHangup arguments:nil];
    }
}

- (void)callDidAccept:(EMCallSession *)aSession {
    [self.channel invokeMethod:EMMethodKeyOnCallAccepted arguments:nil];
}

- (void)callDidConnect:(EMCallSession *)aSession {
    
}

- (void)callStateDidChange:(EMCallSession *)aSession
                      type:(EMCallStreamingStatus)aType
{
    switch (aType) {
        case EMCallStreamStatusVoicePause:
        {
            [self.channel invokeMethod:EMMethodKeyOnCallVoicePause arguments:nil];
            return;
        }
        case EMCallStreamStatusVoiceResume:
        {
            [self.channel invokeMethod:EMMethodKeyOnCallVoiceResume arguments:nil];
            return;
        }
        case EMCallStreamStatusVideoPause:
        {
            [self.channel invokeMethod:EMMethodKeyOnCallVideoPause arguments:nil];
            return;
        }
        case EMCallStreamStatusVideoResume:
        {
            [self.channel invokeMethod:EMMethodKeyOnCallVideoResume arguments:nil];
            return;
        }
            
    }
}

- (void)callNetworkDidChange:(EMCallSession *)aSession
                      status:(EMCallNetworkStatus)aStatus
{
    if (aStatus == EMCallNetworkStatusNormal) {
        [self.channel invokeMethod:EMMethodKeyOnCallNetworkNormal arguments:nil];
    }
    
    if (aStatus == EMCallNetworkStatusUnstable) {
        [self.channel invokeMethod:EMMethodKeyOnCallNetworkUnStable arguments:nil];
    }
}

- (NSString *)currentCallId {
    NSString *callId = self.callSession.callId ?: nil;
    return callId;
}

@end
