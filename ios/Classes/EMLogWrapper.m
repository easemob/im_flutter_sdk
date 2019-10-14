//
//  EMLogWrapper.m
//  
//
//  Created by 杜洁鹏 on 2019/10/14.
//

#import "EMLogWrapper.h"
#import "EMSDKMethod.h"

@interface EMLogWrapper()
@property (strong, nonatomic) FlutterMethodChannel *channel;
@end

@implementation EMLogWrapper

static EMLogWrapper *sdkLog;

+ (EMLogWrapper *)registrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    EMLogWrapper *log = [self sharedInstance];
    log.channel = [FlutterMethodChannel
                   methodChannelWithName:@"com.easemob.im/em_log"
                            binaryMessenger:[registrar messenger]];
    [registrar addMethodCallDelegate:log channel:log.channel];
    return log;
}


+ (EMLogWrapper *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sdkLog = [[EMLogWrapper alloc] init];
    });
    return sdkLog;
}

+ (void)logD:(NSString *)aLog {
    [[EMLogWrapper sharedInstance] logD:aLog];
}

+ (void)logE:(NSString *)aLog {
    [[EMLogWrapper sharedInstance] logE:aLog];
}

- (void)logD:(NSString *)aLog {
    [self.channel invokeMethod:EMMethodKeyDebugLog arguments:@{@"log" : aLog}];
}
- (void)logE:(NSString *)aLog {
    [self.channel invokeMethod:EMMethodKeyErrorLog arguments:@{@"log" : aLog}];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
}

@end
