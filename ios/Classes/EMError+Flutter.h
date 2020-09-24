//
//  EMError+Flutter.h
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2020/9/23.
//

#import <Hyphenate/Hyphenate.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMError (Flutter)
- (NSDictionary *)toJson;
@end

NS_ASSUME_NONNULL_END
