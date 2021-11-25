class EMGroupMessageAck {
  /// 对应的消息id
  late String messageId;

  /// 已读发送方id
  late String from;

  /// 已读回复内容
  String? content;

  /// 群消息已读人数
  int readCount = 0;

  /// 本条已读发送时间
  int timestamp = 0;

  factory EMGroupMessageAck.fromJson(Map map) {
    EMGroupMessageAck ack = EMGroupMessageAck._private();
    ack.messageId = map["msg_id"] as String;
    ack.from = map["from"] as String;
    if (map.containsKey("content")) {
      ack.content = map["content"] as String;
    }
    ack.readCount = map["count"] as int;
    ack.timestamp = map["timestamp"] as int;
    return ack;
  }

  EMGroupMessageAck._private();
}
