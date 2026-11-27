//
//  EMGroup+Helper.h
//  im_flutter_sdk
//

#import "ChatHeaders.h"
#import "ModeToJson.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMGroup (Helper) <ModeToJson>
- (NSDictionary *)toJson;
@end

@interface EMGroupConfigs (Helper) <ModeToJson>
+ (EMGroupConfigs *)fromJson:(NSDictionary *)dict;
- (NSDictionary *)toJson;
@end

@interface EMGroupSharedFile (Helper) <ModeToJson>
- (NSDictionary *)toJson;
@end

NS_ASSUME_NONNULL_END
