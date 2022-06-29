import 'dart:math';

import 'package:flutter/services.dart';

import '../internal/inner_headers.dart';

///
/// 消息对象类。
///
/// 创建一条待发送的文本消息示例代码如下：
///
/// ```dart
///   EMMessage msg = EMMessage.createTxtSendMessage(
///      targetId: "user1",
///      content: "hello",
///    );
/// ```
///
class EMMessage {
  String? _msgId;
  String _msgLocalId = DateTime.now().millisecondsSinceEpoch.toString() +
      Random().nextInt(99999).toString();

  /// 消息 ID。
  String get msgId => _msgId ?? _msgLocalId;

  /// 会话 ID。
  String? conversationId;

  ///
  /// 消息发送方，可以是：
  /// - 用户：用户 ID；
  /// - 群组：群组 ID；
  /// - 聊天室：聊天室 ID。
  ///
  String? from = '';

  ///
  /// 消息接收方，可以是：
  /// - 用户：用户 ID；
  /// - 群组：群组 ID；
  /// - 聊天室：聊天室 ID。
  ///
  String? to = '';

  /// 消息的本地时间戳，单位为毫秒。
  int localTime = DateTime.now().millisecondsSinceEpoch;

  /// 消息的服务器时间戳，单位为毫秒。
  int serverTime = DateTime.now().millisecondsSinceEpoch;

  ///
  /// 设置送达回执，即接收方是否已收到消息。
  ///
  /// - `true`：是；
  /// - `false`：否。
  ///
  bool hasDeliverAck = false;

  ///
  /// 设置已读回执，即接收方是否已阅读消息。
  /// - `true`：是；
  /// - `false`：否。
  ///
  bool hasReadAck = false;

  ///
  /// 设置是否需要群组已读回执。
  ///
  /// - `true`：是；
  /// - `false`：否。
  ///
  bool needGroupAck = false;

  /// 是否为子区中的消息。
  bool isChatThreadMessage = false;

  ///
  /// 查看消息是否已读。
  ///
  /// - `true`：是；
  /// - `false`：否。
  ///
  bool hasRead = false;

  ///
  /// 会话类型枚举。
  ///
  /// 三种会话类型：单聊，群聊，聊天室。
  ///
  ChatType chatType = ChatType.Chat;

  ///
  /// 消息方向，详见 {@link MessageDirection}。
  ///
  MessageDirection direction = MessageDirection.SEND;

  ///
  /// 消息状态，详见 {@link MessageStatus}。
  ///
  MessageStatus status = MessageStatus.CREATE;

  ///
  /// 消息的扩展字段。
  ///
  Map? attributes;

  ///
  /// 消息体。请参见 {@link EMMessageBody)}.
  ///
  late EMMessageBody body;

  MessageStatusCallBack? _messageStatusCallBack;

  ///
  /// 设置消息状态监听器。
  /// 你需要设置这个监听并依据回调结果更新 UI。
  ///
  void setMessageStatusCallBack(MessageStatusCallBack? callback) {
    _messageStatusCallBack = callback;
    if (callback != null) {
      MessageCallBackManager.getInstance.addMessage(this);
    } else {
      MessageCallBackManager.getInstance.removeMessage(localTime.toString());
    }
  }

  EMMessage._private();

  ///
  /// 创建一条接收消息。
  ///
  /// Param [body] 消息体。
  ///
  /// **Return** 消息实例。
  ///
  EMMessage.createReceiveMessage({
    required this.body,
  }) {
    this.direction = MessageDirection.RECEIVE;
  }

  ///
  /// 创建一条待发送的消息。
  ///
  /// Param [body] 消息体。
  ///
  /// Param [to] 接收方，可以是：
  /// - 用户：用户 ID；
  /// - 群组：群组 ID；
  /// - 聊天室：聊天室 ID。
  ///
  /// **Return** 消息对象。
  ///
  EMMessage.createSendMessage({
    required this.body,
    this.to,
  })  : this.from = EMClient.getInstance.currentUsername,
        this.conversationId = to {
    this.hasRead = true;
    this.direction = MessageDirection.SEND;
  }

