//
//  EMDeviceConfig+Helper.h
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2020/10/12.
//

#import <HyphenateChat/HyphenateChat.h>
#import "EaseModeToJson.h"
NS_ASSUME_NONNULL_BEGIN

@interface EMDeviceConfig (Helper) <EaseModeToJson>
- (NSDictionary *)toJson;
@end

NS_ASSUME_NONNULL_END
