// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:math';

import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:agora_chat_sdk/src/tools/chat_extension.dart';
import 'package:agora_chat_sdk_interface/agora_chat_sdk_interface.dart' as platform_interface;

/// ~english
/// The message class.
///
/// The sample code for constructing a text message to send is as follows.
///
/// ```dart
///   ChatMessage msg = ChatMessage.createTxtSendMessage(
///      username: "user1",
///      content: "hello",
///    );
/// ```
/// ~end
///
/// ~chinese
/// 消息对象类。
///
/// 创建一条待发送的文本消息示例代码如下：
///
/// ```dart
///   ChatMessage msg = ChatMessage.createTxtSendMessage(
///      targetId: "user1",
///      content: "hello",
///    );
/// ```
/// ~end
class ChatMessage {
  /// 消息 ID。
  String? _msgId;
  final String _msgLocalId = DateTime.now().millisecondsSinceEpoch.toString() +
      Random().nextInt(99999).toString();

  /// ~english
  /// Gets the message ID.
  ///
  /// **return** The message ID.
  /// ~end
  ///
  /// ~chinese
  /// 消息 ID。
  /// ~end
  String get msgId => _msgId ?? _msgLocalId;

  /// ~english
  /// The conversation ID.
  /// ~end
  ///
  /// ~chinese
  /// 会话 ID。
  /// ~end
  String? conversationId;

  /// ~english
  /// The user ID of the message sender.
  /// ~end
  ///
  /// ~chinese
  /// 消息发送方的用户 ID。
  /// ~end
  String? from = '';

  /// ~english
  /// The message recipient.
  /// - For a one-to-one chat, it is the user ID of the peer user.
  /// - For a group chat, it is the group ID.
  /// - For a chat room, it is the chat room ID.
  /// ~end
  ///
  /// ~chinese
  /// 消息接收方，可以是：
  /// - 单聊：用户 ID；
  /// - 群组：群组 ID；
  /// - 聊天室：聊天室 ID。
  /// ~end
  String? to = '';

  /// ~english
  /// The local timestamp when the message is created on the local device, in milliseconds.
  /// ~end
  ///
  /// ~chinese
  /// 消息的本地时间戳，单位为毫秒。
  /// ~end
  int localTime = DateTime.now().millisecondsSinceEpoch;

  /// ~english
  /// The timestamp when the message is received by the server.
  /// ~end
  ///
  /// ~chinese
  /// 消息的服务器时间戳，单位为毫秒。
  /// ~end
  int serverTime = DateTime.now().millisecondsSinceEpoch;

  /// ~english
  ///  Whether the recipient has received the message.
  /// - `true`: Yes.
  /// - `false`: No.
  /// ~end
  ///
  /// ~chinese
  /// 设置送达回执，即接收方是否已收到消息。
  /// - `true`：是；
  /// - `false`：否。
  /// ~end
  bool hasDeliverAck = false;

  /// ~english
  /// Whether the recipient has read the message.
  /// - `true`: Yes.
  /// - `false`: No.
  /// ~end
  ///
  /// ~chinese
  /// 设置已读回执，即接收方是否已阅读消息。
  /// - `true`：是；
  /// - `false`：否。
  /// ~end
  bool hasReadAck = false;

  /// ~english
  /// Whether read receipts are required for group messages.
  /// - `true`: Yes.
  /// - `false`: No.
  ///
  /// ~end
  ///
  /// ~chinese
  /// 设置是否需要群组已读回执。
  /// - `true`：是；
  /// - `false`：否。
  /// ~end
  bool needGroupAck = false;

  /// ~english
  /// Whether the message is sent within a chat thread.
  /// - `true`: Yes.
  /// - `false`: No.
  /// ~end
  ///
  /// ~chinese
  /// 是否为子区中的消息。
  /// - `true`：是；
  /// - `false`：否。
  /// ~end
  bool isChatThreadMessage = false;

  /// ~english
  /// Whether the message is read.
  /// - `true`: Yes.
  /// - `false`: No.
  /// ~end
  ///
  /// ~chinese
  /// 查看消息是否已读。
  ///
  /// - `true`：是；
  /// - `false`：否。
  /// ~end
  bool hasRead = false;

  /// ~english
  /// The enumeration of chat types.
  ///
  /// There are three chat types: one-to-one chat, group chat, and chat room.
  /// ~end
  ///
  /// ~chinese
  /// 会话类型枚举。
  ///
  /// 三种会话类型：单聊，群聊，聊天室。
  /// ~end
  ChatType chatType = ChatType.Chat;

  /// ~english
  /// The message direction. See [MessageDirection].
  /// ~end
  ///
  /// ~chinese
  /// 消息方向，详见 [MessageDirection]。
  /// ~end
  MessageDirection direction = MessageDirection.SEND;

  /// ~english
  /// The message sending/reception status. See [MessageStatus].
  /// ~end
  ///
  /// ~chinese
  /// 消息状态，详见 [MessageStatus]。
  /// ~end
  MessageStatus status = MessageStatus.CREATE;

  /// ~english
  /// Message's extension attribute.
  /// ~end
  ///
  /// ~chinese
  /// 消息的扩展字段。
  /// ~end
  Map<String, dynamic>? attributes;

  /// ~english
  /// Whether the message is delivered only when the recipient(s) is/are online:
  ///
  /// - `true`：The message is delivered only when the recipient(s) is/are online. If the recipient is offline, the message is discarded.
  /// - (Default) `false` ：The message is delivered when the recipient(s) is/are online. If the recipient(s) is/are offline, the message will not be delivered to them until they get online.
  /// ~end
  ///
  /// ~chinese
  /// 消息是否只投递给在线用户：
  ///
  /// - `true`：只有消息接收方在线时才能投递成功。若接收方离线，则消息会被丢弃。
  /// - （默认）`false`：如果用户在线，则直接投递；如果用户离线，消息会在用户上线时投递。
  /// ~end
  bool deliverOnlineOnly = false;

  /// ~english
  /// The recipient list of a targeted message.
  ///
  /// This property is used only for messages in groups and chat rooms.
  /// ~end
  ///
  /// ~chinese
  /// 定向消息的接收方。
  ///
  /// 该属性仅对群组聊天和聊天室中的消息有效。
  /// ~end
  List<String>? receiverList;

