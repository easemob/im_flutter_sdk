import 'dart:ui';
import 'package:azlistview/azlistview.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:lpinyin/lpinyin.dart';

class ContactModel with ISuspensionBean {
  EMUserInfo? _userInfo;
  String? _showName;

  ContactModel.fromUserId(String userId)
      : this._eid = userId,
        this._isCustom = false;

  ContactModel.fromUserInfo(EMUserInfo userInfo)
      : this._userInfo = userInfo,
        this._eid = userInfo.userId,
        this._isCustom = false;

  ContactModel.custom(String name, [Image? avatar])
      : this._eid = name,
        this._isCustom = true;

  final String _eid;

  bool _isCustom = false;
  String? _firstLetter;

  bool get isCustom => _isCustom;
  String get showName {
    if (_showName != null) {
      return _showName!;
    }
    _showName = _userInfo?.nickName ?? _userInfo?.userId ?? _eid;
    if (_showName!.length == 0) {
      _showName = _eid;
    }
    return _showName!;
  }

  String get contactId => _eid;
  String get firstLetter {
    if (_firstLetter == null) {
      if (_isCustom) {
        return '☆';
      }

      String str =
          PinyinHelper.getShortPinyin(showName.substring(0, 1)).toUpperCase();
      if (!RegExp(r'[A-Z]').hasMatch(str)) {
        str = '#';
      }
      _firstLetter = str;
    }
    return _firstLetter!;
  }

  String getSuspensionTag() => this.firstLetter;
}
