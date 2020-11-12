//
//  EMConferenceManagerWrapper.m
//  im_flutter_sdk
//
//  Created by easemob-DN0164 on 2020/4/27.
//

#import "EMConferenceManagerWrapper.h"
#import "EMSDKMethod.h"
#import "EMCallConference+Flutter.h"
#import "EMStreamParam+Flutter.h"
#import "EMFlutterRenderViewFactory.h"

@interface EMConferenceManagerWrapper ()<EMConferenceManagerDelegate> {
    EMFlutterRenderViewFactory *_factory;
}
@property (nonatomic, strong) NSMutableDictionary *conferenceDict;
@end

@implementation EMConferenceManagerWrapper

- (instancetype)initWithChannelName:(NSString *)aChannelName
                          registrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    if(self = [super initWithChannelName:aChannelName
                               registrar:registrar]) {
        [EMClient.sharedClient.conferenceManager addDelegate:self delegateQueue:nil];
        _factory = [EMFlutterRenderViewFactory factoryWithRegistrar:registrar withId:@"com.easemob.rtc/CallView"];
    }
    return self;
}

#pragma mark - FlutterPlugin

- (void)handleMethodCall:(FlutterMethodCall*)call
                  result:(FlutterResult)result {
    if ([EMMethodKeySetConferenceAppKey isEqualToString:call.method]) {
        [self setConferenceAppKey:call.arguments channelName:EMMethodKeySetConferenceAppKey result:result];
    }
    else if ([EMMethodKeyConferenceHasExists isEqualToString:call.method]) {
        [self conferenceHasExists:call.arguments channelName:EMMethodKeyConferenceHasExists result:result];
    }
    else if ([EMMethodKeyJoinConference isEqualToString:call.method]) {
        [self joinConference:call.arguments channelName:EMMethodKeyJoinConference result:result];
    }
    else if ([EMMethodKeyJoinRoom isEqualToString:call.method]) {
        [self joinRoom:call.arguments channelName:EMMethodKeyJoinRoom result:result];
    }
    else if ([EMMethodKeyCreateWhiteboardRoom isEqualToString:call.method]) {
        [self createWhiteboardRoom:call.arguments channelName:EMMethodKeyCreateWhiteboardRoom result:result];
    }
    else if ([EMMethodKeyDestroyWhiteboardRoom isEqualToString:call.method]) {
        [self destroyWhiteboardRoom:call.arguments channelName:EMMethodKeyDestroyWhiteboardRoom result:result];
    }
    else if ([EMMethodKeyJoinWhiteboardRoom isEqualToString:call.method]) {
        [self joinWhiteboardRoom:call.arguments channelName:EMMethodKeyJoinWhiteboardRoom result:result];
    }
    else if ([EMMethodKeyPublishConference isEqualToString:call.method]) {
        [self publishConference:call.arguments channelName:EMMethodKeyPublishConference result:result];
    }
    else if ([EMMethodKeyUnPublishConference isEqualToString:call.method]) {
        [self unPublishConference:call.arguments channelName:EMMethodKeyUnPublishConference result:result];
    }
    else if ([EMMethodKeySubscribeConference isEqualToString:call.method]) {
        [self subscribeConference:call.arguments channelName:EMMethodKeySubscribeConference result:result];
    }
    else if ([EMMethodKeyUnSubscribeConference isEqualToString:call.method]) {
        [self unSubscribeConference:call.arguments channelName:EMMethodKeyUnSubscribeConference result:result];
    }
    else if ([EMMethodKeyChangeMemberRoleWithMemberName isEqualToString:call.method]) {
        [self changeMemberRoleWithMemberName:call.arguments channelName:EMMethodKeyChangeMemberRoleWithMemberName result:result];
    }
    else if ([EMMethodKeyKickConferenceMember isEqualToString:call.method]) {
        [self kickConferenceMember:call.arguments channelName:EMMethodKeyKickConferenceMember result:result];
    }
    else if ([EMMethodKeyDestroyConference isEqualToString:call.method]) {
        [self destroyConference:call.arguments channelName:EMMethodKeyDestroyConference result:result];
    }
    else if ([EMMethodKeyLeaveConference isEqualToString:call.method]) {
        [self leaveConference:call.arguments channelName:EMMethodKeyLeaveConference result:result];
    }
    else if ([EMMethodKeyStartMonitorSpeaker isEqualToString:call.method]) {
        [self startMonitorSpeaker:call.arguments channelName:EMMethodKeyStartMonitorSpeaker result:result];
    }
    else if ([EMMethodKeyStopMonitorSpeaker isEqualToString:call.method]) {
        [self stopMonitorSpeaker:call.arguments channelName:EMMethodKeyStopMonitorSpeaker result:result];
    }
    else if ([EMMethodKeyRequestTobeConferenceSpeaker isEqualToString:call.method]) {
        [self requestTobeConferenceSpeaker:call.arguments channelName:EMMethodKeyRequestTobeConferenceSpeaker result:result];
    }
    else if ([EMMethodKeyRequestTobeConferenceAdmin isEqualToString:call.method]) {
        [self requestTobeConferenceAdmin:call.arguments channelName:EMMethodKeyRequestTobeConferenceAdmin result:result];
    }
    else if ([EMMethodKeyMuteConferenceMember isEqualToString:call.method]) {
        [self muteConferenceMember:call.arguments channelName:EMMethodKeyMuteConferenceMember result:result];
    }
    else if ([EMMethodKeyResponseReqSpeaker isEqualToString:call.method]) {
        [self responseReqSpeaker:call.arguments channelName:EMMethodKeyResponseReqSpeaker result:result];
    }
    else if ([EMMethodKeyResponseReqAdmin isEqualToString:call.method]) {
        [self responseReqAdmin:call.arguments channelName:EMMethodKeyResponseReqAdmin result:result];
    }
    else if ([EMMethodKeyUpdateConferenceWithSwitchCamera isEqualToString:call.method]) {
        [self updateConferenceWithSwitchCamera:call.arguments channelName:EMMethodKeyUpdateConferenceWithSwitchCamera result:result];
    }
    else if ([EMMethodKeyUpdateConferenceMute isEqualToString:call.method]) {
        [self updateConferenceMute:call.arguments channelName:EMMethodKeyUpdateConferenceMute result:result];
    }
    else if ([EMMethodKeyUpdateConferenceVideo isEqualToString:call.method]) {
        [self updateConferenceVideo:call.arguments channelName:EMMethodKeyUpdateConferenceVideo result:result];
    }
    else if ([EMMethodKeyUpdateRemoteView isEqualToString:call.method]) {
        [self updateRemoteView:call.arguments channelName:EMMethodKeyUpdateRemoteView result:result];
    }
    else if ([EMMethodKeyUpdateMaxVideoKbps isEqualToString:call.method]) {
        [self updateMaxVideoKbps:call.arguments channelName:EMMethodKeyUpdateMaxVideoKbps result:result];
    }
    else if ([EMMethodKeySetConferenceAttribute isEqualToString:call.method]) {
        [self setConferenceAttribute:call.arguments channelName:EMMethodKeySetConferenceAttribute result:result];
    }
    else if ([EMMethodKeyDeleteAttributeWithKey isEqualToString:call.method]) {
        [self deleteAttributeWithKey:call.arguments channelName:EMMethodKeyDeleteAttributeWithKey result:result];
    }
    else if ([EMMethodKeyMuteConferenceRemoteAudio isEqualToString:call.method]) {
        [self muteConferenceRemoteAudio:call.arguments channelName:EMMethodKeyMuteConferenceRemoteAudio result:result];
    }
    else if ([EMMethodKeyMuteConferenceRemoteVideo isEqualToString:call.method]) {
        [self muteConferenceRemoteVideo:call.arguments channelName:EMMethodKeyMuteConferenceRemoteVideo result:result];
    }
    else if ([EMMethodKeyMuteConferenceAll isEqualToString:call.method]) {
        [self muteConferenceAll:call.arguments channelName:EMMethodKeyMuteConferenceAll result:result];
    }
    else if ([EMMethodKeyAddVideoWatermark isEqualToString:call.method]) {
        [self addVideoWatermark:call.arguments channelName:EMMethodKeyAddVideoWatermark result:result];
    }
    else if ([EMMethodKeyClearVideoWatermark isEqualToString:call.method]) {
        [self clearVideoWatermark:call.arguments channelName:EMMethodKeyClearVideoWatermark result:result];
    }
    else {
        [super handleMethodCall:call result:result];
    }
}

