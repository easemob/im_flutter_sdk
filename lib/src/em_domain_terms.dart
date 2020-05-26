import 'dart:io';

import 'package:flutter/cupertino.dart';

import '../im_flutter_sdk.dart';
import 'em_message_body.dart';

/// 初始化SDK上下文的选项
class EMOptions {
  EMOptions({
    @required this.appKey,
  })  : _acceptInvitationAlways = true,
        _autoAcceptGroupInvitation = true,
        _requireAck = true,
        _requireDeliveryAck = false,
        _deleteMessagesAsExitGroup = true,
        _isChatRoomOwnerLeaveAllowed = true,
        _autoLogin = true,
        _enableDNSConfig = true,
        _sortMessageByServerTime = true,
        _dnsUrl = '',
        _restServer = '',
        _imServer = '',
        _imPort = 0,
        _usingHttpsOnly = false,
        _serverTransfer = true,
        _isAutoDownload = true,
        _pushConfig = EMPushConfig();

  bool _acceptInvitationAlways;
  bool _autoAcceptGroupInvitation;
  bool _requireAck;
  bool _requireDeliveryAck;
  bool _deleteMessagesAsExitGroup;
  bool _isChatRoomOwnerLeaveAllowed;

  String appKey;
  bool _autoLogin;
  bool _enableDNSConfig;
  bool _sortMessageByServerTime;
  String _dnsUrl;
  String _restServer;
  String _imServer;
  int _imPort;
  bool _usingHttpsOnly;
  bool _serverTransfer;
  bool _isAutoDownload;
  EMPushConfig _pushConfig;

  /// 获取已读确认设置
  bool getRequireAck() {
    return _requireAck;
  }

  /// 设置是否需要接受方已读确认
  void setRequireAck(bool requireAck) {
    _requireAck = requireAck;
  }

  /// 获取送达确认设置
  bool getRequireDeliveryAck() {
    return _requireDeliveryAck;
  }

  /// 设置是否需要接受方送达确认,默认false
  void setRequireDeliveryAck(bool requireDeliveryAck) {
    _requireDeliveryAck = requireDeliveryAck;
  }

  /// 获取是否自动接受加好友邀请 默认true
  bool getAcceptInvitationAlways() {
    return _acceptInvitationAlways;
  }

  /// 设置是否自动接受加好友邀请 默认true
  void setAcceptInvitationAlways(bool acceptInvitationAlways) {
    _acceptInvitationAlways = acceptInvitationAlways;
  }

  /// 获取退出(主动和被动退出)群组时是否删除聊天消息
  bool isDeleteMessagesAsExitGroup() {
    return _deleteMessagesAsExitGroup;
  }

  /// 设置退出(主动和被动退出)群组时是否删除聊天消息
  void setDeleteMessagesAsExitGroup(bool deleteMessagesAsExitGroup) {
    _deleteMessagesAsExitGroup = deleteMessagesAsExitGroup;
  }

  /// 获取是否自动接受加群邀请
  bool isAutoAcceptGroupInvitation() {
    return _autoAcceptGroupInvitation;
  }

  /// 设置是否自动接受加群邀请
  void setAutoAcceptGroupInvitation(bool autoAcceptGroupInvitation) {
    _autoAcceptGroupInvitation = autoAcceptGroupInvitation;
  }

  /// 是否允许聊天室owner离开
  bool isChatRoomOwnerLeaveAllowed() {
    return _isChatRoomOwnerLeaveAllowed;
  }

  /// 设置是否允许聊天室owner离开并删除会话记录
  void allowChatRoomOwnerLeave(bool isChatRoomOwnerLeaveAllowed) {
    _isChatRoomOwnerLeaveAllowed = isChatRoomOwnerLeaveAllowed;
  }

  /// 是否按照server收到时间进行排序
  bool isSortMessageByServerTime() {
    return _sortMessageByServerTime;
  }

  /// 设置server收到时间进行排序 默认是false
  void setSortMessageByServerTime(bool sortMessageByServerTime) {
    _sortMessageByServerTime = sortMessageByServerTime;
  }

  /// @nodoc 获取设置的im server
  String getIMServer() {
    return _imServer;
  }