  /// 清除引用
  void dispose() {
    MessageCallBackManager.getInstance.removeMessage(localTime.toString());
  }

  void _onMessageError(Map<String, dynamic> map) {
    EMMessage msg = EMMessage.fromJson(map['message']);
    this._msgId = msg.msgId;
    this.status = msg.status;
    this.body = msg.body;
    _messageStatusCallBack?.onError?.call(EMError.fromJson(map['error']));
    return null;
  }

  void _onMessageProgressChanged(Map<String, dynamic> map) {
    int progress = map['progress'];
    _messageStatusCallBack?.onProgress?.call(progress);
    return null;
  }

  void _onMessageSuccess(Map<String, dynamic> map) {
    EMMessage msg = EMMessage.fromJson(map['message']);
    this._msgId = msg.msgId;
    this.status = msg.status;
    this.body = msg.body;
    _messageStatusCallBack?.onSuccess?.call();

    return null;
  }

  void _onMessageReadAck(Map<String, dynamic> map) {
    EMMessage msg = EMMessage.fromJson(map);
    this.hasReadAck = msg.hasReadAck;
    _messageStatusCallBack?.onReadAck?.call();

    return null;
  }

  void _onMessageDeliveryAck(Map<String, dynamic> map) {
    EMMessage msg = EMMessage.fromJson(map);
    this.hasDeliverAck = msg.hasDeliverAck;
    _messageStatusCallBack?.onDeliveryAck?.call();
    return null;
  }

  ///
  /// 创建一条文本消息。
  ///
  /// Param [targetId] 消息接收方，可以是：
  /// - 用户：用户 ID；
  /// - 群组：群组 ID；
  /// - 聊天室：聊天室 ID。
  ///
  /// Param [content] 文本消息内容。
  ///
  /// **Return** 消息体实例。
  ///
  EMMessage.createTxtSendMessage({
    required String targetId,
    required String content,
    List<String>? targetLanguages,
  }) : this.createSendMessage(
          to: targetId,
          body: EMTextMessageBody(
            content: content,
            targetLanguages: targetLanguages,
          ),
        );

  ///
  /// 创建一条待发送的文件消息。
  ///
  /// Param [targetId] 消息接收方，可以是：
  /// - 用户：用户 ID；
  /// - 群组：群组 ID；
  /// - 聊天室：聊天室 ID。
  ///
  /// Param [filePath] 文件路径。
  ///
  /// Param [displayName] 文件名。
  ///
  /// Param [fileSize] 文件大小，单位为字节。
  ///
  /// **Return** 消息体实例。
  ///
  EMMessage.createFileSendMessage({
    required String targetId,
    required String filePath,
    String? displayName,
    int? fileSize,
  }) : this.createSendMessage(
            to: targetId,
            body: EMFileMessageBody(
              localPath: filePath,
              fileSize: fileSize,
              displayName: displayName,
            ));

  ///
  /// 创建一条待发送的图片消息。
  ///
  /// Param [targetId] 消息接收方，可以是：
  /// - 用户：用户 ID；
  /// - 群组：群组 ID；
  /// - 聊天室：聊天室 ID。
  ///
  /// Param [filePath] 文件路径。
  ///
  /// Param [displayName] 图片名。
  ///
  /// Param [thumbnailLocalPath] 缩略图本地路径。
  ///
  /// Param [sendOriginalImage] 是否发送原图。
  /// - `true`: 是。
  /// - `false`: (default) 否。默认大于 100 kb 的图片会自动压缩发送缩略图。
  ///
  /// Param [fileSize] 图片文件大小，单位是字节。
  ///
  /// Param [width] 图片的宽，单位是像素。
  ///
  /// Param [height] 图片的高，单位是像素。
  ///
  /// **Return** 图片实例。
  ///
  EMMessage.createImageSendMessage({
    required String targetId,
    required String filePath,
    String? displayName,
    String? thumbnailLocalPath,
    bool sendOriginalImage = false,
    int? fileSize,
    double? width,
    double? height,
  }) : this.createSendMessage(
            to: targetId,
            body: EMImageMessageBody(
              localPath: filePath,
              displayName: displayName,
              thumbnailLocalPath: thumbnailLocalPath,
              sendOriginalImage: sendOriginalImage,
              width: width,
              height: height,
            ));

