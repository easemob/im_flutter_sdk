//
//  ImFlutterSDKDefine.h
//  
//
//  Created by 杜洁鹏 on 2019/9/12.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG
#define EMLog(...) NSLog(__VA_ARGS__);
#define LOG_METHOD EMLog(@"%s", __func__);
#else
#define EMLog(...); #define LOG_METHOD;
#endif

static NSString *EMMethodKeyInit = @"init";
static NSString *EMMethodKeyLogin = @"login";
static NSString *EMMethodKeyConnectionDidChanged = @"onConnectionDidChanged";


static NSString *EMMethodKeyDebugLog = @"debugLog";
static NSString *EMMethodKeyErrorLog = @"errorLog";