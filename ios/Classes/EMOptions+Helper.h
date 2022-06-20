//
//  EMOptions+Helper.h
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2020/10/12.
//

#import <HyphenateChat/HyphenateChat.h>
#import "EaseModeToJson.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMOptions (Helper) <EaseModeToJson>
- (NSDictionary *)toJson;
+ (EMOptions *)fromJson:(NSDictionary *)aJson;
@end

NS_ASSUME_NONNULL_END