- (void)setConferenceAppKey:(NSDictionary *)param
                channelName:(NSString *)aChannelName
                     result:(FlutterResult)result
{
    __weak typeof(self)weakSelf = self;
        
    NSString *appKey = param[@"appKey"];
    NSString *username = param[@"username"];
    NSString *token = param[@"token"];
    
    [EMClient.sharedClient.conferenceManager setAppkey:appKey username:username token:token];
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:@(YES)];
}


- (void)conferenceHasExists:(NSDictionary *)param
                channelName:(NSString *)aChannelName
                     result:(FlutterResult)result
{
    __weak typeof(self)weakSelf = self;
    
    NSString *conferenceId = param[@"conf_id"];
    NSString *password = param[@"pwd"];
    
    [EMClient.sharedClient.conferenceManager getConference:conferenceId
                                                  password:password
                                                completion:^(EMCallConference *aCall, EMError *aError) {
        
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:@((aCall != nil))];
    }];
}

- (void)joinConference:(NSDictionary *)param
           channelName:(NSString *)aChannelName
                result:(FlutterResult)result
{
    __weak typeof(self)weakSelf = self;
    
    NSString *conferenceId = param[@"conf_id"];
    NSString *password = param[@"pwd"];
    
    [EMClient.sharedClient.conferenceManager joinConferenceWithConfId:conferenceId
                                                             password:password
                                                           completion:^(EMCallConference *aCall, EMError *aError)
    {
        if (!aError && aCall) {
            weakSelf.conferenceDict[aCall.confId] = aCall;
        }
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[aCall toJson]];
    }];
}

