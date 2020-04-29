//
//  EMCallViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/9/19.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "EMCallViewController.h"
#import "Masonry.h"

@interface EMCallViewController ()

@end

@implementation EMCallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    [self _setupCallControllerSubviews];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAudioRouteChanged:)   name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
    
    //监测耳机状态，如果是插入耳机或者蓝牙状态，不显示扬声器按钮
    if (isHeadphone()) {
        self.speakerButton.hidden = YES;
    }else {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
        [audioSession setActive:YES error:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Subviews

- (void)_setupCallControllerSubviews
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.backgroundColor = [UIColor clearColor];
    self.statusLabel.font = [UIFont systemFontOfSize:25];
    self.statusLabel.textColor = [UIColor blackColor];
    [self.view addSubview:self.statusLabel];
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(35);
        make.left.equalTo(self.view).offset(15);
    }];
    
    self.microphoneButton = [[EMButton alloc] initWithTitle:@"麦克风" target:self action:@selector(microphoneButtonAction)];
    [self.microphoneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.microphoneButton setImage:[UIImage imageNamed:@"micphone_gray"] forState:UIControlStateNormal];
    [self.microphoneButton setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    [self.microphoneButton setImage:[UIImage imageNamed:@"micphone_gray"] forState:UIControlStateSelected];
    [self.view addSubview:self.microphoneButton];
    
    self.speakerButton = [[EMButton alloc] initWithTitle:@"扬声器" target:self action:@selector(speakerButtonAction)];
    [self.speakerButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.speakerButton setImage:[UIImage imageNamed:@"speaker_gray"] forState:UIControlStateNormal];
    [self.speakerButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [self.speakerButton setImage:[UIImage imageNamed:@"speaker_gray"] forState:UIControlStateSelected];
    [self.view addSubview:self.speakerButton];
    
    self.minButton = [[UIButton alloc] init];
    self.minButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.minButton setImage:[UIImage imageNamed:@"minimize_white"] forState:UIControlStateNormal];
    [self.minButton addTarget:self action:@selector(minimizeAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.minButton];
    [self.minButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-30);
        make.right.equalTo(self.view).offset(-25);
        make.width.height.equalTo(@40);
    }];
    
    self.hangupButton = [[UIButton alloc] init];
    self.hangupButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.hangupButton setImage:[UIImage imageNamed:@"hangup"] forState:UIControlStateNormal];
    [self.hangupButton addTarget:self action:@selector(hangupAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.hangupButton];
}

#pragma mark - NSNotification

- (void)handleAudioRouteChanged:(NSNotification *)aNotif
{
    NSDictionary *interuptionDict = aNotif.userInfo;
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
        {
            //插入耳机
            dispatch_async(dispatch_get_main_queue(), ^{
                self.speakerButton.hidden = YES;
            });
        }
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
        {
            //拔出耳机
            dispatch_async(dispatch_get_main_queue(), ^{
                self.speakerButton.hidden = NO;
                if (self.speakerButton.isSelected) {
                    [self speakerButtonAction];
                }
            });
            
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
            [audioSession setActive:YES error:nil];
        }
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            break;
    }
}

#pragma mark - Action

- (void)microphoneButtonAction
{
    
}

- (void)speakerButtonAction
{
    self.speakerButton.selected = !self.speakerButton.isSelected;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if (self.speakerButton.isSelected) {
        [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    } else {
        [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
    }
    [audioSession setActive:YES error:nil];
}

- (void)minimizeAction
{
    
}

- (void)hangupAction
{
    
}

@end
