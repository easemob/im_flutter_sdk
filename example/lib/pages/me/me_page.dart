import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

class MePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MePageState();
}

class MePageState extends State<MePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("我"),
      ),
      body: Container(
        margin: EdgeInsets.only(
          left: 10,
          top: 10,
          right: 10,
          bottom: 10,
        ),
        child: Column(
          children: [
            Container(
              height: 30,
              margin: EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'flutter sdk version',
                    style: TextStyle(
                      fontSize: 14.0,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        Colors.red,
                      ),
                    ),
                    onPressed: _logout,
                    child: Text(
                      '退出[${EMClient.getInstance.currentUsername}]',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _logout() async {
    try {
      SmartDialog.showLoading(msg: '退出中...');
      await EMClient.getInstance.logout(true);
      Navigator.of(context).pushReplacementNamed(
        '/login',
      );
    } on EMError catch (e) {
      SmartDialog.showToast('登录失败 $e');
    } finally {
      SmartDialog.dismiss();
    }
  }

  goUserInfoPage() {
    Navigator.of(context).pushNamed('/userInfoPage').then((value) {});
  }
}
