//
//  EMCallStream+Flutter.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2020/11/18.
//

#import "EMCallStream+Flutter.h"

@implementation EMCallStream (Flutter)
- (NSDictionary *)toJson {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"streamId"] = self.streamId;
    data[@"streamName"] = self.streamName;
    data[@"memberName"] = self.memberName;
    data[@"enableVoice"] = @(self.enableVoice);
    data[@"enableVideo"] = @(self.enableVideo);
    data[@"ext"] = self.ext;
    data[@"type"] = @(self.type);
    
    return data;
}
@end
