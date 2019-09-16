#import "ImFlutterSdkPlugin.h"

@implementation ImFlutterSdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    [self registerClientChannel:registrar];
    [self registerChatManagerChannel:registrar];
    [self registerContactManagerChannel:registrar];
}

// em_client
+ (void)registerClientChannel:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                        methodChannelWithName:@"em_client"
                                               binaryMessenger:[registrar messenger]];
    ImClientPlugin* instance = [[ImClientPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

// em_chat_manager
+ (void)registerChatManagerChannel:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                        methodChannelWithName:@"em_chat_manager"
                                               binaryMessenger:[registrar messenger]];
    ImChatManagerPlugin* instance = [[ImChatManagerPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

// em_contactmanager
+ (void)registerContactManagerChannel:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                        methodChannelWithName:@"em_contact_manager"
                                            binaryMessenger:[registrar messenger]];
    ImContactManagerPlugin* instance = [[ImContactManagerPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

@end

@implementation ImClientPlugin

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    // ??
    if ([@"EMClient.getInstance().init()" isEqualToString:call.method]) {
        result(@"");
    } else {
        result(FlutterMethodNotImplemented);
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