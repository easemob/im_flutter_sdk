//
//  EMHelper.m
//  
//
//  Created by 杜洁鹏 on 2019/10/8.
//

#import "EMHelper.h"
#import <Hyphenate/EMOptions+PrivateDeploy.h>

@implementation EMHelper

#pragma mark - ChatRoom
+ (EMCallOptions *)callOptionsDictionaryToEMCallOptions:(NSDictionary *)optionsDict
{
    EMCallOptions *options = [[EMClient sharedClient].callManager getCallOptions];
    options.isSendPushIfOffline = [optionsDict[@"isSendPushIfOffline"] boolValue];
    
    if ([optionsDict[@"userSetAutoResizing"] boolValue]) {
        options.videoResolution = EMCallVideoResolutionDefault;
    } else {
        options.videoResolution = EMCallVideoResolution1280_720;
    }
    options.pingInterval = [optionsDict[@"pingInterval"] intValue];
    options.maxVideoKbps = [optionsDict[@"maxVideoKbps"] intValue];
    options.minVideoKbps = [optionsDict[@"minVideoKbps"] intValue];
    options.maxVideoFrameRate = [optionsDict[@"maxVideoFrameRate"] intValue];
    options.maxAudioKbps = [optionsDict[@"maxAudioKbps"] intValue];
    
    return options;
}

#pragma mark - CallConference
+ (NSDictionary *)callConferenceToDictionary:(EMCallConference *)aCall {
    NSMutableDictionary *callConferenceDict = [NSMutableDictionary dictionary];
        
    if (aCall.confId) {
        callConferenceDict[@"conferenceId"] = aCall.confId;
    }
    callConferenceDict[@"password"] = @"";
    
    EMConferenceType conferenceType = aCall.type;
    int cType;
    if (conferenceType == EMConferenceTypeCommunication) {
        cType = 10;
    }
    callConferenceDict[@"conferenceType"] = [NSNumber numberWithInt:cType];
    
    EMConferenceRole conferenceRoleType = aCall.role;
    int roleType;
    if (conferenceRoleType == EMConferenceRoleNone) {
        roleType = 0;
    } else if (conferenceRoleType == EMConferenceRoleAudience) {
        roleType = 1;
    } else if (conferenceRoleType == EMConferenceRoleSpeaker) {
        roleType = 3;
    } else {
        roleType = 7;
    }
    callConferenceDict[@"conferenceRole"] = [NSNumber numberWithInt:roleType];
    
    if (aCall.memberCount) {
        callConferenceDict[@"memberNum"] = @(aCall.memberCount);
    }
    
    if (aCall.adminIds) {
        callConferenceDict[@"admins"] = aCall.adminIds;
    } else {
        callConferenceDict[@"admins"] = [NSArray array];
    }
  
    if (aCall.speakerIds) {
        callConferenceDict[@"speakers"] = aCall.speakerIds;
    } else {
        callConferenceDict[@"speakers"] = [NSArray array];
    }
    
    callConferenceDict[@"isRecordOnServer"] = [NSNumber numberWithBool:aCall.willRecord];
    
    return callConferenceDict;
}

@end
