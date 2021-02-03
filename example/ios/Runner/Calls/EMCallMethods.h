//
//  EMCallMethods.h
//  Runner
//
//  Created by 杜洁鹏 on 2021/1/21.
//

#import <Foundation/Foundation.h>

#pragma mark - EMCallManagerWrapper
static NSString * const EMMethodKeyStartCall = @"startCall";
static NSString * const EMMethodKeySetCallOptions = @"setCallOptions";
//static NSString * const EMMethodKeyGetCallOptions = @"getCallOptions";
// 兼容安卓
static NSString * const EMMethodKeyRegisterCallReceiver = @"registerCallReceiver";
static NSString * const EMMethodKeyRegisterCallSharedManager = @"registerCallSharedManager";

static NSString * const EMMethodKeyOnCallChanged = @"onCallChanged";

#pragma mark - EMConferenceManagerWrapper
static NSString * const EMMethodKeyCreateAndJoinConference = @"createAndJoinConference";
static NSString * const EMMethodKeyJoinConference = @"joinConference";
static NSString * const EMMethodKeyRegisterConferenceSharedManager = @"registerConferenceSharedManager";
