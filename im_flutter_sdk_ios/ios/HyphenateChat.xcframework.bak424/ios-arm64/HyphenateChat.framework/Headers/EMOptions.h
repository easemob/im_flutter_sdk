/**
 *  \~chinese
 *  @header EMOptions.h
 *  @abstract SDK的设置选项
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header EMOptions.h
 *  @abstract SDK options
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>

#import "EMCommonDefs.h"

/**
 *  \~chinese
 *  日志输出级别。
 *
 *  \~english
 *  The level of logs for output.
 */
typedef NS_ENUM(NSInteger, EMLogLevel)
{
    EMLogLevelDebug = 0, /** \~chinese 输出所有日志。 \~english All logs. */
    EMLogLevelWarning,   /** \~chinese 输出警告及错误。 \~english Warnings and errors. */
    EMLogLevelError      /** \~chinese 只输出错误。 \~english Errors only. */
} ;

typedef NS_ENUM(NSInteger, AreaCode)
{
    AreaCodeCN = 1 << 0,
    AreaCodeNA = 1 << 1,
    AreaCodeEU = 1 << 2,
    AreaCodeAS = 1 << 3,
    AreaCodeJP = 1 << 4,
    AreaCodeIN = 1 << 5,
    AreaCodeGLOB = -1
};

/**
 * \~chinese
 * SDK平台框架枚举。
 *
 * \~english
 * SDK platform framework enumeration.
 */
typedef NS_ENUM(NSUInteger, EMSDKPlatform) {
    /** \~chinese 原生平台。 \~english Native platform.*/
    EMSDKPlatformNative = 0,
    /** \~chinese Flutter。 \~english Flutter platform.*/
    EMSDKPlatformFlutter = 1,
    /** \~chinese React Native。 \~english React Native platform.*/
    EMSDKPlatformReactNative = 2,
    /** \~chinese Unity。 \~english Unity platform.*/
    EMSDKPlatformUnity = 3,
};

/**
 *  \~chinese
 *  SDK 的设置选项。
 *
 *  \~english
 *  The SDK options.
 */
@interface EMOptions : NSObject

/**
 *  \~chinese
 *  app key，是项目的唯一标识。
 *
 *  \~english
 *  The app key, which is the unique identifier of the project.
 */
@property(nonatomic, copy, readonly) NSString *appkey;

/**
 *  \~chinese
 *  appId，是项目的唯一标识。
 *
 *  \~english
 *  The appId, which is the unique identifier of the project.
 */
@property(nonatomic, copy, readonly) NSString *appId;

/**
 *  \~chinese
 *  控制台是否输出日志。
 *  - `YES`：是；
 *  - （默认）`NO`：否。
 *
 *  \~english
 *  Whether to print logs on the Console.
 *  - `YES`: Yes.
 *  - (Default) `NO`: No.
 */
@property(nonatomic, assign) BOOL enableConsoleLog;

/**
 *  \~chinese
 * 日志级别：
 * - (默认)`EMLogLevelDebug`：所有等级的日志；
 * - `EMLogLevelWarning`：警告及错误；
 * - `EMLogLevelError`：错误。
 *
 *  \~english
 *  The log level.
 *  - `EMLogLevelDebug`: All logs;
 *  - `EMLogLevelWarning`: Warnings and errors.
 *  - `EMLogLevelError`: Errors.
 */
@property(nonatomic, assign) EMLogLevel logLevel;

/**
 *  \~chinese
 *  是否只使用 HTTPS 协议。
 *  - `YES`：是：
 *  - （默认）`NO`：否。
 *
 *  \~english
 *  Whether to only use the HTTPS protocol.
 *  - `YES`: Yes.
 *  - (Default) `NO`: No.
 */
@property(nonatomic, assign) BOOL usingHttpsOnly;

/**
 *  \~chinese
 *  是否自动登录。
 *  - （默认）`YES`：是；
 *  - `NO`：否。
 *
 *  该参数需要在 SDK 初始化前设置，否则不生效。
 *
 *  \~english
 *  Whether to enable automatic login. The default value is `YES`.
 *  - (Default) `YES`: Yes.
 *  - `NO`: No.
 *
 *  You need to set this parameter before the SDK is initialized; otherwise, the setting does not take effect.
 */
@property(nonatomic, assign) BOOL isAutoLogin;

/**
 *  \~chinese
 *  离开群组时是否删除该群所有消息。
 *  - （默认）`YES`：是；
 *  - `NO`：否。
 *
 *  \~english
 *  Whether to delete all the group messages when leaving the group.
 *  - (Default) `YES`: Yes.
 *  - `NO`: No.
 */
@property(nonatomic, assign) BOOL deleteMessagesOnLeaveGroup;