  /// ~english
  /// Message body. See [ChatMessageBody].
  /// ~end
  ///
  /// ~chinese
  /// 消息体。请参见 [ChatMessageBody]。
  /// ~end
  late ChatMessageBody body;

  /// ~english
  /// Whether the message gets delivered to an online user.
  ///
  /// This field is issued by the server to indicate whether the recipient is online when the message is delivered.
  ///
  /// This field is not stored in the local database. The value of this field is `true` by default for messages read from the database or pulled from the server.
  /// ~end
  ///
  /// ~chinese
  /// 该字段标记服务器下发消息时判断用户是在线还是离线的状态。
  ///
  /// 该字段为服务器下发字段，不在本地数据库中存储。对于从数据库读取的消息或拉取的漫游消息，该字段的值默认为 `true`。
  /// ~end
  late final bool onlineState;

  /// ~english
  ///  Whether it is a global broadcast message for all chat rooms in an app.
  /// ~end
  ///
  /// ~chinese
  /// 是否是聊天室全局广播消息。
  /// ~end
  late final bool isBroadcast;

  /// ~english
  /// Whether the message content is replaced. It is valid after [ChatOptions.useReplacedMessageContents] is enabled.
  /// ~end
  /// ~chinese
  /// 消息内容是否被替换, 开启[ChatOptions.useReplacedMessageContents]后有效
  /// ~end
  bool isContentReplaced = false;

  ChatRoomMessagePriority? _priority;

  Future<MessagePinInfo?> pinInfo() async {
    if (_msgId == null) {
      return null;
    }
    Map req = {"msgId": msgId};
    Map result = await platform_interface.Client.instance.messageManager.callNativeMethod(
      ChatMethodKeys.getPinInfo,
      req,
    );
    try {
      ChatError.hasErrorFromResult(result);
      if (result.containsKey(ChatMethodKeys.getPinInfo)) {
        return result.getValue<MessagePinInfo>(ChatMethodKeys.getPinInfo,
            callback: (obj) => MessagePinInfo.fromJson(obj));
      } else {
        return null;
      }
    } on ChatError {
      rethrow;
    }
  }

  /// ~english
  /// Sets the priority of chat room messages.
  /// param [priority] The priority of chat room messages. The default value is `Normal`, indicating the normal priority. For details, see[ChatRoomMessagePriority].
  /// ~end
  ///
  /// ~chinese
  /// 设置聊天室消息优先级。
  /// Param [priority] 消息优先级。默认值为 `Normal`，表示普通优先级。详见 [ChatRoomMessagePriority]。
  /// ~end
  set chatroomMessagePriority(ChatRoomMessagePriority priority) {
    _priority = priority;
  }

  ChatMessage._private();

  /// ~english
  /// Creates a received message instance.
  ///
  /// Param [body] The message body.
  ///
  /// Param [chatType] The chat type. The default chat type is one-to-one chat. For the group chat or chat room, see [ChatType].
  ///
  /// **Return** The message instance.
  /// ~end
  ///
  /// ~chinese
  /// 创建一条接收消息。
  ///
  /// Param [body] 消息体。
  ///
  /// Param [chatType] 聊天类型, 默认为单聊，如果是群聊或者聊天室，可以参考[ChatType]。
  ///
  /// **Return** 消息实例。
  /// ~end
  ChatMessage.createReceiveMessage({
    required this.body,
    this.chatType = ChatType.Chat,
  }) {
    onlineState = true;
    direction = MessageDirection.RECEIVE;
  }

  /// ~english
  /// Creates a message instance for sending.
  ///
  /// Param [body] The message body.
  ///
  /// Param [to] The ID of the message recipient.
  /// - For a one-to-one chat, it is the user ID of the peer user.
  /// - For a group chat, it is the group ID.
  /// - For a chat room, it is the chat room ID.
  ///
  /// Param [chatType] The chat type. The default chat type is one-to-one chat. For the group chat or chat room, see [ChatType].
  ///
  /// **Return** The message instance.
  /// ~end
  ///
  /// ~chinese
  /// 创建一条待发送的消息。
  ///
  /// Param [body] 消息体。
  ///
  /// Param [to] 接收方，可以是：
  /// - 用户：用户 ID；
  /// - 群组：群组 ID；
  /// - 聊天室：聊天室 ID。
  ///
  /// Param [chatType] 聊天类型, 默认为单聊，如果是群聊或者聊天室，可以参考[ChatType]。
  ///
  /// **Return** 消息对象。
  /// ~end
  ChatMessage.createSendMessage({
    required this.body,
    this.to,
    this.chatType = ChatType.Chat,
  })  : from = ChatClient.getInstance.currentUserId,
        conversationId = to {
    hasRead = true;
    direction = MessageDirection.SEND;
    onlineState = true;
  }

  void dispose() {}

  /// ~english
  /// Creates a text message for sending.
  ///
  /// Param [targetId] The ID of the message recipient.
  /// - For a one-to-one chat, it is the user ID of the peer user.
  /// - For a group chat, it is the group ID.
  /// - For a chat room, it is the chat room ID.
  ///
  /// Param [content] The text content.
  ///
  /// Param [targetLanguages] Target languages.
  ///
  /// Param [chatType] The chat type. The default chat type is one-to-one chat. For the group chat or chat room, see [ChatType].
  ///
  /// **Return** The message instance.
  /// ~end
  ///
  /// ~chinese
  /// 创建一条文本消息。
  ///
  /// Param [targetId] 消息接收方，可以是：
  /// - 用户：用户 ID；
  /// - 群组：群组 ID；
  /// - 聊天室：聊天室 ID。
  ///
  /// Param [content] 文本消息内容。
  ///
  /// Param [targetLanguages] 目标语言。
  ///
  /// Param [chatType] 聊天类型, 默认为单聊，如果是群聊或者聊天室，可以参考[ChatType]。
  ///
  /// **Return** 消息体实例。
  /// ~end
  ChatMessage.createTxtSendMessage({
    required String targetId,
    required String content,
    List<String>? targetLanguages,
    ChatType chatType = ChatType.Chat,
  }) : this.createSendMessage(
          chatType: chatType,
          to: targetId,
          body: ChatTextMessageBody(
            content: content,
            targetLanguages: targetLanguages,
          ),
        );

