import '../internal/inner_headers.dart';

/// ~english
/// The EMOptions class, which contains the settings of the Chat SDK.
///
/// For example, whether to encrypt the messages before sending and whether to automatically accept the friend invitations.
/// ~end
///
/// ~chinese
/// 提供 SDK 聊天相关的设置。
/// 用户可以用来配置 SDK 的各种参数、选项，
/// 比如，发送消息加密，是否自动接受加好友邀请。
/// ~end
class EMOptions {
  /// ~english
  /// The app key that you get from the console when creating the app.
  /// ~end
  ///
  /// ~chinese
  /// 创建 app 时在 console 后台上注册的 app 唯一识别符。
  /// ~end
  final String? appKey;

  /// ~english
  /// The app key that you get from the console when creating the app.
  /// ~end
  ///
  /// ~chinese
  /// 创建 app 时在 console 后台上注册的 app 唯一识别符。
  /// ~end
  final String? appId;

  /// ~english
  /// Whether to enable automatic login.
  ///
  /// - (Default) `true`: Yes;
  /// - `false`: No.
  /// ~end
  ///
  /// ~chinese
  /// 是否允许自动登录。
  ///
  /// - (默认) `true`：允许;
  /// - `false`：不允许.
  /// ~end
  final bool autoLogin;

  /// ~english
  /// Whether to output the debug information. Make sure to call the method after initializing the EMClient using [EMClient.init].
  ///
  /// - `true`: Yes.
  /// - (Default) `false`: No.
  /// ~end
  ///
  /// ~chinese
  /// 是否输出调试信息，在 EMClient 初始化完成后调用，详见 [EMClient.init]。
  /// - `true`：SDK 会在 log 里输出调试信息；
  /// - （默认）`false`：不会输出调试信息。
  /// ~end
  final bool debugMode;

  /// ~english
  /// Whether to accept friend invitations from other users automatically.
  ///
  /// - (Default) `true`: Yes;
  /// - `false`: No.
  /// ~end
  ///
  /// ~chinese
  /// 是否自动接受加好友邀请。
  /// - `true`：是。
  /// - （默认）`false`：否。
  /// ~end
  final bool acceptInvitationAlways;

  /// ~english
  /// Whether to accept group invitations automatically.
  ///
  /// - (Default) `true`: Yes;
  /// - `false`: No.
  /// ~end
  ///
  /// ~chinese
  /// 是否自动接受群组邀请。
  /// - `true`：是；
  /// - （默认）`false`：否。
  /// ~end
  final bool autoAcceptGroupInvitation;

  /// ~english
  /// Whether to require read receipt after sending a message.
  ///
  /// - (Default) `true`: Yes;
  /// - `false`: No.
  /// ~end
  ///
  /// ~chinese
  /// 是否发送消息已读回执.
  /// - （默认）`true`：是；
  /// - `false`：否。
  /// ~end
  final bool requireAck;

  /// ~english
  /// Whether to require the delivery receipt after sending a message.
  ///
  /// - `true`: Yes;
  /// - (Default) `false`: No.
  /// ~end
  ///
  /// ~chinese
  ///   /// 是否发送消息已送达回执。
  /// - `true`：是。
  /// - （默认）`false`：否。
  /// ~end
  final bool requireDeliveryAck;

  /// ~english
  /// Whether to delete the group messages when leaving a group.
  ///
  /// - (Default) `true`: Yes;
  /// - `false`: No.
  /// ~end
  ///
  /// ~chinese
  /// 离开群组时是否删除消息。
  /// - （默认）`true`：是；
  /// - `false`：否。
  /// ~end
  final bool deleteMessagesAsExitGroup;

  /// ~english
  /// Whether to delete the chat room messages when leaving the chat room.
  ///
  /// - (Default) `true`: Yes;
  /// - `false`: No.
  /// ~end
  ///
  /// ~chinese
  /// 离开聊天室时是否删除消息。
  ///
  /// - （默认）`true`：是；
  /// - `false`：否。
  /// ~end
  final bool deleteMessagesAsExitChatRoom;

  /// ~english
  /// Whether to allow the chat room owner to leave the chat room.
  ///
  /// - (Default) `true`: Yes;
  /// - `false`: No.
  /// ~end
  ///
  /// ~chinese
  /// 是否允许聊天室所有者离开聊天室。
  ///
  /// - （默认）`true`：是；
  /// - `false`：否。
  /// ~end
  final bool isChatRoomOwnerLeaveAllowed;

  /// ~english
  /// Whether to sort the messages by the time when the messages are received by the server.
  ///
  /// - (Default) `true`: Yes;
  /// - `false`: No.
  /// ~end
  ///
  /// ~chinese
  /// 是否根据服务器收到消息的时间对消息进行排序。
  ///
  /// - （默认）`true`：是；
  /// - `false`：否。
  /// ~end
  final bool sortMessageByServerTime;

  /// ~english
  /// Whether only HTTPS is used for REST operations.
  ///
  /// - (Default) `true`: Only HTTPS is used.
  /// - `false`: Both HTTP and HTTPS are allowed.
  /// ~end
  ///
  /// ~chinese
  /// 是否只用 HTTPS。
  ///
  /// - （默认）`true`：是；
  /// - `false`：否。可以同时用 HTTP 和 HTTPS。
  /// ~end
  final bool usingHttpsOnly;

  /// ~english
  /// Whether to upload the message attachments automatically to the chat server.
  ///
  /// - (Default) `true`:  Yes;
  /// - `false`: No. Message attachments are uploaded to a custom path.
  /// ~end
  ///
  /// ~chinese
  /// 是否自动将消息附件上传到聊天服务器。
  ///
  /// - （默认）`true`：是；
  /// - `false`：否。使用自定义路径。
  /// ~end
  final bool serverTransfer;

  /// ~english
  /// Whether to automatically download the thumbnail.
  ///
  /// - (Default) `true`: Yes;
  /// - `false`: No.
  /// ~end
  ///
  /// ~chinese
  /// 是否自动下载缩略图。
  ///
  /// - （默认）`true`：是；
  /// - `false`：否。
  /// ~end
  final bool isAutoDownloadThumbnail;

  /// ~english
  /// Whether to enable DNS.
  ///
  /// - (Default) `true`: Yes;
  /// - `false`: No.
  /// ~end
  ///
  /// ~chinese
  /// 是否开启 DNS。
  ///
  /// - （默认）`true`：是；
  /// - `false`：否。
  /// ~end
  final bool enableDNSConfig;

  /// ~english
  /// The DNS URL.
  /// ~end
  ///
  /// ~chinese
  /// DNS 地址。
  /// ~end
  final String? dnsUrl;

  /// ~english
  /// The custom REST server.
  /// ~end
  ///
  /// ~chinese
  /// REST 服务器。
  /// ~end
  final String? restServer;

