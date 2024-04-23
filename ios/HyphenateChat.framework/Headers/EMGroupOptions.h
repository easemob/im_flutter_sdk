/**
 *  \~chinese
 *  @header EMGroupOptions.h
 *  @abstract 群组属性选项
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header EMGroupOptions.h
 *  @abstract Group property options
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>

#define KSDK_GROUP_MINUSERSCOUNT 3
#define KSDK_GROUP_USERSCOUNTDEFAULT 200

/**
 *  \~chinese 
 *  群组类型。
 *
 *  \~english
 *  The group type.
 */
typedef NS_ENUM(NSInteger, EMGroupStyle) {
    EMGroupStylePrivateOnlyOwnerInvite  = 0,    /**! \~chinese 私有群组类型，只允许群主邀请用户加入。 \~english A private group, where only the group owner can invite users to join. */
    EMGroupStylePrivateMemberCanInvite,         /**! \~chinese 私有群组类型，群主和群成员均可邀请用户加入。 \~english A private group, where all the group members including the group owner, group manager, and other group members can invite users to join.  */
    EMGroupStylePublicJoinNeedApproval,         /**! \~chinese 公开群组类型，群主可以邀请用户加入; 非群成员用户发送入群申请，经群主同意后才能入组。 \~english A public group, where the group owner can invite users to user. Users can send a join request and join the group if the owner approves it. */
    EMGroupStylePublicOpenJoin,                 /**! \~chinese 公开群组类型，用户可以自由加入。 \~english A public group, where users can join freely. */
};

/**
 *  \~chinese
 *  群组属性选项。
 *
 *  \~english
 *  The group options.
 */
@interface EMGroupOptions : NSObject

/**
 *  \~chinese
 *  群组的类型。
 *
 *  \~english
 *  The group style.
 */
@property (nonatomic) EMGroupStyle style;

/**
 *  \~chinese
 *  群组的最大成员数。取值范围 [3,2000]，默认值 200。
 *
 *  \~english
 *  The maximum number of members in a group. The value range is [3,2000]; the default value is 200.
 */
@property (nonatomic) NSInteger maxUsers;

/**
 *  \~chinese
 *  是否需要发送邀请通知。如果设为 NO，则被邀请的人自动加入群组。
 *
 *  \~english
 *  Whether to send an invitation notification when inviting a user to join the group. If you set it as NO, the user joins the group automatically.
 */
@property (nonatomic) BOOL IsInviteNeedConfirm;

/**
 *  \~chinese
 *  扩展信息。
 *
 *  \~english
 *  The extra information of the group.
 */
@property (nonatomic, strong) NSString *ext;

#pragma mark - EM_DEPRECATED_IOS 3.8.8

/**
 *  \~chinese
 *  群组的最大成员数(3 - 2000，默认是200)
 *
 *  \~english
 *  The group capacity (3-2000, the default is 200)
 */
@property (nonatomic) NSInteger maxUsersCount
__deprecated_msg("Use maxUsers instead");


@end
