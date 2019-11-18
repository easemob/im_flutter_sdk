import 'package:flutter/material.dart';

import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import 'conversation_list_page.dart';
import 'contacts_list_page.dart';
import 'settings_page.dart';
import 'package:im_flutter_sdk_example/utils/localizations.dart';
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
  /// 目前只有会话列表，后续替换
  var vcList = [new EMConversationListPage(), new EMContactsListPage(), new EMSettingsPage()];

  int curIndex = 0;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    tabbarList = [
      BottomNavigationBarItem(icon: new Icon(Icons.chat,color: Colors.grey),title: new Text(DemoLocalizations.of(context).conversation)),
      BottomNavigationBarItem(icon: new Icon(Icons.perm_contact_calendar,color: Colors.grey,),title: new Text(DemoLocalizations.of(context).addressBook),),
      BottomNavigationBarItem(icon: new Icon(Icons.settings,color: Colors.grey,),title: new Text(DemoLocalizations.of(context).setting),),
    ];
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
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
    );
  }

  void onMessageReceived(List<EMMessage> messages){

  }
  void onCmdMessageReceived(List<EMMessage> messages){}
  void onMessageRead(List<EMMessage> messages){}
  void onMessageDelivered(List<EMMessage> messages){}
  void onMessageRecalled(List<EMMessage> messages){}
  void onMessageChanged(EMMessage message, Object change){}

}