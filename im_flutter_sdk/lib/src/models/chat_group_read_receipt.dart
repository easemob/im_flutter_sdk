import 'package:im_flutter_sdk/im_flutter_sdk.dart';

/// ~english
/// The details of a group-message read receipt.
/// ~end
///
/// ~chinese
/// 群消息已读回执详情。
/// ~end
class ChatGroupReadReceipt {
  const ChatGroupReadReceipt({
    required this.messageId,
    this.receiptId,
    required this.from,
    required this.readCount,
    required this.timestamp,
  });

  final String messageId;
  final String? receiptId;
  final GroupMemberInfo from;
  final int readCount;
  final int timestamp;

  factory ChatGroupReadReceipt.fromJson(Map map) => ChatGroupReadReceipt(
        messageId: map['msgId'],
        receiptId: map['ack_id'],
        from: GroupMemberInfo.fromJson(Map<String, dynamic>.from(map['from'])),
        readCount: map['count'] ?? 0,
        timestamp: map['timestamp'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'msgId': messageId,
        'ack_id': receiptId,
        'from': from.toJson(),
        'count': readCount,
        'timestamp': timestamp,
      };
}
