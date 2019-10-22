import 'dart:collection';
import 'dart:io';

import 'package:flutter/cupertino.dart';

import 'em_message_body.dart';

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
    this.chatType ,
    this.delivered = false,
    this.direction,
    this.from = '',
    this.listened = false,
    this.localTime,
    this.msgId = '',
    this.msgTime,
    this.progress = 0,
    this.status ,
    this.to = '',
    this.type,
    this.unread = true,
  })  : _attributes = HashMap<String, dynamic>(),
        _conversationId = '',
        _deliverAcked = false,
        _typex = type,
        _userName = '';

  /// Constructors to create various of messages.
  EMMessage.createSendMessage(EMMessageType type)
      : this(type: toType(type), direction: toDirect(Direction.SEND));
  EMMessage.createReceiveMessage(EMMessageType type)
      : this(type: toType(type), direction: toDirect(Direction.RECEIVE));
  EMMessage.createTxtSendMessage(String content, String userName)
      : this(
            direction: toDirect(Direction.SEND),
            to: userName,
            type: 0,
            body: EMTextMessageBody(content));
  EMMessage.createVoiceSendMessage(
      String filePath, int timeLength, String userName)
      : this(direction: toDirect(Direction.SEND));
  EMMessage.createImageSendMessage(
      String filePath, bool sendOriginalImage, String userName)
      : this(
            direction: toDirect(Direction.SEND),
            type: toType(EMMessageType.IMAGE),
            body: EMImageMessageBody(File(filePath), null, sendOriginalImage),
            to: userName);
  EMMessage.createVideoSendMessage(String videoFilePath, String imageThumbPath,
      int timeLength, String userName)
      : this(direction: toDirect(Direction.SEND));
  EMMessage.createLocationSendMessage(double latitude, double longitude,
      String locationAddress, String userName)
      : this(
            direction: toDirect(Direction.SEND),
            type: toType(EMMessageType.LOCATION),
            body: EMLocationMessageBody(locationAddress, latitude, longitude),
            to: userName);
  EMMessage.createFileSendMessage(String filePath, String userName)
      : this(
            direction: toDirect(Direction.SEND),
            type: toType(EMMessageType.FILE),
            body: EMNormalFileMessageBody(File(filePath)),
            to: userName);

  bool _deliverAcked;
  set deliverAcked(bool acked) {
    _deliverAcked = acked;
  }

  final String _conversationId;
  String get conversationId => _conversationId;
  final int _typex;
  int get typex => _typex;

  final String _userName;
  String get userName => _userName;

  bool acked;
  EMMessageBody body;
  int chatType;
  bool delivered;
  int direction;
  String from;
  bool listened;
  int localTime;
  String msgId;
  int msgTime;
  int progress;
  int status;
  String to;
  bool unread;
  int type;

  /// attributes holding arbitrary key/value pair
  final Map<String, dynamic> _attributes;

  void setAttribute(String attr, dynamic value) {
    _attributes[attr] = value;
  }

  dynamic getAttribute(String attr) {
    return _attributes[attr];
  }

  /// TODO: setMessageStatusCallback (EMCallBack callback)

  Map<String, dynamic> ext() {
    return null;
  }

  Map<String, dynamic> toDataMap() {
    var result = Map<String, dynamic>();
    result["acked"] = this.acked;
    result['attributes'] = _attributes;
    result['body'] = body.toDataMap();
    result['chatType'] = this.chatType;
    result['conversationId'] = _conversationId;
    result['deliverAcked'] = _deliverAcked;
    result['delivered'] = delivered;
    result['direction'] = direction;
    result['from'] = from;
    result['listened'] = listened;
    result['localTime'] = localTime;
    result['msgId'] = msgId;
    result['msgTime'] = msgTime;
    result['progress'] = progress;
    result['status'] = status;
    result['to'] = to;
    result['type'] = type;
    result['unread'] = unread;
    result['userName'] = _userName;
    return result;
  }

  EMMessage.from(Map<String, dynamic> data)
      :
        _attributes = data['attributes'],
        localTime = data['localTime'],
        chatType = fromChatType(data),
        msgId = data['msgId'],
        progress = data['progress'],
        body = EMMessageBody.from(data['body']),
        delivered = data['delivered'],
        from = data['from'],
        direction = fromDirect(data),
        listened = data['listened'],
        _conversationId = data['conversationId'],
        status = fromEMMessageStatus(data),
        msgTime = data['msgTime'],
        to = data['to'],
        _userName = data['userName'],
        acked = data['acked'],
        _typex = fromType(data),
        unread = data['unread'];
}
  fromType(Map<String, dynamic> data){
      switch(data['type']){
        case 0:
          return EMMessageType.TXT;
        case 1:
          return EMMessageType.IMAGE;
        case 2:
          return EMMessageType.VIDEO;
        case 3:
          return EMMessageType.LOCATION;
        case 4:
          return EMMessageType.VOICE;
        case 5:
          return EMMessageType.FILE;
        case 6:
          return EMMessageType.CMD;
      }
  }
  toType(EMMessageType type){
      if(type == EMMessageType.TXT){
        return 0;
      }else if(type == EMMessageType.IMAGE){
        return 1;
      }else if(type == EMMessageType.VIDEO){
        return 2;
      }else if(type == EMMessageType.LOCATION){
        return 3;
      }else if(type == EMMessageType.VOICE){
        return 4;
      }else if(type == EMMessageType.FILE){
        return 5;
      }else if(type == EMMessageType.CMD){
        return 6;
      }
  }

  fromChatType(Map<String, dynamic> data){
      switch(data['chatType']){
        case 0:
          return ChatType.Chat;
        case 1:
          return ChatType.GroupChat;
        case 2:
          return ChatType.ChatRoom;
      }
  }
  toChatType(ChatType type){
      if(type == ChatType.Chat){
        return 0;
      }else if(type == ChatType.GroupChat){
        return 1;
      }else if(type == ChatType.ChatRoom){
        return 2;
      }
  }
  fromDirect(Map<String, dynamic> data){
    switch(data['direction']){
      case 0:
        return Direction.SEND;
      case 1:
        return Direction.RECEIVE;
    }
  }
  toDirect(Direction direction){
     if(direction == Direction.SEND){
       return 0;
     }else if(direction == Direction.RECEIVE){
       return 1;
     }
  }
  fromEMMessageStatus(Map<String, dynamic> data){
    switch(data['status']){
      case 0:
        return Status.SUCCESS;
      case 1:
        return Status.FAIL;
      case 2:
        return Status.INPROGRESS;
      case 3:
        return Status.CREATE;
    }
  }
  toEMMessageStatus(Status status){
     if(status == Status.SUCCESS){
       return 0;
     } else if(status == Status.FAIL){
       return 1;
     } else if(status == Status.INPROGRESS){
       return 2;
     } else if(status == Status.CREATE){
       return 3;
     }
  }