  /// @nodoc 设置im server地址
  void setIMServer(String imServer) {
    _imServer = imServer;
  }

  /// @nodoc 获取设置的im server端口号
  int getImPort() {
    return _imPort;
  }

  /// @nodoc 设置 im server端口号
  void setImPort(int imPort) {
    _imPort = imPort;
  }

  /// @nodoc 获取设置的rest server
  String getRestServer() {
    return _restServer;
  }

  /// @nodoc 设置 rest server
  void setRestServer(String restServer) {
    _restServer = restServer;
  }

  /// 获取是否自动登录
  bool getAutoLogin() {
    return _autoLogin;
  }

  /// 设置是否自动登录
  void setAutoLogin(bool autoLogin) {
    _autoLogin = autoLogin;
  }

  /// @nodoc 获取是否使用DNSConfig
  bool getEnableDNSConfig() {
    return _enableDNSConfig;
  }

  /// @nodoc 是否使用DNSConfig
  void enableDNSConfig(bool enableDNSConfig) {
    _enableDNSConfig = enableDNSConfig;
  }

  /// @nodoc 获取是否使用https进行REST操作，默认值是false。
  bool getUsingHttpsOnly() {
    return _usingHttpsOnly;
  }

  /// @nodoc 只使用https进行REST操作，默认值是false。
  void setUsingHttpsOnly(bool usingHttpsOnly) {
    _usingHttpsOnly = usingHttpsOnly;
  }

  /// @nodoc 获取是否使用环信服务器进行上传下载，默认值是true。
  bool getAutoTransferMessageAttachments() {
    return _serverTransfer;
  }

  /// @nodoc 设置是否使用环信服务器进行上传下载
  void setAutoTransferMessageAttachments(bool serverTransfer) {
    _serverTransfer = serverTransfer;
  }

  /// @nodoc 是否自动下载缩略图，默认为true。
  bool getAutoDownloadThumbnail() {
    return _isAutoDownload;
  }

  /// @nodoc 设置是否自动下载缩略图
  void setAutoDownloadThumbnail(bool isAutoDownload) {
    _isAutoDownload = isAutoDownload;
  }

  /// @nodoc 获取DNSURL
  String getDnsUrl() {
    return _dnsUrl;
  }

  /// @nodoc 设置DNSURL
  void setDnsUrl(String dnsUrl) {
    _dnsUrl = dnsUrl;
  }

  /// @nodoc 获取推送配置
  EMPushConfig getPushConfig() {
    return _pushConfig;
  }

  /// @nodoc 设置推送配置
  void setPushConfig(EMPushConfig pushConfig) {
    _pushConfig = pushConfig;
  }

  /// @nodoc
  Map convertToMap() {
    var map = {};
    map.putIfAbsent("acceptInvitationAlways", () => _acceptInvitationAlways);
    map.putIfAbsent(
        "autoAcceptGroupInvitation", () => _autoAcceptGroupInvitation);
    map.putIfAbsent("requireAck", () => _requireAck);
    map.putIfAbsent("requireDeliveryAck", () => _requireDeliveryAck);
    map.putIfAbsent(
        "deleteMessagesAsExitGroup", () => _deleteMessagesAsExitGroup);
    map.putIfAbsent(
        "isChatRoomOwnerLeaveAllowed", () => _isChatRoomOwnerLeaveAllowed);
    map.putIfAbsent("appKey", () => appKey);
    map.putIfAbsent("autoLogin", () => _autoLogin);
    map.putIfAbsent("enableDNSConfig", () => _enableDNSConfig);
    map.putIfAbsent("sortMessageByServerTime", () => _sortMessageByServerTime);
    map.putIfAbsent("dnsUrl", () => _dnsUrl);
    map.putIfAbsent("restServer", () => _restServer);
    map.putIfAbsent("imServer", () => _imServer);
    map.putIfAbsent("imPort", () => _imPort);
    map.putIfAbsent("usingHttpsOnly", () => _usingHttpsOnly);
    map.putIfAbsent("serverTransfer", () => _serverTransfer);
    map.putIfAbsent("isAutoDownload", () => _isAutoDownload);
    map.putIfAbsent("pushConfig", () => _pushConfig.convertToMap());
    print(map);
    return map;
  }
}

