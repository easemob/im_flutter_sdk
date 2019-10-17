//
//  EMGroupManagerWrapper.m
//  FlutterTest
//
//  Created by 杜洁鹏 on 2019/10/17.
//  Copyright © 2019 Easemob. All rights reserved.
//

#import "EMGroupManagerWrapper.h"
#import <Hyphenate/Hyphenate.h>
#import "EMSDKMethod.h"

@interface EMGroupManagerWrapper () <EMGroupManagerDelegate>

@end

@implementation EMGroupManagerWrapper

- (instancetype)initWithChannelName:(NSString *)aChannelName
                          registrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    if(self = [super initWithChannelName:aChannelName
                                   registrar:registrar]) {
        
        [EMClient.sharedClient.groupManager addDelegate:self delegateQueue:nil];
    }
    return self;
}


#pragma mark - FlutterPlugin

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    
    result(FlutterMethodNotImplemented);
}

#pragma mark - EMGroupManagerDelegate


@end
