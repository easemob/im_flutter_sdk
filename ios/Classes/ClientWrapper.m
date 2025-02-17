//
//  EMClientWrapper.m
//  
//
//  Created by 杜洁鹏 on 2019/10/8.
//

#import "ClientWrapper.h"
#import "MethodKeys.h"
#import "ChatManagerWrapper.h"
#import "ContactManagerWrapper.h"
#import "ConversationWrapper.h"
#import "GroupManagerWrapper.h"
#import "ChatroomManagerWrapper.h"
#import "PushManagerWrapper.h"
#import "DeviceConfigHelper.h"
#import "LoginExtensionInfoHelper.h"
#import "OptionsHelper.h"
#import "UserInfoManagerWrapper.h"
#import "PresenceManagerWrapper.h"
#import "ThreadManagerWrapper.h"
#import "MessageWrapper.h"
#import "ProgressManager.h"
#import "ListenerHandle.h"
#import "EnumTools.h"

@interface ClientWrapper () <EMClientDelegate, EMMultiDevicesDelegate, FlutterPlugin>
{
    ChatManagerWrapper *_chatManager;
    ContactManagerWrapper *_contactManager;
    ConversationWrapper *_conversationManager;
    GroupManagerWrapper *_groupManager;
    ChatroomManagerWrapper *_roomManager;
    PushManagerWrapper *_pushManager;
    UserInfoManagerWrapper *_userInfoManager;
    PresenceManagerWrapper *_presenceManager;
    ThreadManagerWrapper *_threadManager;
    MessageWrapper *_msgWrapper;
    ProgressManager *_progressManager;
}
@end

@implementation ClientWrapper {
    EMOptions *_options;
}



- (void)sendDataToFlutter:(NSDictionary *)aData {
    if (aData == nil) {
        return;
    }
    [self.channel invokeMethod:ChatSendDataToFlutter
                     arguments:aData];
}


- (instancetype)initWithChannelName:(NSString *)aChannelName
                          registrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    if(self = [super initWithChannelName:aChannelName
                               registrar:registrar]) {
        
    }
    return self;
}