/**
 *  \~chinese
 *  离开聊天室时是否删除所有消息。
 *  - （默认）`YES`：是；
 *  - `NO`：否。
 *
 *  \~english
 *  Whether to delete all the chat room messages when leaving the chat room.
 *  - (Default) `YES`: Yes.
 *  - `NO`: No.
 */
@property(nonatomic, assign) BOOL deleteMessagesOnLeaveChatroom;

/**
 *  \~chinese
 *  是否允许聊天室所有者离开。
 *  - （默认）`YES`：是；
 *  - `NO`：否。
 *
 *  \~english
 *  Whether to allow the chat room owner to leave the room.
 *  - (Default) `YES`: Yes.
 *  - `NO`: No.
 */
@property(nonatomic, assign) BOOL canChatroomOwnerLeave;

/**
 *  \~chinese
 *  是否自动接受群邀请。
 *  - （默认）`YES`：是；
 *  - `NO`：否。
 *
 *  \~english
 *  Whether to automatically accept group invitations.
 *  - (Default) `YES`: Yes.
 *  - `NO`: No.
 */
@property(nonatomic, assign) BOOL autoAcceptGroupInvitation;

/**
 *  \~chinese
 *  是否自动同意好友邀请。
 *  - （默认）`YES`：是；
 *  - `NO`：否。
 *
 *  \~english
 *  Whether to automatically accept friend requests.
 *  - (Default) `YES`: Yes.
 *  - `NO`: No.
 */
@property(nonatomic, assign) BOOL autoAcceptFriendInvitation;

/**
 *  \~chinese
 *  是否自动下载图片和视频的缩略图及语音消息。
 *  - （默认）`YES`：是；
 *  - `NO`：否。
 *
 *  \~english
 *  Whether to automatically download thumbnails of images and videos and voice messages.
 *  - (Default) `YES`: Yes.
 *  - `NO`: No.
 */
@property(nonatomic, assign) BOOL autoDownloadThumbnail;

/**
 * \~chinese
 * 是否需要接收已读回执。
 *  - （默认）`YES`：是；
 *  - `NO`：否。
 *
 * \~english
 * Whether to receive the message read receipt.
 *  - (Default) `YES`: Yes.
 *  - `NO`: No.
 */
@property(nonatomic, assign) BOOL enableRequireReadAck;
/**
 *  \~chinese
 *  是否发送消息送达回执：
 *  - `YES`：SDK 收到单聊消息时会自动发送送达回执；
 *  - （默认）`NO`：否。
 *  \~english
 *  Whether to send the message delivery receipt.
 *  - `YES`: Upon the reception of a one-to-one message, the SDK automatically sends a delivery receipt.
 *  - `NO`: No.
 *
 */
@property(nonatomic, assign) BOOL enableDeliveryAck;

/**
 *  \~chinese
 *  从数据库加载消息时是否按服务器时间排序。
 *  - （默认）`YES`：按服务器时间排序；
 *  - `NO`：否。
 *
 *  \~english
 *  Whether to sort messages by the server's reception time when loading messages from the database.
 *  - (Default) `YES`: Yes. Messages are sorted by the time when the server receives them.
 *  - `NO`: No.
 *
 */
@property(nonatomic, assign) BOOL sortMessageByServerTime;

/**
 *  \~chinese
 * 是否自动上传或者下载消息中的附件。
 *  - （默认）`YES`：是；
 *  - `NO`：否。
 *
 *  \~english
 *  Whether to automatically upload or download the attachment in the message.
 *  - (Default) `YES`: Yes.
 *  - `NO`: No.
 */
@property(nonatomic, assign) BOOL isAutoTransferMessageAttachments;

/**
 *  \~chinese
 *  iOS 特有属性，APNs 推送证书的名称。
 *
 *  该参数只能在调用 `initializeSDKWithOptions` 时设置，且 app 运行过程中不可以修改。
 *
 *  \~english
 *  The certificate name of Apple Push Notification Service (APNs).
 *
 *  This attribute is specific to APNs.
 *
 *  This attribute can be set only when you call `initializeSDKWithOptions`. The attribute setting cannot be changed during app runtime.
 */
@property(nonatomic, copy) NSString *apnsCertName;

/**
 *  \~chinese
 *  iOS 特有属性，PushKit 的证书名称。
 *
 *  该参数只能在调用 `initializeSDKWithOptions` 时设置，且 app 运行过程中不可以修改。
 *
 *  \~english
 *  The certificate name of Apple PushKit Service.
 *
 *  This attribute is specific to Apple PushKit Service.
 *
 *  This attribute can be set only when you call `initializeSDKWithOptions`. The attribute setting cannot be changed during app runtime.
 */
@property(nonatomic, copy) NSString *pushKitCertName;

