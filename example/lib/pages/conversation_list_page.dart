import 'package:flutter/material.dart';

import 'items/conversation_list_item.dart';

class EMConversationListPage extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _EMConversationListPageState();
  }
}

class _EMConversationListPageState extends State<EMConversationListPage>{
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Widget _buildListView(){
    return ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: 20,
        itemBuilder: (BuildContext context,int index){
          return EMConversationListItem();
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: AppBar(
        title: Text('会话'),
      ),
      key: UniqueKey(),
      body: _buildListView(),
    );
  }
}