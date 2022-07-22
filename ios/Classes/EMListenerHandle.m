//
//  EMListenerHandle.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2022/4/24.
//

#import "EMListenerHandle.h"


@interface EMListenerHandle ()
{
    NSMutableArray *_handleList;
    BOOL _hasReady;
}
@end

@implementation EMListenerHandle

+ (EMListenerHandle *)sharedInstance {
    static EMListenerHandle *handle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        handle = [[EMListenerHandle alloc] init];
    });
    return handle;
}

- (instancetype)init {
    if (self = [super init]) {
        _handleList = [NSMutableArray array];
    }
    
    return self;
}

- (void)addHandle:(EMListenerHandleCallback)handle {
    [_handleList addObject:handle];
    if (_hasReady) {
        [self _runHandle];
    }
}

- (void)_runHandle {
    @synchronized(self){
        NSArray *ary = _handleList;
        for (EMListenerHandleCallback callback in ary) {
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