/**
 *  \~chinese
 *  区域代号。
 *
 * 该属性用于限制连接边缘节点的范围，默认为 `AreaCodeGLOB`。
 *
 *  该参数只能在调用 `initializeSDKWithOptions` 时设置，且 app 运行过程中不能修改。
 *
 *  \~english
 *  The area code.

 *  This attribute is used to restrict the scope of accessible edge nodes. The default value is `AreaCodeGLOB`.
 *
 *  This attribute can be set only when you call `initializeSDKWithOptions`. The attribute setting cannot be changed during the app runtime.
 */
@property(nonatomic) AreaCode area;

/**
 *  \~chinese
 *  是否开启消息流量统计。
*   - `YES`：开启；
 *  - （默认）`NO`: 关闭。
 *
 *  该参数只能在调用 `initializeSDKWithOptions` 时设置，且 app 运行过程中不能修改。
 *
 *  \~english
 *  Whether to enable message statistics.
 *  - `YES`: Yes.
 *  - (Default) `NO`: No.
 *
 *  This attribute can be set only when you call `initializeSDKWithOptions`. The attribute setting cannot be changed during the app runtime.
 */
@property(nonatomic) BOOL enableStatistics;

/**
 *  \~chinese
 *  加载会话时是否包括空会话。
 *
 *  - YES：包含。
 * - （默认）NO：不包含。
 *
 *  该属性只能在调用 `initializeSDKWithOptions` 时设置，而且 app 运行过程中不能修改该参数的设置。
 *
 *  \~english
 *  Whether to include empty conversations when the SDK loads conversations
 *  - `YES`: Empty conversations are included.
 * - (Default) `NO`: Empty conversations are excluded.
 *
 *  This attribute can be set only when you call the `initializeSDKWithOptions` method. The attribute setting cannot be changed during app runtime.
 */
@property(nonatomic) BOOL loadEmptyConversations;

/**
 *  \~chinese
 *  自定义系统类型。
 *
 *  该属性只能在调用 `initializeSDKWithOptions` 时设置，而且 app 运行过程中不能修改该参数的设置。
 *
 *  \~english
 *  The custom system type.
 *
 *  This attribute can be set only when you call the `initializeSDKWithOptions` method. The attribute setting cannot be changed during app runtime.
 */
@property(nonatomic) NSInteger customOSType;

/**
 *  \~chinese
 *  自定义设备名称。
 *
 *  该属性只能在调用 `initializeSDKWithOptions` 时设置，而且 app 运行过程中不能修改该参数的设置。
 *
 *  \~english
 *  The custom device name.
 *
 *  This attribute can be set only when you call the `initializeSDKWithOptions` method. The attribute setting cannot be changed during the app runtime.
 */
@property(strong) NSString* customDeviceName;

/**
 *  \~chinese
 *  当发送的文本消息的内容被文本审核（Moderation）服务替换时，是否需要返回给发送方。
 *  - YES：将内容替换后的消息返回给发送方。
 *  - （默认）NO：将原消息返回给发送方。
 *
 *  该属性只能在调用 `initializeSDKWithOptions` 时设置，而且 app 运行过程中不能修改该参数的设置。
 *
 *  \~english
 *
 *  Whether the server returns the sender the text message with the content replaced during text moderation:
 *
 *  - YES：Return the adjusted message to the sender.
 *  - (Default) NO：Return the original message to the sender.
 *
 *  This attribute can be set only with the `initializeSDKWithOptions` method. The attribute setting cannot be changed during the app runtime.
 */
@property(nonatomic) BOOL useReplacedMessageContents;

/**
 *  \~chinese
 *
 *  发送成功的消息是否在 `ChatManagerDelegate#messagesDidReceive` 中回调。
 *  - YES：是。
 *  - （默认）NO：否。
 *
 *  \~english
 *
 *  Whether the sent message is included in `ChatManagerDelegate#messagesDidReceive`.
 *  - YES：Yes. Besides the received message, the sent message is also included in `ChatManagerDelegate#messagesDidReceive`.
 *  - (Default) NO：No. Only the received message is included in `ChatManagerDelegate#messagesDidReceive`.
 *
 */
@property(nonatomic) BOOL includeSendMessageInMessageListener;

/**
 *  \~chinese
 *
 *  是否使用Chat 的用户信息服务，如果开启，登录时SDK会从服务器自动同步用户属性，发送消息时，会携带相关用户信息，包括头像/昵称/群名片，用户需要主动设置自己的用户属性和群昵称。
 *  - YES：开启。
 *  - （默认）NO：不开启。
 *
 *  \~english
 *
 *  Whether to enable the user info service of Chat. If enabled, the SDK automatically synchronizes user info from the server during login. When sending a message, the SDK includes the relevant user information, such as avatar, nickname, and group card. Users need to actively set their user attributes and group nicknames.
 *  - YES: Enable.
 *  - (Default) NO: Disable.
 *
 */