- (void)joinRoom:(NSDictionary *)param
     channelName:(NSString *)aChannelName
          result:(FlutterResult)result
{
    __weak typeof(self)weakSelf = self;
    
    NSString *roomName = param[@"roomName"];
    NSString *password = param[@"pwd"];
    EMConferenceRole role = [param[@"role"] intValue];
    
    [EMClient.sharedClient.conferenceManager joinRoom:roomName
                                             password:password
                                                 role:role
                                           completion:^(EMCallConference *aCall, EMError *aError)
    {
        if (!aError && aCall) {
            weakSelf.conferenceDict[aCall.confId] = aCall;
        }
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[aCall toJson]];
    }];
}

- (void)createWhiteboardRoom:(NSDictionary *)param
                 channelName:(NSString *)aChannelName
                      result:(FlutterResult)result
{
    __weak typeof(self)weakSelf = self;
    
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:nil];
}

- (void)destroyWhiteboardRoom:(NSDictionary *)param
                  channelName:(NSString *)aChannelName
                       result:(FlutterResult)result
{
    __weak typeof(self)weakSelf = self;
    
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:nil];
}

- (void)joinWhiteboardRoom:(NSDictionary *)param
               channelName:(NSString *)aChannelName
                    result:(FlutterResult)result
{
    __weak typeof(self)weakSelf = self;
    
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:nil];
}

- (void)publishConference:(NSDictionary *)param
              channelName:(NSString *)aChannelName
                   result:(FlutterResult)result
{
//    __weak typeof(self)weakSelf = self;
//    NSString *confereceId = param[@"conference_id"];
//    EMCallConference *conf = self.conferenceDict[confereceId];
//    EMStreamParam *steamParam = [EMStreamParam fromJson:param[@"stream"]];
//    int type = [param[@"type"] intValue];
//    int viewId = [param[@"view_id"] intValue];
//    EMFlutterRenderView *renderView = [_factory getViewWithId:viewId andType:type];
//    steamParam.localView = (EMCallLocalVideoView *)renderView.previewView;
//    [EMClient.sharedClient.conferenceManager publishConference:conf
//                                                   streamParam:steamParam
//                                                    completion:^(NSString *aPubStreamId, EMError *aError)
//     {
//        [weakSelf wrapperCallBack:result
//                      channelName:aChannelName
//                            error:aError
//                           object:aPubStreamId];
//    }];
    
}

- (void)unPublishConference:(NSDictionary *)param
                channelName:(NSString *)aChannelName
                     result:(FlutterResult)result
{
    __weak typeof(self)weakSelf = self;
    NSString *confereceId = param[@"conference_id"];
    NSString *streamId = param[@"stream_id"];
    EMCallConference *conf = self.conferenceDict[confereceId];
    [EMClient.sharedClient.conferenceManager unpublishConference:conf streamId:streamId completion:^(EMError *aError) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:@(!aError)];
    }];
}

