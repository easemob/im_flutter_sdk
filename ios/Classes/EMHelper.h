//
//  EMHelper.h
//  
//
//  Created by 杜洁鹏 on 2019/10/8.
//

#import <Foundation/Foundation.h>
#import <Hyphenate/Hyphenate.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMHelper : NSObject

#pragma mark - Message

+ (EMMessage *)dictionaryToMessage:(NSDictionary *)aDictionary;

+ (NSDictionary *)messageToDictionary:(EMMessage *)aMessage;

+ (NSDictionary *)messagebodyToDictionary:(NSDictionary *)aDictionary;

#pragma mark - Conversation

+ (NSDictionary *)conversationToDictionary:(EMConversation *)aConversation;

#pragma mark - Group

+ (NSDictionary *)groupToDictionary:(EMGroup *)aGroup;

#pragma mark - ChatRoom

+ (NSDictionary *)chatRoomToDictionary:(EMChatroom *)aChatRoom;

#pragma mark - Others

+ (NSDictionary *)pageReslutToDictionary:(NSDictionary *)aDictionary;



@end

NS_ASSUME_NONNULL_END
