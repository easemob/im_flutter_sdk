//
//  EMCallSession+Flutter.m
//  Runner
//
//  Created by 杜洁鹏 on 2020/10/19.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

#import "EMCallSession+Flutter.h"

@implementation EMCallSession (Flutter)

- (NSDictionary *)toJson {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"callId"] = self.callId;
    dict[@"localName"] = self.localName;
    dict[@"callType"] = @(self.type);
    dict[@"isCaller"] = @(self.isCaller);
    dict[@"remoteName"] = self.remoteName;
    dict[@"status"] = @(self.status);
    dict[@"connectType"] = @(self.connectType);
    dict[@"videoLatency"] = @([self chargeInfo:self.videoLatency]);
    dict[@"localVideoFrameRate"] = @([self chargeInfo:self.localVideoFrameRate]);
    dict[@"remoteVideoFrameRate"] = @([self chargeInfo:self.remoteVideoFrameRate]);
    dict[@"localVideoBitrate"] = @([self chargeInfo:self.localVideoBitrate]);
    dict[@"remoteVideoBitrate"] = @([self chargeInfo:self.remoteVideoBitrate]);
    dict[@"localVideoLostRateInPercent"] = @([self chargeInfo:self.localVideoLostRateInPercent]);
    dict[@"remoteVideoLostRateInPercent"] = @([self chargeInfo:self.remoteVideoLostRateInPercent]);
    dict[@"remoteVideoResolution.width"] = @([self chargeInfo:self.remoteVideoResolution.width]);
    dict[@"remoteVideoResolution.height"] = @([self chargeInfo:self.remoteVideoResolution.height]);
    dict[@"serverVideoId"] = self.serverVideoId;
    dict[@"willRecord"] = @(self.willRecord);
    dict[@"ext"] = self.ext;
    
    return dict;
}

- (int)chargeInfo:(int) info{
    return self.connectType == EMCallConnectTypeNone ? -1 : info;
}

@end
