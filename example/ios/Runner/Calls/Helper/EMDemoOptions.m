//
//  EMDemoOptions.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/12/17.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "EMDemoOptions.h"

#import <Hyphenate/EMOptions+PrivateDeploy.h>

static EMDemoOptions *sharedOptions = nil;
@implementation EMDemoOptions

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _initServerOptions];
        
        self.isDeleteMessagesWhenExitGroup = NO;
        self.isAutoAcceptGroupInvitation = NO;
        self.isAutoTransferMessageAttachments = YES;
        self.isAutoDownloadThumbnail = YES;
        self.isSortMessageByServerTime = NO;
        self.isPriorityGetMsgFromServer = NO;
        
        self.isAutoLogin = NO;
        self.loggedInUsername = @"";
        self.loggedInPassword = @"";
        
        self.isChatTyping = NO;
        self.isAutoDeliveryAck = NO;
        
        self.isOfflineHangup = NO;
        
        self.isShowCallInfo = NO;
        self.isUseBackCamera = NO;
        
        self.willRecord = NO;
        self.willMergeStrem = NO;
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        NSString *appkey = [aDecoder decodeObjectForKey:kOptions_Appkey];
        if ([appkey length] == 0) {
            appkey = DEF_APPKEY;
        }
        self.appkey = appkey;
        self.apnsCertName = [aDecoder decodeObjectForKey:kOptions_ApnsCertname];
        self.usingHttpsOnly = [aDecoder decodeBoolForKey:kOptions_HttpsOnly];
        
        self.specifyServer = [aDecoder decodeBoolForKey:kOptions_SpecifyServer];
        self.chatPort = [aDecoder decodeIntForKey:kOptions_IMPort];
        self.chatServer = [aDecoder decodeObjectForKey:kOptions_IMServer];
        self.restServer = [aDecoder decodeObjectForKey:kOptions_RestServer];
        
        self.isDeleteMessagesWhenExitGroup = [aDecoder decodeBoolForKey:kOptions_DeleteChatExitGroup];
        self.isAutoAcceptGroupInvitation = [aDecoder decodeBoolForKey:kOptions_AutoAcceptGroupInvitation];
        self.isAutoTransferMessageAttachments = [aDecoder decodeBoolForKey:kOptions_AutoTransMsgFile];
        self.isAutoDownloadThumbnail = [aDecoder decodeBoolForKey:kOptions_AutoDownloadThumb];
        self.isSortMessageByServerTime = [aDecoder decodeBoolForKey:kOptions_SortMessageByServerTime];
        self.isPriorityGetMsgFromServer = [aDecoder decodeBoolForKey:kOptions_PriorityGetMsgFromServer];
        
        self.isAutoLogin = [aDecoder decodeBoolForKey:kOptions_AutoLogin];
        self.loggedInUsername = [aDecoder decodeObjectForKey:kOptions_LoggedinUsername];
        self.loggedInPassword = [aDecoder decodeObjectForKey:kOptions_LoggedinPassword];
        
        self.isChatTyping = [aDecoder decodeBoolForKey:kOptions_ChatTyping];
        self.isAutoDeliveryAck = [aDecoder decodeBoolForKey:kOptions_AutoDeliveryAck];
        
        self.isOfflineHangup = [aDecoder decodeBoolForKey:kOptions_OfflineHangup];
        
        self.isShowCallInfo = [aDecoder decodeBoolForKey:kOptions_ShowCallInfo];
        self.isUseBackCamera = [aDecoder decodeBoolForKey:kOptions_UseBackCamera];

        self.willRecord = [aDecoder decodeBoolForKey:kOptions_WillRecord];
        self.willMergeStrem = [aDecoder decodeBoolForKey:kOptions_WillMergeStrem];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.appkey forKey:kOptions_Appkey];
    [aCoder encodeObject:self.apnsCertName forKey:kOptions_ApnsCertname];
    [aCoder encodeBool:self.usingHttpsOnly forKey:kOptions_HttpsOnly];
    
    [aCoder encodeBool:self.specifyServer forKey:kOptions_SpecifyServer];
    [aCoder encodeInt:self.chatPort forKey:kOptions_IMPort];
    [aCoder encodeObject:self.chatServer forKey:kOptions_IMServer];
    [aCoder encodeObject:self.restServer forKey:kOptions_RestServer];
    
    [aCoder encodeBool:self.isDeleteMessagesWhenExitGroup forKey:kOptions_DeleteChatExitGroup];
    [aCoder encodeBool:self.isAutoAcceptGroupInvitation forKey:kOptions_AutoAcceptGroupInvitation];
    [aCoder encodeBool:self.isAutoTransferMessageAttachments forKey:kOptions_AutoTransMsgFile];
    [aCoder encodeBool:self.isAutoDownloadThumbnail forKey:kOptions_AutoDownloadThumb];
    [aCoder encodeBool:self.isSortMessageByServerTime forKey:kOptions_SortMessageByServerTime];
    [aCoder encodeBool:self.isPriorityGetMsgFromServer forKey:kOptions_PriorityGetMsgFromServer];
    
    [aCoder encodeBool:self.isAutoLogin forKey:kOptions_AutoLogin];
    [aCoder encodeObject:self.loggedInUsername forKey:kOptions_LoggedinUsername];
    [aCoder encodeObject:self.loggedInPassword forKey:kOptions_LoggedinPassword];
    
    [aCoder encodeBool:self.isChatTyping forKey:kOptions_ChatTyping];
    [aCoder encodeBool:self.isAutoDeliveryAck forKey:kOptions_AutoDeliveryAck];
    
    [aCoder encodeBool:self.isOfflineHangup forKey:kOptions_OfflineHangup];
    
    [aCoder encodeBool:self.isShowCallInfo forKey:kOptions_ShowCallInfo];
    [aCoder encodeBool:self.isUseBackCamera forKey:kOptions_UseBackCamera];
    
    [aCoder encodeBool:self.willRecord forKey:kOptions_WillRecord];
    [aCoder encodeBool:self.willMergeStrem forKey:kOptions_WillMergeStrem];
}