- (void)subscribeConference:(NSDictionary *)param
                channelName:(NSString *)aChannelName
                     result:(FlutterResult)result
{
//    __weak typeof(self)weakSelf = self;
//    
//    NSString *confereceId = param[@"conference_id"];
//    EMCallConference *conf = self.conferenceDict[confereceId];
//    NSString *streamId = param[@"stream_id"];
//    int type = [param[@"type"] intValue];
//    int viewId = [param[@"view_id"] intValue];
//    EMFlutterRenderView *renderView = [_factory getViewWithId:viewId andType:type];
//    
//    [EMClient.sharedClient.conferenceManager subscribeConference:conf
//                                                        streamId:streamId
//                                                 remoteVideoView:(EMCallRemoteVideoView *)renderView.previewView completion:^(EMError *aError)
//    {
//        [weakSelf wrapperCallBack:result
//                      channelName:aChannelName
//                            error:aError
//                           object:@(!aError)];
//    }];
}

- (void)unSubscribeConference:(NSDictionary *)param
                  channelName:(NSString *)aChannelName
                       result:(FlutterResult)result
{
    __weak typeof(self)weakSelf = self;
    
    NSString *confereceId = param[@"conference_id"];
    EMCallConference *conf = self.conferenceDict[confereceId];
    NSString *streamId = param[@"stream_id"];
    
    [EMClient.sharedClient.conferenceManager unsubscribeConference:conf
                                                          streamId:streamId
                                                        completion:^(EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:@(!aError)];
    }];
}

- (void)changeMemberRoleWithMemberName:(NSDictionary *)param
                           channelName:(NSString *)aChannelName
                                result:(FlutterResult)result
{
    __weak typeof(self)weakSelf = self;
    
    NSString *confereceId = param[@"conference_id"];
    EMCallConference *conf = self.conferenceDict[confereceId];
    NSString *memberName = param[@"memberName"];
    int role = [param[@"role"] intValue];
    
    [EMClient.sharedClient.conferenceManager changeMemberRoleWithConfId:conf.confId
                                                             memberName:memberName
                                                                   role:role
                                                             completion:^(EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:@(!aError)];
    }];
}

- (void)kickConferenceMember:(NSDictionary *)param
                 channelName:(NSString *)aChannelName
                      result:(FlutterResult)result
{
    __weak typeof(self)weakSelf = self;
    
    NSString *confereceId = param[@"conference_id"];
    EMCallConference *conf = self.conferenceDict[confereceId];
    
    NSArray *memberNames = param[@"memberNames"];
    
    [EMClient.sharedClient.conferenceManager kickMemberWithConfId:conf.confId
                                                      memberNames:memberNames
                                                       completion:^(EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:@(!aError)];
    }];
}

- (void)destroyConference:(NSDictionary *)param
              channelName:(NSString *)aChannelName
                   result:(FlutterResult)result
{
    __weak typeof(self)weakSelf = self;
    
    NSString *confereceId = param[@"conference_id"];
    EMCallConference *conf = self.conferenceDict[confereceId];
    
    [EMClient.sharedClient.conferenceManager destroyConferenceWithId:conf.confId
                                                          completion:^(EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:@(!aError)];
    }];
}

- (void)leaveConference:(NSDictionary *)param
            channelName:(NSString *)aChannelName
                 result:(FlutterResult)result
{
    __weak typeof(self)weakSelf = self;
    
    NSString *confereceId = param[@"conference_id"];
    EMCallConference *conf = self.conferenceDict[confereceId];
    
    [EMClient.sharedClient.conferenceManager leaveConference:conf
                                                  completion:^(EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:@(!aError)];
    }];
}

- (void)startMonitorSpeaker:(NSDictionary *)param
                channelName:(NSString *)aChannelName
                     result:(FlutterResult)result
{
    __weak typeof(self)weakSelf = self;
    
    NSString *confereceId = param[@"conference_id"];
    EMCallConference *conf = self.conferenceDict[confereceId];
    int time = [param[@"time"] intValue];
    
    [EMClient.sharedClient.conferenceManager startMonitorSpeaker:conf
                                                    timeInterval:time
                                                      completion:^(EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:@(!aError)];
    }];
}

