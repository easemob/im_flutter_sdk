import 'package:flutter/material.dart';

import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:im_flutter_sdk_example/utils/widget_util.dart';
import 'package:im_flutter_sdk_example/widgets/progress_dialog.dart';

import 'chat_page.dart';
import 'items/chatroom_list_item.dart';
import 'package:im_flutter_sdk_example/utils/localizations.dart';
import 'package:im_flutter_sdk_example/utils/theme_util.dart';
import 'package:im_flutter_sdk_example/utils/style.dart';
import 'package:im_flutter_sdk_example/common/common.dart';

class EMChatRoomListPage extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _EMChatRoomListPageState();
  }
}

class _EMChatRoomListPageState extends State<EMChatRoomListPage> implements EMChatRoomListItemDelegate{

  var roomList = List<EMChatRoom>();
  bool _loading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadChatRoomList();
  }

  void _loadChatRoomList(){
    EMClient.getInstance().chatRoomManager().fetchPublicChatRoomsFromServer(1, 20,
    onSuccess: (data){
      print(data);
      roomList = data.getData();
      _loading = false;
      _refreshUI();
    },
    onError: (code ,desc){
      WidgetUtil.hintBoxWithDefault(code.toString()+':'+desc);
    });
  }

  _refreshUI(){
    setState(() {

    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Widget _buildChatRoomListView(){
    return ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: roomList.length,
        itemBuilder:(BuildContext context, int index){
          if(roomList.length <= 0){
            return WidgetUtil.buildEmptyWidget();
          }
          return EMChatRoomListItem(roomList[index], this);
        });
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle : true,
        backgroundColor: ThemeUtils.isDark(context) ? EMColor.darkAppMain : EMColor.appMain,
        title: Text(DemoLocalizations.of(context).chatRoom, style: TextStyle(color: ThemeUtils.isDark(context) ? EMColor.darkText : EMColor.text)),
      ),
      key: UniqueKey(),
      body: Stack(children: <Widget>[
        _buildChatRoomListView(),
        ProgressDialog(loading: _loading, msg: DemoLocalizations.of(context).loading,),
        ],
      ),
    );
  }

  void onTapChatRoom(EMChatRoom room){
    Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context){
      return new ChatPage(arguments: {'mType': Constant.chatTypeChatRoom,'toChatUsername':room.getId()});
    }));  }
}