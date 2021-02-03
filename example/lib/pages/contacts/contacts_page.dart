import 'package:azlistview/azlistview.dart';
import 'package:easeim_flutter_demo/models/contact_model.dart';
import 'package:easeim_flutter_demo/widgets/demo_app_bar.dart';
import 'package:easeim_flutter_demo/widgets/pop_menu.dart';
import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import 'contact_item.dart';

class ContactsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ContactsPageState();
}

class ContactsPageState extends State<ContactsPage>
    implements EMContactEventListener {
  List<ContactModel> _contactList = [];
  List<ContactModel> _topList = [];

  @override
  void initState() {
    super.initState();
    _topList.addAll([
      ContactModel.custom('新的好友'),
      ContactModel.custom('群聊'),
      ContactModel.custom('聊天室')
    ]);
    _fetchContactsFromServer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DemoAppBar.normal(
        '通讯录',
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => PopMenu.show(
              context,
              [
                PopMenuItem('添加好友'),
                PopMenuItem('添加群组'),
              ],
              callback: (index) {
                print('index --- $index');
              },
            ),
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
          /* ['☆', ...kIndexBarData] */
          indexBarData: SuspensionUtil.getTagIndexList(_contactList),
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
      onTap: () => _contactDidSelected(model),
      child: SafeArea(
        child: ContactItem(model.name),
      ),
    );
  }

  _contactDidSelected(ContactModel contact) async {
    if (contact.isCustom) {
    } else {
      EMConversation conv = await EMClient.getInstance.chatManager
          .getConversation(contact.contactId);
      Navigator.of(context).pushNamed('/chat', arguments: conv).then((value) {
        // TODO: reload conversations list.
      });
    }
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
      // Fluttertoast.showToast(msg: '获取失败');
    } finally {
      SuspensionUtil.sortListBySuspensionTag(_contactList);
      SuspensionUtil.setShowSuspensionStatus(_contactList);
      _contactList.insertAll(0, _topList);
      setState(() {});
    }
  }

  @override
  void onContactAdded(String userName) {}

  @override
  void onContactDeleted(String userName) {}

  @override
  void onContactInvited(String userName, String reason) {}

  @override
  void onFriendRequestAccepted(String userName) {}

  @override
  void onFriendRequestDeclined(String userName) {}
}
