import '../internal/inner_headers.dart';

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
  /// - `true`：是；
  /// - `false`：否。
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

    bool isAddedBySelf =
        map.getBoolValue("isAddedBySelf", defaultValue: false)!;
    List<String> userList = [];
    List<String>? tmp = map.getList("userList", valueCallback: (str) {
      return str;
    });
    if (tmp != null) {
      userList.addAll(tmp);
    }
    return EMMessageReaction._private(
      reaction: reaction,
      userCount: count,
      isAddedBySelf: isAddedBySelf,
      userList: userList,
    );
  }
}

///
/// 消息 Reaction 事件类。
///
class EMMessageReactionEvent {
  /// 会话 ID。
  final String conversationId;

  /// 消息 ID。
  final String messageId;

  /// Reaction 列表。
  final List<EMMessageReaction> reactions;

  EMMessageReactionEvent._private({
    required this.conversationId,
    required this.messageId,
    required this.reactions,
  });

  /// @nodoc
  factory EMMessageReactionEvent.fromJson(Map map) {
    String conversationId = map["conversationId"];
    String messageId = map["messageId"];
    List<EMMessageReaction> reactions = [];
    map["reactions"]?.forEach((element) {
      reactions.add(EMMessageReaction.fromJson(element));
    });
    return EMMessageReactionEvent._private(
      conversationId: conversationId,
      messageId: messageId,
      reactions: reactions,
    );
  }
}
