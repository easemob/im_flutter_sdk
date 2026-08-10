/**
 *  \~chinese
 *  @header EMChatroom.h
 *  @abstract 聊天室
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header EMChatroom.h
 *  @abstract Chatroom
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>

#import "EMCommonDefs.h"

/**
 *  \~chinese
 *  聊天室成员类型枚举。
 *
 *  \~english
 *  The enum of chat room permission types.
 */
typedef NS_ENUM(NSInteger, EMChatroomPermissionType) {
    EMChatroomPermissionTypeNone   = -1,    /** \~chinese 未知类型  \~english Unknown type*/
    EMChatroomPermissionTypeMember = 0,     /** \~chinese 普通成员类型  \~english Normal member type*/
    EMChatroomPermissionTypeAdmin,          /** \~chinese 聊天室管理员类型  \~english Chatroom admin type*/
    EMChatroomPermissionTypeOwner,          /** \~chinese 聊天室拥有者类型  \~english Chatroom owner  type*/
};


/**
 *  \~chinese
 *  聊天室实例，需要先调用 getChatroomSpecificationFromServerWithId 方法获取该聊天室详情。
 *
 *  \~english
 *  The chat room object.
 */
@interface EMChatroom : NSObject

/**
 *  \~chinese
 *  聊天室 ID，需要先调用 getChatroomSpecificationFromServerWithId 方法获取该聊天室详情。
 *
 *  \~english
 *  The chat room ID.
 */
@property (nonatomic, copy, readonly) NSString * _Nullable chatroomId;

/**
 *  \~chinese
 *  聊天室的主题，需要先调用 getChatroomSpecificationFromServerWithId 方法获取该聊天室详情。
 *
 *  \~english
 *  The subject of the chat room.
 */
@property (nonatomic, copy, readonly) NSString * _Nullable subject;

/**
 *  \~chinese
 *  聊天室的描述，需要先调用 getChatroomSpecificationFromServerWithId 方法获取该聊天室详情。
 *
 *  \~english
 *  The description of chat room.
 */
@property (nonatomic, copy, readonly) NSString * _Nullable description;

/**
 *  \~chinese
 *  聊天室的所有者，需要先调用 getChatroomSpecificationFromServerWithId 方法获取该聊天室详情。
 *
 *  聊天室的所有者只有一人。
 *
 *  \~english
 *  The owner of the chat room. There is only one owner per chat room.
 */
@property (nonatomic, copy, readonly) NSString * _Nullable owner;

/**
 *  \~chinese
 *  聊天室的公告，需要先调用 getChatroomAnnouncementWithId 方法获取该聊天室详情。
 *
 *  \~english
 *  The announcement of the chat room.
 */
@property (nonatomic, copy, readonly) NSString * _Nullable announcement;

/**
 *  \~chinese
 *  聊天室的管理者，拥有聊天室的最高权限，需要先调用 getChatroomSpecificationFromServerWithId 方法获取该聊天室详情。
 *
 *
 *  \~english
 *  The admins of the chatroom.
 *
 */
@property (nonatomic, copy, readonly) NSArray<NSString *> * _Nullable adminList;

/**
 *  \~chinese
 *  聊天室的成员列表，通过分页获取聊天室成员列表接口加载。
 *
 *  \~english
 *  The list of members in the chat room.
 */
@property (nonatomic, copy, readonly) NSArray<NSString *> * _Nullable memberList;

/**
 *  \~chinese
 *  聊天室的黑名单，需要先调用获取聊天室黑名单方法。
 *
 *  只有聊天室所有者有权限调用该方法，非聊天室所有者返回 nil。
 *
 *  \~english
 *  The blocklist of the chatroom.
 *
 *  Only the chatroom owner can call the method. Returns nil if the user is not the chatroom owner.
 */
@property (nonatomic, strong, readonly) NSArray<NSString *> * _Nullable blacklist;

/**
 *  \~chinese
 *  聊天室的被禁言列表。
 *
 *  只有聊天室所有者有权限调用该方法，非聊天室所有者返回 nil。返回的字典中key为被禁言用户Id，value为禁言到期时间，单位毫秒，-1 代表永久禁言。
 *
 *  \~english
 *  The list of muted members.
 *
 *  Only the chatroom owner can call the method. Returns nil if the user is not the chatroom owner.Return a key-value pairs, where the key is the user ID of the muted user and the value is the mute expiration timestamp in millisecond.Value == -1 means muted forever.
 */
@property (nonatomic, strong, readonly) NSDictionary<NSString *, NSNumber*> * _Nullable muteMembers;

