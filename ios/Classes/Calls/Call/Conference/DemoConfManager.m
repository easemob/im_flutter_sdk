//
//  DemoConfManager.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 23/11/2016.
//  Copyright © 2016 XieYajie. All rights reserved.
//

#import "DemoConfManager.h"

#import <Hyphenate/Hyphenate.h>

#import "DemoCallManager.h"

//#import "EMGlobalVariables.h"

#import "MeetingViewController.h"
#import "Live2ViewController.h"
#import "EMGlobalVariables.h"
#import "EMConversationHelper.h"

#define CALL_TYPE @"type"
#define CALL_MODEL @"EMCallForModel"
#define CALL_MAKECONFERENCE @"EMMakeConference"
#define CALL_SELECTCONFERENCECELL @"EMSelectConferenceCell"
#define MSG_EXT_CALLOP @"em_conference_op"
#define MSG_EXT_CALLID @"em_conference_id"
#define MSG_EXT_CALLPSWD @"em_conference_password"
#define NOTIF_NAVICONTROLLER @"EMNaviController"
static DemoConfManager *confManager = nil;

@interface DemoConfManager()<EMConferenceManagerDelegate, EMChatManagerDelegate>

@property (strong, nonatomic) UINavigationController *confNavController;

@end


@implementation DemoConfManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _initManager];
    }
    
    return self;
}

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        confManager = [[DemoConfManager alloc] init];
    });
    
    return confManager;
}

- (void)dealloc
{
    [[EMClient sharedClient].conferenceManager removeDelegate:self];
    [[EMClient sharedClient].chatManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - private

- (void)_initManager
{
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].conferenceManager addDelegate:self delegateQueue:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMakeConference:) name:CALL_MAKECONFERENCE object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSelectConferenceCell:) name:CALL_SELECTCONFERENCECELL object:nil];
}

#pragma mark - EMChatManagerDelegate

- (void)messagesDidReceive:(NSArray *)aMessages
{
    for (EMMessage *message in aMessages) {
        NSString *conferenceId = [message.ext objectForKey:MSG_EXT_CALLID];
        if ([conferenceId length] == 0) {
            continue;
        }
                
        NSString *op = [message.ext objectForKey:MSG_EXT_CALLOP];
        if ([op isEqualToString:@"request_tobe_speaker"] || [op isEqualToString:@"request_tobe_audience"]) {
            EMConferenceViewController *controller =  self.confNavController.viewControllers[0];
            if ([controller isKindOfClass:[Live2ViewController class]]) {
                Live2ViewController *liveController = (Live2ViewController *)controller;
                [liveController handleRoleChangedMessage:message];
            }
        }
    }
}

#pragma mark - conference

- (void)inviteMemberWithConfType:(EMConferenceType)aConfType
                      inviteType:(ConfInviteType)aInviteType
                  conversationId:(NSString *)aConversationId
                        chatType:(EMChatType)aChatType
                        password:(NSString *)aPassword
                          record:(BOOL)isRecord
                           merge:(BOOL)isMerge
               popFromController:(UIViewController *)aController
                      completion:(void (^)(EMCallConference *aCall,EMError *aError))aCompletionBlock
{
    if (gIsCalling) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误" message:@"有通话正在进行" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        
        return;
    }
    
    ConfInviteUsersViewController *controller = [[ConfInviteUsersViewController alloc] initWithType:aInviteType isCreate:YES excludeUsers:@[[EMClient sharedClient].currentUsername] groupOrChatroomId:aConversationId];
    
    __weak typeof(self) weakSelf = self;
    [controller setDoneCompletion:^(NSArray *aInviteUsers) {
        gIsCalling = YES;
        
        EMConferenceViewController *controller = nil;
        if (aConfType != EMConferenceTypeLive) {
            // 创建
            controller = [[MeetingViewController alloc] initWithType:aConfType password:aPassword inviteUsers:aInviteUsers chatId:aConversationId chatType:aChatType record:isRecord merge:isMerge completion:^(EMCallConference *aCall, EMError *aError) {
                aCompletionBlock(aCall,aError);
            }];
        } else {
            controller = [[Live2ViewController alloc] initWithType:aConfType password:aPassword inviteUsers:aInviteUsers chatId:aConversationId chatType:aChatType record:isRecord merge:isMerge completion:^(EMCallConference *aCall, EMError *aError) {
                
            }];
        }
        controller.inviteType = aInviteType;
        
        weakSelf.confNavController = [[UINavigationController alloc] initWithRootViewController:controller];
        weakSelf.confNavController.modalPresentationStyle = 0;
        [aController presentViewController:weakSelf.confNavController animated:NO completion:nil];
    }];
    //互动会议模式不需要邀请成员
    if(aConfType != EMConferenceTypeLive){
        controller.modalPresentationStyle = 0;
        [aController presentViewController:controller animated:NO completion:nil];
    }else{
        gIsCalling = YES;
        
        EMConferenceViewController *controller = nil;
        if (aConfType != EMConferenceTypeLive) {
            controller = [[MeetingViewController alloc] initWithType:aConfType password:aPassword inviteUsers:nil chatId:aConversationId chatType:aChatType record:isRecord merge:isMerge completion:^(EMCallConference *aCall, EMError *aError) {
                
            }];
        } else {
            controller = [[Live2ViewController alloc] initWithType:aConfType password:aPassword inviteUsers:nil chatId:aConversationId chatType:aChatType record:isRecord merge:isMerge completion:^(EMCallConference *aCall, EMError *aError) {
                
            }];
        }
        controller.inviteType = aInviteType;
        
        weakSelf.confNavController = [[UINavigationController alloc] initWithRootViewController:controller];
        weakSelf.confNavController.modalPresentationStyle = 0;
        [aController presentViewController:weakSelf.confNavController animated:NO completion:nil];
    }
}

