//
//  EMChatThreadEvent+Helper.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2022/6/6.
//

#import "EMChatThreadEvent+Helper.h"
#import "EMChatThread+Helper.h"

@implementation EMChatThreadEvent (Helper)
- (nonnull NSDictionary *)toJson {
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    ret[@"from"] = self.from;
    ret[@"type"] = @([self getIntOperation]);
    ret[@"thread"] = [self.chatThread toJson];
    return ret;
}


- (int)getIntOperation {
    int ret = 0;
    switch (self.type) {
        case EMThreadOperationUnknown:
            ret = 0;
            break;
        case EMThreadOperationCreate:
            ret = 1;
            break;
        case EMThreadOperationUpdate:
            ret = 2;
            break;
        case EMThreadOperationDelete:
            ret = 3;
            break;
        case EMThreadOperationUpdate_msg:
            ret = 4;
            break;
    }
    
    return ret;
}

@end