  /// ~english
  /// The custom IM message server url.
  /// ~end
  ///
  /// ~chinese
  /// 消息服务器。
  /// ~end
  final String? imServer;

  /// ~english
  /// The custom IM server port.
  /// ~end
  ///
  /// ~chinese
  /// 是否使用自定义 IM 服务的端口。用于私有化部署。
  /// ~end
  final int? imPort;

  /// ~english
  /// Whether to enable TLS connection, which takes effect during initialization and is false by default.
  /// ~end
  ///
  /// ~chinese
  /// 是否开启 TLS 连接，初始化时生效，默认为 false。
  /// ~end
  final bool enableTLS;

  /// ~english
  /// Whether the sent message is included in [EMChatEventHandler.onMessagesReceived]:
  /// - `true`: Yes. Besides the received message, the sent message is also included in [EMChatEventHandler.onMessagesReceived].
  /// - (Default) `false`: No. Only the received message is included in [EMChatEventHandler.onMessagesReceived].

  /// ~end
  /// ~chinese
  /// 发送的消息是会执行 [EMChatEventHandler.onMessagesReceived] 回调。
  /// - `true`：是。接收消息回调中包含发送成功的消息。
  /// - （默认）`false`：否。接收消息回调中只包含接收的消息。
  /// ~end
  final bool messagesReceiveCallbackIncludeSend;

  /// ~english
  /// Whether to regard import messages as read.
  /// - `true`: Yes.
  /// - (Default) `false`: No.
  /// ~end
  ///
  /// ~chinese
  /// 是否将导入的消息视为已读。
  /// - `true`：已读。
  /// - （默认）`false`：未读。
  /// ~end
  final bool regardImportMessagesAsRead;

  /// ~english
  /// The area code.
  /// This attribute is used to restrict the scope of accessible edge nodes. The default value is `AreaCodeGLOB`.
  /// This attribute can be set only when you call [EMClient.init]. The attribute setting cannot be changed during the app runtime.
  /// ~end
  ///
  /// ~chinese
  /// 区号
  /// 此属性用于限制可访问边缘节点的范围。缺省值为AreaCodeGLOB。
  /// 此属性只能在调用[EMClient.init]时设置。在应用程序运行期间不能更改属性设置。
  /// ~end
  final int chatAreaCode;

  /// ~english
  /// Whether to include empty conversations when the SDK loads conversations from the local database:
  /// - `true`: Yes;
  /// - (Default) `false`: No.
  /// ~end
  ///
  /// ~chinese
  /// 从本地数据库加载会话时是否包括空会话。
  /// - `true`：包含空会话；
  /// - （默认）`false`：不包含空会话。
  /// ~end
  final bool enableEmptyConversation;

  /// ~english
  ///  Custom device name.
  /// ~end
  ///
  /// ~chinese
  /// 自定义设备名称。
  /// ~end
  final String? deviceName;

  /// ~english
  /// Custom system type.
  /// ~end
  ///
  /// ~chinese
  /// 自定义系统类型。
  /// ~end
  final int? osType;

  /// ~english
  /// Whether the server returns the sender the text message with the content replaced during text moderation:
  /// - `true`: Return the adjusted message to the sender.
  /// - (Default) `false`: Return the original message to the sender.
  /// ~end
  ///
  /// ~chinese
  /// 是否在文本审核时，返回给发送者被替换内容的文本消息：
  /// - `true`：返回给发送者被调整的消息。
  /// - （默认）`false`：返回给发送者原始消息。
  /// ~end
  final bool useReplacedMessageContents;

  /// ~english
  /// Whether the SDK work path is copiable, only valid for iOS, default is false.
  /// ~end
  ///
  /// ~chinese
  ///
  /// SDK 的工作路径是否可备份, 只有ios生效，默认为 false。
  /// ~end
  ///
  final bool workPathCopiable;

  EMPushConfig _pushConfig = EMPushConfig();

  @Deprecated('Use [EMPushManager.bindDeviceToken] instead.')

  /// ~english
  /// Enables OPPO PUSH on OPPO devices.
  ///
  /// Param [appKey] The app ID for OPPO PUSH.
  ///
  /// Param [secret] The app secret for OPPO PUSH.
  /// ~end
  ///
  /// ~chinese
  /// 开启 Oppo 推送。
  ///
  /// Param [appId] Oppo 推送的 App ID。
  ///
  /// Param [appKey] Oppo 推送的 App Key。
  /// ~end
  void enableOppoPush(String appKey, String secret) {
    _pushConfig.enableOppoPush = true;
    _pushConfig.oppoAppKey = appKey;
    _pushConfig.oppoAppSecret = secret;
  }

  @Deprecated('Use [EMPushManager.bindDeviceToken] instead.')

  /// ~english
  /// Enables Mi Push on Mi devices.
  ///
  /// Param [appId] The app ID for Mi Push.
  ///
  /// Param [appKey] The app key for Mi Push.
  /// ~end
  ///
  /// ~chinese
  /// 开启小米推送。
  ///
  /// Param [appId] 小米推送的 App ID。
  ///
  /// Param [appKey] 小米推送的 app key。
  /// ~end
  void enableMiPush(String appId, String appKey) {
    _pushConfig.enableMiPush = true;
    _pushConfig.miAppId = appId;
    _pushConfig.miAppKey = appKey;
  }

  @Deprecated('Use [EMPushManager.bindDeviceToken] instead.')

  /// ~english
  /// Enables MeiZu Push on MeiZu devices.
  /// Param [appId] The app ID for MeiZu Push.
  /// Param [appKey] The app key for MeiZu Push.
  /// ~end
  ///
  /// ~chinese
  /// 开启魅族推送.
  /// Param [appId] 魅族 App ID.
  /// Param [appKey] 魅族 App Key.
  /// ~end
  void enableMeiZuPush(String appId, String appKey) {
    _pushConfig.mzAppId = appId;
    _pushConfig.mzAppKey = appKey;
  }

  @Deprecated('Use [EMPushManager.bindDeviceToken] instead.')

  /// ~english
  /// Enables Firebase Cloud Messaging (FCM) push on devices that support Google Play.
  ///
  /// Param [appId] The app ID for FCM push.
  /// ~end
  ///
  /// ~chinese
  /// 开启 FCM（GCM 的升级版）推送。
  ///
  /// Param [appId] FCM 推送的 App ID。
  /// ~end
  void enableFCM(String appId) {
    _pushConfig.enableFCM = true;
    _pushConfig.fcmId = appId;
  }

  @Deprecated('Use [EMPushManager.bindDeviceToken] instead.')

  /// ~english
  /// Enables vivo Push on vivo devices.
  /// ~end
  ///
  /// ~chinese
  /// 开启 vivo 推送。
  /// ~end
  void enableVivoPush(bool agreePrivacyStatement) {
    _pushConfig.enableVivoPush = true;
    _pushConfig.agreePrivacyStatement = agreePrivacyStatement;
  }

