import '../tools/em_extension.dart';
import 'em_push_config.dart';

///
/// The settings of the chat SDK.
/// You can set parameters and options of the SDK.
/// For example, whether to encrypt the messages before sending, whether to automatically accept the friend invitations.
///
class EMOptions {
  /// The app key you got from the console when create an app.
  late final String appKey;

  ///
  /// Enables/Disables automatic login.
  ///
  /// `true`: (default) Enables automatic login;
  /// `false`: Disables automatic login.
  ///
  final bool autoLogin;

  final bool debugModel;

  ///
  /// Whether to accept friend invitations from other users automatically.
  ///
  /// `true`: (default) Accepts friend invitations automatically;
  /// `false`: Do not accept friend invitations automatically.
  final bool acceptInvitationAlways;

  ///
  /// Whether to accept group invitations automatically.
  ///
  /// `true`: (default) Accepts group invitations automatically;
  /// `false`: Do not accept group invitations automatically.
  ///
  final bool autoAcceptGroupInvitation;

  ///
  /// Whether the read receipt is required.
  ///
  /// `true`: (default) The read receipt is required;
  /// `false`: The read receipt is not required.
  ///
  final bool requireAck;

  ///
  /// Whether the delivery receipt is required.
  ///
  /// `true`: (default) The read receipt is required;
  /// `false`: The read receipt is not required.
  ///
  final bool requireDeliveryAck;

  ///
  /// Whether to delete the group message when leaving a group.
  ///
  /// `true`: (default) Delete the messages when leaving the group.
  /// `false`: Do not delete the messages when leaving a group.
  ///
  final bool deleteMessagesAsExitGroup;

  ///
  /// Whether to delete the chat room message when leaving the chat room.
  ///
  /// `true`: (default) Delete the chat room related message record when leaving the chat room.
  /// `false`: Do not delete the chat room related message record when leaving the chat room.
  ///
  final bool deleteMessagesAsExitChatRoom;

  ///
  /// Whether to allow the chat room owner to leave the chat room.
  ///
  /// `true`: (default) Allow the chat room owner to leave the chat room.
  /// `false`: Do not allow the chat room owner to leave the chat room.
  ///
  final bool isChatRoomOwnerLeaveAllowed;

  ///
  /// Whether to sort messages by the server received time.
  ///
  /// `true`: (default) Sort messages by the server received time;
  /// `false`: Do not sort messages by the server received time.
  ///
  final bool sortMessageByServerTime;

  ///
  /// Sets whether only HTTPS is used for REST operations.
  ///
  /// `true`: (default) Only HTTPS is used.
  /// `false`: Allow to use both HTTP and HTTPS.
  ///
  final bool usingHttpsOnly;

  ///
  /// Whether to upload the message attachments automatically to the chat server.
  ///
  /// `true`: (default) Use the default way to upload and download the message attachments by chat server;
  /// `false`: Do not use the default way to upload and download the message attachments by chat server, using a customized path instead.
  ///
  final bool serverTransfer;

  ///
  /// Whether to auto download the thumbnail.
  ///
  /// `true`: (default) Download the thumbnail automatically;
  /// `false`: Do not download the thumbnail automatically.
  ///
  final bool isAutoDownloadThumbnail;

  ///
  /// Sets whether to disable DNS.
  ///
  ///
  /// `true`: (default) Disable DNS;
  /// `false`: Do not disable DNS.
  final bool enableDNSConfig;

  /// The DNS url.
  final String? dnsUrl;

  /// The custom REST server.
  final String? restServer;

  /// The custom im message server url.
  final String? imServer;

  /// The custom im server port.
  final int? imPort;

  EMPushConfig _pushConfig = EMPushConfig();

  ///
  void enableOppoPush(String appKey, String secret) {
    _pushConfig.enableOppoPush = true;
    _pushConfig.oppoAppKey = appKey;
    _pushConfig.oppoAppSecret = secret;
  }

  ///
  /// Passes the app ID and app key of Mi push to enable Mi push on Mi devices.
  ///
  /// Param [appId] The Xiaomi Push App ID.
  ///
  /// Param [appKey] The Xiaomi push app key.
  ///
  void enableMiPush(String appId, String appKey) {
    _pushConfig.enableMiPush = true;
    _pushConfig.miAppId = appId;
    _pushConfig.miAppKey = appKey;
  }

  ///
  /// Sets the FCM sender ID.
  ///
  void enableFCM(String appId) {
    _pushConfig.enableFCM = true;
    _pushConfig.fcmId = appId;
  }

  ///
  /// Be sure to set the app ID and app key in AndroidManifest in order to make Vivo push available on Vivo devices.
  ///
  void enableVivoPush() {
    _pushConfig.enableVivoPush = true;
  }

  ///
  /// Enables Huawei push on Huawei devices.
  ///
  /// Be sure to set app ID in AndroidManifest or to set agconnect-services.json.
  ///
  void enableHWPush() {
    _pushConfig.enableHWPush = true;
  }

  ///
  /// Enables ios push on ios devices.
  ///
  /// Param [certName] The ios device push cert name.
  void enableAPNs(String certName) {
    _pushConfig.enableAPNS = true;
    _pushConfig.apnsCertName = certName;
  }

  ///
  /// Sets the app options.
  ///
  /// Param [appKey] The app key you got from the console when create an app.
  ///
  /// Param [autoLogin] Enables/Disables automatic login. default is `true`.
  ///
  /// Param [debugModel]
  ///
  /// Param [acceptInvitationAlways] Whether to accept friend invitations from other users automatically. default is `false`.
  ///
  /// Param [autoAcceptGroupInvitation] Whether to accept group invitations automatically. default is `false`.
  ///
  /// Param [requireAck] Whether the read receipt is required. default is `true`.
  ///
  /// Param [requireDeliveryAck] Whether the delivery receipt is required. default is `true`.
  ///
  /// Param [deleteMessagesAsExitGroup] Whether to delete the group message when leaving a group. default is `true`.
  ///
  /// Param [deleteMessagesAsExitChatRoom] Whether to delete the chat room message when leaving the chat room. default is `true`.
  ///
  /// Param [isChatRoomOwnerLeaveAllowed] Whether to allow the chat room owner to leave the chat room. default is `true`.
  ///
  /// Param [sortMessageByServerTime] Whether to sort messages by the server received time. default is `true`.
  ///
  /// Param [usingHttpsOnly] Sets whether only HTTPS is used for REST operations. default is `true`.
  ///
  /// Param [serverTransfer] Whether to upload the message attachments automatically to the chat server. default is `true`.
  ///
  /// Param [isAutoDownloadThumbnail] Whether to auto download the thumbnail. default is `true`.
  ///
  /// Param [enableDNSConfig] Sets whether to disable DNS.
  ///
  /// Param [dnsUrl] The DNS url.
  ///
  /// Param [restServer] The custom REST server.
  ///
  /// Param [imPort] The custom im server port.
  ///
  /// Param [imServer] The custom im message server url.
  ///
  ///
  EMOptions(
      {required this.appKey,
      this.autoLogin = true,
      this.debugModel = false,
      this.acceptInvitationAlways = false,
      this.autoAcceptGroupInvitation = false,
      this.requireAck = false,
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
      this.imServer});

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

    data['sortMessageByServerTime'] = this.sortMessageByServerTime;
    data['usingHttpsOnly'] = this.usingHttpsOnly;
    data['pushConfig'] = this._pushConfig.toJson();
    return data;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