#pragma mark - FlutterPlugin

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([ChatInit isEqualToString:call.method])
    {
        [self initSDKWithDict:call.arguments
                  channelName:call.method
                       result:result];
    }
    else if ([ChatCreateAccount isEqualToString:call.method])
    {
        [self createAccount:call.arguments
                channelName:call.method
                     result:result];
    }
    else if ([ChatLogin isEqualToString:call.method])
    {
        [self login:call.arguments
        channelName:call.method
             result:result];
    }
    else if ([ChatLogout isEqualToString:call.method])
    {
        [self logout:call.arguments
         channelName:call.method
              result:result];
    }
    else if ([ChatChangeAppKey isEqualToString:call.method])
    {
        [self changeAppKey:call.arguments
               channelName:call.method
                    result:result];
    }
    else if ([ChatUploadLog isEqualToString:call.method])
    {
        [self uploadLog:call.arguments
            channelName:call.method
                 result:result];
    }
    else if ([ChatCompressLogs isEqualToString:call.method])
    {
        [self compressLogs:call.arguments
               channelName:call.method
                    result:result];
    }
    else if ([ChatGetLoggedInDevicesFromServer isEqualToString:call.method])
    {
        [self getLoggedInDevicesFromServer:call.arguments
                               channelName:call.method
                                    result:result];
    }
    else if ([ChatKickDevice isEqualToString:call.method])
    {
        [self kickDevice:call.arguments
             channelName:call.method
                  result:result];
    }
    else if ([ChatKickAllDevices isEqualToString:call.method])
    {
        [self kickAllDevices:call.arguments
                 channelName:call.method
                      result:result];
    }
    else if([ChatIsLoggedInBefore isEqualToString:call.method])
    {
        [self isLoggedInBefore:call.arguments
                   channelName:call.method
                        result:result];
    }
    else if([ChatGetCurrentUser isEqualToString:call.method])
    {
        [self getCurrentUser:call.arguments
                 channelName:call.method
                      result:result];
    }
    else if([ChatGetToken isEqualToString:call.method])
    {
        [self getToken:call.arguments
           channelName:call.method
                result:result];
    }
    else if ([ChatLoginWithAgoraToken isEqualToString:call.method])
    {
        [self loginWithAgoraToken:call.arguments channelName:call.method result:result];
    }
    else if([ChatIsConnected isEqualToString:call.method])
    {
        [self isConnected:call.arguments
              channelName:call.method
                   result:result];
    }
    else if ([ChatRenewToken isEqualToString:call.method]){
        [self renewToken:call.arguments
             channelName:call.method
                  result:result];
    }else if ([ChatStartCallback isEqualToString:call.method]){
        [self startCallBack:call.arguments
                channelName:call.method
                     result:result];
    }
    // 481
    else if ([ChatUpdateUsingHttpsOnlySetting isEqualToString:call.method]){
        [self updateUsingHttpsOnlySetting:call.arguments
                              channelName:call.method
                                   result:result];
    }
    else if ([ChatUpdateLoginExtensionInfo isEqualToString:call.method]){
        [self updateLoginExtensionInfo:call.arguments
                           channelName:call.method
                                result:result];
    }
    else if ([ChatUpdateDeleteMessagesWhenLeaveGroupSetting isEqualToString:call.method]){
        [self updateDeleteMessagesWhenLeaveGroupSetting:call.arguments
                                            channelName:call.method
                                                 result:result];
    }
    else if ([ChatUpdateDeleteMessageWhenLeaveRoomSetting isEqualToString:call.method]){
        [self updateDeleteMessageWhenLeaveRoomSetting:call.arguments
                                          channelName:call.method
                                               result:result];
    }
    else if ([ChatUpdateRoomOwnerCanLeaveSetting isEqualToString:call.method]){
        [self updateRoomOwnerCanLeaveSetting:call.arguments
                                 channelName:call.method
                                      result:result];
    }
    else if ([ChatUpdateAutoAcceptGroupInvitationSetting isEqualToString:call.method]){
        [self updateAutoAcceptGroupInvitationSetting:call.arguments
                                         channelName:call.method
                                              result:result];
    }
    else if ([ChatUpdateAcceptInvitationAlways isEqualToString:call.method]){
        [self updateAcceptInvitationAlways:call.arguments
                               channelName:call.method
                                    result:result];
    }
    else if ([ChatUpdateAutoDownloadAttachmentThumbnailSetting isEqualToString:call.method]){
        [self updateAutoDownloadAttachmentThumbnailSetting:call.arguments
                                               channelName:call.method
                                                    result:result];
    }
    else if ([ChatUpdateRequireAckSetting isEqualToString:call.method]){
        [self updateRequireAckSetting:call.arguments
                          channelName:call.method
                               result:result];
    }
    else if ([ChatUpdateDeliveryAckSetting isEqualToString:call.method]){
        [self updateDeliveryAckSetting:call.arguments
                           channelName:call.method
                                result:result];
    }
    else if ([ChatUpdateSortMessageByServerTimeSetting isEqualToString:call.method]){
        [self updateSortMessageByServerTimeSetting:call.arguments
                                       channelName:call.method
                                            result:result];
    }
    else if ([ChatUpdateMessagesReceiveCallbackIncludeSendSetting isEqualToString:call.method]){
        [self updateMessagesReceiveCallbackIncludeSendSetting:call.arguments
                                                  channelName:call.method
                                                       result:result];
    }
    else if ([ChatUpdateRegradeMessagesSetting isEqualToString:call.method]){
        [self updateRegradeMessagesSetting:call.arguments
                               channelName:call.method
                                    result:result];
    }
    else if ([changeAppId isEqual:call.method]) {
        [self changeAppId:call.arguments
              channelName:call.method
                   result:result];
    }
    
    else {
        [super handleMethodCall:call result:result];
    }
}


#pragma mark - Actions
- (void)initSDKWithDict:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    
    if(_options) {
        [weakSelf wrapperCallBack:result
                      channelName:ChatInit
                            error:nil
                           object:nil];
        return;
    }
    
    _options = [EMOptions fromJson:param];

    [EMClient.sharedClient initializeSDKWithOptions:_options];

    [self registerManagers];
    [weakSelf wrapperCallBack:result
                  channelName:ChatInit
                        error:nil
                       object:nil];
}


