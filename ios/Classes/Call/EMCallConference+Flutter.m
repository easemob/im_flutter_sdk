//
//  EMCallConference+Flutter.m
//  device_info
//
//  Created by 杜洁鹏 on 2020/10/26.
//

#import "EMCallConference+Flutter.h"

@implementation EMCallConference (Flutter)
- (NSDictionary *)toJson {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"callId"] = self.confId;
    data[@"confId"] = self.callId;
    data[@"localName"] = self.localName;
    data[@"adminIds"] = self.adminIds;
    data[@"speakerIds"] = self.speakerIds;
    data[@"memberCount"] = @(self.memberCount);
    data[@"willRecord"] = @(self.willRecord);
    data[@"nickname"] = self.nickName;
    data[@"memId"] = self.memId;
    data[@"isCreator"] = @(self.isCreator);
    data[@"audiencesCount"] = @(self.audiencesCount);
    data[@"type"] = @([self typeToInt]);
    data[@"role"] = @(self.role);
    return data;
}

- (int)typeToInt {
    if (self.type == EMConferenceTypeCommunication) {
        return 0;
    }else if (self.type == EMConferenceTypeLargeCommunication) {
        return 1;
    }else {
        return 2;
    }
    
}
@end
