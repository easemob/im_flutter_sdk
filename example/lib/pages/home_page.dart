import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:im_flutter_sdk_example/pages/call_page.dart';
import 'package:im_flutter_sdk_example/utils/theme_util.dart';

import 'conversation_list_page.dart';
import 'dart:io';
import 'find_page.dart';
import 'package:im_flutter_sdk_example/utils/localizations.dart';
import 'package:im_flutter_sdk_example/utils/style.dart';
import 'contacts_list_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> implements EMCallManagerListener{

  var tabbarList = [
    BottomNavigationBarItem(icon: new Icon(null)),
  ];

  var vcList = [new EMConversationListPage(), new EMContactsListPage(), new FindPage(), new EMSettingsPage()];
  int curIndex = 0;


  @override
  void initState() {
    super.initState();
    EMClient.getInstance.callManager.addCallManagerListener(this);
  }

  void refreshUI(bool visible){

  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    tabbarList = [
      BottomNavigationBarItem(icon: new Icon(Icons.chat,),activeIcon: new Icon(Icons.chat,), title: new Text(DemoLocalizations.of(context).conversation)),
      BottomNavigationBarItem(icon: new Icon(Icons.perm_contact_calendar,),activeIcon: new Icon(Icons.perm_contact_calendar,),title: new Text(DemoLocalizations.of(context).addressBook),),
      BottomNavigationBarItem(icon: new Icon(Icons.apps,),activeIcon: new Icon(Icons.apps,),title: new Text(DemoLocalizations.of(context).find),),
      BottomNavigationBarItem(icon: new Icon(Icons.face,),activeIcon: new Icon(Icons.face,),title: new Text(DemoLocalizations.of(context).mine),),
    ];
    return WillPopScope(
      onWillPop: () async{
        SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: ThemeUtils.isDark(context)? EMColor.darkAppMain : EMColor.appMain,
          items: tabbarList,
          type: BottomNavigationBarType.fixed,
          onTap: (int index) {
            setState(() {
              curIndex = index;
            });
          },
          currentIndex: curIndex,
        ),
        body: vcList[curIndex],
      ),);

  }

  void _pushCallPage(EMCallSession session) async {
    try{
      Navigator.push(context, new MaterialPageRoute(
          builder: (BuildContext context){
            return CallPage(session: session);
          },
          fullscreenDialog: true));
    }catch(e){
    }
  }

  @override
  void onCallDidEnd(String callId, int reason, [EMError error]) {
    Navigator.pop(context);
  }

  @override
  void onCallReceived(EMCallSession session) {
    _pushCallPage(session);
  }
}