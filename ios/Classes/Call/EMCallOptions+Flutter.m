//
//  EMCallOptions+Flutter.m
//  Runner
//
//  Created by 杜洁鹏 on 2020/10/19.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

#import "EMCallOptions+Flutter.h"

@implementation EMCallOptions (Flutter)

+ (EMCallOptions *)fromJson:(NSDictionary *)aJson {
    EMCallOptions *options = [[EMCallOptions alloc] init];
    options.pingInterval = [aJson[@"pingInterval"] intValue];
    options.isSendPushIfOffline = [aJson[@"isSendPushIfOffline"] boolValue];
    options.offlineMessageText = aJson[@"offlineMessageText"];
    options.maxVideoKbps = [aJson[@"maxVideoKbps"] intValue];
    options.minVideoKbps = [aJson[@"minVideoKbps"] intValue];
    options.maxVideoFrameRate = [aJson[@"maxVideoFrameRate"] intValue];
    options.maxAudioKbps = [aJson[@"maxAudioKbps"] intValue];
    options.audioCustomSamples = [aJson[@"audioCustomSamples"] intValue];
    options.audioCustomChannels = [aJson[@"audioCustomChannels"] intValue];
    options.isClarityFirst = [aJson[@"isClarityFirst"] boolValue];
    return options;
}

- (NSDictionary *)toJson {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"pingInterval"] = @(self.pingInterval);
    data[@"isSendPushIfOffline"] = @(self.isSendPushIfOffline);
    data[@"offlineMessageText"] = self.offlineMessageText;
    data[@"maxVideoKbps"] = @(self.maxVideoKbps);
    data[@"minVideoKbps"] = @(self.minVideoKbps);
    data[@"maxVideoFrameRate"] = @(self.maxVideoFrameRate);
    data[@"maxAudioKbps"] = @(self.maxAudioKbps);
    data[@"audioCustomSamples"] = @(self.audioCustomSamples);
    data[@"audioCustomChannels"] = @(self.audioCustomChannels);
    data[@"isClarityFirst"] = @(self.isClarityFirst);

    
    return data;
}

@end
