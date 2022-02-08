
import 'package:easeim_flutter_demo/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:url_launcher/url_launcher.dart';


class MeAboutPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("关于环信"),
      ),
      body: Container(
        margin: EdgeInsets.only(
          left: 0,
          top: 0,
          right: 0,
          bottom: 0,
        ),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 20,
              ),
              Image.asset(
                "images/login_icon.png",
                width: 120,
              ),
              SizedBox(
                height: 10,
              ),
              Text("环信IM ${EMClient.getInstance.flutterSDKVersion}"),
              SizedBox(
                height: 10,
              ),
              Container(
                color: Color(0xFFEEEEEE),
                height: 15,
              ),
              commonCellWidget(
                "产品介绍", 
                onTap: () {
                  launch("http://www.easemob.com/product/im");
                }
              ),
              commonCellWidget(
                "公司介绍",
                onTap: () {
                  launch("http://www.easemob.com/about");
                }
              ),
            ],
          ),
        ),
      ),
    );
  }
}