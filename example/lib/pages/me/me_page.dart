import 'package:easeim_flutter_demo/pages/me/me_about_page.dart';
import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:easeim_flutter_demo/pages/me/me_setting_page.dart';

class MePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MePageState();
}

class MePageState extends State<MePage> {
  
  EMUserInfo userInfo;

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
            InkWell(
              onTap: _didClickUserInfo,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  this.userInfo == null || this.userInfo.avatarUrl == null ?
                  Image.asset(
                    'images/contact_default_avatar.png',
                    width: 50,
                    height: 50,
                  ) : 
                  Image.network(
                    this.userInfo.avatarUrl,
                    width: 50,
                    height: 50,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: this._showNameWidgets(),
                  )
                ],
              ),
            ),
            Container(
              height: 20,
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (ctx) {
                    return MeSettingPage();
                  }),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    'images/me_settings.png',
                    width: 24,
                    height: 24,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "设置",
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            Container(
              height: 5,
            ),
            InkWell(
              onTap: (){
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (ctx) {
                    return MeAboutPage();
                  }),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    'images/me_aboutHX.png',
                    width: 24,
                    height: 24,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "关于环信",
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            Container(
              height: 5,
            ),
            Container(
              height: 24,
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
                  Text(
                    EMClient.getInstance.flutterSDKVersion,
                    style: TextStyle(
                      fontSize: 14.0,
                    ),
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
                    onPressed: _loggout,
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

  @override
  void initState() {
    super.initState();
    this.loadUserInfo();
  }

  void loadUserInfo() async {
    var userInfo = await EMClient.getInstance.userInfoManager.fetchOwnInfo();
    if (userInfo != null) {
      this.userInfo = userInfo;
      this.setState(() {
        
      });
    }
  }

  List<Widget> _showNameWidgets() {
    List<Widget> list = [];
    if (this.userInfo != null && this.userInfo.nickName != null && this.userInfo.nickName == this.userInfo.userId) {
      list.add(Text(
        "${this.userInfo.userId}",
        style: TextStyle(
          fontSize: 14.0,
          color: Colors.black,
        ),
        textAlign: TextAlign.left,
      ));
    } else {
      list.add(Text(
        "${this.userInfo.nickName}",
        style: TextStyle(
          fontSize: 14.0,
          color: Colors.black,
        ),
        textAlign: TextAlign.left,
      ));
      list.add(Text(
        "${EMClient.getInstance.currentUsername}",
        style: TextStyle(
          fontSize: 14.0,
          color: Colors.grey,
        ),
        textAlign: TextAlign.left,
      ));
    }
    return list;
  }

  _loggout() async {
    try {
      await EMClient.getInstance.logout(true);
      Navigator.of(context).pushReplacementNamed(
        '/login',
      );
    } on EMError {}
  }

  _didClickUserInfo() {
    Navigator.of(context).pushNamed('/meDetailPage').then((value) {
      this.loadUserInfo();
    });
  }
}