  @Deprecated('Use [EMPushManager.bindDeviceToken] instead.')

  /// ~english
  /// Enables Huawei Push on Huawei devices.
  /// ~end
  ///
  /// ~chinese
  /// 开启华为推送。
  /// ~end
  void enableHWPush() {
    _pushConfig.enableHWPush = true;
  }

  @Deprecated('Use [EMPushManager.bindDeviceToken] instead.')

  /// ~english
  /// Enables Apple Push Notification service (APNs) on iOS devices.
  ///
  /// Param [certName] The APNs certificate name.
  /// ~end
  ///
  /// ~chinese
  /// 开启 Apple 推送通知服务（APNs）推送。
  ///
  /// Param [certName] APNs 推送证书的名称。
  /// ~end
  void enableAPNs(String certName) {
    _pushConfig.enableAPNS = true;
    _pushConfig.apnsCertName = certName;
  }

  @Deprecated('Use [EMPushManager.bindDeviceToken] instead.')

  /// ~english
  /// Enables Honor Push on Honor devices.
  /// ~end
  ///
  /// ~chinese
  /// 开启荣耀推送。
  /// ~end
  void enableHonorPush() {
    _pushConfig.enableHonorPush = true;
  }

  /// ~english
  /// Sets the app options.
  ///
  /// Param [appId] The app Id that you get from the console when creating an app.
  ///
  /// Param [autoLogin] Whether to enable automatic login.
  /// - (Default) `true`: Enables automatic login.
  /// - `false`: Disables automatic login.
  ///
  /// Param [debugMode] Whether to output the debug information. Make sure to call the method after the EMClient is initialized.
  /// - `true`: Yes.
  /// - (Default) `false`: No.
  /// Param [acceptInvitationAlways] Whether to accept friend invitations from other users automatically.
  /// - `true`: Yes.
  /// - (Default) `false`: No.
  ///
  /// Param [autoAcceptGroupInvitation] Whether to accept group invitations automatically.
  /// - `true`: Yes.
  /// - (Default) `false`: No.
  ///
  /// Param [requireAck] Whether to require the message read receipt from the recipient.
  /// - (Default) `true`: Yes.
  /// - `false`: No.
  ///
  /// Param [requireDeliveryAck] Whether the delivery receipt is required.
  /// `true`: Yes.
  /// (Default) `false`: No.
  ///
  /// Param [deleteMessagesAsExitGroup] Whether to delete the related group messages when leaving a group.
  /// - (Default) `true`: Yes.
  /// - `false`: No.
  ///
  /// Param [deleteMessagesAsExitChatRoom] Whether to delete the related chat room messages when leaving the chat room.
  /// - (Default) `true`: Yes.
  /// - `false`: No.
  ///
  /// Param [isChatRoomOwnerLeaveAllowed] Whether to allow the chat room owner to leave the chat room.
  /// - (Default) `true`: Yes. Even if the chat room owner leaves the chat room, the owner still has all privileges, except for receiving messages in the chat room.
  /// - `false`: No.
  ///
  /// Param [sortMessageByServerTime] Whether to sort the messages in the reverse chronological order of the time when they are received by the server.
  /// - (Default) `true`: Yes;
  /// - `false`: No. Messages are sorted in the reverse chronological order of the time when they are created.

