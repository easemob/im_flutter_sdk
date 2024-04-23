/**
 *  \~chinese
 *  @header EMGroupManagerDelegate.h
 *  @abstract 群组相关的管理协议类。
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header EMGroupManagerDelegate.h
 *  @abstract This protocol defined the callbacks of group.
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>

/**
 *  \~chinese 
 *  离开群组原因。
 *
 *  \~english
 *  The reasons for a group member leaving the group.
 */
typedef NS_ENUM(NSInteger, EMGroupLeaveReason) {
    EMGroupLeaveReasonBeRemoved = 0,    /** \~chinese 成员被群主移除。 \~english The member is removed by the group owner. */
    EMGroupLeaveReasonUserLeave,        /** \~chinese 成员主动离开群组。 \~english The member leaves the group.*/
    EMGroupLeaveReasonDestroyed,        /** \~chinese 群组被销毁。 \~english The group is destroyed.*/
};

@class EMGroup;
@class EMGroupSharedFile;

/**
 *  \~chinese
 *  群组相关的管理协议类。
 *
 *  \~english
 *  The group manager delegates.
 */
@protocol EMGroupManagerDelegate <NSObject>

@optional

/**
 *  \~chinese
 *  收到群组邀请回调。
 * 
 *  该回调是由远端用户发送群组邀请触发的。如，用户 A 邀请用户 B 入群，则用户 B 会收到该回调。
 *
 *  @param aGroupId    群组 ID。
 *  @param aGroupName  群组名称。
 *  @param aInviter    发送群组邀请的用户。
 *  @param aMessage    群组邀请的信息。
 *
 *  \~english
 *  Occurs when the user receives a group invitation.
 *
 *  This callback is triggered by a peer user sending a group invitation. For example, after user A sends user B a group invitation, user B receives this callback.
 *
 *  @param aGroupId          The group ID.
 *  @param aGroupName      The group name.
 *  @param aInviter          The user sending the group invitation.
 *  @param aMessage          The invitation message.
 */

- (void)groupInvitationDidReceive:(NSString *_Nonnull)aGroupId
                        groupName:(NSString *_Nonnull)aGroupName
                          inviter:(NSString *_Nonnull)aInviter
                          message:(NSString *_Nullable)aMessage;


/**
 *  \~chinese
 *  远端用户接受群组邀请回调。
 * 
 *  该回调是由远端用户接受本地用户发送的群组邀请触发的。如，用户 B 接受用户 A 的群组邀请后，用户 A 会收到该回调。
 *
 *  @param aGroup    群组实例。
 *  @param aInvitee  被邀请者。
 *
 *  \~english
 *  This callback is triggered when the peer user accepts the group invitation sent by the local user. For example, user B accepts the invitation of user A, user A receives this callback.
 *
 *  @param aGroup    The group instance.
 *  @param aInvitee  The user that accepts the invitation.
 */
- (void)groupInvitationDidAccept:(EMGroup *_Nonnull)aGroup
                         invitee:(NSString *_Nonnull)aInvitee;

/**
 *  \~chinese
 *  远端用户拒绝群组邀请回调。
 * 
 *  该回调是由远端用户拒绝本地用户发送的群组邀请触发的。如，用户 B 拒绝用户 A 的群组邀请后，用户 A 会收到该回调。
 *
 *  @param aGroup    群组。
 *  @param aInvitee  被邀请者。
 *  @param aReason   拒绝理由。
 *
 *  \~english
 *  Occurs when the group invitation is declined.
 *
 *  This callback is triggered when a peer user declines the group invitation sent by the local user. For example, user B declines the group invitation sent by user A, user A receives this callback.
 *
 *  @param aGroup    The group instance.
 *  @param aInvitee  The invitee.
 *  @param aReason   The reason for declining the group invitation.
 */
- (void)groupInvitationDidDecline:(EMGroup *_Nonnull)aGroup
                          invitee:(NSString *_Nonnull)aInvitee
                           reason:(NSString *_Nullable)aReason;

