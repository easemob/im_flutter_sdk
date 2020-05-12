//
//  EMCallPlugin.m
//  Runner
//
//  Created by 东海 on 2020/5/12.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

#import "EMCallPlugin.h"
#import "EMCallManagerWrapper.h"
#import "EMConferenceManagerWrapper.h"


#define EMChannelName(name) [NSString stringWithFormat:@"com.easemob.im/%@",name]
@implementation EMCallPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
    EMCallManagerWrapper *callWrapper = [[EMCallManagerWrapper alloc] initWithChannelName:EMChannelName(@"em_call_manager") registrar:registrar];
    EMConferenceManagerWrapper *conferenceWrapper = [[EMConferenceManagerWrapper alloc] initWithChannelName:EMChannelName(@"em_conference_manager") registrar:registrar];
#pragma clang diagnostic pop
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
}

@end
