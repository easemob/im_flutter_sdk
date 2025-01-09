import '../../src/internal/inner_headers.dart';

class Contact {
  final String userId;
  final String remark;

  Contact._private(Map map)
      : userId = map["userId"],
        remark = map["remark"];

  Map toJson() {
    Map data = Map();
    data.putIfNotNull("userId", userId);
    data.putIfNotNull("remark", remark);

    return data;
  }

  factory Contact.fromJson(Map map) {
    return Contact._private(map);
  }
}
