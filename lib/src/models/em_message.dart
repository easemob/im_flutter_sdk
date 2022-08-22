import 'dart:math';

import 'package:flutter/services.dart';

import '../internal/inner_headers.dart';

///
/// The message class.
///
/// The sample code for constructing a text message to send is as follows.
///
/// ```dart
///   EMMessage msg = EMMessage.createTxtSendMessage(
///      username: "user1",
///      content: "hello",
///    );
/// ```
///
class EMMessage {
  /// 消息 ID。
  String? _msgId;
  String _msgLocalId = DateTime.now().millisecondsSinceEpoch.toString() +
      Random().nextInt(99999).toString();

  ///
  /// Gets the message ID.
  ///
  /// **return** The message ID.
  String get msgId => _msgId ?? _msgLocalId;

  ///
  /// The conversation ID.
  ///
  String? conversationId;

  ///
  /// The ID of the message sender.
  /// - For a one-to-one chat, it is the username of the peer user.
  /// - For a group chat, it is the group ID.
  /// - For a chat room, it is the chat room ID.
  ///
  String? from = '';

  ///
  /// The ID of the message recipient.
  /// - For a one-to-one chat, it is the username of the peer user.
  /// - For a group chat, it is the group ID.
  /// - For a chat room, it is the chat room ID.
  ///
  String? to = '';

  ///
  /// The local timestamp when the message is created on the local device, in milliseconds.
  ///
  int localTime = DateTime.now().millisecondsSinceEpoch;

  ///
  /// The timestamp when the message is received by the server.
  ///
  int serverTime = DateTime.now().millisecondsSinceEpoch;

  ///
  /// The delivery receipt, which is to check whether the other party has received the message.
  ///
  ///  Whether the recipient has received the message.
  /// - `true`: Yes.
  /// - `false`: No.
  ///
  bool hasDeliverAck = false;

  ///
  /// Whether the recipient has read the message.
  /// - `true`: Yes.
  /// - `false`: No.
  ///
  bool hasReadAck = false;

  ///
  /// Whether read receipts are required for group messages.
  ///
  /// - `true`: Yes.
  /// - `false`: No.
  ///
  ///
  bool needGroupAck = false;

  ///
  /// Is it a message sent within a thread
  bool isChatThreadMessage = false;

  ///
  /// Whether the message is read.
  /// - `true`: Yes.
  /// - `false`: No.
  ///
  ///
  bool hasRead = false;

  ///
  /// The enumeration of the chat type.
  ///
  /// There are three chat types: one-to-one chat, group chat, and chat room.
  ///
  ChatType chatType = ChatType.Chat;

  ///
  /// The message direction. see {@link MessageDirection}
  ///
  MessageDirection direction = MessageDirection.SEND;

  ///
  /// Gets the message sending/reception status. see {@link MessageStatus}
  ///
  MessageStatus status = MessageStatus.CREATE;

  ///
  /// Message's extension attribute.
  ///
  Map? attributes;

  ///
  /// Message body. We recommend you use {@link EMMessageBody)}.
  ///
  late EMMessageBody body;

  ///
  /// Sets the message status change callback.
  /// Your app should set messageStatusCallBack to get the message status and then refresh the UI accordingly.
  ///
  MessageStatusCallBack? _messageStatusCallBack;

  ///
  /// Message Online Status
  ///
  /// Local database does not store. The default value for reading or pulling roaming messages from the database is YES
  ///
  late final bool onlineState;

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
  /// Creates a received message instance.
  ///
  /// Param [body] The message body.
  ///
  /// **Return** The message instance.
  ///
  EMMessage.createReceiveMessage({
    required this.body,
    this.chatType = ChatType.Chat,
  }) {
    this.onlineState = true;
    this.direction = MessageDirection.RECEIVE;
  }

