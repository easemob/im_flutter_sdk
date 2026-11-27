//
//  EMSearchServerMessageResult+Helper.h
//  im_flutter_sdk
//
//  4.24.0
//

#import "ChatHeaders.h"
#import "ModeToJson.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMSearchServerMessageResult (Helper) <ModeToJson>
- (NSDictionary *)toJson;
@end

NS_ASSUME_NONNULL_END
