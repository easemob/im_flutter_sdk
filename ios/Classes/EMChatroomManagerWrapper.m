//
//  EMChatroomManagerWrapper.m
//  FlutterTest
//
//  Created by 杜洁鹏 on 2019/10/17.
//  Copyright © 2019 Easemob. All rights reserved.
//

#import "EMChatroomManagerWrapper.h"
#import <Hyphenate/Hyphenate.h>
#import "EMSDKMethod.h"

@interface EMChatroomManagerWrapper () <EMChatroomManagerDelegate>

@end

@implementation EMChatroomManagerWrapper

- (instancetype)initWithChannelName:(NSString *)aChannelName
                          registrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    if(self = [super initWithChannelName:aChannelName
                                   registrar:registrar]) {
        
        [EMClient.sharedClient.roomManager addDelegate:self delegateQueue:nil];
    }
    return self;
}


#pragma mark - FlutterPlugin

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {

    result(FlutterMethodNotImplemented);
}

#pragma mark - EMChatroomManagerDelegate


@end
