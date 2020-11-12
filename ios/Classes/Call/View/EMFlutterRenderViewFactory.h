//
//  EMFlutterRenderViewFactory.h
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2020/10/20.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import "EMFlutterRenderView.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMFlutterRenderViewFactory : NSObject <FlutterPlatformViewFactory>

+ (EMFlutterRenderViewFactory *)factoryWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar withId:(NSString *)aFactoryId;

- (EMFlutterRenderView *)getLocalViewWithId:(int)viewId;

- (EMFlutterRenderView *)getRemoteViewWithId:(int)viewId;

- (void)releaseVideoView:(int)viewId;
@end

NS_ASSUME_NONNULL_END