  /// Param [usingHttpsOnly] Whether only HTTPS is used for REST operations.
  /// - (Default) `true`: Only HTTPS is supported.
  /// - `false`: Both HTTP and HTTPS are allowed.
  ///
  /// Param [serverTransfer] Whether to upload the message attachments automatically to the chat server.
  /// - (Default) `true`: Yes.
  /// - `false`: No. A custom path is used.
  ///
  /// Param [isAutoDownloadThumbnail] Whether to automatically download the thumbnail.
  /// - (Default) `true`: Yes.
  /// - `false`: No.
  ///
  /// Param [enableDNSConfig] Whether to enable DNS.
  /// - (Default) `true`: Yes.
  /// - `false`: No. DNS needs to be disabled for private deployment.
  ///
  /// Param [dnsUrl] The DNS url.
  ///
  /// Param [restServer] The REST server for private deployments.
  ///
  /// Param [imPort] The IM server port for private deployments.
  ///
  /// Param [imServer] The IM server URL for private deployment.
  ///
  /// Param [chatAreaCode] The area code.
  ///
  /// Param [enableEmptyConversation] Whether to include empty conversations when the SDK loads conversations from the local database.
  /// - `true`: Yes. Empty conversations are included.
  /// - (Default) `false`: No. Empty conversations are excluded.
  ///
  /// Param [deviceName] Custom device name.
  ///
  /// Param [osType] Custom system type.
  ///
  /// Param [useReplacedMessageContents] Whether the server returns the sender the text message with the content replaced during text moderation.
  /// - `true`: Yes.
  /// - (Default) `false`: No. The server returns the original message to the sender.
  ///
  /// Param [enableTLS] Whether to enable TLS connection, which takes effect during initialization and is false by default.
  ///
  /// Param [messagesReceiveCallbackIncludeSend] Whether to include the sent message in [EMChatEventHandler.onMessagesReceived].
  /// - `true`: Yes. Besides the received message, the sent message is also included in [EMChatEventHandler.onMessagesReceived].
  /// - (Default)`false`: No. Only the received message is included in [EMChatEventHandler.onMessagesReceived].
  ///
  /// Param [regardImportMessagesAsRead] Whether to regard import messages as read:
  /// - `true`: Yes.
  /// - (Default) `false`: No.
  ///
  /// Param [workPathCopiable] Whether the SDK work path is copiable, only valid for iOS, default is false.
  ///
  /// ~end
  ///
  /// ~chinese
  /// 设置 SDK
  /// Param [appKey] 创建 app 时在 console 后台上注册的 app 唯一识别符。
  ///
  /// Param [autoLogin] 是否开启自动登录。
  /// - （默认）`true`：是；
  /// - `false`：否。
  ///
  /// Param [debugMode] 是否输出调试信息，在 EMClient 初始化完成后调用，详见 [EMClient.init]。
  /// - `true`：SDK 会在 log 里输出调试信息；
  /// - （默认）`false`：不会输出调试信息。
  ///
  /// Param [acceptInvitationAlways] 是否自动接受加好友邀请。
  /// - （默认）`true`：是；
  /// - `false`：否。
  ///
  /// Param [autoAcceptGroupInvitation] 是否自动接受群组邀请。
  /// - `true`：是；
  /// - （默认）`false`：否。
  ///
  /// Param [requireAck] 是否发送已读回执。
  /// - （默认）`true`：是；
  /// - `false`：否。
  ///
  /// Param [requireDeliveryAck] 是否发送已送达回执。
  /// - （默认）`true`：是；
  /// - `false`：否。
  ///
  /// Param [deleteMessagesAsExitGroup] 是否在离开群组时删除群组历史消息。
  /// - （默认）`true`：是；
  /// - `false`：否。
  ///
  /// Param [deleteMessagesAsExitChatRoom] 是否在离开聊天室时删除聊天历史消息。
  /// - （默认）`true`：是；
  /// - `false`：否。
  ///
  /// Param [isChatRoomOwnerLeaveAllowed] 是否允许聊天室所有者离开聊天室。
  /// - （默认）`true`：是；
  /// - `false`：否。
  ///
  /// Param [sortMessageByServerTime] 是否根据服务器收到消息的时间对消息进行排序。
  /// - （默认）`true`：是；
  /// - `false`：否。
  ///
  /// Param [usingHttpsOnly] 是否只使用 HTTPS。
  /// - （默认）`true`：是；
  /// - `false`：否。
  ///
  /// Param [serverTransfer] 是否自动将消息附件上传到聊天服务器。
  /// - （默认）`true`：是；
  /// - `false`：否。
  ///
  /// Param [isAutoDownloadThumbnail] 是否自动下载缩略图。
  /// - （默认）`true`：是；
  /// - `false`：否。
  ///
  /// Param [enableDNSConfig] 设置是否开启 DNS。
  /// - （默认）`true`：是；
  /// - `false`：否。
  ///
  /// Param [dnsUrl] DNS 地址。
  ///
  /// Param [restServer] 私有部署时的 REST 服务器地址。
  ///
  /// Param [imPort] 私有部署时的 IM 服务器端口。
  ///
  /// Param [imServer] 私有部署时的 IM 服务器地址。
  ///
  /// Param [chatAreaCode] server 区域码.
  ///
  /// Param [enableEmptyConversation] 从本地数据库加载会话时是否包括空会话。
  /// - `true`：包含空会话；
  /// - （默认）`false`：不包含空会话。
  ///
  /// Param [deviceName] 自定义设备名称。
  ///
  /// Param [osType] 自定义系统类型。
  ///
  /// Param [useReplacedMessageContents] 是否在文本审核时，返回给发送者被替换内容的文本消息。
  ///  - `true`：将内容替换后的消息返回给发送方。
  ///  - （默认）`false`：将原消息返回给发送方。
  ///
  /// Param [enableTLS] 是否开启 TLS 连接，初始化时生效，默认为 false。
  ///
  /// Param [messagesReceiveCallbackIncludeSend] 发送的消息是会执行 [EMChatEventHandler.onMessagesReceived] 回调。
  /// - `true`：是。接收消息通知中包含发送成功的消息。
  /// - （默认）`false`：否。接收消息通知中只包含接收的消息。
  ///
  /// Param [regardImportMessagesAsRead] 是否将导入的消息视为已读, 默认为 false。
  ///
  ///
  /// Param [workPathCopiable] 是否允许复制工作路径到其他地方，只有ios生效，默认为 false。
  ///
  /// ~end
  EMOptions.withAppId(
    String appId, {
    bool autoLogin = true,
    bool debugMode = false,
    bool acceptInvitationAlways = false,
    bool autoAcceptGroupInvitation = false,
    bool requireAck = true,
    bool requireDeliveryAck = false,
    bool deleteMessagesAsExitGroup = true,
    bool deleteMessagesAsExitChatRoom = true,
    bool isChatRoomOwnerLeaveAllowed = true,
    bool sortMessageByServerTime = true,
    bool usingHttpsOnly = true,
    bool serverTransfer = true,
    bool isAutoDownloadThumbnail = true,
    bool enableDNSConfig = true,
    String? dnsUrl,
    String? restServer,
    int? imPort,
    String? imServer,
    int? chatAreaCode,
    bool enableEmptyConversation = false,
    String? deviceName,
    int? osType,
    bool useReplacedMessageContents = false,
    bool enableTLS = false,
    bool messagesReceiveCallbackIncludeSend = false,
    bool regardImportMessagesAsRead = false,
    bool workPathCopiable = false,
    String? loginExtension,
  }) : this._(
          appId: appId,
          autoLogin: autoLogin,
          debugMode: debugMode,
          acceptInvitationAlways: acceptInvitationAlways,
          autoAcceptGroupInvitation: autoAcceptGroupInvitation,
          requireAck: requireAck,
          requireDeliveryAck: requireDeliveryAck,
          deleteMessagesAsExitGroup: deleteMessagesAsExitGroup,
          deleteMessagesAsExitChatRoom: deleteMessagesAsExitChatRoom,
          isChatRoomOwnerLeaveAllowed: isChatRoomOwnerLeaveAllowed,
          sortMessageByServerTime: sortMessageByServerTime,
          usingHttpsOnly: usingHttpsOnly,
          serverTransfer: serverTransfer,
          isAutoDownloadThumbnail: isAutoDownloadThumbnail,
          enableDNSConfig: enableDNSConfig,
          dnsUrl: dnsUrl,
          restServer: restServer,
          imPort: imPort,
          imServer: imServer,
          chatAreaCode: chatAreaCode ?? ChatAreaCode.GLOB,
          enableEmptyConversation: enableEmptyConversation,
          deviceName: deviceName,
          osType: osType,
          useReplacedMessageContents: useReplacedMessageContents,
          enableTLS: enableTLS,
          messagesReceiveCallbackIncludeSend:
              messagesReceiveCallbackIncludeSend,
          regardImportMessagesAsRead: regardImportMessagesAsRead,
          workPathCopiable: workPathCopiable,
          loginExtension: loginExtension,
        );

  /// ~english
  /// Sets the app options.
  ///
  /// Param [appKey] The app key that you get from the console when creating an app.
  ///
  /// Param [autoLogin] Whether to enable automatic login.
  /// - (Default) `true`: Enables automatic login.
  /// - `false`: Disables automatic login.
  ///
  /// Param [debugMode] Whether to output the debug information. Make sure to call the method after the EMClient is initialized.
  /// - `true`: Yes.
  /// - (Default) `false`: No.
  /// Param [acceptInvitationAlways] Whether to accept friend invitations from other users automatically.
  /// - `true`: Yes.
  /// - (Default) `false`: No.
  ///
  /// Param [autoAcceptGroupInvitation] Whether to accept group invitations automatically.
  /// - `true`: Yes.
  /// - (Default) `false`: No.
  ///
  /// Param [requireAck] Whether to require the message read receipt from the recipient.
  /// - (Default) `true`: Yes.
  /// - `false`: No.
  ///
  /// Param [requireDeliveryAck] Whether the delivery receipt is required.
  /// `true`: Yes.
  /// (Default) `false`: No.
  ///
  /// Param [deleteMessagesAsExitGroup] Whether to delete the related group messages when leaving a group.
  /// - (Default) `true`: Yes.
  /// - `false`: No.
  ///
  /// Param [deleteMessagesAsExitChatRoom] Whether to delete the related chat room messages when leaving the chat room.
  /// - (Default) `true`: Yes.
  /// - `false`: No.
  ///
  /// Param [isChatRoomOwnerLeaveAllowed] Whether to allow the chat room owner to leave the chat room.
  /// - (Default) `true`: Yes. Even if the chat room owner leaves the chat room, the owner still has all privileges, except for receiving messages in the chat room.
  /// - `false`: No.
  ///
  /// Param [sortMessageByServerTime] Whether to sort the messages in the reverse chronological order of the time when they are received by the server.
  /// - (Default) `true`: Yes;
  /// - `false`: No. Messages are sorted in the reverse chronological order of the time when they are created.

