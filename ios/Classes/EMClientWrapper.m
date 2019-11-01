//
//  EMClientWrapper.m
//  
//
//  Created by 杜洁鹏 on 2019/10/8.
//

#import "EMClientWrapper.h"
#import <Hyphenate/Hyphenate.h>
#import "EMSDKMethod.h"

@interface EMClientWrapper () <EMClientDelegate, EMMultiDevicesDelegate>
@property (nonatomic, strong) NSMutableDictionary *deviceDict;
@end

@implementation EMClientWrapper
- (instancetype)initWithChannelName:(NSString *)aChannelName
                          registrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    if(self = [super initWithChannelName:aChannelName
                               registrar:registrar]) {
        [EMClient.sharedClient addDelegate:self delegateQueue:nil];
        [EMClient.sharedClient addMultiDevicesDelegate:self delegateQueue:nil];
    }
    return self;
}

#pragma mark - FlutterPlugin

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if (![call.arguments isKindOfClass:[NSDictionary class]]) {
        NSLog(@"wrong type");
        return;
    }
    if ([EMMethodKeyInit isEqualToString:call.method]) {
        [self initSDKWithDict:call.arguments result:result];
    } else if ([EMMethodKeyLogin isEqualToString:call.method]) {
        [self login:call.arguments result:result];
    } else if ([EMMethodKeyCreateAccount isEqualToString:call.method]) {
        [self createAccount:call.arguments result:result];
    } else if ([EMMethodKeyLoginWithToken isEqualToString:call.method]) {
        [self loginWithToken:call.arguments result:result];
    } else if ([EMMethodKeyLogout isEqualToString:call.method]) {
        [self logout:call.arguments result:result];
    } else if ([EMMethodKeyChangeAppKey isEqualToString:call.method]) {
        [self changeAppKey:call.arguments result:result];
    } else if ([EMMethodKeySetDebugMode isEqualToString:call.method]) {
        [self setDebugMode:call.arguments result:result];
    } else if ([EMMethodKeyUpdateCurrentUserNick isEqualToString:call.method]) {
        [self updateCurrentUserNick:call.arguments result:result];
    } else if ([EMMethodKeyUploadLog isEqualToString:call.method]) {
        [self uploadLog:call.arguments result:result];
    } else if ([EMMethodKeyCompressLogs isEqualToString:call.method]) {
        [self compressLogs:call.arguments result:result];
    } else if ([EMMethodKeyGetLoggedInDevicesFromServer isEqualToString:call.method]) {
        [self getLoggedInDevicesFromServer:call.arguments result:result];
    } else if ([EMMethodKeyKickDevice isEqualToString:call.method]) {
        [self kickDevice:call.arguments result:result];
    } else if ([EMMethodKeyKickAllDevices isEqualToString:call.method]) {
        [self kickAllDevices:call.arguments result:result];
    } else if ([EMMethodKeySendFCMTokenToServer isEqualToString:call.method]) {
        [self sendFCMTokenToServer:call.arguments result:result];
    } else if ([EMMethodKeySendHMSPushTokenToServer isEqualToString:call.method]) {
        [self sendHMSPushTokenToServer:call.arguments result:result];
    } else if ([EMMethodKeyGetDeviceInfo isEqualToString:call.method]) {
        [self getDeviceInfo:call.arguments result:result];
    } else if ([EMMethodKeyCheck isEqualToString:call.method]) {
        [self check:call.arguments result:result];
    }  else {
        [super handleMethodCall:call result:result];
    }
}

#pragma mark - Actions
- (void)initSDKWithDict:(NSDictionary *)param result:(FlutterResult)result {
    NSString *appKey = param[@"appKey"];
    EMOptions *options = [EMOptions optionsWithAppkey:appKey];
    options.enableConsoleLog = YES;
    [EMClient.sharedClient initializeSDKWithOptions:options];
    [EMClient.sharedClient addDelegate:self delegateQueue:nil];
}

