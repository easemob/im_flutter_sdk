import 'package:im_flutter_sdk/src/tools/em_extension.dart';
import 'package:im_flutter_sdk/src/models/em_user_info.dart';

class EMContact {
  final String userId;
  final String remark;
  // Unix epoch in milliseconds
  final int? updatedAt;
  final EMUserInfo? userInfo;

  EMContact(Map map)
      : userId = map["userId"],
        remark = map["remark"],
        updatedAt = map["updatedAt"],
        userInfo = (map["userInfo"] is Map)
            ? EMUserInfo.fromJson(Map.from(map["userInfo"]))
            : null;

  Map toJson() {
    Map data = {};
    data.putIfNotNull("userId", userId);
    data.putIfNotNull("remark", remark);
    data.putIfNotNull("updatedAt", updatedAt);
    if (userInfo != null) {
      data["userInfo"] = userInfo!.toJson();
    }

    return data;
  }

  factory EMContact.fromJson(Map map) {
    return EMContact(map);
  }
}
