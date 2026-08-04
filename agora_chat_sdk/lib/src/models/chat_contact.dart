import 'package:agora_chat_sdk/src/tools/chat_extension.dart';

class ChatContact {
  final String userId;
  final String remark;

  ChatContact(Map map)
      : userId = map["userId"],
        remark = map["remark"];

  Map toJson() {
    Map data = {};
    data.putIfNotNull("userId", userId);
    data.putIfNotNull("remark", remark);

    return data;
  }

  factory ChatContact.fromJson(Map map) {
    return ChatContact(map);
  }
}
