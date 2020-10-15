//
//  EMPushOptions+Flutter.h
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2020/10/15.
//

#import <Hyphenate/Hyphenate.h>
#import "EaseToFlutterJson.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMPushOptions (Flutter) <EaseToFlutterJson>
- (NSDictionary *)toJson;
@end

NS_ASSUME_NONNULL_END
