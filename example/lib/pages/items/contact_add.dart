import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:im_flutter_sdk_example/utils/style.dart';
import 'package:im_flutter_sdk_example/utils/theme_util.dart';

class EMContactAddPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _EMContactAddPageState();
  }
}

class _EMContactAddPageState extends State<EMContactAddPage>  {

  TextEditingController _addController = TextEditingController();
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
        title: Text('添加好友', ),
        leading: Icon(null),
        backgroundColor: ThemeUtils.isDark(context) ? EMColor.darkAppMain : EMColor.appMain,
      ),
      key: UniqueKey(),
      body: Column(
        children: <Widget>[


          SizedBox(height: 50,),
          /// 好友id
          Container(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 33.0),
            child: TextField(
              controller: _addController,
              maxLines: 1,
              decoration: InputDecoration(
                hintText: "用户名",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(57),
                  borderSide: BorderSide.none,
                ),
                fillColor: Colors.white,
                filled: true,
              ),
            ),
          ),

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
                '添 加',
//              DemoLocalizations.of(context).login,
                style: TextStyle(color: Colors.white, fontSize: 16.0),

              ),
              color: Color.fromRGBO(0, 0, 0, 0.1),
              onPressed: () {
//                    register(context);
//                Navigator.of(context).pushNamed('login_page');

              },
            ),
          ),
        ],
      ),
    );
  }
}