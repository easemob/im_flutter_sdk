import 'package:azlistview/azlistview.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

class ContactModel with ISuspensionBean {
  ContactModel(this._contact) : this._eid = _contact.eid;
  final EMContact _contact;
  final String _eid;

  String _firstLetter;

  String get contactId => _eid;
  String get firstLetter {
    if (_firstLetter == null) {
      String str = _contact.eid.substring(0, 1)?.toUpperCase();
      if (!RegExp(r'[A-Z]').hasMatch(str)) {
        str = '#';
      }
      _firstLetter = str;
    }
    return _firstLetter;
  }

  String getSuspensionTag() => this.firstLetter;
}
