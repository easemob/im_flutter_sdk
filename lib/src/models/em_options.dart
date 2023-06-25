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
  final String appKey;

  /// ~english
  /// Whether to enable automatic login.
  ///
  /// - `true`: (Default) Yes;
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
  /// - `false`: (Default)No.
  /// ~end
  ///
  /// ~chinese
  /// 是否输出调试信息，在 EMClient 初始化完成后调用，详见 {@link #init(Context, EMOptions)}。
  /// - `true`：SDK 会在 log 里输出调试信息；
  /// - （默认）`false`：不会输出调试信息。
  /// ~end
  final bool debugModel;

  /// ~english
  /// Whether to accept friend invitations from other users automatically.
  ///
  /// - `true`: (Default) Yes;
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
  /// - `true`: (Default) Yes;
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
  /// - `true`: (Default) Yes;
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
  /// - `false`: (Default) No.
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
  /// - `true`: (Default) Yes;
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
  /// - `true`: (Default) Yes;
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
  /// - `true`: (Default) Yes;
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
  /// - `true`: (Default) Yes;
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
  /// - `true`: (Default) Only HTTPS is used.
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
  /// - `true`: (Default) Yes;
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
  /// - `true`: (Default) Yes;
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
  /// - `true`: (Default) Yes;
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
  /// - `false`: (Default) No.
  /// ~end
  ///
  /// ~chinese
  /// 是否使用自定义 IM 服务的端口。用于私有化部署。
  /// ~end
  final bool enableEmptyConversation;

  EMPushConfig _pushConfig = EMPushConfig();

  /// ~english
  /// Enable OPPO PUSH on OPPO devices.
  ///
  /// Param [appKey] The app id for OPPO PUSH.
  ///
  /// Param [secret] The app secret for OPPO PUSH.
  /// ~end
  ///
  /// ~chinese
  /// 开启 Oppo 推送。
  ///
  /// Param [appId] Oppo 推送的 App ID。
  ///
  /// Param [appKey] Oppo 推送的 app key。
  /// ~end
  void enableOppoPush(String appKey, String secret) {
    _pushConfig.enableOppoPush = true;
    _pushConfig.oppoAppKey = appKey;
    _pushConfig.oppoAppSecret = secret;
  }

  /// ~english
  /// Enable Mi Push on Mi devices.
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

  /// ~english
  /// Enable MeiZu Push on MeiZu devices.
  /// Param [appId] The app ID for MeiZu Push.
  /// Param [appKey] The app key for MeiZu Push.
  /// ~end
  ///
  /// ~chinese
  /// 开启魅族推送.
  /// Param [appId] 魅族AppId.
  /// Param [appKey] 魅族Appkey.
  /// ~end
  void enableMeiZuPush(String appId, String appKey) {
    _pushConfig.mzAppId = appId;
    _pushConfig.mzAppKey = appKey;
  }

  /// ~english
  /// Enable Firebase Cloud Messaging (FCM) push on devices that support Google Play.
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

  /// ~english
  /// Enable vivo Push on vivo devices.
  /// ~end
  ///
  /// ~chinese
  /// 开启 vivo 推送。
  /// ~end
  void enableVivoPush() {
    _pushConfig.enableVivoPush = true;
  }

  /// ~english
  /// Enable Huawei Push on Huawei devices.
  /// ~end
  ///
  /// ~chinese
  /// 开启华为推送。
  /// ~end
  void enableHWPush() {
    _pushConfig.enableHWPush = true;
  }

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

  /// ~english
  /// Sets the app options.
  ///
  /// Param [appKey] The app key that you get from the console when creating an app.
  ///
  /// Param [autoLogin] Whether to enable automatic login.
  ///
  /// Param [debugModel] Whether to output the debug information. Make sure to call the method after the EMClient is initialized. See [EMClient.init].
  ///
  /// Param [acceptInvitationAlways] Whether to accept friend invitations from other users automatically.
  ///
  /// Param [autoAcceptGroupInvitation] Whether to accept group invitations automatically.
  ///
  /// Param [requireAck] Whether the read receipt is required.
  ///
  /// Param [requireDeliveryAck] Whether the delivery receipt is required.
  ///
  /// Param [deleteMessagesAsExitGroup] Whether to delete the related group messages when leaving a group.
  ///
  /// Param [deleteMessagesAsExitChatRoom] Whether to delete the related chat room messages when leaving the chat room.
  ///
  /// Param [isChatRoomOwnerLeaveAllowed] Whether to allow the chat room owner to leave the chat room.
  ///
  /// Param [sortMessageByServerTime] Whether to sort the messages by the time the server receives messages.
  ///
  /// Param [usingHttpsOnly] Whether only HTTPS is used for REST operations.
  ///
  /// Param [serverTransfer] Whether to upload the message attachments automatically to the chat server.
  ///
  /// Param [isAutoDownloadThumbnail] Whether to automatically download the thumbnail.
  ///
  /// Param [enableDNSConfig] Whether to enable DNS.
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
  /// Param [debugModel] 是否输出调试信息，在 EMClient 初始化完成后调用，详见 {@link #init(Context, EMOptions)}。
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
  ///
  /// ~end
  EMOptions({
    required this.appKey,
    this.autoLogin = true,
    this.debugModel = false,
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
  });

  /// @nodoc
  Map toJson() {
    Map data = new Map();
    data.putIfNotNull("appKey", appKey);
    data.putIfNotNull("autoLogin", autoLogin);
    data.putIfNotNull("debugModel", debugModel);
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

    data["usingHttpsOnly"] = this.usingHttpsOnly;
    data["pushConfig"] = this._pushConfig.toJson();
    data["areaCode"] = this.chatAreaCode;
    return data;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
