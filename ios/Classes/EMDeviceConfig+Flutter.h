//
//  EMDeviceConfig+Flutter.h
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2020/10/12.
//

#import <HyphenateLite/HyphenateLite.h>
#import "EaseToFlutterJson.h"
NS_ASSUME_NONNULL_BEGIN

@interface EMDeviceConfig (Flutter)<EaseToFlutterJson>
- (NSDictionary *)toJson;
@end

NS_ASSUME_NONNULL_END
