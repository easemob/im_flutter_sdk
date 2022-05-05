//
//  EMClientWrapper.m
//  
//
//  Created by 杜洁鹏 on 2019/10/8.
//

#import "EMClientWrapper.h"
#import "EMSDKMethod.h"
#import "EMChatManagerWrapper.h"
#import "EMContactManagerWrapper.h"
#import "EMConversationWrapper.h"
#import "EMGroupManagerWrapper.h"
#import "EMChatroomManagerWrapper.h"
#import "EMPushManagerWrapper.h"
#import "EMDeviceConfig+Helper.h"
#import "EMOptions+Helper.h"
#import "EMUserInfoManagerWrapper.h"
#import "EMPresenceManagerWrapper.h"
#import "EMChatMessageWrapper.h"
#import "EMListenerHandle.h"

@interface EMClientWrapper () <EMClientDelegate, EMMultiDevicesDelegate, FlutterPlugin>
@end

@implementation EMClientWrapper

static EMClientWrapper *wrapper = nil;


+ (EMClientWrapper *)sharedWrapper {
    return wrapper;
}

- (void)sendDataToFlutter:(NSDictionary *)aData {
    if (aData == nil) {
        return;
    }
    [self.channel invokeMethod:ChatSendDataToFlutter
                     arguments:aData];
}

+ (EMClientWrapper *)channelName:(NSString *)aChannelName
                       registrar:(NSObject<FlutterPluginRegistrar>*)registrar
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        wrapper = [[EMClientWrapper alloc] initWithChannelName:aChannelName registrar:registrar];
    });
    return wrapper;
}

- (instancetype)initWithChannelName:(NSString *)aChannelName
                          registrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    if(self = [super initWithChannelName:aChannelName
                               registrar:registrar]) {
        [registrar addApplicationDelegate:self];
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
        [self startCallBack];
    }
    else {
        [super handleMethodCall:call result:result];
    }
}


#pragma mark - Actions
- (void)initSDKWithDict:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    
    EMOptions *options = [EMOptions fromJson:param];

    [EMClient.sharedClient initializeSDKWithOptions:options];
    
    [EMClient.sharedClient removeDelegate:self];
    [EMClient.sharedClient removeMultiDevicesDelegate:self];
    [EMClient.sharedClient addDelegate:self delegateQueue:nil];
    [EMClient.sharedClient addMultiDevicesDelegate:self delegateQueue:nil];
    [self registerManagers];
    
    [weakSelf wrapperCallBack:result
                  channelName:ChatInit
                        error:nil
                       object:nil];
}


- (void)registerManagers {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
    EMChatManagerWrapper * chat = [[EMChatManagerWrapper alloc] initWithChannelName:EMChannelName(@"chat_manager")registrar:self.flutterPluginRegister];
    EMContactManagerWrapper * contact = [[EMContactManagerWrapper alloc] initWithChannelName:EMChannelName(@"chat_contact_manager") registrar:self.flutterPluginRegister];
    EMConversationWrapper *conversation = [[EMConversationWrapper alloc] initWithChannelName:EMChannelName(@"chat_conversation") registrar:self.flutterPluginRegister];
    EMGroupManagerWrapper * group = [[EMGroupManagerWrapper alloc] initWithChannelName:EMChannelName(@"chat_group_manager") registrar:self.flutterPluginRegister];
    EMChatroomManagerWrapper * chatroom =[[EMChatroomManagerWrapper alloc] initWithChannelName:EMChannelName(@"chat_room_manager") registrar:self.flutterPluginRegister];
    EMPushManagerWrapper * push =[[EMPushManagerWrapper alloc] initWithChannelName:EMChannelName(@"chat_push_manager") registrar:self.flutterPluginRegister];
    EMUserInfoManagerWrapper *userInfo = [[EMUserInfoManagerWrapper alloc] initWithChannelName:EMChannelName(@"chat_userInfo_manager") registrar:self.flutterPluginRegister];
    EMPresenceManagerWrapper * presence = [[EMPresenceManagerWrapper alloc] initWithChannelName:EMChannelName(@"chat_presence_manager") registrar:self.flutterPluginRegister];
    EMChatMessageWrapper *chatMessage = [[EMChatMessageWrapper alloc] initWithChannelName:EMChannelName(@"chat_message") registrar:self.flutterPluginRegister];
    
#pragma clang diagnostic pop
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
            [EMListenerHandle.sharedInstance clearHandle];
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
    NSString *password = param[@"password"];
    NSString *resource = param[@"resource"];
    
    [EMClient.sharedClient kickDeviceWithUsername:username
                                         password:password
                                         resource:resource
                                       completion:^(EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:nil];
    }];
}

- (void)kickAllDevices:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSString *username = param[@"username"];
    NSString *password = param[@"password"];
    [EMClient.sharedClient kickAllDevicesWithUsername:username
                                             password:password
                                           completion:^(EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:nil];
    }];
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
    NSString *agoraToken = param[@"agoratoken"];
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
    NSString *newAgoraToken = param[@"agora_token"];
    [EMClient.sharedClient renewToken:newAgoraToken];
    [self wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:nil];
}

- (void)getLoggedInDevicesFromServer:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSString *username = param[@"username"];
    NSString *password = param[@"password"];
    [EMClient.sharedClient getLoggedInDevicesFromServerWithUsername:username
                                                           password:password
                                                         completion:^(NSArray *aList, EMError *aError)
     {
        
        NSMutableArray *list = [NSMutableArray array];
        for (EMDeviceConfig *deviceInfo in aList) {
            [list addObject:[deviceInfo toJson]];
        }
        
        
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:nil];
    }];
}

- (void)startCallBack {
    [EMListenerHandle.sharedInstance startCallback];
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
 
}

// 声网token即将过期
- (void)tokenWillExpire:(int)aErrorCode {
    [self.channel invokeMethod:ChatOnTokenWillExpire
                     arguments:nil];
}

// 声网token过期
- (void)tokenDidExpire:(int)aErrorCode {
    [EMListenerHandle.sharedInstance clearHandle];
    [self.channel invokeMethod:ChatOnTokenDidExpire
                     arguments:nil];
}

- (void)userAccountDidLoginFromOtherDevice {
    [EMListenerHandle.sharedInstance clearHandle];
    [self.channel invokeMethod:ChatOnUserDidLoginFromOtherDevice
                     arguments:nil];
}

- (void)userAccountDidRemoveFromServer {
    [EMListenerHandle.sharedInstance clearHandle];
    [self.channel invokeMethod:ChatOnUserDidRemoveFromServer
                     arguments:nil];
}

- (void)userDidForbidByServer {
    [EMListenerHandle.sharedInstance clearHandle];
    [self.channel invokeMethod:ChatOnUserDidForbidByServer
                     arguments:nil];
}

- (void)userAccountDidForcedToLogout:(EMError *)aError {
    [EMListenerHandle.sharedInstance clearHandle];
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
    [self.channel invokeMethod:ChatOnMultiDeviceEvent arguments:data];
}

- (void)multiDevicesGroupEventDidReceive:(EMMultiDevicesEvent)aEvent
                                 groupId:(NSString *)aGroupId
                                     ext:(id)aExt {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"event"] = @(aEvent);
    data[@"target"] = aGroupId;
    data[@"userNames"] = aExt;
    [self.channel invokeMethod:ChatOnMultiDeviceEvent arguments:data];
}


@end
