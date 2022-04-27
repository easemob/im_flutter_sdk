//
//  EMUserInfo+Helper.h
//  im_flutter_sdk
//
//  Created by liujinliang on 2021/4/28.
//

#import <HyphenateChat/HyphenateChat.h>
#import "EaseModeToJson.h"


NS_ASSUME_NONNULL_BEGIN

@interface EMUserInfo (Helper)<EaseModeToJson>
-(NSDictionary *)toJson;
+ (EMUserInfo *)fromJson:(NSDictionary *)aJson;

@end

NS_ASSUME_NONNULL_END
