import 'package:flutter/material.dart';

import 'conversation_list_page.dart';
class HomePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage>{
  var tabbarList = [
    new BottomNavigationBarItem(icon: new Icon(Icons.chat,color: Colors.grey),title: new Text("会话"),),
    new BottomNavigationBarItem(icon: new Icon(Icons.perm_contact_calendar,color: Colors.grey,),title: new Text("通讯录"),),
    new BottomNavigationBarItem(icon: new Icon(Icons.settings,color: Colors.grey,),title: new Text("设置"),),
  ];
  var vcList = [new EMConversationListPage(), new EMConversationListPage(), new EMConversationListPage()];

  int curIndex = 0;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
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
}