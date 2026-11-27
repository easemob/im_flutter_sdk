//
//  OSLogForwarder.m
//  im_flutter_sdk
//

#import "OSLogForwarder.h"
#import "ChatHeaders.h"
#import <os/log.h>

static os_log_t EMOSLogInstance(void) {
    static os_log_t instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = os_log_create("com.hyphenate.chatsdk", "chatsdk");
    });
    return instance;
}

@interface OSLogForwarder () <EMLogDelegate>
@end

@implementation OSLogForwarder

static BOOL _enabled = NO;

+ (void)install {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        static OSLogForwarder *forwarder;
        forwarder = [[OSLogForwarder alloc] init];
        dispatch_queue_t queue = dispatch_queue_create("com.easemob.im_flutter_sdk.oslog",
                                                       DISPATCH_QUEUE_SERIAL);
        [EMClient.sharedClient addLogDelegate:forwarder delegateQueue:queue];
    });
}

+ (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
}

- (void)logDidOutput:(NSString *)log {
    if (!_enabled || log.length == 0) {
        return;
    }
    // %{public}@ keeps the message visible in release builds; default level
    // is persisted to the log store (debug level is not).
    os_log(EMOSLogInstance(), "%{public}@", log);
}

@end