  ///
  /// 创建一条待发送的视频消息。
  ///
  /// Param [targetId] 消息接收方，可以是：
  /// - 用户：用户 ID；
  /// - 群组：群组 ID；
  /// - 聊天室：聊天室 ID。
  ///
  /// Param [filePath] 视频文件路径。
  ///
  /// Param [displayName] 文件名。
  ///
  /// Param [duration] 视频时长，单位是秒。
  ///
  /// Param [fileSize] 视频文件大小。
  ///
  /// Param [thumbnailLocalPath] 缩略图的本地路径，一般取视频第一帧作为缩略图。
  ///
  /// Param [width] 缩略图宽度，单位是像素。
  ///
  /// Param [height] 缩略图高度，单位是像素。
  ///
  /// **Return** 消息体实例。
  ///
  EMMessage.createVideoSendMessage({
    required String targetId,
    required String filePath,
    String? displayName,
    int duration = 0,
    int? fileSize,
    String? thumbnailLocalPath,
    double? width,
    double? height,
  }) : this.createSendMessage(
            to: targetId,
            body: EMVideoMessageBody(
              localPath: filePath,
              displayName: displayName,
              duration: duration,
              fileSize: fileSize,
              thumbnailLocalPath: thumbnailLocalPath,
              width: width,
              height: height,
            ));

  ///
  /// 创建一条待发送的语音消息。
  ///
  /// Param [targetId] 消息接收方，可以是：
  /// - 用户：用户 ID；
  /// - 群组：群组 ID；
  /// - 聊天室：聊天室 ID。
  ///
  /// Param [filePath] 文件路径。
  ///
  /// Param [duration] 语音时长，单位为秒。
  ///
  /// Param [fileSize] 语音文件大小，单位是字节。
  ///
  /// Param [displayName] 文件名。
  ///
  /// **Return** 消息体实例。
  ///
  EMMessage.createVoiceSendMessage({
    required String targetId,
    required String filePath,
    int duration = 0,
    int? fileSize,
    String? displayName,
  }) : this.createSendMessage(
            to: targetId,
            body: EMVoiceMessageBody(
                localPath: filePath,
                duration: duration,
                fileSize: fileSize,
                displayName: displayName));

  ///
  /// 创建一条待发送的位置信息。
  ///
  /// Param [targetId] 消息接收方，可以是：
  /// - 用户：用户 ID；
  /// - 群组：群组 ID；
  /// - 聊天室：聊天室 ID。
  ///
  /// Param [latitude] 纬度。
  ///
  /// Param [longitude] 经度。
  ///
  /// Param [address] 地址。
  ///
  /// Param [buildingName] 建筑物名称。
  ///
  /// **Return** 消息体实例。
  ///
  EMMessage.createLocationSendMessage({
    required String targetId,
    required double latitude,
    required double longitude,
    String? address,
    String? buildingName,
  }) : this.createSendMessage(
            to: targetId,
            body: EMLocationMessageBody(
              latitude: latitude,
              longitude: longitude,
              address: address,
            ));

  /// 创建一条待发送的命令消息。
  ///
  /// Param [targetId] 消息接收方，可以是：
  /// - 用户：用户 ID；
  /// - 群组：群组 ID；
  /// - 聊天室：聊天室 ID。
  ///
  /// Param [action] 命令内容。
  ///
  /// **Return** 消息体实例。
  ///
  EMMessage.createCmdSendMessage({
    required String targetId,
    required action,
    bool deliverOnlineOnly = false,
  }) : this.createSendMessage(
            to: targetId,
            body: EMCmdMessageBody(
                action: action, deliverOnlineOnly: deliverOnlineOnly));

  /// 创建一条待发送的自定义消息。
  ///
  /// Param [targetId] 消息接收方，可以是：
  /// - 用户：用户 ID；
  /// - 群组：群组 ID；
  /// - 聊天室：聊天室 ID。
  ///
  /// Param [event] 事件内容。
  ///
  /// Param [params] 自定义消息的键值对 Map 列表。
  ///
  /// **Return** 消息体实例。
  ///
  EMMessage.createCustomSendMessage(
      {required String targetId, required event, Map<String, String>? params})
      : this.createSendMessage(
            to: targetId,
            body: EMCustomMessageBody(event: event, params: params));

