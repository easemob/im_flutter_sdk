import '../internal/inner_headers.dart';

/// ~english
/// The message Reaction instance class, which has the following attributes:
/// Reaction: The message Reaction.
/// UserCount: The count of users that added the Reaction.
/// UserList: The list of users that added the Reaction.
/// isAddedBySelf: Whether the current user added this Reaction.
/// ~end
///
/// ~chinese
/// 消息 Reaction 实体类，用于指定 Reaction 属性。
/// ~end
class MessageReaction {
  /// ~english
  /// The Reaction content
  /// ~end
  ///
  /// ~chinese
  /// Reaction 内容。
  /// ~end
  final String reaction;

  /// ~english
  /// The count of the users who added this Reaction.
  /// ~end
  ///
  /// ~chinese
  /// 添加了指定 Reaction 的用户数量。
  /// ~end
  final int userCount;

  /// ~english
  /// Whether the current user added this Reaction.
  ///
  /// `Yes`: is added by self
  /// `No`: is not added by self.
  /// ~end
  ///
  /// ~chinese
  /// 当前用户是否添加了该 Reaction。
  ///
  /// - `true`：是；
  /// - `false`：否。
  /// ~end
  final bool isAddedBySelf;

  /// ~english
  /// The list of users that added this Reaction
  ///
  /// **Note**
  /// To get the entire list of users adding this Reaction, you can call [ChatManager.fetchReactionDetail] which returns the user list with pagination.
  /// Other methods like [Message.reactionList], [ChatManager.fetchReactionList] or [ChatEventHandler.onMessageReactionDidChange] can get the first three users.
  /// ~end
  ///
  /// ~chinese
  /// 添加了指定 Reaction 的用户列表。
  /// ~end
  final List<String> userList;

  MessageReaction._private({
    required this.reaction,
    required this.userCount,
    required this.isAddedBySelf,
    required this.userList,
  });

  MessageReaction copyWith({
    String? reaction,
    int? userCount,
    bool? isAddedBySelf,
    List<String>? userList,
  }) {
    return MessageReaction._private(
      reaction: reaction ?? this.reaction,
      userCount: userCount ?? this.userCount,
      isAddedBySelf: isAddedBySelf ?? this.isAddedBySelf,
      userList: userList ?? this.userList,
    );
  }

  factory MessageReaction.fromJson(Map map) {
    String reaction = map["reaction"];
    int count = map["count"];

    bool isAddedBySelf = map["isAddedBySelf"] ?? false;
    List<String> userList = [];
    List<String>? tmp = map.getList("userList");
    if (tmp != null) {
      userList.addAll(tmp);
    }
    return MessageReaction._private(
      reaction: reaction,
      userCount: count,
      isAddedBySelf: isAddedBySelf,
      userList: userList,
    );
  }
}

/// ~english
/// The message reaction change event class.
/// ~end
///
/// ~chinese
/// 消息 Reaction 事件类。
/// ~end
class MessageReactionEvent {
  /// ~english
  /// The conversation ID.
  /// ~end
  ///
  /// ~chinese
  /// 会话 ID。
  /// ~end
  final String conversationId;

  /// ~english
  /// The message ID.
  /// ~end
  ///
  /// ~chinese
  /// 消息 ID。
  /// ~end
  final String messageId;

  /// ~english
  /// The Reaction which is changed.
  /// ~end
  ///
  /// ~chinese
  /// Reaction 列表。
  /// ~end
  final List<MessageReaction> reactions;

  /// ~english
  /// Details of changed operation.
  /// ~end
  ///
  /// ~chinese
  /// 发生变化的操作详情。
  /// ~end
  final List<ReactionOperation> operations;

  MessageReactionEvent._private({
    required this.conversationId,
    required this.messageId,
    required this.reactions,
    required this.operations,
  });

  factory MessageReactionEvent.fromJson(Map map) {
    String conversationId = map["conversationId"];
    String messageId = map["messageId"];
    List<MessageReaction> reactions = [];
    map["reactions"]?.forEach((element) {
      reactions.add(MessageReaction.fromJson(element));
    });

    List<ReactionOperation> operations = [];
    map["operations"]?.forEach((e) {
      operations.add(ReactionOperation.fromJson(e));
    });

    return MessageReactionEvent._private(
      conversationId: conversationId,
      messageId: messageId,
      reactions: reactions,
      operations: operations,
    );
  }
}