  ///
  /// Creates a message instance for sending.
  ///
  /// Param [body] The message body.
  ///
  /// Param [to] The ID of the message recipient.
  /// - For a one-to-one chat, it is the username of the peer user.
  /// - For a group chat, it is the group ID.
  /// - For a chat room, it is the chat room ID.
  ///
  /// **Return** The message instance.
  ///
  EMMessage.createSendMessage({
    required this.body,
    this.to,
    this.chatType = ChatType.Chat,
  })  : this.from = EMClient.getInstance.currentUsername,
        this.conversationId = to {
    this.hasRead = true;
    this.direction = MessageDirection.SEND;
    this.onlineState = true;
  }

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
  /// Creates a text message for sending.
  ///
  /// Param [targetId] The ID of the message recipient.
  /// - For a one-to-one chat, it is the username of the peer user.
  /// - For a group chat, it is the group ID.
  /// - For a chat room, it is the chat room ID.
  ///
  /// Param [content] The text content.
  ///
  /// Param [targetLanguages] Target languages.
  ///
  /// **Return** The message instance.
  ///
  EMMessage.createTxtSendMessage({
    required String targetId,
    required String content,
    List<String>? targetLanguages,
    ChatType chatType = ChatType.Chat,
  }) : this.createSendMessage(
          chatType: chatType,
          to: targetId,
          body: EMTextMessageBody(
            content: content,
            targetLanguages: targetLanguages,
          ),
        );

  ///
  /// Creates a file message for sending.
  ///
  /// Param [targetId] The ID of the message recipient.
  /// - For a one-to-one chat, it is the username of the peer user.
  /// - For a group chat, it is the group ID.
  /// - For a chat room, it is the chat room ID.
  ///
  /// Param [filePath] The file path.
  ///
  /// Param [displayName] The file name.
  ///
  /// Param [fileSize] The file size in bytes.
  ///
  /// **Return** The message instance.
  ///
  EMMessage.createFileSendMessage({
    required String targetId,
    required String filePath,
    String? displayName,
    ChatType chatType = ChatType.Chat,
    int? fileSize,
  }) : this.createSendMessage(
            chatType: chatType,
            to: targetId,
            body: EMFileMessageBody(
              localPath: filePath,
              fileSize: fileSize,
              displayName: displayName,
            ));