  /// @nodoc
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data.setValueWithOutNull("from", from);
    data.setValueWithOutNull("to", to);
    data.setValueWithOutNull("body", body.toJson());
    data.setValueWithOutNull("attributes", attributes);
    data.setValueWithOutNull(
        "direction", this.direction == MessageDirection.SEND ? 'send' : 'rec');
    data.setValueWithOutNull("hasRead", hasRead);
    data.setValueWithOutNull("hasReadAck", hasReadAck);
    data.setValueWithOutNull("hasDeliverAck", hasDeliverAck);
    data.setValueWithOutNull("needGroupAck", needGroupAck);
    data.setValueWithOutNull("msgId", msgId);
    data.setValueWithOutNull("conversationId", this.conversationId ?? this.to);
    data.setValueWithOutNull("chatType", chatTypeToInt(chatType));
    data.setValueWithOutNull("localTime", localTime);
    data.setValueWithOutNull("serverTime", serverTime);
    data.setValueWithOutNull("status", messageStatusToInt(this.status));
    data.setValueWithOutNull("isThread", isChatThreadMessage);

    return data;
  }

  /// @nodoc
  factory EMMessage.fromJson(Map<String, dynamic> map) {
    return EMMessage._private()
      ..to = map.getStringValue("to")
      ..from = map.getStringValue("from")
      ..body = _bodyFromMap(map["body"])!
      ..attributes = map.getMapValue("attributes")
      ..direction = map.getStringValue("direction") == 'send'
          ? MessageDirection.SEND
          : MessageDirection.RECEIVE
      ..hasRead = map.boolValue('hasRead')
      ..hasReadAck = map.boolValue('hasReadAck')
      ..needGroupAck = map.boolValue('needGroupAck')
      ..hasDeliverAck = map.boolValue('hasDeliverAck')
      .._msgId = map.getStringValue("msgId")
      ..conversationId = map.getStringValue("conversationId")
      ..chatType = chatTypeFromInt(map.getIntValue("chatType"))
      ..localTime = map.getIntValue("localTime", defaultValue: 0)!
      ..serverTime = map.getIntValue("serverTime", defaultValue: 0)!
      ..isChatThreadMessage = map.getBoolValue("isThread", defaultValue: false)!
      // 提供单独的get方法，每次都去原生侧取。
      // ..chatThread = map.getValueWithKey<EMChatThread>(
      //   "thread",
      //   callback: (obj) {
      //     return EMChatThread.fromJson(obj);
      //   },
      // )
      ..status = messageStatusFromInt(map.intValue("status"));
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

  static const MethodChannel _emMessageChannel =
      const MethodChannel('com.chat.im/chat_message', JSONMethodCodec());

  ///
  /// 获取 Reaction 列表。
  ///
  /// **Return** Reaction 列表。
  ///
  /// **Throws** 如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 {@link EMError}。
  ///
  Future<List<EMMessageReaction>> reactionList() async {
    Map req = {"msgId": msgId};
    Map result = await _emMessageChannel.invokeMethod(
      ChatMethodKeys.getReactionList,
      req,
    );
    try {
      EMError.hasErrorFromResult(result);
      List<EMMessageReaction> list = [];
      result[ChatMethodKeys.getReactionList]?.forEach(
        (element) => list.add(
          EMMessageReaction.fromJson(element),
        ),
      );
      return list;
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 获取群消息已读人数。
  ///
  /// **Return** 群消息已读人数。
  ///
  /// **Throws** 如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 {@link EMError}。
  ///
  Future<int> groupAckCount() async {
    Map req = {"msgId": msgId};
    Map result =
        await _emMessageChannel.invokeMethod(ChatMethodKeys.groupAckCount, req);
    try {
      EMError.hasErrorFromResult(result);
      if (result.containsKey(ChatMethodKeys.groupAckCount)) {
        return result[ChatMethodKeys.groupAckCount];
      } else {
        return 0;
      }
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 获得消息中的子区概述。
  ///
  /// @note
  /// 目前，该方法只适用于群组消息。
  ///
  /// **Return** 子区概述内容。
  ///
  /// **Throws** 如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 {@link EMError}。
  ///
  Future<EMChatThread?> chatThread() async {
    Map req = {"msg": msgId};
    Map result =
        await _emMessageChannel.invokeMethod(ChatMethodKeys.getChatThread, req);
    try {
      EMError.hasErrorFromResult(result);
      if (result.containsKey(ChatMethodKeys.getChatThread)) {
        return result.getValueWithKey<EMChatThread>(
            ChatMethodKeys.getChatThread,
            callback: (obj) => EMChatThread.fromJson(obj));
      } else {
        return null;
      }
    } on EMError catch (e) {
      throw e;
    }
  }
}

class MessageCallBackManager {
  static const _channelPrefix = 'com.chat.im';
  static const MethodChannel _emMessageChannel =
      const MethodChannel('$_channelPrefix/chat_message', JSONMethodCodec());
  Map<String, EMMessage> cacheHandleMap = {};
  static MessageCallBackManager? _instance;
  static MessageCallBackManager get getInstance =>
      _instance = _instance ?? MessageCallBackManager._internal();

  MessageCallBackManager._internal() {
    _emMessageChannel.setMethodCallHandler((MethodCall call) async {
      Map<String, dynamic> argMap = call.arguments;
      int? localTime = argMap['localTime'];
      EMMessage? handle = cacheHandleMap[localTime.toString()];

      if (call.method == ChatMethodKeys.onMessageProgressUpdate) {
        return handle?._onMessageProgressChanged(argMap);
      } else if (call.method == ChatMethodKeys.onMessageError) {
        return handle?._onMessageError(argMap);
      } else if (call.method == ChatMethodKeys.onMessageSuccess) {
        return handle?._onMessageSuccess(argMap);
      } else if (call.method == ChatMethodKeys.onMessageReadAck) {
        return handle?._onMessageReadAck(argMap);
      } else if (call.method == ChatMethodKeys.onMessageDeliveryAck) {
        return handle?._onMessageDeliveryAck(argMap);
      }
      return null;
    });
  }

  void addMessage(EMMessage message) {
    cacheHandleMap[message.localTime.toString()] = message;
  }

  void removeMessage(String key) {
    if (cacheHandleMap.containsKey(key)) {
      cacheHandleMap.remove(key);
    }
  }
}

/// @nodoc
abstract class EMMessageBody {
  EMMessageBody({required this.type});

  /// @nodoc
  EMMessageBody.fromJson({
    required Map map,
    required this.type,
  });

  /// @nodoc
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = messageTypeToTypeStr(this.type);
    return data;
  }

  @override
  String toString() {
    return toJson().toString();
  }

  /// 获取消息类型。
  MessageType type;
}

///
/// 命令消息体类。
///
class EMCmdMessageBody extends EMMessageBody {
  ///
  /// 创建一个命令消息。
  ///
  EMCmdMessageBody({required this.action, this.deliverOnlineOnly = false})
      : super(type: MessageType.CMD);

  /// @nodoc
  EMCmdMessageBody.fromJson({required Map map})
      : super.fromJson(map: map, type: MessageType.CMD) {
    this.action = map["action"];
    this.deliverOnlineOnly =
        map.getBoolValue("deliverOnlineOnly", defaultValue: false)!;
  }

  /// @nodoc
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.setValueWithOutNull("action", action);
    data.setValueWithOutNull("deliverOnlineOnly", deliverOnlineOnly);

    return data;
  }

  /// 命令内容。
  late final String action;

  ///
  /// 判断当前 CMD 类型消息是否只投递在线用户。
  ///
  /// - `true`：是；
  /// - `false`：否。
  ///
  bool deliverOnlineOnly = false;
}

///
/// 位置消息类。
///
class EMLocationMessageBody extends EMMessageBody {
  ///
  /// 创建一个位置消息体实例。
  ///
  /// Param [latitude] 纬度。
  ///
  /// Param [longitude] 经度。
  ///
  /// Param [address] 地址。
  ///
  /// Param [buildingName] 建筑物名称。
  ///
  EMLocationMessageBody({
    required this.latitude,
    required this.longitude,
    String? address,
    String? buildingName,
  }) : super(type: MessageType.LOCATION) {
    _address = address;
    _buildingName = buildingName;
  }

  /// @nodoc
  EMLocationMessageBody.fromJson({required Map map})
      : super.fromJson(map: map, type: MessageType.LOCATION) {
    this.latitude = map.getDoubleValue("latitude", defaultValue: 0.0)!;
    this.longitude = map.getDoubleValue("longitude", defaultValue: 0.0)!;
    this._address = map.getStringValue("address");
    this._buildingName = map.getStringValue("buildingName");
  }

  /// @nodoc
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data.setValueWithOutNull("address", this._address);
    data.setValueWithOutNull("buildingName", this._buildingName);
    return data;
  }

  String? _address;
  String? _buildingName;

  /// 地址。
  String? get address => _address;

  /// 建筑物名称。
  String? get buildingName => _buildingName;

  /// 纬度。
  late final double latitude;

  /// 经度。
  late final double longitude;
}

///
/// 文件类消息的基类。
///
class EMFileMessageBody extends EMMessageBody {
  /// 创建一条带文件附件的消息。
  ///
  /// Param [localPath] 图片文件路径。
  ///
  /// Param [displayName] 文件显示名称。
  ///
  /// Param [fileSize] 文件大小，单位是字节。
  ///
  /// Param [type] 文件类型。
  ///
  EMFileMessageBody({
    required this.localPath,
    this.displayName,
    this.fileSize,
    MessageType type = MessageType.FILE,
  }) : super(type: type);

  /// @nodoc
  EMFileMessageBody.fromJson(
      {required Map map, MessageType type = MessageType.FILE})
      : super.fromJson(map: map, type: type) {
    this.secret = map.getStringValue("secret");
    this.remotePath = map.getStringValue("remotePath");
    this.fileSize = map.getIntValue("fileSize");
    this.localPath = map.getStringValue("localPath", defaultValue: "")!;
    this.displayName = map.getStringValue("displayName");
    this.fileStatus = EMFileMessageBody.downloadStatusFromInt(
      map.getIntValue("fileStatus"),
    );
  }

  /// @nodoc
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.setValueWithOutNull("secret", this.secret);
    data.setValueWithOutNull("remotePath", this.remotePath);
    data.setValueWithOutNull("fileSize", this.fileSize);
    data.setValueWithOutNull("localPath", this.localPath);
    data.setValueWithOutNull("displayName", this.displayName);
    data.setValueWithOutNull(
        "fileStatus", downloadStatusToInt(this.fileStatus));

    return data;
  }

  /// 附件的本地路径。
  late final String localPath;

  /// 获取附件的密钥。
  String? secret;

  /// 附件的服务器路径。
  String? remotePath;

  /// 附件的下载状态：
  DownloadStatus fileStatus = DownloadStatus.PENDING;

  /// 附件的大小，以字节为单位。
  int? fileSize;

  /// 附件的名称。
  String? displayName;

  static DownloadStatus downloadStatusFromInt(int? status) {
    if (status == 0) {
      return DownloadStatus.DOWNLOADING;
    } else if (status == 1) {
      return DownloadStatus.SUCCESS;
    } else if (status == 2) {
      return DownloadStatus.FAILED;
    } else {
      return DownloadStatus.PENDING;
    }
  }
}

