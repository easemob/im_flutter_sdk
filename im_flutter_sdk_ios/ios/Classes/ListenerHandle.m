//
//  EMListenerHandle.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2022/4/24.
//

#import "ListenerHandle.h"


@interface ListenerHandle ()
{
    NSMutableArray *_handleList;
    BOOL _hasReady;
}
@end

@implementation ListenerHandle

+ (ListenerHandle *)sharedInstance {
    static ListenerHandle *handle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        handle = [[ListenerHandle alloc] init];
    });
    return handle;
}

- (instancetype)init {
    if (self = [super init]) {
        _handleList = [NSMutableArray array];
    }
    
    return self;
}

- (void)addHandle:(ListenerHandleCallback)handle {
    [_handleList addObject:handle];
    if (_hasReady) {
        [self _runHandle];
    }
}

- (void)_runHandle {
    @synchronized(self){
        NSArray *ary = _handleList;
        for (ListenerHandleCallback callback in ary) {
            callback();
        }
        [_handleList removeAllObjects];
    }
}

- (void)startCallback {
    _hasReady = YES;
    [self _runHandle];
}

- (void)clearHandle {
    _hasReady = NO;
    @synchronized(self){
        [_handleList removeAllObjects];
    }
}

@end