- (void)registerManagers {
    [self clearAllListener];
    [EMClient.sharedClient addDelegate:self delegateQueue:nil];
    [EMClient.sharedClient addMultiDevicesDelegate:self delegateQueue:nil];
    _chatManager = [[ChatManagerWrapper alloc] initWithChannelName:EMChannelName(@"chat_manager")registrar:self.flutterPluginRegister];
    _contactManager = [[ContactManagerWrapper alloc] initWithChannelName:EMChannelName(@"chat_contact_manager") registrar:self.flutterPluginRegister];
    _conversationManager = [[ConversationWrapper alloc] initWithChannelName:EMChannelName(@"chat_conversation") registrar:self.flutterPluginRegister];
    _groupManager = [[GroupManagerWrapper alloc] initWithChannelName:EMChannelName(@"chat_group_manager") registrar:self.flutterPluginRegister];
    _groupManager.clientWrapper = self;
    _roomManager =[[ChatroomManagerWrapper alloc] initWithChannelName:EMChannelName(@"chat_room_manager") registrar:self.flutterPluginRegister];
    _pushManager =[[PushManagerWrapper alloc] initWithChannelName:EMChannelName(@"chat_push_manager") registrar:self.flutterPluginRegister];
    _userInfoManager = [[UserInfoManagerWrapper alloc] initWithChannelName:EMChannelName(@"chat_userInfo_manager") registrar:self.flutterPluginRegister];
    _presenceManager = [[PresenceManagerWrapper alloc] initWithChannelName:EMChannelName(@"chat_presence_manager") registrar:self.flutterPluginRegister];
    _threadManager = [[ThreadManagerWrapper alloc] initWithChannelName:EMChannelName(@"chat_thread_manager") registrar:self.flutterPluginRegister];

    _msgWrapper = [[MessageWrapper alloc] initWithChannelName:EMChannelName(@"chat_message") registrar:self.flutterPluginRegister];
    
    _progressManager = [[ProgressManager alloc] initWithChannelName:EMChannelName(@"file_progress_manager")  registrar:self.flutterPluginRegister];
}

- (void)clearAllListener {
    [_chatManager unRegisterEaseListener];
    [_contactManager unRegisterEaseListener];
    [_conversationManager unRegisterEaseListener];
    [_groupManager unRegisterEaseListener];
    [_roomManager unRegisterEaseListener];
    [_userInfoManager unRegisterEaseListener];
    [_presenceManager unRegisterEaseListener];
    [_threadManager unRegisterEaseListener];
    [_msgWrapper unRegisterEaseListener];
    [super unRegisterEaseListener];
    [EMClient.sharedClient removeDelegate:self];
    [EMClient.sharedClient removeMultiDevicesDelegate:self];
}

// 由父类调用，不需要调用 clearAllListener方法，每个manager中都由父类调用。
- (void)unRegisterEaseListener {
    [EMClient.sharedClient removeDelegate:self];
    [EMClient.sharedClient removeMultiDevicesDelegate:self];
}

- (ProgressManager *)progressManager {
    return _progressManager;
}

- (void)createAccount:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSString *username = param[@"username"];
    NSString *password = param[@"password"];
    [EMClient.sharedClient registerWithUsername:username
                                       password:password
                                     completion:^(NSString *aUsername, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:aUsername];
    }];
}

- (void)login:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSString *username = param[@"username"];
    NSString *pwdOrToken = param[@"pwdOrToken"];
    BOOL isPwd = [param[@"isPassword"] boolValue];
    
    if (isPwd) {

        [EMClient.sharedClient loginWithUsername:username
                                        password:pwdOrToken
                                      completion:^(NSString *aUsername, EMError *aError){

            [weakSelf wrapperCallBack:result
                          channelName:aChannelName
                                error:aError
                               object:EMClient.sharedClient.currentUsername];
        }];
    }else {
        [EMClient.sharedClient loginWithUsername:username
                                           token:pwdOrToken
                                      completion:^(NSString *aUsername, EMError *aError)
         {
            [weakSelf wrapperCallBack:result
                          channelName:aChannelName
                                error:aError
                               object:EMClient.sharedClient.currentUsername];
        }];
    }
}

