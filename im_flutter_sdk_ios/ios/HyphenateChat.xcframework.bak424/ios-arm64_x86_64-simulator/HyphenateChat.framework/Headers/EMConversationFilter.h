//
//  EMConversationFilter.h
//  HyphenateChat
//
//  Created by li xiaoming on 2023/12/6.
//  Copyright © 2023 easemob.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMConversation.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  \~chinese
 *  会话过滤类。
 *
 *  \~english
 *  The conversation filter class.
 */
@interface EMConversationFilter : NSObject

/**
 * \~chinese
 * 每页获取的的会话数。取值范围为 [1,10]。
 *
 * \~english
 * The number of conversations to retrieve on each page. The value range is [1,10].
 *
 */
@property (nonatomic) NSInteger pageSize;

/**
 * \~chinese
 * 查询的会话标记。
 *
 * \~english
 * The conversation mark.
 *
 */
@property (nonatomic) EMMarkType mark;

/**
 *  \~chinese
 *  初始化会话过滤类。
 *
 *  @param mark   会话标记。
 *  @param pageSize 每页拉取的会话数。取值范围为 [1,10]。
 *
 *  @result 会话过滤类实例。
 *
 *  \~english
 *  Initializes the conversation filter class.
 *
 *  @param mark   The conversation mark.
 *  @param pageSize The number of conversations to retrieve on each page. The value range is [1,10].
 *
 *  @result The conversation filter instance.
 */
- (instancetype _Nonnull)initWithMark:(EMMarkType)mark pageSize:(NSInteger)pageSize;
@end

NS_ASSUME_NONNULL_END
