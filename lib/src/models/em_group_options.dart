import '../internal/em_transform_tools.dart';

import 'em_chat_enums.dart';
import '../tools/em_extension.dart';

///
/// Group property options to be configured during group creation.
///
class EMGroupOptions {
  EMGroupOptions._private();

  ///
  /// Create a group property options
  ///
  /// Param [style] The group style.  see {EMGroupStyle}
  ///
  /// Param [count] The maximum number of members in a group. default is 200.
  ///
  /// Param [inviteNeedConfirm]
  ///
  /// Param [extension]
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
  /// Gets the group style.  see {EMGroupStyle}
  ///
  /// **return** The group style.  see {EMGroupStyle}
  ///
  EMGroupStyle? get style => _style;

  ///
  /// Get maximum number of members in a group.
  ///
  /// **return** The maximum number of members in a group.
  ///
  int? get maxCount => _maxCount;

  ///
  /// This option defines whether to ask for content when inviting a user to join a group.
  ///
  /// Whether automatically accepting the invitation to join a group depends on two settings: inviteNeedConfirm, an option during group creation,
  /// and {@link EMOptions#autoAcceptGroupInvitation(boolean)} which determines whether to automatically accept an invitation to join the group.
  /// There are two cases:
  /// (1) If inviteNeedConfirm is set to 'false', adds the invitee directly to the group on the server side
  ///  regardless of the setting of {@link EMOptions#autoAcceptGroupInvitation(boolean)}.
  ///
  /// (2) If inviteNeedConfirm is set to 'true', the user automatically joins a group or decides whether to join, depending on the setting of {@link EMOptions#autoAcceptGroupInvitation(boolean)}.
  ///  {@link EMOptions#autoAcceptGroupInvitation(boolean)} is an SDK-level operation. If it is set to true,
  ///  SDK calls the API for agreeing to join the group to automatically accept the joining invitation.
  ///  If inviteNeedConfirm is set to false, SDK does not automatically accept its invitation,
  ///  but the user decides to accept or reject the invitation.
  ///
  /// **return** The whether to ask for content when inviting a user to join a group.
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
