//
//  EMChatThreadEvent+Helper.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2022/6/6.
//

#import "ThreadEventHelper.h"
#import "ThreadHelper.h"
#import "EnumTools.h"

@implementation EMChatThreadEvent (Helper)
- (nonnull NSDictionary *)toJson {
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    ret[@"from"] = self.from;
    ret[@"type"] = @([self getIntOperation]);
    ret[@"thread"] = [self.chatThread toJson];
    return ret;
}


- (NSInteger)getIntOperation {
    return [EnumTools threadOperationToInt:self.type];
}

@end
