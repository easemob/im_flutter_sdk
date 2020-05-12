//
//  Live2ViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/9/20.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "Live2ViewController.h"
#import "Masonry.h"
#import "UIViewController+HUD.h"

#define MSG_EXT_CALLOP @"em_conference_op"
#define MSG_EXT_CALLID @"em_conference_id"
#define MSG_EXT_CALLPSWD @"em_conference_password"
@interface Live2ViewController ()

@property (nonatomic, strong) EMButton *roleButton;
@property (nonatomic, strong) EMButton *vkbpsButton;

@property (nonatomic) int maxVkbps;

@end

@implementation Live2ViewController
//加入会议者
- (instancetype)initWithJoinConfId:(NSString *)aConfId
                          password:(NSString *)aPassword
                             admin:(NSString *)aAdmin
                            chatId:(NSString *)aChatId
                          chatType:(EMChatType)aChatType
{
    self = [super initWithJoinConfId:aConfId password:aPassword type:EMConferenceTypeLive chatId:aChatId chatType:aChatType];
    if (self) {
        self.admin = aAdmin;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _maxVkbps = 0;
    
    [self _setupSubviews];
    [self _createOrJoinLive];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    self.vkbpsButton = [[EMButton alloc] initWithTitle:@"设置码率" target:self action:@selector(vkbpsAction)];
    [self.vkbpsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.vkbpsButton setImage:[UIImage imageNamed:@"kbps_white"] forState:UIControlStateNormal];
    [self.vkbpsButton setTitle:@"禁用" forState:UIControlStateDisabled];
    [self.vkbpsButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [self.vkbpsButton setImage:[UIImage imageNamed:@"kbps_gray"] forState:UIControlStateDisabled];
    [self.view addSubview:self.vkbpsButton];
    [self.vkbpsButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.microphoneButton);
        make.top.equalTo(self.microphoneButton.mas_bottom).offset(20);
        make.width.mas_equalTo(self.microphoneButton.mas_width);
        make.height.mas_equalTo(self.microphoneButton.mas_height);
    }];
    
    self.roleButton = [[EMButton alloc] initWithTitle:@"上麦" target:self action:@selector(roleAction)];
    [self.roleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.roleButton setImage:[UIImage imageNamed:@"role_white"] forState:UIControlStateNormal];
    [self.roleButton setTitle:@"下麦" forState:UIControlStateSelected];
    [self.roleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.roleButton setImage:[UIImage imageNamed:@"role_white"] forState:UIControlStateSelected];
    [self.view addSubview:self.roleButton];
    [self.roleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.videoButton);
        make.top.equalTo(self.videoButton.mas_bottom).offset(20);
        make.width.mas_equalTo(self.videoButton.mas_width);
        make.height.mas_equalTo(self.videoButton.mas_height);
    }];
    
    self.roleButton.hidden = YES;
    //创建者，默认上传本地视频流
    if (self.isCreater) {
        self.videoButton.selected = YES;
    } else {
        self.switchCameraButton.enabled = NO;
        self.microphoneButton.enabled = NO;
        self.videoButton.enabled = NO;
        self.vkbpsButton.enabled = NO;
    }
}

- (void)_updateViewsAfterPubWithEnableVideo:(BOOL)aEnableVideo
                                      error:(EMError *)aError
{
    if (!aError) {
        self.microphoneButton.enabled = YES;
        
        self.videoButton.enabled = YES;
        self.videoButton.selected = aEnableVideo;
        self.switchCameraButton.enabled = aEnableVideo;

        self.roleButton.selected = YES;
        self.vkbpsButton.enabled = YES;
    } else {
        self.roleButton.selected = NO;
        self.vkbpsButton.enabled = NO;
    }
    
    if (self.isCreater) {
        self.roleButton.hidden = YES;
    } else {
        self.roleButton.hidden = NO;
    }
}

#pragma mark - EMConferenceManagerDelegate