  /// Param [usingHttpsOnly] Whether only HTTPS is used for REST operations.
  /// - (Default) `true`: Only HTTPS is supported.
  /// - `false`: Both HTTP and HTTPS are allowed.
  ///
  /// Param [serverTransfer] Whether to upload the message attachments automatically to the chat server.
  /// - (Default) `true`: Yes.
  /// - `false`: No. A custom path is used.
  ///
  /// Param [isAutoDownloadThumbnail] Whether to automatically download the thumbnail.
  /// - (Default) `true`: Yes.
  /// - `false`: No.
  ///
  /// Param [enableDNSConfig] Whether to enable DNS.
  /// - (Default) `true`: Yes.
  /// - `false`: No. DNS needs to be disabled for private deployment.
  ///
  /// Param [dnsUrl] The DNS url.
  ///
  /// Param [restServer] The REST server for private deployments.
  ///
  /// Param [imPort] The IM server port for private deployments.
  ///
  /// Param [imServer] The IM server URL for private deployment.
  ///
  /// Param [chatAreaCode] The area code.
  ///
  /// Param [enableEmptyConversation] Whether to include empty conversations when the SDK loads conversations from the local database.
  /// - `true`: Yes. Empty conversations are included.
  /// - (Default) `false`: No. Empty conversations are excluded.
  ///
  /// Param [deviceName] Custom device name.
  ///
  /// Param [osType] Custom system type.
  ///
  /// Param [useReplacedMessageContents] Whether the server returns the sender the text message with the content replaced during text moderation.
  /// - `true`: Yes.
  /// - (Default) `false`: No. The server returns the original message to the sender.
  ///
  /// Param [enableTLS] Whether to enable TLS connection, which takes effect during initialization and is false by default.
  ///
  /// Param [messagesReceiveCallbackIncludeSend] Whether to include the sent message in [EMChatEventHandler.onMessagesReceived].
  /// - `true`: Yes. Besides the received message, the sent message is also included in [EMChatEventHandler.onMessagesReceived].
  /// - (Default)`false`: No. Only the received message is included in [EMChatEventHandler.onMessagesReceived].
  ///
  /// Param [regardImportMessagesAsRead] Whether to regard import messages as read:
  /// - `true`: Yes.
  /// - (Default) `false`: No.
  ///
  /// Param [workPathCopiable] Whether the SDK work path is copiable, only valid for iOS, default is false.
  ///
  /// ~end
  ///
  /// ~chinese
  /// 设置 SDK
  /// Param [appKey] 创建 app 时在 console 后台上注册的 app 唯一识别符。
  ///
  /// Param [autoLogin] 是否开启自动登录。
  /// - （默认）`true`：是；
  /// - `false`：否。
  ///
  /// Param [debugMode] 是否输出调试信息，在 EMClient 初始化完成后调用，详见 [EMClient.init]。
  /// - `true`：SDK 会在 log 里输出调试信息；
  /// - （默认）`false`：不会输出调试信息。
  ///
  /// Param [acceptInvitationAlways] 是否自动接受加好友邀请。
  /// - （默认）`true`：是；
  /// - `false`：否。
  ///
  /// Param [autoAcceptGroupInvitation] 是否自动接受群组邀请。
  /// - `true`：是；
  /// - （默认）`false`：否。
  ///
  /// Param [requireAck] 是否发送已读回执。
  /// - （默认）`true`：是；
  /// - `false`：否。
  ///
  /// Param [requireDeliveryAck] 是否发送已送达回执。
  /// - （默认）`true`：是；
  /// - `false`：否。
  ///
  /// Param [deleteMessagesAsExitGroup] 是否在离开群组时删除群组历史消息。
  /// - （默认）`true`：是；
  /// - `false`：否。
  ///
  /// Param [deleteMessagesAsExitChatRoom] 是否在离开聊天室时删除聊天历史消息。
  /// - （默认）`true`：是；
  /// - `false`：否。
  ///
  /// Param [isChatRoomOwnerLeaveAllowed] 是否允许聊天室所有者离开聊天室。
  /// - （默认）`true`：是；
  /// - `false`：否。
  ///
  /// Param [sortMessageByServerTime] 是否根据服务器收到消息的时间对消息进行排序。
  /// - （默认）`true`：是；
  /// - `false`：否。
  ///
  /// Param [usingHttpsOnly] 是否只使用 HTTPS。
  /// - （默认）`true`：是；
  /// - `false`：否。
  ///
  /// Param [serverTransfer] 是否自动将消息附件上传到聊天服务器。
  /// - （默认）`true`：是；
  /// - `false`：否。
  ///
  /// Param [isAutoDownloadThumbnail] 是否自动下载缩略图。
  /// - （默认）`true`：是；
  /// - `false`：否。
  ///
  /// Param [enableDNSConfig] 设置是否开启 DNS。
  /// - （默认）`true`：是；
  /// - `false`：否。
  ///
  /// Param [dnsUrl] DNS 地址。
  ///
  /// Param [restServer] 私有部署时的 REST 服务器地址。
  ///
  /// Param [imPort] 私有部署时的 IM 服务器端口。
  ///
  /// Param [imServer] 私有部署时的 IM 服务器地址。
  ///
  /// Param [chatAreaCode] server 区域码.
  ///
  /// Param [enableEmptyConversation] 从本地数据库加载会话时是否包括空会话。
  /// - `true`：包含空会话；
  /// - （默认）`false`：不包含空会话。
  ///
  /// Param [deviceName] 自定义设备名称。
  ///
  /// Param [osType] 自定义系统类型。
  ///
  /// Param [useReplacedMessageContents] 是否在文本审核时，返回给发送者被替换内容的文本消息。
  ///  - `true`：将内容替换后的消息返回给发送方。
  ///  - （默认）`false`：将原消息返回给发送方。
  ///
  /// Param [enableTLS] 是否开启 TLS 连接，初始化时生效，默认为 false。
  ///
  /// Param [messagesReceiveCallbackIncludeSend] 发送的消息是会执行 [EMChatEventHandler.onMessagesReceived] 回调。
  /// - `true`：是。接收消息通知中包含发送成功的消息。
  /// - （默认）`false`：否。接收消息通知中只包含接收的消息。
  ///
  /// Param [regardImportMessagesAsRead] 是否将导入的消息视为已读, 默认为 false。
  ///
  ///
  /// Param [workPathCopiable] 是否允许复制工作路径到其他地方，只有ios生效，默认为 false。
  ///
  /// ~end
  EMOptions.withAppKey(
    String appKey, {
    bool autoLogin = true,
    bool debugMode = false,
    bool acceptInvitationAlways = false,
    bool autoAcceptGroupInvitation = false,
    bool requireAck = true,
    bool requireDeliveryAck = false,
    bool deleteMessagesAsExitGroup = true,
    bool deleteMessagesAsExitChatRoom = true,
    bool isChatRoomOwnerLeaveAllowed = true,
    bool sortMessageByServerTime = true,
    bool usingHttpsOnly = true,
    bool serverTransfer = true,
    bool isAutoDownloadThumbnail = true,
    bool enableDNSConfig = true,
    String? dnsUrl,
    String? restServer,
    int? imPort,
    String? imServer,
    int? chatAreaCode,
    bool enableEmptyConversation = false,
    String? deviceName,
    int? osType,
    bool useReplacedMessageContents = false,
    bool enableTLS = false,
    bool messagesReceiveCallbackIncludeSend = false,
    bool regardImportMessagesAsRead = false,
    bool workPathCopiable = false,
    String? loginExtension,
  }) : this._(
          appKey: appKey,
          autoLogin: autoLogin,
          debugMode: debugMode,
          acceptInvitationAlways: acceptInvitationAlways,
          autoAcceptGroupInvitation: autoAcceptGroupInvitation,
          requireAck: requireAck,
          requireDeliveryAck: requireDeliveryAck,
          deleteMessagesAsExitGroup: deleteMessagesAsExitGroup,
          deleteMessagesAsExitChatRoom: deleteMessagesAsExitChatRoom,
          isChatRoomOwnerLeaveAllowed: isChatRoomOwnerLeaveAllowed,
          sortMessageByServerTime: sortMessageByServerTime,
          usingHttpsOnly: usingHttpsOnly,
          serverTransfer: serverTransfer,
          isAutoDownloadThumbnail: isAutoDownloadThumbnail,
          enableDNSConfig: enableDNSConfig,
          dnsUrl: dnsUrl,
          restServer: restServer,
          imPort: imPort,
          imServer: imServer,
          chatAreaCode: chatAreaCode ?? ChatAreaCode.GLOB,
          enableEmptyConversation: enableEmptyConversation,
          deviceName: deviceName,
          osType: osType,
          useReplacedMessageContents: useReplacedMessageContents,
          enableTLS: enableTLS,
          messagesReceiveCallbackIncludeSend:
              messagesReceiveCallbackIncludeSend,
          regardImportMessagesAsRead: regardImportMessagesAsRead,
          workPathCopiable: workPathCopiable,
          loginExtension: loginExtension,
        );

