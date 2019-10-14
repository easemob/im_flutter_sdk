//
//  EMClientWrapper.m
//  
//
//  Created by 杜洁鹏 on 2019/10/8.
//

#import "EMClientWrapper.h"
#import <Hyphenate/Hyphenate.h>
#import "EMSDKMethod.h"
#import "EMLogWrapper.h"

@interface EMClientWrapper () <EMClientDelegate>

@end

@implementation EMClientWrapper
- (instancetype)initWithChannelName:(NSString *)aChannelName
                          registrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    if(self = [super initWithChannelName:aChannelName
                               registrar:registrar]) {
    }
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([EMMethodKeyInit isEqualToString:call.method]) {
        [self initSDKWithArg:call.arguments result:result];
    } else if ([EMMethodKeyLogin isEqualToString:call.method]) {
        [self login:call.arguments result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)initSDKWithArg:(id)arg result:(FlutterResult)result {
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSString *appKey = param[@"appkey"];
        if (appKey) {
            EMOptions *options = [EMOptions optionsWithAppkey:appKey];
            [EMClient.sharedClient initializeSDKWithOptions:options];
            [EMClient.sharedClient addDelegate:self delegateQueue:nil];
        }else {

        }
    }
}

- (void)createAccount:(id)arg result:(FlutterResult)result {
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSString *username = param[@"userName"];
        NSString *password = param[@"password"];
        [EMClient.sharedClient registerWithUsername:username
                                             password:password
                                           completion:^(NSString *aUsername, EMError *aError)
        {
            // result(aError ? [self emError2FlutterError:aError] : @"");
        }];
    }
}

- (void)login:(id)arg result:(FlutterResult)result {
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSString *username = param[@"userName"];
        NSString *password = param[@"password"];
        [EMClient.sharedClient loginWithUsername:username
                                        password:password
                                      completion:^(NSString *aUsername, EMError *aError)
        {
            // result(aError ? [self emError2FlutterError:aError] : @"");
        }];
    }
}

#pragma - mark EMClientDelegate
- (void)connectionStateDidChange:(EMConnectionState)connectionState {
    BOOL isConnected = connectionState == EMConnectionConnected;
    [self.channel invokeMethod:EMMethodKeyConnectionDidChanged
                     arguments:@{@"isConnected" : [NSNumber numberWithBool:isConnected]}];
}

@end