/**
 *  \~chinese
 *  自动加入群组回调。
 * 
 *  如果你在 EMOptions 中将 isAutoAcceptGroupInvitation 设为 YES，则在收到其他用户的群组邀请后，SDK 会自动进群，并触发该回调。
 * 
 * 
 *  @param aGroup    群组实例。
 *  @param aInviter  邀请者。
 *  @param aMessage  邀请消息。
 *
 *  \~english
 *  Occurs when the SDK automatically joins the group.
 * 
 *  If isAutoAcceptGroupInvitation in EMOptions is set as YES, when you receive a group invitation, the SDK automatically accepts the invitation and joins the group. 
 *   
 *  Needs to set the EMOptions's isAutoAcceptGroupInvitation property as YES.
 *
 *  @param aGroup    The group instance.
 *  @param aInviter  The inviter.
 *  @param aMessage  The invite message.
 */
- (void)didJoinGroup:(EMGroup *_Nonnull)aGroup
             inviter:(NSString *_Nonnull)aInviter
             message:(NSString *_Nullable)aMessage;

/**
 *  \~chinese
 *  离开群组回调。
 *
 *  @param aGroup    群组实例。
 *  @param aReason   离开原因。
 *
 *  \~english
 *  Occurs when the user leaves a group.
 *
 *  @param aGroup    The group instance.
 *  @param aReason   The reason for leaving the group.
 */
- (void)didLeaveGroup:(EMGroup *_Nonnull)aGroup
               reason:(EMGroupLeaveReason)aReason;

/**
 *  \~chinese
 *  群主收到用户入群申请回调。
 * 
 *  如果你将群组类型设置为 EMGroupStylePublicJoinNeedApproval，则用户申请入群时，群主会收到该回调。
 *
 *  @param aGroup     群组实例。
 *  @param aApplicant 申请者。
 *  @param aReason    申请者的附属信息。
 *
 *  \~english
 *  Occurs when the group owner receives a join request.
 * 
 *  If you set the group type as EMGroupStylePublicJoinNeedApproval, when a user requests to join the group, the group owner receives this callback.
 *
 *  @param aGroup     The group instance.
 *  @param aUsername  The user that sends the join request.
 *  @param aReason    The extra information for joining the group.
 */
- (void)joinGroupRequestDidReceive:(EMGroup *_Nonnull)aGroup
                              user:(NSString *_Nonnull)aUsername
                            reason:(NSString *_Nullable)aReason;

/**
 *  \~chinese
 *  群主拒绝入群申请回调。
 * 
 *  如果你将群组类型设为 EMGroupStylePublicJoinNeedApproval，则群主拒绝用户的入群申请后，该用户会收到该回调。
 * 
 *  @param aGroupId    群组 ID。
 *  @param aReason     拒绝理由。
 *
 *  \~english
 *  If you set the group type as EMGroupStylePublicJoinNeedApproval, when the group owner declines a join request, the user that sends the request receives this callback. 
 * 
 *  @param aGroupId    The group ID.
 *  @param aReason     The reason for declining the join request.
 */
- (void)joinGroupRequestDidDecline:(NSString *_Nonnull)aGroupId
                            reason:(NSString *_Nullable)aReason;

/**
 *  \~chinese
 * 加入群组申请已同意回调。
 * 
 *  如果你将群组类型设为 EMGroupStylePublicJoinNeedApproval，则群主同意用户的入群申请后，该用户会收到该回调。 
 * 
 *  @param aGroup   通过申请的群组。
 *
 *  \~english
 *  If you set the group type as EMGroupStylePublicJoinNeedApproval, when the group owner approves the join request, the user that sends the request receives this callback.
 *
 *  @param aGroup   The group instance.
 */
- (void)joinGroupRequestDidApprove:(EMGroup *_Nonnull)aGroup;

/**
 *  \~chinese
 *  群组列表发生变化回调。
 *
 *  @param aGroupList  群组列表，详见 <EMGroup>。
 *
 *  \~english
 *  Occurs when the group list updates.
 *
 *  @param aGroupList  The group NSArray. See <EMGroup>.
 */
- (void)groupListDidUpdate:(NSArray<EMGroup *> *_Nonnull)aGroupList;


/**
 *  \~chinese
 *  群成员加入群禁言列表回调。
 *
 *  @param aGroup           群组实例。
 *  @param aMutedMembers    被禁言的成员。
 *  @param aMuteExpire      禁言失效时间，当前不可用。禁言后是永久禁言，直到被取消禁言。
 *
 *  \~english
 *  Occurs when the group members are added to the group mute list.
 *
 *  @param aGroup           The group instance.
 *  @param aMutedMembers    The group members that are added to the mute list.
 *  @param aMuteExpire      The time when the mute state expires. This parameter is not available at the moment.
 */