  @Deprecated('Use [EMOptions.withAppKey] instead.')

  /// ~english
  /// Sets the app options.
  ///
  /// Param [appKey] The app key that you get from the console when creating an app.
  ///
  /// Param [autoLogin] Whether to enable automatic login.
  /// - (Default) `true`: Enables automatic login.
  /// - `false`: Disables automatic login.
  ///
  /// Param [debugMode] Whether to output the debug information. Make sure to call the method after the EMClient is initialized.
  /// - `true`: Yes.
  /// - (Default) `false`: No.
  /// Param [acceptInvitationAlways] Whether to accept friend invitations from other users automatically.
  /// - `true`: Yes.
  /// - (Default) `false`: No.
  ///
  /// Param [autoAcceptGroupInvitation] Whether to accept group invitations automatically.
  /// - `true`: Yes.
  /// - (Default) `false`: No.
  ///
  /// Param [requireAck] Whether to require the message read receipt from the recipient.
  /// - (Default) `true`: Yes.
  /// - `false`: No.
  ///
  /// Param [requireDeliveryAck] Whether the delivery receipt is required.
  /// `true`: Yes.
  /// (Default) `false`: No.
  ///
  /// Param [deleteMessagesAsExitGroup] Whether to delete the related group messages when leaving a group.
  /// - (Default) `true`: Yes.
  /// - `false`: No.
  ///
  /// Param [deleteMessagesAsExitChatRoom] Whether to delete the related chat room messages when leaving the chat room.
  /// - (Default) `true`: Yes.
  /// - `false`: No.
  ///
  /// Param [isChatRoomOwnerLeaveAllowed] Whether to allow the chat room owner to leave the chat room.
  /// - (Default) `true`: Yes. Even if the chat room owner leaves the chat room, the owner still has all privileges, except for receiving messages in the chat room.
  /// - `false`: No.
  ///
  /// Param [sortMessageByServerTime] Whether to sort the messages in the reverse chronological order of the time when they are received by the server.
  /// - (Default) `true`: Yes;
  /// - `false`: No. Messages are sorted in the reverse chronological order of the time when they are created.