///
/// 图片消息体类。
///
class EMImageMessageBody extends EMFileMessageBody {
  ///
  /// 用图片文件创建一个图片消息体。
  ///
  /// Param [localPath] 图片文件本地路径。
  ///
  /// Param [displayName] 文件名。
  ///
  /// Param [thumbnailLocalPath] 图片缩略图本地路径。
  ///
  /// Param [sendOriginalImage] 发送图片消息时的原始图片文件。
  ///
  /// Param [fileSize] 图片文件大小，单位是字节。
  ///
  /// Param [width] 图片宽度，单位为像素。
  ///
  /// Param [height] 图片高度，单位为像素。
  ///
  EMImageMessageBody({
    required String localPath,
    String? displayName,
    this.thumbnailLocalPath,
    this.sendOriginalImage = false,
    int? fileSize,
    this.width,
    this.height,
  }) : super(
          localPath: localPath,
          displayName: displayName,
          fileSize: fileSize,
          type: MessageType.IMAGE,
        );

  /// @nodoc
  EMImageMessageBody.fromJson({required Map map})
      : super.fromJson(map: map, type: MessageType.IMAGE) {
    this.thumbnailLocalPath = map.getStringValue("thumbnailLocalPath");
    this.thumbnailRemotePath = map.getStringValue("thumbnailRemotePath");
    this.thumbnailSecret = map.getStringValue("thumbnailSecret");
    this.sendOriginalImage = map.getBoolValue(
      "sendOriginalImage",
      defaultValue: false,
    )!;
    this.height = map.getDoubleValue("height");
    this.width = map.getDoubleValue("width");
    this.thumbnailStatus = EMFileMessageBody.downloadStatusFromInt(
      map.getIntValue("thumbnailStatus"),
    );
  }

