//
//  EMFetchServerMessagesOption+Helper.h
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2023/5/15.
//

#import "ChatHeaders.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMFetchServerMessagesOption (Helper)
+ (EMFetchServerMessagesOption *)fromJson:(NSDictionary *)dict;
@end

NS_ASSUME_NONNULL_END
