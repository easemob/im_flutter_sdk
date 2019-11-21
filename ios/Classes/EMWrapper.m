//
//  EMWrapper.m
//  
//
//  Created by 杜洁鹏 on 2019/10/8.
//

#import "EMWrapper.h"


@implementation EMWrapper

- (instancetype)initWithChannelName:(NSString *)aChannelName
                          registrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    if(self = [super init]) {
        self.flutterPluginRegister = registrar;
        FlutterJSONMethodCodec *codec = [FlutterJSONMethodCodec sharedInstance];
        FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:aChannelName
                                                                    binaryMessenger:[registrar messenger]
                                                                              codec:codec];
        self.channel = channel;
        [registrar addMethodCallDelegate:self channel:channel];
    }
    return self;
}

- (void)wrapperCallBack:(FlutterResult)result
                  error:(EMError *__nullable)error
               userInfo:(NSDictionary *__nullable)userInfo {
    if (result) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        if (!error) {
            dic[@"success"] = @YES;
            if (userInfo) {
                [dic addEntriesFromDictionary:userInfo];
            }
        }else {
            dic[@"success"] = @NO;
            dic[@"code"] = @(error.code);
            dic[@"desc"] = error.errorDescription;
        }
        result(dic);
    }
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    result(FlutterMethodNotImplemented);
}


+ (void)registerWithRegistrar:(nonnull NSObject<FlutterPluginRegistrar> *)registrar {
    
}

@end