- (void)groupMuteListDidUpdate:(EMGroup *_Nonnull)aGroup
             addedMutedMembers:(NSArray<NSString *> *_Nonnull)aMutedMembers
                    muteExpire:(NSInteger)aMuteExpire;

/**
 *  \~chinese
 *  成员被移出禁言列表回调。
 *
 *  @param aGroup           群组实例。
 *  @param aMutedMembers    移出禁言列表的成员。
 *
 *  \~english
 *  Occurs when the group members are removed from the mute list.
 *
 *  @param aGroup           The group instance.
 *  @param aMutedMembers    The group members removed from the mute list.
 */
- (void)groupMuteListDidUpdate:(EMGroup *_Nonnull)aGroup
           removedMutedMembers:(NSArray<NSString *> *_Nonnull)aMutedMembers;

/**
 *  \~chinese
 *  用户加入白名单回调。
 *
 *  @param aGroup           群组实例。
 *  @param aMembers         被加入白名单的成员。
 *
 *  \~english
 *  Occurs when the group members are added to the allowlist.
 *
 *  @param aGroup       The group instance.
 *  @param aMembers     The group members added to the allowlist.
 */
- (void)groupWhiteListDidUpdate:(EMGroup *_Nonnull)aGroup
          addedWhiteListMembers:(NSArray<NSString *> *_Nonnull)aMembers;

/**
 *  \~chinese
 *  用户被移出白名单回调。
 *
 *  @param aGroup           群组实例。
 *  @param aMembers         被移出白名单的成员。
 *
 *  \~english
 *  Occurs when the group members are removed from the allowlist.
 *
 *  @param aGroup        The group instance.
 *  @param aMembers      The group members removed from the allowlist.
 */
- (void)groupWhiteListDidUpdate:(EMGroup *_Nonnull)aGroup
        removedWhiteListMembers:(NSArray<NSString *> *_Nonnull)aMembers;


/**
*  \~chinese
*  群组全部成员禁言状态发生变化回调。
*
*  @param aGroup           群组实例。
*  @param aMuted           是否被全部禁言。
*
*  \~english
*  Occurs when the mute state of all group members changes.
*
*  @param aGroup           The group instance.
*  @param aMuted           Whether all the group members are muted.
*/
- (void)groupAllMemberMuteChanged:(EMGroup *_Nonnull)aGroup
                 isAllMemberMuted:(BOOL)aMuted;

/**
 *  \~chinese
 *  成员被加入管理员列表回调。
 *
 *  @param aGroup    群组实例。
 *  @param aAdmin    加入管理员列表的成员。
 *
 *  \~english
 *  Occurs when a group member is added to the admin list.
 *
 *  @param aGroup    The group instance.
 *  @param aAdmin    The group member added to the admin list.
 */
- (void)groupAdminListDidUpdate:(EMGroup *_Nonnull)aGroup
                     addedAdmin:(NSString *_Nonnull)aAdmin;

/**
 *  \~chinese
 *  成员被移出管理员列表回调。
 *
 *  @param aGroup    群组实例。
 *  @param aAdmin    移出管理员列表的成员。
 *
 *  \~english
 *  Occurs when a groupmember is removed from the admin list.
 *
 *  @param aGroup    The group instance.
 *  @param aAdmin    The group member removed from the admin list.
 */
- (void)groupAdminListDidUpdate:(EMGroup *_Nonnull)aGroup
                   removedAdmin:(NSString *_Nonnull)aAdmin;

/**
 *  \~chinese
 *  群组所有者有更新回调。
 *
 *  @param aGroup       群组实例。
 *  @param aNewOwner    新群主。
 *  @param aOldOwner    旧群主。
 *
 *  \~english
 *  Occurs when the group owner changes.
 *
 *  @param aGroup       The group instance.
 *  @param aNewOwner    The new owner.
 *  @param aOldOwner    The old owner.
 */
- (void)groupOwnerDidUpdate:(EMGroup *_Nonnull)aGroup
                   newOwner:(NSString *_Nonnull)aNewOwner
                   oldOwner:(NSString *_Nonnull)aOldOwner;

/**
 *  \~chinese
 *  用户加入群组回调。
 *
 *  @param aGroup       加入的群组。
 *  @param aUsername    加入群组的用户名。
 *
 *  \~english
 *  Occurs when a user joins a group.
 *
 *  @param aGroup       The group instance.
 *  @param aUsername    The user that joins the group.
 */
