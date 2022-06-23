import '../internal/em_transform_tools.dart';
import 'em_chat_enums.dart';

/// @nodoc
abstract class EMMessageBody {
  EMMessageBody({required this.type});

  /// @nodoc
  EMMessageBody.fromJson({
    required Map map,
    required this.type,
  });

  /// @nodoc
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = messageTypeToTypeStr(this.type);
    return data;
  }

  @override
  String toString() {
    return toJson().toString();
  }

  /// 获取消息类型。
  MessageType type;
}
