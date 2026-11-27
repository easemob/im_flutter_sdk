//
//  GroupMemberInfoHelper.h
//  im_flutter_sdk_ios
//
//  Created by 杜洁鹏 on 2025/5/7.
//

#import "ChatHeaders.h"
#import "ModeToJson.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMGroupMemberInfo (Helper) <ModeToJson>
- (NSDictionary *)toJson;
@end


NS_ASSUME_NONNULL_END
