import 'package:azlistview/azlistview.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

class ContactModel extends ISuspensionBean {
  ContactModel(this._contact) : this._eid = _contact.eid;
  final EMContact _contact;
  final String _eid;

  String get contactId => _eid;
  String get firstLetter => _contact.eid.substring(0, 1);
  String tagIndex;

  String getSuspensionTag() => _contact.eid.substring(0, 1);
}
