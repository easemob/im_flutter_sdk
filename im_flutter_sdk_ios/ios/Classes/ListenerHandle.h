//
//  EMListenerHandle.h
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2022/4/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


typedef void (^ListenerHandleCallback)(void);

@interface ListenerHandle : NSObject
+ (ListenerHandle *)sharedInstance;
- (void)addHandle:(ListenerHandleCallback)handle;
- (void)startCallback;
- (void)clearHandle;
@end

NS_ASSUME_NONNULL_END
