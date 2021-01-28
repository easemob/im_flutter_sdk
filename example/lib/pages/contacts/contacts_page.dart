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
        physics: BouncingScrollPhysics(),
        data: _contactList,
        itemCount: _contactList.length,
        itemBuilder: (_, index) {
          return getContactRow(index);
        },
        susItemHeight: 40,
        susItemBuilder: (_, index) {
          ContactModel model = _contactList[index];
          String tag = model.getSuspensionTag();
          if ('🔍' == model.getSuspensionTag()) {
            return Container();
          }
          return _buildSusWidget(tag, isFloat: true);
        },
        indexBarData: SuspensionUtil.getTagIndexList(_contactList),
      ),
    );
  }

// // 吸顶组件
  Widget _buildSusWidget(String susTag, {bool isFloat = false}) {
    return Container(
      height: 40,
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
        '${susTag == '★' ? '★ 星标朋友' : susTag}',
        softWrap: false,
        style: TextStyle(
            fontSize: 18,
            color: Color(0xff777777),
            fontWeight: FontWeight.bold),
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
      _handleList(_contactList);
      setState(() {});
    }
  }

  void _handleList(List<ContactModel> list) {
    for (int i = 0, length = list.length; i < length; i++) {
      if (RegExp("[A-Z]").hasMatch(list[i].firstLetter)) {
        list[i].tagIndex = list[i].firstLetter;
      } else {
        list[i].tagIndex = "#";
      }
    }
    //根据A-Z排序
    SuspensionUtil.sortListBySuspensionTag(list);
  }
}
