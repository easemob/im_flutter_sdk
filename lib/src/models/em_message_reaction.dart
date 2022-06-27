///
/// The message Reaction instance class, which has the following attributes:
/// Reaction: The message Reaction.
/// UserCount: The count of users that added the Reaction.
/// UserList: The list of users that added the Reaction.
/// isAddedBySelf: Whether the current user added this Reaction.
///
class EMMessageReaction {
  /// The Reaction content
  final String reaction;

  /// The count of the users who added this Reaction
  final int userCount;

  /// Whether the current user added this Reaction
  ///
  /// `Yes`: is added by self
  /// `No`: is not added by self.
  ///
  final bool isAddedBySelf;

  ///
  /// The list of users that added this Reaction
  ///
  /// **Note**
  /// To get the entire list of users adding this Reaction, you can call {@link #getReactionDetail(EMChatManager)} which returns the user list with pagination. Other methods like {@link #reactionList(EMMessage)}, {@link #getReactionList(EMChatManager)} or {@link messageReactionDidChange(EMChatManagerListener)} can get the first three users.
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

///
/// The message reaction change event class.
///
class EMMessageReactionEvent {
  /// The conversation ID
  final String conversationId;

  /// The message ID
  final String messageId;

  /// The Reaction which is changed
  final List<EMMessageReaction> reactions;

  EMMessageReactionEvent._private({
    required this.conversationId,
    required this.messageId,
    required this.reactions,
  });

  /// nodoc
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
