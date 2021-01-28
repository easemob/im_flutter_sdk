//
//  EMGroup+Flutter.h
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2020/9/28.
//

#import <HyphenateLite/HyphenateLite.h>
#import "EaseToFlutterJson.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMGroup (Flutter) <EaseToFlutterJson>
- (NSDictionary *)toJson;
+ (EMGroupPermissionType)premissionTypeFromInt:(int)type;
+ (int)premissionTypeToInt:(EMGroupPermissionType)type;
@end


@interface EMGroupOptions (Flutter) <EaseToFlutterJson>
+ (EMGroupOptions *)formJson:(NSDictionary *)dict;
- (NSDictionary *)toJson;
+ (EMGroupStyle)styleFromInt:(int)style;
+ (int)styleToInt:(EMGroupStyle)style;
@end

@interface EMGroupSharedFile (Flutter) <EaseToFlutterJson>
- (NSDictionary *)toJson;

@end

NS_ASSUME_NONNULL_END
