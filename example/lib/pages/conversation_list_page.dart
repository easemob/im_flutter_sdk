import 'package:flutter/material.dart';

import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import 'items/conversation_list_item.dart';
import 'package:im_flutter_sdk_example/utils/style.dart';

class EMConversationListPage extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _EMConversationListPageState();
  }
}

class _EMConversationListPageState extends State<EMConversationListPage>
    implements EMMessageListener,
    EMConversationListItemDelegate{
    List conList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    EMClient.getInstance().chatManager().addMessageListener(this);
    loadEMConversationList();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    EMClient.getInstance().chatManager().removeMessageListener(this);
  }

  void loadEMConversationList() async{
    Map map = await EMClient.getInstance().chatManager().getAllConversations();
    map.forEach((k, v){
      conList.add(v);
    });

    _refreshUI();
  }

  void _refreshUI() {
    setState(() {});
  }

  Widget _buildListView(){
    return ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: conList.length,
        itemBuilder: (BuildContext context,int index){
          return EMConversationListItem(conList[index], this);
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: AppBar(
        centerTitle : true,
        title: Text('会话', style: TextStyle(color: Color(EMColor.EMConListTitleColor)), ),
        leading: Icon(null),
        backgroundColor: Color(EMColor.EMConListItemBgColor),
        actions: <Widget>[
          Icon(Icons.add, color: Color(EMColor.EMConListTitleColor),),
          SizedBox(width: 8,)
        ],
      ),
      key: UniqueKey(),
      body: _buildListView(),
    );
  }

  void onMessageReceived(List<EMMessage> messages){
    print('onMessageReceived');
    _refreshUI();
  }
  void onCmdMessageReceived(List<EMMessage> messages){}
  void onMessageRead(List<EMMessage> messages){}
  void onMessageDelivered(List<EMMessage> messages){}
  void onMessageRecalled(List<EMMessage> messages){}
  void onMessageChanged(EMMessage message, Object change){}

  void onTapConversation(EMConversation conversation){
    print('onTapConversation');
  }
  void onLongPressConversation(EMConversation conversation,Offset tapPos){
    print('onLongPressConversation');
  }
}