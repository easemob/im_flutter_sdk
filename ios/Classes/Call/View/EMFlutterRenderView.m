//
//  EMFlutterRenderView.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2020/10/20.
//

#import "EMFlutterRenderView.h"

@interface EMFlutterRenderView ()
{
    UIView *_iOSView;
}
@end

@implementation EMFlutterRenderView

- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(id)args
                    messenger:(nonnull NSObject <FlutterBinaryMessenger> *)messager
                     viewType:(EMFlutterRenderViewType)viewType {
    if (self = [super init]) {
        switch (viewType) {
            case Local:
                [self createLocalView:frame
                       viewIdentifier:viewId
                            arguments:args];
                break;
            case Remote:
                [self createRemoteView:frame
                        viewIdentifier:viewId
                             arguments:args];
                break;
            default:
                break;
        }
        
    }
    return self;
}

- (void)createLocalView:(CGRect)frame
         viewIdentifier:(int64_t)viewId
              arguments:(id)args
{
    EMCallLocalView *localView = [[EMCallLocalView alloc] initWithFrame:frame];
    localView.backgroundColor = UIColor.redColor;
    localView.scaleMode = EMCallViewScaleModeAspectFill;
    _iOSView = localView;
}

- (void)createRemoteView:(CGRect)frame
          viewIdentifier:(int64_t)viewId
               arguments:(id)args
{
    EMCallRemoteView *remoteView = [[EMCallRemoteView alloc] initWithFrame:frame];
    remoteView.backgroundColor = UIColor.redColor;
    remoteView.scaleMode = EMCallViewScaleModeAspectFill;
    _iOSView = remoteView;
}

- (UIView *)previewView {
    return _iOSView;
}

#pragma mark - FlutterPlatformView
- (nonnull UIView *)view {
    return _iOSView;
}




@end
