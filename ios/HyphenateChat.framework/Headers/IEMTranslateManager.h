//
//  IEMTranslateManager.h
//  HyphenateSDK
//
//  Created by lixiaoming on 2021/11/10.
//  Copyright © 2021 easemob.com. All rights reserved.
//

#ifndef IEMTranslateManager_h
#define IEMTranslateManager_h
#import "EMTranslationResult.h"
/*!
 *  \~chinese
 *  @header IEMTranslateManager.h
 *  @abstract 翻译服务数据接口
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header IEMTranslateManager.h
 *  @abstract Translate service manager interface
 *  @author Hyphenate
 *  @version 3.00
 */
@protocol IEMTranslateManager <NSObject>
/*!
 *  \~chinese
 *  设置消息的翻译信息
 *
 *  @param translate       翻译信息
 *
 *  \~english
 *  Set translate info of message
 *
 *  @param translate       The translate info to set
 */
- (BOOL)updateTranslate:(EMTranslationResult*)translate conversationId:(NSString*)conversationId;
/*!
 *  \~chinese
 *  根据消息id获取翻译信息
 *
 *  @param  msgId               Message Id
 *  @result translate       翻译信息
 *
 *  \~english
 *  Get translate info by messageId
 *
 *  @param msgId               Message Id
 *  @result translate       The translate info to set
 */
- (EMTranslationResult*)getTranslationResultByMsgId:(NSString*)msgId;
/*!
 *  \~chinese
 *  获取指定条数的最新消息翻译信息
 *
 *  @param  count               翻译条数
 *  @result translateResults       获取到的翻译信息
 *
 *  \~english
 *  Gets the latest message translation information for the specified number of messages
 *
 *  @param count               Message Id
 *  @result translateResults       The translates info getted
 */
- (NSArray<EMTranslationResult*>*)loadTranslateResults:(NSNumber*)count;
/*!
 *  \~chinese
 *  根据消息ID删除翻译信息
 *
 *  @param  msgIds               要删除翻译信息的消息ID数组
 *
 *  \~english
 *  Remove translation infos by messageIds
 *
 *  @param msgIds       MessageIds to remove translation info
 */
- (BOOL)removeTranslationsByMsgId:(NSArray<NSString*>*)msgIds;
/*!
 *  \~chinese
 *  根据会话ID删除翻译信息
 *
 *  @param  msgIds               要删除翻译信息的消息ID数组
 *
 *  \~english
 *  Remove translation infos by conversationId
 *
 *  @param conversationId       conversationId to remove translation info
 */
- (BOOL)removeTranslationsByConversationId:(NSString*)conversationId;
/*!
 *  \~chinese
 *  删除所有的翻译信息
 *
 *  \~english
 *  Remove all translation infos
 *
 */
- (BOOL)removeAllTranslations;
@end

#endif /* IEMTranslateManager_h */
