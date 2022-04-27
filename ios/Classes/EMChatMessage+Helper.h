//
//  EMChatMessage+Helper.h
//  Pods
//
//  Created by 杜洁鹏 on 2020/9/11.
//

#import <HyphenateChat/HyphenateChat.h>
#import "EaseModeToJson.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMChatMessage (Helper) <EaseModeToJson>
+ (EMChatMessage *)fromJson:(NSDictionary *)aJson;
- (NSDictionary *)toJson;
@end

@interface EMMessageBody (Helper) <EaseModeToJson>
+ (EMMessageBody *)fromJson:(NSDictionary *)aJson;
- (NSDictionary *)toJson;
+ (EMMessageBodyType)typeFromString:(NSString *)aStrType;

@end

NS_ASSUME_NONNULL_END
