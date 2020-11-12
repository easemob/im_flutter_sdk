//
//  EMFlutterRenderViewFactory.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2020/10/20.
//

#import "EMFlutterRenderViewFactory.h"

@interface EMFlutterRenderViewFactory ()
{
    NSObject <FlutterBinaryMessenger> *_messenger;
    NSMutableDictionary *_localViewMap;
    NSMutableDictionary *_remoteViewMap;
}
@end

@implementation EMFlutterRenderViewFactory

static EMFlutterRenderViewFactory *factory;

+ (EMFlutterRenderViewFactory *)factoryWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar withId:(NSString *)aFactoryId
{
    if (!factory) {
        factory = [[EMFlutterRenderViewFactory alloc] initWithMessenger:registrar.messenger];
        [registrar registerViewFactory:factory withId:aFactoryId];
    }
    
    return factory;
}

- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger> *)messenger{
    self = [super init];
    if (self) {
        _messenger = messenger;
        _localViewMap = [NSMutableDictionary dictionary];
        _remoteViewMap = [NSMutableDictionary dictionary];
    }
    return self;
}

- (EMFlutterRenderView *)getLocalViewWithId:(int)viewId {
    NSString *key = [NSString stringWithFormat:@"%d", viewId];
    return _localViewMap[key];
}

- (EMFlutterRenderView *)getRemoteViewWithId:(int)viewId {
    NSString *key = [NSString stringWithFormat:@"%d", viewId];
    return _remoteViewMap[key];
}


- (void)releaseVideoView:(int)viewId {
    NSString *key = [NSString stringWithFormat:@"%d", viewId];
    for (NSString *_key in _localViewMap.allKeys) {
        if ([_key isEqualToString:key]) {
            [_localViewMap removeObjectForKey:_key];
            break;
        }
    }
    for (NSString *_key in _remoteViewMap.allKeys) {
        if ([_key isEqualToString:key]) {
            [_remoteViewMap removeObjectForKey:_key];
            break;
        }
    }
}

- (void)destroy {
    [self->_localViewMap removeAllObjects];
    
    [self->_remoteViewMap removeAllObjects];
}


#pragma mark - FlutterPlatformViewFactory
-(NSObject<FlutterMessageCodec> *)createArgsCodec{
    return [FlutterStandardMessageCodec sharedInstance];
}


- (nonnull NSObject<FlutterPlatformView> *)createWithFrame:(CGRect)frame
                                            viewIdentifier:(int64_t)viewId
                                                 arguments:(id _Nullable)args
{
    NSNumber *viewNum = @(0);
    if (args != nil) {
        viewNum = ((NSDictionary *)args)[@"tag"];
    }
    EMFlutterRenderViewType viewType = (EMFlutterRenderViewType) viewNum.intValue;
    EMFlutterRenderView *iosView = [[EMFlutterRenderView alloc] initWithFrame:frame
                                                               viewIdentifier:viewId
                                                                    arguments:args
                                                                    messenger:_messenger
                                                                     viewType:viewType];
    switch (viewType) {
        case Local: {
            NSString *localViewId = [NSString stringWithFormat:@"%lld", viewId];
            [_localViewMap setValue:iosView forKey:localViewId];
        }
            break;
        case Remote: {
            NSString *remoteViewId = [NSString stringWithFormat:@"%lld", viewId];
            [_remoteViewMap setValue:iosView forKey:remoteViewId];
        }
            break;
        default:
            break;
    }
    return iosView;
}

@end
