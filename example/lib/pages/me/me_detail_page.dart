
import 'package:easeim_flutter_demo/pages/me/me_choose_header.dart';
import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

class MeDetailPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MeDetailPageState();
}

class MeDetailPageState extends State<MeDetailPage> {

  var textEditingController = TextEditingController();
  EMUserInfo userInfo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("个人资料"),
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
              onTap: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (ctx) {
                    return MeChooseHeaderPage();
                  }),
                ).then((value){
                  this.loadUserInfo();
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "头像",
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  this.userInfo == null || this.userInfo.avatarUrl == null ?
                  Image.asset(
                    'images/me_developerService.png',
                    width: 40,
                    height: 40,
                  ) : 
                  Image.network(
                    this.userInfo.avatarUrl,
                    width: 40,
                    height: 40,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            InkWell(
              onTap: _changeNickname,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "昵称",
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  Image.asset(
                    'images/icon_enter.png',
                    width: 24,
                    height: 24,
                  ),
                ],
              ),
            ),
          ],
        )
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

  void _changeNickname() {
    showDialog<Null>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('更改昵称'),
          content: SingleChildScrollView(
            child: TextField(
              decoration: InputDecoration(
                hintText: "请输入昵称",
              ),
              controller: this.textEditingController,
              autofocus: true,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('确定'),
              onPressed: () async {
                var inputNickname = this.textEditingController.text;
                if (inputNickname != null && inputNickname.length > 0) {
                  await EMClient.getInstance.pushManager.updatePushNickname(inputNickname);
                  await EMClient.getInstance.userInfoManager.updateOwnUserInfoWithType(EMUserInfoType.NickName, inputNickname);
                  Navigator.of(context).pop();
                }
              },
            ),
            TextButton(
              child: Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    ).then((val) {
        print(val);
    });
  }

}