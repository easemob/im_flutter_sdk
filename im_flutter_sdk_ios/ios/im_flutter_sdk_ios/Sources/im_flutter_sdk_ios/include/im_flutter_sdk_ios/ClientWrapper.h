//
//  EMClientWrapper.h
//  
//
//  Created by 杜洁鹏 on 2019/10/8.
//

#import "Wrapper.h"
#import "ProgressManager.h"
NS_ASSUME_NONNULL_BEGIN

@interface ClientWrapper : Wrapper

- (void)sendDataToFlutter:(NSDictionary *)aData;
- (ProgressManager *)progressManager;
@end

NS_ASSUME_NONNULL_END