  /// @nodoc
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.setValueWithOutNull("thumbnailLocalPath", thumbnailLocalPath);
    data.setValueWithOutNull("thumbnailRemotePath", thumbnailRemotePath);
    data.setValueWithOutNull("thumbnailSecret", thumbnailSecret);
    data.setValueWithOutNull("sendOriginalImage", sendOriginalImage);
    data.setValueWithOutNull("height", height);
    data.setValueWithOutNull("width", width);
    data.setValueWithOutNull(
        "thumbnailStatus", downloadStatusToInt(this.thumbnailStatus));
    return data;
  }

  ///
  /// 设置发送图片时，是否发送原图。
  /// - （默认）`false`：图片小于 100 KB 时，发送原图和缩略图；图片大于 100 KB 时，发送压缩后的图片和压缩后图片的缩略图。
  ///  - `true`：发送原图和缩略图。
  ///
  bool sendOriginalImage = false;

  /// 缩略图的本地路径或者字符串形式的资源标识符。
  String? thumbnailLocalPath;

  /// 缩略图的服务器路径。
  String? thumbnailRemotePath;

  /// 设置访问缩略图的密钥。下载缩略图时用户需要提供密钥进行校验。
  String? thumbnailSecret;

  /// 缩略图的下载状态。
  DownloadStatus thumbnailStatus = DownloadStatus.PENDING;

  /// 图片宽度，单位为像素。
  double? width;

  /// 图片高度，单位为像素。
  double? height;
}

