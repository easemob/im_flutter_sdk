

import 'package:flutter/foundation.dart';
import 'em_domain_terms.dart';

class EMOptions {
  /// 环信 appKey, 必须设置。
  String? appKey = '';

  /// 是否自动登录，当为`true`时，首次登录成功后，您再次启动App时，sdk会在
  /// 初始化后自定为您登录上一次登录的账号。
  bool? autoLogin = true;

  bool? debugModel = false;

  /// 自动同意好友申请，当设置为`true`时，
  /// 您在线时收到好友申请将自动同意,
  /// 如您不在线，等您上线后会自动同意。
  bool? acceptInvitationAlways = false;

  /// 是否自动同意群邀请，当设置为`true`时，
  /// 您在线时收到加群邀请会自动同意，
  /// 如您不在线，等您上线后会自动同意。
  bool? autoAcceptGroupInvitation = false;

  /// 是否允许发送已读回执,默认值为`ture`,
  /// 当为false时,当您通过EMChatManager调用sendMessageReadAck无效；
  bool? requireAck = true;

  /// 是否发送已送达回执，默认为`false`, 当为`ture`时，
  /// 您收到消息后会自动相对方发送已送达回执。
  /// 对方可以通过`onMessagesDelivered()`方法监听；
  bool? requireDeliveryAck = false;

  /// 退出群组时是否删除相应会话, 当为`true`时，
  /// 您离开群组后对应的群消息会被删除。
  bool? deleteMessagesAsExitGroup = true;

  /// 退出聊天室时是否删除相应会话, 当为`true`时，
  /// 您离开聊天室后对应的聊天室消息会被删除。
  bool? deleteMessagesAsExitChatRoom = true;

  /// 是否允许聊天室创建者退出聊天室，当为`true`时，
  /// 聊天室创建者可以退出聊天室。
  bool? isChatRoomOwnerLeaveAllowed = true;

  /// 消息按照服务器时间排序, 当为`true`时，您从数据库中
  /// 获取的消息是按照服务器时间排序的，否则是按照消息的本地时间排序。
  bool? sortMessageByServerTime = true;

  bool? usingHttpsOnly = false;
  bool? serverTransfer = true;
  bool? isAutoDownload = true;

  EMPushConfig? pushConfig;

  bool? enableDNSConfig = true;
  String? dnsUrl = '';
  String? restServer = '';
  String? imServer = '';
  int? imPort = 0;

  EMOptions({required this.appKey});

  /// 设置自定义server地址
  void customServerInfo({
    required String customRestServer,
    required String customImServer,
    required int customImPort,
  }) {
    restServer = customRestServer;
    imServer = customImServer;
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
      data['pushConfig'] = this.pushConfig!.toJson();
    }
    return data;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}

class EMPushConfig {
  String? _mzAppId = '';
  String? _mzAppKey = '';

  String? _oppoAppKey = '';
  String? _oppoAppSecret = '';

  String? _miAppId = '';
  String? _miAppKey = '';

  String? _fcmId = '';

  String? _apnsCertName = '';

  bool? _enableMeiZuPush = false;
  bool? _enableOppoPush = false;
  bool? _enableMiPush = false;

  bool? _enableFCM = false;

  bool? _enableVivoPush = false;
  bool? _enableHWPush = false;

  bool? _enableAPNS = false;

  /// 开启魅族推送, `appId`是推送用AppId, `appKey`是推送用AppKey。申请流程请访问
  /// `http://docs-im.easemob.com/im/android/push/thirdpartypush`
  void enableMeiZuPush(String appId, String appKey) {
    _enableMeiZuPush = true;
    _mzAppId = appId;
    _mzAppKey = appKey;
  }

  /// 开启Oppo推送，`appkey`是Oppo的appkey，`secret`是Oppo的secret。申请流程访问
  /// `http://docs-im.easemob.com/im/android/push/thirdpartypush`
  void enableOppPush(String appKey, String secret) {
    _enableOppoPush = true;
    _oppoAppKey = appKey;
    _oppoAppSecret = secret;
  }

  /// 开启小米推送, `appId`是推送用AppId, `appKey`是推送用AppKey。申请流程请访问
  /// `http://docs-im.easemob.com/im/android/push/thirdpartypush`
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

  /// 华为推送，具体流程请访问
  /// `http://docs-im.easemob.com/im/android/push/thirdpartypush`
  void enableHWPush() {
    _enableHWPush = true;
  }

  /// 开启苹果推送，具体申请证书和上传流程请参考文档
  /// `http://docs-im.easemob.com/im/ios/apns/deploy`
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
