import '../internal/inner_headers.dart';

class EMMessage {
  EMMessage({
    required this.from,
    required this.to,
    MessageDirection direction = MessageDirection.SEND,
    String? msgId,
    required this.chatType,
    MessageStatus? status,
    required this.body,
    this.attributes,
    bool? hasRead,
    bool? hasReadAck,
    bool? needGroupAck,
    bool? hasDeliverAck,
    int? localTime,
    int? serverTime,
    bool? isChatThreadMessage,
    bool? onlineState,
    ChatRoomMessagePriority? priority,
  })  : this.conversationId = direction == MessageDirection.SEND ? to : from,
        this.direction = direction,
        this.msgId = msgId ?? EMTools.randomId,
        this.status = MessageStatus.SUCCESS,
        this.messageType = body.type,
        this.hasRead = hasRead ?? true,
        this.hasReadAck = hasReadAck ?? true,
        this.needGroupAck = needGroupAck ?? false,
        this.hasDeliverAck = hasDeliverAck ?? false,
        this.localTime = localTime ?? EMTools.millisecondsSinceEpoch,
        this.serverTime = serverTime ?? EMTools.millisecondsSinceEpoch,
        this.isChatThreadMessage = isChatThreadMessage ?? false,
        this.onlineState = onlineState ?? true,
        this.priority = priority ?? ChatRoomMessagePriority.High;

  EMMessage.createSendMessage({
    required this.body,
    required String targetId,
    String? msgId,
    MessageStatus status = MessageStatus.CREATE,
    this.chatType = ChatType.Chat,
    this.attributes,
    bool? hasRead,
    bool? hasReadAck,
    bool? needGroupAck,
    bool? hasDeliverAck,
    int? localTime,
    int? serverTime,
    bool? isChatThreadMessage,
    bool? onlineState,
    ChatRoomMessagePriority? priority,
  })  : this.to = targetId,
        this.from = EMClient.getInstance.currentUserId!,
        this.conversationId = targetId,
        this.messageType = body.type,
        this.direction = MessageDirection.SEND,
        this.msgId = msgId ?? EMTools.randomId,
        this.status = status,
        this.hasRead = hasRead ?? true,
        this.hasReadAck = hasReadAck ?? true,
        this.needGroupAck = needGroupAck ?? false,
        this.hasDeliverAck = hasDeliverAck ?? false,
        this.localTime = localTime ?? EMTools.millisecondsSinceEpoch,
        this.serverTime = serverTime ?? EMTools.millisecondsSinceEpoch,
        this.isChatThreadMessage = isChatThreadMessage ?? false,
        this.onlineState = onlineState ?? true,
        this.priority = priority ?? ChatRoomMessagePriority.High;

  EMMessage.createReceiveMessage({
    required this.body,
    required String fromId,
    String? msgId,
    MessageStatus status = MessageStatus.SUCCESS,
    this.chatType = ChatType.Chat,
    this.attributes,
    bool? hasRead,
    bool? hasReadAck,
    bool? needGroupAck,
    bool? hasDeliverAck,
    int? localTime,
    int? serverTime,
    bool? isChatThreadMessage,
    bool? onlineState,
    ChatRoomMessagePriority? priority,
  })  : this.to = EMClient.getInstance.currentUserId!,
        this.from = fromId,
        this.conversationId = fromId,
        this.messageType = body.type,
        this.direction = MessageDirection.RECEIVE,
        this.msgId = msgId ?? EMTools.randomId,
        this.status = status,
        this.hasRead = hasRead ?? true,
        this.hasReadAck = hasReadAck ?? true,
        this.needGroupAck = needGroupAck ?? false,
        this.hasDeliverAck = hasDeliverAck ?? true,
        this.localTime = localTime ?? EMTools.millisecondsSinceEpoch,
        this.serverTime = serverTime ?? EMTools.millisecondsSinceEpoch,
        this.isChatThreadMessage = isChatThreadMessage ?? false,
        this.onlineState = onlineState ?? true,
        this.priority = priority ?? ChatRoomMessagePriority.High;

