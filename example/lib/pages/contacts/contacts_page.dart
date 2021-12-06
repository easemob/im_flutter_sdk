import 'package:azlistview/azlistview.dart';
import 'package:easeim_flutter_demo/unit/event_bus_manager.dart';
import 'package:easeim_flutter_demo/models/contact_model.dart';
import 'package:easeim_flutter_demo/unit/share_preference_manager.dart';
import 'package:easeim_flutter_demo/widgets/common_widgets.dart';
import 'package:easeim_flutter_demo/widgets/demo_app_bar.dart';
import 'package:easeim_flutter_demo/widgets/pop_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import 'contact_item.dart';

class ContactsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ContactsPageState();
}

class ContactsPageState extends State<ContactsPage>
    implements EMContactEventListener {
  List<ContactModel> _contactList = [];
  List<ContactModel> _topList = [
    ContactModel.custom('新的好友'),
    ContactModel.custom('群聊'),
    ContactModel.custom('聊天室'),
  ];

  int _friendRequestCount = 0;

  @override
  void initState() {
    super.initState();
    EMClient.getInstance.contactManager.addContactListener(this);

    String currentUser = EMClient.getInstance.currentUsername;
    SharePreferenceManager.load(currentUser, callback: () {
      setState(() {});
    });
  }

  void didChangeDependencies() {
    super.didChangeDependencies();

    _fetchContactsFromServer(3);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DemoAppBar(
        '通讯录',
        rightWidgets: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => PopMenu.show(
              context,
              [
                PopMenuItem('添加好友'),
                PopMenuItem('添加群组'),
              ],
              callback: (index) {
                if (index == 0) {
                  Navigator.of(context)
                      .pushNamed('/addFriends')
                      .then((value) {});
                } else if (index == 1) {
                  Navigator.of(context)
                      .pushNamed('/publicGroups')
                      .then((value) {});
                }
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
        child: Builder(
          builder: (_) {
            int unreadCount = 0;
            if (index == 0) {
              unreadCount = _friendRequestCount;
            }
            if (model.isCustom) {
              return ContactItem(
                model.showName,
                unreadCount: unreadCount,
              );
            } else {
              return slidableItem(
                child: ContactItem(
                  model.showName,
                  unreadCount: unreadCount,
                ),
                actions: [
                  slidableDeleteAction(
                    onTap: () => _deleteContact(model),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  _deleteContact(ContactModel contact) {
    try {
      SmartDialog.showLoading(msg: '删除中...');
      EMClient.getInstance.contactManager.deleteContact(contact.contactId);
      SmartDialog.showToast('删除成功');
    } on EMError catch (e) {
      SmartDialog.showToast('删除失败$e');
    } finally {
      SmartDialog.dismiss();
    }
  }

  _contactDidSelected(ContactModel contact, int index) async {
    if (contact.isCustom) {
      if (index == 0) {
        Navigator.of(context).pushNamed('/friendsRequest').then((value) {
          _friendRequestCount = SharePreferenceManager.loadUnreadCount();
          _fetchContactsFromServer();
        });
      } else if (index == 1) {
        Navigator.of(context).pushNamed('/joinedGroups').then((value) {
          _fetchContactsFromServer();
        });
      } else if (index == 2) {
        Navigator.of(context).pushNamed('/rooms').then((value) {
          _fetchContactsFromServer();
        });
      }
    } else {
      EMConversation conv = await EMClient.getInstance.chatManager
          .getConversation(contact.contactId);
      if (conv == null) {
        SmartDialog.showToast('会话创建失败');
        return;
      }
      Navigator.of(context).pushNamed(
        '/chat',
        arguments: [contact.contactId, conv],
      ).then((value) {
        eventBus.fire(EventBusManager.updateConversations());
      });
    }
  }

  Future<void> _fetchContactsFromServer([int count = 1]) async {
    if (count == 0) {
      return;
    }

    count--;
    try {
      List<String> contacts =
          await EMClient.getInstance.contactManager.getAllContactsFromServer();
      List<ContactModel> list = await _fetchUserInfo(contacts);
      _contactList.clear();
      _contactList.addAll(list);
    } on EMError {
      SmartDialog.showToast('获取失败');
      _loadLocalContacts(count);
    } finally {
      SuspensionUtil.sortListBySuspensionTag(_contactList);
      SuspensionUtil.setShowSuspensionStatus(_contactList);
      _contactList.insertAll(0, _topList);
      setState(() {});
    }
  }

  Future<void> _loadLocalContacts([int count = 1]) async {
    try {
      List<String> contacts =
          await EMClient.getInstance.contactManager.getAllContactsFromDB();
      List<ContactModel> list = await _fetchUserInfo(contacts);
      _contactList.clear();
      _contactList.addAll(list);
    } on EMError {
    } finally {
      SuspensionUtil.sortListBySuspensionTag(_contactList);
      SuspensionUtil.setShowSuspensionStatus(_contactList);
      _contactList.insertAll(0, _topList);
      setState(() {});
      Future.delayed(Duration(seconds: 3)).then((value) {
        _fetchContactsFromServer(count);
      });
    }
  }

  Future<List<ContactModel>> _fetchUserInfo(List<String> emIds) async {
    List<ContactModel> ret = [];

    Map<String, EMUserInfo> map = await EMClient.getInstance.userInfoManager
        .fetchUserInfoByIdWithExpireTime(emIds);

    List<String> hasInfoIds = map.keys.toList();
    for (var hasInfoId in hasInfoIds) {
      ret.add(ContactModel.fromUserInfo(map[hasInfoId]));
    }

    List<String> noInfoIds = emIds.toList();
    noInfoIds.removeWhere((element) {
      return hasInfoIds.contains(element);
    });

    for (var noInfoId in noInfoIds) {
      ret.add(ContactModel.fromUserId(noInfoId));
    }

    return ret;
  }

  @override
  void onContactAdded(String userName) {
    _fetchContactsFromServer();
    SmartDialog.showToast('已被$userName加为好友');
  }

  @override
  void onContactDeleted(String userName) {
    _fetchContactsFromServer();
    SmartDialog.showToast('已被$userName删除好友');
  }

  @override
  void onContactInvited(String userName, String reason) {
    SharePreferenceManager.addRequest(userName);
    _friendRequestCount = SharePreferenceManager.loadUnreadCount();
    setState(() {});
  }

  @override
  void onFriendRequestAccepted(String userName) {
    SmartDialog.showToast('好友申请被$userName同意');
    _fetchContactsFromServer();
  }

  @override
  void onFriendRequestDeclined(String userName) {
    SmartDialog.showToast('好友申请被$userName拒绝');
  }

  void dispose() {
    EMClient.getInstance.contactManager.removeContactListener(this);
    super.dispose();
  }
}
