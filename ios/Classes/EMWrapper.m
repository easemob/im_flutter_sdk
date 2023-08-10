//
//  EMWrapper.m
//  
//
//  Created by 杜洁鹏 on 2019/10/8.
//

#import "EMWrapper.h"
#import "EMError+Helper.h"
#define easemob_dispatch_main_async_safe(block)\
    if ([NSThread isMainThread]) {\
        block();\
    } else {\
        dispatch_async(dispatch_get_main_queue(), block);\
    }


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

        easemob_dispatch_main_async_safe(^(){
            result(dic);
        });
    }
}

- (void)unRegisterEaseListener {
   
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    result(FlutterMethodNotImplemented);
}


+ (void)registerWithRegistrar:(nonnull NSObject<FlutterPluginRegistrar> *)registrar {

}

- (void)detachFromEngineForRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    [self unRegisterEaseListener];
}

-(void)dealloc{
    NSLog(@"wrapper dealloc");
}

@end
