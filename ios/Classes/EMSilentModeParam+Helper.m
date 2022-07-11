//
//  EMSilentModeParam+Helper.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2022/7/8.
//

#import "EMSilentModeParam+Helper.h"
#import "EMSilentModeTime+Helper.h"

@implementation EMSilentModeParam (Helper)
+ (EMSilentModeParam *)formJson:(NSDictionary *)dict {
    EMSilentModeParamType paramType = [self paramTypeFromInt:[dict[@"paramType"] intValue]];
    EMSilentModeParam *param = [[EMSilentModeParam alloc] initWithParamType:paramType];
    NSDictionary *dictStartTime = dict[@"startTime"];
    NSDictionary *dictEndTime = dict[@"endTime"];
    int duration = [dict[@"duration"] intValue];
    
    EMPushRemindType remindType = [self remindTypeFromInt:[dict[@"remindType"] intValue]];
    
    param.remindType = remindType;
    param.silentModeStartTime = [EMSilentModeTime formJson:dictStartTime];
    param.silentModeEndTime = [EMSilentModeTime formJson:dictEndTime];
    param.silentModeDuration = duration;
    return param;
}


+ (EMSilentModeParamType)paramTypeFromInt:(int)iParamType {
    EMSilentModeParamType ret = EMSilentModeParamTypeRemindType;
    if (iParamType == 0) {
        ret = EMSilentModeParamTypeRemindType;
    }else if (iParamType == 1) {
        ret = EMSilentModeParamTypeDuration;
    }else if (iParamType == 2) {
        ret = EMSilentModeParamTypeInterval;
    }
    return ret;
}

+ (EMPushRemindType)remindTypeFromInt:(int)iRemindTime {
    EMPushRemindType ret = EMPushRemindTypeAll;
    if (iRemindTime == 0) {
        ret = EMPushRemindTypeAll;
    }else if (iRemindTime == 1) {
        ret = EMPushRemindTypeMentionOnly;
    }else if (iRemindTime == 2) {
        ret = EMPushRemindTypeNone;
    }
    return ret;
}

+ (int)remindTypeToInt:(EMPushRemindType)type {
    int ret = 0;
    switch(type) {
        case EMPushRemindTypeAll:
            ret = 0;
            break;
        case EMPushRemindTypeMentionOnly:
            ret = 1;
            break;
        case EMPushRemindTypeNone:
            ret = 2;
            break;
    }
    return ret;
}

@end
