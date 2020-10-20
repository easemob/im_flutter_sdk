//
//  EMFlutterRenderView.h
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2020/10/20.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import "EMHelper.h"

typedef NS_ENUM(NSUInteger, EMFlutterRenderViewType) {
    Local,
    Remote,
};

NS_ASSUME_NONNULL_BEGIN


@interface EMFlutterRenderView : NSObject <FlutterPlatformView>
@property(nonatomic, strong, readonly) UIView *previewView;

- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(id)args
                    messenger:(nonnull NSObject <FlutterBinaryMessenger> *)messager
                     viewType:(EMFlutterRenderViewType)viewType;

@end

NS_ASSUME_NONNULL_END
