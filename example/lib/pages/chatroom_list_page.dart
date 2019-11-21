import 'package:flutter/material.dart';

import 'package:im_flutter_sdk/im_flutter_sdk.dart';

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
    loadChatRoomList();
  }

  void loadChatRoomList(){
    EMClient.getInstance().chatRoomManager().fetchPublicChatRoomsFromServer(pageNum : 0, pageSize: 20,
    onSuccess: (data){
      roomList = data.getData();
      _loading = false;
      _refreshUI();
    },
    onError: (code ,desc){

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
            return Container(
              height: 1,
              width: 1,
            );
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
        ProgressDialog(loading: _loading, msg: '正在加载...',),
        ],
      ),
    );
  }

  void onTapChatRoom(EMChatRoom room){
    Navigator.of(context).pushNamed(Constant.toChatPage,arguments: {'mType': Constant.chatTypeChatRoom ,'toChatUsername': room.getId()});
  }
}

/// 显示加载dialog
class ProgressDialog extends StatelessWidget {
  final bool loading;
  //进度提示内容
  final String msg;
  //加载中动画
  final Widget progress;
  //背景透明度
  final double alpha;
  //字体颜色
  final Color textColor;
  ProgressDialog({Key key,@required this.loading,this.msg,
    this.progress = const CircularProgressIndicator(),this.alpha = 0.6,
    this.textColor = Colors.white,})
      : assert(loading != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetList = [];
    //假如正在加载，则显示加载增加加载中布局
    if(loading) {
      Widget layoutProgress;
      if (msg == null) {
        layoutProgress = Center(
          child: progress,
        );
      }else {
        layoutProgress = Center(
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(4.0)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                progress,
                Container(
                  padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0),
                  child: Text(
                    msg, style: TextStyle(color: textColor, fontSize: 16.0),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      widgetList.add(Opacity(
        opacity: alpha,
        child: new ModalBarrier(dismissible: false),
      )
      );
      widgetList.add(layoutProgress);
    }
    return Stack(
      children: widgetList,
    );
  }
}