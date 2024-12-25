//
//  EMGroupMessageAck+Helper.h
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2021/11/25.
//

#import "ChatHeaders.h"
#import "ModeToJson.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMGroupMessageAck (Helper) <ModeToJson>
- (NSDictionary *)toJson;
@end

NS_ASSUME_NONNULL_END
