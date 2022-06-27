import '../internal/inner_headers.dart';

///
/// 提供 SDK 聊天相关的设置。
/// 用户可以用来配置 SDK 的各种参数、选项，
/// 比如，发送消息加密，是否自动接受加好友邀请。
///
class EMOptions {
  /// 创建 app 时在 console 后台上注册的 app 唯一识别符。
  late final String appKey;

  ///
  /// 是否允许自动登录。
  ///
  /// - (默认) `true`: (默认) 允许;
  /// - `false`: 不允许.
  ///
  final bool autoLogin;

  /// 是否输出调试信息，在 EMClient 初始化完成后调用，详见 {@link #init(Context, EMOptions)}。
  /// - `true`：SDK 会在 log 里输出调试信息；
  /// - （默认）`false`：不会输出调试信息。
  ///
  final bool debugModel;

  ///
  /// 是否自动接受加好友邀请。
  /// - `true`：是。
  /// - （默认）`false`：否。
  ///
  final bool acceptInvitationAlways;

  ///
  /// 是否自动接受群组邀请。
  /// - `true`：是；
  /// - （默认）`false`：否。
  ///
  final bool autoAcceptGroupInvitation;

  ///
  /// 是否发送消息已读回执.
  /// - （默认）`true`：是；
  /// - `false`：否。
  ///
  final bool requireAck;

  ///
  /// 是否发送消息已送达回执。
  /// - `true`：是。
  /// - （默认）`false`：否。
  ///
  final bool requireDeliveryAck;

  ///
  /// 离开群组时是否删除消息。
  /// - （默认）`true`：是；
  /// - `false`：否。
  ///
  final bool deleteMessagesAsExitGroup;

  ///
  /// 离开聊天室时是否删除消息。
  ///
  /// - （默认）`true`：是；
  /// - `false`：否。
  ///
  final bool deleteMessagesAsExitChatRoom;

  ///
  /// 是否允许聊天室所有者离开聊天室。
  ///
  /// - （默认）`true`：是；
  /// - `false`：否。
  ///
  final bool isChatRoomOwnerLeaveAllowed;

  ///
  /// 是否根据服务器收到消息的时间对消息进行排序。
  ///
  /// - （默认）`true`：是；
  /// - `false`：否。
  ///
  final bool sortMessageByServerTime;

  ///
  /// 是否只用 HTTPS。
  ///
  /// - （默认）`true`：是；
  /// - `false`：否。可以同时用 HTTP 和 HTTPS。
  ///
  final bool usingHttpsOnly;

  ///
  /// 是否自动将消息附件上传到聊天服务器。
  ///
  /// - （默认）`true`：是；
  /// - `false`：否。使用自定义路径。
  ///
  final bool serverTransfer;

  ///
  /// 是否自动下载缩略图。
  ///
  /// - （默认）`true`：是；
  /// - `false`：否。
  ///
  final bool isAutoDownloadThumbnail;

  ///
  /// 是否开启 DNS。
  ///
  /// - （默认）`true`：是；
  /// - `false`：否。
  ///
  final bool enableDNSConfig;

  /// DNS 地址。
  final String? dnsUrl;

  /// REST 服务器。
  final String? restServer;

  /// 消息服务器。
  final String? imServer;

  /// 是否使用自定义 IM 服务的端口。用于私有化部署。.
  final int? imPort;

  EMPushConfig _pushConfig = EMPushConfig();

  /// 开启 Oppo 推送。
  ///
  /// Param [appId] Oppo 推送的 App ID。
  ///
  /// Param [appKey] Oppo 推送的 app key。
  ///
  void enableOppoPush(String appKey, String secret) {
    _pushConfig.enableOppoPush = true;
    _pushConfig.oppoAppKey = appKey;
    _pushConfig.oppoAppSecret = secret;
  }

  ///
  /// 开启小米推送。
  ///
  /// Param [appId] 小米推送的 App ID。
  ///
  /// Param [appKey] 小米推送的 app key。
  ///
  void enableMiPush(String appId, String appKey) {
    _pushConfig.enableMiPush = true;
    _pushConfig.miAppId = appId;
    _pushConfig.miAppKey = appKey;
  }

