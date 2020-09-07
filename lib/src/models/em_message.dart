import 'package:flutter/cupertino.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

// 消息类型
enum ChatType {
  Chat, // 单聊消息
  GroupChat, // 群聊消息
  ChatRoom, // 聊天室消息
}

// 消息方向
enum Direction {
  SEND,  // 发送的消息
  RECEIVE,  // 接收的消息
}

// 消息状态
enum Status {
  CREATE, // 创建
  PROGRESS, // 发送中
  SUCCESS, // 发送成功
  FAIL, // 发送失败
}

// 附件状态
enum EMDownloadStatus {
  PENDING,  // 下载未开始
  DOWNLOADING, // 下载中
  SUCCESS, // 下载成功
  FAILED, // 下载失败
}

class Message {

  // 消息id
  String msgId = '';

  // 消息所属会话id
  String conversationId = '';

  // 消息发送方
  String from = '';

  // 消息接收方
  String to = '';

  // 消息本地时间
  DateTime localTime = DateTime.now();

  // 消息的服务器时间
  DateTime serverTime = DateTime.now();

  // 消息是否收到已送达回执
  bool hasDeliverAck = false;

  // 消息是否收到已读回执
  bool hasReadAck = false;

  // 消息类型
  ChatType chatType = ChatType.Chat;

  // 消息方向
  Direction direction = Direction.SEND;

  // 消息扩展
  Map attributes;

}

// message body
abstract class EMMessageBody {
  Map<String, dynamic> toJson();
}

// text body
class EMTextMessageBody extends EMMessageBody {

  EMTextMessageBody({@required this.content});

  String content;

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['content'] = this.content;
    return data;
  }
}

abstract class EMFileMessageBody extends EMMessageBody {

  EMFileMessageBody({@required this.localPath});

  // 本地路径
  final String localPath;

  // secret
  String secret = '';

  // 服务器路径
  String remotePath = '';

  // 文件大小
  int fileSize = 0;

  // 文件名称
  String displayName = '';

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['secret'] = this.secret;
    data['remotePath'] = this.remotePath;
    data['fileSize'] = this.fileSize;
    data['localPath'] = this.localPath;
    data['displayName'] = this.displayName;
    return data;
  }
}


// image body
class EMImageMessageBody extends EMFileMessageBody {

  EMImageMessageBody({@required localPath}) : super(localPath: localPath);

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    return data;
  }
}


// video body
class EMVideoMessageBody extends EMFileMessageBody {

  EMVideoMessageBody({@required localPath}) : super(localPath: localPath);


  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    return data;
  }
}

//
//// location body
//class EMLocationMessageBody extends EMMessageBody {
//
//  EMLocationMessageBody({
//    @required this.latitude,
//    @required this.longitude
//  });
//
//  // 地址
//  String address = '';
//
//  // 经纬度
//  final double latitude;
//  final double longitude;
//
//  @override
//  Map<String, dynamic> toJson() {
//    final Map<String, dynamic> data = new Map<String, dynamic>();
//    data['address'] = this.address;
//    data['latitude'] = this.latitude;
//    data['longitude'] = this.longitude;
//    return data;
//  }
//}
//
//// voice body
//class EMVoiceMessageBody extends EMMessageBody {
//
//  @override
//  Map<String, dynamic> toJson() {
//    final Map<String, dynamic> data = new Map<String, dynamic>();
//    return data;
//  }
//}
//
//// file body
//class EMFileMessageBody extends EMMessageBody {
//
//  @override
//  Map<String, dynamic> toJson() {
//    final Map<String, dynamic> data = new Map<String, dynamic>();
//    return data;
//  }
//}
//
//// cmd body
//class EMCmdMessageBody extends EMMessageBody {
//
//  String action = '';
//  bool deliverOnlineOnly = false;
//
//  @override
//  Map<String, dynamic> toJson() {
//    final Map<String, dynamic> data = new Map<String, dynamic>();
//    data['action'] = this.action;
//    data['deliverOnlineOnly'] = this.deliverOnlineOnly;
//    return data;
//  }
//}
//
//// custom body
//class EMCustomMessageBody extends EMMessageBody {
//
//  String event;
//  Map params;
//
//  @override
//  Map<String, dynamic> toJson() {
//    final Map<String, dynamic> data = new Map<String, dynamic>();
//    data['event'] = event;
//    data['params'] = params;
//    return data;
//  }
//}