- (void)logout:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    BOOL unbindToken = [param[@"unbindToken"] boolValue];
    [EMClient.sharedClient logout:unbindToken completion:^(EMError *aError) {
        if(aError == nil) {
            [ListenerHandle.sharedInstance clearHandle];
        }
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:@(!aError)];
    }];
}

- (void)changeAppKey:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSString *appKey = param[@"appKey"];
    EMError *aError = [EMClient.sharedClient changeAppkey:appKey];
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:aError
                       object:@(!aError)];
}


- (void)getCurrentUser:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSString* username = EMClient.sharedClient.currentUsername;
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:username];
    
}

- (void)uploadLog:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    [EMClient.sharedClient uploadDebugLogToServerWithCompletion:^(EMError *aError) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:nil];
    }];
}

- (void)compressLogs:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    [EMClient.sharedClient getLogFilesPathWithCompletion:^(NSString *aPath, EMError *aError) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:aPath];
    }];
}

- (void)kickDevice:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSString *username = param[@"username"];
    NSString *pwdOrToken = param[@"password"];
    NSString *resource = param[@"resource"];
    bool isPwd = [param[@"isPwd"] boolValue];
    if(isPwd) {
        [EMClient.sharedClient kickDeviceWithUsername:username
                                             password:pwdOrToken
                                             resource:resource
                                           completion:^(EMError *aError)
         {
            [weakSelf wrapperCallBack:result
                          channelName:aChannelName
                                error:aError
                               object:nil];
        }];
    }else {
        [EMClient.sharedClient kickDeviceWithUserId:username token:pwdOrToken resource:resource completion:^(EMError * _Nullable aError) {
            [weakSelf wrapperCallBack:result
                          channelName:aChannelName
                                error:aError
                               object:nil];
        }];
    }
}

- (void)kickAllDevices:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSString *username = param[@"username"];
    NSString *pwdOrToken = param[@"password"];
    bool isPwd = [param[@"isPwd"] boolValue];
    if(isPwd) {
        [EMClient.sharedClient kickAllDevicesWithUsername:username
                                                 password:pwdOrToken
                                               completion:^(EMError *aError)
         {
            [weakSelf wrapperCallBack:result
                          channelName:aChannelName
                                error:aError
                               object:nil];
        }];
    }else {
        [EMClient.sharedClient kickAllDevicesWithUserId:username token:pwdOrToken completion:^(EMError * _Nullable aError) {
            [weakSelf wrapperCallBack:result
                          channelName:aChannelName
                                error:aError
                               object:nil];
        }];
    }
}

- (void)isLoggedInBefore:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:@(EMClient.sharedClient.isLoggedIn)];
    
}

- (void)loginWithAgoraToken:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSString *username = param[@"username"];
    NSString *agoraToken = param[@"agora_token"];
    [EMClient.sharedClient loginWithUsername:username
                                  agoraToken:agoraToken
                                  completion:^(NSString *aUsername, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:EMClient.sharedClient.currentUsername];
    }];
}


- (void)getToken:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result{
    [self wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:EMClient.sharedClient.accessUserToken];
}


- (void)isConnected:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result{
    [self wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:@(EMClient.sharedClient.isConnected)];
}

- (void)renewToken:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result{
    __weak typeof(self)weakSelf = self;
    NSString *newAgoraToken = param[@"agora_token"];
    [EMClient.sharedClient renewToken:newAgoraToken completion:^(EMError * _Nullable aError) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:nil
                           object:nil];
    }];
}