- (void)stopMonitorSpeaker:(NSDictionary *)param
               channelName:(NSString *)aChannelName
                    result:(FlutterResult)result
{
    __weak typeof(self)weakSelf = self;
    
    NSString *confereceId = param[@"conference_id"];
    EMCallConference *conf = self.conferenceDict[confereceId];
    
    [EMClient.sharedClient.conferenceManager stopMonitorSpeaker:conf];
    
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:@(YES)];
}

- (void)requestTobeConferenceSpeaker:(NSDictionary *)param
                         channelName:(NSString *)aChannelName
                              result:(FlutterResult)result
{
    __weak typeof(self)weakSelf = self;
    
    NSString *confereceId = param[@"conference_id"];
    EMCallConference *conf = self.conferenceDict[confereceId];
    
    NSString *adminId = param[@"admin_id"];
    
    [EMClient.sharedClient.conferenceManager requestTobeSpeaker:conf
                                                        adminId:adminId
                                                     completion:^(EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:@(!aError)];
    }];
}

- (void)requestTobeConferenceAdmin:(NSDictionary *)param
                       channelName:(NSString *)aChannelName
                            result:(FlutterResult)result
{
    __weak typeof(self)weakSelf = self;
    
    NSString *confereceId = param[@"conference_id"];
    EMCallConference *conf = self.conferenceDict[confereceId];
    
    NSString *adminId = param[@"admin_id"];
    
    [EMClient.sharedClient.conferenceManager requestTobeAdmin:conf
                                                      adminId:adminId
                                                   completion:^(EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:@(!aError)];
    }];
}

- (void)muteConferenceMember:(NSDictionary *)param
                 channelName:(NSString *)aChannelName
                      result:(FlutterResult)result
{
    __weak typeof(self)weakSelf = self;
    
    NSString *confereceId = param[@"conference_id"];
    EMCallConference *conf = self.conferenceDict[confereceId];
    
    NSString *memberId = param[@"member_id"];
    BOOL isMute = [param[@"isMute"] boolValue];
    
    [EMClient.sharedClient.conferenceManager setMuteMember:conf
                                                     memId:memberId
                                                      mute:isMute
                                                completion:^(EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:@(!aError)];
    }];
}

- (void)responseReqSpeaker:(NSDictionary *)param
               channelName:(NSString *)aChannelName
                    result:(FlutterResult)result
{
    __weak typeof(self)weakSelf = self;
    
    NSString *confereceId = param[@"conference_id"];
    EMCallConference *conf = self.conferenceDict[confereceId];
    
    NSString *memberId = param[@"member_id"];
    BOOL agree = [param[@"agree"] boolValue];
    
    [EMClient.sharedClient.conferenceManager responseReqSpeaker:conf
                                                          memId:memberId
                                                         result:agree ? 0 : 1
                                                     completion:^(EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:@(!aError)];
    }];
}

- (void)responseReqAdmin:(NSDictionary *)param
             channelName:(NSString *)aChannelName
                  result:(FlutterResult)result
{
    __weak typeof(self)weakSelf = self;
    
    NSString *confereceId = param[@"conference_id"];
    EMCallConference *conf = self.conferenceDict[confereceId];
    
    NSString *memberId = param[@"member_id"];
    BOOL agree = [param[@"agree"] boolValue];
    
    [EMClient.sharedClient.conferenceManager responseReqAdmin:conf
                                                        memId:memberId
                                                       result:agree ? 0 : 1
                                                   completion:^(EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:@(!aError)];
    }];
}

- (void)updateConferenceWithSwitchCamera:(NSDictionary *)param
                             channelName:(NSString *)aChannelName
                                  result:(FlutterResult)result
{
    __weak typeof(self)weakSelf = self;
    
    NSString *confereceId = param[@"conference_id"];
    EMCallConference *conf = self.conferenceDict[confereceId];
    
    [EMClient.sharedClient.conferenceManager updateConferenceWithSwitchCamera:conf];
    
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:@(YES)];
}

- (void)updateConferenceMute:(NSDictionary *)param
                 channelName:(NSString *)aChannelName
                      result:(FlutterResult)result
{
    __weak typeof(self)weakSelf = self;
    
    NSString *confereceId = param[@"conference_id"];
    EMCallConference *conf = self.conferenceDict[confereceId];
    
    BOOL mute = [param[@"mute"] boolValue];
    
    [EMClient.sharedClient.conferenceManager updateConference:conf isMute:mute];
    
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:@(YES)];
}

