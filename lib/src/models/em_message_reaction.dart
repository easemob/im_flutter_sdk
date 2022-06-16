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