- (void)getLoggedInDevicesFromServer:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSString *username = param[@"username"];
    NSString *pwdOrToken = param[@"password"];
    bool isPwd = [param[@"isPwd"] boolValue];
    if(isPwd) {
        [EMClient.sharedClient getLoggedInDevicesFromServerWithUsername:username
                                                               password:pwdOrToken
                                                             completion:^(NSArray *aList, EMError *aError)
         {
            
            NSMutableArray *list = [NSMutableArray array];
            for (EMDeviceConfig *deviceInfo in aList) {
                [list addObject:[deviceInfo toJson]];
            }
            
            
            [weakSelf wrapperCallBack:result
                          channelName:aChannelName
                                error:aError
                               object:list];
        }];
    }else {
        [EMClient.sharedClient getLoggedInDevicesFromServerWithUserId:username
                                                                token:pwdOrToken
                                                           completion:^(NSArray<EMDeviceConfig *> * _Nullable aList, EMError * _Nullable aError)
         {
            NSMutableArray *list = [NSMutableArray array];
            for (EMDeviceConfig *deviceInfo in aList) {
                [list addObject:[deviceInfo toJson]];
            }
            
            
            [weakSelf wrapperCallBack:result
                          channelName:aChannelName
                                error:aError
                               object:list];
        }];
    }
    
}

- (void)startCallBack:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result{
    __weak typeof(self)weakSelf = self;
    [ListenerHandle.sharedInstance startCallback];
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:nil];
}

#pragma - mark EMClientDelegate

- (void)connectionStateDidChange:(EMConnectionState)aConnectionState {
    BOOL isConnected = aConnectionState == EMConnectionConnected;
    if (isConnected) {
        [self.channel invokeMethod:ChatOnConnected
                         arguments:nil];
    }else {
        [self.channel invokeMethod:ChatOnDisconnected
                         arguments:nil];
    }
}

- (void)autoLoginDidCompleteWithError:(EMError *)aError {
    if (aError.code == EMErrorServerServingForbidden) {
         [self userDidForbidByServer];
    }else if (aError.code == EMErrorAppActiveNumbersReachLimitation) {
        [self activeNumbersReachLimitation];
    }
}

- (void)activeNumbersReachLimitation {
    [self.channel invokeMethod:ChatOnAppActiveNumberReachLimit arguments:nil];
}

// 声网token即将过期
- (void)tokenWillExpire:(EMErrorCode)aErrorCode {
    [self.channel invokeMethod:ChatOnTokenWillExpire arguments:nil];
}

// 声网token过期
- (void)tokenDidExpire:(EMErrorCode)aErrorCode {
    [ListenerHandle.sharedInstance clearHandle];
    [self.channel invokeMethod:ChatOnTokenDidExpire
                     arguments:nil];
}

//- (void)userAccountDidLoginFromOtherDevice:(NSString *)aDeviceName {
//    [EMListenerHandle.sharedInstance clearHandle];
//    [self.channel invokeMethod:ChatOnUserDidLoginFromOtherDevice
//                     arguments:@{@"deviceName": aDeviceName}];
//}

- (void)onOfflineMessageSyncStart {
    [self.channel invokeMethod:onOfflineMessageSyncStart
                     arguments:nil];
}

- (void)onOfflineMessageSyncFinish {
    [self.channel invokeMethod:onOfflineMessageSyncFinish
                     arguments:nil];
}

- (void)userAccountDidRemoveFromServer {
    [ListenerHandle.sharedInstance clearHandle];
    [self.channel invokeMethod:ChatOnUserDidRemoveFromServer
                     arguments:nil];
}

- (void)userDidForbidByServer {
    [ListenerHandle.sharedInstance clearHandle];
    [self.channel invokeMethod:ChatOnUserDidForbidByServer
                     arguments:nil];
}


- (void)userAccountDidForcedToLogout:(EMError *)aError {
    [ListenerHandle.sharedInstance clearHandle];
    if (aError.code == EMErrorUserKickedByChangePassword) {
        [self.channel invokeMethod:ChatOnUserDidChangePassword
                         arguments:nil];
    } else if (aError.code == EMErrorUserLoginTooManyDevices) {
        [self.channel invokeMethod:ChatOnUserDidLoginTooManyDevice
                         arguments:nil];
    } else if (aError.code == EMErrorUserKickedByOtherDevice) {
        [self.channel invokeMethod:ChatOnUserKickedByOtherDevice
                         arguments:nil];
    } else if (aError.code == EMErrorUserAuthenticationFailed) {
        [self.channel invokeMethod:ChatOnUserAuthenticationFailed
                         arguments:nil];
    }
}

