//
//  EMFetchServerMessagesOption+Helper.h
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2023/5/15.
//

#import <HyphenateChat/HyphenateChat.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMFetchServerMessagesOption (Helper)
+ (EMFetchServerMessagesOption *)formJson:(NSDictionary *)dict;
@end

NS_ASSUME_NONNULL_END
