//
//  EM1v1CallViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/9/19.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "EM1v1CallViewController.h"

#import "EMGlobalVariables.h"
#import "UIViewController+HUD.h"
#import "Masonry.h"

#define STBundle_Name @"IMFlutterResoure.bundle"
#define STBundle_Path [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:STBundle_Name]
#define STBundle [NSBundle bundleWithPath:STBundle_Path]

@interface EM1v1CallViewController ()

@property (nonatomic, strong) NSTimer *callDurationTimer;
@property (nonatomic) int callDuration;

@end

@implementation EM1v1CallViewController

- (instancetype)initWithCallSession:(EMCallSession *)aCallSession
{
    self = [super init];
    if (self) {
        _callSession = aCallSession;
        _callStatus = EMCallSessionStatusDisconnected;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    [self _setup1v1CallControllerSubviews];
    
    self.remoteNameLabel.text = self.callSession.remoteName;
    self.timeLabel.hidden = YES;
    self.answerButton.enabled = NO;
    self.callStatus = self.callSession.status;
    [self.waitImgView startAnimating];
    [self floatingView];//初始化视频小窗
    //监测耳机状态，如果是插入耳机状态，不显示扬声器按钮
    self.speakerButton.hidden = isHeadphone();
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self clearDataAndView];
}

- (void)clearDataAndView
{
    [self _stopCallDurationTimer];
    
    [_floatingView removeFromSuperview];
    _floatingView = nil;
}

#pragma mark - Subviews

- (void)_setup1v1CallControllerSubviews
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.statusLabel.text = @"正在建立连接...";
    
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.backgroundColor = [UIColor clearColor];
    self.timeLabel.font = [UIFont systemFontOfSize:25];
    self.timeLabel.textColor = [UIColor blackColor];
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    self.timeLabel.text = @"00:00";
    [self.view addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.statusLabel);
        make.right.equalTo(self.view).offset(-15);
    }];
    
    self.remoteNameLabel = [[UILabel alloc] init];
    self.remoteNameLabel.backgroundColor = [UIColor clearColor];
    self.remoteNameLabel.font = [UIFont systemFontOfSize:15];
    self.remoteNameLabel.textColor = [UIColor blackColor];
    [self.view addSubview:self.remoteNameLabel];
    [self.remoteNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.statusLabel.mas_bottom).offset(15);
        make.left.equalTo(self.statusLabel.mas_left).offset(5);
        make.right.equalTo(self.view).offset(-15);
    }];
    
    self.waitImgView = [[UIImageView alloc] init];
    self.waitImgView.contentMode = UIViewContentModeScaleAspectFit;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 25; i < 88; i++) {
        NSString *name = [[NSString alloc] initWithFormat:@"animate_000%@", @(i)];
//        NSString *path = [NSBundle.mainBundle pathForResource:@"image@2x" type:@"png"];

//        NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"png"];
//        UIImage *image = [UIImage imageWithContentsOfFile:path];
        [array addObject:[UIImage imageNamed:name]];
//        NSData *imageData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:nil]];
//        [array addObject:[UIImage imageWithData:imageData]];
//        [array addObject:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:nil]]];
        
    }
    [self.waitImgView setAnimationImages:array];
    [self.view addSubview:self.waitImgView];
    [self.waitImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
    }];
    
    [self.minButton setImage:[UIImage imageNamed:@"minimize_gray"] forState:UIControlStateNormal];
    [self.minButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-30);
        make.right.equalTo(self.view).offset(-25);
        make.width.height.equalTo(@40);
    }];
    
    if (self.callSession.isCaller) {
        [self.hangupButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-40);
            make.width.height.equalTo(@60);
        }];
    } else {
        CGFloat size = 60;
        CGFloat padding = ([UIScreen mainScreen].bounds.size.width - size * 2) / 3;
        
        [self.hangupButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).offset(-40);
            make.right.equalTo(self.view).offset(-padding);
            make.width.height.mas_equalTo(size);
        }];
        
        self.answerButton = [[UIButton alloc] init];
        self.answerButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.answerButton setImage:[UIImage imageNamed:@"answer"] forState:UIControlStateNormal];
        [self.answerButton addTarget:self action:@selector(answerAction) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.answerButton];
        [self.answerButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.hangupButton);
            make.left.equalTo(self.view).offset(padding);
            make.width.height.mas_equalTo(size);
        }];
    }
}

#pragma mark - Floating View

- (EMStreamView *)floatingView
{
    if (_floatingView == nil) {
        _floatingView = [[EMStreamView alloc] init];
        _floatingView.enableVideo = self.callSession.type == EMCallTypeVideo ? YES : NO;
        _floatingView.delegate = self;
    }
    
    return _floatingView;
}

- (void)_updateFloatingViewWithCallStatus:(EMCallSessionStatus)callStatus
{
    if (!_floatingView) {
        return;
    }
    
    switch (callStatus) {
        case EMCallSessionStatusConnecting:
        {
            _floatingView.status = StreamStatusConnecting;
        }
            break;
        case EMCallSessionStatusConnected:
        case EMCallSessionStatusAccepted:
        {
            _floatingView.status = StreamStatusConnected;
        }
            break;
            
        default:
            _floatingView.status = StreamStatusNormal;
            break;
    }
}

- (void)_updateFloatingViewWithStreamingStatus:(EMCallStreamingStatus)aStatus
{
    //空值，所以未初始化之前不会有任何内容，即就是不会设置上静音图标
    if (!_floatingView) {
        return;
    }
    
    switch (aStatus) {
        case EMCallStreamStatusVoicePause:
            _floatingView.enableVoice = NO;
            break;
        case EMCallStreamStatusVoiceResume:
            _floatingView.enableVoice = YES;
            break;
        case EMCallStreamStatusVideoPause:
            _floatingView.enableVideo = NO;
            break;
        case EMCallStreamStatusVideoResume:
            _floatingView.enableVideo = YES;
            break;
            
        default:
            break;
    }
}