//关闭会议
- (void)endConference:(EMCallConference *)aCall
            isDestroy:(BOOL)aIsDestroy
{
    gIsCalling = NO;
    self.confNavController = nil;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
    [audioSession setActive:YES error:nil];
    
    [[EMClient sharedClient].conferenceManager stopMonitorSpeaker:aCall];
    
    if (aIsDestroy) {
        [[EMClient sharedClient].conferenceManager destroyConferenceWithId:aCall.confId completion:nil];
    } else {
        [[EMClient sharedClient].conferenceManager leaveConference:aCall completion:nil];
    }
    
    gIsCalling = NO;
}

#pragma mark - conference
- (void)createAndJoinConference:(NSDictionary *)dict completion:(void (^)(EMCallConference *aCall,EMError *aError))aCompletionBlock
{
    EMConferenceType type = (EMConferenceType)[[dict objectForKey:CALL_TYPE] integerValue];
    id model = [dict objectForKey:CALL_MODEL];
    
    NSString *conversationId = nil;
    ConfInviteType inviteType = ConfInviteTypeUser;
    EMChatType chatType = EMChatTypeChat;
    if ([model isKindOfClass:[EMConversationModel class]]) {
        EMConversationModel *cmodel = (EMConversationModel *)model;
        conversationId = cmodel.emModel.conversationId;
        chatType =(EMChatType)cmodel.emModel.type;
        if (cmodel.emModel.type == EMChatTypeGroupChat) {
            inviteType = ConfInviteTypeGroup;
        } else if (cmodel.emModel.type == EMChatTypeChatRoom) {
            inviteType = ConfInviteTypeChatroom;
        }
    }
    
    UIViewController *controller = [dict objectForKey:NOTIF_NAVICONTROLLER];
    if (controller == nil) {
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        controller = window.rootViewController;
    }
    
    [self inviteMemberWithConfType:type
                        inviteType:inviteType
                    conversationId:conversationId
                          chatType:chatType
                          password:[dict objectForKey:@"password"]
                            record:[[dict objectForKey:@"record"] boolValue]
                             merge:[[dict objectForKey:@"merge"] boolValue]
                 popFromController:controller
                        completion:aCompletionBlock];
}

- (void)joinCoference:(NSDictionary *)dict completion:(void (^)(EMCallConference *aCall,EMError *aError))aCompletionBlock
{
    //如果正在进行1v1通话，不处理
    if (gIsCalling) {
        return;
    }
    
    //新版属性
    NSString *conferenceId = [dict objectForKey:MSG_EXT_CALLID];
    NSString *password = [dict objectForKey:MSG_EXT_CALLPSWD];
    
    //如果conferenceId不存在，则不处理
    if ([conferenceId length] == 0) {
        return;
    }
    
    EMConferenceViewController *controller = nil;
    do {
        controller = [[MeetingViewController alloc] initWithJoinConfId:conferenceId password:password type:EMConferenceTypeCommunication chatId:conferenceId chatType:EMChatTypeChat completion:^(EMCallConference *aCall, EMError *aError) {
            aCompletionBlock(aCall,aError);
        }];
    } while (0);
    
    if (controller) {
        gIsCalling = YES;
        self.confNavController = [[UINavigationController alloc] initWithRootViewController:controller];
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        UIViewController *rootViewController = window.rootViewController;
        self.confNavController.modalPresentationStyle = 0;
        [rootViewController presentViewController:self.confNavController animated:NO completion:nil];
    }
}


@end
