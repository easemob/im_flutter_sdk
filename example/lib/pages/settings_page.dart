import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:flutter/services.dart';

import 'package:im_flutter_sdk_example/utils/style.dart';
import 'package:im_flutter_sdk_example/utils/localizations.dart';

class EMSettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _EMSettingsPageState();
  }
}

class _EMSettingsPageState extends State<EMSettingsPage> {

  var _mapData = [
    {'imageName':'images/通用@2x.png','name':'通用'},
    {'imageName':'images/安全与隐私@2x.png','name':'安全与隐私'},
    {'imageName':'images/消息设置@2x.png','name':'消息设置'},
    {'imageName':'images/群组设置@2x.png','name':'群组设置'},
    {'imageName':'images/黑名单@2x.png','name':'黑名单'},
    {'imageName':'images/多端多设备管理@2x.png','name':'多端多设备管理'},
    {'imageName':'images/自定义服务器@2x.png','name':'自定义服务器'},
    {'imageName':'images/清除缓存@2x.png','name':'清除缓存'}
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
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
    );

  }

 Widget _rowStyle(int index) {

    if(index == 0) {
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
                leading: ClipOval(
                  child: Image.asset('images/head.png',width: 40.0,height: 40.0),
                ),
                title: Text(
                  EMClient.getInstance().getCurrentUser(),
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
    } else if(index == 4) {
      return _isCutoffLineWithRow(index,false);

    } else if(index == 5 || index == 8 || index == 11){
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
    } else {
      return _isCutoffLineWithRow(index,true);
    }
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

  void logout (BuildContext context){

    EMClient.getInstance().logout(
      unbindToken: false,
      onSuccess: (){

      },
      onError: (code, desc) {

      },
    );

    Navigator.of(context).pushNamed('login');

  }
}