#pragma mark - Timer

- (void)_updateCallDuration
{
    self.callDuration += 1;
    int hour = self.callDuration / 3600;
    int m = (self.callDuration - hour * 3600) / 60;
    int s = self.callDuration - hour * 3600 - m * 60;
    
    if (hour > 0) {
        self.timeLabel.text = [NSString stringWithFormat:@"%i:%i:%i", hour, m, s];
    }
    else if(m > 0){
        self.timeLabel.text = [NSString stringWithFormat:@"%i:%i", m, s];
    }
    else{
        self.timeLabel.text = [NSString stringWithFormat:@"00:%i", s];
    }
}

- (void)_startCallDurationTimer
{
    [self _stopCallDurationTimer];
    
    self.callDuration = 0;
    self.callDurationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(_updateCallDuration) userInfo:nil repeats:YES];
}

- (void)_stopCallDurationTimer
{
    if (self.callDurationTimer) {
        [self.callDurationTimer invalidate];
        self.callDurationTimer = nil;
    }
}

#pragma mark - EMStreamViewDelegate

- (void)streamViewDidTap:(EMStreamView *)aVideoView
{
    self.minButton.selected = NO;
    [self.floatingView removeFromSuperview];
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIViewController *rootViewController = window.rootViewController;
    self.modalPresentationStyle = 0;
    [rootViewController presentViewController:self animated:NO completion:nil];
}

#pragma mark - Status

- (void)setCallStatus:(EMCallSessionStatus)callStatus
{
    if (_callStatus >= callStatus) {
        return;
    }
    
    switch (callStatus) {
        case EMCallSessionStatusConnecting:
        {
            self.statusLabel.text = @"正在建立连接...";
        }
            break;
        case EMCallSessionStatusConnected:
        {
            self.statusLabel.text = @"等待接听...";
            self.answerButton.enabled = YES;
        }
            break;
        case EMCallSessionStatusAccepted:
        {
            [self _startCallDurationTimer];
            
            self.statusLabel.text = @"通话中...";
            self.timeLabel.hidden = NO;
            [self.waitImgView stopAnimating];
            if (!self.callSession.isCaller) {
                [self.answerButton removeFromSuperview];
                [self.hangupButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(self.view);
                    make.bottom.equalTo(self.view).offset(-40);
                    make.width.height.equalTo(@60);
                }];
            }
            
            NSString *connectStr = @"";
            if (self.callSession.connectType == EMCallConnectTypeRelay) {
                connectStr = @"Relay";
            } else if (self.callSession.connectType == EMCallConnectTypeDirect) {
                connectStr = @"Direct";
            }
            self.remoteNameLabel.text = [NSString stringWithFormat:@"%@  --  %@", self.callSession.remoteName, connectStr];

            if (self.microphoneButton.isSelected) {
                [self.callSession pauseVoice];
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (!self.microphoneButton.isSelected && self.speakerButton.isSelected) {
                    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
                    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
                    [audioSession setActive:YES error:nil];
                }
            });
        }
            break;
            
        default:
            break;
    }
    
    [self _updateFloatingViewWithCallStatus:callStatus];
}

- (void)updateStreamingStatus:(EMCallStreamingStatus)aStatus
{
    NSString *str = @"对方数据流状态有更新";
    switch (aStatus) {
        case EMCallStreamStatusVoicePause:
            str = @"对方已静音";
            break;
        case EMCallStreamStatusVoiceResume:
            str = @"对方解除静音";
            break;
        case EMCallStreamStatusVideoPause:
            str = @"对方禁止上传视频";
            break;
        case EMCallStreamStatusVideoResume:
            str = @"对方恢复上传视频";
            break;
            
        default:
            break;
    }
    
    [self showHint:str];
    
    [self _updateFloatingViewWithStreamingStatus:aStatus];
}

#pragma mark - Action
//点击麦克风
- (void)microphoneButtonAction
{
    self.microphoneButton.selected = !self.microphoneButton.selected;
    if (self.microphoneButton.isSelected) {
        [self.callSession pauseVoice];
    } else {
        [self.callSession resumeVoice];
    }
}

- (void)speakerButtonAction
{
    [super speakerButtonAction];
}

- (void)minimizeAction
{
}
//1v1挂断触发事件
- (void)hangupAction
{
    [self clearDataAndView];
    
    NSString *callId = self.callSession.callId;
    _callSession = nil;
    
    EMCallEndReason reason = EMCallEndReasonHangup;
    if (self.callDuration < 1 && !self.callSession.isCaller) {
        reason = EMCallEndReasonDecline;
    }
    [[DemoCallManager sharedManager] endCallWithId:callId reason:reason];
}

- (void)answerAction
{
    [[DemoCallManager sharedManager] answerCall:self.callSession.callId];
    self.callStatus = EMCallSessionStatusAccepted;
}

- (void)setNetwork:(EMCallNetworkStatus)status {
    NSString *showInfo = @"";
    switch (status) {
        case EMCallNetworkStatusNormal:
        {
            showInfo = @"网络恢复正常";
        }
            break;
        case EMCallNetworkStatusUnstable:
        {
            showInfo = @"网络状态不稳定";
        }
            break;
        case EMCallNetworkStatusNoData:
        {
            showInfo = @"";
        }
            break;
        default:
            break;
    }
    if (showInfo.length == 0) {
        return;
    }
    [self showHint:showInfo];
}

@end