  /// Param [usingHttpsOnly] Whether only HTTPS is used for REST operations.
  /// - (Default) `true`: Only HTTPS is supported.
  /// - `false`: Both HTTP and HTTPS are allowed.
  ///
  /// Param [serverTransfer] Whether to upload the message attachments automatically to the chat server.
  /// - (Default) `true`: Yes.
  /// - `false`: No. A custom path is used.
  ///
  /// Param [isAutoDownloadThumbnail] Whether to automatically download the thumbnail.
  /// - (Default) `true`: Yes.
  /// - `false`: No.
  ///
  /// Param [enableDNSConfig] Whether to enable DNS.
  /// - (Default) `true`: Yes.
  /// - `false`: No. DNS needs to be disabled for private deployment.
  ///
  /// Param [dnsUrl] The DNS url.
  ///
  /// Param [restServer] The REST server for private deployments.
  ///
  /// Param [imPort] The IM server port for private deployments.
  ///
  /// Param [imServer] The IM server URL for private deployment.
  ///
  /// Param [chatAreaCode] The area code.
  ///
  /// Param [enableEmptyConversation] Whether to include empty conversations when the SDK loads conversations from the local database.
  /// - `true`: Yes. Empty conversations are included.
  /// - (Default) `false`: No. Empty conversations are excluded.
  ///
  /// Param [deviceName] Custom device name.
  ///
  /// Param [osType] Custom system type.
  ///
  /// Param [useReplacedMessageContents] Whether the server returns the sender the text message with the content replaced during text moderation.
  /// - `true`: Yes.
  /// - (Default) `false`: No. The server returns the original message to the sender.
  ///
  /// Param [enableTLS] Whether to enable TLS connection, which takes effect during initialization and is false by default.
  ///
  /// Param [messagesReceiveCallbackIncludeSend] Whether to include the sent message in [EMChatEventHandler.onMessagesReceived].
  /// - `true`: Yes. Besides the received message, the sent message is also included in [EMChatEventHandler.onMessagesReceived].
  /// - (Default)`false`: No. Only the received message is included in [EMChatEventHandler.onMessagesReceived].
  ///
  /// Param [regardImportMessagesAsRead] Whether to regard import messages as read:
  /// - `true`: Yes.
  /// - (Default) `false`: No.
  ///
  /// Param [workPathCopiable] Whether the SDK work path is copiable, only valid for iOS, default is false.
  ///
  /// ~end
  ///
  /// ~chinese
  /// 设置 SDK
  /// Param [appKey] 创建 app 时在 console 后台上注册的 app 唯一识别符。
  ///
  /// Param [autoLogin] 是否开启自动登录。
  /// - （默认）`true`：是；
  /// - `false`：否。
  ///
  /// Param [debugMode] 是否输出调试信息，在 EMClient 初始化完成后调用，详见 [EMClient.init]。
  /// - `true`：SDK 会在 log 里输出调试信息；
  /// - （默认）`false`：不会输出调试信息。
  ///
  /// Param [acceptInvitationAlways] 是否自动接受加好友邀请。
  /// - （默认）`true`：是；
  /// - `false`：否。
  ///
  /// Param [autoAcceptGroupInvitation] 是否自动接受群组邀请。
  /// - `true`：是；
  /// - （默认）`false`：否。
  ///
  /// Param [requireAck] 是否发送已读回执。
  /// - （默认）`true`：是；
  /// - `false`：否。
  ///
  /// Param [requireDeliveryAck] 是否发送已送达回执。
  /// - （默认）`true`：是；
  /// - `false`：否。
  ///
  /// Param [deleteMessagesAsExitGroup] 是否在离开群组时删除群组历史消息。
  /// - （默认）`true`：是；
  /// - `false`：否。
  ///
  /// Param [deleteMessagesAsExitChatRoom] 是否在离开聊天室时删除聊天历史消息。
  /// - （默认）`true`：是；
  /// - `false`：否。
  ///
  /// Param [isChatRoomOwnerLeaveAllowed] 是否允许聊天室所有者离开聊天室。
  /// - （默认）`true`：是；
  /// - `false`：否。
  ///
  /// Param [sortMessageByServerTime] 是否根据服务器收到消息的时间对消息进行排序。
  /// - （默认）`true`：是；
  /// - `false`：否。
  ///
  /// Param [usingHttpsOnly] 是否只使用 HTTPS。
  /// - （默认）`true`：是；
  /// - `false`：否。
  ///
  /// Param [serverTransfer] 是否自动将消息附件上传到聊天服务器。
  /// - （默认）`true`：是；
  /// - `false`：否。
  ///
  /// Param [isAutoDownloadThumbnail] 是否自动下载缩略图。
  /// - （默认）`true`：是；
  /// - `false`：否。
  ///
  /// Param [enableDNSConfig] 设置是否开启 DNS。
  /// - （默认）`true`：是；
  /// - `false`：否。
  ///
  /// Param [dnsUrl] DNS 地址。
  ///
  /// Param [restServer] 私有部署时的 REST 服务器地址。
  ///
  /// Param [imPort] 私有部署时的 IM 服务器端口。
  ///
  /// Param [imServer] 私有部署时的 IM 服务器地址。
  ///
  /// Param [chatAreaCode] server 区域码.
  ///
  /// Param [enableEmptyConversation] 从本地数据库加载会话时是否包括空会话。
  /// - `true`：包含空会话；
  /// - （默认）`false`：不包含空会话。
  ///
  /// Param [deviceName] 自定义设备名称。
  ///
  /// Param [osType] 自定义系统类型。
  ///
  /// Param [useReplacedMessageContents] 是否在文本审核时，返回给发送者被替换内容的文本消息。
  ///  - `true`：将内容替换后的消息返回给发送方。
  ///  - （默认）`false`：将原消息返回给发送方。
  ///
  /// Param [enableTLS] 是否开启 TLS 连接，初始化时生效，默认为 false。
  ///
  /// Param [messagesReceiveCallbackIncludeSend] 发送的消息是会执行 [EMChatEventHandler.onMessagesReceived] 回调。
  /// - `true`：是。接收消息通知中包含发送成功的消息。
  /// - （默认）`false`：否。接收消息通知中只包含接收的消息。
  ///
  /// Param [regardImportMessagesAsRead] 是否将导入的消息视为已读, 默认为 false。
  ///
  ///
  /// Param [workPathCopiable] 是否允许复制工作路径到其他地方，只有ios生效，默认为 false。
  ///
  /// ~end
  EMOptions({
    required String appKey,
    bool autoLogin = true,
    bool debugMode = false,
    bool acceptInvitationAlways = false,
    bool autoAcceptGroupInvitation = false,
    bool requireAck = true,
    bool requireDeliveryAck = false,
    bool deleteMessagesAsExitGroup = true,
    bool deleteMessagesAsExitChatRoom = true,
    bool isChatRoomOwnerLeaveAllowed = true,
    bool sortMessageByServerTime = true,
    bool usingHttpsOnly = true,
    bool serverTransfer = true,
    bool isAutoDownloadThumbnail = true,
    bool enableDNSConfig = true,
    String? dnsUrl,
    String? restServer,
    int? imPort,
    String? imServer,
    int? chatAreaCode,
    bool enableEmptyConversation = false,
    String? deviceName,
    int? osType,
    bool useReplacedMessageContents = false,
    bool enableTLS = false,
    bool messagesReceiveCallbackIncludeSend = false,
    bool regardImportMessagesAsRead = false,
    bool workPathCopiable = false,
    String? loginExtension,
  }) : this._(
          appKey: appKey,
          autoLogin: autoLogin,
          debugMode: debugMode,
          acceptInvitationAlways: acceptInvitationAlways,
          autoAcceptGroupInvitation: autoAcceptGroupInvitation,
          requireAck: requireAck,
          requireDeliveryAck: requireDeliveryAck,
          deleteMessagesAsExitGroup: deleteMessagesAsExitGroup,
          deleteMessagesAsExitChatRoom: deleteMessagesAsExitChatRoom,
          isChatRoomOwnerLeaveAllowed: isChatRoomOwnerLeaveAllowed,
          sortMessageByServerTime: sortMessageByServerTime,
          usingHttpsOnly: usingHttpsOnly,
          serverTransfer: serverTransfer,
          isAutoDownloadThumbnail: isAutoDownloadThumbnail,
          enableDNSConfig: enableDNSConfig,
          dnsUrl: dnsUrl,
          restServer: restServer,
          imPort: imPort,
          imServer: imServer,
          chatAreaCode: chatAreaCode ?? ChatAreaCode.GLOB,
          enableEmptyConversation: enableEmptyConversation,
          deviceName: deviceName,
          osType: osType,
          useReplacedMessageContents: useReplacedMessageContents,
          enableTLS: enableTLS,
          messagesReceiveCallbackIncludeSend:
              messagesReceiveCallbackIncludeSend,
          regardImportMessagesAsRead: regardImportMessagesAsRead,
          workPathCopiable: workPathCopiable,
          loginExtension: loginExtension,
        );

