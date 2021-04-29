//
//  EMUserInfo+Flutter.h
//  im_flutter_sdk
//
//  Created by liujinliang on 2021/4/28.
//

#import <HyphenateChat/HyphenateChat.h>
#import "EaseToFlutterJson.h"


NS_ASSUME_NONNULL_BEGIN

@interface EMUserInfo (Flutter)<EaseToFlutterJson>
-(NSDictionary *)toJson;
+ (EMUserInfo *)fromJson:(NSDictionary *)aJson;

@end

NS_ASSUME_NONNULL_END
