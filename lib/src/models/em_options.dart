import 'package:flutter/material.dart';

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
      ..autoLogin = json['autoLogin']
      ..debugModel = json['debugModel']
      ..requireAck = json['requireAck']
      ..requireDeliveryAck = json['requireDeliveryAck']
      ..sortMessageByServerTime = json['sortMessageByServerTime']
      ..acceptInvitationAlways = json['acceptInvitationAlways']
      ..autoAcceptGroupInvitation = json['autoAcceptGroupInvitation']
      ..deleteMessagesAsExitGroup = json['deleteMessagesAsExitGroup']
      ..isAutoDownload = json['isAutoDownload']
      ..isChatRoomOwnerLeaveAllowed = json['isChatRoomOwnerLeaveAllowed']
      ..serverTransfer = json['serverTransfer']
      ..usingHttpsOnly = json['usingHttpsOnly']
      ..pushConfig = json['pushConfig'] != null ? EMPushConfig.fromJson(json['pushConfig']) : null
      ..enableDNSConfig = json['enableDNSConfig']
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
  EMPushConfig enableMeiZuPush({@required String appId, @required String appKey}) {
    _enableMeiZuPush = true;
    _mzAppId = appId;
    _mzAppKey = appKey;
    return this;
  }

  EMPushConfig enableOppPush({@required String appKey, @required String secret}) {
    _enableOppoPush = true;
    _oppoAppKey = appKey;
    _oppoAppSecret = secret;
    return this;
  }

  EMPushConfig enableMiPush({@required String appId, @required String appKey}) {
    _enableMiPush = true;
    _miAppId = appId;
    _miAppKey = appKey;
    return this;
  }

  EMPushConfig enableFCM({@required String appId}) {
    _enableFCM = true;
    _fcmId = appId;
    return this;
  }

  EMPushConfig enableVivoPush() {
    _enableVivoPush = true;
    return this;
  }

  EMPushConfig enableHWPush() {
    _enableHWPush = true;
    return this;
  }

  EMPushConfig enableAPNs({@required String apnsCertName}) {
    _enableAPNS = true;
    _apnsCertName = apnsCertName;
    return this;
  }

  EMPushConfig();

  factory EMPushConfig.fromJson(Map<String, dynamic> json) {

    return EMPushConfig().._mzAppId = json['mzAppId']
      .._mzAppKey = json['mzAppKey']
      .._oppoAppKey = json['oppoAppKey']
      .._oppoAppSecret = json['oppoAppSecret']
      .._miAppId = json['miAppId']
      .._miAppKey = json['miAppKey']
      .._fcmId = json['fcmId']
      .._apnsCertName = json['apnsCertName']
      .._enableMeiZuPush = json['enableMeiZuPush']
      .._enableOppoPush = json['enableOppoPush']
      .._enableMiPush = json['enableMiPush']
      .._enableFCM = json['enableFCM']
      .._enableVivoPush = json['enableVivoPush']
      .._enableHWPush = json['enableHWPush']
      .._enableAPNS = json['enableAPNS'];
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
}