import 'package:im_flutter_sdk/src/models/chat_user_info.dart';
import 'package:im_flutter_sdk/src/tools/chat_extension.dart';

class ChatContact {
  final String userId;
  final String remark;

  /// ~english
  /// The user attributes of the contact.
  /// ~end
  ///
  /// ~chinese
  /// 联系人的用户属性。
  /// ~end
  final ChatUserInfo? userInfo;

  /// ~english
  /// The timestamp when the contact is added, in milliseconds.
  /// ~end
  ///
  /// ~chinese
  /// 添加联系人的时间戳，单位为毫秒。
  /// ~end
  final int? addTimestamp;

  ChatContact(Map map)
      : userId = map["userId"],
        remark = map["remark"],
        userInfo = map["userInfo"] != null
            ? ChatUserInfo.fromJson(map["userInfo"])
            : null,
        addTimestamp = map["addTimestamp"];

  Map toJson() {
    Map data = {};
    data.putIfNotNull("userId", userId);
    data.putIfNotNull("remark", remark);
    data.putIfNotNull("userInfo", userInfo?.toJson());
    data.putIfNotNull("addTimestamp", addTimestamp);

    return data;
  }

  factory ChatContact.fromJson(Map map) {
    return ChatContact(map);
  }
}
