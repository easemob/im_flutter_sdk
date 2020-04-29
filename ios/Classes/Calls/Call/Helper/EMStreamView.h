//
//  EMStreamView.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/9/20.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Hyphenate/Hyphenate.h>

typedef enum {
    StreamStatusNormal = 0,
    StreamStatusConnecting,
    StreamStatusConnected,
    StreamStatusTalking,
} StreamStatus;

@protocol EMStreamViewDelegate;
@interface EMStreamView : UIView

@property (nonatomic, weak) id<EMStreamViewDelegate> delegate;

@property (nonatomic, strong) UIImageView *bgView;

@property (nonatomic, strong) UIView *displayView;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic) StreamStatus status;

@property (nonatomic) BOOL enableVoice;

@property (nonatomic) BOOL enableVideo;

@property (nonatomic) BOOL isLockedBgView;

@property (nonatomic, strong) id ext;

@end

@protocol EMStreamViewDelegate <NSObject>

@optional

- (void)streamViewDidTap:(EMStreamView *)aVideoView;

@end


@interface EMStreamItem : NSObject

@property (nonatomic, strong) EMCallStream *stream;

@property (nonatomic, strong) EMStreamView *videoView;

@end

