//
//  EMChatMessage+Helper.h
//  Pods
//
//  Created by 杜洁鹏 on 2020/9/11.
//

#import "ChatHeaders.h"
#import "ModeToJson.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMChatMessage (Helper) <ModeToJson>
+ (EMChatMessage *)fromJson:(NSDictionary *)aJson;
- (NSDictionary *)toJson;

@end

@interface EMMessageBody (Helper) <ModeToJson>
+ (EMMessageBody *)fromJson:(NSDictionary *)aJson;
- (NSDictionary *)toJson;
@end

@interface EMTextMessageBody (Helper)
+ (EMTextMessageBody *)fromJson:(NSDictionary *)aJson;
- (NSDictionary *)toJson;
@end

NS_ASSUME_NONNULL_END
