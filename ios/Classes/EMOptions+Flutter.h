//
//  EMOptions+Flutter.h
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2020/10/12.
//

#import <HyphenateChat/HyphenateChat.h>
#import "EaseToFlutterJson.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMOptions (Flutter) <EaseToFlutterJson>
- (NSDictionary *)toJson;
+ (EMOptions *)fromJson:(NSDictionary *)aJson;
@end

NS_ASSUME_NONNULL_END
