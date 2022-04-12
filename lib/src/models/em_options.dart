import '../tools/em_extension.dart';
import '../internal/em_push_config.dart';

///
/// The EMOptions class, which contains the settings of the Chat SDK.
///
/// For example, whether to encrypt the messages before sending and whether to automatically accept the friend invitations.
///
class EMOptions {
  /// The app key that you get from the console when creating the app.
  late final String appKey;

  ///
  /// Whether to enable automatic login.
  ///
  /// - `true`: (Default) Yes;
  /// - `false`: No.
  ///
  final bool autoLogin;

  ///
  /// Whether to output the debug information. Make sure to call the method after initializing the EMClient using {@link #init(Context, EMOptions)}.
  ///
  /// - `true`: Yes.
  /// - `false`: (Default)No.
  ///
  final bool debugModel;

  ///
  /// Whether to accept friend invitations from other users automatically.
  ///
  /// - `true`: (Default) Yes;
  /// - `false`: No.
  final bool acceptInvitationAlways;

  ///
  /// Whether to accept group invitations automatically.
  ///
  /// - `true`: (Default) Yes;
  /// - `false`: No.
  ///
  final bool autoAcceptGroupInvitation;

  ///
  /// Whether to require read receipt after sending a message.
  ///
  /// - `true`: (Default) Yes;
  /// - `false`: No.
  ///
  final bool requireAck;

  ///
  /// Whether to require the delivery receipt after sending a message.
  ///
  /// - `true`: (Default) Yes;
  /// - `false`: No.
  ///
  final bool requireDeliveryAck;

  ///
  /// Whether to delete the group messages when leaving a group.
  ///
  /// - `true`: (Default) Yes;
  /// - `false`: No.
  ///
  final bool deleteMessagesAsExitGroup;

  ///
  /// Whether to delete the chat room messages when leaving the chat room.
  ///
  /// - `true`: (Default) Yes;
  /// - `false`: No.
  ///
  final bool deleteMessagesAsExitChatRoom;

  ///
  /// Whether to allow the chat room owner to leave the chat room.
  ///
  /// - `true`: (Default) Yes;
  /// - `false`: No.
  ///
  final bool isChatRoomOwnerLeaveAllowed;

  ///
  /// Whether to sort the messages by the time when the messages are received by the server.
  ///
  /// - `true`: (Default) Yes;
  /// - `false`: No.
  ///
  final bool sortMessageByServerTime;

  ///
  /// Whether only HTTPS is used for REST operations.
  ///
  /// - `true`: (Default) Only HTTPS is used.
  /// - `false`: Both HTTP and HTTPS are allowed.
  ///
  final bool usingHttpsOnly;

  ///
  /// Whether to upload the message attachments automatically to the chat server.
  ///
  /// - `true`: (Default) Yes;
  /// - `false`: No. Message attachments are uploaded to a custom path.
  ///
  final bool serverTransfer;

  ///
  /// Whether to automatically download the thumbnail.
  ///
  /// - `true`: (Default) Yes;
  /// - `false`: No.
  ///
  final bool isAutoDownloadThumbnail;

  ///
  /// Whether to enable DNS.
  ///
  /// - `true`: (Default) Yes;
  /// - `false`: No.
  ///
  final bool enableDNSConfig;

  /// The DNS URL.
  final String? dnsUrl;

  /// The custom REST server.
  final String? restServer;

  /// The custom IM message server url.
  final String? imServer;

  /// The custom IM server port.
  final int? imPort;

  EMPushConfig _pushConfig = EMPushConfig();

  /// Enable OPPO PUSH on OPPO devices.
  ///
  /// Param [appId] The app ID for OPPO PUSH.
  ///
  /// Param [appKey] The app key for OPPO PUSH.
  ///
  void enableOppoPush(String appKey, String secret) {
    _pushConfig.enableOppoPush = true;
    _pushConfig.oppoAppKey = appKey;
    _pushConfig.oppoAppSecret = secret;
  }

  ///
  /// Enable Mi Push on Mi devices.
  ///
  /// Param [appId] The app ID for Mi Push.
  ///
  /// Param [appKey] The app key for Mi Push.
  ///
  void enableMiPush(String appId, String appKey) {
    _pushConfig.enableMiPush = true;
    _pushConfig.miAppId = appId;
    _pushConfig.miAppKey = appKey;
  }

