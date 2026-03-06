import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:im_flutter_sdk/src/tools/em_extension.dart';

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
class EMMessageReaction {
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
  /// To get the entire list of users adding this Reaction, you can call [EMChatManager.fetchReactionDetail] which returns the user list with pagination.
  /// Other methods like [EMMessage.reactionList], [EMChatManager.fetchReactionList] or [EMChatEventHandler.onMessageReactionDidChange] can get the first three users.
  /// ~end
  ///
  /// ~chinese
  /// 添加了指定 Reaction 的用户列表。
  /// ~end
  final List<String> userList;

  EMMessageReaction({
    required this.reaction,
    required this.userCount,
    required this.isAddedBySelf,
    required this.userList,
  });

  EMMessageReaction copyWith({
    String? reaction,
    int? userCount,
    bool? isAddedBySelf,
    List<String>? userList,
  }) {
    return EMMessageReaction(
      reaction: reaction ?? this.reaction,
      userCount: userCount ?? this.userCount,
      isAddedBySelf: isAddedBySelf ?? this.isAddedBySelf,
      userList: userList ?? this.userList,
    );
  }

  factory EMMessageReaction.fromJson(Map map) {
    String reaction = map["reaction"];
    int count = map["count"];

    bool isAddedBySelf = map["isAddedBySelf"] ?? false;
    List<String> userList = [];
    List<String>? tmp = map.getList("userList");
    if (tmp != null) {
      userList.addAll(tmp);
    }
    return EMMessageReaction(
      reaction: reaction,
      userCount: count,
      isAddedBySelf: isAddedBySelf,
      userList: userList,
    );
  }

  Map toJson() {
    Map data = {};
    data["reaction"] = reaction;
    data["count"] = userCount;
    data["isAddedBySelf"] = isAddedBySelf;
    data["userList"] = userList;
    return data;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}

/// ~english
/// The message reaction change event class.
/// ~end
///
/// ~chinese
/// 消息 Reaction 事件类。
/// ~end
class EMMessageReactionEvent {
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
  final List<EMMessageReaction> reactions;

  /// ~english
  /// Details of changed operation.
  /// ~end
  ///
  /// ~chinese
  /// 发生变化的操作详情。
  /// ~end
  final List<ReactionOperation> operations;

  EMMessageReactionEvent({
    required this.conversationId,
    required this.messageId,
    required this.reactions,
    required this.operations,
  });

  factory EMMessageReactionEvent.fromJson(Map map) {
    String conversationId = map["convId"];
    String messageId = map["msgId"];
    List<EMMessageReaction> reactions = [];
    map["reactions"]?.forEach((element) {
      reactions.add(EMMessageReaction.fromJson(element));
    });

    List<ReactionOperation> operations = [];
    map["operations"]?.forEach((e) {
      operations.add(ReactionOperation.fromJson(e));
    });

    return EMMessageReactionEvent(
      conversationId: conversationId,
      messageId: messageId,
      reactions: reactions,
      operations: operations,
    );
  }

  Map toJson() {
    Map data = {};
    data["convId"] = conversationId;
    data["msgId"] = messageId;
    data["reactions"] = reactions.map((r) => r.toJson()).toList();
    data["operations"] = operations.map((o) => o.toJson()).toList();
    return data;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
