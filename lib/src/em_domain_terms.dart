import 'dart:io';

import 'package:flutter/cupertino.dart';

import '../im_flutter_sdk.dart';
import 'em_message_body.dart';

/// 初始化SDK上下文的选项
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

  /// @nodoc 获取已读确认设置
  bool getRequireAck(){
    return _requireAck;
  }
  /// @nodoc 设置是否需要接受方已读确认
  void setRequireAck(bool requireAck){
    _requireAck = requireAck;
  }
  /// @nodoc 获取送达确认设置
  bool getRequireDeliveryAck(){
    return _requireDeliveryAck;
  }
  /// @nodoc 设置是否需要接受方送达确认,默认false
  void setRequireDeliveryAck(bool requireDeliveryAck){
    _requireDeliveryAck = requireDeliveryAck;
  }
  /// @nodoc 获取是否自动接受加好友邀请 默认true
  bool getAcceptInvitationAlways(){
    return _acceptInvitationAlways;
  }
  /// @nodoc 设置是否自动接受加好友邀请 默认true
  void setAcceptInvitationAlways(bool acceptInvitationAlways){
    _acceptInvitationAlways = acceptInvitationAlways;
  }
  /// @nodoc 获取退出(主动和被动退出)群组时是否删除聊天消息
  bool isDeleteMessagesAsExitGroup(){
    return _deleteMessagesAsExitGroup;
  }
  /// @nodoc 设置退出(主动和被动退出)群组时是否删除聊天消息
  void setDeleteMessagesAsExitGroup(bool deleteMessagesAsExitGroup){
    _deleteMessagesAsExitGroup = deleteMessagesAsExitGroup;
  }
  /// @nodoc 获取是否自动接受加群邀请
  bool isAutoAcceptGroupInvitation(){
    return _autoAcceptGroupInvitation;
  }
  /// @nodoc 设置是否自动接受加群邀请
  void setAutoAcceptGroupInvitation(bool autoAcceptGroupInvitation){
    _autoAcceptGroupInvitation = autoAcceptGroupInvitation;
  }
  /// @nodoc 是否允许聊天室owner离开
  bool isChatRoomOwnerLeaveAllowed(){
    return _isChatRoomOwnerLeaveAllowed;
  }
  /// @nodoc 设置是否允许聊天室owner离开并删除会话记录
  void allowChatRoomOwnerLeave(bool isChatRoomOwnerLeaveAllowed){
    _isChatRoomOwnerLeaveAllowed = isChatRoomOwnerLeaveAllowed;
  }
  /// @nodoc 是否按照server收到时间进行排序
  bool isSortMessageByServerTime(){
    return _sortMessageByServerTime;
  }
  /// @nodoc 设置server收到时间进行排序 默认是false
  void setSortMessageByServerTime(bool sortMessageByServerTime){
    _sortMessageByServerTime = sortMessageByServerTime;
  }
  /// @nodoc 获取设置的im server
  String getIMServer(){
    return _imServer;
  }
  /// @nodoc 设置im server地址
  void setIMServer(String imServer){
    _imServer = imServer;
  }
  /// @nodoc 获取设置的im server端口号
  int getImPort(){
    return _imPort;
  }
  /// @nodoc 设置 im server端口号
  void setImPort(int imPort){
    _imPort = imPort;
  }
  /// @nodoc 获取设置的rest server
  String getRestServer(){
    return _restServer;
  }
  /// @nodoc 设置 rest server
  void setRestServer(String restServer){
    _restServer = restServer;
  }
  /// @nodoc 获取是否自动登录
  bool getAutoLogin(){
    return _autoLogin;
  }
  /// @nodoc 设置是否自动登录
  void setAutoLogin(bool autoLogin){
    _autoLogin = autoLogin;
  }

  bool getEnableDNSConfig(){
    return _enableDNSConfig;
  }

  void enableDNSConfig(bool enableDNSConfig){
    _enableDNSConfig = enableDNSConfig;
  }
  /// @nodoc 获取是否使用https进行REST操作，默认值是false。
  bool getUsingHttpsOnly(){
    return _usingHttpsOnly;
  }
  /// @nodoc 只使用https进行REST操作，默认值是false。
  void setUsingHttpsOnly(bool usingHttpsOnly){
    _usingHttpsOnly = usingHttpsOnly;
  }
  /// @nodoc 获取是否使用环信服务器进行上传下载，默认值是true。
  bool getAutoTransferMessageAttachments(){
    return _serverTransfer;
  }
  /// @nodoc 设置是否使用环信服务器进行上传下载
  void setAutoTransferMessageAttachments(bool serverTransfer){
    _serverTransfer = serverTransfer;
  }
  /// @nodoc 是否自动下载缩略图，默认为true。
  bool getAutoDownloadThumbnail(){
    return _isAutoDownload;
  }
  /// @nodoc 设置是否自动下载缩略图
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

  /// 用于创建各种消息的构造函数 - 发送方。
  EMMessage.createSendMessage(EMMessageType type)
      : this(type: type, direction: Direction.SEND);

  /// 用于创建各种消息的构造函数 - 接收方。
  EMMessage.createReceiveMessage(EMMessageType type)
      : this(type: type, direction: Direction.RECEIVE);

  /// 创建文本类型消息 - 发送方
  EMMessage.createTxtSendMessage(String content, String userName)
      : this(
            direction: Direction.SEND,
            to: userName,
            type: EMMessageType.TXT,
            body: EMTextMessageBody(content));

  /// @nodoc 创建语音类型消息 - 发送方
  EMMessage.createVoiceSendMessage(
      String filePath, int timeLength, String userName)
      : this(direction: Direction.SEND);

  /// @nodoc 创建图片类型消息 - 发送方.
  EMMessage.createImageSendMessage(
      String filePath, bool sendOriginalImage, String userName)
      : this(
            direction: Direction.SEND,
            type: EMMessageType.IMAGE,
            body: EMImageMessageBody(File(filePath),sendOriginalImage),
            to: userName);

  /// @nodoc 创建视频类型消息 - 发送方
  EMMessage.createVideoSendMessage(String videoFilePath,
      int timeLength, String userName)
      : this(
            direction: Direction.SEND,
            type: EMMessageType.VIDEO,
            body: EMVideoMessageBody(File(videoFilePath),timeLength),
            to: userName);

  /// @nodoc 创建位置类型消息 - 发送方
  EMMessage.createLocationSendMessage(double latitude, double longitude,
      String locationAddress, String userName)
      : this(
            direction: Direction.SEND,
            type: EMMessageType.LOCATION,
            body: EMLocationMessageBody(locationAddress, latitude, longitude),
            to: userName);

  /// @nodoc 创建文件类型消息 - 发送方
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

  /// 扩展属性 包含任意键/值对的属性
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
  /// 消息类型 int 类型数据转 EMMessageType
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
  /// 消息类型 EMMessageType 类型数据转 int
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
  /// 聊天类型 int 类型数据转 ChatType
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
  /// 聊天类型 ChatType 类型数据转 int
  toChatType(ChatType type){
      if(type == ChatType.Chat){
        return 0;
      }else if(type == ChatType.GroupChat){
        return 1;
      }else if(type == ChatType.ChatRoom){
        return 2;
      }
  }
  /// 消息方向 int 类型数据转 Direction
  fromDirect(int type){
    switch(type){
      case 0:
        return Direction.SEND;
      case 1:
        return Direction.RECEIVE;
    }
  }
  /// 消息方向 Direction 类型数据转 int
  toDirect(Direction direction){
     if(direction == Direction.SEND){
       return 0;
     }else if(direction == Direction.RECEIVE){
       return 1;
     }
  }
  /// 消息状态 int 类型数据转 Status
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
  /// 消息状态 Status 类型数据转 int
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
  /// 下载状态 int 类型数据转 EMDownloadStatus
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
  /// 下载状态 EMDownloadStatus 类型数据转 int
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

/// EMMessageBody - body of message.
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

class EMCursorResult<T> {
  String _cursor;

  List<T> _data;

  String getCursor(){
    return _cursor;
  }

  void setCursor(String cursor){
    _cursor = cursor;
  }

  List<T> getData(){
    return _data;
  }

  void setData(List list){
    _data = list;
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

  void setPageCount(int pageCount) {
    _pageCount = pageCount;
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

/// 会话类型 EMConversationType 数据类型转 int
toEMConversationType(EMConversationType type){
  if(type == EMConversationType.Chat){
    return 0;
  }else if(type == EMConversationType.GroupChat){
    return 1;
  }else if(type == EMConversationType.ChatRoom){
    return 2;
  }
}
/// 会话类型 int 数据类型转 EMConversationType
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
/// 搜索方向 EMSearchDirection 数据类型转 int
toEMSearchDirection(EMSearchDirection direction){
  if(direction == EMSearchDirection.Up){
    return 0;
  }else if(direction == EMSearchDirection.Down){
    return 1;
  }
}

