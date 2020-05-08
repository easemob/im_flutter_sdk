import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:im_flutter_sdk_example/plugin/im_demo_plugin.dart';
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
    // TODO: implement createState
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> implements EMMessageListener{

  var tabbarList = [
    BottomNavigationBarItem(icon: new Icon(null)),
  ];

  var vcList = [new EMConversationListPage(), new EMContactsListPage(), new FindPage(), new EMSettingsPage()];
  int curIndex = 0;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    EMClient.getInstance().groupManager().loadAllGroups();
    EMClient.getInstance().chatManager().loadAllConversations();
    EMClient.getInstance().chatManager().addMessageListener(this);
    if(Platform.isAndroid) {
      new ImDemoPlugin().loginComplete();
    }
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

  void onMessageReceived(List<EMMessage> messages){

  }
  void onCmdMessageReceived(List<EMMessage> messages){}
  void onMessageRead(List<EMMessage> messages){}
  void onMessageDelivered(List<EMMessage> messages){}
  void onMessageRecalled(List<EMMessage> messages){}
  void onMessageChanged(EMMessage message){}

}