import 'em_message_reaction.dart';

///
/// 消息 Reaction 事件类。
///
class EMMessageReactionChange {
  /// 会话 ID。
  final String conversationId;

  /// 消息 ID。
  final String messageId;

  /// Reaction 列表。
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
