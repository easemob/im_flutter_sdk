//
//  MeetingViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/9/20.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "MeetingViewController.h"

typedef void(^MyBlock)(UIColor *, BOOL);

@interface MeetingViewController ()

@end

@implementation MeetingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.switchCameraButton.enabled = NO;
    
    [self _createOrJoinConference];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - EMConference

- (void)_createOrJoinConference
{
    __weak typeof(self) weakself = self;
    void (^block)(EMCallConference *aCall, NSString *aPassword, EMError *aError) = ^(EMCallConference *aCall, NSString *aPassword, EMError *aError) {
        if (aError) {
            [self hangupAction];
            NSString *title = weakself.isCreater ? @"创建会议失败" : @"加入会议失败";
            NSString *msg = title;
            switch (aError.code) {
                case EMErrorServiceArrearages:
                    msg = @"余额不足";
                    break;
                    
                case EMErrorCallSpeakerFull:
                    msg = @"主播人数达到上限";
                    break;
                default:
                    break;
            }
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            
            return ;
        }
        
        [[EMClient sharedClient].conferenceManager enableStatistics:YES];
        weakself.conference = aCall;
        weakself.password = aPassword;
        
        [weakself pubLocalStreamWithEnableVideo:NO completion:nil];
        
        //群组会议模式中不会给群组中发邀请消息，只会给被邀请人单发消息
        
        /*
        //如果是创建者并且是从会话中触发
        if (weakself.isCreater && [weakself.chatId length] > 0) {
            [weakself sendInviteMessageWithChatId:weakself.chatId chatType:weakself.chatType];
            [weakself showHint:@"已在群中发送邀请消息"];
        }
        */
         
        //如果是创建者，进行邀请人操作
        if (weakself.isCreater) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                for (NSString *username in weakself.inviteUsers) {
                    [weakself sendInviteMessageWithChatId:username chatType:EMChatTypeChat];
                }
            });
        }
    };
    if (self.isCreater) {
        // 创建
        [[EMClient sharedClient].conferenceManager createAndJoinConferenceWithType:self.type password:self.password record:self.isRecord mergeStream:self.isMerge isSupportWechatMiniProgram:YES completion:^(EMCallConference *aCall, NSString *aPassword, EMError *aError) {
            weakself.confResultBlock(aCall, aError);
            block(aCall, weakself.password, aError);
        }];
        
    } else {
        // 加入
        [[EMClient sharedClient].conferenceManager joinConferenceWithConfId:self.joinConfId password:self.password completion:^(EMCallConference *aCall, EMError *aError) {
            weakself.confResultBlock(aCall, aError);
            block(aCall, weakself.password, aError);
        }];
    }
}

@end
