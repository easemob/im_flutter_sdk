//
//  EMContact+Helper.h
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2023/11/13.
//

#import "ChatHeaders.h"
#import "ModeToJson.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMContact (Helper)  <ModeToJson>
+ (EMContact *)fromJson:(NSDictionary *)aJson;
- (NSDictionary *)toJson;
@end

NS_ASSUME_NONNULL_END