class EMPushConfig {
  EMPushConfig()
      : _enableVivoPush = false,
        _enableMeiZuPush = false,
        _enableMiPush = false,
        _enableOppoPush = false,
        _enableHWPush = false,
        _enableFCM = false,
        _enableAPNS = false,
        _miAppId = '',
        _miAppKey = '',
        _mzAppId = '',
        _mzAppKey = '',
        _oppoAppKey = '',
        _oppoAppSecret = '',
        _fcmSenderId = '',
        _apnsSenderId = '';

  bool _enableVivoPush;
  bool _enableMeiZuPush;
  bool _enableMiPush;
  bool _enableOppoPush;
  bool _enableHWPush;
  bool _enableFCM;
  bool _enableAPNS;
  String _miAppId;
  String _miAppKey;
  String _mzAppId;
  String _mzAppKey;
  String _oppoAppKey;
  String _oppoAppSecret;
  String _fcmSenderId;
  String _apnsSenderId;

  void enableVivoPush() {
    _enableVivoPush = true;
  }

  void enableMeiZuPush(String appId, String appKey) {
    _enableMeiZuPush = true;
    _mzAppId = appId;
    _mzAppKey = appKey;
  }

  void enableMiPush(String appId, String appKey) {
    _enableMiPush = true;
    _miAppId = appId;
    _miAppKey = appKey;
  }

  void enableOppoPush(String appKey, String appSecret) {
    _enableOppoPush = true;
    _oppoAppKey = appKey;
    _oppoAppSecret = appSecret;
  }

  void enableHWPush() {
    _enableHWPush = true;
  }

  void enableFCM(String senderId) {
    _enableFCM = true;
    _fcmSenderId = senderId;
  }

  void enableAPNS(String senderId) {
    _enableAPNS = true;
    _apnsSenderId = senderId;
  }

  /// @nodoc
  Map convertToMap() {
    var map = Map();
    map.putIfAbsent("enableVivoPush", () => _enableVivoPush);
    map.putIfAbsent("enableMeiZuPush", () => _enableMeiZuPush);
    map.putIfAbsent("enableMiPush", () => _enableMiPush);
    map.putIfAbsent("enableOppoPush", () => _enableOppoPush);
    map.putIfAbsent("enableHWPush", () => _enableHWPush);
    map.putIfAbsent("enableFCM", () => _enableFCM);
    map.putIfAbsent("enableAPNS", () => _enableAPNS);
    map.putIfAbsent("miAppId", () => _miAppId);
    map.putIfAbsent("miAppKey", () => _miAppKey);
    map.putIfAbsent("mzAppId", () => _mzAppId);
    map.putIfAbsent("mzAppKey", () => _mzAppKey);
    map.putIfAbsent("oppoAppKey", () => _oppoAppKey);
    map.putIfAbsent("oppoAppSecret", () => _oppoAppSecret);
    map.putIfAbsent("fcmSenderId", () => _fcmSenderId);
    map.putIfAbsent("apnsSenderId", () => _apnsSenderId);
    return map;
  }
}

/// EMMessage - various types of message
class EMMessage {
  EMMessage({
    this.acked,
    this.body,
    this.delivered,
    this.direction,
    this.from,
    this.listened,
    this.msgTime = '',
    this.status,
    this.to,
    this.type,
    this.unread,
    this.deliverAcked,
  })  : _attributes = {},
        _conversationId = '',
        _userName = '',
        chatType = ChatType.Chat,
        msgId = currentTimeMillis(),
        localTime = currentTimeMillis();

  /// 用于创建各种消息的构造函数 - 发送方。
  EMMessage.createSendMessage(EMMessageType type)
      : this(type: type, direction: Direction.SEND);

  /// 用于创建各种消息的构造函数 - 接收方。
  EMMessage.createReceiveMessage(EMMessageType type)
      : this(type: type, direction: Direction.RECEIVE);

  /// 创建文本类型消息 [content]: 消息内容; [userName]: 接收方id
  EMMessage.createTxtSendMessage(String content, String userName)
      : this(
            direction: Direction.SEND,
            to: userName,
            type: EMMessageType.TXT,
            body: EMTextMessageBody(content));

