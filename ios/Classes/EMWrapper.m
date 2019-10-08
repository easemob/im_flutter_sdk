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
        FlutterMethodChannel* channel = [FlutterMethodChannel
                                methodChannelWithName:aChannelName
                                      binaryMessenger:[registrar messenger]];
        self.channel = channel;
        [registrar addMethodCallDelegate:self channel:channel];
    }
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
}
@end
