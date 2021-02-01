import 'package:azlistview/azlistview.dart';
import 'package:easeim_flutter_demo/models/contact_model.dart';
import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

class ContactsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ContactsPageState();
}

class ContactsPageState extends State<ContactsPage> {
  List<ContactModel> _contactList = [];

  @override
  void initState() {
    super.initState();
    _fetchContactsFromServer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Title(
          color: Colors.white,
          child: Text(
            '通讯录',
          ),
        ),
      ),
      body: AzListView(
          // physics: BouncingScrollPhysics(),
          data: _contactList,
          itemCount: _contactList.length,
          itemBuilder: (_, index) => getContactRow(index),
          susItemHeight: 30,
          susItemBuilder: (_, index) {
            ContactModel model = _contactList[index];
            String tag = model.getSuspensionTag();
            return _buildSusWidget(
              tag,
              isFloat: true,
            );
          },
          indexBarData: SuspensionUtil.getTagIndexList(_contactList),
          indexHintBuilder: (BuildContext context, String tag) {
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
          }),
    );
  }

// // 吸顶组件
  Widget _buildSusWidget(String susTag, {bool isFloat = false}) {
    return Container(
      height: 30,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(left: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: isFloat
            ? Border(bottom: BorderSide(color: Color(0xFFE6E6E6), width: 0.5))
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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _contactDidSelected(_contactList[index]),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(
                left: 15,
                top: 10,
                bottom: 10,
              ),
              width: 50,
              height: 50,
              child: Image.asset('images/logo.png'),
            ),
            Container(
              alignment: Alignment.centerLeft,
              height: 60,
              margin: EdgeInsets.only(top: 5, bottom: 5, left: 15, right: 5),
              child: Text(
                _contactList[index].contactId,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                ),
                maxLines: 1,
              ),
            )
          ],
        ),
      ),
    );
  }

  _contactDidSelected(ContactModel contact) async {
    EMConversation conv = await EMClient.getInstance.chatManager
        .getConversation(contact.contactId);
    Navigator.of(context).pushNamed('/chat', arguments: conv).then((value) {});
  }

  Future<void> _fetchContactsFromServer() async {
    try {
      List<EMContact> contacts =
          await EMClient.getInstance.contactManager.getAllContactsFromServer();
      _contactList.clear();
      for (var contact in contacts) {
        _contactList.add(ContactModel(contact));
      }
    } on EMError {
      // Fluttertoast.showToast(msg: '获取失败');
    } finally {
      SuspensionUtil.sortListBySuspensionTag(_contactList);
      SuspensionUtil.setShowSuspensionStatus(_contactList);

      setState(() {});
    }
  }
}
