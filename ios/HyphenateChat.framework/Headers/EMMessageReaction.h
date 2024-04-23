//
//  EMMessageReaction.h
//  HyphenateChat
//
//  Created by 冯钊 on 2022/2/11.
//  Copyright © 2022 easemob.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  \~chinese
 *  消息Reaction类。
 *
 *  \~english
 *  The message reaction object.
 */
@interface EMMessageReaction : NSObject

/**
 *  \~chinese
 *  Reaction 内容。
 *
 *  \~english
 *  The Reaction content.
 */
@property (readonly, nullable) NSString *reaction;

/**
 *  \~chinese
 *  添加该 Reaction 的用户总数。
 *
 *  \~english
 *  The count of the users who added this Reaction.
 */
@property (readonly) NSUInteger count;

/**
 *  \~chinese
 *  当前用户是否添加了该 Reaction。
 * - `YES`: 是；
 * - `NO`: 否。
 *
 *  \~english
 *  Whether the current user added this Reaction.
 *  - `Yes`: Yes;
 *  - `No`: No.
 */
@property (readonly) BOOL isAddedBySelf;

/**
 *  \~chinese
 *  添加了指定 Reaction 的用户列表。
 *
 *  **Note**
 *  只有通过 {@link #getReactionDetail(IEMChatManager)} 接口获取的是全部用户的分页数据；其他相关接口如 {@link #reactionList(EMChatMessage)}、{@link #getReactionList(IEMChatManager)} 或者 {@link messageReactionDidChange(EMChatManagerDelegate)} 等都只包含前三个用户。
 *
 *  \~english
 *  The list of users that added this Reaction.
 *
 *  **Note**
 *  To get the entire list of users adding this Reaction, you can call {@link #getReactionDetail(IEMChatManager)} which returns the user list with pagination. Other methods like {@link #reactionList(EMChatMessage)}, {@link #getReactionList(IEMChatManager)} or {@link messageReactionDidChange(EMChatManagerDelegate)} can get the first three users.
 */
@property (readonly, nullable) NSArray <NSString *>*userList;

@end

NS_ASSUME_NONNULL_END
