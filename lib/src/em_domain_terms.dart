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
    this.acked,
    this.body,
    this.chatType ,
    this.delivered,
    this.direction,
    this.from,
    this.listened ,
    this.localTime,
    this.msgId ,
    this.msgTime,
    this.progress ,
    this.status ,
    this.to,
    this.type,
    this.unread,
    this.deliverAcked,
  })
      : _attributes = {},
        _conversationId = '',
        _userName = '';

  /// Constructors to create various of messages.
  EMMessage.createSendMessage(EMMessageType type)
      : this(type: type, direction: Direction.SEND);

  EMMessage.createReceiveMessage(EMMessageType type)
      : this(type: type, direction: Direction.RECEIVE);

  EMMessage.createTxtSendMessage(String content, String userName)
      : this(
            direction: Direction.SEND,
            to: userName,
            type: EMMessageType.TXT,
            body: EMTextMessageBody(content));

  EMMessage.createVoiceSendMessage(
      String filePath, int timeLength, String userName)
      : this(direction: Direction.SEND);

  EMMessage.createImageSendMessage(
      String filePath, bool sendOriginalImage, String userName)
      : this(
            direction: Direction.SEND,
            type: EMMessageType.IMAGE,
            body: EMImageMessageBody(File(filePath),sendOriginalImage),
            to: userName);

  EMMessage.createVideoSendMessage(String videoFilePath,
      int timeLength, String userName)
      : this(
            direction: Direction.SEND,
            type: EMMessageType.VIDEO,
            body: EMVideoMessageBody(File(videoFilePath),timeLength),
            to: userName);

  EMMessage.createLocationSendMessage(double latitude, double longitude,
      String locationAddress, String userName)
      : this(
            direction: Direction.SEND,
            type: EMMessageType.LOCATION,
            body: EMLocationMessageBody(locationAddress, latitude, longitude),
            to: userName);

  EMMessage.createFileSendMessage(String filePath, String userName)
      : this(
            direction: Direction.SEND,
            type: EMMessageType.FILE,
            body: EMNormalFileMessageBody(File(filePath)),
            to: userName);

  set isDeliverAcked(bool acked) {
    deliverAcked = acked;
  }

  final String _conversationId;
  String get conversationId => _conversationId;

  final String _userName;
  String get userName => _userName;

  bool deliverAcked;
  bool acked;
  EMMessageBody body;
  ChatType chatType;
  bool delivered;
  Direction direction;
  String from;
  bool listened;
  String localTime;
  String msgId;
  String msgTime;
  int progress;
  Status status;
  String to;
  bool unread;
  EMMessageType type;

  /// attributes holding arbitrary key/value pair
  final Map _attributes;

  void setAttribute(String attr, dynamic value) {
    _attributes[attr] = value;
  }

  dynamic getAttribute(String attr) {
    return _attributes[attr];
  }

  /// TODO: setMessageStatusCallback (EMCallBack callback)

  Map ext() {
    return _attributes;
  }

  Map toDataMap() {
    var result = {};
    result["acked"] = this.acked;
    result['attributes'] = _attributes;
    result['body'] = body.toDataMap();
    result['chatType'] = toChatType(chatType);
    result['conversationId'] = _conversationId;
    result['deliverAcked'] = deliverAcked;
    result['delivered'] = delivered;
    result['direction'] = toDirect(direction);
    result['from'] = from;
    result['listened'] = listened;
    result['localTime'] = localTime;
    result['msgId'] = msgId;
    result['msgTime'] = msgTime;
    result['progress'] = progress;
    result['status'] = toEMMessageStatus(status);
    result['to'] = to;
    result['type'] = toType(type);
    result['unread'] = unread;
    result['userName'] = _userName;
    return result;
  }

   EMMessage.from(Map data):
        _attributes = data['attributes'],
        localTime = data['localTime'],
        chatType = fromChatType(data['chatType']),
        msgId = data['msgId'],
        progress = data['progress'],
        body = EMMessageBody.from(data['body']),
        delivered = data['delivered'],
        from = data['from'],
        direction = fromDirect(data['direction']),
        listened = data['listened'],
        _conversationId = data['conversationId'],
        status = fromEMMessageStatus(data['status']),
        msgTime = data['msgTime'],
        to = data['to'],
        _userName = data['userName'],
        acked = data['acked'],
        type = fromType(data['type']),
        unread = data['unread'];


  String toString(){
    return from;
  }

}

  fromType(int type){
      switch(type){
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

  fromChatType(int type){
      switch(type){
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

  fromDirect(int type){
    switch(type){
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

  fromEMMessageStatus(int status){
    switch(status){
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

  toEMDownloadStatus(EMDownloadStatus status){
    if(status == EMDownloadStatus.DOWNLOADING){
      return 0;
    } else if(status == EMDownloadStatus.SUCCESSED){
      return 1;
    } else if(status == EMDownloadStatus.FAILED){
      return 2;
    } else if(status == EMDownloadStatus.PENDING){
      return 3;
    }
  }

  fromEMDownloadStatus(int status){
    if(status == 0){
      return EMDownloadStatus.DOWNLOADING;
    } else if(status == 1){
      return EMDownloadStatus.SUCCESSED;
    } else if(status == 2){
      return EMDownloadStatus.FAILED;
    } else if(status == 3){
      return EMDownloadStatus.PENDING;
    }
  }

class EMContact {
  final String userName;
  String nickName;

  EMContact({@required String userName}) : userName = userName;
}

// EMMessageBody - body of message.
abstract class EMMessageBody {
  Map toDataMap();
  static EMMessageBody from(Map data) {
    switch (data['type']) {
      case 0:
        return EMTextMessageBody.fromData(data);
      case 1:
        return EMImageMessageBody.fromData(data);
      case 2:
        return EMVideoMessageBody.fromData(data);
      case 3:
        return EMLocationMessageBody.fromData(data);
      case 4:
        return EMVoiceMessageBody.fromData(data);
      case 5:
        return EMNormalFileMessageBody.fromData(data);
      case 6:
        return EMCmdMessageBody.fromData(data);
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
abstract class EMCursorResults<T> {
  Future<T> getCursor();
}

class EMCursorResult {
  String _cursor;

  List _data;

  String getCursor(){
    return _cursor;
  }

  List
  getData(){
    return _data;
  }

  EMCursorResult.from(Map<String, dynamic> data)
      : _cursor = data['cursor'],
        _data = data['data'];
}



class EMGroupOptions {
  EMGroupOptions({
    this.maxUsers = 200,
    this.style = EMGroupStyle.EMGroupStylePrivateOnlyOwnerInvite,
  });

  int maxUsers;
  EMGroupStyle style;
}

enum EMGroupStyle{
  EMGroupStylePrivateOnlyOwnerInvite,
  EMGroupStylePrivateMemberCanInvite,
  EMGroupStylePublicJoinNeedApproval,
  EMGroupStylePublicOpenJoin,
}

int convertEMGroupStyleToInt(EMGroupStyle style){
  if(style == EMGroupStyle.EMGroupStylePrivateOnlyOwnerInvite){
    return 0;
  }
  if(style == EMGroupStyle.EMGroupStylePrivateMemberCanInvite){
    return 1;
  }
  if(style == EMGroupStyle.EMGroupStylePublicJoinNeedApproval){
    return 2;
  }
  if(style == EMGroupStyle.EMGroupStylePublicOpenJoin){
    return 3;
  }
  return 0;
}

class EMMucSharedFile{
  String _fileId;
  String _fileName;
  String _fileOwner;
  int _updateTime;
  int _fileSize;

  String getFileId(){
    return _fileId;
  }

  String getFileName(){
    return _fileName;
  }
  String getFileOwner(){
    return _fileOwner;
  }
  int getFileUpdateTime(){
    return _updateTime;
  }
  int getFileSize(){
    return _fileSize;
  }
  EMMucSharedFile.from(Map<String, dynamic> data)
      : _fileId = data['fileId'],
        _fileName = data['fileName'],
        _fileOwner = data['fileOwner'],
        _updateTime = data['updateTime'],
        _fileSize = data['fileSize'];

  String toString(){
    return 'fileId:' + _fileId +"--"
    +'fileName:' + _fileName +"--"
    +'fileOwner:' + _fileOwner +"--"
    +'updateTime:' + _updateTime.toString() +"--"
    +'fileSize:' + _fileSize.toString();
  }
}

class EMGroupInfo{
  String _groupId;
  String _groupName;

  String getGroupId(){
    return _groupId;
  }

  String getGroupName(){
    return _groupName;
  }

  EMGroupInfo.from(Map<String, dynamic> data)
      : _groupId = data['groupId'],
        _groupName = data['groupName'];
}

enum EMGroupPermissionType{
  EMGroupPermissionTypeNone,
  EMGroupPermissionTypeMember,
  EMGroupPermissionTypeAdmin,
  EMGroupPermissionTypeOwner,
}

EMGroupPermissionType convertIntToEMGroupPermissionType(int i){
  if(i == -1){
    return EMGroupPermissionType.EMGroupPermissionTypeNone;
  }
  if(i == 0){
    return EMGroupPermissionType.EMGroupPermissionTypeMember;
  }
  if(i == 1){
    return EMGroupPermissionType.EMGroupPermissionTypeAdmin;
  }
  if(i == 2){
    return EMGroupPermissionType.EMGroupPermissionTypeOwner;
  }
  return EMGroupPermissionType.EMGroupPermissionTypeNone;
}