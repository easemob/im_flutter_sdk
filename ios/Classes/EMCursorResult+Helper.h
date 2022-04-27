//
//  EMCursorResult+Helper.h
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2020/9/27.
//

#import <HyphenateChat/HyphenateChat.h>
#import "EaseModeToJson.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMCursorResult (Helper) <EaseModeToJson>
- (NSDictionary *)toJson;
@end

NS_ASSUME_NONNULL_END
