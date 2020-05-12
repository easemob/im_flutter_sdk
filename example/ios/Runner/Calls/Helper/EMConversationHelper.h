//
//  EMConversationHelper.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/14.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Hyphenate/Hyphenate.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMConversationModel : NSObject

@property (nonatomic, strong) EMConversation *emModel;

@property (nonatomic, strong) NSString *name;

- (instancetype)initWithEMModel:(EMConversation *)aModel;

@end


@protocol EMConversationsDelegate;
@interface EMConversationHelper : NSObject

- (void)addDelegate:(id<EMConversationsDelegate>)aDelegate;

- (void)removeDelegate:(id<EMConversationsDelegate>)aDelegate;

+ (instancetype)shared;

+ (NSArray<EMConversationModel *> *)modelsFromEMConversations:(NSArray<EMConversation *> *)aConversations;

+ (EMConversationModel *)modelFromContact:(NSString *)aContact;

+ (EMConversationModel *)modelFromGroup:(EMGroup *)aGroup;

+ (EMConversationModel *)modelFromChatroom:(EMChatroom *)aChatroom;

//调用该方法，会触发[EMConversationsDelegate didConversationUnreadCountToZero:]
+ (void)markAllAsRead:(EMConversationModel *)aConversationModel;

//调用该方法，会触发[EMConversationsDelegate didResortConversationsLatestMessage]
+ (void)resortConversationsLatestMessage;

@end


@protocol EMConversationsDelegate <NSObject>

@optional

- (void)didConversationUnreadCountToZero:(EMConversationModel *)aConversation;

- (void)didResortConversationsLatestMessage;

@end

NS_ASSUME_NONNULL_END
