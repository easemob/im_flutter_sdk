import 'dart:math';

import '../tools/em_message_callback_manager.dart';
import '../tools/em_extension.dart';
import '../../im_flutter_sdk.dart';
import 'em_message_state_handle.dart';

// 消息类型
enum EMMessageChatType {
  Chat, // 单聊消息
  GroupChat, // 群聊消息
  ChatRoom, // 聊天室消息
}

// 消息方向
enum EMMessageDirection {
  SEND, // 发送的消息
  RECEIVE, // 接收的消息
}

// 消息状态
enum EMMessageStatus {
  CREATE, // 创建
  PROGRESS, // 发送中
  SUCCESS, // 发送成功
  FAIL, // 发送失败
}

// 附件状态
enum EMDownloadStatus {
  PENDING, // 下载未开始
  DOWNLOADING, // 下载中
  SUCCESS, // 下载成功
  FAILED, // 下载失败
}

/// body类型
enum EMMessageBodyType {
  TXT, // 文字消息
  IMAGE, // 图片消息
  VIDEO, // 视频消息
  LOCATION, // 位置消息
  VOICE, // 音频消息
  FILE, // 文件消息
  CMD, // CMD消息
  CUSTOM, // CUSTOM消息
}

abstract class EMMessageStatusListener {
  /// 消息进度
  void onProgress(int progress) {}

  /// 消息发送失败
  void onError(EMError error) {}

  /// 消息发送成功
  void onSuccess() {}

  /// 消息已读
  void onReadAck() {}

  /// 消息已送达
  void onDeliveryAck() {}

  /// 消息状态发生改变
  void onStatusChanged() {}
}

class EMMessage {
  EMMessage._private() {
    _tmpKey = localTime.toString();
  }

  late EMMessageStateHandle _handle;

  /// 构造接收的消息
  EMMessage.createReceiveMessage({
    required this.body,
    this.direction = EMMessageDirection.RECEIVE,
  }) {
    _tmpKey = localTime.toString();
    _handle = EMMessageStateHandle(
      _tmpKey,
      onMessageDeliveryAck: _onMessageDeliveryAck,
      onMessageError: _onMessageError,
      onMessageProgressChanged: _onMessageProgressChanged,
      onMessageReadAck: _onMessageReadAck,
      onMessageSuccess: _onMessageSuccess,
      onMessageStatusChanged: _onMessageStatusChanged,
    );
    MessageCallBackManager.getInstance.addMessage(_tmpKey, _handle);
  }

  /// 构造发送的消息
  EMMessage.createSendMessage({
    required this.body,
    this.direction = EMMessageDirection.SEND,
    this.to,
    this.hasRead = true,
  })  : this.from = EMClient.getInstance.currentUsername,
        this.conversationId = to {
    _tmpKey = localTime.toString();
    _handle = EMMessageStateHandle(
      _tmpKey,
      onMessageDeliveryAck: _onMessageDeliveryAck,
      onMessageError: _onMessageError,
      onMessageProgressChanged: _onMessageProgressChanged,
      onMessageReadAck: _onMessageReadAck,
      onMessageSuccess: _onMessageSuccess,
      onMessageStatusChanged: _onMessageStatusChanged,
    );
    MessageCallBackManager.getInstance.addMessage(_tmpKey, _handle);
  }

  void dispose() {
    MessageCallBackManager.getInstance.removeMessage(_tmpKey);
    // listener = null;
  }

  void _onMessageError(Map<String, dynamic> map) {
    EMLog.v('发送失败 -- ' + map.toString());
    EMMessage msg = EMMessage.fromJson(map['message']);
    this._msgId = msg.msgId;
    this.status = msg.status;
    this.body = msg.body;
    listener?.onError(EMError.fromJson(map['error']));
    return null;
  }

  void _onMessageProgressChanged(Map<String, dynamic> map) {
    EMLog.v(
      '发送 -- ' + ' msg_id: ' + this.msgId! + ' ' + map['progress'].toString(),
    );
    int progress = map['progress'];
    listener?.onProgress(progress);
    return null;
  }