- (void)userDidJoinGroup:(EMGroup *_Nonnull)aGroup
                    user:(NSString *_Nonnull)aUsername;

/**
 *  \~chinese
 *  用户离开群组回调。
 *
 *  @param aGroup       离开的群组。
 *  @param aUsername    离开群组的用户名。
 *
 *  \~english
 *  Occurs when a user leaves the group.
 *
 *  @param aGroup       The group instance.
 *  @param aUsername    The user that leaves the group.
 */
- (void)userDidLeaveGroup:(EMGroup *_Nonnull)aGroup
                     user:(NSString *_Nonnull)aUsername;

/**
 *  \~chinese
 *  群公告更新回调。
 *
 *  @param aGroup           群组实例。
 *  @param aAnnouncement    群公告。
 *
 *  \~english
 *  Occurs when the group announcement updates.
 *
 *  @param aGroup           The group instance.
 *  @param aAnnouncement    The group announcement.
 */
- (void)groupAnnouncementDidUpdate:(EMGroup *_Nonnull)aGroup
                      announcement:(NSString *_Nullable)aAnnouncement;

/**
 *  \~chinese
 *  上传群共享文件回调。
 *
 *  @param aGroup       群组实例。
 *  @param aSharedFile  共享文件。
 *
 *  \~english
 *  Occurs when the group shared file is uploaded.
 *
 *  @param aGroup       The group instance.
 *  @param aSharedFile  The shared file.
 */
- (void)groupFileListDidUpdate:(EMGroup *_Nonnull)aGroup
               addedSharedFile:(EMGroupSharedFile *_Nonnull)aSharedFile;

/**
 *  \~chinese
 *  群共享文件被删除回调。
 *
 *  @param aGroup       群组实例。
 *  @param aFileId      共享文件 ID。
 *
 *  \~english
 *  Occurs when the shared file of the group is removed.
 *
 *  @param aGroup      The group instance.
 *  @param aFileId     The ID of the shared file.
 */
- (void)groupFileListDidUpdate:(EMGroup *_Nonnull)aGroup
             removedSharedFile:(NSString *_Nonnull)aFileId;

/**
 *  \~chinese
 *  群组禁用状态发生变化回调。
 *
 *  @param aGroup           群组实例。
 *  @param aDisabled           是否禁用。
 *
 *  \~english
 *  Occurs when the disabled state of group changes.
 *
 *  @param aGroup           The group instance.
 *  @param aDisabled        Whether the group is disabled.
 */
 - (void)groupStateChanged:(EMGroup *)aGroup
                isDisabled:(BOOL)aDisabled;

/**
 *  \~chinese
 *  群详情已有改动，需调用获取群详情api（IEMGroupManager.h : getGroupSpecificationFromServerWithId）得到最新群信息
 *
 *  @param aGroup       群组实例。
 *
 *  \~english
 *  Occurs when the group specification update,Need to call for details of the API (IEMGroupManager.h : getGroupSpecificationFromServerWithId) to get the latest information
 *
 *  @param aGroup      The group instance.
 */
- (void)groupSpecificationDidUpdate:(EMGroup *)aGroup;

#pragma mark - Deprecated methods
/**
 *  \~chinese
 *  收到群组邀请回调。
 *
 *  该回调是由远端用户发送群组邀请触发的。如，用户 A 邀请用户 B 入群，则用户 B 会收到该回调。
 *
 *  已废弃，请用 {@link groupInvitationDidReceive:groupName:inviter:message: } 代替。

 *  @param aGroupId    群组 ID。
 *  @param aInviter    发送群组邀请的用户。
 *  @param aMessage    群组邀请的信息。
 *
 *  \~english
 *  Occurs when the user receives a group invitation.
 *
 *  This callback is triggered by a peer user sending a group invitation. For example, after user A sends user B a group invitation, user B receives this callback.
 *
 *  Deprecated. Please use  {@link groupInvitationDidReceive:groupName:inviter:message: }  instead.
 *
 *  @param aGroupId          The group ID.
 *  @param aInviter          The user sending the group invitation.
 *  @param aMessage          The invitation message.
 */
- (void)groupInvitationDidReceive:(NSString *)aGroupId
                          inviter:(NSString *)aInviter
                          message:(NSString *)aMessage
                          __deprecated_msg("Use -groupInvitationDidReceive:groupName:inviter:message: instead");
@end
