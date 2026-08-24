//
//  EMMessageSearchOption.h
//  HyphenateChat
//
//  Created by OpenAI Codex on 2026/4/2.
//

#import <Foundation/Foundation.h>
#import "EMConversation.h"

/**
 *  \~chinese
 *  搜索关键词的匹配方式。
 *  \~english
 *  The match type for search keywords.
 */
typedef NS_ENUM(NSInteger, EMKeywordListMatchType) {
    EMKeywordListMatchTypeOR,
    EMKeywordListMatchTypeAND
};
/**
 *  \~chinese
 *  服务端消息搜索的参数配置类。
 *  该功能需要在 Console 开通「消息搜索」增值服务。
 *
 *  \~english
 *  The parameter configuration class for server message search.
 *  This feature requires the "Message Search" service to be enabled in the Console.
 */
@interface EMMessageSearchOption : NSObject

/**
 \~chinese 搜索关键词列表（每个关键词 1-120 字符，总共最大120字符，最多5个关键词）。
 \~english The search keyword list (each keyword 1-120 characters, total maximum 120 characters, up to 5 keywords).
 */
@property (nonatomic, strong) NSArray<NSString *> * _Nonnull keywordList;

/**
 \~chinese 搜索关键词查询组合方式。
 \~english The search keyword match type
 */
@property (nonatomic) EMKeywordListMatchType keywordMatchType;

/**
 \~chinese 会话 ID 过滤（可选）。对于单聊，为对方用户 ID；对于群聊/聊天室，为群组/聊天室 ID。为空表示搜索所有会话。
 \~english Conversation ID filter (optional). For one-to-one chat, it is the other user's ID; for group/chatroom, it is the group/chatroom ID. Empty means searching all conversations.
 */
@property (nonatomic, strong) NSString * _Nullable conversationId;

/**
 \~chinese 消息类型过滤（可选），不支持透传消息和语音消息搜索。
 \~english Message type filter (optional), does not support command messages and voice messages search.
 */
@property (nonatomic, strong) NSArray<NSNumber *> * _Nullable msgTypes;

/**
 \~chinese 消息查询的起始时间，Unix 时间戳，单位为毫秒。需与 endTime 同时指定。
 \~english The start time for query. Unix timestamp in milliseconds. Must be specified with endTime.
 */
@property (nonatomic) NSInteger startTime;

/**
 \~chinese 消息查询的结束时间，Unix 时间戳，单位为毫秒。需与 startTime 同时指定。
 \~english The end time for query. Unix timestamp in milliseconds. Must be specified with startTime.
 */
@property (nonatomic) NSInteger endTime;

/**
 \~chinese 搜索范围（默认仅搜内容）。详见 {@link EMConversation.EMMessageSearchScope}。
 \~english Search scope (default content only). See {@link EMConversation.EMMessageSearchScope}.
 */
@property (nonatomic) EMMessageSearchScope searchScope;
@end