- (void)roleDidChanged:(EMCallConference *)aConference
{
    __weak typeof(self) weakself = self;
    if (aConference.role == EMConferenceRoleSpeaker && [self.pubStreamId length] == 0) {
        [self pubLocalStreamWithEnableVideo:YES completion:^(NSString *aPubStreamId, EMError *aError) {
            [weakself _updateViewsAfterPubWithEnableVideo:YES error:aError];
            weakself.vkbpsButton.enabled = YES;
        }];
    } else if (aConference.role == EMConferenceRoleAudience && [self.pubStreamId length] > 0) {
        self.vkbpsButton.enabled = NO;
        self.roleButton.selected = NO;
        self.switchCameraButton.enabled = NO;
        self.microphoneButton.enabled = NO;
        self.videoButton.enabled = NO;
        self.vkbpsButton.enabled = NO;
        
        [self removeStreamWithId:self.pubStreamId];
        self.pubStreamId = nil;
    }
}

#pragma mark - EMConference

- (void)_createOrJoinLive
{
    if (self.isCreater) {
        [self _createLive];
    } else {
        [self _joinLive];
    }
}
//创建直播房间
- (void)_createLive
{
    __weak typeof(self) weakself = self;
    void (^block)(EMCallConference *aCall, NSString *aPassword, EMError *aError) = ^(EMCallConference *aCall, NSString *aPassword, EMError *aError) {
        if (aError) {
            [self hangupAction];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误" message:@"创建互动会议失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            
            return ;
        }
        
        weakself.conference = aCall;
        weakself.password = aPassword;
        weakself.admin = [EMClient sharedClient].currentUsername;
        
        [weakself pubLocalStreamWithEnableVideo:YES completion:^(NSString *aPubStreamId, EMError *aError) {
            [weakself _updateViewsAfterPubWithEnableVideo:YES error:aError];
            weakself.vkbpsButton.enabled = YES;
        }];
        
        //如果是创建者并且是从会话中触发
        if ([self.chatId length] > 0) {
            [self sendInviteMessageWithChatId:self.chatId chatType:self.chatType];
            [weakself showHint:@"已在群中发送邀请消息"];
        }
        
        //如果是创建者，进行邀请人操作
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (NSString *username in weakself.inviteUsers) {
                [weakself sendInviteMessageWithChatId:username chatType:EMChatTypeChat];
            }
        });
    };
    //创建并加入房间
    [[EMClient sharedClient].conferenceManager createAndJoinConferenceWithType:EMConferenceTypeLive password:self.password record:YES mergeStream:YES isSupportWechatMiniProgram:YES completion:block];
}
//加入直播房间
- (void)_joinLive
{
    __weak typeof(self) weakself = self;
    void (^block)(EMCallConference *aCall, EMError *aError) = ^(EMCallConference *aCall, EMError *aError) {
        if (aError) {
            [self hangupAction];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误" message:@"进入互动会议失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            
            return ;
        }
        
        weakself.conference = aCall;
        
        if (aCall.role != EMConferenceRoleAudience) {
            [weakself pubLocalStreamWithEnableVideo:YES completion:^(NSString *aPubStreamId, EMError *aError) {
                [weakself _updateViewsAfterPubWithEnableVideo:YES error:aError];
            }];
        } else {
            weakself.vkbpsButton.enabled = NO;
            weakself.roleButton.hidden = NO;
        }
    };
    
    [[EMClient sharedClient].conferenceManager joinConferenceWithConfId:self.joinConfId password:self.password completion:block];
}

#pragma mark - Action

