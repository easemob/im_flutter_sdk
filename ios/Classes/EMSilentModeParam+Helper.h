//
//  EMSilentModeParam+Helper.h
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2022/7/8.
//

#import <HyphenateChat/HyphenateChat.h>


NS_ASSUME_NONNULL_BEGIN

@interface EMSilentModeParam (Helper)
+ (EMSilentModeParam *)formJson:(NSDictionary *)dict;
+ (int)remindTypeToInt:(EMPushRemindType)type;

@end

NS_ASSUME_NONNULL_END
