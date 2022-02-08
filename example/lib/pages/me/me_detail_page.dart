
import 'package:easeim_flutter_demo/pages/me/me_choose_header.dart';
import 'package:easeim_flutter_demo/widgets/common_widgets.dart';
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
      body: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          commonCellWidget(
            "头像", 
            onTap: (){
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (ctx) {
                  return MeChooseHeaderPage();
                }),
              ).then((value){
                this.loadUserInfo();
              });
            },
            rightChildren: [
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
            arrowShow: false,
          ),
          SizedBox(
            height: 15,
          ),
          commonCellWidget(
            "昵称", 
            onTap: _changeNickname,
          ),
        ],
      )
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