  /// ~english
  /// Creates a file message for sending.
  ///
  /// Param [targetId] The ID of the message recipient.
  /// - For a one-to-one chat, it is the user ID of the peer user.
  /// - For a group chat, it is the group ID.
  /// - For a chat room, it is the chat room ID.
  ///
  /// Param [filePath] The file path.
  ///
  /// Param [displayName] The file name.
  ///
  /// Param [fileSize] The file size in bytes.
  ///
  /// Param [chatType] The chat type. The default chat type is one-to-one chat. For the group chat or chat room, see [ChatType].
  ///
  /// **Return** The message instance.
  /// ~end
  ///
  /// ~chinese
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
  /// Param [chatType] 聊天类型, 默认为单聊，如果是群聊或者聊天室，可以参考[ChatType]。
  ///
  /// **Return** 消息体实例。
  /// ~end
  ChatMessage.createFileSendMessage({
    required String targetId,
    required String filePath,
    String? displayName,
    int? fileSize,
    ChatType chatType = ChatType.Chat,
  }) : this.createSendMessage(
            chatType: chatType,
            to: targetId,
            body: ChatFileMessageBody(
              localPath: filePath,
              fileSize: fileSize,
              displayName: displayName,
            ));

  /// ~english
  /// Creates an image message for sending.
  ///
  /// Param [targetId] The ID of the message recipient.
  /// - For a one-to-one chat, it is the user ID of the peer user.
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
  /// - (Default) `false`: No. For an image greater than 100 KB, the SDK will compress it and send the thumbnail.
  ///
  /// Param [fileSize] The image file size in bytes.
  ///
  /// Param [width] The image width in pixels.
  ///
  /// Param [height] The image height in pixels.
  ///
  /// Param [chatType] The chat type. The default chat type is one-to-one chat. For the group chat or chat room, see [ChatType].
  ///
  /// **Return** The message instance.
  /// ~end
  ///
  /// ~chinese
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
  /// - （默认）`false`: 否。默认大于 100 KB 的图片会自动压缩发送缩略图。
  ///
  /// Param [fileSize] 图片文件大小，单位是字节。
  ///
  /// Param [width] 图片的宽，单位是像素。
  ///
  /// Param [height] 图片的高，单位是像素。
  ///
  /// Param [chatType] 聊天类型, 默认为单聊，如果是群聊或者聊天室，可以参考[ChatType]。
  ///
  /// **Return** 消息体实例。
  /// ~end
  ChatMessage.createImageSendMessage({
    required String targetId,
    required String filePath,
    String? displayName,
    String? thumbnailLocalPath,
    bool sendOriginalImage = false,
    bool isGif = false,
    int? fileSize,
    double? width,
    double? height,
    ChatType chatType = ChatType.Chat,
  }) : this.createSendMessage(
            chatType: chatType,
            to: targetId,
            body: ChatImageMessageBody(
              localPath: filePath,
              displayName: displayName,
              thumbnailLocalPath: thumbnailLocalPath,
              sendOriginalImage: sendOriginalImage,
              width: width,
              height: height,
              isGif: isGif,
            ));

