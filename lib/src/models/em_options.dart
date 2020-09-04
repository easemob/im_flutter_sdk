import 'package:flutter/cupertino.dart';

class EMOptions {

  /// 环信 appkey
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

    EMOptions options = EMOptions();
    options.appKey = json['appKey'];
    options.autoLogin = json['autoLogin'];
    options.debugModel = json['debugModel'];

    options.requireAck = json['requireAck'];
    options.requireDeliveryAck = json['requireDeliveryAck'];
    options.sortMessageByServerTime = json['sortMessageByServerTime'];

    options.acceptInvitationAlways = json['acceptInvitationAlways'];
    options.autoAcceptGroupInvitation = json['autoAcceptGroupInvitation'];
    options.deleteMessagesAsExitGroup = json['deleteMessagesAsExitGroup'];

    options.isAutoDownload = json['isAutoDownload'];
    options.isChatRoomOwnerLeaveAllowed = json['isChatRoomOwnerLeaveAllowed'];

    options.serverTransfer = json['serverTransfer'];

    options.usingHttpsOnly = json['usingHttpsOnly'];

    options.pushConfig = json['pushConfig'] != null ? EMPushConfig.fromJson(json['pushConfig']) : null;

    options.enableDNSConfig = json['enableDNSConfig'];
    options.imPort = json['imPort'];
    options.imServer = json['imServer'];
    options.restServer = json['restServer'];
    options.dnsUrl = json['dnsUrl'];

    return options;
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

  EMPushConfig enableOppoPush({@required String appKey, @required String secret}) {
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
    EMPushConfig config = EMPushConfig();

    config._mzAppId = json['mzAppId'];
    config._mzAppKey = json['mzAppKey'];

    config._oppoAppKey = json['oppoAppKey'];
    config._oppoAppSecret = json['oppoAppSecret'];

    config._miAppId = json['miAppId'];
    config._miAppKey = json['miAppKey'];

    config._fcmId = json['fcmId'];

    config._apnsCertName = json['apnsCertName'];

    config._enableMeiZuPush = json['enableMeiZuPush'];
    config._enableOppoPush = json['enableOppoPush'];
    config._enableMiPush = json['enableMiPush'];

    config._enableFCM = json['enableFCM'];

    config._enableVivoPush = json['enableVivoPush'];
    config._enableHWPush = json['enableHWPush'];

    config._enableAPNS = json['enableAPNS'];

    return config;
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