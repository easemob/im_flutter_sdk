import '../internal/em_transform_tools.dart';

import 'em_chat_enums.dart';
import '../tools/em_extension.dart';

///
/// The group options to be configured when the chat group is created.
///
class EMGroupOptions {
  EMGroupOptions._private();

  ///
  /// Sets the group options.
  ///
  /// Param [style] The group style: {EMGroupStyle}.
  ///
  /// Param [count] The maximum number of members in a group. The default value is 200.
  ///
  /// Param [inviteNeedConfirm] Whether you can automatically add a user to the chat group depends on the settings of {GroupOptions#inviteNeedConfirm} and {EMOptions#autoAcceptGroupInvitation}.
  ///
  /// - If `inviteNeedConfirm` is set to `false`, you can add the invitee directly to the chat group, regardless of the settings of `EMOptions#autoAcceptGroupInvitation`.
  /// - If `inviteNeedConfirm` is set to `true`, whether the invitee automatically joins the chat group or not depends on the settings of {@link EMOptions#autoAcceptGroupInvitation(boolean)} on the invitee's client.
  ///    - If `autoAcceptGroupInvitation` is set to `true`, the invitee automatically joins the chat group.
  ///    - If `autoAcceptGroupInvitation` is set to `false`, the invitee does not join the chat group until this invitee approves the group invitation.
  ///
  /// Param [extension] Group detail extensions which can be in the JSON format to contain more group information.
  ///
  EMGroupOptions({
    EMGroupStyle style = EMGroupStyle.PrivateOnlyOwnerInvite,
    int count = 200,
    bool inviteNeedConfirm = false,
    String? extension,
  }) {
    _style = style;
    _maxCount = count;
    _inviteNeedConfirm = inviteNeedConfirm;
    _ext = extension;
  }

  EMGroupStyle? _style;
  int? _maxCount;
  bool? _inviteNeedConfirm;
  String? _ext;

  ///
  /// Gets the group style.
  ///
  /// **Return** The group style. See {EMGroupStyle}.
  ///
  EMGroupStyle? get style => _style;

  ///
  /// Gets the maximum number of members in a group.
  ///
  /// **Return** The maximum number of members in a group.
  ///
  int? get maxCount => _maxCount;

  ///
  /// Whether you need the approval from the user when adding this user to the chat group.
  ///
  /// Whether you can automatically add a user to the chat group depends on the settings of {GroupOptions#inviteNeedConfirm} and {EMOptions#autoAcceptGroupInvitation}.
  ///
  /// - If `inviteNeedConfirm` is set to `false`, you can add the invitee directly to the chat group, regardless of the settings of `EMOptions#autoAcceptGroupInvitation`.
  /// - If `inviteNeedConfirm` is set to `true`, whether the invitee automatically joins the chat group or not depends on the settings of {@link EMOptions#autoAcceptGroupInvitation(boolean)} on the invitee's client.
  ///    - If `autoAcceptGroupInvitation` is set to `true`, the invitee automatically joins the chat group.
  ///    - If `autoAcceptGroupInvitation` is set to `false`, the invitee does not join the chat group until this invitee approves the group invitation.
  ///
  /// **Return** Whether you need the approval from the user when adding this user to the chat group.
  ///
  bool? get inviteNeedConfirm => _inviteNeedConfirm;
  String? get ext => _ext;

  /// @nodoc
  factory EMGroupOptions.fromJson(Map? map) {
    return EMGroupOptions._private()
      .._style = groupStyleTypeFromInt(map?['style'])
      .._maxCount = map?['maxCount']
      .._ext = map?['ext']
      .._inviteNeedConfirm = map?.boolValue('inviteNeedConfirm');
  }

  /// @nodoc
  Map toJson() {
    Map data = Map();
    data['style'] = groupStyleTypeToInt(_style);
    data['maxCount'] = _maxCount;
    data['inviteNeedConfirm'] = _inviteNeedConfirm;
    data.setValueWithOutNull("ext", _ext);
    return data;
  }

  @override
  String toString() {
    return this.toJson().toString();
  }
}
