//
//  EMClientWrapper.h
//  
//
//  Created by 杜洁鹏 on 2019/10/8.
//

#import "EMWrapper.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMClientWrapper : EMWrapper
+ (void)setDeviceToken:(NSData *)aDeviceToken;
@end

NS_ASSUME_NONNULL_END