- (void)createAccount:(NSDictionary *)param result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSString *username = param[@"userName"];
    NSString *password = param[@"password"];
    [EMClient.sharedClient registerWithUsername:username
                                         password:password
                                       completion:^(NSString *aUsername, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                            error:aError
                         userInfo:@{@"aUsername":aUsername}];
    }];
}

- (void)login:(NSDictionary *)param result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSString *username = param[@"userName"];
    NSString *password = param[@"password"];
    [EMClient.sharedClient loginWithUsername:username
                                    password:password
                                  completion:^(NSString *aUsername, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                        error:aError
                     userInfo:@{@"aUsername":aUsername}];
    }];
}

- (void)loginWithToken:(NSDictionary *)param result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSString *username = param[@"userName"];
    NSString *token = param[@"token"];
    [EMClient.sharedClient loginWithUsername:username
                                       token:token
                                  completion:^(NSString *aUsername, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                        error:aError
                     userInfo:@{@"aUsername":aUsername}];
    }];
}

- (void)logout:(NSDictionary *)param result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    BOOL unbindToken = [param[@"unbindToken"] boolValue];
    [EMClient.sharedClient logout:unbindToken completion:^(EMError *aError) {
        [weakSelf wrapperCallBack:result
                            error:aError
                         userInfo:nil];
        if (!aError) {
            [weakSelf.deviceDict removeAllObjects];
        }
    }];
}

- (void)changeAppKey:(NSDictionary *)param result:(FlutterResult)result {
    NSString *appKey = param[@"appKey"];
    EMError *aError = [EMClient.sharedClient changeAppkey:appKey];
    [self wrapperCallBack:result
                    error:aError
                 userInfo:nil];
}

// ios sdk 不支持这个实现
- (void)setDebugMode:(NSDictionary *)param result:(FlutterResult)result {
    [self wrapperCallBack:result
                    error:nil
                 userInfo:nil];
}

- (void)getCurrentUser:(NSDictionary *)param result:(FlutterResult)result {
    NSString *username = EMClient.sharedClient.currentUsername;
    [self wrapperCallBack:result
                    error:nil
                 userInfo:username];
}

- (void)updateCurrentUserNick:(NSDictionary *)param result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSString *nickName = param[@"nickName"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *aError = [EMClient.sharedClient setApnsNickname:nickName];
        // 切换到主线程?
        [weakSelf wrapperCallBack:result
                        error:aError
                     userInfo:nil];
    });
}

- (void)uploadLog:(NSDictionary *)param result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    [EMClient.sharedClient uploadDebugLogToServerWithCompletion:^(EMError *aError) {
        [weakSelf wrapperCallBack:result
                            error:aError
                         userInfo:nil];
    }];
}

- (void)compressLogs:(NSDictionary *)param result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    [EMClient.sharedClient getLogFilesPathWithCompletion:^(NSString *aPath, EMError *aError) {
        [weakSelf wrapperCallBack:result
                            error:aError
                         userInfo:aPath];
    }];
}

- (void)kickDevice:(NSDictionary *)param result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSString *userName = param[@"userName"];
    NSString *password = param[@"password"];
    NSString *resource = param[@"resource"];
    EMDeviceConfig *deviceConfig = self.deviceDict[resource];
    [EMClient.sharedClient kickDevice:deviceConfig
                             username:userName
                             password:password
                           completion:^(EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                            error:aError
                         userInfo:nil];
    }];
}

- (void)kickAllDevices:(NSDictionary *)param result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSString *userName = param[@"userName"];
    NSString *password = param[@"password"];
    [EMClient.sharedClient kickAllDevicesWithUsername:userName
                                             password:password
                                           completion:^(EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                            error:aError
                         userInfo:nil];
    }];
}

- (void)sendFCMTokenToServer:(NSDictionary *)param result:(FlutterResult)result {
    [self wrapperCallBack:result
                    error:nil
                userInfo:nil];
}

