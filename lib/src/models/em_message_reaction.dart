///
/// 消息 Reaction 实体类，用于指定 Reaction 属性。
///
class EMMessageReaction {
  /// Reaction 内容。
  final String reaction;

  ///  添加了指定 Reaction 的用户数量。
  final int userCount;

  /// 当前用户是否添加了该 Reaction。
  ///
  /// `Yes`: 是。
  /// `No`: 否。
  ///
  final bool isAddedBySelf;

  ///
  /// 添加了指定 Reaction 的用户列表。
  ///
  final List<String> userList;

  EMMessageReaction._private({
    required this.reaction,
    required this.userCount,
    required this.isAddedBySelf,
    required this.userList,
  });

  /// @nodoc
  factory EMMessageReaction.fromJson(Map map) {
    String reaction = map["reaction"];
    int count = map["count"];
    bool isAddedBySelf = map["isAddedBySelf"];
    List<String> userList = map["userList"];
    return EMMessageReaction._private(
      reaction: reaction,
      userCount: count,
      isAddedBySelf: isAddedBySelf,
      userList: userList,
    );
  }
}
