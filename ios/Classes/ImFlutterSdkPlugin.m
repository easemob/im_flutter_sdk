#import "ImFlutterSdkPlugin.h"
#import "ImFlutterSDKDefine.h"

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
}

// em_client
+ (void)registerClientChannel:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                        methodChannelWithName:@"em_client"
                                               binaryMessenger:[registrar messenger]];
    ImClientPlugin* instance = [[ImClientPlugin alloc] initWithChannel:channel];
    [registrar addMethodCallDelegate:instance channel:channel];
}

// em_chat_manager
+ (void)registerChatManagerChannel:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                        methodChannelWithName:@"em_chat_manager"
                                               binaryMessenger:[registrar messenger]];
    ImChatManagerPlugin* instance = [[ImChatManagerPlugin alloc] initWithChannel:channel];
    [registrar addMethodCallDelegate:instance channel:channel];
}

// em_contact_manager
+ (void)registerContactManagerChannel:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                        methodChannelWithName:@"em_contact_manager"
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

@implementation ImClientPlugin

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    // ??
    if ([EMMethodKeyInit isEqualToString:call.method]) {
        result(@"");
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)setupSDK:(NSString *)aAppKey {

}

- (void)createAccount:(id)arg result:(FlutterResult)result {
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSString username = param[@"username"];
        NSString password = param[@"password"];
        [[EMClient sharedClient] registerWithUsername:username
                                             password:password
                                           completion:^(NSString *aUsername, EMError *aError)
                                           {
                                                if (!aError) {
                                                    result(@"");
                                                }else {
                                                    result(@"error");
                                                }
                                            }];
    }
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