- (void)sendHMSPushTokenToServer:(NSDictionary *)param result:(FlutterResult)result {
    [self wrapperCallBack:result
                    error:nil
                userInfo:nil];
}

- (void)getDeviceInfo:(NSDictionary *)param result:(FlutterResult)result {
    [self wrapperCallBack:result
                    error:nil
                userInfo:nil];
}


- (void)onMultiDeviceEvent:(NSDictionary *)param result:(FlutterResult)result {
    
}

// TODO: 作用？
- (void)check:(NSDictionary *)param result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSString *userName = param[@"userName"];
    NSString *password = param[@"password"];
    [EMClient.sharedClient serviceCheckWithUsername:userName
                                           password:password
                                         completion:^(EMServerCheckType aType, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                            error:nil
                         userInfo:nil];
    }];
}

- (void)getLoggedInDevicesFromServer:(NSDictionary *)param result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSString *userName = param[@"userName"];
    NSString *password = param[@"password"];
    [EMClient.sharedClient getLoggedInDevicesFromServerWithUsername:userName
                                                           password:password
                                                         completion:^(NSArray *aList, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                            error:aError
                         userInfo:[weakSelf deviceConfigsToDictionaryList:aList]];
        if (!aError) {
            [self.deviceDict removeAllObjects];
            for (EMDeviceConfig * deviceConfig in aList) {
                self.deviceDict[deviceConfig.resource] = deviceConfig;
            }
        }
    }];
}


#pragma - mark EMClientDelegate

- (void)connectionStateDidChange:(EMConnectionState)aConnectionState {
    BOOL isConnected = aConnectionState == EMConnectionConnected;
    if (isConnected) {
        [self onConnected];
    }else {
        [self onDisconnected:1]; // 需要明确具体的code
    }
}

- (void)autoLoginDidCompleteWithError:(EMError *)aError {
    [self onDisconnected:1];  // 需要明确具体的code
}

- (void)userAccountDidLoginFromOtherDevice {
    [self onDisconnected:1];  // 需要明确具体的code
}

- (void)userAccountDidRemoveFromServer {
    [self onDisconnected:1];  // 需要明确具体的code
}

- (void)userDidForbidByServer {
    [self onDisconnected:1];  // 需要明确具体的code
}

- (void)userAccountDidForcedToLogout:(EMError *)aError {
    [self onDisconnected:1];  // 需要明确具体的code
}

#pragma mark - EMMultiDevicesDelegate

- (void)multiDevicesContactEventDidReceive:(EMMultiDevicesEvent)aEvent
                                  username:(NSString *)aUsername
                                       ext:(NSString *)aExt {
        
}

- (void)multiDevicesGroupEventDidReceive:(EMMultiDevicesEvent)aEvent
                                 groupId:(NSString *)aGroupId
                                     ext:(id)aExt {
    
}

#pragma mark - Merge Android and iOS Method
- (void)onConnected {
    [self.channel invokeMethod:EMMethodKeyOnConnected
                     arguments:@{@"connected" : @(YES)}];
}

- (void)onDisconnected:(int)errorCode {
    [self.channel invokeMethod:EMMethodKeyOnDisconnected
                     arguments:@{@"errorCode" : @(errorCode)}];
}


#pragma mark - Private
- (NSArray *)deviceConfigsToDictionaryList:(NSArray *)aList {
    NSMutableArray *ret = [NSMutableArray array];
    for (EMDeviceConfig *config in aList) {
        [ret addObject:@{@"resource":config.resource,
                         @"UUID":config.deviceUUID,
                         @"name":config.deviceName}];
    }
    
    return ret;
}

#pragma mark - Getter
- (NSMutableDictionary *)deviceDict {
    if (!_deviceDict) {
        _deviceDict = [NSMutableDictionary dictionary];
    }
    
    return _deviceDict;
}

@end