@property(nonatomic) BOOL enableUserInfo;

/**
 *  \~chinese
 *
 *  是否将服务器导入的消息设置为已读：
 *  - YES：已读。会话的未读消息数 `EMConversation#unreadMessagesCount` 不发生变化。
 *  - （默认）NO：未读。`EMConversation#unreadMessagesCount` 的数量会增加。
 *
 *  \~english
 *
 *  Whether to set messages from the server side as read:
 *  - YES：Read. After the messages are imported, the number of unread messages specified with `EMConversation#unreadMessagesCount` remains unchanged.
 *  - (Default) NO：Unread. After the messages are imported, the value of `EMConversation#unreadMessagesCount` is increased.
 */
@property(nonatomic) BOOL regardImportMessagesAsRead;

/**
 *  \~chinese
 *
 *  是否自动加载会话列表：
 *  - YES：自动加载。
 *  - （默认）YES：自动加载。
 *
 *  \~english
 *
 *  Whether to automatically load the conversation list:
 *  - YES：Automatically load.
 *  - (Default) YES：Automatically load.
 */
@property(nonatomic) BOOL autoLoadConversations;

/**
 *  \~chinese
 *  登录时携带的扩展信息，可以是JSON 字符串，目前字符串长度 底层限制长度1024

 *
 *  \~english
 *  The extended information carried during login can be a JSON string. The current string length is limited to 1024 characters.
 */
@property (nonatomic) NSString * loginExtensionInfo;

/**
 *  \~chinese
 *  SDK 的工作路径是否可备份。
 *  - YES：可拷贝。
 *  - （默认）NO：不可拷贝。

 *
 *  \~english
 *  Whether the SDK work path is copiable.
 *  - YES：Copiable.
 *  - （Default）NO：Uncopiable.
 */
@property (nonatomic) BOOL workPathCopiable;

/**
 *  \~chinese
 *  UIKit 版本号。
 *  - （默认）不设置。
 *
 *  \~english
 *  The UIKit version.
 *  - (Default) Not set.
 */
@property (nonatomic, copy) NSString* uiKitVersion;

/**
 *  \~chinese
 *  SDK 平台。
 *  - （默认）`EMSDKPlatformNative`：原生平台；
 *
 *  \~english
 *  The SDK platform.
 *  - (Default) `EMSDKPlatformNative`: Native platform;
 */
@property (nonatomic) EMSDKPlatform platform;

/**
 *  \~chinese
 *  doh 类型。
 *  - （默认） 国内（1），海外（2）；
 *  - 0.禁用 1.国内 2.海外
 *
 *  \~english
 *  doh type..
 *  - (default)  china (1),  global (2);
 *  - 0.disable 1.china 2.global
 */
@property (nonatomic) NSInteger dohVendor;
/**
 * \~chinese
 * 登录时是否同步好友列表.默认值为`NO`
 *
 * \~english
 * Whether to synchronize the friend list during login.Defaults to `NO`
 */
@property (nonatomic) BOOL enableAutoSyncContacts;

/**
 *  \~chinese
 *  自定义 NTP 服务器地址列表。格式为 "host" 或 "host:port"，默认端口为 123。
 *  服务器需符合 NTPv4 协议（RFC 5905）。
 *
 *  该属性只能在调用 `initializeSDKWithOptions` 时设置，且 app 运行过程中不能修改。
 *
 *  \~english
 *  The custom NTP server address list. Format: "host" or "host:port", default port is 123.
 *  Servers must be NTPv4-compliant (RFC 5905).
 *
 *  This attribute can be set only when you call `initializeSDKWithOptions`.
 *  The attribute setting cannot be changed during app runtime.
 */
@property (nonatomic, copy) NSArray<NSString *> *ntpServers;

/**
 *  \~chinese
 *  获取 SDK 选项实例。
 *
 *  @param aAppkey  App key。
 *
 *  @result SDK 设置项实例。
 *
 *  \~english
 *  Gets an SDK options instance.
 *
 *  @param aAppkey  The App Key.
 *
 *  @result  The SDK options instance.
 */
+ (instancetype _Nonnull)optionsWithAppkey:(NSString * _Nonnull)aAppkey;

/**
 *  \~chinese
 *  获取 SDK 选项实例。
 *
 *  @param appId  App Id。
 *
 *  @result SDK 设置项实例。
 *
 *  \~english
 *  Gets an SDK options instance.
 *
 *  @param appId  The App Id.
 *
 *  @result  The SDK options instance.
 */
+ (instancetype _Nonnull)optionsWithAppId:(NSString* _Nonnull)appId;
@end
