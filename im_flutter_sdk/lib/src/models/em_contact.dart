import 'package:im_flutter_sdk/src/tools/em_extension.dart';

class EMContact {
  final String userId;
  final String remark;

  EMContact(Map map)
      : userId = map["userId"],
        remark = map["remark"];

  Map toJson() {
    Map data = {};
    data.putIfNotNull("userId", userId);
    data.putIfNotNull("remark", remark);

    return data;
  }

  factory EMContact.fromJson(Map map) {
    return EMContact(map);
  }
}
