#import "ImFlutterSdkPlugin.h"

@implementation ImFlutterSdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    // em_client
    FlutterMethodChannel* clientChannel = [FlutterMethodChannel
                                        methodChannelWithName:@"em_client"
                                               binaryMessenger:[registrar messenger]];
    ImFlutterSdkPlugin* instance = [[ImFlutterSdkPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:clientChannel];


    // em_chatManager
    FlutterMethodChannel* chatManagerChannel = [FlutterMethodChannel
                                        methodChannelWithName:@"em_chat_manager"
                                           binaryMessenger:[registrar messenger]];
    ImChatManagerPlugin* chatManagerInstance = [[ImChatManagerPlugin alloc] init];
    [registrar addMethodCallDelegate:chatManagerInstance channel:chatManagerChannel];

    // em_chatManager
    FlutterMethodChannel* contactManagerChannel = [FlutterMethodChannel
                                        methodChannelWithName:@"em_contact_manager"
                                            binaryMessenger:[registrar messenger]];
    ImContactManagerPlugin* contactManagerInstance = [[ImContactManagerPlugin alloc] init];
    [registrar addMethodCallDelegate:chatManagerInstance channel:contactManagerChannel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    // ??
    if ([@"" isEqualToString:call.method]) {
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