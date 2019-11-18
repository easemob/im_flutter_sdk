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

+ (NSArray *)dictionarysToMessages:(NSArray *)dicts;

+ (NSArray *)messagesToDictionarys:(NSArray *)messages;

+ (NSDictionary *)messagebodyToDictionary:(NSDictionary *)aDictionary;

#pragma mark - Conversation

+ (NSDictionary *)conversationToDictionary:(EMConversation *)aConversation;

#pragma mark - Group

+ (NSDictionary *)groupToDictionary:(EMGroup *)aGroup;

+ (NSArray *)groupsToDictionarys:(NSArray *)groups;

+ (NSDictionary *)groupSharedFileToDictionary:(EMGroupSharedFile *)sharedFile;

+ (NSArray *)groupFileListToDictionaryList:(NSArray *)groupFileList;

#pragma mark - ChatRoom

+ (NSDictionary *)chatRoomToDictionary:(EMChatroom *)aChatRoom;

+ (NSArray *)chatRoomsToDictionarys:(NSArray *)chatRooms;

#pragma mark - Others

+ (NSDictionary *)pageReslutToDictionary:(EMPageResult *)pageResult;



@end

NS_ASSUME_NONNULL_END