  void _onMessageSuccess(Map<String, dynamic> map) {
    EMMessage msg = EMMessage.fromJson(map['message']);
    this._msgId = msg.msgId;
    this.status = msg.status;
    this.body = msg.body;
    listener?.onSuccess();
    EMLog.v('发送成功 -- ' + this.toString());
    return null;
  }

  void _onMessageReadAck(Map<String, dynamic> map) {
    EMLog.v('消息已读 -- ' + ' msg_id: ' + this.msgId!);
    EMMessage msg = EMMessage.fromJson(map);
    this.hasReadAck = msg.hasReadAck;
    listener?.onReadAck();

    return null;
  }

  void _onMessageDeliveryAck(Map<String, dynamic> map) {
    EMMessage msg = EMMessage.fromJson(map);
    this.hasDeliverAck = msg.hasDeliverAck;
    listener?.onDeliveryAck();
    return null;
  }

  void _onMessageStatusChanged(Map<String, dynamic> map) {
    EMMessage msg = EMMessage.fromJson(map);
    this.status = msg.status;
    listener?.onStatusChanged();
    return null;
  }

  /// 构造发送的文字消息
  EMMessage.createTxtSendMessage({
    required String username,
    required String content,
  }) : this.createSendMessage(
          to: username,
          body: EMTextMessageBody(content: content),
        );

  /// 构造发送的文件消息
  EMMessage.createFileSendMessage({
    required String username,
    required String filePath,
    String displayName = '',
    int? fileSize,
  }) : this.createSendMessage(
            to: username,
            body: EMFileMessageBody(
              localPath: filePath,
              fileSize: fileSize,
              displayName: displayName,
            ));

  /// 构造发送的图片消息
  EMMessage.createImageSendMessage({
    required String username,
    required String filePath,
    String displayName = '',
    String thumbnailLocalPath = '',
    bool sendOriginalImage = false,
    int? fileSize,
    double width = 0,
    double height = 0,
  }) : this.createSendMessage(
            to: username,
            body: EMImageMessageBody(
              localPath: filePath,
              displayName: displayName,
              thumbnailLocalPath: thumbnailLocalPath,
              sendOriginalImage: sendOriginalImage,
              width: width,
              height: height,
            ));

  /// 构造发送的视频消息
  EMMessage.createVideoSendMessage({
    required String username,
    required String filePath,
    String displayName = '',
    int duration = 0,
    int? fileSize,
    String thumbnailLocalPath = '',
    double width = 0,
    double height = 0,
  }) : this.createSendMessage(
            to: username,
            body: EMVideoMessageBody(
              localPath: filePath,
              displayName: displayName,
              duration: duration,
              fileSize: fileSize,
              thumbnailLocalPath: thumbnailLocalPath,
              width: width,
              height: height,
            ));

  /// 构造发送的音频消息
  EMMessage.createVoiceSendMessage({
    required String username,
    required String filePath,
    int duration = 0,
    int? fileSize,
    String displayName = '',
  }) : this.createSendMessage(
            to: username,
            body: EMVoiceMessageBody(
                localPath: filePath,
                duration: duration,
                fileSize: fileSize,
                displayName: displayName));

  /// 构造发送的位置消息
  EMMessage.createLocationSendMessage({
    required String username,
    required double latitude,
    required double longitude,
    String address = '',
  }) : this.createSendMessage(
            to: username,
            body: EMLocationMessageBody(
                latitude: latitude, longitude: longitude, address: address));

  /// 构造发送的cmd消息
  EMMessage.createCmdSendMessage({required String username, required action})
      : this.createSendMessage(
            to: username, body: EMCmdMessageBody(action: action));

  /// 构造发送的自定义消息
  EMMessage.createCustomSendMessage(
      {required String username, required event, Map<String, String>? params})
      : this.createSendMessage(
            to: username,
            body: EMCustomMessageBody(event: event, params: params));