#pragma mark - EMMultiDevicesDelegate

- (void)multiDevicesContactEventDidReceive:(EMMultiDevicesEvent)aEvent
                                  username:(NSString *)aUsername
                                       ext:(NSString *)aExt {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"event"] = @(aEvent);
    data[@"target"] = aUsername;
    data[@"ext"] = aExt;
    [self.channel invokeMethod:ChatOnMultiDeviceContactEvent arguments:data];
}

- (void)multiDevicesGroupEventDidReceive:(EMMultiDevicesEvent)aEvent
                                 groupId:(NSString *)aGroupId
                                     ext:(id)aExt {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"event"] = @(aEvent);
    data[@"target"] = aGroupId;
    data[@"users"] = aExt;
    [self.channel invokeMethod:ChatOnMultiDeviceGroupEvent arguments:data];
}

- (void)multiDevicesChatThreadEventDidReceive:(EMMultiDevicesEvent)aEvent
                                 threadId:(NSString *)aThreadId
                                          ext:(id)aExt {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"event"] = @(aEvent);
    data[@"threadId"] = aThreadId;
    data[@"users"] = aExt;
    [self.channel invokeMethod:ChatOnMultiDeviceThreadEvent arguments:data];
}

- (void)multiDevicesMessageBeRemoved:(NSString *)conversationId deviceId:(NSString *)deviceId {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"convId"] = conversationId;
    data[@"deviceId"] = deviceId;
    [self.channel invokeMethod:ChatOnMultiDeviceRemoveMessagesEvent arguments:data];
}

- (void)multiDevicesConversationEvent:(EMMultiDevicesEvent)event
                       conversationId:(NSString *)conversationId
                     conversationType:(EMConversationType)conversationType {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"event"] = @(event);
    data[@"convId"] = conversationId;
    data[@"convType"] = [NSNumber numberWithInteger:[EnumTools conversationTypeToInt:conversationType]];
    [self.channel invokeMethod:ChatOnMultiDevicesConversationEvent arguments:data];
}

//- (void)multiDevicesUndisturbEventNotifyFormOtherDeviceData:(NSString *)undisturbData {
//    
//}


# pragma mark - 481
- (void)userAccountDidLoginFromOtherDeviceWithInfo:(EMLoginExtensionInfo *)info {
    [ListenerHandle.sharedInstance clearHandle];
    [self.channel invokeMethod:ChatOnUserDidLoginFromOtherDevice
                     arguments:[info toJson]];
}


- (void)updateUsingHttpsOnlySetting:(NSDictionary *)param
                        channelName:(NSString *)aChannelName
                             result:(FlutterResult)result 
{
    __weak typeof(self)weakSelf = self;
    BOOL usingHttpsOnly = [param[@"usingHttpsOnly"] boolValue];
    EMClient.sharedClient.options.usingHttpsOnly = usingHttpsOnly;
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:nil];
}

- (void)updateLoginExtensionInfo:(NSDictionary *)param
                     channelName:(NSString *)aChannelName
                          result:(FlutterResult)result
{
    __weak typeof(self)weakSelf = self;
    NSString *ext = param[@"extension"];
    EMClient.sharedClient.options.loginExtensionInfo = ext;
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:nil];
}

- (void)updateDeleteMessagesWhenLeaveGroupSetting:(NSDictionary *)param
                                      channelName:(NSString *)aChannelName
                                           result:(FlutterResult)result
{
    __weak typeof(self)weakSelf = self;
    BOOL deleteMessagesWhenLeaveGroup = [param[@"deleteMessagesWhenLeaveGroup"] boolValue];
    EMClient.sharedClient.options.deleteMessagesOnLeaveGroup = deleteMessagesWhenLeaveGroup;
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:nil];
}

- (void)updateDeleteMessageWhenLeaveRoomSetting:(NSDictionary *)param
                                    channelName:(NSString *)aChannelName
                                         result:(FlutterResult)result
{
    __weak typeof(self)weakSelf = self;
    BOOL deleteMessageWhenLeaveRoom = [param[@"deleteMessageWhenLeaveRoom"] boolValue];
    EMClient.sharedClient.options.deleteMessagesOnLeaveChatroom = deleteMessageWhenLeaveRoom;
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:nil];
}

