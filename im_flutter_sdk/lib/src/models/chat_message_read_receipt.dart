/// ~english
/// The read-receipt summary of a message.
/// ~end
///
/// ~chinese
/// 消息已读回执汇总信息。
/// ~end
class ChatMessageReadReceipt {
  const ChatMessageReadReceipt({
    required this.messageId,
    required this.conversationId,
    required this.isPeerReceipt,
    required this.readCount,
  });

  final String messageId;
  final String conversationId;
  final bool isPeerReceipt;
  final int readCount;

  factory ChatMessageReadReceipt.fromJson(Map map) => ChatMessageReadReceipt(
        messageId: map['messageId'],
        conversationId: map['conversationId'],
        isPeerReceipt: map['isPeerReceipt'] ?? false,
        readCount: map['readCount'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'messageId': messageId,
        'conversationId': conversationId,
        'isPeerReceipt': isPeerReceipt,
        'readCount': readCount,
      };
}