  /// ~english
  /// Creates a video message instance for sending.
  ///
  /// Param [targetId] The ID of the message recipient.
  /// - For a one-to-one chat, it is the user ID of the peer user.
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
  /// Param [chatType] The chat type. The default chat type is one-to-one chat. For the group chat or chat room, see [ChatType].
  ///
  /// **Return** The message instance.
  /// ~end
  ///
  /// ~chinese
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
  /// Param [chatType] 聊天类型, 默认为单聊，如果是群聊或者聊天室，可以参考[ChatType]。
  ///
  /// **Return** 消息体实例。
  /// ~end
  ChatMessage.createVideoSendMessage({
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
            body: ChatVideoMessageBody(
              localPath: filePath,
              displayName: displayName,
              duration: duration,
              fileSize: fileSize,
              thumbnailLocalPath: thumbnailLocalPath,
              width: width,
              height: height,
            ));

  /// ~english
  /// Creates a voice message for sending.
  ///
  /// Param [targetId] The ID of the message recipient.
  /// - For a one-to-one chat, it is the user ID of the peer user.
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
  /// Param [chatType] The chat type. The default chat type is one-to-one chat. For the group chat or chat room, see [ChatType].
  ///
  /// **Return** The message instance.
  /// ~end
  ///
  /// ~chinese
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
  /// Param [chatType] 聊天类型, 默认为单聊，如果是群聊或者聊天室，可以参考[ChatType]。
  ///
  /// **Return** 消息体实例。
  /// ~end
  ChatMessage.createVoiceSendMessage({
    required String targetId,
    required String filePath,
    int duration = 0,
    int? fileSize,
    String? displayName,
    ChatType chatType = ChatType.Chat,
  }) : this.createSendMessage(
            chatType: chatType,
            to: targetId,
            body: ChatVoiceMessageBody(
                localPath: filePath,
                duration: duration,
                fileSize: fileSize,
                displayName: displayName));

  /// ~english
  /// Creates a location message for sending.
  ///
  /// Param [targetId] The ID of the message recipient.
  /// - For a one-to-one chat, it is the user ID of the peer user.
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
  /// Param [chatType] The chat type. The default chat type is one-to-one chat. For the group chat or chat room, see [ChatType].
  ///
  /// **Return** The message instance.
  /// ~end
  ///
  /// ~chinese
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
  /// Param [chatType] 聊天类型, 默认为单聊，如果是群聊或者聊天室，可以参考[ChatType]。
  ///
  /// **Return** 消息体实例。
  /// ~end
  ChatMessage.createLocationSendMessage({
    required String targetId,
    required double latitude,
    required double longitude,
    String? address,
    String? buildingName,
    ChatType chatType = ChatType.Chat,
  }) : this.createSendMessage(
            chatType: chatType,
            to: targetId,
            body: ChatLocationMessageBody(
              latitude: latitude,
              longitude: longitude,
              address: address,
              buildingName: buildingName,
            ));

  /// ~english
  /// Creates a command message for sending.
  ///
  /// Param [targetId] The ID of the message recipient.
  /// - For a one-to-one chat, it is the user ID of the peer user.
  /// - For a group chat, it is the group ID.
  /// - For a chat room, it is the chat room ID.
  ///
  /// Param [action] The command action.
  ///
  /// Param [deliverOnlineOnly] Whether to send only to online users.
  ///
  /// Param [chatType] The chat type. The default chat type is one-to-one chat. For the group chat or chat room, see [ChatType].
  ///
  /// **Return** The message instance.
  /// ~end
  ///
  /// ~chinese
  /// 创建一条待发送的命令消息。
  ///
  /// Param [targetId] 消息接收方，可以是：
  /// - 用户：用户 ID；
  /// - 群组：群组 ID；
  /// - 聊天室：聊天室 ID。
  ///
  /// Param [action] 命令内容。
  ///
  /// Param [deliverOnlineOnly] 是否只发送在线用户。
  ///
  /// Param [chatType] 聊天类型, 默认为单聊，如果是群聊或者聊天室，可以参考[ChatType]。
  ///
  /// **Return** 消息体实例。
  /// ~end
  ChatMessage.createCmdSendMessage({
    required String targetId,
    required action,
    bool deliverOnlineOnly = false,
    ChatType chatType = ChatType.Chat,
  }) : this.createSendMessage(
            chatType: chatType,
            to: targetId,
            body: ChatCmdMessageBody(
                action: action, deliverOnlineOnly: deliverOnlineOnly));

  /// ~english
  /// Creates a custom message for sending.
  ///
  /// Param [targetId] The ID of the message recipient.
  /// - For a one-to-one chat, it is the user ID of the peer user.
  /// - For a group chat, it is the group ID.
  /// - For a chat room, it is the chat room ID.
  ///
  /// Param [event] The event.
  ///
  /// Param [params] The params map.
  ///
  /// Param [chatType] The chat type. The default chat type is one-to-one chat. For the group chat or chat room, see [ChatType].
  ///
  /// **Return** The message instance.
  /// ~end
  ///
  /// ~chinese
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
  /// Param [chatType] 聊天类型, 默认为单聊，如果是群聊或者聊天室，可以参考[ChatType]。
  ///
  /// **Return** 消息体实例。
  /// ~end
  ChatMessage.createCustomSendMessage({
    required String targetId,
    required String event,
    Map<String, String>? params,
    ChatType chatType = ChatType.Chat,
  }) : this.createSendMessage(
            chatType: chatType,
            to: targetId,
            body: ChatCustomMessageBody(event: event, params: params));

  /// ~english
  /// Creates a combined message for sending.
  ///
  /// Param [targetId] The message recipient. The field setting is determined by the conversation type:
  /// - For a one-to-one chat, it is the user ID of the peer user.
  /// - For a group chat, it is the group ID.
  /// - For a chat room, it is the chat room ID.
  ///
  /// Param [title]  The title of the combined message.
  ///
  /// Param [summary]  The summary of the combined message.
  ///
  /// Param [compatibleText] The compatible text of the combined message.
  ///
  /// Param [msgIds] The list of original messages included in the combined message.
  ///
  /// Param [chatType] The chat type. The default chat type is one-to-one chat. For the group chat or chat room, see [ChatType].
  ///
  /// **Return** The message instance.
  /// ~end
  ///
  /// ~chinese
  /// 创建一条待发送的合并消息。
  ///
  /// Param [targetId] 消息接收方。该字段的设置取决于会话类型：
  /// - 单聊：对方用户 ID；
  /// - 群组：群组 ID；
  /// - 聊天室：聊天室 ID。
  ///
  /// Param [title] 合并消息的标题。
  ///
  /// Param [summary] 合并消息的概要。
  ///
  /// Param [compatibleText] 合并消息的兼容信息。
  ///
  /// Param [msgIds] 合并消息的消息 ID 列表。
  ///
  /// Param [chatType] 聊天类型, 默认为单聊，如果是群聊或者聊天室，可以参考 [ChatType]。
  ///
  /// **Return** 消息体实例。
  /// ~end
  ChatMessage.createCombineSendMessage({
    required String targetId,
    String? title,
    String? summary,
    String? compatibleText,
    required List<String> msgIds,
    ChatType chatType = ChatType.Chat,
  }) : this.createSendMessage(
            chatType: chatType,
            to: targetId,
            body: CombineMessageBody(
              title: title,
              summary: summary,
              compatibleText: compatibleText,
              messageList: msgIds,
            ));

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data.putIfNotNull("from", from);
    data.putIfNotNull("to", to);
    data.putIfNotNull("body", body.toJson());
    data.putIfNotNull("attributes", attributes);
    data.putIfNotNull("direction", direction.index);
    data.putIfNotNull("hasRead", hasRead);
    data.putIfNotNull("hasReadAck", hasReadAck);
    data.putIfNotNull("hasDeliverAck", hasDeliverAck);
    data.putIfNotNull("needGroupAck", needGroupAck);
    data.putIfNotNull("msgId", msgId);
    data.putIfNotNull("convId", conversationId ?? to);
    data.putIfNotNull("chatType", chatType.index);
    data.putIfNotNull("localTime", localTime);
    data.putIfNotNull("serverTime", serverTime);
    data.putIfNotNull("status", status.index);
    data.putIfNotNull("isThread", isChatThreadMessage);
    data.putIfNotNull('isContentReplaced', isContentReplaced);
    if (_priority != null) {
      data.putIfNotNull("chatroomMessagePriority", _priority!.index);
    }
    data.putIfNotNull('deliverOnlineOnly', deliverOnlineOnly);
    if (receiverList != null) {
      data.putIfNotNull('receiverList', receiverList);
    }

    return data;
  }

  factory ChatMessage.fromJson(Map<String, dynamic> map) {
    return ChatMessage._private()
      ..to = map["to"]
      ..from = map["from"]
      ..body = _bodyFromMap(map["body"])!
      ..attributes = map.getMapValue("attributes")
      ..direction = MessageDirection.values[map["direction"]]
      ..hasRead = map.boolValue('hasRead')
      ..hasReadAck = map.boolValue('hasReadAck')
      ..needGroupAck = map.boolValue('needGroupAck')
      ..hasDeliverAck = map.boolValue('hasDeliverAck')
      .._msgId = map["msgId"]
      ..conversationId = map["convId"]
      ..chatType = ChatType.values[map["chatType"]]
      ..localTime = map["localTime"] ?? 0
      ..serverTime = map["serverTime"] ?? 0
      ..isChatThreadMessage = map["isThread"] ?? false
      ..onlineState = map["onlineState"] ?? true
      ..deliverOnlineOnly = map['deliverOnlineOnly'] ?? false
      ..status = MessageStatus.values[map["status"]]
      ..receiverList = map["receiverList"]?.cast<String>()
      ..isBroadcast = map["broadcast"] ?? false
      ..isContentReplaced = map["isContentReplaced"] ?? false;
  }

