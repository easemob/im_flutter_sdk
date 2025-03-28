//
//  EMGroup+Helper.h
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2020/9/28.
//

#import "ChatHeaders.h"
#import "ModeToJson.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMGroup (Helper) <ModeToJson>
- (NSDictionary *)toJson;
@end

@interface EMGroupOptions (Helper) <ModeToJson>
+ (EMGroupOptions *)fromJson:(NSDictionary *)dict;
- (NSDictionary *)toJson;
+ (EMGroupStyle)styleFromInt:(int)style;
+ (int)styleToInt:(EMGroupStyle)style;
@end

@interface EMGroupSharedFile (Helper) <ModeToJson>
- (NSDictionary *)toJson;

@end

NS_ASSUME_NONNULL_END
