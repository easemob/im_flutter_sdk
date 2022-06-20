//
//  EMConversation+Helper.h
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2020/9/21.
//

#import <HyphenateChat/HyphenateChat.h>
#import "EaseModeToJson.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMConversation (Helper) <EaseModeToJson>
- (NSDictionary *)toJson;
+ (int)typeToInt:(EMConversationType)aType;
+ (EMConversationType)typeFromInt:(int)aType;
@end

NS_ASSUME_NONNULL_END
