//
//  EMStreamView.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/9/20.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "EMStreamView.h"
#import "Masonry.h"

@interface EMStreamView()

@property (nonatomic, strong) UIImageView *statusView;

@end

@implementation EMStreamView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _enableVoice = YES;
        
        self.bgView = [[UIImageView alloc] init];
        self.bgView.contentMode = UIViewContentModeScaleAspectFit;
        self.bgView.userInteractionEnabled = YES;
        self.bgView.layer.borderWidth = 0.5;
        self.bgView.layer.borderColor = [UIColor grayColor].CGColor;
        self.bgView.image = [UIImage imageNamed:@"bg_connecting"];
        [self addSubview:self.bgView];
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        self.statusView = [[UIImageView alloc] init];
        self.statusView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.statusView];
        [self.statusView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(5);
            make.right.equalTo(self).offset(-5);
            make.width.height.equalTo(@20);
        }];
        
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.textColor = [UIColor whiteColor];
        self.nameLabel.font = [UIFont systemFontOfSize:13];
        [self addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(5);
            make.left.equalTo(self).offset(5);
            make.right.equalTo(self.statusView.mas_left).offset(-5);
            make.height.equalTo(@20);
        }];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapAction:)];
        [self addGestureRecognizer:tap];
        
        [self bringSubviewToFront:_nameLabel];
        
        _isLockedBgView = NO;
    }
    
    return self;
}

- (void)setStatus:(StreamStatus)status
{
    if (_status == status) {
        return;
    }
    
    _status = status;
    [self bringSubviewToFront:_statusView];
    
    switch (_status) {
        case StreamStatusConnecting:
        {
            if (_enableVoice) {
                _statusView.image = [UIImage imageNamed:@"ring_gray"];
            }
        }
            break;
        case StreamStatusConnected:
        {
            if (_enableVoice) {
                _statusView.image = nil;
            }
            
            if (!self.isLockedBgView) {
                _bgView.image = [UIImage imageNamed:@"bg_micro"];
            }
        }
            break;
        case StreamStatusTalking:
            if (_enableVoice) {
                _statusView.image = [UIImage imageNamed:@"talking_green"];
            }
            break;
            
        default:
            {
                if (_enableVoice) {
                    _statusView.image = nil;
                }
            }
            break;
    }
}

- (void)setEnableVoice:(BOOL)enableVoice
{
    _enableVoice = enableVoice;
    
    [self bringSubviewToFront:_statusView];
    if (enableVoice) {
        _statusView.image = nil;
    } else {
        _statusView.image = [UIImage imageNamed:@"mute_red"];
    }
}

- (void)setEnableVideo:(BOOL)enableVideo
{
    _enableVideo = enableVideo;
    
    if (enableVideo) {
        [self sendSubviewToBack:_bgView];
    } else {
        [self sendSubviewToBack:_displayView];
    }
}

#pragma mark - UITapGestureRecognizer

- (void)handleTapAction:(UITapGestureRecognizer *)aTap
{
    if (aTap.state == UIGestureRecognizerStateEnded) {

        if (_delegate && [_delegate respondsToSelector:@selector(streamViewDidTap:)]) {
            [_delegate streamViewDidTap:self];
        }
    }
}

@end


@implementation EMStreamItem

@end
