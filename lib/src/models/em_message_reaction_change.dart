import 'em_message_reaction.dart';

class EMMessageReactionChange {
  /// The conversation ID
  final String conversationId;

  /// The message ID
  final String messageId;

  /// The Reaction which is changed
  final List<EMMessageReaction> reactions;

  EMMessageReactionChange._private({
    required this.conversationId,
    required this.messageId,
    required this.reactions,
  });

  /// nodoc
  factory EMMessageReactionChange.fromJson(Map map) {
    String conversationId = map["conversationId"];
    String messageId = map["messageId"];
    List<EMMessageReaction> reactions = [];
    map["reactions"]?.forEach((element) {
      reactions.add(EMMessageReaction.fromJson(element));
    });
    return EMMessageReactionChange._private(
      conversationId: conversationId,
      messageId: messageId,
      reactions: reactions,
    );
  }
}