  EMMessageStatusListener? listener;

  void setMessageListener(EMMessageStatusListener? listener) {
    this.listener = listener;
  }

  late String _tmpKey;

  /// 消息id
  String? _msgId,
      msgLocalId = DateTime.now().millisecondsSinceEpoch.toString() +
          Random().nextInt(99999).toString();

  String? get msgId => _msgId ?? msgLocalId;

  /// 消息所属会话id
  String? conversationId;

  /// 消息发送方
  String? from = '';

  /// 消息接收方
  String? to = '';

  /// 消息本地时间
  int localTime = DateTime.now().millisecondsSinceEpoch;

  /// 消息的服务器时间
  int serverTime = DateTime.now().millisecondsSinceEpoch;

  /// 消息是否收到已送达回执
  bool hasDeliverAck = false;

  /// 消息是否发送/收到已读回执
  bool hasReadAck = false;

  /// 是否需要群消息已读回执，默认为false
  bool needGroupAck = false;

  /// 群消息已读数量，只有在群消息时有效
  int groupAckCount = 0;

  /// 是否已读
  bool hasRead = false;

  /// 消息类型
  EMMessageChatType chatType = EMMessageChatType.Chat;

  /// 消息方向
  EMMessageDirection direction = EMMessageDirection.SEND;

  /// 消息状态
  EMMessageStatus status = EMMessageStatus.CREATE;

  /// 消息扩展
  Map attributes = {};

  /// msg body
  EMMessageBody? body;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['from'] = this.from;
    data['to'] = this.to;
    data['body'] = this.body!.toJson();
    data['attributes'] = this.attributes;
    data['direction'] =
        this.direction == EMMessageDirection.SEND ? 'send' : 'rec';
    data['hasRead'] = this.hasRead;
    data['hasReadAck'] = this.hasReadAck;
    data['hasDeliverAck'] = this.hasDeliverAck;
    data['needGroupAck'] = this.needGroupAck;
    data['groupAckCount'] = this.groupAckCount;
    data['msgId'] = this.msgId;
    data['conversationId'] = this.conversationId ?? this.to;
    data['chatType'] = chatTypeToInt(this.chatType);
    data['localTime'] = this.localTime;
    data['serverTime'] = this.serverTime;
    data['status'] = _chatStatusToInt(this.status);