  static ChatMessageBody? _bodyFromMap(Map map) {
    ChatMessageBody? body;
    MessageType type = MessageType.values[map['type']];
    switch (type) {
      case MessageType.TXT:
        body = ChatTextMessageBody.fromJson(map: map);
        break;
      case MessageType.LOCATION:
        body = ChatLocationMessageBody.fromJson(map: map);
        break;
      case MessageType.CMD:
        body = ChatCmdMessageBody.fromJson(map: map);
        break;
      case MessageType.CUSTOM:
        body = ChatCustomMessageBody.fromJson(map: map);
        break;
      case MessageType.FILE:
        body = ChatFileMessageBody.fromJson(map: map);
        break;
      case MessageType.IMAGE:
        body = ChatImageMessageBody.fromJson(map: map);
        break;
      case MessageType.VIDEO:
        body = ChatVideoMessageBody.fromJson(map: map);
        break;
      case MessageType.VOICE:
        body = ChatVoiceMessageBody.fromJson(map: map);
        break;
      case MessageType.COMBINE:
        body = CombineMessageBody.fromJson(map: map);
        break;
    }

    return body;
  }

  @override
  String toString() {
    return toJson().toString();
  }

  /// ~english
  /// Gets the Reaction list.
  ///
  /// **Return** The Reaction list
  ///
  /// **Throws** A description of the exception. See [ChatError]
  /// ~end
  ///
  /// ~chinese
  /// 获取 Reaction 列表。
  ///
  /// **Return** Reaction 列表。
  ///
  /// **Throws** 如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [ChatError]。
  /// ~end
  Future<List<ChatMessageReaction>> reactionList() async {
    try {
      Map req = {"msgId": msgId};
      Map result = await platform_interface.Client.instance.messageManager.callNativeMethod(
        ChatMethodKeys.getReactionList,
        req,
      );
      ChatError.hasErrorFromResult(result);
      List<ChatMessageReaction> list = [];
      result[ChatMethodKeys.getReactionList]?.forEach(
        (element) => list.add(
          ChatMessageReaction.fromJson(element),
        ),
      );
      return list;
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Gets the number of members that have read the group message.
  ///
  /// **Return** group ack count
  ///
  /// **Throws** A description of the exception. See [ChatError]
  /// ~end
  ///
  /// ~chinese
  /// 获取群消息已读人数。
  ///
  /// **Return** 群消息已读人数。
  ///
  /// **Throws** 如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [ChatError]。
  /// ~end
  Future<int> groupAckCount() async {
    try {
      Map req = {"msgId": msgId};
      Map result = await platform_interface.Client.instance.messageManager
          .callNativeMethod(ChatMethodKeys.groupAckCount, req);
      ChatError.hasErrorFromResult(result);
      if (result.containsKey(ChatMethodKeys.groupAckCount)) {
        return result[ChatMethodKeys.groupAckCount];
      } else {
        return 0;
      }
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Get an overview of the thread in the message (currently only supported by group messages)
  ///
  /// **Return** overview of the thread
  ///
  /// **Throws** A description of the exception. See [ChatError]
  /// ~end
  ///
  /// ~chinese
  /// 获得消息中的子区概述。
  ///
  /// @note
  /// 目前，该方法只适用于群组消息。
  ///
  /// **Return** 子区概述内容。
  ///
  /// **Throws** 如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [ChatError]。
  /// ~end
  Future<ChatThread?> chatThread() async {
    try {
      Map req = {"msgId": msgId};
      Map result = await platform_interface.Client.instance.messageManager
          .callNativeMethod(ChatMethodKeys.getChatThread, req);
      ChatError.hasErrorFromResult(result);
      if (result.containsKey(ChatMethodKeys.getChatThread)) {
        return result.getValue<ChatThread>(ChatMethodKeys.getChatThread,
            callback: (obj) => ChatThread.fromJson(obj));
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }
}

abstract class ChatMessageBody {
  ChatMessageBody({required this.type});

  ChatMessageBody.fromJson({
    required Map map,
    required this.type,
  }) {
    _operatorTime = map["operatorTime"];
    _operatorId = map["operatorId"];
    _operatorCount = map["operatorCount"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type.index;
    return data;
  }

  @override
  String toString() {
    return toJson().toString();
  }

  /// ~english
  /// Gets the chat message type.
  /// ~end
  ///
  /// ~chinese
  /// 获取消息类型。
  /// ~end
  MessageType type;

  /// ~english
  /// Get the user ID of the operator that modified the message last time.
  /// ~end
  ///
  /// ~chinese
  /// 获取最后一次消息修改的操作者的用户 ID。
  /// ~end
  String? _operatorId;

  /// ~english
  /// Get the UNIX timestamp of the last message modification, in milliseconds.
  /// ~end
  ///
  /// ~chinese
  /// 获取最后一次消息修改的时间戳，单位为毫秒。
  /// ~end
  int? _operatorTime;

  /// ~english
  /// Get the number of times a message is modified.
  /// ~end
  ///
  /// ~chinese
  /// 获取消息修改次数。
  /// ~end
  int? _operatorCount;
}

/// ~english
/// The command message body.
/// ~end
///
/// ~chinese
/// 命令消息体类。
/// ~end
class ChatCmdMessageBody extends ChatMessageBody {
  /// ~english
  /// Creates a command message.
  /// ~end
  ///
  /// ~chinese
  /// 创建一个命令消息。
  /// ~end
  ChatCmdMessageBody({required this.action, this.deliverOnlineOnly = false})
      : super(type: MessageType.CMD);

  ChatCmdMessageBody.fromJson({required Map map})
      : super.fromJson(map: map, type: MessageType.CMD) {
    action = map["action"];
    deliverOnlineOnly = map["deliverOnlineOnly"] ?? false;
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.putIfNotNull("action", action);
    data.putIfNotNull("deliverOnlineOnly", deliverOnlineOnly);

    return data;
  }

  /// ~english
  /// The command action content.
  /// ~end
  ///
  /// ~chinese
  /// 命令内容。
  /// ~end
  late final String action;

  /// ~english
  /// Checks whether this command message is only delivered to online users.
  ///
  /// - `true`: Yes.
  /// - `false`: No.
  /// ~end
  ///
  /// ~chinese
  /// 判断当前 CMD 类型消息是否只投递在线用户。
  ///
  /// - `true`：是；
  /// - `false`：否。
  /// ~end
  bool deliverOnlineOnly = false;
}

/// ~english
/// The location message class.
/// ~end
///
/// ~chinese
/// 位置消息类。
/// ~end
class ChatLocationMessageBody extends ChatMessageBody {
  /// ~english
  /// Creates a location message body instance.
  ///
  /// Param [latitude] The latitude.
  ///
  /// Param [longitude] The longitude.
  ///
  /// Param [address] The address.
  ///
  /// Param [buildingName] The building name.
  /// ~end
  ///
  /// ~chinese
  /// 创建一个位置消息体实例。
  ///
  /// Param [latitude] 纬度。
  ///
  /// Param [longitude] 经度。
  ///
  /// Param [address] 地址。
  ///
  /// Param [buildingName] 建筑物名称。
  /// ~end
  ChatLocationMessageBody({
    required this.latitude,
    required this.longitude,
    String? address,
    String? buildingName,
  }) : super(type: MessageType.LOCATION) {
    _address = address;
    _buildingName = buildingName;
  }

  ChatLocationMessageBody.fromJson({required Map map})
      : super.fromJson(map: map, type: MessageType.LOCATION) {
    latitude = (map["latitude"] ?? 0).toDouble();
    longitude = (map["longitude"] ?? 0).toDouble();
    _address = map["address"];
    _buildingName = map["buildingName"];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data.putIfNotNull("address", _address);
    data.putIfNotNull("buildingName", _buildingName);
    return data;
  }

  String? _address;
  String? _buildingName;

  /// ~english
  /// The address.
  /// ~end
  ///
  /// ~chinese
  /// 地址。
  /// ~end
  String? get address => _address;

  /// ~english
  /// The building name.
  /// ~end
  ///
  /// ~chinese
  /// 建筑物名称。
  /// ~end
  String? get buildingName => _buildingName;

  /// ~english
  /// The latitude.
  /// ~end
  ///
  /// ~chinese
  /// 纬度。
  /// ~end
  late final double latitude;

  /// ~english
  /// The longitude.
  /// ~end
  ///
  /// ~chinese
  /// 经度。
  /// ~end
  late final double longitude;
}

/// ~english
/// The base class of file messages.
/// ~end
///
/// ~chinese
/// 文件类消息的基类。
/// ~end
class ChatFileMessageBody extends ChatMessageBody {
  /// ~english
  /// Creates a message with an attachment.
  ///
  /// Param [localPath] The path of the image file.
  ///
  /// Param [displayName] The file name.
  ///
  /// Param [fileSize] The size of the file in bytes.
  ///
  /// Param [type] The file type.
  /// ~end
  ///
  /// ~chinese
  /// 创建一条带文件附件的消息。
  ///
  /// Param [localPath] 图片文件路径。
  ///
  /// Param [displayName] 文件显示名称。
  ///
  /// Param [fileSize] 文件大小，单位是字节。
  ///
  /// Param [type] 文件类型。
  /// ~end
  ChatFileMessageBody({
    required this.localPath,
    this.displayName,
    this.fileSize,
    super.type = MessageType.FILE,
  });

  ChatFileMessageBody.fromJson({required Map map, super.type = MessageType.FILE})
      : super.fromJson(map: map) {
    secret = map["secret"];
    remotePath = map["remotePath"];
    fileSize = map["fileSize"];
    localPath = map["localPath"] ?? "";
    displayName = map["displayName"];
    fileStatus = DownloadStatus.values[map["fileStatus"]];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.putIfNotNull("secret", secret);
    data.putIfNotNull("remotePath", remotePath);
    data.putIfNotNull("fileSize", fileSize);
    data.putIfNotNull("localPath", localPath);
    data.putIfNotNull("displayName", displayName);
    data.putIfNotNull("fileStatus", fileStatus.index);

    return data;
  }

  /// ~english
  /// The local path of the attachment.
  /// ~end
  ///
  /// ~chinese
  /// 附件的本地路径。
  /// ~end
  late final String localPath;

  /// ~english
  /// The token used to get the attachment.
  /// ~end
  ///
  /// ~chinese
  /// 获取附件的密钥。
  /// ~end
  String? secret;

  /// ~english
  /// The attachment path in the server.
  /// ~end
  ///
  /// ~chinese
  /// 附件的服务器路径。
  /// ~end
  String? remotePath;

  /// ~english
  /// The download status of the attachment.
  /// ~end
  ///
  /// ~chinese
  /// 附件的下载状态。
  /// ~end
  DownloadStatus fileStatus = DownloadStatus.PENDING;

  /// ~english
  /// The size of the attachment in bytes.
  /// ~end
  ///
  /// ~chinese
  /// 附件的大小，以字节为单位。
  /// ~end
  int? fileSize;

  /// ~english
  /// The attachment name.
  /// ~end
  ///
  /// ~chinese
  /// 附件的名称。
  /// ~end
  String? displayName;
}

/// ~english
/// The image message body class.
/// ~end
///
/// ~chinese
/// 图片消息体类。
/// ~end
class ChatImageMessageBody extends ChatFileMessageBody {
  /// ~english
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
  /// ~end
  ///
  /// ~chinese
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
  /// ~end
  ChatImageMessageBody({
    required super.localPath,
    super.displayName,
    this.thumbnailLocalPath,
    this.sendOriginalImage = false,
    super.fileSize,
    this.width,
    this.height,
    this.isGif = false,
  }) : super(
          type: MessageType.IMAGE,
        );

  ChatImageMessageBody.fromJson({required Map map})
      : super.fromJson(map: map, type: MessageType.IMAGE) {
    thumbnailLocalPath = map["thumbnailLocalPath"];
    thumbnailRemotePath = map["thumbnailRemotePath"];
    thumbnailSecret = map["thumbnailSecret"];
    sendOriginalImage = map["sendOriginalImage"] ?? false;
    height = (map["height"] ?? 0).toDouble();
    width = (map["width"] ?? 0).toDouble();
    thumbnailStatus = DownloadStatus.values[map["thumbnailStatus"]];
    isGif = map["isGif"] ?? false;
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.putIfNotNull("thumbnailLocalPath", thumbnailLocalPath);
    data.putIfNotNull("thumbnailRemotePath", thumbnailRemotePath);
    data.putIfNotNull("thumbnailSecret", thumbnailSecret);
    data.putIfNotNull("sendOriginalImage", isGif ? true : sendOriginalImage);
    data.putIfNotNull("height", height ?? 0.0);
    data.putIfNotNull("width", width ?? 0.0);
    data.putIfNotNull("thumbnailStatus", thumbnailStatus.index);
    data.putIfNotNull('isGif', isGif);
    return data;
  }

  /// ~english
  /// Whether to send the original image.
  ///
  /// - (default) `false`: No. The original image will be compressed if it exceeds 100 KB and the thumbnail will be sent.
  /// - `true`: Yes.
  /// ~end
  ///
  /// ~chinese
  /// 设置发送图片时，是否发送原图。
  /// - （默认）`false`：图片小于 100 KB 时，发送原图和缩略图；图片大于 100 KB 时，发送压缩后的图片和压缩后图片的缩略图。
  ///  - `true`：发送原图和缩略图。
  /// ~end
  bool sendOriginalImage = false;

  /// ~english
  /// The local path or the URI (a string) of the thumbnail.
  /// ~end
  ///
  /// ~chinese
  /// 缩略图的本地路径或者字符串形式的资源标识符。
  /// ~end
  String? thumbnailLocalPath;

  /// ~english
  /// The URL of the thumbnail on the server.
  /// ~end
  ///
  /// ~chinese
  /// 缩略图的服务器路径。
  /// ~end
  String? thumbnailRemotePath;

  /// ~english
  /// The secret to access the thumbnail. A secret is required for verification for thumbnail download.
  /// ~end
  ///
  /// ~chinese
  /// 设置访问缩略图的密钥。下载缩略图时用户需要提供密钥进行校验。
  /// ~end
  String? thumbnailSecret;

  /// ~english
  /// The download status of the thumbnail.
  /// ~end
  ///
  /// ~chinese
  /// 缩略图的下载状态。
  /// ~end
  DownloadStatus thumbnailStatus = DownloadStatus.PENDING;

  /// ~english
  /// The image width in pixels.
  /// ~end
  ///
  /// ~chinese
  /// 图片宽度，单位为像素。
  /// ~end
  double? width;

  /// ~english
  /// The image height in pixels.
  /// ~end
  ///
  /// ~chinese
  /// 图片高度，单位为像素。
  /// ~end
  double? height;

  /// ~english
  /// ~end
  /// ~chinese
  /// ~end
  bool isGif = false;
}

/// ~english
/// The text message class.
/// ~end
///
/// ~chinese
/// 文本消息类。
/// ~end
class ChatTextMessageBody extends ChatMessageBody {
  /// ~english
  /// Creates a text message.
  ///
  /// Param [content] The text content.
  /// ~end
  ///
  /// ~chinese
  /// 创建一条文本消息。
  ///
  /// Param [content] 文本消息内容。
  /// ~end
  ChatTextMessageBody({
    required this.content,
    this.targetLanguages,
  }) : super(type: MessageType.TXT);

  ChatTextMessageBody.fromJson({required Map map})
      : super.fromJson(map: map, type: MessageType.TXT) {
    content = map["content"] ?? "";
    targetLanguages = map.getList("targetLanguages");
    if (map.containsKey("translations")) {
      translations = map["translations"]?.cast<String, String>();
    }
  }

  @override

  ///@nodoc
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['content'] = content;
    data.putIfNotNull("targetLanguages", targetLanguages);
    data.putIfNotNull("translations", translations);
    return data;
  }

  /// ~english
  /// The text content.
  /// ~end
  ///
  /// ~chinese
  /// 文本消息内容。
  /// ~end
  late final String content;

  /// ~english
  /// The target languages for translation.
  /// ~end
  ///
  /// ~chinese
  /// 翻译的目标语言。
  /// ~end
  List<String>? targetLanguages;

  /// ~english
  /// It is Map, where the key is target language and the value is translated content.
  /// ~end
  ///
  /// ~chinese
  /// 译文。
  /// ~end
  Map<String, String>? translations;

  /// ~english
  /// Gets the user ID of the operator that modified the message last time.
  /// ~end
  ///
  /// ~chinese
  /// 获取最后一次消息修改的操作者的用户 ID。
  /// ~end
  String? get lastModifyOperatorId => _operatorId;

  /// ~english
  /// Gets the UNIX timestamp of the last message modification, in milliseconds.
  /// ~end
  ///
  /// ~chinese
  /// 获取最后一次消息修改的时间戳，单位为毫秒。
  /// ~end
  int? get lastModifyTime => _operatorTime;

  /// ~english
  /// Gets the number of times a message is modified.
  /// ~end
  ///
  /// ~chinese
  /// 获取消息修改次数。
  /// ~end
  int? get modifyCount => _operatorCount;
}

/// ~english
/// The video message body class.
/// ~end
///
/// ~chinese
/// 视频消息体类。
/// ~end
class ChatVideoMessageBody extends ChatFileMessageBody {
  /// ~english
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
  /// ~end
  ///
  /// ~chinese
  /// 创建一条视频消息。
  ///
  /// Param [localPath] 视频文件本地路径。
  ///
  /// Param [displayName] 视频名称。
  ///
  /// Param [duration] 视频时长，单位为秒。
  ///
  /// Param [fileSize] 视频文件大小，单位是字节。
  ///
  /// Param [thumbnailLocalPath] 视频缩略图本地路径。
  ///
  /// Param [height] 视频高度，单位是像素。
  ///
  /// Param [width] 视频宽度，单位是像素。
  /// ~end
  ChatVideoMessageBody({
    required super.localPath,
    super.displayName,
    this.duration = 0,
    super.fileSize,
    this.thumbnailLocalPath,
    this.height,
    this.width,
  }) : super(
          type: MessageType.VIDEO,
        );

  ChatVideoMessageBody.fromJson({required Map map})
      : super.fromJson(map: map, type: MessageType.VIDEO) {
    duration = map["duration"];
    thumbnailLocalPath = map["thumbnailLocalPath"];
    thumbnailRemotePath = map["thumbnailRemotePath"];
    thumbnailSecret = map["thumbnailSecret"];
    height = (map["height"] ?? 0).toDouble();
    width = (map["width"] ?? 0).toDouble();
    thumbnailStatus = DownloadStatus.values[map["thumbnailStatus"]];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.putIfNotNull("duration", duration);
    data.putIfNotNull("thumbnailLocalPath", thumbnailLocalPath);
    data.putIfNotNull("thumbnailRemotePath", thumbnailRemotePath);
    data.putIfNotNull("thumbnailSecret", thumbnailSecret);
    data.putIfNotNull("height", height ?? 0.0);
    data.putIfNotNull("width", width ?? 0.0);
    data.putIfNotNull("thumbnailStatus", thumbnailStatus.index);

    return data;
  }

  /// ~english
  /// The video duration in seconds.
  /// ~end
  ///
  /// ~chinese
  /// 视频时长，单位是秒。
  /// ~end
  int? duration;

  /// ~english
  /// The local path of the video thumbnail.
  /// ~end
  ///
  /// ~chinese
  /// 视频缩略图的本地路径。
  /// ~end
  String? thumbnailLocalPath;

  /// ~english
  /// The URL of the thumbnail on the server.
  /// ~end
  ///
  /// ~chinese
  /// 视频缩略图的在服务器上的存储路径。
  /// ~end
  String? thumbnailRemotePath;

  /// ~english
  /// The secret key of the video thumbnail.
  /// ~end
  ///
  /// ~chinese
  /// 视频缩略图的密钥。
  /// ~end
  String? thumbnailSecret;

  /// ~english
  /// The download status of the video thumbnail.
  /// ~end
  ///
  /// ~chinese
  /// 视频缩略图的下载状态。
  /// ~end
  DownloadStatus thumbnailStatus = DownloadStatus.PENDING;

  /// ~english
  /// The video width in pixels.
  /// ~end
  ///
  /// ~chinese
  /// 视频宽度，单位是像素。
  /// ~end
  double? width;

  /// ~english
  /// The video height in pixels.
  /// ~end
  ///
  /// ~chinese
  /// 视频高度，单位是像素。
  /// ~end
  double? height;
}

/// ~english
/// The voice message body class.
/// ~end
///
/// ~chinese
/// 语音消息体类。
/// ~end
class ChatVoiceMessageBody extends ChatFileMessageBody {
  /// ~english
  /// Creates a voice message.
  ///
  /// Param [localPath] The local path of the voice file.
  ///
  /// Param [displayName] The name of the voice file.
  ///
  /// Param [fileSize] The size of the voice file in bytes.
  ///
  /// Param [duration] The voice duration in seconds.
  /// ~end
  ///
  /// ~chinese
  /// 创建一条语音消息。
  ///
  /// Param [localPath] 语言消息本地路径。
  ///
  /// Param [displayName] 语音文件名。
  ///
  /// Param [duration] 语音时长，单位是秒。
  ///
  /// Param [fileSize] 语音文件大小，单位是字节。
  /// ~end
  ChatVoiceMessageBody({
    required super.localPath,
    this.duration = 0,
    super.displayName,
    super.fileSize,
  }) : super(
          type: MessageType.VOICE,
        );

  ChatVoiceMessageBody.fromJson({required Map map})
      : super.fromJson(map: map, type: MessageType.VOICE) {
    duration = map["duration"] ?? 0;
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.putIfNotNull("duration", duration);
    return data;
  }

  /// ~english
  /// The voice duration in seconds.
  /// ~end
  ///
  /// ~chinese
  /// 语音时长，单位是秒。
  /// ~end
  late final int duration;
}

/// ~english
/// The custom message body.
/// ~end
///
/// ~chinese
/// 自定义消息体类。
/// ~end
class ChatCustomMessageBody extends ChatMessageBody {
  /// ~english
  /// Creates a custom message.
  /// ~end
  ///
  /// ~chinese
  /// 自定义消息体类。
  /// ~end
  ChatCustomMessageBody({
    required this.event,
    this.params,
  }) : super(type: MessageType.CUSTOM);
  ChatCustomMessageBody.fromJson({required Map map})
      : super.fromJson(map: map, type: MessageType.CUSTOM) {
    event = map["event"];
    params = map["params"]?.cast<String, String>();
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.putIfNotNull("event", event);
    data.putIfNotNull("params", params);

    return data;
  }

  /// ~english
  /// The event.
  /// ~end
  ///
  /// ~chinese
  /// 自定义事件内容。
  /// ~end
  late final String event;

  /// ~english
  /// The custom params map.
  /// ~end
  ///
  /// ~chinese
  /// 自定义消息的键值对 Map 列表。
  /// ~end
  Map<String, String>? params;
}

class CombineMessageBody extends ChatMessageBody {
  CombineMessageBody({
    this.title,
    this.summary,
    this.fileStatus = DownloadStatus.PENDING,
    List<String>? messageList,
    String? compatibleText,
  })  : _compatibleText = compatibleText,
        _messageList = messageList,
        super(type: MessageType.COMBINE);

  final String? title;
  final String? summary;
  final DownloadStatus fileStatus;
  final List<String>? _messageList;
  late final String? _compatibleText;

  String? _localPath;
  String? _remotePath;
  String? _secret;

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.putIfNotNull("title", title);
    data.putIfNotNull("summary", summary);
    data.putIfNotNull("messageList", _messageList);
    data.putIfNotNull("compatibleText", _compatibleText);
    data.putIfNotNull("localPath", _localPath);
    data.putIfNotNull("remotePath", _remotePath);
    data.putIfNotNull("secret", _secret);
    data.putIfNotNull("fileStatus", fileStatus.index);
    return data;
  }

  factory CombineMessageBody.fromJson({required Map map}) {
    var body = CombineMessageBody(
      title: map["title"],
      summary: map["summary"],
      fileStatus: DownloadStatus.values[map["fileStatus"]],
    );
    body._localPath = map["localPath"];
    body._remotePath = map["remotePath"];
    body._secret = map["secret"];

    return body;
  }
}
