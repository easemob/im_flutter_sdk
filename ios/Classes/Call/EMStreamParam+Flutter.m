//
//  EMStreamParam+Flutter.m
//  device_info
//
//  Created by 杜洁鹏 on 2020/10/26.
//

#import "EMStreamParam+Flutter.h"

@implementation EMStreamParam (Flutter)
+ (EMStreamParam *)fromJson:(NSDictionary *)aJson {
    EMStreamParam *stream = [[EMStreamParam alloc] initWithStreamName:aJson[@"streamId"]];
    stream.type = [aJson[@"steamType"] intValue];
    stream.enableVideo = [aJson[@"enableVideo"] boolValue];
    stream.isMute = [aJson[@"isMute"] boolValue];
    stream.isBackCamera = [aJson[@"isBackCamera"] boolValue];
    stream.maxVideoKbps = [aJson[@"maxVideoKbps"] boolValue];
    stream.minVideoKbps = [aJson[@"minVideoKbps"] boolValue];
    stream.maxAudioKbps = [aJson[@"maxAudioKbps"] boolValue];
    
    
    return stream;
}

- (NSDictionary *)toJson {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"streamName"] = self.streamName;
    data[@"type"] = @(self.type);
    data[@"enableVideo"] = @(self.enableVideo);
    data[@"isMute"] = @(self.isMute);
    data[@"isBackCamera"] = @(self.isBackCamera);
    data[@"maxVideoKbps"] = @(self.maxVideoKbps);
    data[@"minVideoKbps"] = @(self.minVideoKbps);
    data[@"maxAudioKbps"] = @(self.maxAudioKbps);
    
    return nil;
}

@end
