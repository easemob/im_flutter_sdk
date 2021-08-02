import 'package:easeim_flutter_demo/widgets/demo_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'dart:ui';

class UserInfoPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => UserInfoPageState();
}

class UserInfoPageState extends State<UserInfoPage> {
  List<Widget> _items;
  String _nickName = '';
  TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    buildItems();
    fetchCurrentNickName();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  fetchCurrentNickName() async {
    EMUserInfo userInfo =
        await EMClient.getInstance.userInfoManager.getCurrentUserInfo();
    setState(() {
      _nickName = userInfo.nickName;
    });
  }

  updateCurrentNickName() async {
    EMUserInfo userInfo = await EMClient.getInstance.userInfoManager
        .updateOwnUserInfoWithType(
            EMUserInfoType.EMUserInfoTypeNickName, _textController.text);
    setState(() {
      _nickName = userInfo.nickName;
    });
  }

  buildItems() {
    _items = List();
    Widget item1 = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Container(
            margin: EdgeInsets.only(
              left: 10,
              top: 10,
              bottom: 10,
            ),
            child: Text(
              '头像',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 14.0,
                color: Color.fromRGBO(153, 153, 153, 1),
              ),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(
            left: 15,
            top: 10,
            bottom: 10,
            right: 10,
          ),
          width: 45,
          height: 50,
          child: Image.asset('images/logo.png'),
        ),
      ],
    );
    _items.add(item1);

    Widget item2 = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Container(
            margin: EdgeInsets.only(
              left: 10,
              top: 10,
              bottom: 10,
            ),
            child: Text(
              '环信ID',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 14.0,
                color: Color.fromRGBO(153, 153, 153, 1),
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(left: 10, top: 10, bottom: 10, right: 10),
            child: Text(
              EMClient.getInstance.currentUsername,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14.0,
                color: Color.fromRGBO(153, 153, 153, 1),
              ),
            ),
          ),
        ),
      ],
    );
    _items.add(item2);
  }

  _openAlertDialog() async {
    print('_openAlertDialog');
    showDialog(
      context: context,
      barrierDismissible: false, //// user must tap button!
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('更改昵称'),
          content: Card(
            elevation: 0.0,
            child: Column(
              children: <Widget>[
                // Text('this is a message'),
                TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                      hintText: _nickName ?? '请输入昵称',
                      filled: true,
                      fillColor: Colors.grey.shade50),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('取消'),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
                updateCurrentNickName();
              },
              child: Text('确定'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DemoAppBar('我的资料'),
      body: ListView(
        children: [
          _items[0],
          _items[1],
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _openAlertDialog(),
            child: SafeArea(
              child: Builder(
                // ignore: missing_return
                builder: (_) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(
                            left: 10,
                            top: 10,
                            bottom: 10,
                          ),
                          child: Text(
                            "昵称",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Color.fromRGBO(153, 153, 153, 1),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(
                            left: 10,
                            top: 10,
                            bottom: 10,
                            right: 10,
                          ),
                          child: Text(
                            '$_nickName',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Color.fromRGBO(153, 153, 153, 1),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
