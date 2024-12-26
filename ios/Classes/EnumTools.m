//
//  EnumTools.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2024/10/23.
//

#import "EnumTools.h"

@implementation EnumTools
+(NSInteger)messageBodyTypeToInt:(EMMessageBodyType)value {
    switch (value) {
        case EMMessageBodyTypeText:
            return 0;
            break;
        case EMMessageBodyTypeImage:
            return 1;
            break;
        case EMMessageBodyTypeVideo:
            return 2;
            break;
        case EMMessageBodyTypeLocation:
            return 3;
            break;
        case EMMessageBodyTypeVoice:
            return 4;
            break;
        case EMMessageBodyTypeFile:
            return 5;
            break;
        case EMMessageBodyTypeCmd:
            return 6;
            break;
        case EMMessageBodyTypeCustom:
            return 7;
            break;
        case EMMessageBodyTypeCombine:
            return 8;
            break;
        default:
            break;
    }
    return 0;
}

+(EMMessageBodyType)messageBodyTypeFromInt:(NSInteger)value{
    switch (value) {
        case 0:
            return EMMessageBodyTypeText;
            break;
        case 1:
            return EMMessageBodyTypeImage;
            break;
        case 2:
            return EMMessageBodyTypeVideo;
            break;
        case 3:
            return EMMessageBodyTypeLocation;
            break;
        case 4:
            return EMMessageBodyTypeVoice;
            break;
        case 5:
            return EMMessageBodyTypeFile;
            break;
        case 6:
            return EMMessageBodyTypeCmd;
            break;
        case 7:
            return EMMessageBodyTypeCustom;
            break;
        case 8:
            return EMMessageBodyTypeCombine;
            break;
        default:
            break;
    }
    return EMMessageBodyTypeText;
}

+(NSInteger)downloadStatusToInt:(EMDownloadStatus)value{
    return value;
}

+(EMDownloadStatus)downloadStatusFromInt:(NSInteger)value{
    return value;
}

+(NSInteger)chatTypeToInt:(EMChatType)value{
    return value;
}

+(EMChatType)chatTypeFromInt:(NSInteger)value{
    return value;
}

+(NSInteger)chatRoomPermissionTypeToInt:(EMChatroomPermissionType)value{
    switch (value) {
        case EMChatroomPermissionTypeMember:
            return 0;
            break;
        case EMChatroomPermissionTypeAdmin:
            return 1;
            break;
        case EMChatroomPermissionTypeOwner:
            return 2;
            break;
        case EMChatroomPermissionTypeNone:
            return 3;
            break;
        default:
            break;
    }
    return 3;
}

+(EMChatroomPermissionType)chatRoomPermissionTypeFromInt:(NSInteger)value{
    switch (value) {
        case 0:
            return EMChatroomPermissionTypeMember;
            break;
        case 1:
            return EMChatroomPermissionTypeAdmin;
            break;
        case 2:
            return EMChatroomPermissionTypeOwner;
            break;
        case 3:
            return EMChatroomPermissionTypeNone;
            break;
        default:
            break;
    }
    return EMChatroomPermissionTypeNone;
}

+(NSInteger)groupPermissionTypeToInt:(EMGroupPermissionType)value{
    switch (value) {
        case EMGroupPermissionTypeMember:
            return 0;
            break;
        case EMGroupPermissionTypeAdmin:
            return 1;
            break;
        case EMGroupPermissionTypeOwner:
            return 2;
            break;
        case EMGroupPermissionTypeNone:
            return 3;
            break;
        default:
            break;
    }
    return 3;
}

+(EMGroupPermissionType)groupPermissionTypeFromInt:(NSInteger)value{
    switch (value) {
        case 0:
            return EMGroupPermissionTypeMember;
            break;
        case 1:
            return EMGroupPermissionTypeAdmin;
            break;
        case 2:
            return EMGroupPermissionTypeOwner;
            break;
        case 3:
            return EMGroupPermissionTypeNone;
            break;
        default:
            break;
    }
    return EMGroupPermissionTypeNone;
}

+(NSInteger)searchDirectionToInt:(EMMessageSearchDirection)value{
    return value;
}

+(EMMessageSearchDirection)searchDirectionFromInt:(NSInteger)value{
    return value;
}

+(NSInteger)conversationTypeToInt:(EMConversationType)value{
    return value;
}

+(EMConversationType)conversationTypeFromInt:(NSInteger)value{
    return value;
}

+(NSInteger)silentModeParamTypeToInt:(EMSilentModeParamType)value{
    return value;
}

+(EMSilentModeParamType)silentModeParamTypeFromInt:(NSInteger)value{
    return value;
}

+(NSInteger)remindTypeToInt:(EMPushRemindType)value{
    return value;
}

+(EMPushRemindType)remindTypeFromInt:(NSInteger)value{
    return value;
}

+(NSInteger)messageStatusToInt:(EMMessageStatus)value{
    return value;
}

+(EMMessageStatus)messageStatusFromInt:(NSInteger)value{
    return value;
}

+(NSInteger)messageDirectToInt:(EMMessageDirection)value {
    return value;
}

+(EMMessageDirection)messageDirectFromInt:(NSInteger)value {
    return value;
}

+(NSInteger)threadOperationToInt:(EMThreadOperation)value {
    return value;
}

+(EMThreadOperation)threadOperationFromInt:(NSInteger)value {
    return value;
}

+(NSInteger)reactionOperationToInt:(EMMessageReactionOperate)value {
    return value;
}

+(EMMessageReactionOperate)recationOperationFromInt:(NSInteger)value {
    return value;
}
@end
