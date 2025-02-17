//
//  EMSilentModeParam+Helper.h
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2022/7/8.
//

#import "ChatHeaders.h"


NS_ASSUME_NONNULL_BEGIN

@interface EMSilentModeParam (Helper)
+ (EMSilentModeParam *)fromJson:(NSDictionary *)dict;
+ (int)remindTypeToInt:(EMPushRemindType)type;

@end

NS_ASSUME_NONNULL_END
