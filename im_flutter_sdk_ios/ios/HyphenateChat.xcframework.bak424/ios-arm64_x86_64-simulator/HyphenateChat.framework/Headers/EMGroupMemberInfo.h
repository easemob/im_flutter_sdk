//
//  EMGroupMemberInfo.h
//  HyphenateChat
//
//  Created by 朱继超 on 2/28/25.
//  Copyright © 2025 easemob.com. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  \~chinese
 *  群组成员角色类型。
 *
 *  \~english
 *  The group member role type.
 */
typedef NS_ENUM(NSInteger, EMGroupPermissionType) {
    EMGroupPermissionTypeNone   = -1,    /** \~chinese 未知类型。 \~english The unknown type.*/
    EMGroupPermissionTypeMember = 0,     /** \~chinese 普通成员。  \~english The group member.*/
    EMGroupPermissionTypeAdmin,          /** \~chinese 群组管理员。 \~english The group admin.*/
    EMGroupPermissionTypeOwner,          /** \~chinese 群主。 \~english The group owner.*/
};

NS_ASSUME_NONNULL_BEGIN

@interface EMGroupMemberInfo : NSObject
/**
 *  \~chinese
 *  群成员的用户id。
 *
 *  \~english
 *   The user id of the group member.
 */
@property (nonatomic, copy) NSString *userId;

/**
 *  \~chinese
 *  群成员的加群时间。
 *
 *  \~english
 *   The time when the group member joined the group.
 */
@property (nonatomic, assign) NSUInteger joinedTimestamp;

/**
 * \~chinese
 * 群成员的角色。
 *
 * \~english
 * The role of the group member.
 */
@property (nonatomic, assign) EMGroupPermissionType role;

/**
 *  \~chinese
 *  群成员的群昵称。
 * \~english
 *  The group nickname of the group member.
 */
@property (nonatomic, copy) NSString* _Nullable namecard;

/**
 *  \~chinese
 *  群成员的昵称。
 * \~english
 *  The nickname of the group member.
 */
@property (nonatomic, copy) NSString* _Nullable nickname;

/**
 *  \~chinese
 *  群成员的头像URL。
 * \~english
 *  The avatar URL of the group member.
 */
@property (nonatomic, copy) NSString* _Nullable avatarUrl;

@end

NS_ASSUME_NONNULL_END