  ///
  /// 开启 FCM（GCM 的升级版）推送。
  ///
  /// Param [appId] FCM 推送的 App ID。
  ///
  void enableFCM(String appId) {
    _pushConfig.enableFCM = true;
    _pushConfig.fcmId = appId;
  }

  ///
  /// 开启 vivo 推送。
  ///
  void enableVivoPush() {
    _pushConfig.enableVivoPush = true;
  }

  ///
  /// 开启华为推送。
  ///
  void enableHWPush() {
    _pushConfig.enableHWPush = true;
  }

  ///
  /// 开启 Apple 推送通知服务（APNs）推送。
  ///
  /// Param [certName] APNs 推送证书的名称。
  ///
  void enableAPNs(String certName) {
    _pushConfig.enableAPNS = true;
    _pushConfig.apnsCertName = certName;
  }

  ///
  /// 创建EMOptions
  ///
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
  });

  /// @nodoc
  factory EMOptions.fromJson(Map<String, dynamic> json) {
    var ret = EMOptions(
      appKey: json['appKey'],
      autoLogin: json.boolValue('autoLogin'),
      debugModel: json.boolValue('debugModel'),
      requireAck: json.boolValue('requireAck'),
      requireDeliveryAck: json.boolValue('requireDeliveryAck'),
      sortMessageByServerTime: json.boolValue('sortMessageByServerTime'),
      acceptInvitationAlways: json.boolValue('acceptInvitationAlways'),
      autoAcceptGroupInvitation: json.boolValue('autoAcceptGroupInvitation'),
      deleteMessagesAsExitGroup: json.boolValue('deleteMessagesAsExitGroup'),
      deleteMessagesAsExitChatRoom:
          json.boolValue('deleteMessagesAsExitChatRoom'),
      isAutoDownloadThumbnail: json.boolValue('isAutoDownload'),
      isChatRoomOwnerLeaveAllowed:
          json.boolValue('isChatRoomOwnerLeaveAllowed'),
      serverTransfer: json.boolValue('serverTransfer'),
      usingHttpsOnly: json.boolValue('usingHttpsOnly'),
      enableDNSConfig: json.boolValue('enableDNSConfig'),
      imPort: json.intValue("imPort"),
      imServer: json.stringValue("imServer"),
      restServer: json.stringValue("restServer"),
      dnsUrl: json.stringValue("dnsUrl"),
    );

    ret._pushConfig = EMPushConfig();
    if (json['pushConfig'] != null) {
      ret._pushConfig.updateFromJson(json);
    }

    return ret;
  }

  /// @nodoc
  Map toJson() {
    Map data = new Map();
    data.setValueWithOutNull("appKey", appKey);
    data.setValueWithOutNull("autoLogin", autoLogin);
    data.setValueWithOutNull("debugModel", debugModel);
    data.setValueWithOutNull("acceptInvitationAlways", acceptInvitationAlways);
    data.setValueWithOutNull(
      "autoAcceptGroupInvitation",
      autoAcceptGroupInvitation,
    );
    data.setValueWithOutNull(
        "deleteMessagesAsExitGroup", deleteMessagesAsExitGroup);
    data.setValueWithOutNull(
        "deleteMessagesAsExitChatRoom", deleteMessagesAsExitChatRoom);
    data.setValueWithOutNull("dnsUrl", dnsUrl);
    data.setValueWithOutNull("enableDNSConfig", enableDNSConfig);
    data.setValueWithOutNull("imPort", imPort);
    data.setValueWithOutNull("imServer", imServer);
    data.setValueWithOutNull("isAutoDownload", isAutoDownloadThumbnail);
    data.setValueWithOutNull(
        "isChatRoomOwnerLeaveAllowed", isChatRoomOwnerLeaveAllowed);
    data.setValueWithOutNull("requireAck", requireAck);
    data.setValueWithOutNull("requireDeliveryAck", requireDeliveryAck);
    data.setValueWithOutNull("restServer", restServer);
    data.setValueWithOutNull("serverTransfer", serverTransfer);
    data.setValueWithOutNull(
        "sortMessageByServerTime", sortMessageByServerTime);
    data.setValueWithOutNull("usingHttpsOnly", usingHttpsOnly);

    data["usingHttpsOnly"] = this.usingHttpsOnly;
    data["pushConfig"] = this._pushConfig.toJson();
    return data;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
