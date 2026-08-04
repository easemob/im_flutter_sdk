//
//  Helper.h
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2025/2/17.
//

#import <Foundation/Foundation.h>
#import "ChatHeaders.h"
NS_ASSUME_NONNULL_BEGIN

@interface Helper : NSObject
+ (void)mergeMessage:(EMChatMessage *)msg withDBMessage:(EMChatMessage *)dbMsg;
@end

NS_ASSUME_NONNULL_END
