//
//  EMCursorResult+Flutter.h
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2020/9/27.
//

#import <HyphenateChat/HyphenateChat.h>
#import "EaseToFlutterJson.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMCursorResult (Flutter) <EaseToFlutterJson>
- (NSDictionary *)toJson;
@end

NS_ASSUME_NONNULL_END