class EMContact {
  final String userName;
  String nickName;

  EMContact({@required String userName}) : userName = userName;
}

// EMMessageBody - body of message.
abstract class EMMessageBody {
  Map<String, dynamic> toDataMap();
  static EMMessageBody from(Map<String, dynamic> data) {
    print("EMMessageBody-->"+fromType(data));
    switch (fromType(data)) {
      case EMMessageType.TXT:
        print( EMTextMessageBody.fromData(data));
        return EMTextMessageBody.fromData(data);
      case EMMessageType.CMD:
        return EMCmdMessageBody.fromData(data);
      case EMMessageType.IMAGE:
        return EMImageMessageBody.fromData(data);
      case EMMessageType.FILE:
        return EMNormalFileMessageBody.fromData(data);
      case EMMessageType.LOCATION:
        return EMLocationMessageBody.fromData(data);
      case EMMessageType.VOICE:
        return EMVoiceMessageBody.fromData(data);
      default:
        return null;
    }
  }
}

/// Type - EMMessage type enumeration.
enum EMMessageType {
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

/// EMDeviceInfo - device info.
class EMDeviceInfo {
  final String resource;
  final String deviceUUID;
  final String deviceName;

  EMDeviceInfo(String resource, String deviceUUID, String deviceName)
      : resource = resource,
        deviceUUID = deviceUUID,
        deviceName = deviceName;
}

/// EMCheckType - check type enumeration.
enum EMCheckType {
  ACCOUNT_VALIDATION,
  GET_DNS_LIST_FROM_SERVER,
  GET_TOKEN_FROM_SERVER,
  DO_LOGIN,
  DO_MSG_SEND,
  DO_LOGOUT,
}

/// EMSearchDirection - Search direction.
enum EMSearchDirection { Up, Down }

/// EMCursorResult - Cursor result for iteration.
abstract class EMCursorResult<T> {
  Future<T> getCursor();
}