- (void)vkbpsAction
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"设置视频最大码率" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    __weak typeof(self) weakself = self;
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入视频最大码率";
        if (weakself.maxVkbps > 0) {
            textField.text = @(weakself.maxVkbps).stringValue;
        }
    }];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField = alertController.textFields.firstObject;
        weakself.maxVkbps = [textField.text intValue];
        [[EMClient sharedClient].conferenceManager updateConference:weakself.conference maxVideoKbps:weakself.maxVkbps];
    }];
    [alertController addAction:okAction];
    
    [alertController addAction: [UIAlertAction actionWithTitle:@"取消" style: UIAlertActionStyleCancel handler:nil]];
    
    alertController.modalPresentationStyle = 0;
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)roleAction
{
    if (self.isCreater) {
        return;
    }
    
    if (!self.roleButton.selected && self.conference.role != EMConferenceRoleAudience && [self.pubStreamId length] == 0) {
        __weak typeof(self) weakself = self;
        [self pubLocalStreamWithEnableVideo:YES completion:^(NSString *aPubStreamId, EMError *aError) {
            [weakself _updateViewsAfterPubWithEnableVideo:YES error:aError];
        }];
        
        return;
    }
    
    NSString *op = @"";
    NSString *msg = @"";
    NSString *currentUser = [EMClient sharedClient].currentUsername;
    if (self.roleButton.isSelected) {
        op = @"request_tobe_audience";
        msg = [[NSString alloc] initWithFormat:@"%@ 申请下麦互动视频会议'%@'", currentUser, self.conference.confId];
        
        __weak typeof(self) weakself = self;
        [[EMClient sharedClient].conferenceManager unpublishConference:self.conference streamId:self.pubStreamId completion:^(EMError *aError) {
            weakself.vkbpsButton.enabled = NO;
            weakself.roleButton.selected = NO;
            weakself.switchCameraButton.enabled = NO;
            weakself.microphoneButton.enabled = NO;
            weakself.videoButton.enabled = NO;
            
            [weakself removeStreamWithId:weakself.pubStreamId];
            weakself.pubStreamId = nil;
            EMCallOptions *options = [[EMClient sharedClient].callManager getCallOptions];
            if(options.enableCustomAudioData)
               [[self audioRecord] stopAudioDataRecord];
        }];
    } else {
        op = @"request_tobe_speaker";
        msg = [[NSString alloc] initWithFormat:@"%@ 申请成为互动视频会议'%@'的主播", currentUser, self.conference.confId];
    }

    NSString *applyUid = [[EMClient sharedClient].conferenceManager getMemberNameWithAppkey:[EMClient sharedClient].options.appkey username:currentUser];
    EMTextMessageBody *textBody = [[EMTextMessageBody alloc] initWithText:msg];
    EMMessage *message = [[EMMessage alloc] initWithConversationID:self.admin from:currentUser to:self.admin body:textBody ext:@{MSG_EXT_CALLID:self.conference.confId, MSG_EXT_CALLPSWD:self.password, @"em_member_name":applyUid, MSG_EXT_CALLOP:op}];
    message.chatType = EMChatTypeChat;
    [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:nil];
    
    [self showHint:@"已经向管理员发送申请信息"];
}

- (void)minimizeAction
{
    self.minButton.selected = YES;
    
    EMStreamItem *item = nil;
    if ([self.pubStreamId length] > 0) {
        item = [self.streamItemDict objectForKey:self.pubStreamId];
    } else if ([self.streamIds count] > 0) {
        item = [self.streamItemDict objectForKey:self.streamIds[0]];
    }
    
    if (!item) {
        return;
    }
    
    self.floatViewFromFrame = CGRectMake(item.videoView.frame.origin.x, item.videoView.frame.origin.y, item.videoView.frame.size.width, item.videoView.frame.size.height);
    self.floatingView = item.videoView;
    [self.floatingView removeFromSuperview];
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    self.floatingView.frame = CGRectMake(keyWindow.frame.size.width - 120, 80, 80, 80);
    [keyWindow addSubview:self.floatingView];
    [keyWindow bringSubviewToFront:self.floatingView];
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - Public

- (void)handleRoleChangedMessage:(EMMessage *)aMessage
{
    NSString *confrId = [aMessage.ext objectForKey:MSG_EXT_CALLID];
    if (![confrId isEqualToString:self.conference.confId]) {
        return;
    }
    
    EMTextMessageBody *textBody = (EMTextMessageBody *)aMessage.body;
    NSString *text = textBody.text;
    
    NSString *op = [aMessage.ext objectForKey:MSG_EXT_CALLOP];
    if ([op isEqualToString:@"request_tobe_audience"]) {
        NSString *applyer = [aMessage.ext objectForKey:@"em_member_name"];
        [[EMClient sharedClient].conferenceManager changeMemberRoleWithConfId:self.conference.confId memberNames:@[applyer] role:EMConferenceRoleAudience completion:^(EMError *aError) {
        }];
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:text message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"同意" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *applyer = [aMessage.ext objectForKey:@"em_member_name"];
        if ([op isEqualToString:@"request_tobe_speaker"]) {
            [[EMClient sharedClient].conferenceManager changeMemberRoleWithConfId:self.conference.confId memberNames:@[applyer] role:EMConferenceRoleSpeaker completion:^(EMError *aError) {
            }];
        }
    }];
    
    if ([op isEqualToString:@"request_tobe_speaker"]) {
        [alertController addAction: [UIAlertAction actionWithTitle:@"忽略" style: UIAlertActionStyleCancel handler:nil]];
    }
    
    [alertController addAction:okAction];
    alertController.modalPresentationStyle = 0;
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
