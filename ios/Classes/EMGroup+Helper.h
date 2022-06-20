//
//  EMGroup+Helper.h
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2020/9/28.
//

#import <HyphenateChat/HyphenateChat.h>
#import "EaseModeToJson.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMGroup (Helper) <EaseModeToJson>
- (NSDictionary *)toJson;
+ (EMGroupPermissionType)premissionTypeFromInt:(int)type;
+ (int)premissionTypeToInt:(EMGroupPermissionType)type;
@end

@interface EMGroupOptions (Helper) <EaseModeToJson>
+ (EMGroupOptions *)formJson:(NSDictionary *)dict;
- (NSDictionary *)toJson;
+ (EMGroupStyle)styleFromInt:(int)style;
+ (int)styleToInt:(EMGroupStyle)style;
@end

@interface EMGroupSharedFile (Helper) <EaseModeToJson>
- (NSDictionary *)toJson;

@end

NS_ASSUME_NONNULL_END
