//
//  EMCallPluginWrapper.h
//  Runner
//
//  Created by 杜洁鹏 on 2021/1/21.
//  Copyright © 2021 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import <Hyphenate/Hyphenate.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMCallPluginWrapper : NSObject <FlutterPlugin>
@property (nonatomic, strong) FlutterMethodChannel *channel;
@property (nonatomic, strong) NSObject<FlutterPluginRegistrar> *flutterPluginRegister;

- (instancetype)initWithChannelName:(NSString *)aChannelName
                          registrar:(NSObject<FlutterPluginRegistrar>*)registrar;



- (void)wrapperCallBack:(FlutterResult)result
                    error:(EMError *__nullable)error
                 userInfo:(NSDictionary *__nullable)userInfo;

@end

NS_ASSUME_NONNULL_END