  EMOptions._({
    this.appId,
    this.appKey,
    this.autoLogin = true,
    this.debugMode = false,
    this.acceptInvitationAlways = false,
    this.autoAcceptGroupInvitation = false,
    this.requireAck = true,
    this.requireDeliveryAck = false,
    this.deleteMessagesAsExitGroup = true,
    this.deleteMessagesAsExitChatRoom = true,
    this.isChatRoomOwnerLeaveAllowed = true,
    this.sortMessageByServerTime = true,
    this.usingHttpsOnly = true,
    this.serverTransfer = true,
    this.isAutoDownloadThumbnail = true,
    this.enableDNSConfig = true,
    this.dnsUrl,
    this.restServer,
    this.imPort,
    this.imServer,
    this.chatAreaCode = ChatAreaCode.GLOB,
    this.enableEmptyConversation = false,
    this.deviceName,
    this.osType,
    this.useReplacedMessageContents = false,
    this.enableTLS = false,
    this.messagesReceiveCallbackIncludeSend = false,
    this.regardImportMessagesAsRead = false,
    this.workPathCopiable = false,
    this.loginExtension,
  });

  Map toJson() {
    Map data = new Map();
    data.putIfNotNull("appKey", appKey);
    data.putIfNotNull("appId", appId);
    data.putIfNotNull("autoLogin", autoLogin);
    data.putIfNotNull("debugModel", debugMode);
    data.putIfNotNull("acceptInvitationAlways", acceptInvitationAlways);
    data.putIfNotNull(
      "autoAcceptGroupInvitation",
      autoAcceptGroupInvitation,
    );
    data.putIfNotNull("deleteMessagesAsExitGroup", deleteMessagesAsExitGroup);
    data.putIfNotNull(
        "deleteMessagesAsExitChatRoom", deleteMessagesAsExitChatRoom);
    data.putIfNotNull("dnsUrl", dnsUrl);
    data.putIfNotNull("enableDNSConfig", enableDNSConfig);
    data.putIfNotNull("imPort", imPort);
    data.putIfNotNull("imServer", imServer);
    data.putIfNotNull("isAutoDownload", isAutoDownloadThumbnail);
    data.putIfNotNull(
        "isChatRoomOwnerLeaveAllowed", isChatRoomOwnerLeaveAllowed);
    data.putIfNotNull("requireAck", requireAck);
    data.putIfNotNull("requireDeliveryAck", requireDeliveryAck);
    data.putIfNotNull("restServer", restServer);
    data.putIfNotNull("serverTransfer", serverTransfer);
    data.putIfNotNull("sortMessageByServerTime", sortMessageByServerTime);
    data.putIfNotNull("usingHttpsOnly", usingHttpsOnly);
    data.putIfNotNull('loadEmptyConversations', enableEmptyConversation);
    data.putIfNotNull('deviceName', deviceName);
    data.putIfNotNull('osType', osType);
    data.putIfNotNull('useReplacedMessageContents', useReplacedMessageContents);
    data.putIfNotNull('enableTLS', enableTLS);
    data.putIfNotNull('messagesReceiveCallbackIncludeSend',
        messagesReceiveCallbackIncludeSend);
    data.putIfNotNull('regardImportMessagesAsRead', regardImportMessagesAsRead);

    data["usingHttpsOnly"] = this.usingHttpsOnly;
    data["pushConfig"] = this._pushConfig.toJson();
    data["areaCode"] = this.chatAreaCode;

    // 481
    data.putIfNotNull('loginExtensionInfo', loginExtension);

    // 4.10
    data.putIfNotNull('workPathCopiable', workPathCopiable);

    return data;
  }

  @override
  String toString() {
    return toJson().toString();
  }

  // 481

  /// ~english
  /// The extended information carried during login can be a JSON string. The current string length is limited to 1024 characters.
  /// ~end
  ///
  /// ~chinese
  /// 登录时携带的扩展信息，可以是JSON 字符串，目前字符串长度 底层限制长度1024
  /// ~end
  final String? loginExtension;

  EMOptions copyWith({
    bool? usingHttpsOnly,
    String? loginExtension,
    bool? deleteMessageWhenLeaveRoom,
    bool? deleteMessagesWhenLeaveGroup,
    bool? roomOwnerCanLeave,
    bool? autoAcceptGroupInvitation,
    bool? acceptInvitationAlways,
    bool? autoDownloadThumbnail,
    bool? requireDeliveryAck,
    bool? requireAck,
    bool? sortMessageByServerTime,
    bool? messagesReceiveCallbackIncludeSend,
    bool? regardImportMessagesAsRead,
  }) {
    return EMOptions._(
      appKey: appKey,
      appId: appId,
      autoLogin: autoLogin,
      debugMode: debugMode,
      acceptInvitationAlways:
          acceptInvitationAlways ?? this.acceptInvitationAlways,
      autoAcceptGroupInvitation:
          autoAcceptGroupInvitation ?? this.autoAcceptGroupInvitation,
      requireAck: requireAck ?? this.requireAck,
      requireDeliveryAck: requireDeliveryAck ?? this.requireDeliveryAck,
      deleteMessagesAsExitGroup:
          deleteMessagesWhenLeaveGroup ?? this.deleteMessagesAsExitGroup,
      deleteMessagesAsExitChatRoom:
          deleteMessageWhenLeaveRoom ?? this.deleteMessagesAsExitChatRoom,
      isChatRoomOwnerLeaveAllowed:
          roomOwnerCanLeave ?? this.isChatRoomOwnerLeaveAllowed,
      sortMessageByServerTime:
          sortMessageByServerTime ?? this.sortMessageByServerTime,
      usingHttpsOnly: usingHttpsOnly ?? this.usingHttpsOnly,
      serverTransfer: serverTransfer,
      isAutoDownloadThumbnail:
          autoDownloadThumbnail ?? this.isAutoDownloadThumbnail,
      enableDNSConfig: enableDNSConfig,
      dnsUrl: dnsUrl,
      restServer: restServer,
      imPort: imPort,
      imServer: imServer,
      chatAreaCode: chatAreaCode,
      enableEmptyConversation: enableEmptyConversation,
      deviceName: deviceName,
      osType: osType,
      useReplacedMessageContents: useReplacedMessageContents,
      enableTLS: enableTLS,
      messagesReceiveCallbackIncludeSend: messagesReceiveCallbackIncludeSend ??
          this.messagesReceiveCallbackIncludeSend,
      regardImportMessagesAsRead:
          regardImportMessagesAsRead ?? this.regardImportMessagesAsRead,
      loginExtension: loginExtension,
    );
  }
}
