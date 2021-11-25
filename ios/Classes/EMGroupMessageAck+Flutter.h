//
//  EMGroupMessageAck+Flutter.h
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2021/11/25.
//

#import <HyphenateChat/HyphenateChat.h>
#import "EaseToFlutterJson.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMGroupMessageAck (Flutter) <EaseToFlutterJson>
- (NSDictionary *)toJson;
@end

NS_ASSUME_NONNULL_END
