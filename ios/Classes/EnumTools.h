//
//  EnumTools.h
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2024/10/23.
//

#import <Foundation/Foundation.h>
#import "ChatHeaders.h"

NS_ASSUME_NONNULL_BEGIN

@interface EnumTools : NSObject
+(NSInteger)messageBodyTypeToInt:(EMMessageBodyType)value;
+(EMMessageBodyType)messageBodyTypeFromInt:(NSInteger)value;
+(NSInteger)downloadStatusToInt:(EMDownloadStatus)value;
+(EMDownloadStatus)downloadStatusFromInt:(NSInteger)value;
+(NSInteger)chatTypeToInt:(EMChatType)value;
+(EMChatType)chatTypeFromInt:(NSInteger)value;
+(NSInteger)chatRoomPermissionTypeToInt:(EMChatroomPermissionType)value;
+(EMChatroomPermissionType)chatRoomPermissionTypeFromInt:(NSInteger)value;
+(NSInteger)groupPermissionTypeToInt:(EMGroupPermissionType)value;
+(EMGroupPermissionType)groupPermissionTypeFromInt:(NSInteger)value;
+(NSInteger)searchDirectionToInt:(EMMessageSearchDirection)value;
+(EMMessageSearchDirection)searchDirectionFromInt:(NSInteger)value;
+(NSInteger)conversationTypeToInt:(EMConversationType)value;
+(EMConversationType)conversationTypeFromInt:(NSInteger)value;
+(NSInteger)silentModeParamTypeToInt:(EMSilentModeParamType)value;
+(EMSilentModeParamType)silentModeParamTypeFromInt:(NSInteger)value;
+(NSInteger)remindTypeToInt:(EMPushRemindType)value;
+(EMPushRemindType)remindTypeFromInt:(NSInteger)value;
+(NSInteger)messageStatusToInt:(EMMessageStatus)value;
+(EMMessageStatus)messageStatusFromInt:(NSInteger)value;
+(NSInteger)messageDirectToInt:(EMMessageDirection)value;
+(EMMessageDirection)messageDirectFromInt:(NSInteger)value;
+(NSInteger)threadOperationToInt:(EMThreadOperation)value;
+(EMThreadOperation)threadOperationFromInt:(NSInteger)value;
+(NSInteger)reactionOperationToInt:(EMMessageReactionOperate)value;
+(EMMessageReactionOperate)recationOperationFromInt:(NSInteger)value;
@end

NS_ASSUME_NONNULL_END
