import 'package:im_flutter_sdk/src/tools/chat_extension.dart';

/// ~english
/// The message sender info class, which contains the user attributes of the message sender.
/// ~end
///
/// ~chinese
/// 消息发送者信息类，包含消息发送者的用户属性。
/// ~end
class ChatMessageSenderInfo {
  /// ~english
  /// Creates a message sender info.
  /// ~end
  ///
  /// ~chinese
  /// 创建消息发送者信息。
  /// ~end
  ChatMessageSenderInfo({
    this.userId,
    this.nickname,
    this.avatarUrl,
    this.remark,
    this.groupNameCard,
  });

  factory ChatMessageSenderInfo.fromJson(Map map) {
    return ChatMessageSenderInfo(
      userId: map["userId"],
      nickname: map["nickname"],
      avatarUrl: map["avatarUrl"],
      remark: map["remark"],
      groupNameCard: map["groupNameCard"],
    );
  }

  Map toJson() {
    Map data = {};
    data.putIfNotNull("userId", userId);
    data.putIfNotNull("nickname", nickname);
    data.putIfNotNull("avatarUrl", avatarUrl);
    data.putIfNotNull("remark", remark);
    data.putIfNotNull("groupNameCard", groupNameCard);

    return data;
  }

  /// ~english
  /// The user ID of the message sender.
  /// ~end
  ///
  /// ~chinese
  /// 消息发送者的用户 ID。
  /// ~end
  final String? userId;

  /// ~english
  /// The nickname of the message sender.
  /// ~end
  ///
  /// ~chinese
  /// 消息发送者的昵称。
  /// ~end
  final String? nickname;

  /// ~english
  /// The avatar URL of the message sender.
  /// ~end
  ///
  /// ~chinese
  /// 消息发送者的头像。
  /// ~end
  final String? avatarUrl;

  /// ~english
  /// The remark of the message sender set by the current user.
  /// ~end
  ///
  /// ~chinese
  /// 当前用户给消息发送者设置的备注。
  /// ~end
  final String? remark;

  /// ~english
  /// The group namecard of the message sender.
  /// ~end
  ///
  /// ~chinese
  /// 消息发送者的群名片。
  /// ~end
  final String? groupNameCard;
}
