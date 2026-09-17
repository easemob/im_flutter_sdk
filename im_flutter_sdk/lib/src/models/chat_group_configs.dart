import 'package:im_flutter_sdk/src/tools/chat_extension.dart';

/// ~english
/// The group configuration used when creating or updating a group.
/// ~end
///
/// ~chinese
/// 创建或更新群组时使用的群组配置。
/// ~end
class ChatGroupConfigs {
  /// ~english
  /// Creates group configurations.
  ///
  /// Param [maxCount] The maximum number of group members.
  ///
  /// Param [inviteNeedConfirm] Whether an invitee must confirm a group invitation.
  ///
  /// Param [ext] The group extension.
  ///
  /// Param [isPublic] Whether the group is public.
  ///
  /// Param [joinApprovalRequired] Whether joining the public group requires approval.
  ///
  /// Param [allowInvites] Whether ordinary members can invite users.
  /// ~end
  ///
  /// ~chinese
  /// 创建群组配置。
  ///
  /// Param [maxCount] 群组最大成员数。
  ///
  /// Param [inviteNeedConfirm] 受邀用户是否需要确认群邀请。
  ///
  /// Param [ext] 群组扩展信息。
  ///
  /// Param [isPublic] 是否为公开群。
  ///
  /// Param [joinApprovalRequired] 加入公开群是否需要审批。
  ///
  /// Param [allowInvites] 是否允许普通成员邀请用户入群。
  /// ~end
  const ChatGroupConfigs({
    this.maxCount = 200,
    this.inviteNeedConfirm = false,
    this.ext,
    this.isPublic = false,
    this.joinApprovalRequired = false,
    this.allowInvites = false,
  });

  final int maxCount;
  final bool inviteNeedConfirm;
  final String? ext;
  final bool isPublic;
  final bool joinApprovalRequired;
  final bool allowInvites;

  factory ChatGroupConfigs.fromJson(Map map) => ChatGroupConfigs(
        maxCount: map['maxCount'] ?? 200,
        inviteNeedConfirm: map['inviteNeedConfirm'] ?? false,
        ext: map['ext'],
        isPublic: map['isPublic'] ?? false,
        joinApprovalRequired: map['joinApprovalRequired'] ?? false,
        allowInvites: map['allowInvites'] ?? false,
      );

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'maxCount': maxCount,
      'inviteNeedConfirm': inviteNeedConfirm,
      'isPublic': isPublic,
      'joinApprovalRequired': joinApprovalRequired,
      'allowInvites': allowInvites,
    };
    data.putIfNotNull('ext', ext);
    return data;
  }
}

/// ~english
/// Bit-mask values that specify which group configuration fields to update.
/// Combine values with the bitwise OR operator.
/// ~end
///
/// ~chinese
/// 指定需要更新的群组配置字段的位掩码值。多个值可使用按位或组合。
/// ~end
abstract final class ChatGroupConfigsType {
  static const int allowInvites = 1 << 0;
  static const int maxUsers = 1 << 1;
  static const int inviteNeedConfirm = 1 << 2;
  static const int joinApprovalRequired = 1 << 3;
  static const int isPublic = 1 << 4;
  static const int ext = 1 << 5;
}
