import '../internal/inner_headers.dart';

class EMContact {
  final String userId;
  final String remark;

  EMContact._private(Map map)
      : userId = map["userId"],
        remark = map["remark"];

  Map toJson() {
    Map data = Map();
    data.putIfNotNull("userId", userId);
    data.putIfNotNull("remark", remark);

    return data;
  }

  factory EMContact.fromJson(Map map) {
    return EMContact._private(map);
  }
}
