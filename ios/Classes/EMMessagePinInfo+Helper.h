//
//  EMMessagePinInfo+Helper.h
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2020/9/28.
//

#import <HyphenateChat/HyphenateChat.h>
#import "EaseModeToJson.h"

NS_ASSUME_NONNULL_BEGIN


@interface EMMessagePinInfo (Helper) <EaseModeToJson>
+ (EMMessagePinInfo *)fromJson:(NSDictionary *)dict;
- (NSDictionary *)toJson;
@end

NS_ASSUME_NONNULL_END
