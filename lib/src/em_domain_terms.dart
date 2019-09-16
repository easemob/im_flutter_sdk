import 'dart:collection';

import 'package:flutter/cupertino.dart';

/// EMOptions - options to initialize SDK context.
class EMOptions {
  EMOptions({
    this.acceptInvitationAlways = true,
    this.allowChatroomOwnerLeave,
    @required this.appKey,
    this.autoAcceptGroupInvitation,
    this.autoDownloadThumbnail = true,
    this.autoLogin,
    this.autoTransferMessageAttachments = true,
    this.deleteMessagesAsExitGroup,
    this.fcmNumber,
    this.imServer,
    this.imPort,
    //this.miPushConfig,
    //this.pushConfig,
    this.requireAck = true,
    this.requireDeliveryAck = false,
    this.restServer,
    this.sortMessageByServerTime = false,
    this.useFcm,
    this.usingHttpsOnly = false,
  });

  bool acceptInvitationAlways;
  String accessToken;
  bool allowChatroomOwnerLeave;
  bool autoDownloadThumbnail;
  bool autoLogin;
  bool autoTransferMessageAttachments;
  String appKey;
  bool autoAcceptGroupInvitation;
  bool deleteMessagesAsExitGroup;
  String dnsUrl;
  bool enableDNSConfig;
  String fcmNumber;
  int imPort;
  String imServer;
  //EMMipushConfig miPushConfig;
  //EMPushConfig pushConfig;
  bool requireAck;
  bool requireDeliveryAck;
  String restServer;
  bool sortMessageByServerTime;
  bool useFcm;
  bool usingHttpsOnly;

  bool _useHttps;
  set useHttps(bool _use) => _useHttps = _use;

  String _version;
  String get version {
    return _version;
  }
}

/// EMMessage - various types of message
class EMMessage {
  EMMessage({
    this.acked = false,
    this.body,
    this.chatType = ChatType.Chat,
    this.delivered = false,
    this.direction = Direction.SEND,
    this.from = '',
    this.listened = false,
    this.localTime,
    this.msgId = '',
    this.msgTime,
    this.progress = 0,
    this.status = Status.CREATE,
    this.to = '',
    Type type,
    this.unread = true,
  })  : _attributes = HashMap<String, dynamic>(),
        _conversationId = '',
        _deliverAcked = false,
        _type = type,
        _userName = '';

  /// Constructors to create various of messages.
  EMMessage.createSendMessage(Type type)
      : this(type: type, direction: Direction.SEND);
  EMMessage.createReceiveMessage(Type type)
      : this(type: type, direction: Direction.RECEIVE);
  EMMessage.createTxtSendMessage(String content, String userName)
      : this(direction: Direction.SEND);
  EMMessage.createVoiceSendMessage(
      String filePath, int timeLength, String userName)
      : this(direction: Direction.SEND);
  EMMessage.createImageSendMessage(
      String filePath, bool sendOriginalImage, String userName)
      : this(direction: Direction.SEND);
  EMMessage.createVideoSendMessage(String videoFilePath, String imageThumbPath,
      int timeLength, String userName)
      : this(direction: Direction.SEND);
  EMMessage.createLocationSendMessage(double latitude, double longitude,
      String locationAddress, String userName)
      : this(direction: Direction.SEND);
  EMMessage.createFileSendMessage(String filePath, String userName)
      : this(direction: Direction.SEND);

  bool _deliverAcked;
  set deliverAcked(bool acked) {
    _deliverAcked = acked;
  }

  final String _conversationId;
  String get conversationId => _conversationId;
  final Type _type;
  Type get type => _type;
  final String _userName;
  String get userName => _userName;

  bool acked;
  EMMessageBody body;
  ChatType chatType;
  bool delivered;
  Direction direction;
  String from;
  bool listened;
  int localTime;
  String msgId;
  int msgTime;
  int progress;
  Status status;
  String to;
  bool unread;

  /// attributes holding arbitrary key/value pair
  final Map<String, dynamic> _attributes;

  void setAttribute(String attr, dynamic value) {
    _attributes[attr] = value;
  }

  dynamic getAttribute(String attr) {
    return _attributes[attr];
  }

  Map<String, dynamic> ext() {
    return null;
  }
}

// EMMessageBody - body of message.
abstract class EMMessageBody {}

/// Type - EMMessage type enumeration.
enum Type {
  TXT,
  IMAGE,
  VIDEO,
  LOCATION,
  VOICE,
  FILE,
  CMD,
}

/// Status - EMMessage status enumeration.
enum Status {
  SUCCESS,
  FAIL,
  INPROGRESS,
  CREATE,
}

/// ChatType - EMMessage chat type enumeration.
enum ChatType { Chat, GroupChat, ChatRoom }

/// Direction - EMMessage direction enumeration.
enum Direction { SEND, RECEIVE }

/// EMDownloadStatus - download status enumeration.
enum EMDownloadStatus { DOWNLOADING, SUCCESSED, FAILED, PENDING }