  ///
  /// Enable Firebase Cloud Messaging (FCM) push on devices that support Google Play.
  ///
  /// Param [appId] The app ID for FCM push.
  ///
  void enableFCM(String appId) {
    _pushConfig.enableFCM = true;
    _pushConfig.fcmId = appId;
  }

  /// Enable vivo Push on vivo devices.
  ///
  /// Param [appId] The app ID for vivo Push.
  ///
  /// Param [appKey] The app key for vivo Push.
  ///
  void enableVivoPush() {
    _pushConfig.enableVivoPush = true;
  }

  /// Enable Huawei Push on Huawei devices.
  ///
  /// Param [appId] The app ID for HuaWei Push.
  ///
  /// Param [appKey] The app key for HuaWei Push.
  ///
  void enableHWPush() {
    _pushConfig.enableHWPush = true;
  }

  ///
  /// Enables Apple Push Notification service (APNs) on iOS devices.
  ///
  /// Param [certName] The APNs certificate name.
  void enableAPNs(String certName) {
    _pushConfig.enableAPNS = true;
    _pushConfig.apnsCertName = certName;
  }

  ///
  /// Sets the app options.
  ///
  EMOptions(
      {

      /// Param [appKey] The app key that you get from the console when creating an app.
      required this.appKey,

      /// Param [autoLogin] Whether to enable automatic login.
      /// - `true`: (Default) Yes;
      /// - `false`: No.
      this.autoLogin = true,

      /// Param [debugModel] Whether to output the debug information. Make sure to call the method after the EMClient is initialized. See {@link #init(Context, EMOptions)}.
      /// - `true`: Yes.
      /// - `false`: (Default) No.
      this.debugModel = false,

      /// Param [acceptInvitationAlways] Whether to accept friend invitations from other users automatically.
      /// - `true`: Yes;
      /// - `false`: (Default) No.
      this.acceptInvitationAlways = false,

      /// Param [autoAcceptGroupInvitation] Whether to accept group invitations automatically.
      /// - `true`: Yes;
      /// - `false`: (Default) No.
      this.autoAcceptGroupInvitation = false,

      /// Param [requireAck] Whether the read receipt is required.
      /// - `true`: (Default) Yes;
      /// - `false`: No.
      this.requireAck = true,

      /// Param [requireDeliveryAck] Whether the delivery receipt is required.
      /// - `true`: Yes;
      /// - `false`: (Default) No.
      this.requireDeliveryAck = false,

      /// Param [deleteMessagesAsExitGroup] Whether to delete the related group messages when leaving a group.
      /// - `true`: (Default) Yes;
      /// - `false`: No.
      this.deleteMessagesAsExitGroup = true,

      /// Param [deleteMessagesAsExitChatRoom] Whether to delete the related chat room messages when leaving the chat room.
      /// - `true`: (Default) Yes;
      /// - `false`: No.
      this.deleteMessagesAsExitChatRoom = true,

      /// Param [isChatRoomOwnerLeaveAllowed] Whether to allow the chat room owner to leave the chat room.
      /// - `true`: (Default) Yes;
      /// - `false`: No.
      this.isChatRoomOwnerLeaveAllowed = true,

      /// Param [sortMessageByServerTime] Whether to sort the messages by the time the server receives messages.
      /// - `true`: (Default) Yes;
      /// - `false`: No.
      this.sortMessageByServerTime = true,

      /// Param [usingHttpsOnly] Whether only HTTPS is used for REST operations.
      /// - `true`: (Default) Yes;
      /// - `false`: No.
      this.usingHttpsOnly = true,

      /// Param [serverTransfer] Whether to upload the message attachments automatically to the chat server.
      /// - `true`: (Default) Yes;
      /// - `false`: No.
      this.serverTransfer = true,

      /// Param [isAutoDownloadThumbnail] Whether to automatically download the thumbnail.
      /// - `true`: (Default) Yes;
      /// - `false`: No.
      this.isAutoDownloadThumbnail = true,

      /// Param [enableDNSConfig] Whether to enable DNS.
      /// - `true`: (Default) Yes;
      /// - `false`: No.
      this.enableDNSConfig = true,

      /// Param [dnsUrl] The DNS url.
      this.dnsUrl,

      /// Param [restServer] The REST server for private deployments.
      this.restServer,

      /// Param [imPort] The IM server port for private deployments.
      this.imPort,

      /// Param [imServer] The IM server URL for private deployment.
      this.imServer});

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