/**
*  \~chinese
*  聊天室的白名单列表。
*
*  只有聊天室所有者有权限调用该方法，非聊天室所有者返回 nil。
*
*  \~english
*  The allowlist members <NSString>
*
*  Only the chatroom owner can call the method. Returns nil if the user is not the chatroom owner.
*/
@property (nonatomic, strong, readonly) NSArray<NSString *> * _Nullable whitelist;

/**
 *  \~chinese
 *  当前登录账号的聊天室成员类型。
 *
 *  \~english
 *  The chatroom membership type of the current login account.
 */
@property (nonatomic, readonly) EMChatroomPermissionType permissionType;

/**
 *  \~chinese
 *  聊天室的最大人数，需要先调用 getChatroomSpecificationFromServerWithId 方法获取该聊天室详情。如果没有获取聊天室详情将返回 0。
 *
 *  \~english
 *  The maximum member number of the chat room.
 */
@property (nonatomic, readonly) NSInteger maxOccupantsCount;

/**
 *  \~chinese
 *  聊天室的当前人数
 *  包括聊天室所有者、管理员与普通成员
 *  加入聊天室即可获取
 *  当聊天室有成员进出时，此属性会更新。
 *
 *  \~english
 *  The current number of members in the chat room.
 *  This includes the chat room owner, administrators, and regular members.
 *  You can get this information after joining the chat room.
 *  This property is updated when members join or leave the chat room.
 */
@property (nonatomic, readonly) NSInteger occupantsCount;

/**
 *  \~chinese
 *  聊天室成员是否全部被禁言,加入聊天室即可获取。
 *  加入聊天室后，收到一键禁言/取消禁言的回调时，该状态会更新。
 *
 *  \~english
 *  Checks whether all members are muted,This propery is available once join the chat room.
 *  After joining the chat room, when you receive a callback for muting or unmuting all members, this property will be updated.
 */
@property (nonatomic, readonly) BOOL isMuteAllMembers;

/**
 * \~chinese
 * 获取聊天室创建时间戳（毫秒）。
 * 只有加入聊天室后可获取。
 *
 * \~english
 * Gets the timestamp(ms) when the chat room was created.
 * This property is available once join the chat room.
 */
@property (nonatomic,readonly) NSInteger createTimestamp;

/**
 * \~chinese
 * 当前登录用户是否在白名单中。
 * 加入聊天室后可获取。
 * 当前用户被加入或者被移除白名单时，此属性会发生变化。
 * - `true`: 在白名单中。
 * - `false`: 不在白名单中。
 *
 * \~english
 * Current user is in allow list or not.
 * This property is available once join the chat room.
 * This property will be updated when current user is added or removed from the white list.
 * - `true`: In white list.
 * - `false`: Not in white list.
 */
@property (nonatomic,readonly) BOOL isInWhitelist;

/**
 * \~chinese
 * 获取当前被禁言截止时间戳（毫秒）。
 *
 * 加入聊天室后可获取。
 * 当前用户被禁言或者被解除禁言时，此属性会被更新。
 *
 * - 当取值为0，表示当前用户未被禁言。
 * - 当取值为-1，表示未能获取到用户被禁言时间戳。
 *
 * \~english
 * Gets the timestamp(ms) when Current user will be unmuted.
 *
 * This property is available once join the chat room.
 * This property will be updated when current use is muted or unmuted.
 *
 * - Current use is not muted if it is zero.
 * - Means cannot get MuteUntilTimeStamp correctly if it is be set with -1;
 */
@property (nonatomic,readonly) NSInteger muteExpireTimestamp;

/**
 *  \~chinese
 *  获取聊天室实例。
 *
 *  @param aChatroomId   聊天室 ID
 *
 *  @result 聊天室实例
 *
 *  \~english
 *  Constructs a chatroom instance with chatroom ID.
 *
 *  @param aChatroomId   The chatroom ID.
 *
 *  @result The chatroom instance.
 */
+ (instancetype _Nullable)chatroomWithId:(NSString * _Nonnull )aChatroomId;

/**
 *  \~chinese
 *  聊天室的被禁言列表。
 *
 *  只有聊天室所有者有权限调用该方法，非聊天室所有者返回 nil。
 *
 *  \~english
 *  The list of muted members.
 *
 *  Only the chatroom owner can call the method. Returns nil if the user is not the chatroom owner.
 */
@property (nonatomic, strong, readonly) NSArray<NSString *> * _Nullable muteList __deprecated_msg("Use muteMembers instead");

@end
