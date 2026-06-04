import 'em_chat_enums.dart';

/// ~english
/// Reaction operation.
/// ~end
///
/// ~chinese
/// Reaction 操作。
/// ~end
class ReactionOperation {
  /// ~english
  /// Reaction operation.
  ///
  /// Param [userId] The user ID of the operator.
  ///
  /// Param [reaction] Changed Reaction.
  ///
  /// Param [operate] The Reaction operation type.
  /// ~end
  ///
  /// ~chinese
  /// Reaction 操作。
  ///
  /// Param [userId] 操作者的用户 ID。
  ///
  /// Param [reaction] 发生变化的 Reaction。
  ///
  /// Param [operate] 具体 Reaction 操作类型。
  /// ~end
  const ReactionOperation(
    this.userId,
    this.reaction,
    this.operate,
  );

  /// ~english
  /// The user ID of the operator.
  /// ~end
  ///
  /// ~chinese
  /// 操作者的用户 ID。
  /// ~end
  final String userId;

  /// ~english
  /// Changed Reaction.
  /// ~end
  ///
  /// ~chinese
  /// 发生变化的 Reaction。
  /// ~end
  final String reaction;

  /// ~english
  /// The Reaction operation type.
  /// ~end
  ///
  /// ~chinese
  /// Reaction 操作类型。
  /// ~end
  final ReactionOperate operate;

  factory ReactionOperation.fromJson(Map map) {
    String userId = map["userId"];
    String reaction = map["reaction"];

    ReactionOperate operate = ReactionOperate.values[map["operate"]];
    return ReactionOperation(userId, reaction, operate);
  }

  Map toJson() {
    Map data = {};
    data["userId"] = userId;
    data["reaction"] = reaction;
    data["operate"] = operate.index;
    return data;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
