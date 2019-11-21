import 'dart:io';

import 'package:flutter/cupertino.dart';

import '../im_flutter_sdk.dart';
import 'em_message_body.dart';

/// EMOptions - options to initialize SDK context.
class EMOptions {
  EMOptions({
    @required this.appKey,
  });
  bool _acceptInvitationAlways = true;
  bool _autoAcceptGroupInvitation = true;
  bool _requireAck = true;
  bool _requireDeliveryAck = false;
  bool _deleteMessagesAsExitGroup = true;
  bool _isChatRoomOwnerLeaveAllowed = true;
  String appKey = '';
  bool _autoLogin = true;
  bool _enableDNSConfig = true;
  bool _sortMessageByServerTime = true;
  String _dnsUrl = '';
  String _restServer = '';
  String _imServer = '';
  int _imPort = 0;
  bool _usingHttpsOnly = false;
  bool _serverTransfer = true;
  bool _isAutoDownload = true;
//  EMPushConfig _pushConfig;

  bool getRequireAck(){
    return _requireAck;
  }

  void setRequireAck(bool requireAck){
    _requireAck = requireAck;
  }

  bool getRequireDeliveryAck(){
    return _requireDeliveryAck;
  }

  void setRequireDeliveryAck(bool requireDeliveryAck){
    _requireDeliveryAck = requireDeliveryAck;
  }

  bool getAcceptInvitationAlways(){
    return _acceptInvitationAlways;
  }

  void setAcceptInvitationAlways(bool acceptInvitationAlways){
    _acceptInvitationAlways = acceptInvitationAlways;
  }

  bool isDeleteMessagesAsExitGroup(){
    return _deleteMessagesAsExitGroup;
  }

  void setDeleteMessagesAsExitGroup(bool deleteMessagesAsExitGroup){
    _deleteMessagesAsExitGroup = deleteMessagesAsExitGroup;
  }

  bool isAutoAcceptGroupInvitation(){
    return _autoAcceptGroupInvitation;
  }

  void setAutoAcceptGroupInvitation(bool autoAcceptGroupInvitation){
    _autoAcceptGroupInvitation = autoAcceptGroupInvitation;
  }

  bool isChatRoomOwnerLeaveAllowed(){
    return _isChatRoomOwnerLeaveAllowed;
  }

  void allowChatRoomOwnerLeave(bool isChatRoomOwnerLeaveAllowed){
    _isChatRoomOwnerLeaveAllowed = isChatRoomOwnerLeaveAllowed;
  }

  bool isSortMessageByServerTime(){
    return _sortMessageByServerTime;
  }

  void setSortMessageByServerTime(bool sortMessageByServerTime){
    _sortMessageByServerTime = sortMessageByServerTime;
  }

  String getIMServer(){
    return _imServer;
  }

  void setIMServer(String imServer){
    _imServer = imServer;
  }

  int getImPort(){
    return _imPort;
  }

  void setImPort(int imPort){
    _imPort = imPort;
  }

  String getRestServer(){
    return _restServer;
  }

  void setRestServer(String restServer){
    _restServer = restServer;
  }

  bool getAutoLogin(){
    return _autoLogin;
  }

  void setAutoLogin(bool autoLogin){
    _autoLogin = autoLogin;
  }

  bool getEnableDNSConfig(){
    return _enableDNSConfig;
  }

  void enableDNSConfig(bool enableDNSConfig){
    _enableDNSConfig = enableDNSConfig;
  }

  bool getUsingHttpsOnly(){
    return _usingHttpsOnly;
  }

  void setUsingHttpsOnly(bool usingHttpsOnly){
    _usingHttpsOnly = usingHttpsOnly;
  }

  bool getAutoTransferMessageAttachments(){
    return _serverTransfer;
  }

  void setAutoTransferMessageAttachments(bool serverTransfer){
    _serverTransfer = serverTransfer;
  }

  bool getAutoDownloadThumbnail(){
    return _isAutoDownload;
  }

  void setAutoDownloadThumbnail(bool isAutoDownload){
    _isAutoDownload = isAutoDownload;
  }

  String getDnsUrl(){
    return _dnsUrl;
  }

  void setDnsUrl(String dnsUrl){
    _dnsUrl = dnsUrl;
  }

//  EMPushConfig getPushConfig(){
//    return _pushConfig;
//  }
//
//  void setPushConfig(EMPushConfig pushConfig){
//    _pushConfig = pushConfig;
//  }

  Map convertToMap(){
    var map = {};
    map.putIfAbsent("acceptInvitationAlways", ()=> _acceptInvitationAlways );
    map.putIfAbsent("autoAcceptGroupInvitation", ()=> _autoAcceptGroupInvitation );
    map.putIfAbsent("requireAck", ()=> _requireAck );
    map.putIfAbsent("requireDeliveryAck", ()=> _requireDeliveryAck );
    map.putIfAbsent("deleteMessagesAsExitGroup", ()=> _deleteMessagesAsExitGroup );
    map.putIfAbsent("isChatRoomOwnerLeaveAllowed", ()=> _isChatRoomOwnerLeaveAllowed );
    map.putIfAbsent("appKey", ()=> appKey );
    map.putIfAbsent("autoLogin", ()=> _autoLogin );
    map.putIfAbsent("enableDNSConfig", ()=> _enableDNSConfig );
    map.putIfAbsent("sortMessageByServerTime", ()=> _sortMessageByServerTime );
    map.putIfAbsent("dnsUrl", ()=> _dnsUrl );
    map.putIfAbsent("restServer", ()=> _restServer );
    map.putIfAbsent("imServer", ()=> _imServer );
    map.putIfAbsent("imPort", ()=> _imPort );
    map.putIfAbsent("usingHttpsOnly", ()=> _usingHttpsOnly );
    map.putIfAbsent("serverTransfer", ()=> _serverTransfer );
    map.putIfAbsent("isAutoDownload", ()=> _isAutoDownload );
    print(map);
    return map;
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
    return body.toString();
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
  toDataMap();
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

  List getData(){
    return _data;
  }

  EMCursorResult.from(Map<String, dynamic> data)
      : _cursor = data['cursor'],
        _data = data['data'];
}

class EMPageResult<T>{
  int _pageCount;

  List<T> _data;

  int getPageCount() {
    return _pageCount;
  }

  List<T> getData(){
    return _data;
  }

  void setData(List list){
     _data = list;
  }

  EMPageResult.from(Map<String, dynamic> data)
      : _pageCount = data['pageCount'],
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


toEMConversationType(EMConversationType type){
  if(type == EMConversationType.Chat){
    return 0;
  }else if(type == EMConversationType.GroupChat){
    return 1;
  }else if(type == EMConversationType.ChatRoom){
    return 2;
  }
}

fromEMConversationType(int type){
  if(type == 0){
    return EMConversationType.Chat;
  }else if(type == 1){
    return EMConversationType.GroupChat;
  }else if(type == 2){
    return EMConversationType.ChatRoom;
  }else if(type == 3){
    return EMConversationType.DiscussionGroup;
  }else if(type == 4){
    return EMConversationType.HelpDesk;
  }
}

toEMSearchDirection(EMSearchDirection direction){
  if(direction == EMSearchDirection.Up){
    return 0;
  }else if(direction == EMSearchDirection.Down){
    return 1;
  }
}