  EMMessage.createTxtSendMessage({
    required String targetId,
    required ChatType chatType,
    bool? needGroupAck,
    bool? isChatThreadMessage,
    ChatRoomMessagePriority? priority,
    Map<String, dynamic>? attributes,
    required String content,
    List<String>? targetLanguages,
  }) : this.createSendMessage(
            body: EMTextMessageBody(content, targetLanguages: targetLanguages),
            targetId: targetId,
            chatType: chatType,
            status: MessageStatus.CREATE,
            needGroupAck: needGroupAck,
            isChatThreadMessage: isChatThreadMessage,
            priority: priority,
            attributes: attributes);

  EMMessage.createLocationSendMessage({
    required String targetId,
    required ChatType chatType,
    bool? needGroupAck,
    bool? isChatThreadMessage,
    ChatRoomMessagePriority? priority,
    Map<String, dynamic>? attributes,
    required double latitude,
    required double longitude,
    String? address,
    String? buildingName,
  }) : this.createSendMessage(
            body: EMLocationMessageBody(
                latitude: latitude,
                longitude: longitude,
                address: address,
                buildingName: buildingName),
            targetId: targetId,
            chatType: chatType,
            status: MessageStatus.CREATE,
            needGroupAck: needGroupAck,
            isChatThreadMessage: isChatThreadMessage,
            priority: priority,
            attributes: attributes);

  EMMessage.createCustomSendMessage({
    required String targetId,
    required ChatType chatType,
    bool? needGroupAck,
    bool? isChatThreadMessage,
    ChatRoomMessagePriority? priority,
    Map<String, dynamic>? attributes,
    required String event,
    Map<String, String>? params,
  }) : this.createSendMessage(
            body: EMCustomMessageBody(event: event, params: params),
            targetId: targetId,
            chatType: chatType,
            status: MessageStatus.CREATE,
            needGroupAck: needGroupAck,
            isChatThreadMessage: isChatThreadMessage,
            priority: priority,
            attributes: attributes);

  EMMessage.createCmdSendMessage({
    required String targetId,
    required ChatType chatType,
    bool? needGroupAck,
    bool? isChatThreadMessage,
    ChatRoomMessagePriority? priority,
    Map<String, dynamic>? attributes,
    required String action,
    bool deliverOnlineOnly = false,
  }) : this.createSendMessage(
            body: EMCmdMessageBody(
                action: action, deliverOnlineOnly: deliverOnlineOnly),
            targetId: targetId,
            chatType: chatType,
            status: MessageStatus.CREATE,
            needGroupAck: needGroupAck,
            isChatThreadMessage: isChatThreadMessage,
            priority: priority,
            attributes: attributes);

  EMMessage.createFileSendMessage({
    required String targetId,
    required ChatType chatType,
    bool? needGroupAck,
    bool? isChatThreadMessage,
    ChatRoomMessagePriority? priority,
    Map<String, dynamic>? attributes,
    required String displayName,
    required String localPath,
  }) : this.createSendMessage(
            body: EMFileMessageBody(
                displayName: displayName, localPath: localPath),
            targetId: targetId,
            chatType: chatType,
            status: MessageStatus.CREATE,
            needGroupAck: needGroupAck,
            isChatThreadMessage: isChatThreadMessage,
            priority: priority,
            attributes: attributes);

  EMMessage.createImageSendMessage({
    required String targetId,
    required ChatType chatType,
    bool? needGroupAck,
    bool? isChatThreadMessage,
    ChatRoomMessagePriority? priority,
    Map<String, dynamic>? attributes,
    required String displayName,
    required String localPath,
    String? thumbnailLocalPath,
    bool sendOriginalImage = false,
    double? width,
    double? height,
  }) : this.createSendMessage(
            body: EMImageMessageBody(
                displayName: displayName,
                localPath: localPath,
                thumbnailLocalPath: thumbnailLocalPath,
                sendOriginalImage: sendOriginalImage,
                width: width,
                height: height),
            targetId: targetId,
            chatType: chatType,
            status: MessageStatus.CREATE,
            needGroupAck: needGroupAck,
            isChatThreadMessage: isChatThreadMessage,
            priority: priority,
            attributes: attributes);

