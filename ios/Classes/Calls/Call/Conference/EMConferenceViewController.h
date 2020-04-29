//
//  EMConferenceViewController.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/9/20.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "EMCallViewController.h"

#import "DemoConfManager.h"
#import "EMStreamView.h"
#import "ConfInviteUsersViewController.h"
#import "AudioRecord.h"

#define kConferenceVideoMaxCol 2

//默认状态：
//1. 使用前置摄像头
//2. 不上传本地视频

typedef void (^ConferenceBlock)(EMCallConference *aCall,EMError *aError);
@interface EMConferenceViewController : EMCallViewController<EMConferenceManagerDelegate, EMStreamViewDelegate>

@property (nonatomic, strong) EMButton *switchCameraButton;
@property (nonatomic, strong) EMButton *videoButton;
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) EMStreamView *floatingView;

@property (nonatomic) float videoViewBorder;
@property (nonatomic) CGSize videoViewSize;

@property (nonatomic, strong) __block EMCallConference *conference;
@property (nonatomic, strong, readonly) NSString *joinConfId;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *admin;
@property (nonatomic, readonly) EMConferenceType type;
@property (nonatomic, readonly) BOOL isCreater;
@property (nonatomic) BOOL isUseBackCamera;

@property (nonatomic, strong, readonly) NSMutableArray *talkingStreamIds;

@property (nonatomic, strong, readonly) NSMutableDictionary *streamItemDict;
@property (nonatomic, strong) NSString *pubStreamId;
@property (nonatomic, strong) NSMutableArray *streamIds;

@property (nonatomic, strong, readonly) NSMutableArray *inviteUsers;
@property (nonatomic) ConfInviteType inviteType;

@property (nonatomic, strong, readonly) NSString *chatId;
@property (nonatomic, readonly) EMChatType chatType;
@property (nonatomic, assign) BOOL isRecord;
@property (nonatomic, assign) BOOL isMerge;
@property (nonatomic, copy) ConferenceBlock confResultBlock;

@property (nonatomic) CGRect floatViewFromFrame;

@property (nonatomic, strong) AudioRecord* audioRecord;

- (instancetype)initWithType:(EMConferenceType)aType
                    password:(NSString *)aPassword
                 inviteUsers:(NSArray *)aInviteUsers
                      chatId:(NSString *)aChatId
                    chatType:(EMChatType)aChatType;

- (instancetype)initWithType:(EMConferenceType)aType
                    password:(NSString *)aPassword
                 inviteUsers:(NSArray *)aInviteUsers
                      chatId:(NSString *)aChatId
                    chatType:(EMChatType)aChatType
                      record:(BOOL)isRecord
                       merge:(BOOL)isMerge
                  completion:(void (^)(EMCallConference *aCall,EMError *aError))aCompletionBlock;;

- (instancetype)initWithJoinConfId:(NSString *)aConfId
                          password:(NSString *)aPassword
                              type:(EMConferenceType)aType
                            chatId:(NSString *)aChatId
                          chatType:(EMChatType)aChatType;

- (instancetype)initWithJoinConfId:(NSString *)aConfId
                          password:(NSString *)aPassword
                              type:(EMConferenceType)aType
                            chatId:(NSString *)aChatId
                          chatType:(EMChatType)aChatType
                        completion:(void (^)(EMCallConference *aCall,EMError *aError))aCompletionBlock;

//stream
- (CGRect)getNewVideoViewFrame;

- (EMStreamItem *)setupNewStreamItemWithName:(NSString *)aName
                                 displayView:(UIView *)aDisplayView
                                      stream:(EMCallStream *)aStream;

- (void)pubLocalStreamWithEnableVideo:(BOOL)aEnableVideo
                           completion:(void (^)(NSString *aPubStreamId, EMError *aError))aCompletionBlock;

- (void)removeStreamWithId:(NSString *)aStreamId;

//member
- (void)sendInviteMessageWithChatId:(NSString *)aChatId
                           chatType:(EMChatType)aChatType;

//action
- (void)videoButtonAction:(EMButton *)aButton;

@end
