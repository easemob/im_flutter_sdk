//
//  EMMessage+Flutter.h
//  Pods
//
//  Created by 杜洁鹏 on 2020/9/11.
//

#import <Hyphenate/Hyphenate.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMMessage (Flutter)
+ (EMMessage *)fromJson:(NSDictionary *)aJson;
- (NSDictionary *)toJson;
@end


@interface EMMessageBody (Flutter)
+ (EMMessageBody *)fromJson:(NSDictionary *)aJson;
- (NSDictionary *)toJson;
+ (EMMessageBodyType)typeFromString:(NSString *)aStrType;

@end



NS_ASSUME_NONNULL_END