  EMMessage.createVideoSendMessage({
    required String targetId,
    required ChatType chatType,
    bool? needGroupAck,
    bool? isChatThreadMessage,
    ChatRoomMessagePriority? priority,
    Map<String, dynamic>? attributes,
    required String displayName,
    required String localPath,
    required String thumbnailLocalPath,
    required int duration,
    double? width,
    double? height,
  }) : this.createSendMessage(
            body: EMVideoMessageBody(
                displayName: displayName,
                localPath: localPath,
                fileStatus: DownloadStatus.PENDING,
                thumbnailLocalPath: thumbnailLocalPath,
                thumbnailStatus: DownloadStatus.PENDING,
                duration: duration,
                width: width,
                height: height),
            targetId: targetId,
            chatType: chatType,
            status: MessageStatus.CREATE,
            needGroupAck: needGroupAck,
            isChatThreadMessage: isChatThreadMessage,
            priority: priority,
            attributes: attributes);

  EMMessage.createVoiceSendMessage({
    required String targetId,
    required ChatType chatType,
    bool? needGroupAck,
    bool? isChatThreadMessage,
    ChatRoomMessagePriority? priority,
    Map<String, dynamic>? attributes,
    required String displayName,
    required String localPath,
    required int duration,
    int? fileSize,
  }) : this.createSendMessage(
            body: EMVoiceMessageBody(
              displayName: displayName,
              localPath: localPath,
              fileSize: fileSize,
              fileStatus: DownloadStatus.PENDING,
              duration: duration,
            ),
            targetId: targetId,
            chatType: chatType,
            status: MessageStatus.CREATE,
            needGroupAck: needGroupAck,
            isChatThreadMessage: isChatThreadMessage,
            priority: priority,
            attributes: attributes);

  final String from;
  final String to;
  final String conversationId;
  final String msgId;
  final ChatType chatType;
  final MessageDirection direction;
  final MessageStatus status;
  final MessageType messageType;
  final EMMessageBody body;
  final Map<String, dynamic>? attributes;
  final bool hasRead;
  final bool hasReadAck;
  final bool needGroupAck;
  final bool hasDeliverAck;
  final int localTime;
  final int serverTime;
  final bool isChatThreadMessage;
  final bool onlineState;
  final ChatRoomMessagePriority priority;
}

/// @nodoc
abstract class EMMessageBody {
  EMMessageBody({required this.type});

  /// @nodoc
  EMMessageBody.fromJson({
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
  final MessageType type;
}

class EMTextMessageBody extends EMMessageBody {
  EMTextMessageBody(
    this.content, {
    this.targetLanguages,
    this.translations,
  }) : super(type: MessageType.TXT);

  /// The text content.
  final String content;

  /// The target languages to translate
  final List<String>? targetLanguages;

  /// It is Map, key is target language, value is translated content
  final Map<String, String>? translations;

  EMTextMessageBody.fromJson(Map map)
      : content = map["content"] ?? "",
        targetLanguages = map["targetLanguages"],
        translations = map["translations"],
        super.fromJson(type: MessageType.TXT);

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = super.toJson();
    return map;
  }
}

class EMLocationMessageBody extends EMMessageBody {
  EMLocationMessageBody({
    required this.latitude,
    required this.longitude,
    this.address,
    this.buildingName,
  }) : super(type: MessageType.LOCATION);

  /// The latitude.
  final double latitude;

  /// The longitude.
  final double longitude;

  /// The address.
  final String? address;

  /// The building name.
  final String? buildingName;

  EMLocationMessageBody.fromJson(Map map)
      : this.latitude = map["latitude"],
        this.longitude = map["longitude"],
        this.address = map["address"],
        this.buildingName = map["buildingName"],
        super.fromJson(type: MessageType.LOCATION);

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = super.toJson();
    return map;
  }
}

class EMCustomMessageBody extends EMMessageBody {
  EMCustomMessageBody({
    required this.event,
    this.params,
  }) : super(type: MessageType.CUSTOM);