    return data;
  }

  factory EMMessage.fromJson(Map<String, dynamic> map) {
    return EMMessage._private()
      ..to = map['to'] as String?
      ..from = map['from'] as String?
      ..body = _bodyFromMap(map['body'])
      ..attributes = map['attributes'] ?? {}
      ..direction = map['direction'] == 'send'
          ? EMMessageDirection.SEND
          : EMMessageDirection.RECEIVE
      ..hasRead = map.boolValue('hasRead')
      ..hasReadAck = map.boolValue('hasReadAck')
      ..needGroupAck = map.boolValue('needGroupAck')
      ..groupAckCount = map["groupAckCount"] as int? ?? 0
      ..hasDeliverAck = map.boolValue('hasDeliverAck')
      .._msgId = map['msgId'] as String?
      ..conversationId = map['conversationId'] as String?
      ..chatType = chatTypeFromInt(map['chatType'] as int?)
      ..localTime = map['localTime'] as int
      ..serverTime = map['serverTime'] as int
      ..status = _chatStatusFromInt(map['status'] as int?);
  }

  static int chatTypeToInt(EMMessageChatType type) {
    if (type == EMMessageChatType.ChatRoom) {
      return 2;
    } else if (type == EMMessageChatType.GroupChat) {
      return 1;
    } else {
      return 0;
    }
  }

  static EMMessageChatType chatTypeFromInt(int? type) {
    if (type == 2) {
      return EMMessageChatType.ChatRoom;
    } else if (type == 1) {
      return EMMessageChatType.GroupChat;
    } else {
      return EMMessageChatType.Chat;
    }
  }

  static int _chatStatusToInt(EMMessageStatus status) {
    if (status == EMMessageStatus.FAIL) {
      return 3;
    } else if (status == EMMessageStatus.SUCCESS) {
      return 2;
    } else if (status == EMMessageStatus.PROGRESS) {
      return 1;
    } else {
      return 0;
    }
  }

  static EMMessageStatus _chatStatusFromInt(int? status) {
    if (status == 3) {
      return EMMessageStatus.FAIL;
    } else if (status == 2) {
      return EMMessageStatus.SUCCESS;
    } else if (status == 1) {
      return EMMessageStatus.PROGRESS;
    } else {
      return EMMessageStatus.CREATE;
    }
  }

  static EMMessageBody? _bodyFromMap(Map map) {
    EMMessageBody? body;
    switch (map['type']) {
      case 'txt':
        body = EMTextMessageBody.fromJson(map: map);
        break;
      case 'loc':
        body = EMLocationMessageBody.fromJson(map: map);
        break;
      case 'cmd':
        body = EMCmdMessageBody.fromJson(map: map);
        break;
      case 'custom':
        body = EMCustomMessageBody.fromJson(map: map);
        break;
      case 'file':
        body = EMFileMessageBody.fromJson(map: map);
        break;
      case 'img':
        body = EMImageMessageBody.fromJson(map: map);
        break;
      case 'video':
        body = EMVideoMessageBody.fromJson(map: map);
        break;
      case 'voice':
        body = EMVoiceMessageBody.fromJson(map: map);
        break;
      default:
    }

    return body;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}

// message body
abstract class EMMessageBody {
  EMMessageBody({required this.type});

  EMMessageBody.fromJson({required Map map, this.type});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = EMMessageBody.bodyTypeToTypeStr(this.type!);
    return data;
  }

  @override
  String toString() {
    return toJson().toString();
  }

  static String bodyTypeToTypeStr(EMMessageBodyType type) {
    switch (type) {
      case EMMessageBodyType.TXT:
        return 'txt';
      case EMMessageBodyType.LOCATION:
        return 'loc';
      case EMMessageBodyType.CMD:
        return 'cmd';
      case EMMessageBodyType.CUSTOM:
        return 'custom';
      case EMMessageBodyType.FILE:
        return 'file';
      case EMMessageBodyType.IMAGE:
        return 'img';
      case EMMessageBodyType.VIDEO:
        return 'video';
      case EMMessageBodyType.VOICE:
        return 'voice';
    }
  }

  // body 类型
  EMMessageBodyType? type;
}

/// text body
class EMTextMessageBody extends EMMessageBody {
  EMTextMessageBody({required this.content})
      : super(type: EMMessageBodyType.TXT);

  EMTextMessageBody.fromJson({required Map map})
      : super.fromJson(map: map, type: EMMessageBodyType.TXT) {
    this.content = map['content'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['content'] = this.content;
    return data;
  }

  String? content = '';
}

/// location body
class EMLocationMessageBody extends EMMessageBody {
  EMLocationMessageBody(
      {required this.latitude, required this.longitude, this.address})
      : super(type: EMMessageBodyType.LOCATION);

  EMLocationMessageBody.fromJson({required Map map})
      : super.fromJson(map: map, type: EMMessageBodyType.LOCATION) {
    this.latitude = map['latitude'];
    this.longitude = map['longitude'];
    this.address = map['address'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['address'] = this.address;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    return data;
  }

  /// 地址
  String? address = '';

  /// 经纬度
  double? latitude = 0;
  double? longitude = 0;
}

/// file body
class EMFileMessageBody extends EMMessageBody {
  EMFileMessageBody({
    this.localPath,
    this.displayName,
    int? fileSize,
    EMMessageBodyType type = EMMessageBodyType.FILE,
  }) : super(type: type) {
    this.fileSize = fileSize ?? 0;
  }

