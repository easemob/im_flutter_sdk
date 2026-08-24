//
//  EMChatroom+Helper.h
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2020/9/27.
//

#import "ChatHeaders.h"
#import "ModeToJson.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMChatroom (Helper) <ModeToJson>
- (NSDictionary *)toJson;
@end

NS_ASSUME_NONNULL_END
