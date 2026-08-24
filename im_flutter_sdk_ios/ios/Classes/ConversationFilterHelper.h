//
//  EMConversationFilter+Helper.h
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2020/9/28.
//

#import "ChatHeaders.h"

NS_ASSUME_NONNULL_BEGIN


@interface EMConversationFilter (Helper)
+ (EMConversationFilter *)fromJson:(NSDictionary *)dict;
// 不需要提供toJson
//- (NSDictionary *)toJson;
+ (NSString *)getCursor:(NSDictionary *)dict;
+ (BOOL)getPinned:(NSDictionary *)dict;
+ (BOOL)hasMark:(NSDictionary *)dict;
+ (NSInteger)pageSize:(NSDictionary *)dict;
@end

NS_ASSUME_NONNULL_END