  EMFileMessageBody.fromJson(
      {required Map map, EMMessageBodyType type = EMMessageBodyType.FILE})
      : super.fromJson(map: map, type: type) {
    this.secret = map['secret'];
    this.remotePath = map['remotePath'];
    this.fileSize = map['fileSize'];
    this.localPath = map['localPath'];
    this.displayName = map['displayName'];
    this.fileStatus = EMFileMessageBody.downloadStatusFromInt(
      map['fileStatus'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['secret'] = this.secret;
    data['remotePath'] = this.remotePath;
    // if (this.fileSize != 0) {
    data['fileSize'] = this.fileSize;
    // }
    data['localPath'] = this.localPath;
    data['displayName'] = this.displayName ?? '';
    data['fileStatus'] = EMFileMessageBody.downloadStatusToInt(this.fileStatus);
    return data;
  }

  /// 本地路径
  String? localPath = '';

  /// secret
  String? secret = '';

  /// 服务器路径
  String? remotePath = '';

  /// 附件状态
  EMDownloadStatus fileStatus = EMDownloadStatus.PENDING;

  /// 文件大小
  int fileSize = 0;

  /// 文件名称
  String? displayName = '';

  static EMDownloadStatus downloadStatusFromInt(int? status) {
    if (status == 0) {
      return EMDownloadStatus.DOWNLOADING;
    } else if (status == 1) {
      return EMDownloadStatus.SUCCESS;
    } else if (status == 2) {
      return EMDownloadStatus.FAILED;
    } else {
      return EMDownloadStatus.PENDING;
    }
  }

  static int downloadStatusToInt(EMDownloadStatus status) {
    if (status == EMDownloadStatus.DOWNLOADING) {
      return 0;
    } else if (status == EMDownloadStatus.SUCCESS) {
      return 1;
    } else if (status == EMDownloadStatus.FAILED) {
      return 2;
    } else {
      return 3;
    }
  }
}

/// image body
class EMImageMessageBody extends EMFileMessageBody {
  EMImageMessageBody({
    String? localPath,
    String? displayName,
    this.thumbnailLocalPath,
    this.sendOriginalImage,
    int? fileSize,
    this.width,
    this.height,
  }) : super(
          localPath: localPath,
          displayName: displayName,
          fileSize: fileSize,
          type: EMMessageBodyType.IMAGE,
        );

  EMImageMessageBody.fromJson({required Map map})
      : super.fromJson(map: map, type: EMMessageBodyType.IMAGE) {
    this.thumbnailLocalPath = map['thumbnailLocalPath'];
    this.thumbnailRemotePath = map['thumbnailRemotePath'];
    this.thumbnailSecret = map['thumbnailSecret'];
    this.sendOriginalImage = map.boolValue('sendOriginalImage');
    this.height = map['height']?.toDouble();
    this.width = map['width']?.toDouble();
    this.thumbnailStatus = EMFileMessageBody.downloadStatusFromInt(
      map['thumbnailStatus'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['thumbnailLocalPath'] = this.thumbnailLocalPath;
    data['thumbnailRemotePath'] = this.thumbnailRemotePath;
    data['thumbnailSecret'] = this.thumbnailSecret;
    data['sendOriginalImage'] = this.sendOriginalImage;
    data['height'] = this.height;
    data['width'] = this.width;
    data['thumbnailStatus'] =
        EMFileMessageBody.downloadStatusToInt(this.thumbnailStatus);
    return data;
  }

  /// 是否是原图
  bool? sendOriginalImage = false;

  /// 缩略图本地地址
  String? thumbnailLocalPath = '';

  /// 缩略图服务器地址
  String? thumbnailRemotePath = '';

  /// 缩略图 secret
  String? thumbnailSecret = '';

  /// 缩略图状态
  EMDownloadStatus thumbnailStatus = EMDownloadStatus.PENDING;

  /// 宽
  double? width = 0;

  /// 高
  double? height = 0;
}

/// video body
class EMVideoMessageBody extends EMFileMessageBody {
  EMVideoMessageBody({
    String? localPath,
    String? displayName,
    this.duration,
    int? fileSize,
    this.thumbnailLocalPath,
    this.height,
    this.width,
  }) : super(
          localPath: localPath,
          displayName: displayName,
          fileSize: fileSize,
          type: EMMessageBodyType.VIDEO,
        );

  EMVideoMessageBody.fromJson({required Map map})
      : super.fromJson(map: map, type: EMMessageBodyType.VIDEO) {
    this.duration = map['duration'] as int?;
    this.thumbnailLocalPath = map['thumbnailLocalPath'] as String?;
    this.thumbnailRemotePath = map['thumbnailRemotePath'] as String?;
    this.thumbnailSecret = map['thumbnailSecret'] as String?;
    this.height = map['height']?.toDouble();
    this.width = map['width']?.toDouble();
    this.thumbnailStatus = EMFileMessageBody.downloadStatusFromInt(
      map['thumbnailStatus'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['duration'] = this.duration;
    data['thumbnailLocalPath'] = this.thumbnailLocalPath;
    data['thumbnailRemotePath'] = this.thumbnailRemotePath;
    data['thumbnailSecret'] = this.thumbnailSecret;
    data['height'] = this.height;
    data['width'] = this.width;
    data['thumbnailStatus'] =
        EMFileMessageBody.downloadStatusToInt(this.thumbnailStatus);
    return data;
  }

  /// 时长。秒
  int? duration = 0;

  /// 缩略图本地地址
  String? thumbnailLocalPath = '';

  /// 缩略图服务器地址
  String? thumbnailRemotePath = '';

  /// 缩略图 secret
  String? thumbnailSecret = '';

  /// 缩略图状态
  EMDownloadStatus thumbnailStatus = EMDownloadStatus.PENDING;

  /// 宽
  double? width = 0;

  /// 高
  double? height = 0;
}

/// voice body
class EMVoiceMessageBody extends EMFileMessageBody {
  EMVoiceMessageBody({
    localPath,
    String? displayName,
    int? fileSize,
    this.duration,
  }) : super(
          localPath: localPath,
          displayName: displayName,
          fileSize: fileSize,
          type: EMMessageBodyType.VOICE,
        );

  EMVoiceMessageBody.fromJson({required Map map})
      : super.fromJson(map: map, type: EMMessageBodyType.VOICE) {
    this.duration = map['duration'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['duration'] = this.duration;
    return data;
  }

  /// 时长, 秒
  int? duration = 0;
}

/// cmd body
class EMCmdMessageBody extends EMMessageBody {
  EMCmdMessageBody({required this.action, this.deliverOnlineOnly = false})
      : super(type: EMMessageBodyType.CMD);

  EMCmdMessageBody.fromJson({required Map map})
      : super.fromJson(map: map, type: EMMessageBodyType.CMD) {
    this.action = map['action'];
    this.deliverOnlineOnly = map['deliverOnlineOnly'] == 0 ? false : true;
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['action'] = this.action;
    data['deliverOnlineOnly'] = this.deliverOnlineOnly;
    return data;
  }

  /// cmd 标识
  String? action = '';

  /// 只投在线
  bool? deliverOnlineOnly = false;
}

/// custom body
class EMCustomMessageBody extends EMMessageBody {
  EMCustomMessageBody({required this.event, this.params})
      : super(type: EMMessageBodyType.CUSTOM);

  EMCustomMessageBody.fromJson({required Map map})
      : super.fromJson(map: map, type: EMMessageBodyType.CUSTOM) {
    this.event = map['event'];
    this.params = map['params']?.cast<String, String>();
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['event'] = event;
    if (params != null) {
      data['params'] = params;
    }

    return data;
  }

  /// 自定义事件key
  String? event = '';

  /// 附加参数
  Map<String, String>? params = {};
}
