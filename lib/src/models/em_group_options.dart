import 'em_chat_enums.dart';
import '../tools/em_extension.dart';

class EMGroupOptions {
  EMGroupOptions._private();

  EMGroupOptions(
      {required EMGroupStyle style,
      int count = 200,
      bool inviteNeedConfirm = false,
      String extension = ''}) {
    _style = style;
    _maxCount = count;
    _inviteNeedConfirm = inviteNeedConfirm;
    _ext = extension;
  }

  EMGroupStyle? _style;
  int? _maxCount;
  bool? _inviteNeedConfirm;
  String? _ext;

  EMGroupStyle? get style => _style;
  int? get maxCount => _maxCount;
  bool? get inviteNeedConfirm => _inviteNeedConfirm;
  String? get ext => _ext;

  factory EMGroupOptions.fromJson(Map? map) {
    return EMGroupOptions._private()
      .._style = EMGroupOptions.styleTypeFromInt(map?['style'])
      .._maxCount = map?['maxCount']
      .._ext = map?['ext']
      .._inviteNeedConfirm = map?.boolValue('inviteNeedConfirm');
  }

  Map toJson() {
    Map data = Map();
    data['style'] = EMGroupOptions.styleTypeToInt(_style);
    data['maxCount'] = _maxCount;
    data['inviteNeedConfirm'] = _inviteNeedConfirm;
    data['ext'] = _ext;
    return data;
  }

  static EMGroupStyle styleTypeFromInt(int? type) {
    EMGroupStyle ret = EMGroupStyle.PrivateOnlyOwnerInvite;
    switch (type) {
      case 0:
        {
          ret = EMGroupStyle.PrivateOnlyOwnerInvite;
        }
        break;
      case 1:
        {
          ret = EMGroupStyle.PrivateMemberCanInvite;
        }
        break;
      case 2:
        {
          ret = EMGroupStyle.PublicJoinNeedApproval;
        }
        break;
      case 3:
        {
          ret = EMGroupStyle.PublicOpenJoin;
        }
        break;
    }
    return ret;
  }

  static int styleTypeToInt(EMGroupStyle? type) {
    int ret = 0;
    if (type == null) return ret;
    switch (type) {
      case EMGroupStyle.PrivateOnlyOwnerInvite:
        {
          ret = 0;
        }
        break;
      case EMGroupStyle.PrivateMemberCanInvite:
        {
          ret = 1;
        }
        break;
      case EMGroupStyle.PublicJoinNeedApproval:
        {
          ret = 2;
        }
        break;
      case EMGroupStyle.PublicOpenJoin:
        {
          ret = 3;
        }
        break;
    }
    return ret;
  }

  @override
  String toString() {
    return this.toJson().toString();
  }
}