- (id)copyWithZone:(nullable NSZone *)zone
{
    EMDemoOptions *retModel = [[[self class] alloc] init];
    retModel.appkey = self.appkey;
    retModel.apnsCertName = self.apnsCertName;
    retModel.usingHttpsOnly = self.usingHttpsOnly;
    retModel.specifyServer = self.specifyServer;
    retModel.chatPort = self.chatPort;
    retModel.chatServer = self.chatServer;
    retModel.restServer = self.restServer;
    retModel.isDeleteMessagesWhenExitGroup = self.isDeleteMessagesWhenExitGroup;
    retModel.isAutoAcceptGroupInvitation = self.isAutoAcceptGroupInvitation;
    retModel.isAutoTransferMessageAttachments = self.isAutoTransferMessageAttachments;
    retModel.isAutoDownloadThumbnail = self.isAutoDownloadThumbnail;
    retModel.isSortMessageByServerTime = self.isSortMessageByServerTime;
    retModel.isPriorityGetMsgFromServer = self.isPriorityGetMsgFromServer;
    retModel.isAutoLogin = self.isAutoLogin;
    retModel.loggedInUsername = self.loggedInUsername;
    retModel.loggedInPassword = self.loggedInPassword;
    retModel.isChatTyping = self.isChatTyping;
    retModel.isAutoDeliveryAck = self.isAutoDeliveryAck;
    retModel.isOfflineHangup = self.isOfflineHangup;
    retModel.isShowCallInfo = self.isShowCallInfo;
    retModel.isUseBackCamera = self.isUseBackCamera;
    retModel.willRecord = self.willRecord;
    retModel.willMergeStrem = self.willMergeStrem;
    return retModel;
}

- (void)setLoggedInUsername:(NSString *)loggedInUsername
{
    if (![_loggedInUsername isEqualToString:loggedInUsername]) {
        _loggedInUsername = loggedInUsername;
        _loggedInPassword = @"";
    }
}

#pragma mark - Private

- (void)_initServerOptions
{
    self.appkey = DEF_APPKEY;
#if DEBUG
    self.apnsCertName = @"chatdemoui_dev";
#else
    self.apnsCertName = @"chatdemoui";
#endif
    self.usingHttpsOnly = NO;
    self.specifyServer = NO;
    self.chatServer = @"39.107.54.56";
    self.chatPort = 6717;
    self.restServer = @"a1-hsb.easemob.com";
}

#pragma mark - Public

- (void)archive
{
    NSString *fileName = @"emdemo_options.data";
    NSString *file = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:fileName];
    [NSKeyedArchiver archiveRootObject:self toFile:file];
}

#pragma mark - Class Methods

+ (instancetype)sharedOptions
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedOptions = [EMDemoOptions getOptionsFromLocal];
    });
    
    return sharedOptions;
}

+ (EMDemoOptions *)getOptionsFromLocal
{
    EMDemoOptions *retModel = nil;
    NSString *fileName = @"emdemo_options.data";
    NSString *file = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:fileName];
    retModel = [NSKeyedUnarchiver unarchiveObjectWithFile:file];
    if (!retModel) {
        retModel = [[EMDemoOptions alloc] init];
        [retModel archive];
    }
    
    return retModel;
}

+ (void)reInitAndSaveServerOptions
{
    EMDemoOptions *demoOptions = [EMDemoOptions sharedOptions];
    [demoOptions _initServerOptions];
    
    [demoOptions archive];
}

+ (void)updateAndSaveServerOptions:(NSDictionary *)aDic
{
    NSString *appkey = [aDic objectForKey:kOptions_Appkey];
    NSString *apns = [aDic objectForKey:kOptions_ApnsCertname];
    BOOL httpsOnly = [[aDic objectForKey:kOptions_HttpsOnly] boolValue];
    if ([appkey length] == 0) {
        appkey = DEF_APPKEY;
    }
    if ([apns length] == 0) {
#if DEBUG
        apns = @"chatdemoui_dev";
#else
        apns = @"chatdemoui";
#endif
    }
    
    EMDemoOptions *demoOptions = [EMDemoOptions sharedOptions];
    demoOptions.appkey = appkey;
    demoOptions.apnsCertName = apns;
    demoOptions.usingHttpsOnly = httpsOnly;
    
    int specifyServer = [[aDic objectForKey:kOptions_SpecifyServer] intValue];
    demoOptions.specifyServer = NO;
    if (specifyServer != 0) {
        demoOptions.specifyServer = YES;
        
        NSString *imServer = [aDic objectForKey:kOptions_IMServer];
        NSString *imPort = [aDic objectForKey:kOptions_IMPort];
        NSString *restServer = [aDic objectForKey:kOptions_RestServer];
        if ([imServer length] > 0 && [restServer length] > 0 && [imPort length] > 0) {
            demoOptions.chatPort = [imPort intValue];
            demoOptions.chatServer = imServer;
            demoOptions.restServer = restServer;
        }
    }
    
    [demoOptions archive];
}

@end
