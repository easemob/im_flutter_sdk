//
//  EMMessagePinInfo+Helper.h
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2020/9/28.
//

#import "ChatHeaders.h"
#import "ModeToJson.h"

NS_ASSUME_NONNULL_BEGIN


@interface EMMessagePinInfo (Helper) <ModeToJson>
+ (EMMessagePinInfo *)fromJson:(NSDictionary *)dict;
- (NSDictionary *)toJson;
@end

NS_ASSUME_NONNULL_END
