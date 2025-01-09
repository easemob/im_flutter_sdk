import '../internal/inner_headers.dart';

/// ~english
/// The group options to be configured when the chat group is created.
/// ~end
///
/// ~chinese
/// 创建群组时的属性配置类。
/// ~end
class GroupOptions {
  /// ~english
  /// Sets the group options.
  ///
  /// Param [style] The group style: {GroupStyle}.
  ///
  /// Param [maxCount] The maximum number of members in a group. The default value is 200.
  ///
  /// Param [inviteNeedConfirm] Whether you can automatically add a user to the chat group depends on the settings of [inviteNeedConfirm] and [Options.autoAcceptGroupInvitation].
  ///
  /// - If `inviteNeedConfirm` is set to `false`, you can add the invitee directly to the chat group, regardless of the settings of [Options.autoAcceptGroupInvitation].
  /// - If `inviteNeedConfirm` is set to `true`, whether the invitee automatically joins the chat group or not depends on the settings of [Options.autoAcceptGroupInvitation] on the invitee's client.
  /// - If `autoAcceptGroupInvitation` is set to `true`, the invitee automatically joins the chat group.
  /// - If `autoAcceptGroupInvitation` is set to `false`, the invitee does not join the chat group until this invitee approves the group invitation.
  ///
  /// Param [ext] Group detail extensions which can be in the JSON format to contain more group information.
  /// ~end
  ///
  /// ~chinese
  /// 设置群组属性。
  ///
  /// Param [style] 群组的类型。详见 {GroupStyle}。
  ///
  /// Param [maxCount] 群组的最大成员数，默认为 200。
  ///
  /// Param [inviteNeedConfirm] 邀请用户进群是否需要对方同意。收到邀请是否自动入群取决于两个设置：创建群组时设置 inviteNeedConfirm 以及通过 [Options.setAutoAcceptGroupInvitation] 确定是否自动接受加群邀请。
  /// 具体使用如下：
  ///（1）如果 inviteNeedConfirm 设置为 'false'，在服务端直接加受邀人进群，
  /// 与受邀人对 [Options.setAutoAcceptGroupInvitation] 的设置无关。
  /// (2) 如果 inviteNeedConfirm 设置为 'true'，是否自动入群取决于被邀请人对 [Options.setAutoAcceptGroupInvitation] 的设置。
  /// [Options.setAutoAcceptGroupInvitation] 为 SDK 级别操作，设置为 'true' 时，受邀人收到入群邀请后，SDK 在内部调用同意入群的 API，
  /// 自动接受邀请入群；
  /// 若设置为 'false'，即非自动同意其邀请，用户可以选择接受邀请进群，也可选择拒绝邀请。
  ///
  /// Param [ext] 群组详情扩展，可以采用 JSON 格式，以包含更多群信息。
  /// ~end
  GroupOptions({
    this.style = GroupStyle.PrivateOnlyOwnerInvite,
    this.maxCount = 200,
    this.inviteNeedConfirm = false,
    this.ext,
  });

  /// ~english
  /// Gets the group style.
  ///
  /// **Return** The group style. See {GroupStyle}.
  /// ~end
  ///
  /// ~chinese
  /// 群组类型。
  /// ~end
  final GroupStyle style;

  /// ~english
  /// Gets the maximum number of members in a group.
  ///
  /// **Return** The maximum number of members in a group.
  /// ~end
  ///
  /// ~chinese
  /// 群组的最大人数上限。
  /// ~end
  final int maxCount;

  /// ~english
  /// Whether you need the approval from the user when adding this user to the chat group.
  ///
  /// Whether you can automatically add a user to the chat group depends on the settings of [inviteNeedConfirm] and [Options.autoAcceptGroupInvitation].
  ///
  /// - If `inviteNeedConfirm` is set to `false`, you can add the invitee directly to the chat group, regardless of the settings of [Options.autoAcceptGroupInvitation].
  /// - If `inviteNeedConfirm` is set to `true`, whether the invitee automatically joins the chat group or not depends on the settings of [Options.autoAcceptGroupInvitation] on the invitee's client.
  ///    - If `autoAcceptGroupInvitation` is set to `true`, the invitee automatically joins the chat group.
  ///    - If `autoAcceptGroupInvitation` is set to `false`, the invitee does not join the chat group until this invitee approves the group invitation.
  ///
  /// **Return** Whether you need the approval from the user when adding this user to the chat group.
  /// ~end
  ///
  /// ~chinese
  /// 邀请用户进群是否需要对方同意。收到邀请是否自动入群取决于两个设置：创建群组时设置 inviteNeedConfirm 以及通过 [Options.setAutoAcceptGroupInvitation] 确定是否自动接受加群邀请。
  /// 具体使用如下：
  ///（1）如果 inviteNeedConfirm 设置为 'false'，在服务端直接加受邀人进群，
  /// 与受邀人对 [Options.setAutoAcceptGroupInvitation] 的设置无关。
  /// (2) 如果 inviteNeedConfirm 设置为 'true'，是否自动入群取决于被邀请人对 [Options.setAutoAcceptGroupInvitation] 的设置。
  /// [Options.setAutoAcceptGroupInvitation] 为 SDK 级别操作，设置为 'true' 时，受邀人收到入群邀请后，SDK 在内部调用同意入群的 API，自动接受邀请入群；
  /// 若设置为 'false'，即非自动同意其邀请，用户可以选择接受邀请进群，也可选择拒绝邀请。
  ///
  /// **Return** 邀请用户进群是否需要对方同意。
  /// ~end
  final bool inviteNeedConfirm;

  /// ~english
  ///  Gets the extension in a group.
  ///
  /// **Return** The extension in a group.
  /// ~end
  ///
  /// ~chinese
  /// 群组扩展属性。
  /// ~end
  final String? ext;

  Map toJson() {
    Map data = Map();
    data['style'] = groupStyleTypeToInt(style);
    data['maxCount'] = maxCount;
    data['inviteNeedConfirm'] = inviteNeedConfirm;
    data.putIfNotNull("ext", ext);
    return data;
  }

  @override
  String toString() {
    return this.toJson().toString();
  }
}
