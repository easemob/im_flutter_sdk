import 'package:flutter/material.dart';

import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import 'items/conversation_list_item.dart';
import 'package:im_flutter_sdk_example/utils/style.dart';
import 'package:im_flutter_sdk_example/utils/localizations.dart';

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
    var conList = List<EMConversation>();
    var sortMap = Map<String, EMConversation>();

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
    sortMap.clear();
    Map map = await EMClient.getInstance().chatManager().getAllConversations();
    map.forEach((k, v) async{
      var conversation = v as EMConversation;
      EMMessage message = await conversation.getLastMessage();
      sortMap.putIfAbsent(message.msgTime,() => v);
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
          if(conList.length <= 0){
            return Container(
              height: 1,
              width: 1,
            );
          }
          return EMConversationListItem(conList[index], this);
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    conList.clear();
    List sortKeys = sortMap.keys.toList();
    // key排序
    sortKeys.sort((a, b) => b.compareTo(a));
    sortKeys.forEach((k){
      var v = sortMap.putIfAbsent(k, null);
      conList.add(v);
    });
    // TODO: implement build
    return new Scaffold(
      appBar: AppBar(
        centerTitle : true,
        title: Text(DemoLocalizations.of(context).conversation, style: TextStyle(color: Color(EMColor.EMConListTitleColor)), ),
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
    loadEMConversationList();
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