  /// 创建语音类型消息 [filePath]: 语音片断路径;  [timeLength]: 语音时长; [userName]: 接收方id
  EMMessage.createVoiceSendMessage(
      String filePath, int timeLength, String userName)
      : this(direction: Direction.SEND,
      type: EMMessageType.VOICE,
      body:EMVoiceMessageBody(File(filePath),timeLength),
      to:userName);

  /// 创建图片类型消息 [filePath]: 图片路径; [sendOriginalImage]: 是否发送原图; [userName]: 接收方id.
  EMMessage.createImageSendMessage(
      String filePath, bool sendOriginalImage, String userName)
      : this(
            direction: Direction.SEND,
            type: EMMessageType.IMAGE,
            body: EMImageMessageBody(File(filePath), sendOriginalImage),
            to: userName);

  /// 创建视频类型消息 [filePath]: 视频片断路径;  [timeLength]: 语音时长; [userName]: 接收方id
  EMMessage.createVideoSendMessage(
      String filePath, int timeLength, String userName)
      : this(
            direction: Direction.SEND,
            type: EMMessageType.VIDEO,
            body: EMVideoMessageBody(File(filePath), timeLength),
            to: userName);

  /// 创建位置类型消息 [latitude]: 纬度; [longitude]: 经度; [locationAddress]: 位置名称; [userName]: 接收方id
  EMMessage.createLocationSendMessage(double latitude, double longitude,
      String locationAddress, String userName)
      : this(
            direction: Direction.SEND,
            type: EMMessageType.LOCATION,
            body: EMLocationMessageBody(locationAddress, latitude, longitude),
            to: userName);

  /// 创建文件类型消息 [filePath]: 文件路径; [userName]: 接收方id
  EMMessage.createFileSendMessage(String filePath, String userName)
      : this(
            direction: Direction.SEND,
            type: EMMessageType.FILE,
            body: EMNormalFileMessageBody(File(filePath)),
            to: userName);

  /// @nodoc TODO:
  set isDeliverAcked(bool acked) {
    deliverAcked = acked;
  }

  final String _conversationId;

  /// 会话id
  String get conversationId => _conversationId;

  final String _userName;

  /// @nodoc TODO:
  String get userName => _userName;

  /// @nodoc TODO:
  bool deliverAcked = false;

  /// 是否已读
  bool acked = false;

  /// 消息body
  EMMessageBody body;

  /// 消息类型[单聊，群聊，聊天室]
  ChatType chatType;

  /// @nodoc TODO:
  bool delivered;

  /// 消息反向(发送，接收)
  Direction direction;

  /// 消息发送方
  String from;

  /// @nodoc TODO：
  bool listened;

  /// 本地时间
  String localTime;

  /// 消息id
  String msgId;

  /// 服务器时间
  String msgTime;

  /// 消息发送状态
  Status status;

  /// 消息接收方
  String to;

  /// 是否未读
  bool unread;

  /// 消息类型[文字，图片，语音...]
  EMMessageType type;

  /// 扩展属性 包含任意键/值对的属性
  final Map _attributes;

  /// @nodoc
  void setAttribute(Map map) {
    _attributes.addAll(map);
  }

  /// @nodoc
  dynamic getAttribute(String attr) {
    return _attributes[attr];
  }

  /// TODO: setMessageStatusCallback (EMCallBack callback)

  /// ext
  Map ext() {
    return _attributes;
  }

