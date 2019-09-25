#import "ImFlutterSdkPlugin.h"
#import <Hyphenate/Hyphenate.h>

#import "ImFlutterSDKDefine.h"
#import "ImFlutterSDKLog.h"

@implementation ImFlutterSdkPlugin

- (instancetype)initWithChannel:(FlutterMethodChannel *)aChannel {
    if (self = [super init]) {
        self.channel = aChannel;
    }
    return self;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    [self registerClientChannel:registrar];
    [self registerChatManagerChannel:registrar];
    [self registerContactManagerChannel:registrar];
    [self registerGroupManagerChannel:registrar];
    [self registerChatRoomManagerChannel:registrar];
    [ImFlutterSDKLog registrar:registrar];
}

- (FlutterError *)emError2FlutterError:(EMError *)aError {
    return [FlutterError errorWithCode:[@(aError.code) stringValue] message:aError.errorDescription details:nil];
}


// em_client
+ (void)registerClientChannel:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                        methodChannelWithName:@"com.easemob.im/em_client"
                                               binaryMessenger:[registrar messenger]];
    ImClientPlugin* instance = [[ImClientPlugin alloc] initWithChannel:channel];
    [registrar addMethodCallDelegate:instance channel:channel];
}

// em_chat_manager
+ (void)registerChatManagerChannel:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                        methodChannelWithName:@"com.easemob.im/em_chat_manager"
                                               binaryMessenger:[registrar messenger]];
    ImChatManagerPlugin* instance = [[ImChatManagerPlugin alloc] initWithChannel:channel];
    [registrar addMethodCallDelegate:instance channel:channel];
}

// em_contact_manager
+ (void)registerContactManagerChannel:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                        methodChannelWithName:@"com.easemob.im/em_contact_manager"
                                            binaryMessenger:[registrar messenger]];
    ImContactManagerPlugin* instance = [[ImContactManagerPlugin alloc] initWithChannel:channel];
    [registrar addMethodCallDelegate:instance channel:channel];
}

// em_chat_group_manager
+ (void)registerGroupManagerChannel:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                        methodChannelWithName:@"em_chat_group_manager"
                                            binaryMessenger:[registrar messenger]];
    ImGroupManagerPlugin* instance = [[ImGroupManagerPlugin alloc] initWithChannel:channel];
    [registrar addMethodCallDelegate:instance channel:channel];
}

// em_chat_room_manager
+ (void)registerChatRoomManagerChannel:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                        methodChannelWithName:@"em_chat_room_manager"
                                            binaryMessenger:[registrar messenger]];
    ImChatRoomManagerPlugin* instance = [[ImChatRoomManagerPlugin alloc] initWithChannel:channel];
    [registrar addMethodCallDelegate:instance channel:channel];
}
@end

@interface ImClientPlugin() <EMClientDelegate>
@end

@implementation ImClientPlugin

- (instancetype)initWithChannel:(FlutterMethodChannel *)aChannel {
    if(self = [super initWithChannel:aChannel]) {

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
            result(aError ? [self emError2FlutterError:aError] : @"");
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
            result(aError ? [self emError2FlutterError:aError] : @"");
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

@implementation ImChatManagerPlugin

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    // ??
    if ([@"" isEqualToString:call.method]) {
        result(@"");
    } else {
        result(FlutterMethodNotImplemented);
    }
}
@end

@implementation ImContactManagerPlugin

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    // ??
    if ([@"" isEqualToString:call.method]) {
        result(@"");
    } else {
        result(FlutterMethodNotImplemented);
    }
}
@end

@implementation ImGroupManagerPlugin

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    // ??
    if ([@"" isEqualToString:call.method]) {
        result(@"");
    } else {
        result(FlutterMethodNotImplemented);
    }
}
@end

@implementation ImChatRoomManagerPlugin

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    // ??
    if ([@"" isEqualToString:call.method]) {
        result(@"");
    } else {
        result(FlutterMethodNotImplemented);
    }
}
@end
