//
//  ImFlutterSDKLog.m
//  
//
//  Created by 杜洁鹏 on 2019/9/20.
//

#import "ImFlutterSDKLog.h"
#import "ImFlutterSDKDefine.h"

@interface ImFlutterSDKLog()
@property (strong, nonatomic) FlutterMethodChannel *channel;
@end

@implementation ImFlutterSDKLog

static ImFlutterSDKLog *sdkLog;

+ (ImFlutterSDKLog *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sdkLog = [[ImFlutterSDKLog alloc] init];
    });
    return sdkLog;
}

+ (ImFlutterSDKLog *)registrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    ImFlutterSDKLog *log = [self sharedInstance];
    log.channel = [FlutterMethodChannel
                   methodChannelWithName:@"com.easemob.im/em_log"
                            binaryMessenger:[registrar messenger]];
    [registrar addMethodCallDelegate:log channel:log.channel];
    return log;
}

+ (void)logD:(NSString *)aLog {
    [[ImFlutterSDKLog sharedInstance] logD:aLog];
}

+ (void)logE:(NSString *)aLog {
    [[ImFlutterSDKLog sharedInstance] logE:aLog];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
}

- (void)logD:(NSString *)aLog {
    [_channel invokeMethod:EMMethodKeyDebugLog arguments:@{@"log" : aLog}];
}
- (void)logE:(NSString *)aLog {
    [_channel invokeMethod:EMMethodKeyErrorLog arguments:@{@"log" : aLog}];
}

@end
