import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:im_flutter_sdk_example/utils/widget_util.dart';
import 'package:im_flutter_sdk_example/common/common.dart';

class EMContactRequestPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _EMContactRequestPageState();
  }
}

class _EMContactRequestPageState extends State<EMContactRequestPage>  {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        centerTitle : true,
        title: Text('好友请求', ),
//        leading: Icon(Icons.arrow_back, color: Colors.black, ),
        elevation: 0, // 隐藏阴影
//        backgroundColor: ThemeUtils.isDark(context) ? EMColor.darkAppMain : EMColor.appMain,
        backgroundColor: Colors.white,
      ),
//      key: UniqueKey(),
      body: Column(
        children: <Widget>[

          SizedBox(height: 50,),
          /// 好友id

          SizedBox(
            height: 10.0,
          ),

          /// 添加按钮
          Container(
            padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 33.0),
            width: double.infinity,
            height: 50.0,
            child: RaisedButton(
              padding: EdgeInsets.all(12.0),
              shape: StadiumBorder(),
              child: Text(
                '添加好友',
//              DemoLocalizations.of(context).login,
                style: TextStyle(color: Colors.white, fontSize: 16.0),

              ),
              color: Colors.blue,
              onPressed: () {

              },
            ),
          ),
        ],
      ),
    );
  }

}