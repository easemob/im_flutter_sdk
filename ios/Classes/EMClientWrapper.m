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
    } else {
        [super handleMethodCall:call result:result];
    }
}

- (void)initSDKWithDict:(NSDictionary *)param result:(FlutterResult)result {
    NSString *appKey = param[@"appKey"];
    EMOptions *options = [EMOptions optionsWithAppkey:appKey];
    options.enableConsoleLog = YES;
    [EMClient.sharedClient initializeSDKWithOptions:options];
    [EMClient.sharedClient addDelegate:self delegateQueue:nil];
}

- (void)createAccount:(NSDictionary *)param result:(FlutterResult)result {
    NSString *username = param[@"userName"];
    NSString *password = param[@"password"];
    [EMClient.sharedClient registerWithUsername:username
                                         password:password
                                       completion:^(NSString *aUsername, EMError *aError)
    {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:@{@"aUsername":aUsername}];
    }];
}

- (void)login:(NSDictionary *)param result:(FlutterResult)result {
    NSString *username = param[@"userName"];
    NSString *password = param[@"password"];
    [EMClient.sharedClient loginWithUsername:username
                                    password:password
                                  completion:^(NSString *aUsername, EMError *aError)
    {
        [self wrapperCallBack:result
                        error:aError
                     userInfo:@{@"aUsername":aUsername}];
    }];
}

#pragma - mark EMClientDelegate

- (void)connectionStateDidChange:(EMConnectionState)aConnectionState {
    BOOL isConnected = aConnectionState == EMConnectionConnected;
    [self.channel invokeMethod:EMMethodKeyOnConnectionDidChanged
                     arguments:@{@"isConnected" : [NSNumber numberWithBool:isConnected]}];
}

- (void)autoLoginDidCompleteWithError:(EMError *)aError {
    
}

- (void)userAccountDidLoginFromOtherDevice {
    
}

- (void)userAccountDidRemoveFromServer {
    
}

- (void)userDidForbidByServer {
    
}

- (void)userAccountDidForcedToLogout:(EMError *)aError {
    
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

@end
