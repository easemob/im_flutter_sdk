//
//  EMMessage+Flutter.h
//  Pods
//
//  Created by 杜洁鹏 on 2020/9/11.
//

#import <HyphenateChat/HyphenateChat.h>
#import "EaseToFlutterJson.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMChatMessage (Flutter) <EaseToFlutterJson>
+ (EMChatMessage *)fromJson:(NSDictionary *)aJson;
- (NSDictionary *)toJson;
@end

@interface EMMessageBody (Flutter) <EaseToFlutterJson>
+ (EMMessageBody *)fromJson:(NSDictionary *)aJson;
- (NSDictionary *)toJson;
+ (EMMessageBodyType)typeFromString:(NSString *)aStrType;

@end

NS_ASSUME_NONNULL_END