- (void)updateConferenceVideo:(NSDictionary *)param
                  channelName:(NSString *)aChannelName
                       result:(FlutterResult)result
{
    __weak typeof(self)weakSelf = self;
    
    NSString *confereceId = param[@"conference_id"];
    EMCallConference *conf = self.conferenceDict[confereceId];
    
    BOOL enable = [param[@"enable"] boolValue];
    
    [EMClient.sharedClient.conferenceManager  updateConference:conf enableVideo:enable];
    
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:@(YES)];
}

// TODO:
- (void)updateRemoteView:(NSDictionary *)param
             channelName:(NSString *)aChannelName
                  result:(FlutterResult)result
{
    __weak typeof(self)weakSelf = self;
    
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:nil];
}

// TODO:
- (void)updateMaxVideoKbps:(NSDictionary *)param
               channelName:(NSString *)aChannelName
                    result:(FlutterResult)result
{
    __weak typeof(self)weakSelf = self;
    
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:nil];
}

- (void)setConferenceAttribute:(NSDictionary *)param
                   channelName:(NSString *)aChannelName
                        result:(FlutterResult)result
{
    __weak typeof(self)weakSelf = self;
    
//    NSString *confereceId = param[@"conference_id"];
//    EMCallConference *conf = self.conferenceDict[confereceId];
    
    NSString *key = param[@"key"];
    NSString *value = param[@"value"];
    
    [EMClient.sharedClient.conferenceManager setConferenceAttribute:key
                                                              value:value
                                                         completion:^(EMError *aError) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:@(!aError)];
    }];
}

- (void)deleteAttributeWithKey:(NSDictionary *)param
                   channelName:(NSString *)aChannelName
                        result:(FlutterResult)result
{
    __weak typeof(self)weakSelf = self;
    
    //    NSString *confereceId = param[@"conference_id"];
    //    EMCallConference *conf = self.conferenceDict[confereceId];
    
    NSString *key = param[@"key"];
    
    [EMClient.sharedClient.conferenceManager deleteAttributeWithKey:key
                                                         completion:^(EMError *aError) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:@(!aError)];
    }];
}

- (void)muteConferenceRemoteAudio:(NSDictionary *)param
                      channelName:(NSString *)aChannelName
                           result:(FlutterResult)result
{
    __weak typeof(self)weakSelf = self;
    
    NSString *steamId = param[@"steam_id"];
    BOOL isMute = [param[@"isMute"] boolValue];
    [EMClient.sharedClient.conferenceManager muteRemoteAudio:steamId mute:isMute];
    
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:@(YES)];
}

- (void)muteConferenceRemoteVideo:(NSDictionary *)param
                      channelName:(NSString *)aChannelName
                           result:(FlutterResult)result
{
    __weak typeof(self)weakSelf = self;
    
    NSString *steamId = param[@"steam_id"];
    BOOL isMute = [param[@"isMute"] boolValue];
    [EMClient.sharedClient.conferenceManager muteRemoteVideo:steamId mute:isMute];
    
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:@(YES)];
}

- (void)muteConferenceAll:(NSDictionary *)param
              channelName:(NSString *)aChannelName
                   result:(FlutterResult)result
{
    __weak typeof(self)weakSelf = self;
    
    BOOL isMute = [param[@"isMute"] boolValue];
    
    [EMClient.sharedClient.conferenceManager muteAll:isMute completion:^(EMError *aError) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:nil
                           object:@(YES)];
    }];
}

// TODO:
- (void)addVideoWatermark:(NSDictionary *)param
              channelName:(NSString *)aChannelName
                   result:(FlutterResult)result
{
    __weak typeof(self)weakSelf = self;
    
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:nil];
}

// TODO:
- (void)clearVideoWatermark:(NSDictionary *)param
                channelName:(NSString *)aChannelName
                     result:(FlutterResult)result
{
    __weak typeof(self)weakSelf = self;
    
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:nil];
}

- (NSMutableDictionary *)conferenceDict {
    if (!_conferenceDict) {
        _conferenceDict = [NSMutableDictionary dictionary];
    }
    return _conferenceDict;
}
@end
