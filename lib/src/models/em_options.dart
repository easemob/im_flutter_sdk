import 'package:flutter/foundation.dart';
import 'em_domain_terms.dart';

class EMOptions {

  /// 环信 appKey
  String appKey = '';
  bool autoLogin = true;
  bool debugModel = false;

  bool acceptInvitationAlways = true;
  bool autoAcceptGroupInvitation = true;
  bool requireAck = true;
  bool requireDeliveryAck = false;
  bool deleteMessagesAsExitGroup = true;
  bool deleteMessagesAsExitChatRoom = true;
  bool isChatRoomOwnerLeaveAllowed = true;
  bool sortMessageByServerTime = true;

  bool usingHttpsOnly = false;
  bool serverTransfer = true;
  bool isAutoDownload = true;

  EMPushConfig pushConfig;

  bool enableDNSConfig = true;
  String dnsUrl = '';
  String restServer = '';
  String imServer = '';
  int imPort = 0;

  EMOptions({
    @required this.appKey
  });

  /// 设置自定义server地址
  void customServerInfo({
    @required String customRestServer,
    @required String customImServer,
    @required int customImPort,}) {
    restServer = customRestServer;
    imServer= customImServer;
    imPort = customImPort;
    enableDNSConfig = false;
  }

  factory EMOptions.fromJson(Map<String, dynamic> json) {
    return EMOptions(appKey: json['appKey'])
      ..autoLogin = json.boolValue('autoLogin')
      ..debugModel = json.boolValue('debugModel')
      ..requireAck = json.boolValue('requireAck')
      ..requireDeliveryAck = json.boolValue('requireDeliveryAck')
      ..sortMessageByServerTime = json.boolValue('sortMessageByServerTime')
      ..acceptInvitationAlways = json.boolValue('acceptInvitationAlways')
      ..autoAcceptGroupInvitation = json.boolValue('autoAcceptGroupInvitation')
      ..deleteMessagesAsExitGroup = json.boolValue('deleteMessagesAsExitGroup')
      ..deleteMessagesAsExitChatRoom = json.boolValue('deleteMessagesAsExitChatRoom')
      ..isAutoDownload = json.boolValue('isAutoDownload')
      ..isChatRoomOwnerLeaveAllowed = json.boolValue('isChatRoomOwnerLeaveAllowed')
      ..serverTransfer = json.boolValue('serverTransfer')
      ..usingHttpsOnly = json.boolValue('usingHttpsOnly')
      ..pushConfig = json['pushConfig'] != null ? EMPushConfig.fromJson(json['pushConfig']) : null

      ..enableDNSConfig = json.boolValue('enableDNSConfig')
      ..imPort = json['imPort']
      ..imServer = json['imServer']
      ..restServer = json['restServer']
      ..dnsUrl = json['dnsUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['appKey'] = this.appKey;
    data['autoLogin'] = this.autoLogin;
    data['debugModel'] = this.debugModel;
    data['acceptInvitationAlways'] = this.acceptInvitationAlways;
    data['autoAcceptGroupInvitation'] = this.autoAcceptGroupInvitation;
    data['deleteMessagesAsExitGroup'] = this.deleteMessagesAsExitGroup;
    data['deleteMessagesAsExitChatRoom'] = this.deleteMessagesAsExitChatRoom;
    data['dnsUrl'] = this.dnsUrl;
    data['enableDNSConfig'] = this.enableDNSConfig;
    data['imPort'] = this.imPort;
    data['imServer'] = this.imServer;
    data['isAutoDownload'] = this.isAutoDownload;
    data['isChatRoomOwnerLeaveAllowed'] = this.isChatRoomOwnerLeaveAllowed;
    data['requireAck'] = this.requireAck;
    data['requireDeliveryAck'] = this.requireDeliveryAck;
    data['restServer'] = this.restServer;
    data['serverTransfer'] = this.serverTransfer;
    data['sortMessageByServerTime'] = this.sortMessageByServerTime;
    data['usingHttpsOnly'] = this.usingHttpsOnly;
    if (this.pushConfig != null) {
      data['pushConfig'] = this.pushConfig.toJson();
    }
    return data;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}

class EMPushConfig {

  String _mzAppId = '';
  String _mzAppKey = '';

  String _oppoAppKey = '';
  String _oppoAppSecret = '';

  String _miAppId = '';
  String _miAppKey = '';

  String _fcmId = '';

  String _apnsCertName = '';

  bool _enableMeiZuPush = false;
  bool _enableOppoPush = false;
  bool _enableMiPush = false;

  bool _enableFCM = false;

  bool _enableVivoPush = false;
  bool _enableHWPush = false;

  bool _enableAPNS = false;

  /// 开启魅族推送 [appId]: 推送用AppId, [appKey]: 推送用AppKey
  void enableMeiZuPush(String appId, String appKey) {
    _enableMeiZuPush = true;
    _mzAppId = appId;
    _mzAppKey = appKey;
  }

  void enableOppPush(String appKey, String secret) {
    _enableOppoPush = true;
    _oppoAppKey = appKey;
    _oppoAppSecret = secret;
  }

  void enableMiPush(String appId, String appKey) {
    _enableMiPush = true;
    _miAppId = appId;
    _miAppKey = appKey;
  }

  void enableFCM(String appId) {
    _enableFCM = true;
    _fcmId = appId;
  }

  void enableVivoPush() {
    _enableVivoPush = true;
  }

  void enableHWPush() {
    _enableHWPush = true;
  }

  void enableAPNs(String certName) {
    _enableAPNS = true;
    _apnsCertName = certName;
  }

  EMPushConfig();

  EMPushConfig._private();

  factory EMPushConfig.fromJson(Map<String, dynamic> json) {

    return EMPushConfig._private()
      .._mzAppId = json['mzAppId']
      .._mzAppKey = json['mzAppKey']
      .._oppoAppKey = json['oppoAppKey']
      .._oppoAppSecret = json['oppoAppSecret']
      .._miAppId = json['miAppId']
      .._miAppKey = json['miAppKey']
      .._fcmId = json['fcmId']
      .._apnsCertName = json['apnsCertName']

      .._enableMeiZuPush = json.boolValue('enableMeiZuPush')
      .._enableOppoPush = json.boolValue('enableOppoPush')
      .._enableMiPush = json.boolValue('enableMiPush')
      .._enableFCM = json.boolValue('enableFCM')
      .._enableVivoPush = json.boolValue('enableVivoPush')
      .._enableHWPush = json.boolValue('enableHWPush')
      .._enableAPNS = json.boolValue('enableAPNS');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['mzAppId'] = this._mzAppId;
    data['mzAppKey'] = this._mzAppKey;

    data['oppoAppKey'] = this._oppoAppKey;
    data['oppoAppSecret'] = this._oppoAppSecret;

    data['miAppId'] = this._miAppId;
    data['miAppKey'] = this._miAppKey;

    data['fcmId'] = this._fcmId;

    data['apnsCertName'] = this._apnsCertName;

    data['enableMeiZuPush'] = this._enableMeiZuPush;
    data['enableOppoPush'] = this._enableOppoPush;
    data['enableMiPush'] = this._enableMiPush;

    data['enableFCM'] = this._enableFCM;

    data['enableHWPush'] = this._enableHWPush;
    data['enableVivoPush'] = this._enableVivoPush;

    data['enableAPNS'] = this._enableAPNS;

    return data;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}