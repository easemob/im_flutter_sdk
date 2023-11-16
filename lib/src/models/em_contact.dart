import 'package:im_flutter_sdk/src/internal/inner_headers.dart';

class EMContact {
  final String userId;
  final String remark;

  EMContact._private(Map map)
      : userId = map["userId"],
        remark = map["remark"];

  /// @nodoc
  Map toJson() {
    Map data = Map();
    data.putIfNotNull("userId", userId);
    data.putIfNotNull("remark", remark);

    return data;
  }

  /// @nodoc
  factory EMContact.fromJson(Map map) {
    return EMContact._private(map);
  }
}
