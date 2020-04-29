//
//  EMDemoOptions.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/12/17.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *kOptions_Appkey = @"Appkey";
static NSString *kOptions_ApnsCertname = @"ApnsCertname";
static NSString *kOptions_HttpsOnly = @"HttpsOnly";

static NSString *kOptions_SpecifyServer = @"SpecifyServer";
static NSString *kOptions_IMPort = @"IMPort";
static NSString *kOptions_IMServer = @"IMServer";
static NSString *kOptions_RestServer = @"RestServer";

static NSString *kOptions_AutoAcceptGroupInvitation = @"AutoAcceptGroupInvitation";
static NSString *kOptions_AutoTransMsgFile = @"AutoTransferMessageAttachments";
static NSString *kOptions_AutoDownloadThumb = @"AutoDownloadThumbnail";
static NSString *kOptions_DeleteChatExitGroup = @"DeleteChatExitGroup";
static NSString *kOptions_SortMessageByServerTime = @"SortMessageByServerTime";
static NSString *kOptions_PriorityGetMsgFromServer = @"PriorityGetMsgFromServer";

static NSString *kOptions_AutoLogin = @"AutoLogin";
static NSString *kOptions_LoggedinUsername = @"LoggedinUsername";
static NSString *kOptions_LoggedinPassword = @"LoggedinPassword";

static NSString *kOptions_ChatTyping = @"ChatTyping";
static NSString *kOptions_AutoDeliveryAck = @"AutoDeliveryAck";

static NSString *kOptions_OfflineHangup = @"OfflineHangup";

static NSString *kOptions_ShowCallInfo = @"ShowCallInfo";
static NSString *kOptions_UseBackCamera = @"UseBackCamera";

static NSString *kOptions_WillRecord = @"WillRecord";
static NSString *kOptions_WillMergeStrem = @"WillMergeStrem";

#define DEF_APPKEY @"easemob-demo#chatdemoui"

NS_ASSUME_NONNULL_BEGIN

@class EMOptions;
@interface EMDemoOptions : NSObject <NSCoding, NSCopying>

@property (nonatomic, copy) NSString *appkey;

@property (nonatomic, copy) NSString *apnsCertName;

@property (nonatomic, assign) BOOL usingHttpsOnly;

@property (nonatomic) BOOL specifyServer;

@property (nonatomic, assign) int chatPort;

@property (nonatomic, copy) NSString *chatServer;

@property (nonatomic, copy) NSString *restServer;

@property (nonatomic) BOOL isDeleteMessagesWhenExitGroup;
@property (nonatomic) BOOL isAutoAcceptGroupInvitation;
@property (nonatomic) BOOL isAutoTransferMessageAttachments;
@property (nonatomic) BOOL isAutoDownloadThumbnail;
@property (nonatomic) BOOL isSortMessageByServerTime;
@property (nonatomic) BOOL isPriorityGetMsgFromServer;

@property (nonatomic) BOOL isAutoLogin;
@property (nonatomic, strong) NSString *loggedInUsername;
@property (nonatomic, strong) NSString *loggedInPassword;

@property (nonatomic) BOOL isChatTyping;
@property (nonatomic) BOOL isAutoDeliveryAck;

@property (nonatomic) BOOL isOfflineHangup;

@property (nonatomic) BOOL isShowCallInfo;
@property (nonatomic) BOOL isUseBackCamera;

@property (nonatomic) BOOL willRecord;
@property (nonatomic) BOOL willMergeStrem;

@property (nonatomic) BOOL enableCustomAudioData;
@property (nonatomic) int  customAudioDataSamples;



+ (instancetype)sharedOptions;

+ (void)reInitAndSaveServerOptions;

+ (void)updateAndSaveServerOptions:(NSDictionary *)aDic;

- (void)archive;

@end

NS_ASSUME_NONNULL_END