- (void)updateRoomOwnerCanLeaveSetting:(NSDictionary *)param
                           channelName:(NSString *)aChannelName
                                result:(FlutterResult)result
{
    __weak typeof(self)weakSelf = self;
    BOOL roomOwnerCanLeave = [param[@"roomOwnerCanLeave"] boolValue];
    EMClient.sharedClient.options.canChatroomOwnerLeave = roomOwnerCanLeave;
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:nil];
}

- (void)updateAutoAcceptGroupInvitationSetting:(NSDictionary *)param
                                   channelName:(NSString *)aChannelName
                                        result:(FlutterResult)result
{
    __weak typeof(self)weakSelf = self;
    BOOL autoAcceptGroupInvitation = [param[@"autoAcceptGroupInvitation"] boolValue];
    EMClient.sharedClient.options.autoAcceptGroupInvitation = autoAcceptGroupInvitation;
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:nil];
}

- (void)updateAcceptInvitationAlways:(NSDictionary *)param
                         channelName:(NSString *)aChannelName
                              result:(FlutterResult)result
{
    __weak typeof(self)weakSelf = self;
    BOOL acceptInvitationAlways = [param[@"acceptInvitationAlways"] boolValue];
    EMClient.sharedClient.options.autoAcceptFriendInvitation = acceptInvitationAlways;
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:nil];
}

- (void)updateAutoDownloadAttachmentThumbnailSetting:(NSDictionary *)param
                                         channelName:(NSString *)aChannelName
                                              result:(FlutterResult)result
{
    __weak typeof(self)weakSelf = self;
    BOOL autoDownloadThumbnail = [param[@"autoDownloadThumbnail"] boolValue];
    EMClient.sharedClient.options.autoDownloadThumbnail = autoDownloadThumbnail;
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:nil];
}

- (void)updateRequireAckSetting:(NSDictionary *)param
                    channelName:(NSString *)aChannelName
                         result:(FlutterResult)result
{
    __weak typeof(self)weakSelf = self;
    BOOL requireAck = [param[@"requireAck"] boolValue];
    EMClient.sharedClient.options.enableRequireReadAck = requireAck;
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:nil];
}

- (void)updateDeliveryAckSetting:(NSDictionary *)param
                     channelName:(NSString *)aChannelName
                          result:(FlutterResult)result
{
    __weak typeof(self)weakSelf = self;
    BOOL requireDeliveryAck = [param[@"requireDeliveryAck"] boolValue];
    EMClient.sharedClient.options.enableDeliveryAck = requireDeliveryAck;
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:nil];
}

- (void)updateSortMessageByServerTimeSetting:(NSDictionary *)param
                                 channelName:(NSString *)aChannelName
                                      result:(FlutterResult)result
{
    __weak typeof(self)weakSelf = self;
    BOOL sortMessageByServerTime = [param[@"sortMessageByServerTime"] boolValue];
    EMClient.sharedClient.options.sortMessageByServerTime = sortMessageByServerTime;
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:nil];
}

- (void)updateMessagesReceiveCallbackIncludeSendSetting:(NSDictionary *)param
                                            channelName:(NSString *)aChannelName
                                                 result:(FlutterResult)result
{
    __weak typeof(self)weakSelf = self;
    BOOL includeSend = [param[@"includeSend"] boolValue];
    EMClient.sharedClient.options.includeSendMessageInMessageListener = includeSend;
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:nil];
}

- (void)updateRegradeMessagesSetting:(NSDictionary *)param
                         channelName:(NSString *)aChannelName
                              result:(FlutterResult)result
{
    __weak typeof(self)weakSelf = self;
    BOOL isRead = [param[@"isRead"] boolValue];
    EMClient.sharedClient.options.regardImportMessagesAsRead = isRead;
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:nil];
}

// shenwang
- (void)changeAppId:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
#if defined(AgoraChat)
    __weak typeof(self)weakSelf = self;
    NSString *appId = param[@"appId"];
    EMError *aError = [EMClient.sharedClient changeAppId:appId];
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:aError
                       object:@(!aError)];
#endif
}


@end