///
/// 文本消息类。
///
class EMTextMessageBody extends EMMessageBody {
  ///
  /// 创建一条文本消息。
  ///
  /// Param [content] 文本消息内容。
  ///
  EMTextMessageBody({
    required this.content,
    this.targetLanguages,
  }) : super(type: MessageType.TXT);

  /// @nodoc
  EMTextMessageBody.fromJson({required Map map})
      : super.fromJson(
          map: map,
          type: MessageType.TXT,
        ) {
    this.content = map.getStringValue("content", defaultValue: "")!;
    this.targetLanguages = map.getList<String>(
      "targetLanguages",
      valueCallback: (item) {
        return item;
      },
    );
    if (map.containsKey("translations")) {
      this.translations = map["translations"]?.cast<String, String>();
    }
  }

  @override

  ///@nodoc
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['content'] = this.content;
    data.setValueWithOutNull("targetLanguages", this.targetLanguages);
    data.setValueWithOutNull("translations", this.translations);
    return data;
  }

  /// 文本消息内容。
  late final String content;

  /// 翻译的目标语言。
  List<String>? targetLanguages;

  /// 译文。
  Map<String, String>? translations;
}

///
/// 视频消息体类。
///
class EMVideoMessageBody extends EMFileMessageBody {
  ///
  /// 创建一条视频消息。
  ///
  /// Param [localPath] 视频文件本地路径。
  ///
  EMVideoMessageBody({
    required String localPath,

    /// Param [displayName] 视频名称。
    String? displayName,

    /// Param [duration] 视频时长，单位为秒。
    this.duration = 0,

    /// Param [fileSize] 视频文件大小，单位是字节。
    int? fileSize,

    /// Param [thumbnailLocalPath] 视频缩略图本地路径。
    this.thumbnailLocalPath,

    /// Param [height] 视频高度，单位是像素。
    this.height,

    /// /// Param [width] 视频宽度，单位是像素。
    this.width,
  }) : super(
          localPath: localPath,
          displayName: displayName,
          fileSize: fileSize,
          type: MessageType.VIDEO,
        );

