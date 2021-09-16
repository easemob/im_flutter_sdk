import 'dart:ui';

import 'package:azlistview/azlistview.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

class ContactModel with ISuspensionBean {
  ContactModel.contact(EMContact contact)
      : this._eid = contact.eid,
        this._isCustom = false;
  ContactModel.custom(String name, [Image avatar])
      : this._eid = name,
        this._isCustom = true;

  final String _eid;

  bool _isCustom = false;
  String _firstLetter;

  bool get isCustom => _isCustom;
  String get name => _eid;
  String get contactId => _eid;
  String get firstLetter {
    if (_firstLetter == null) {
      if (_isCustom) {
        return '☆';
      }
      String str = _eid.substring(0, 1)?.toUpperCase();
      if (!RegExp(r'[A-Z]').hasMatch(str)) {
        str = '#';
      }
      _firstLetter = str;
    }
    return _firstLetter;
  }

  String getSuspensionTag() => this.firstLetter;
}
