//
//  EMClientWrapper.h
//  
//
//  Created by 杜洁鹏 on 2019/10/8.
//

#import "EMWrapper.h"
#import "EMProgressManager.h"
NS_ASSUME_NONNULL_BEGIN

@interface EMClientWrapper : EMWrapper

- (void)sendDataToFlutter:(NSDictionary *)aData;
- (EMProgressManager *)progressManager;
@end

NS_ASSUME_NONNULL_END
