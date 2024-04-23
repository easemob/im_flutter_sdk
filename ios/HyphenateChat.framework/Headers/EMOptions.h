/**
 *  \~chinese
 *  @header EMOptions.h
 *  @abstract SDK的设置选项
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header EMOptions.h
 *  @abstract SDK setting options
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
 *  Log output level types.
 */
typedef NS_ENUM(NSInteger, EMLogLevel)
{
    EMLogLevelDebug = 0, /** \~chinese 输出所有日志。 \~english Output all logs. */
    EMLogLevelWarning,   /** \~chinese 输出警告及错误。 \~english Output warnings and errors. */
    EMLogLevelError      /** \~chinese 只输出错误。 \~english Output errors only. */
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
 *  \~chinese
 *  SDK 的设置选项。
 *
 *  \~english
 *  The SDK setting options.
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
 *  控制台是否输出日志。默认值为 `NO`。
 *
 *  \~english
 *  Whether to print logs on Console. The default value is `NO`.
 */
@property(nonatomic, assign) BOOL enableConsoleLog;

/**
 *  \~chinese
 *  默认值为 `EMLogLevelDebug`，表示所有等级的日志。
 *
 *  \~english
 *  The log output level. The default value is EMLogLevelDebug, which means all log levels.
 */
@property(nonatomic, assign) EMLogLevel logLevel;

/**
 *  \~chinese
 *  是否只使用 HTTPS 协议。默认值为 `NO`。
 *
 *  \~english
 *  Whether to only use the HTTPS protocol. The default value is `NO`.
 */
@property(nonatomic, assign) BOOL usingHttpsOnly;

/**
 *  \~chinese
 *  是否自动登录，默认为 `YES`。
 *
 *  该参数需要在 SDK 初始化前设置，否则不生效。
 *
 *  \~english
 *  Whether to enable automatic login. The default value is `YES`.
 *
 *  You need to set this parameter before the SDK is initialized.
 */
@property(nonatomic, assign) BOOL isAutoLogin;

/**
 *  \~chinese
 *  离开群组时是否删除该群所有消息，默认为 `YES`。
 *
 *  \~english
 *  Whether to delete all the group messages when leaving the group. The default value is YES.
 */
@property(nonatomic, assign) BOOL deleteMessagesOnLeaveGroup;

/**
 *  \~chinese
 *  离开聊天室时是否删除所有消息，默认为 `YES`。
 *
 *  \~english
 *  Whether to delete all the chat room messages when leaving the chat room. The default value is YES.
 */
@property(nonatomic, assign) BOOL deleteMessagesOnLeaveChatroom;

/**
 *  \~chinese
 *  是否允许聊天室所有者离开，默认为 `YES`。
 *
 *  \~english
 *  Whether to allow the chatroom owner leave the room. The default value is YES.
 */
@property(nonatomic, assign) BOOL canChatroomOwnerLeave;

/**
 *  \~chinese
 *  是否自动接受群邀请。默认值为 `YES`。
 *
 *  \~english
 *  Whether to automatically accept group invitation. The default value is `YES`.
 */
@property(nonatomic, assign) BOOL autoAcceptGroupInvitation;

/**
 *  \~chinese
 *  是否自动同意好友邀请。默认值为 `NO`。
 *
 *  \~english
 *  Whether to automatically approve contact request. The default value is `NO`.
 */
@property(nonatomic, assign) BOOL autoAcceptFriendInvitation;

/**
 *  \~chinese
 *  是否自动下载图片和视频缩略图及语音消息，默认为 `YES`。
 *
 *  \~english
 *  Whether to automatically download image or video thumbnails and voice messages. The default value is `YES`.
 */
@property(nonatomic, assign) BOOL autoDownloadThumbnail;

/**
 * \~chinese
 * 是否需要接收信息接收方已读回执。默认值为 `YES`。
 *
 * \~english
 * Whether need to receive the message read receipt. The default value is `YES`.
 */
@property(nonatomic, assign) BOOL enableRequireReadAck;
/**
 *  \~chinese
 *  是否发送消息送达回执，默认为 `NO`，如果设置为 `YES`，SDK 收到单聊消息时会自动发送送达回执。
 *
 *  \~english
 *  Whether to send the message delivery receipt. The default value is `NO`. If you set it to `YES`, the SDK automatically send a delivery receipt when you receive a chat message.
 */
@property(nonatomic, assign) BOOL enableDeliveryAck;

/**
 *  \~chinese
 *  从数据库加载消息时是否按服务器时间排序，默认值为 `YES`，表示按按服务器时间排序。
 *
 *  \~english
 *  Whether to sort messages by server received time when loading message from database. The default value is `YES`.
 */
@property(nonatomic, assign) BOOL sortMessageByServerTime;

/**
 *  \~chinese
 * 是否自动上传或者下载消息中的附件，默认值为 `YES`。
 *
 *  \~english
 *  Whether to automatically upload or download the attachment in the message. The default value is `YES`.
 */
@property(nonatomic, assign) BOOL isAutoTransferMessageAttachments;

/**
 *  \~chinese
 * 是否打开FPA加速功能，默认关闭
 *
 *  \~english
 *  Whether to enable fpa feature. The default value is `NO`.
 */
@property(nonatomic, assign) BOOL enableFpa;

/**
 *  \~chinese
 *  iOS 特有属性，推送证书的名称。
 *
 *  消息推送的证书名称。该参数只能在调用 `initializeSDKWithOptions` 时设置，且 app 运行过程中不可以修改。
 *
 *  \~english
 *  The certificate name of Apple Push Notification Service.
 *
 *  Ensure that you set this parameter when calling `initializeSDKWithOptions`. During the app runtime, you can not change the settings.
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
 *  Ensure that you set this parameter when calling `initializeSDKWithOptions`. During the app runtime, you can not change the settings.
 */
@property(nonatomic, copy) NSString *pushKitCertName;

/**
 *  \~chinese
 *  区域代号。
 *
 * 该属性用于限制连接边缘节点的范围，默认为 AreaCodeGLOB。
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
 *  是否开启消息流量统计，默认不开启。
 *
 *  该参数只能在调用 `initializeSDKWithOptions` 时设置，且 app 运行过程中不能修改。
 *
 *  \~english
 *  Whether to enable message statistics. The default value is `NO`.
 *
 *  This attribute can be set only when you call `initializeSDKWithOptions`. The attribute setting cannot be changed during the app runtime.
 */
@property(nonatomic) BOOL enableStatistics;

/**
 *  \~chinese
 *  获取实例。
 *
 *  @param aAppkey  app key。
 *
 *  @result SDK 设置项实例。
 *
 *  \~english
 *  Gets a SDK setting options instance.
 *
 *  @param aAppkey  The app key.
 *
 *  @result  The SDK setting options instance.
 */
+ (instancetype _Nonnull)optionsWithAppkey:(NSString * _Nonnull)aAppkey;

#pragma mark - EM_DEPRECATED_IOS 3.8.8
/**
 *  \~chinese
 *  离开群组时是否删除该群所有消息, 默认为 YES。
 *
 *  \~english
 *  Whether to delete all the group messages when leaving the group. The default value is YES.
 */
@property(nonatomic, assign) BOOL isDeleteMessagesWhenExitGroup __deprecated_msg("Use deleteMessagesOnLeaveGroup instead");

/**
 *  \~chinese
 *  离开聊天室时是否删除所有消息, 默认为 YES。
 *
 *  \~english
 *  Whether to delete all the chat room messages when leaving the chat room. The default value is YES.
 */
@property(nonatomic, assign) BOOL isDeleteMessagesWhenExitChatRoom
    __deprecated_msg("Use deleteMessagesOnLeaveChatroom instead");

/**
 *  \~chinese
 *  是否允许聊天室所有者离开, 默认为 YES。
 *
 *  \~english
 *  if allow chat room's owner can leave the chat room. The default value is YES.
 */
@property(nonatomic, assign) BOOL isChatroomOwnerLeaveAllowed
    __deprecated_msg("Use canChatroomOwnerLeave instead");

/**
 *  \~chinese
 *  用户自动同意群邀请, 默认为 YES。
 *
 *  \~english
 *  Whether to automatically accept group invitation. The default value is YES.
 */
@property(nonatomic, assign) BOOL isAutoAcceptGroupInvitation
    __deprecated_msg("Use autoAcceptGroupInvitation instead");

/**
 *  \~chinese
 *  自动同意好友申请, 默认为 NO。
 *
 *  \~english
 *  Whether to automatically approve friend request. The default value is NO.
 */
@property(nonatomic, assign) BOOL isAutoAcceptFriendInvitation
    __deprecated_msg("Use autoAcceptFriendInvitation instead");

/**
 *  \~chinese
 *  是否自动下载图片和视频缩略图及语音消息, 默认为 YES。
 *
 *  \~english
 *  Whether to automatically download thumbnail of image&video and audio. The default value is YES.
 */
@property(nonatomic, assign) BOOL isAutoDownloadThumbnail
    __deprecated_msg("Use autoDownloadThumbnail instead");

@end
