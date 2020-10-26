//
//  EMStreamParam+Flutter.h
//  device_info
//
//  Created by 杜洁鹏 on 2020/10/26.
//

#import <Hyphenate/Hyphenate.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMStreamParam (Flutter)
+ (EMStreamParam *)fromJson:(NSDictionary *)aJson;
- (NSDictionary *)toJson;
@end

NS_ASSUME_NONNULL_END