  /// @nodoc
  EMVideoMessageBody.fromJson({required Map map})
      : super.fromJson(map: map, type: MessageType.VIDEO) {
    this.duration = map.getIntValue("duration", defaultValue: 0)!;
    this.thumbnailLocalPath = map.getStringValue("thumbnailLocalPath");
    this.thumbnailRemotePath = map.getStringValue("thumbnailRemotePath");
    this.thumbnailSecret = map.getStringValue("thumbnailSecret");
    this.height = map.getDoubleValue("height")?.toDouble();
    this.width = map.getDoubleValue("width")?.toDouble();
    this.thumbnailStatus = EMFileMessageBody.downloadStatusFromInt(
        map.getIntValue("thumbnailStatus"));
  }

  /// @nodoc
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.setValueWithOutNull("duration", duration);
    data.setValueWithOutNull("thumbnailLocalPath", thumbnailLocalPath);
    data.setValueWithOutNull("thumbnailRemotePath", thumbnailRemotePath);
    data.setValueWithOutNull("thumbnailSecret", thumbnailSecret);
    data.setValueWithOutNull("height", height);
    data.setValueWithOutNull("width", width);
    data.setValueWithOutNull(
        "thumbnailStatus", downloadStatusToInt(this.thumbnailStatus));

    return data;
  }

  /// 视频时长，单位是秒。
  int? duration;

  /// 视频缩略图的本地路径。
  String? thumbnailLocalPath;

  /// 视频缩略图的在服务器上的存储路径。
  String? thumbnailRemotePath;

  /// 视频缩略图的密钥。
  String? thumbnailSecret;

  /// 视频缩略图的下载状态。
  DownloadStatus thumbnailStatus = DownloadStatus.PENDING;

  /// 视频宽度，单位是像素。
  double? width;

  /// 视频高度，单位是像素。
  double? height;
}

///
/// 语音消息体类。
///
class EMVoiceMessageBody extends EMFileMessageBody {
  ///
  /// 创建一条语音消息。
  ///
  /// Param [localPath] 语言消息本地路径。
  ///
  /// Param [displayName] 语音文件名。
  ///
  /// Param [duration] 语音时长，单位是秒。
  ///
  /// Param [fileSize] 语音文件大小，单位是字节。
  ///
  EMVoiceMessageBody({
    localPath,
    this.duration = 0,
    String? displayName,
    int? fileSize,
  }) : super(
          localPath: localPath,
          displayName: displayName,
          fileSize: fileSize,
          type: MessageType.VOICE,
        );

  /// @nodoc
  EMVoiceMessageBody.fromJson({required Map map})
      : super.fromJson(map: map, type: MessageType.VOICE) {
    this.duration = map.getIntValue("duration", defaultValue: 0)!;
  }

  /// @nodoc
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.setValueWithOutNull("duration", duration);
    return data;
  }

  /// 语音时长，单位是秒。
  late final int duration;
}

///
/// 自定义消息体类。
///
class EMCustomMessageBody extends EMMessageBody {
  ///
  /// 自定义消息体类。
  ///
  EMCustomMessageBody({
    required this.event,
    this.params,
  }) : super(type: MessageType.CUSTOM);
  EMCustomMessageBody.fromJson({required Map map})
      : super.fromJson(map: map, type: MessageType.CUSTOM) {
    this.event = map["event"];
    this.params = map["params"]?.cast<String, String>();
  }

  /// @nodoc
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.setValueWithOutNull("event", event);
    data.setValueWithOutNull("params", params);

    return data;
  }

  /// 自定义事件内容。
  late final String event;

  /// 自定义消息的键值对 Map 列表。
  Map<String, String>? params;
}