  ///
  /// Creates an image message for sending.
  ///
  /// Param [targetId] The ID of the message recipient.
  /// - For a one-to-one chat, it is the username of the peer user.
  /// - For a group chat, it is the group ID.
  /// - For a chat room, it is the chat room ID.
  ///
  /// Param [filePath] The image path.
  ///
  /// Param [displayName] The image name.
  ///
  /// Param [thumbnailLocalPath] The local path of the image thumbnail.
  ///
  /// Param [sendOriginalImage] Whether to send the original image.
  /// - `true`: Yes.
  /// - `false`: (default) No. For an image greater than 100 KB, the SDK will compress it and send the thumbnail.
  ///
  /// Param [fileSize] The image file size in bytes.
  ///
  /// Param [width] The image width in pixels.
  ///
  /// Param [height] The image height in pixels.
  ///
  /// **Return** The message instance.
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
    ChatType chatType = ChatType.Chat,
  }) : this.createSendMessage(
            chatType: chatType,
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
  ///  Creates a video message instance for sending.
  ///
  /// Param [targetId] The ID of the message recipient.
  /// - For a one-to-one chat, it is the username of the peer user.
  /// - For a group chat, it is the group ID.
  /// - For a chat room, it is the chat room ID.
  ///
  /// Param [filePath] The path of the video file.
  ///
  /// Param [displayName] The video name.
  ///
  /// Param [duration] The video duration in seconds.
  ///
  /// Param [fileSize] The video file size in bytes.
  ///
  /// Param [thumbnailLocalPath] The local path of the thumbnail, which is usually the first frame of video.
  ///
  /// Param [width] The width of the video thumbnail, in pixels.
  ///
  /// Param [height] The height of the video thumbnail, in pixels.
  ///
  /// **Return** The message instance.
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
    ChatType chatType = ChatType.Chat,
  }) : this.createSendMessage(
            chatType: chatType,
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
  /// Creates a voice message for sending.
  ///
  /// Param [targetId] The ID of the message recipient.
  /// - For a one-to-one chat, it is the username of the peer user.
  /// - For a group chat, it is the group ID.
  /// - For a chat room, it is the chat room ID.
  ///
  /// Param [filePath] The path of the voice file.
  ///
  /// Param [duration] The voice duration in seconds.
  ///
  /// Param [fileSize] The size of the voice file, in bytes.
  ///
  /// Param [displayName] The name of the voice file which ends with a suffix that indicates the format of the file. For example "voice.mp3".
  ///
  /// **Return** The message instance.
  ///
  EMMessage.createVoiceSendMessage({
    required String targetId,
    required String filePath,
    int duration = 0,
    int? fileSize,
    String? displayName,
    ChatType chatType = ChatType.Chat,
  }) : this.createSendMessage(
            chatType: chatType,
            to: targetId,
            body: EMVoiceMessageBody(
                localPath: filePath,
                duration: duration,
                fileSize: fileSize,
                displayName: displayName));

  ///
  /// Creates a location message for sending.
  ///
  /// Param [targetId] The ID of the message recipient.
  /// - For a one-to-one chat, it is the username of the peer user.
  /// - For a group chat, it is the group ID.
  /// - For a chat room, it is the chat room ID.
  ///
  /// Param [latitude] The latitude.
  ///
  /// Param [longitude] The longitude.
  ///
  /// Param [address] The address.
  ///
  /// Param [buildingName] The building name.
  ///
  /// **Return** The message instance.
  ///
  EMMessage.createLocationSendMessage({
    required String targetId,
    required double latitude,
    required double longitude,
    String? address,
    String? buildingName,
    ChatType chatType = ChatType.Chat,
  }) : this.createSendMessage(
            chatType: chatType,
            to: targetId,
            body: EMLocationMessageBody(
              latitude: latitude,
              longitude: longitude,
              address: address,
            ));

  /// Creates a command message for sending.
  ///
  /// Param [targetId] The ID of the message recipient.
  /// - For a one-to-one chat, it is the username of the peer user.
  /// - For a group chat, it is the group ID.
  /// - For a chat room, it is the chat room ID.
  ///
  /// Param [action] The command action.
  ///
  /// **Return** The message instance.
  ///
  EMMessage.createCmdSendMessage({
    required String targetId,
    required action,
    bool deliverOnlineOnly = false,
    ChatType chatType = ChatType.Chat,
  }) : this.createSendMessage(
            chatType: chatType,
            to: targetId,
            body: EMCmdMessageBody(
                action: action, deliverOnlineOnly: deliverOnlineOnly));

  /// Creates a custom message for sending.
  ///
  /// Param [targetId] The ID of the message recipient.
  /// - For a one-to-one chat, it is the username of the peer user.
  /// - For a group chat, it is the group ID.
  /// - For a chat room, it is the chat room ID.
  ///
  /// Param [event] The event.
  ///
  /// Param [params] The params map.
  ///
  /// **Return** The message instance.
  ///
  EMMessage.createCustomSendMessage({
    required String targetId,
    required event,
    Map<String, String>? params,
    ChatType chatType = ChatType.Chat,
  }) : this.createSendMessage(
            chatType: chatType,
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
      ..onlineState = map.getBoolValue("onlineState", defaultValue: true)!
      ..status = messageStatusFromInt(map.intValue("status"));
    // 提供单独的get方法，每次都去原生侧取。
    // ..chatThread = map.getValueWithKey<EMChatThread>(
    //   "thread",
    //   callback: (obj) {
    //     return EMChatThread.fromJson(obj);
    //   },
    // )
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
  /// Gets the Reaction list.
  ///
  /// **Return** The Reaction list
  ///
  /// **Throws** A description of the exception. See {@link EMError}
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
  /// Gets the number of members that have read the group message.
  ///
  /// **Return** group ack count
  ///
  /// **Throws** A description of the exception. See {@link EMError}
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
  /// Get an overview of the thread in the message (currently only supported by group messages)
  ///
  /// **Return** overview of the thread
  ///
  /// **Throws** A description of the exception. See {@link EMError}
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

  /// Gets the chat message type.
  MessageType type;
}

///
/// The command message body.
///
class EMCmdMessageBody extends EMMessageBody {
  ///
  /// Creates a command message.
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

  /// The command action content.
  late final String action;

  ///
  /// Checks whether this command message is only delivered to online users.
  ///
  /// - `true`: Yes.
  /// - `false`: No.
  ///
  bool deliverOnlineOnly = false;
}

///
/// The location message class.
///
class EMLocationMessageBody extends EMMessageBody {
  ///
  /// Creates a location message body instance.
  ///
  /// Param [latitude] The latitude.
  ///
  /// Param [longitude] The longitude.
  ///
  /// Param [address] The address.
  ///
  /// Param [buildingName] The building name.
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

  /// The address.
  String? get address => _address;

  /// The building name.
  String? get buildingName => _buildingName;

  /// The latitude.
  late final double latitude;

  /// The longitude.
  late final double longitude;
}

///
/// The base class of file messages.
///
class EMFileMessageBody extends EMMessageBody {
  /// Creates a message with an attachment.
  ///
  /// Param [localPath] The path of the image file.
  ///
  /// Param [displayName] The file name.
  ///
  /// Param [fileSize] The size of the file in bytes.
  ///
  /// Param [type] The file type.
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

  /// The local path of the attachment.
  late final String localPath;

  /// The token used to get the attachment.
  String? secret;

  /// The attachment path in the server.
  String? remotePath;

  /// The download status of the attachment.
  DownloadStatus fileStatus = DownloadStatus.PENDING;

  ///  The size of the attachment in bytes.
  int? fileSize;

  /// The attachment name.
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
/// The image message body class.
///
class EMImageMessageBody extends EMFileMessageBody {
  ///
  /// Creates an image message body with an image file.
  ///
  /// Param [localPath] The local path of the image file.
  ///
  /// Param [displayName] The image name.
  ///
  /// Param [thumbnailLocalPath] The local path of the image thumbnail.
  ///
  /// Param [sendOriginalImage] The original image included in the image message to be sent.
  ///
  /// Param [fileSize] The size of the image file in bytes.
  ///
  /// Param [width] The image width in pixels.
  ///
  /// Param [height] The image height in pixels.
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
  /// Whether to send the original image.
  ///
  /// - `false`: (default) No. The original image will be compressed if it exceeds 100 KB and the thumbnail will be sent.
  /// - `true`: Yes.
  ///
  bool sendOriginalImage = false;

  /// The local path or the URI (a string) of the thumbnail.
  String? thumbnailLocalPath;

  /// The URL of the thumbnail on the server.
  String? thumbnailRemotePath;

  /// The secret to access the thumbnail. A secret is required for verification for thumbnail download.
  String? thumbnailSecret;

  /// The download status of the thumbnail.
  DownloadStatus thumbnailStatus = DownloadStatus.PENDING;

  /// The image width in pixels.
  double? width;

  /// The image height in pixels.
  double? height;
}

///
/// The text message class.
///
class EMTextMessageBody extends EMMessageBody {
  ///
  /// Creates a text message.
  ///
  /// Param [content] The text content.
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

  /// The text content.
  late final String content;

  /// The target languages to translate
  List<String>? targetLanguages;

  /// It is Map, key is target language, value is translated content
  Map<String, String>? translations;
}

///
/// The video message body class.
///
class EMVideoMessageBody extends EMFileMessageBody {
  ///
  /// Creates a video message.
  ///
  /// Param [localPath] The local path of the video file.
  ///
  /// Param [displayName] The video name.
  ///
  /// Param [duration] The video duration in seconds.
  ///
  /// Param [fileSize] The size of the video file in bytes.
  ///
  /// Param [thumbnailLocalPath] The local path of the video thumbnail.
  ///
  /// Param [height] The video height in pixels.
  ///
  /// Param [width] The video width in pixels.
  ///
  EMVideoMessageBody({
    required String localPath,
    String? displayName,
    this.duration = 0,
    int? fileSize,
    this.thumbnailLocalPath,
    this.height,
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

  /// The video duration in seconds.
  int? duration;

  ///  The local path of the video thumbnail.
  String? thumbnailLocalPath;

  /// The URL of the thumbnail on the server.
  String? thumbnailRemotePath;

  /// The secret key of the video thumbnail.
  String? thumbnailSecret;

  /// The download status of the video thumbnail.
  DownloadStatus thumbnailStatus = DownloadStatus.PENDING;

  /// The video width in pixels.
  double? width;

  /// The video height in pixels.
  double? height;
}

///
/// The voice message body class.
///
class EMVoiceMessageBody extends EMFileMessageBody {
  ///
  /// Creates a voice message.
  ///
  /// Param [localPath] The local path of the voice file.
  ///
  /// Param [displayName] The name of the voice file.
  ///
  /// Param [fileSize] The size of the voice file in bytes.
  ///
  /// Param [duration] The voice duration in seconds.
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

  /// The voice duration in seconds.
  late final int duration;
}

///
/// The custom message body.
///
class EMCustomMessageBody extends EMMessageBody {
  ///
  /// Creates a custom message.
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

  /// The event.
  late final String event;

  /// The custom params map.
  Map<String, String>? params;
}
