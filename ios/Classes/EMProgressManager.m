//
//  EMProgressManager.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2022/5/23.
//
#import <Flutter/Flutter.h>
#import <HyphenateChat/HyphenateChat.h>
#import "EMProgressManager.h"
#import "EMError+Helper.h"

@interface EMProgressManager ()

@end


@implementation EMProgressManager

- (instancetype)initWithChannelName:(NSString *)aChannelName
                          registrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    if(self = [super initWithChannelName:aChannelName
                               registrar:registrar]) {

    }
    return self;
}

- (void)sendDownloadSuccessToFlutter:(NSString *)fileId path:(NSString *)savePath {
    [self.channel invokeMethod:@"onSuccess" arguments:@{@"fileId":fileId, @"savePath": savePath}];
}

- (void)sendDownloadProgressToFlutter:(NSString *)fileId progress:(int)progress {
    [self.channel invokeMethod:@"onProgress" arguments:@{@"fileId":fileId, @"progress": @(progress)}];
}

- (void)sendDownloadErrorToFlutter:(NSString *)fileId error:(EMError *)error {
    [self.channel invokeMethod:@"onError" arguments:@{@"fileId":fileId, @"error": [error toJson]}];
}


- (void)unRegisterEaseListener {
}


@end
