//
//  EMUserInfo+Helper.h
//  im_flutter_sdk
//
//  Created by liujinliang on 2021/4/28.
//

#import "ChatHeaders.h"
#import "ModeToJson.h"


NS_ASSUME_NONNULL_BEGIN

@interface EMUserInfo (Helper)<ModeToJson>
-(NSDictionary *)toJson;
+ (EMUserInfo *)fromJson:(NSDictionary *)aJson;

@end

NS_ASSUME_NONNULL_END
