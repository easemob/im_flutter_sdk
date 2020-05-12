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

#pragma mark - EMOptions
+ (EMOptions *)dictionaryToEMOptions:(NSDictionary *)aDictionary;

#pragma mark - Message

+ (EMMessage *)dictionaryToMessage:(NSDictionary *)aDictionary;

+ (NSDictionary *)messageToDictionary:(EMMessage *)aMessage;

+ (NSArray *)dictionariesToMessages:(NSArray *)dicts;

+ (NSArray *)messagesToDictionaries:(NSArray *)messages;

+ (NSDictionary *)messageBodyToDictionary:(EMMessageBody *)aBody;

#pragma mark - Conversation

+ (NSDictionary *)conversationToDictionary:(EMConversation *)aConversation;

#pragma mark - Group

+ (NSDictionary *)groupToDictionary:(EMGroup *)aGroup;

+ (NSArray *)groupsToDictionaries:(NSArray *)groups;

+ (NSDictionary *)groupSharedFileToDictionary:(EMGroupSharedFile *)sharedFile;

+ (NSArray *)groupFileListToDictionaries:(NSArray *)groupFileList;

#pragma mark - ChatRoom

+ (NSDictionary *)chatRoomToDictionary:(EMChatroom *)aChatRoom;

+ (NSArray *)chatRoomsToDictionaries:(NSArray *)chatRooms;

#pragma mark - ChatRoom

+ (EMCallOptions *)callOptionsDictionaryToEMCallOptions:(NSDictionary *)options;

#pragma mark - CallConference
+ (NSDictionary *)callConferenceToDictionary:(EMCallConference *)aCall;

#pragma mark - PushOptions
+ (NSDictionary *)pushOptionsToDictionary:(EMPushOptions *)aPushOptions;

#pragma mark - Others

+ (NSDictionary *)pageReslutToDictionary:(EMPageResult *)pageResult;



@end

NS_ASSUME_NONNULL_END
