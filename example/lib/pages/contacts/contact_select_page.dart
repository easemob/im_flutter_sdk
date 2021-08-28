import 'package:azlistview/azlistview.dart';
import 'package:easeim_flutter_demo/models/contact_model.dart';
import 'package:easeim_flutter_demo/widgets/common_widgets.dart';
import 'package:easeim_flutter_demo/widgets/demo_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

class ContactSelectPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ContactSelectPageState();
}

class ContactSelectPageState extends State<ContactSelectPage> {
  List<ContactModel> _contactList = [];
  List<String> _selectedUsers = [];
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchContactsFromServer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DemoAppBar(
        '选择联系人',
        rightWidgets: [
          TextButton(
            child: Text(
              '确定',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => {Navigator.pop(context, _selectedUsers)},
          )
        ],
      ),
      body: AzListView(
        data: _contactList,
        itemCount: _contactList.length,
        itemBuilder: (_, index) => getContactRow(index),
        separatorBuilder: (_, __) {
          return Container(
            color: Colors.grey[300],
            height: 0.5,
            margin: EdgeInsets.only(left: 20, right: 10),
          );
        },
        susItemHeight: 30,
        susItemBuilder: (_, index) {
          ContactModel model = _contactList[index];
          if (model.firstLetter == '☆') {
            return Container();
          } else {
            String tag = model.getSuspensionTag();
            return _buildSusWidget(
              tag,
              isFloat: false,
            );
          }
        },
        indexBarData: ['☆', ...kIndexBarData],
        indexHintBuilder: (BuildContext context, String tag) {
          if (tag == '☆') {
            return Container();
          } else {
            return Container(
              alignment: Alignment.center,
              width: 60.0,
              height: 60.0,
              decoration: BoxDecoration(
                color: Colors.blue[700].withAlpha(200),
                shape: BoxShape.circle,
              ),
              child: Text(
                tag,
                style: TextStyle(color: Colors.white, fontSize: 30.0),
              ),
            );
          }
        },
      ),
    );
  }

  // 吸顶组件
  Widget _buildSusWidget(String susTag, {bool isFloat = false}) {
    return Container(
      height: 30,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(left: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: isFloat
            ? Border(
                bottom: BorderSide(
                  color: Color(0xFFE6E6E6),
                  width: 0.5,
                ),
              )
            : null,
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        susTag,
        textAlign: TextAlign.center,
        softWrap: true,
        style: TextStyle(
          fontSize: 17,
          color: Color(0xff777777),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget getContactRow(int index) {
    ContactModel model = _contactList[index];
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _contactDidSelected(model, index),
      child: SafeArea(
        child: SelectContactItem(
          model.name,
          selected: _selectedUsers.contains(
            model.contactId,
          ),
        ),
      ),
    );
  }

  _contactDidSelected(ContactModel contact, int index) {
    if (_selectedUsers.contains(contact.contactId)) {
      _selectedUsers.remove(contact.contactId);
    } else {
      _selectedUsers.add(contact.contactId);
    }
    setState(() {});
  }

  Future<void> _fetchContactsFromServer() async {
    try {
      List<EMContact> contacts =
          await EMClient.getInstance.contactManager.getAllContactsFromServer();
      _contactList.clear();
      for (var contact in contacts) {
        _contactList.add(ContactModel.contact(contact));
      }
    } on EMError {
      SmartDialog.showToast('获取失败');
      _loadLocalContacts();
    } finally {
      SuspensionUtil.sortListBySuspensionTag(_contactList);
      SuspensionUtil.setShowSuspensionStatus(_contactList);
      setState(() {});
    }
  }

  Future<void> _loadLocalContacts() async {
    try {
      List<EMContact> contacts =
          await EMClient.getInstance.contactManager.getAllContactsFromDB();
      _contactList.clear();
      for (var contact in contacts) {
        _contactList.add(ContactModel.contact(contact));
      }
    } on EMError {} finally {
      SuspensionUtil.sortListBySuspensionTag(_contactList);
      SuspensionUtil.setShowSuspensionStatus(_contactList);
      setState(() {});
      _fetchContactsFromServer();
    }
  }
}

class SelectContactItem extends StatelessWidget {
  SelectContactItem(
    this.title, {
    this.avatar,
    this.selected = false,
  });
  final String title;
  final Image avatar;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(
            left: 15,
            top: 10,
            bottom: 10,
          ),
          width: 45,
          height: 50,
          child: avatar ?? Image.asset('images/logo.png'),
        ),
        Container(
          alignment: Alignment.centerLeft,
          height: 50,
          margin: EdgeInsets.only(
            top: 5,
            bottom: 5,
            left: 15,
            right: 5,
          ),
          child: Text(
            title,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: sFontSize(17),
              color: Colors.black,
            ),
            maxLines: 1,
          ),
        ),
        Expanded(
          child: SizedBox(),
        ),
        Container(
          margin: EdgeInsets.only(
            right: sWidth(30),
          ),
          child: Image.asset(
            selected
                ? 'images/contact_select_check.png'
                : 'images/contact_select_uncheck.png',
            fit: BoxFit.contain,
            width: sWidth(50),
            height: sWidth(50),
          ),
        ),
      ],
    );
  }
}