  /// The event.
  final String event;

  /// The custom params map.
  final Map<String, String>? params;

  EMCustomMessageBody.fromJson(Map map)
      : event = map["event"] ?? "",
        params = map["params"],
        super.fromJson(type: MessageType.CUSTOM);

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = super.toJson();
    return map;
  }
}

class EMCmdMessageBody extends EMMessageBody {
  EMCmdMessageBody({
    required this.action,
    this.deliverOnlineOnly = false,
  }) : super(type: MessageType.CMD);

  /// The command action content.
  final String action;

  ///
  /// Checks whether this command message is only delivered to online users.
  ///
  /// - `true`: Yes.
  /// - `false`: No.
  ///
  final bool deliverOnlineOnly;

  EMCmdMessageBody.fromJson(Map map)
      : action = map["action"] ?? "",
        deliverOnlineOnly = map["deliverOnlineOnly"] ?? false,
        super.fromJson(type: MessageType.CMD);

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = super.toJson();
    map.add("action", action);
    map.add("deliverOnlineOnly", deliverOnlineOnly);
    return map;
  }
}

class EMFileMessageBody extends EMMessageBody {
  EMFileMessageBody({
    required this.displayName,
    required this.localPath,
    this.secret,
    this.remotePath,
    this.fileStatus = DownloadStatus.PENDING,
    this.fileSize,
  }) : super(type: MessageType.FILE);

  /// The attachment name.
  final String displayName;

  /// The local path of the attachment.
  final String localPath;

  /// The token used to get the attachment.
  final String? secret;

  /// The attachment path in the server.
  final String? remotePath;

  /// The download status of the attachment.
  final DownloadStatus fileStatus;

  ///  The size of the attachment in bytes.
  final int? fileSize;

  EMFileMessageBody.fromJson(Map map)
      : displayName = map["displayName"] ?? "",
        localPath = map["localPath"] ?? "",
        secret = map["secret"],
        remotePath = map["remotePath"],
        fileSize = map["fileSize"],
        fileStatus = downloadStatusFromInt(map["fileStatus"]),
        super.fromJson(type: MessageType.FILE);

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = super.toJson();
    return map;
  }
}

class EMImageMessageBody extends EMMessageBody {
  EMImageMessageBody({
    required this.displayName,
    required this.localPath,
    this.secret,
    this.remotePath,
    this.fileStatus = DownloadStatus.PENDING,
    this.fileSize,
    this.sendOriginalImage = false,
    this.thumbnailLocalPath,
    this.thumbnailRemotePath,
    this.thumbnailSecret,
    this.thumbnailStatus = DownloadStatus.PENDING,
    this.width,
    this.height,
  }) : super(type: MessageType.IMAGE);

  /// The attachment name.
  final String displayName;

  /// The local path of the attachment.
  final String localPath;

  /// The token used to get the attachment.
  final String? secret;

  /// The attachment path in the server.
  final String? remotePath;

  /// The download status of the attachment.
  final DownloadStatus fileStatus;

  ///  The size of the attachment in bytes.
  final int? fileSize;

  ///
  /// Whether to send the original image.
  ///
  /// - `false`: (default) No. The original image will be compressed if it exceeds 100 KB and the thumbnail will be sent.
  /// - `true`: Yes.
  ///
  final bool sendOriginalImage;

  /// The local path or the URI (a string) of the thumbnail.
  final String? thumbnailLocalPath;

  /// The URL of the thumbnail on the server.
  final String? thumbnailRemotePath;

  /// The secret to access the thumbnail. A secret is required for verification for thumbnail download.
  final String? thumbnailSecret;

  /// The download status of the thumbnail.
  final DownloadStatus thumbnailStatus;

  /// The image width in pixels.
  final double? width;

  /// The image height in pixels.
  final double? height;

