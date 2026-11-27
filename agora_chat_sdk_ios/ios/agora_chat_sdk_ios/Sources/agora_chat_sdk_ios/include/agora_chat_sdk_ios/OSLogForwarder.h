//
//  OSLogForwarder.h
//  im_flutter_sdk
//

#import <Foundation/Foundation.h>

// Forwards native SDK logs to the Apple unified log (os_log), mirroring the
// always-on Android JNI bridge (EMNDKLogCallback -> logcat). Installed once at
// plugin registration, before SDK init: addLogDelegate registers directly into
// the core EMLog singleton, so logs from the init window are captured too.
// The Dart-side `debugMode` option (default off) gates forwarding via
// +setEnabled:. The core log file and the core console (cout) output are
// unaffected either way.
@interface OSLogForwarder : NSObject

+ (void)install;
+ (void)setEnabled:(BOOL)enabled;

@end
