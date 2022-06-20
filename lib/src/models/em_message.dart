import 'dart:math';

import 'package:flutter/services.dart';

import '../internal/chat_method_keys.dart';
import '../internal/em_transform_tools.dart';
import '../tools/em_extension.dart';
import 'em_chat_thread.dart';
import 'em_chat_enums.dart';
import "em_message_body.dart";
import "../em_message_status_callback.dart";
import "../em_client.dart";
import 'em_error.dart';
import 'em_text_message_body.dart';
import 'em_image_message_body.dart';
import 'em_location_message_body.dart';
import 'em_voice_message_body.dart';
import 'em_video_message_body.dart';
import 'em_file_message_body.dart';
import 'em_custom_message_body.dart';
import 'em_cmd_message_body.dart';
import 'em_message_reaction.dart';
import '../em_status_listener.dart';

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

  int _groupAckCount = 0;

  ///
  /// Gets the number of members that have read the group message.
  ///
  @Deprecated("Switch to using EMMessage#groupAckCount instead.")
  int get groupAckCount => _groupAckCount;

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
  }) {
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
  })  : this.from = EMClient.getInstance.currentUsername,
        this.conversationId = to {
    this.hasRead = true;
    this.direction = MessageDirection.SEND;
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
  }) : this.createSendMessage(
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
    int? fileSize,
  }) : this.createSendMessage(
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
  }) : this.createSendMessage(
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
  }) : this.createSendMessage(
            to: targetId,
            body: EMLocationMessageBody(
              latitude: latitude,
              longitude: longitude,
              address: address,
            ));

  /// Creates a command message for sending.
  ///
  /// Param [username] The ID of the message recipient.
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
  }) : this.createSendMessage(
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
  /// Param [Map<String, String>? params] The params map.
  ///
  /// **Return** The message instance.
  ///
  EMMessage.createCustomSendMessage(
      {required String targetId, required event, Map<String, String>? params})
      : this.createSendMessage(
            to: targetId,
            body: EMCustomMessageBody(event: event, params: params));

  @Deprecated("Switch to using messageStatusCallBack instead.")
  StatusListener? listener;

  @Deprecated("Switch to using messageStatusCallBack instead.")
  void setMessageStatusListener(StatusListener? listener) {
    this.listener = listener;
  }

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
    data.setValueWithOutNull("groupAckCount", _groupAckCount);
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
      .._groupAckCount = map.getIntValue("groupAckCount", defaultValue: 0)!
      ..hasDeliverAck = map.boolValue('hasDeliverAck')
      .._msgId = map.getStringValue("msgId")
      ..conversationId = map.getStringValue("conversationId")
      ..chatType = chatTypeFromInt(map.getIntValue("chatType"))
      ..localTime = map.getIntValue("localTime", defaultValue: 0)!
      ..serverTime = map.getIntValue("serverTime", defaultValue: 0)!
      ..isChatThreadMessage = map.getBoolValue("isThread", defaultValue: false)!
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

extension EMMessageExtension on EMMessage {
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
