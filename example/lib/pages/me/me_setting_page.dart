
import 'package:easeim_flutter_demo/pages/me/me_account_and_safe_page.dart';
import 'package:easeim_flutter_demo/pages/me/me_privacy_page.dart';
import 'package:easeim_flutter_demo/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

class MeSettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("我"),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          commonCellWidget(
            "账号与安全",
            onTap: () {
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (ctx) {
                    return MeAccountAndSafePage();
                  }
                )
              );
            }
          ),
          commonCellWidget("新消息提醒"),
          Container(
            color: Color(0xFFEEEEEE),
            height: 15,
          ),
          commonCellWidget("通用"),
          commonCellWidget(
            "隐私",
            onTap: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (ctx){
                  return MePrivacyPage();
                })
              );
            }
          ),
          Container(
            color: Color(0xFFEEEEEE),
            height: 15,
          ),
          Container(
            height: 60,
            child: InkWell(
              child: Center(
                child: Text("退出"),
              ),
              onTap: () async {
                try {
                  await EMClient.getInstance.logout(true);
                  Navigator.of(context).pushReplacementNamed(
                    '/login',
                  );
                } on EMError {}
              },
            ),
          ),
          Container(
            color: Color(0xFFEEEEEE),
            height: 15,
          ),
        ],
      ),
    );
  }
}