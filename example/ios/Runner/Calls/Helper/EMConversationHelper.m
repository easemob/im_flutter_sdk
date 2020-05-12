//
//  EMConversationHelper.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/14.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMConversationHelper.h"

#import "EMMulticastDelegate.h"


@implementation EMConversationModel

- (instancetype)initWithEMModel:(EMConversation *)aModel
{
    self = [super init];
    if (self) {
        _emModel = aModel;
        _name = aModel.conversationId;
    }
    
    return self;
}

@end


static EMConversationHelper *shared = nil;
@interface EMConversationHelper()

@property (nonatomic, strong) EMMulticastDelegate<EMConversationsDelegate> *delegates;

@end

@implementation EMConversationHelper

- (instancetype)init
{
    self = [super init];
    if (self) {
        _delegates = (EMMulticastDelegate<EMConversationsDelegate> *)[[EMMulticastDelegate alloc] init];
    }
    
    return self;
}

+ (instancetype)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[EMConversationHelper alloc] init];
    });
    
    return shared;
}

- (void)dealloc
{
    [self.delegates removeAllDelegates];
}

#pragma mark - Delegate

- (void)addDelegate:(id<EMConversationsDelegate>)aDelegate
{
    [self.delegates addDelegate:aDelegate delegateQueue:dispatch_get_main_queue()];
}

- (void)removeDelegate:(id<EMConversationsDelegate>)aDelegate
{
    [self.delegates removeDelegate:aDelegate];
}

#pragma mark - Class Methods

+ (NSArray<EMConversationModel *> *)modelsFromEMConversations:(NSArray<EMConversation *> *)aConversations
{
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    
    NSArray *groupArray = [[EMClient sharedClient].groupManager getJoinedGroups];
    for (int i = 0; i < [aConversations count]; i++) {
        EMConversation *conversation = aConversations[i];
        EMConversationModel *model = [[EMConversationModel alloc] initWithEMModel:conversation];
        if (conversation.type == EMConversationTypeGroupChat || conversation.type == EMConversationTypeChatRoom) {
            NSString *name = [conversation.ext objectForKey:@"subject"];
            if ([name length] == 0 && conversation.type == EMConversationTypeGroupChat) {
                for (EMGroup *group in groupArray) {
                    if ([group.groupId isEqualToString:conversation.conversationId]) {
                        NSMutableDictionary *ext = [NSMutableDictionary dictionaryWithDictionary:conversation.ext];
                        [ext setObject:group.subject forKey:@"subject"];
                        [ext setObject:[NSNumber numberWithBool:group.isPublic] forKey:@"isPublic"];
                        conversation.ext = ext;
                        name = group.subject;
                        break;
                    }
                }
            }
            
            model.name = name;
        }
        [retArray addObject:model];
    }
    
    return retArray;
}

+ (EMConversationModel *)modelFromContact:(NSString *)aContact
{
    EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:aContact type:EMConversationTypeChat createIfNotExist:YES];
    EMConversationModel *model = [[EMConversationModel alloc] initWithEMModel:conversation];
    return model;
}

+ (EMConversationModel *)modelFromGroup:(EMGroup *)aGroup
{
    EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:aGroup.groupId type:EMConversationTypeGroupChat createIfNotExist:YES];
    EMConversationModel *model = [[EMConversationModel alloc] initWithEMModel:conversation];
    model.name = aGroup.subject;
    
    NSMutableDictionary *ext = [NSMutableDictionary dictionaryWithDictionary:conversation.ext];
    [ext setObject:aGroup.subject forKey:@"subject"];
    [ext setObject:[NSNumber numberWithBool:aGroup.isPublic] forKey:@"isPublic"];
    conversation.ext = ext;
    
    return model;
}

+ (EMConversationModel *)modelFromChatroom:(EMChatroom *)aChatroom
{
    EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:aChatroom.chatroomId type:EMConversationTypeChatRoom createIfNotExist:YES];
    EMConversationModel *model = [[EMConversationModel alloc] initWithEMModel:conversation];
    model.name = aChatroom.subject;
    
    NSMutableDictionary *ext = [NSMutableDictionary dictionaryWithDictionary:conversation.ext];
    [ext setObject:aChatroom.subject forKey:@"subject"];
    conversation.ext = ext;
    
    return model;
}

+ (void)markAllAsRead:(EMConversationModel *)aConversationModel
{
    [aConversationModel.emModel markAllMessagesAsRead:nil];
    
    EMConversationHelper *helper = [EMConversationHelper shared];
    [helper.delegates didConversationUnreadCountToZero:aConversationModel];
}

+ (void)resortConversationsLatestMessage
{
    EMConversationHelper *helper = [EMConversationHelper shared];
    [helper.delegates didResortConversationsLatestMessage];
}

@end