  EMImageMessageBody.fromJson(Map map)
      : displayName = map["displayName"] ?? "",
        localPath = map["localPath"] ?? "",
        secret = map["secret"],
        remotePath = map["remotePath"],
        fileSize = map["fileSize"],
        fileStatus = downloadStatusFromInt(map["fileStatus"]),
        sendOriginalImage = map["sendOriginalImage"] ?? false,
        thumbnailLocalPath = map["thumbnailLocalPath"],
        thumbnailRemotePath = map["thumbnailRemotePath"],
        thumbnailSecret = map["thumbnailSecret"],
        thumbnailStatus = downloadStatusFromInt(map["thumbnailStatus"]),
        width = map["width"],
        height = map["height"],
        super.fromJson(type: MessageType.IMAGE);

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = super.toJson();
    return map;
  }
}

class EMVideoMessageBody extends EMMessageBody {
  EMVideoMessageBody({
    required this.displayName,
    required this.localPath,
    required this.thumbnailLocalPath,
    required this.duration,
    this.secret,
    this.remotePath,
    this.fileStatus = DownloadStatus.PENDING,
    this.fileSize,
    this.thumbnailRemotePath,
    this.thumbnailSecret,
    this.thumbnailStatus = DownloadStatus.PENDING,
    this.width,
    this.height,
  }) : super(type: MessageType.VIDEO);

  /// The attachment name.
  final String displayName;

  /// The local path of the attachment.
  final String localPath;

  /// The token used to get the attachment.
  final String? secret;

  /// The attachment path in the server.
  final String? remotePath;

  /// The download status of the attachment.
  final DownloadStatus fileStatus;

  ///  The size of the attachment in bytes.
  final int? fileSize;

  /// The local path or the URI (a string) of the thumbnail.
  final String thumbnailLocalPath;

  /// The URL of the thumbnail on the server.
  final String? thumbnailRemotePath;

  /// The secret to access the thumbnail. A secret is required for verification for thumbnail download.
  final String? thumbnailSecret;

  /// The download status of the thumbnail.
  final DownloadStatus thumbnailStatus;

  /// The video duration in seconds.
  final int duration;

  /// The image width in pixels.
  final double? width;

  /// The image height in pixels.
  final double? height;

  EMVideoMessageBody.fromJson(Map map)
      : displayName = map["displayName"] ?? "",
        localPath = map["localPath"] ?? "",
        secret = map["secret"],
        remotePath = map["remotePath"],
        fileSize = map["fileSize"],
        fileStatus = downloadStatusFromInt(map["fileStatus"]),
        thumbnailLocalPath = map["thumbnailLocalPath"],
        thumbnailRemotePath = map["thumbnailRemotePath"],
        thumbnailSecret = map["thumbnailSecret"],
        thumbnailStatus = downloadStatusFromInt(map["thumbnailStatus"]),
        duration = map["duration"] ?? 0,
        width = map["width"],
        height = map["height"],
        super.fromJson(type: MessageType.VIDEO);

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = super.toJson();
    return map;
  }
}

class EMVoiceMessageBody extends EMMessageBody {
  EMVoiceMessageBody({
    required this.displayName,
    required this.localPath,
    required this.duration,
    this.secret,
    this.remotePath,
    this.fileStatus = DownloadStatus.PENDING,
    this.fileSize,
  }) : super(type: MessageType.VOICE);

  /// The attachment name.
  final String displayName;

  /// The local path of the attachment.
  final String localPath;

  /// The token used to get the attachment.
  final String? secret;

  /// The attachment path in the server.
  final String? remotePath;

  /// The download status of the attachment.
  final DownloadStatus fileStatus;

  ///  The size of the attachment in bytes.
  final int? fileSize;

  /// The video duration in seconds.
  final int duration;

  EMVoiceMessageBody.fromJson(Map map)
      : displayName = map["displayName"] ?? "",
        localPath = map["localPath"] ?? "",
        secret = map["secret"],
        remotePath = map["remotePath"],
        fileSize = map["fileSize"],
        fileStatus = downloadStatusFromInt(map["fileStatus"]),
        duration = map["duration"] ?? 0,
        super.fromJson(type: MessageType.VIDEO);

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = super.toJson();
    return map;
  }
}

DownloadStatus downloadStatusFromInt(int? status) {
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
