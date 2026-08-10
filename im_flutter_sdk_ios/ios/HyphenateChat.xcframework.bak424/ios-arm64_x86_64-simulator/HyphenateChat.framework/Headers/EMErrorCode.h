/**
 *  \~chinese
 *  @header EMErrorCode.h
 *  @abstract SDK定义的错误码。
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header EMErrorCode.h
 *  @abstract The SDK defined error type.
 *  @author Hyphenate
 *  @version 3.00
 */

#ifndef EMErrorCode_h
#define EMErrorCode_h

typedef NS_ENUM(NSInteger, EMErrorCode) {
    
    EMErrorNoError = 0,                      /** \~chinese 没有错误。 \~english no error */

    EMErrorGeneral = 1,                      /** \~chinese 默认未区分类型的错误。 \~english A general error. */
    EMErrorNetworkUnavailable,               /** \~chinese 网络错误。 \~english The network is unavailable. */
    EMErrorDatabaseOperationFailed,          /** \~chinese 数据库操作失败。 \~english The database operation fails. */
    EMErrorExceedServiceLimit,               /** \~chinese 超过服务限制。 \~english You have exceeded the service limit. */
    EMErrorServiceArrearages,                /** \~chinese 余额不足。该错误码已废弃。 \~english This error code is deprecated. Your account balance is insufficient.*/
    EMErrorPushReportActionFailed,            /** \~chinese 推送报错 \~english The push failed.*/
    EMErrorPartialSuccess,                    /** \~chinese 操作部分成功 \~english The operation succeeds partially.*/
    EMErrorAppActiveNumbersReachLimitation,       /** \~chinese 应用程序的日活跃用户数量（DAU）或月活跃用户数量（MAU）达到上限。\~english The number of daily active users (DAU) or monthly active users (MAU) for the app has reached the upper limit .*/
    
    EMErrorInvalidAppkey = 100,              /** \~chinese 不合法的 App Key。 \~english The App key is invalid. */
    EMErrorInvalidUsername,                  /** \~chinese 用户 ID 不正确。 \~english The user ID is invalid. */
    EMErrorInvalidPassword,                  /** \~chinese 用户密码不正确。 \~english The password is invalid. */
    EMErrorInvalidURL,                       /** \~chinese URL 无效。 \~english The URL is invalid. */
    EMErrorInvalidToken,                     /** \~chinese Token 不正确。 \~english The token is invalid. */
    EMErrorUsernameTooLong,                  /** \~chinese 用户名过长。 \~english The username is too long. */
    EMErrorChannelSyncNotOpen,               /** \~chinese 会话同步未启用。 \~english The channel message synchronization is not enabled. */
    EMErrorInvalidConversation,              /** \~chinese 不正确的会话。 \~english Invalid conversation. */
    EMErrorTokenExpire,                      /** \~chinese Token 过期。 \~english The token has expired. */
    EMErrorTokeWillExpire,                   /** \~chinese Token 即将过期。 \~english The token will expire. */
    
    EMErrorInvalidParam = 110,               /** \~chinese 参数无效。 \~english Parameters are invalid. */
    EMErrorOperationUnsupported,             /** \~chinese 不支持的操作。 \~english The operation is not supported. */
    EMErrorQueryParamReachesLimit,           /** \~chinese 查询参数达到限制。 \~english Query parameters have reached the limit. */
    
    EMErrorUserAlreadyLoginSame = 200,       /** \~chinese 当前用户已登录。 \~english The user is already logged in. */
    EMErrorUserNotLogin,                     /** \~chinese 用户未登录。 \~english The user is not logged in. */
    EMErrorUserAuthenticationFailed,         /** \~chinese 用户鉴权失败。 \~english The user authentication fails. */
    EMErrorUserAlreadyExist,                 /** \~chinese 用户已存在。 \~english The user already exists. */
    EMErrorUserNotFound,                     /** \~chinese 用户不存在。 \~english The user is not found. */
    EMErrorUserIllegalArgument,              /** \~chinese 用户参数不正确。 \~english Invalid argument. */
    EMErrorUserLoginOnAnotherDevice,         /** \~chinese 当前用户在其他设备登录。 \~english The user has logged in from another device. */
    EMErrorUserRemoved,                      /** \~chinese 当前用户从服务器端被删掉。 \~english The user was removed from the server. */
    EMErrorUserRegisterFailed,               /** \~chinese 用户注册失败。 \~english User registration fails. */
    EMErrorUpdateApnsConfigsFailed,          /** \~chinese 更新推送设置失败。 \~english Fails to configure the Apple push notification.*/
    EMErrorUserPermissionDenied,             /** \~chinese 用户无权限。 \~english The user has no operation permission. */
    EMErrorUserBindDeviceTokenFailed,        /** \~chinese 绑定 device token 失败。  \~english Fails to bind the device token. */
    EMErrorUserUnbindDeviceTokenFailed,      /** \~chinese 解除 device token 失败。 \~english Fails to unbind the user with the device token. */
    EMErrorUserBindAnotherDevice,            /** \~chinese 用户已与其他设备绑定，无法自动登录。 \~english The user is bound to another device and automatic login is not allowed.*/
    EMErrorUserLoginTooManyDevices,          /** \~chinese 用户登录设备数超过限制。默认可以登录 4 个设备，有特殊需求可以联系商务 sales@agora.io。 \~english The user is logged on too many devices. By default, a user can log in to at most four devices with the same account. To increase this number or disable multi-device login, contact sales@agora.io. */
    EMErrorUserMuted,                        /** \~chinese 用户在群组或聊天室中被禁言。 \~english The user is muted in the chat group or chat room. */
    EMErrorUserKickedByChangePassword,       /** \~chinese 用户密码更新。 \~english The user has changed the password. */
    EMErrorUserKickedByOtherDevice,          /** \~chinese 用户被踢下线。 \~english The user is kicked off from another device. */
    EMErrorUserAlreadyLoginAnother,          /** \~chinese 其他用户已登录。 \~english Another user is already logged in. */
    EMErrorUserMutedByAdmin,                 /** \~chinese 当前用户被管理员禁言。 \~english The user is muted by the admin. */
    EMErrorUserDeviceChanged,                /** \~chinese 用户设备与上次登录不同，需要重新登录。注意： 默认会允许用户登录，踢掉另一个设备上的登录，此error在打开不踢掉另外设备上的登录开关后才会生效 \~english User device different with last login, need login again */
    EMErrorUserNotOnRoster,                  /** \~chinese 此用户不是你的好友，不能发送消息 \~english The user is not your friend and therefore cannot send messages. */

    EMErrorServerNotReachable = 300,         /** \~chinese 请求服务失败。 \~english The server is not reachable. */
    EMErrorServerTimeout,                    /** \~chinese 请求服务超时。 \~english The server response times out. */
    EMErrorServerBusy,                       /** \~chinese 服务器忙碌。 \~english The server is busy. */
    EMErrorServerUnknownError,               /** \~chinese 服务请求的通用错误码。 \~english An unknown server error occurs. */
    EMErrorServerGetDNSConfigFailed,         /** \~chinese 获取服务器配置信息错误。 \~english Fails to retrieve the DNS configurations. */
    EMErrorServerServingForbidden,           /** \~chinese 当前 app 被禁用。 \~english The service is forbidden. */
    EMErrorServerDecryptionFailed,           /** \~chinese 服务器解密失败。 \~english Server transfer decryption failure. */
    EMErrorServerGetRTCConfigFailed,        /** \~chinese 获取rtc配置失败。 \~english Cannot get the RTC configuration. */
    EMErrorServerNoMatchURL, /** \~chinese 与服务端url不匹配。 \~english Url doesn't matched with server */
    
    /** \~chinese 连接服务器超时。 \~english The connection to the server times out. */
    EMErrorConnectionTimeout = 350,
    /** \~chinese 连接服务器发生 DNS 错误。 \~english A DNS error occurs when connecting to the server. */
    EMErrorConnectionDNSError,
    /** \~chinese 连接服务器发生IO错误。 \~english An I/O error occurs when connecting to the server. */
    EMErrorConnectionIOError,
    /** \~chinese 连接服务器时流被关闭。 \~english The stream is closed when connecting to the server. */
    EMErrorConnectionStreamClosed,
    /** \~chinese 连接服务器时认证超时。 \~english Authentication times out when connecting to the server. */
    EMErrorConnectionProvisionTimeout,
    
    
    EMErrorFileNotFound = 400,               /** \~chinese 文件未找到。 \~english Cannot find the file. */
    EMErrorFileInvalid,                      /** \~chinese 文件异常。 \~english The file is invalid. */
    EMErrorFileUploadFailed,                 /** \~chinese 上传文件错误。 \~english Fails to upload the file. */
    EMErrorFileDownloadFailed,               /** \~chinese 下载文件错误。 \~english Fails to download the file. */
    EMErrorFileDeleteFailed,                 /** \~chinese 删除文件错误。 \~english Fails to delete the file. */
    EMErrorFileTooLarge,                     /** \~chinese 文件太大。 \~english The file is too large. */
    EMErrorFileContentImproper,              /** \~chinese 文件内容不合规。 \~english The file contains improper content. */
    EMErrorFileExpired,                      /** \~chinese 文件已过期。 \~english The file is expired. */
    EMErrorFileDurationTooLong,             /** \~chinese 待转换为文字的语音文件时长超出限制（60s）。 \~english "The duration of the voice file to be transcribed to text exceeds the limit (60s). */
    EMErrorFileVoiceToTextFailed,           /** \~chinese 语音文件转文字失败。 \~english Fails to transcribe the voice file to text. */
    
    
    EMErrorMessageInvalid = 500,             /** \~chinese 消息异常错误。 \~english The message is invalid. */
    EMErrorMessageIncludeIllegalContent,     /** \~chinese 消息含有非法内容。 \~english The message contains invalid content. */
    EMErrorMessageTrafficLimit,              /** \~chinese 消息限流。 \~english Message sending has exceeded the traffic limit. */
    EMErrorMessageEncryption,                /** \~chinese 消息加密错误。 \~english An error occurs with message encryption. */
    EMErrorMessageRecallTimeLimit,           /** \~chinese 消息撤回超时错误。 \~english Message recall has exceeded the time limit. */
    EMErrorServiceNotEnable,                 /** \~chinese 服务未开通。 \~english The service is not enabled. */
    EMErrorMessageExpired,                   /** \~chinese 消息过期。 \~english  The message has expired. */
    EMErrorMessageIllegalWhiteList,          /** \~chinese 用户未在白名单中无法发送。 \~english  The message fails to be delivered because the user is not in the whitelist.*/
    EMErrorMessageExternalLogicBlocked,      /** \~chinese 消息被外部逻辑拦截，无法发送。 \~english  The message is blocked by the external logic. */
    EMErrorMessageCurrentLimiting,           /** \~chinese 消息被限流，发送失败。 \~english  The message sending failure by the current limiting. */
    EMErrorMessageSizeLimit,                 /** \~chinese 消息体太大，发送失败。 \~english  The message sending failure because the body is too large. */
    EMErrorEditFailed,                      /** \~chinese 编辑消息失败。 \~english  The message edit failed. */
    EMErrorStreamIntervalTimeout,    /** \~chinese 流式消息分片发送超时。 \~english The chunk of stream message sending interval timeout.*/
    EMErrorMessageStreamTimeout,    /** \~chinese 流式消息发送超时。 \~english The  stream message sending timeout.*/
    
    EMErrorGroupInvalidId = 600,             /** \~chinese 群组 ID 异常。 \~english The group ID is invalid. */
    EMErrorGroupAlreadyJoined,               /** \~chinese 用户已加入该群组。 \~english The user is already in the group. */
    EMErrorGroupNotJoined,                   /** \~chinese 用户未加入该群组。 \~english The user has not joined the group. */
    EMErrorGroupPermissionDenied,            /** \~chinese 无权限的群组操作。 \~english The user does not have permission to access the operation. */
    EMErrorGroupMembersFull,                 /** \~chinese 群组已满。 \~english The group has reached the maximum member capacity.*/
    EMErrorGroupSharedFileInvalidId,         /** \~chinese 共享文件 ID 无效。 \~english The shared file ID is invalid. */
    EMErrorGroupNotExist,                    /** \~chinese 群组不存在。 \~english The group does not exist. */
    EMErrorGroupDisabled,                    /** \~chinese 群组被禁用。 \~english The group is disabled. */
    EMErrorGroupNameViolation,               /** \~chinese 群组名称违规。 \~english The group name is invalid. */
    EMErrorGroupMemberAttributesReachLimit,  /** \~chinese 群组成员自定义属性个数到达上限。 \~english You have reached the maximum number of custom attributes for a group member.  */
    EMErrorGroupMemberAttributesUpdateFailed,/** \~chinese 设置群成员自定义属性失败。 \~english Fails to set the custom attribute(s) of the group member. */

    EMErrorGroupMemberAttributesKeyReachLimit,/** \~chinese 设置的群成员自定义属性 key 长度（不能超过 16 字节）超限。 \~english The key of a custom attribute(s) of the group member has exceeded the maximum allowed length of 16 bytes. */
    
    EMErrorGroupMemberAttributesValueReachLimit,/** \~chinese 设置群成员自定义属性 value 长度（不能超过 512 字节）超限。 \~english The value of a custom attribute(s) of the group member has exceeded the maximum allowed length of 512 bytes. */
    EMErrorGroupUserInBlockList,             /** \~chinese 用户在群组黑名单中。 \~english The userId  is in group block list. */
    
    EMErrorChatroomInvalidId = 700,          /** \~chinese 聊天室 ID 异常。 \~english The chatroom ID is invalid.*/
    EMErrorChatroomAlreadyJoined,            /** \~chinese 用户已在该聊天室中。 \~english The user is already in the chatroom. */
    EMErrorChatroomNotJoined,                /** \~chinese 未加入该聊天室。 \~english The user has not joined the chatroom. */
    EMErrorChatroomPermissionDenied,         /** \~chinese 无权限的聊天室操作。 \~english The user does not have operation permission. */
    EMErrorChatroomMembersFull,              /** \~chinese 聊天室已满。 \~english The chatroom has reached the maximum member capacity. */
    EMErrorChatroomNotExist,                 /** \~chinese 聊天室不存在。 \~english The chatroom does not exist. */
    EMErrorChatroomOwnerNotAllowLeave,       /** \~chinese 聊天室owner不允许离开。 \~english The owner of the chat room is not allowed to leave. */
    EMErrorChatroomUserInBlockList,          /** \~chinese 用户在聊天室黑名单中。 \~english The userId  is in chatroom block list. */
    
    
    EMErrorUserCountExceed = 900,            /** \~chinese 获取用户属性的用户个数超过 100 个。 \~english The count of users to get userinfo more than 100 */
    EMErrorUserInfoDataLengthExceed = 901,   /** \~chinese 设置的用户属性长度太长。 \~english The count of The datalength of userinfo to set is too long */

    
    EMErrorContactAddFaild = 1000,           /** \~chinese 添加联系人失败 \~english Fails to add the contact. */
    EMErrorContactReachLimit = 1001,    /** \~chinese 邀请者好友数量已经达到上限 \~english The number of inviter's friends has reached the maximum */
    EMErrorContactReachLimitPeer = 1002,    /** \~chinese 被邀请者好友数量已经达到上限 \~english The number of invitee's friends has reached the maximum */

    EMErrorPresenceParamExceed = 1100, /** \~chinese Presence 参数超限 \~english The value of a presence parameter has reached the upper limit. */
    EMErrorPresenceCannotSubscribeSelf = 1101, /** \~chinese Presence 不能订阅自己 \~english You cannot subscribe to the presence state of yourself. */
    
    EMErrorTranslateParamError = 1110, /** \~chinese 翻译参数错误 \~english translation parameter error */
    EMErrorTranslateServiceNotEnabled = 1111,/** \~chinese 翻译服务不可用 \~english Translation service unavailable */
    EMErrorTranslateUsageLimit = 1112, /** \~chinese 翻译功能受限 \~english Translation is limited */
    EMErrorTranslateServiceFail = 1113,/** \~chinese 翻译失败\~english Translation failed */
    
    EMErrorModerationFailed = 1200,           /** \~chinese 第三方内容审核失败。 \~english The service is forbidden. */
    EMErrorThirdServiceFailed = 1299,                /** \~chinese 第三方服务默认失败。 \~english The service is forbidden. */
    
    EMErrorReactionReachLimit = 1300,   /** \~chinese Reaction 数量达到上限 \~english The number of Reactions has reached the maximum. */
    EMErrorReactionHasBeenOperated = 1301,  /** \~chinese Reaction 重复添加 \~english The Reaction already exists. */
    EMErrorReactionOperationIsIllegal = 1302,   /** \~chinese Reaction 操作非法 \~english Illegal Reaction operation. */
    EMErrorThreadNotExist = 1400,/** \~chinese 子区不存在 \~english The message thread does not exist. */
    EMErrorThreadAlreadyExist = 1401, /** \~chinese 子区已存在 \~english The message thread already exists. */
    EMErrorThreadCreateMessageIllegal = 1402,/** \~chinese 创建子区的消息不合法 \~english The parent message for thread creation is invalid. */
    
    EMErrorNotSupportPush,          /** \~chinese 当前设备SDK不支持push  \~english SDK  The current device doesn't support the push function.*/
    EMErrorPushBindFailed = 1501,/** \~chinese push功能绑定账号失败 \~english Failed to bind the account with the push function. */
    EMErrorPushUnBindFailed = 1502,/** \~chinese push功能解除绑定账号失败 \~english The push function failed to unbind the account. */
};

#endif
