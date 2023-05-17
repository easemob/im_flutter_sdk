import 'em_chat_enums.dart';

/// ~english
/// Reaction Operation
/// ~end
///
/// ~chinese
/// Reaction 操作
/// ~end
class ReactionOperation {
  /// ~english
  /// Reaction Operation
  ///
  /// Param [userId] Operator userId.
  ///
  /// Param [reaction] Changed reaction.
  ///
  /// Param [operate] Operate type.
  /// ~end
  ///
  /// ~chinese
  /// Reaction 操作
  ///
  /// Param [userId] 操作者。
  ///
  /// Param [reaction] 发生变化的 reaction。
  ///
  /// Param [operate] 具体操作类型。
  /// ~end
  const ReactionOperation._private(
    this.userId,
    this.reaction,
    this.operate,
  );

  /// ~english
  /// Operator userId.
  /// ~end
  ///
  /// ~chinese
  /// 操作者。
  /// ~end
  final String userId;

  /// ~english
  /// Changed reaction.
  /// ~end
  ///
  /// ~chinese
  /// 发生变化的 reaction。
  /// ~end
  final String reaction;

  /// ~english
  /// Operate type.
  /// ~end
  ///
  /// ~chinese
  /// 具体操作类型。
  /// ~end
  final ReactionOperate operate;

  /// @nodoc
  factory ReactionOperation.fromJson(Map map) {
    String userId = map["userId"];
    String reaction = map["reaction"];

    ReactionOperate operate =
        map["operate"] ?? 0 == 0 ? ReactionOperate.Remove : ReactionOperate.Add;

    return ReactionOperation._private(userId, reaction, operate);
  }
}
