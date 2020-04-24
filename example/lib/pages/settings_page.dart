import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:flutter/services.dart';

import 'package:im_flutter_sdk_example/utils/style.dart';
import 'package:im_flutter_sdk_example/utils/localizations.dart';
import 'package:im_flutter_sdk_example/common/common.dart';
import 'package:im_flutter_sdk_example/utils/widget_util.dart';
import 'package:im_flutter_sdk_example/widgets/progress_dialog.dart';

class EMSettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _EMSettingsPageState();
  }
}

class _EMSettingsPageState extends State<EMSettingsPage> {

  var _mapData = [
    {'imageName':'images/general@2x.png','name':'通用'},
    {'imageName':'images/security@2x.png','name':'安全与隐私'},
    {'imageName':'images/messageSetup@2x.png','name':'消息设置'},
    {'imageName':'images/groupSetup@2x.png','name':'群组设置'},
    {'imageName':'images/blacklist@2x.png','name':'黑名单'},
    {'imageName':'images/multiterminal@2x.png','name':'多端多设备管理'},
    {'imageName':'images/customServer@2x.png','name':'自定义服务器'},
    {'imageName':'images/clearCache@2x.png','name':'清除缓存'}
  ];

  String userName = 'name';
  bool _loading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() async{
    userName = await EMClient.getInstance().getCurrentUser();
    _refreshUI(false);
  }

  _refreshUI(bool loading){
    _loading = loading;
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return
      Stack(
        children: <Widget>[
          Scaffold(
//        backgroundColor: Colors.blue,
            appBar: AppBar(
              elevation: 0, // 隐藏阴影
              backgroundColor: Colors.blue,
              leading: Icon(null),
            ),
            body: SingleChildScrollView(
              child: ListView.builder(
                shrinkWrap: true,
                physics:NeverScrollableScrollPhysics(),
                itemCount: this._mapData.length + 1 + 3,
                itemBuilder: (BuildContext context,int index){
                  return _rowStyle(index);
                },
              ),
            ),
          ),
          ProgressDialog(loading: _loading, msg: DemoLocalizations.of(context).inLogout,),
        ],
      );

  }

 Widget _rowStyle(int index) {

    if(index == 0) {
      return _header();
    } else if(index == 4) {
      return _isCutoffLineWithRow(index,false);
    } else if(index == 5 || index == 8){
      return Container(
        height: 24.0,
        color: Color.fromRGBO(240, 240, 240, 1.0),
      );
    } else if(index == 6) {
      return _isCutoffLineWithRow(index-1,true);
    } else if(index == 7) {
      return _isCutoffLineWithRow(index-1,false);
    } else if(index == 9) {
      return _isCutoffLineWithRow(index-2,true);
    } else if(index == 10) {
      return _isCutoffLineWithRow(index-2,false);
    } else if(index == 11) {
      return _logoutButton();
    } else {
      return _isCutoffLineWithRow(index,true);
    }
  }

  Widget _header() {
    return Container(
      height: 171.0,
      child: Stack(
        children: <Widget>[
          Container(
            height: 107.0,
            color: Colors.blue,
          ),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            height: 71.0,
            margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 56.0),
            child: ListTile(
              leading: Image.asset('images/logo@2x.png',width: 40.0,height: 40.0),
              title: Text(
                userName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              subtitle: Text('头像,昵称,手机号...'),
            ),
          ),
        ],
      ),
    );
  }

  Stack _isCutoffLineWithRow(int index, bool isCutoffLine) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 16.0),
          height: 65,
          child: Row(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.circular(10.0),
                  image: DecorationImage(
                    image: AssetImage(_mapData[index-1]['imageName']),
                    fit: BoxFit.cover,
                  ),
                ),
                width: 40.0,
                height: 40.0,
              ),
              Padding(padding: EdgeInsets.all(10.0)),
              Text(_mapData[index-1]['name'], style: TextStyle(fontSize: 18.0),),
            ],
          ),
        ),

        _getCutoffLine(isCutoffLine),

        Positioned(
          child: RotatedBox(
            quarterTurns: 2,
            child: Image.asset('images/back_01.png',width: 19.5, height: 35.0,),
          ),
          right: 30.0,
          top: 15.0,
        )
      ],
    );
  }

  Positioned _getCutoffLine(bool isCutoffLine) {
    if(isCutoffLine) {
      return Positioned(
        child: Container(
          height: 1.0,
          color: Color(0xffe5e5e5),
        ),
        left: 64.0, top: 64, right: 0, bottom: 0,
      );
    } else {
      return Positioned(
        child: Container(
          height: 0.01,
          color: Color(0xffe5e5e5),
        ),
      );
    }
  }

  Widget _logoutButton() {
    return Container(
      height: 60.0,
//      color: Color.fromRGBO(240, 240, 240, 1.0),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 33.0),
        width: double.infinity,
        height: 50.0,
        child: RaisedButton(
          padding: EdgeInsets.all(12.0),
          shape: StadiumBorder(),
          child: Text(
            '退出登录',
//              DemoLocalizations.of(context).logout,
            style: TextStyle(color: Colors.white, fontSize: 16.0),

          ),
//          color: Color.fromRGBO(0, 0, 0, 0.1),
          onPressed: () {
            logout(context);
          },
        ),
      ),
    );
  }

  void logout (BuildContext context){
    _refreshUI(true);
    EMClient.getInstance().logout(
      false,
      onSuccess: (){
        Navigator.of(context).pushNamed(Constant.toLoginPage);
      },
      onError: (code, desc) {
        _refreshUI(false);
        WidgetUtil.hintBoxWithDefault(desc);
      },
    );
  }
}