import '../tools/em_extension.dart';
import 'em_push_config.dart';

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

  EMPushConfig _pushConfig = EMPushConfig();

  bool? enableDNSConfig = true;
  String? dnsUrl = '';
  String? restServer = '';
  String? imServer = '';
  int? imPort = 0;

  /// 开启Oppo推送，`appkey`是Oppo的appkey，`secret`是Oppo的secret。申请流程访问
  /// `http://docs-im.easemob.com/im/android/push/thirdpartypush`
  void enableOppPush(String appKey, String secret) {
    _pushConfig.enableOppoPush = true;
    _pushConfig.oppoAppKey = appKey;
    _pushConfig.oppoAppSecret = secret;
  }

  /// 开启小米推送, `appId`是推送用AppId, `appKey`是推送用AppKey。申请流程请访问
  /// `http://docs-im.easemob.com/im/android/push/thirdpartypush`
  void enableMiPush(String appId, String appKey) {
    _pushConfig.enableMiPush = true;
    _pushConfig.miAppId = appId;
    _pushConfig.miAppKey = appKey;
  }

  void enableFCM(String appId) {
    _pushConfig.enableFCM = true;
    _pushConfig.fcmId = appId;
  }

  void enableVivoPush() {
    _pushConfig.enableVivoPush = true;
  }

  /// 华为推送，具体流程请访问
  /// `http://docs-im.easemob.com/im/android/push/thirdpartypush`
  void enableHWPush() {
    _pushConfig.enableHWPush = true;
  }

  /// 开启苹果推送，具体申请证书和上传流程请参考文档
  /// `http://docs-im.easemob.com/im/ios/apns/deploy`
  void enableAPNs(String certName) {
    _pushConfig.enableAPNS = true;
    _pushConfig.apnsCertName = certName;
  }

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
    var ret = EMOptions(appKey: json['appKey'])
      ..autoLogin = json.boolValue('autoLogin')
      ..debugModel = json.boolValue('debugModel')
      ..requireAck = json.boolValue('requireAck')
      ..requireDeliveryAck = json.boolValue('requireDeliveryAck')
      ..sortMessageByServerTime = json.boolValue('sortMessageByServerTime')
      ..acceptInvitationAlways = json.boolValue('acceptInvitationAlways')
      ..autoAcceptGroupInvitation = json.boolValue('autoAcceptGroupInvitation')
      ..deleteMessagesAsExitGroup = json.boolValue('deleteMessagesAsExitGroup')
      ..deleteMessagesAsExitChatRoom =
          json.boolValue('deleteMessagesAsExitChatRoom')
      ..isAutoDownload = json.boolValue('isAutoDownload')
      ..isChatRoomOwnerLeaveAllowed =
          json.boolValue('isChatRoomOwnerLeaveAllowed')
      ..serverTransfer = json.boolValue('serverTransfer')
      ..usingHttpsOnly = json.boolValue('usingHttpsOnly')
      ..enableDNSConfig = json.boolValue('enableDNSConfig')
      ..imPort = json.intValue("imPort")
      ..imServer = json.stringValue("imServer")
      ..restServer = json.stringValue("restServer")
      ..dnsUrl = json.stringValue("dnsUrl");
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
    data.setValueWithOutNull("isAutoDownload", isAutoDownload);
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
