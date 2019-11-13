//
//  EMHelper.m
//  
//
//  Created by 杜洁鹏 on 2019/10/8.
//

#import "EMHelper.h"

@implementation EMHelper


#pragma mark - Message

+ (EMMessage *)dictionaryToMessage:(NSDictionary *)aDictionary {
    return nil;
}

+ (NSDictionary *)messageToDictionary:(EMMessage *)aMessage {
    return nil;
}

+ (NSDictionary *)messagebodyToDictionary:(NSDictionary *)aDictionary {
    return nil;
}

#pragma mark - Conversation

+ (NSDictionary *)conversationToDictionary:(EMConversation *)aConversation {
    return [NSMutableDictionary dictionary];
}

#pragma mark - Group

+ (NSDictionary *)groupToDictionary:(EMGroup *)aGroup {
    return nil;
}

#pragma mark - ChatRoom

+ (NSDictionary *)chatRoomToDictionary:(EMChatroom *)aChatRoom {
    return nil;
}

#pragma mark - Others

+ (NSDictionary *)pageReslutToDictionary:(NSDictionary *)aDictionary {
    return nil;
}


@end
