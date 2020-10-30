//
//  EMWrapper.m
//  
//
//  Created by 杜洁鹏 on 2019/10/8.
//

#import "EMWrapper.h"
#import "EMError+Flutter.h"

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
            channelName:(NSString *)aChannelName
                  error:(EMError *)error
                 object:(NSObject *)aObj
{
    if (result) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"error"] = [error toJson];
        if (aObj) {
            dic[aChannelName] = aObj;
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