  static String currentTimeMillis() {
    return new DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// @nodoc
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

  /// @nodoc
  EMMessage.from(Map data)
      : _attributes = data['attributes'],
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

  /// @nodoc
  String toString() {
    return body.toString();
  }
}

/// @nodoc 消息类型 int 类型数据转 EMMessageType
fromType(int type) {
  switch (type) {
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

/// @nodoc 消息类型 EMMessageType 类型数据转 int
toType(EMMessageType type) {
  if (type == EMMessageType.TXT) {
    return 0;
  } else if (type == EMMessageType.IMAGE) {
    return 1;
  } else if (type == EMMessageType.VIDEO) {
    return 2;
  } else if (type == EMMessageType.LOCATION) {
    return 3;
  } else if (type == EMMessageType.VOICE) {
    return 4;
  } else if (type == EMMessageType.FILE) {
    return 5;
  } else if (type == EMMessageType.CMD) {
    return 6;
  }
}

/// @nodoc 聊天类型 int 类型数据转 ChatType
fromChatType(int type) {
  switch (type) {
    case 0:
      return ChatType.Chat;
    case 1:
      return ChatType.GroupChat;
    case 2:
      return ChatType.ChatRoom;
  }
}

/// @nodoc 聊天类型 ChatType 类型数据转 int
toChatType(ChatType type) {
  if (type == ChatType.Chat) {
    return 0;
  } else if (type == ChatType.GroupChat) {
    return 1;
  } else if (type == ChatType.ChatRoom) {
    return 2;
  }
}

/// @nodoc 消息方向 int 类型数据转 Direction
fromDirect(int type) {
  switch (type) {
    case 0:
      return Direction.SEND;
    case 1:
      return Direction.RECEIVE;
  }
}

/// @nodoc 消息方向 Direction 类型数据转 int
toDirect(Direction direction) {
  if (direction == Direction.SEND) {
    return 0;
  } else if (direction == Direction.RECEIVE) {
    return 1;
  }
}

/// @nodoc 消息状态 int 类型数据转 Status
fromEMMessageStatus(int status) {
  switch (status) {
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

/// @nodoc 消息状态 Status 类型数据转 int
toEMMessageStatus(Status status) {
  if (status == Status.SUCCESS) {
    return 0;
  } else if (status == Status.FAIL) {
    return 1;
  } else if (status == Status.INPROGRESS) {
    return 2;
  } else if (status == Status.CREATE) {
    return 3;
  }
}

/// @nodoc 下载状态 int 类型数据转 EMDownloadStatus
toEMDownloadStatus(EMDownloadStatus status) {
  if (status == EMDownloadStatus.DOWNLOADING) {
    return 0;
  } else if (status == EMDownloadStatus.SUCCESSED) {
    return 1;
  } else if (status == EMDownloadStatus.FAILED) {
    return 2;
  } else if (status == EMDownloadStatus.PENDING) {
    return 3;
  }
}

/// @nodoc 下载状态 EMDownloadStatus 类型数据转 int
fromEMDownloadStatus(int status) {
  if (status == 0) {
    return EMDownloadStatus.DOWNLOADING;
  } else if (status == 1) {
    return EMDownloadStatus.SUCCESSED;
  } else if (status == 2) {
    return EMDownloadStatus.FAILED;
  } else if (status == 3) {
    return EMDownloadStatus.PENDING;
  }
}

class EMContact {
  /// 环信id
  final String userName;

  /// @nodoc 昵称(暂未实现)
  String nickName;

  EMContact({@required String userName}) : userName = userName;
}

/// @nodoc  EMMessageBody - body of message.
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

/// 消息类型
enum EMMessageType {
  /// 文字消息
  TXT,

  /// 图片消息
  IMAGE,

  /// 视频消息
  VIDEO,

  /// 位置消息
  LOCATION,

  /// 音频消息
  VOICE,

  /// 文件消息
  FILE,

  /// CMD消息
  CMD,
}

/// @nodoc Status - EMMessage status enumeration.
enum Status {
  SUCCESS,
  FAIL,
  INPROGRESS,
  CREATE,
}

/// @nodoc ChatType - EMMessage chat type enumeration.
enum ChatType { Chat, GroupChat, ChatRoom }

/// @nodoc Direction - EMMessage direction enumeration.
enum Direction { SEND, RECEIVE }

/// @nodoc EMDownloadStatus - download status enumeration.
enum EMDownloadStatus { DOWNLOADING, SUCCESSED, FAILED, PENDING }

/// EMDeviceInfo - device info.
class EMDeviceInfo {
  /// 设备资源描述
  final String resource;

  /// 设备的UUID
  final String deviceUUID;

  /// 设备名称
  final String deviceName;

  /// nodoc
  EMDeviceInfo(String resource, String deviceUUID, String deviceName)
      : resource = resource,
        deviceUUID = deviceUUID,
        deviceName = deviceName;
}

/// @nodoc EMCheckType - check type enumeration.
enum EMCheckType {
  ACCOUNT_VALIDATION,
  GET_DNS_LIST_FROM_SERVER,
  GET_TOKEN_FROM_SERVER,
  DO_LOGIN,
  DO_MSG_SEND,
  DO_LOGOUT,
}

/// @nodoc EMSearchDirection - Search direction.
enum EMSearchDirection { Up, Down }

/// @nodoc EMCursorResult - Cursor result for iteration.
abstract class EMCursorResults<T> {
  /// 获取cursor
  Future<T> getCursor();
}

/// @nodoc
class EMCursorResult<T> {
  String _cursor;

  List<T> _data;

  String getCursor() {
    return _cursor;
  }

  void setCursor(String cursor) {
    _cursor = cursor;
  }

  List<T> getData() {
    return _data;
  }

  void setData(List list) {
    _data = list;
  }

  EMCursorResult.from(Map<String, dynamic> data)
      : _cursor = data['cursor'],
        _data = data['data'];
}

/// @nodoc
class EMPageResult<T> {
  int _pageCount;

  List<T> _data;

  int getPageCount() {
    return _pageCount;
  }

  void setPageCount(int pageCount) {
    _pageCount = pageCount;
  }

  List<T> getData() {
    return _data;
  }

  void setData(List list) {
    _data = list;
  }

  EMPageResult.from(Map<String, dynamic> data)
      : _pageCount = data['pageCount'],
        _data = data['data'];
}

class EMGroupOptions {
  /// GroupOptions
  EMGroupOptions({
    this.maxUsers = 200,
    this.style = EMGroupStyle.EMGroupStylePrivateOnlyOwnerInvite,
  });

  /// 群人数上限
  int maxUsers;

  /// 群类型
  EMGroupStyle style;
}

/// 群组类型
enum EMGroupStyle {
  /// 私有群，只有群主可邀请
  EMGroupStylePrivateOnlyOwnerInvite,

  /// 私有群，成员都可邀请
  EMGroupStylePrivateMemberCanInvite,

  /// 共有群，加入需要申请
  EMGroupStylePublicJoinNeedApproval,

  /// 共有群，任何人可加入
  EMGroupStylePublicOpenJoin,
}

/// @nodoc
int convertEMGroupStyleToInt(EMGroupStyle style) {
  if (style == EMGroupStyle.EMGroupStylePrivateOnlyOwnerInvite) {
    return 0;
  }
  if (style == EMGroupStyle.EMGroupStylePrivateMemberCanInvite) {
    return 1;
  }
  if (style == EMGroupStyle.EMGroupStylePublicJoinNeedApproval) {
    return 2;
  }
  if (style == EMGroupStyle.EMGroupStylePublicOpenJoin) {
    return 3;
  }
  return 0;
}

class EMMucSharedFile {
  String _fileId;
  String _fileName;
  String _fileOwner;
  int _updateTime;
  int _fileSize;

  /// 获取文件id
  String getFileId() {
    return _fileId;
  }

  /// 获取文件文件
  String getFileName() {
    return _fileName;
  }

  /// 获取文件上传者
  String getFileOwner() {
    return _fileOwner;
  }

  /// 获取文件更新时间
  int getFileUpdateTime() {
    return _updateTime;
  }

  /// 获取文件大小
  int getFileSize() {
    return _fileSize;
  }

  /// @nodoc
  EMMucSharedFile.from(Map<String, dynamic> data)
      : _fileId = data['fileId'],
        _fileName = data['fileName'],
        _fileOwner = data['fileOwner'],
        _updateTime = data['updateTime'],
        _fileSize = data['fileSize'];

  /// @nodoc
  String toString() {
    return 'fileId:' +
        _fileId +
        "--" +
        'fileName:' +
        _fileName +
        "--" +
        'fileOwner:' +
        _fileOwner +
        "--" +
        'updateTime:' +
        _updateTime.toString() +
        "--" +
        'fileSize:' +
        _fileSize.toString();
  }
}

/// 群组详情
class EMGroupInfo {
  String _groupId;
  String _groupName;

  /// 获取群id
  String getGroupId() {
    return _groupId;
  }

  /// 获取群名称
  String getGroupName() {
    return _groupName;
  }

  /// @nodoc
  EMGroupInfo.from(Map<String, dynamic> data)
      : _groupId = data['groupId'],
        _groupName = data['groupName'];
}

/// 群成员权限
enum EMGroupPermissionType {
  /// none
  EMGroupPermissionTypeNone,

  /// 群成员
  EMGroupPermissionTypeMember,

  /// 群管理员
  EMGroupPermissionTypeAdmin,

  /// 群拥有者
  EMGroupPermissionTypeOwner,
}

/// @nodoc
EMGroupPermissionType convertIntToEMGroupPermissionType(int i) {
  if (i == -1) {
    return EMGroupPermissionType.EMGroupPermissionTypeNone;
  }
  if (i == 0) {
    return EMGroupPermissionType.EMGroupPermissionTypeMember;
  }
  if (i == 1) {
    return EMGroupPermissionType.EMGroupPermissionTypeAdmin;
  }
  if (i == 2) {
    return EMGroupPermissionType.EMGroupPermissionTypeOwner;
  }
  return EMGroupPermissionType.EMGroupPermissionTypeNone;
}

/// @nodoc 会话类型 EMConversationType 数据类型转 int
toEMConversationType(EMConversationType type) {
  switch (type) {
    case EMConversationType.Chat:
      return 0;
    case EMConversationType.GroupChat:
      return 1;
    case EMConversationType.ChatRoom:
      return 2;
    default:
      return 0;
  }
}

/// @nodoc 会话类型 int 数据类型转 EMConversationType
fromEMConversationType(int type) {
  if (type == 0) {
    return EMConversationType.Chat;
  } else if (type == 1) {
    return EMConversationType.GroupChat;
  } else if (type == 2) {
    return EMConversationType.ChatRoom;
  } else if (type == 3) {
    return EMConversationType.DiscussionGroup;
  } else if (type == 4) {
    return EMConversationType.HelpDesk;
  }
}

/// @nodoc 搜索方向 EMSearchDirection 数据类型转 int
toEMSearchDirection(EMSearchDirection direction) {
  if (direction == EMSearchDirection.Up) {
    return 0;
  } else if (direction == EMSearchDirection.Down) {
    return 1;
  }
}

/// 推送消息的显示风格
enum EMPushDisplayStyle {
  /// 简单显示"您有一条新消息
  EMPushDisplayStyleSimpleBanner,

  /// 显示消息内容
  EMPushDisplayStyleMessageSummary,
}

/// @nodoc 推送消息的显示风格 int 数据类型转 EMPushDisplayStyle
fromEMPushDisplayStyle(int type) {
  if (type == 0) {
    return EMPushDisplayStyle.EMPushDisplayStyleSimpleBanner;
  } else {
    return EMPushDisplayStyle.EMPushDisplayStyleMessageSummary;
  }
}

toEMPushDisplayStyle(EMPushDisplayStyle Style) {
  if (Style == EMPushDisplayStyle.EMPushDisplayStyleSimpleBanner) {
    return 0;
  } else if (Style == EMPushDisplayStyle.EMPushDisplayStyleMessageSummary) {
    return 1;
  }
}


/// 消息推送设置
class EMPushConfigs {
  String _displayNickname;
  EMPushDisplayStyle _displayStyle;
  bool _noDisturbOn;
  int _noDisturbStartHour;
  int _noDisturbEndHour;

  /// 设置推送昵称
  String getDisplayNickname() {
    return _displayNickname;
  }

  /// 获取消息推送的显示风格 （目前只支持iOS）
  EMPushDisplayStyle getDisplayStyle() {
    return _displayStyle;
  }

  /// 是否开启消息推送免打扰
  bool isNoDisturbOn() {
    return _noDisturbOn;
  }

  /// 消息推送免打扰开始时间，小时，暂时只支持整点（小时）
  int getNoDisturbStartHour() {
    return _noDisturbStartHour;
  }

  /// 消息推送免打扰结束时间，小时，暂时只支持整点（小时）
  int getNoDisturbEndHour() {
    return _noDisturbEndHour;
  }

  EMPushConfigs.from(Map<String, dynamic> data)
      : _displayNickname = data['nickName'],
        _displayStyle = fromEMPushDisplayStyle(data['displayStyle']),
        _noDisturbOn = data['noDisturbOn'],
        _noDisturbStartHour = data['startHour'],
        _noDisturbEndHour = data['endHour'];
}

enum EMConferenceType {
  /// 普通通信会议
  EMConferenceTypeCommunication // 10
}

/// @nodoc 会议类型 int 数据类型转 EMConferenceType
fromEMConferenceType(int type) {
  if (type == 10) {
    return EMConferenceType.EMConferenceTypeCommunication;
  }
}

/// @nodoc 会议类型 EMConferenceType 数据类型转 int
toEMConferenceType(EMConferenceType type) {
  if (type == EMConferenceType.EMConferenceTypeCommunication) {
    return 10;
  }
}

enum EMConferenceRole {
  NoType,   // 0
  Audience, // 1
  Talker,   // 3
  Admin,    // 7
}

toEMConferenceRole(EMConferenceRole emConferenceRole) {
  if (emConferenceRole == EMConferenceRole.Admin) {
    return 7;
  } else if (emConferenceRole == EMConferenceRole.Talker) {
    return 3;
  } else if (emConferenceRole == EMConferenceRole.Audience) {
    return 1;
  } else if (emConferenceRole == EMConferenceRole.NoType) {
    return 0;
  }
}

fromEMConferenceRole(int role) {
  if (role == 7) {
    return EMConferenceRole.Admin;
  } else if (role == 3) {
    return EMConferenceRole.Talker;
  } else if (role == 1) {
    return EMConferenceRole.Audience;
  } else if (role == 0) {
    return EMConferenceRole.NoType;
  }
}


class EMConference {
  String _conferenceId;
  String _password;
  EMConferenceType _conferenceType;
  EMConferenceRole _conferenceRole;
  int _memberNum;
  var _admins = List<String>();
  var _speakers = List<String>();
  bool _isRecordOnServer = false;


  String getConferenceId() {
    return _conferenceId;
  }

  void setConferenceId(String conferenceId) {
    _conferenceId = conferenceId;
  }

  String getPassword() {
    return _password;
  }

  void setPassword(String password) {
    _password = password;
  }

  EMConferenceType getConferenceType() {
    return _conferenceType;
  }

  void setConferenceType(EMConferenceType conferenceType) {
    _conferenceType = conferenceType;
  }

  EMConferenceRole getConferenceRole() {
    return _conferenceRole;
  }

  void setConferenceRole(EMConferenceRole conferenceRole) {
    _conferenceRole = conferenceRole;
  }

  int getMemberNum() {
    return _memberNum;
  }

  void setMemberNum(int memberNum) {
    _memberNum = memberNum;
  }

  List<String> getAdmins() {
    return _admins;
  }

  void setAdmins(List<String> admins) {
    _admins = admins;
  }

  List<String> getSpeakers() {
    return _speakers;
  }

  void setSpeakers(List<String> speakers) {
    _speakers = speakers;
  }

  bool isRecordOnServer() {
    return _isRecordOnServer;
  }

  void setRecordOnServer(bool isRecordOnServer) {
    _isRecordOnServer = isRecordOnServer;
  }

  void reset() {
    _conferenceId = "";
    _password = "";
    _conferenceType = null;
    _conferenceRole = null;
    _memberNum = 0;
    _admins = null;
    _speakers = null;
  }

  EMConference.from(Map<String, dynamic> data){
    _conferenceId = data["conferenceId"];
    _password = data["password"];
    _conferenceType = fromEMConferenceType(data["conferenceType"]);
    _conferenceRole = fromEMConferenceRole(data["conferenceRole"]);
    _memberNum = data["memberNum"];
    var admins = new List<String>();
    
    for(var s in data["admins"]){
      admins.add(s);
    }
    _admins = admins;
    var speakers = new List<String>();
    for(var s in data["speakers"]){
      speakers.add(s);
    }
    _speakers = speakers;
    _isRecordOnServer = data["isRecordOnServer"];
  }
}
