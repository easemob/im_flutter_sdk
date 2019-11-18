
import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:im_flutter_sdk_example/ease_user_info.dart';
import 'package:im_flutter_sdk_example/utils/widget_util.dart';

import '../bottom_input_bar.dart';
import 'items/chat_item.dart';


class ChatPage extends StatefulWidget {

  var arguments;
  ChatPage({Key key, this.arguments}) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _ChatPageState(arguments: this.arguments);
}

class _ChatPageState extends State<ChatPage> implements EMMessageListener,ChatItemDelegate,BottomInputBarDelegate{
  var arguments;
  EMConversationType conversationType;
  String toChatUsername;
  EMConversation conversation;

  UserInfo user;
  int _pageSize = 10;
  int msgCount = 0;
  int allMsgCount = 0;
  bool isLoad = false;
  String msgStartId = '';

  List<EMMessage> messageTotalList = new List();//消息数组
  List<EMMessage> messageList = new List();//消息数组
  List<Widget> extWidgetList = new List();//加号扩展栏的 widget 列表
  bool showExtWidget = false;//是否显示加号扩展栏内容

  ChatStatus currentStatus;//当前输入工具栏的状态

  ScrollController _scrollController = ScrollController();

  _ChatPageState({this.arguments});

  @override
  Widget build(BuildContext context) {
//    arguments = ModalRoute.of(context).settings.arguments;
//    print(arguments.toString() + '.....');
//    ///聊天类型 和 ID
//    conversationType = arguments["conversationType"];
//    toChatUsername = arguments["toChatUsername"];
    print(isLoad);
    if(messageList.length > 0 ){
      messageList.sort((a, b) => b.msgTime.compareTo(a.msgTime));
      if(!isLoad){
        messageTotalList.clear();
        messageTotalList.addAll(messageList);
        print(messageTotalList.length.toString() + 'after build true: ' + messageList.length.toString());
      }else{
        print( '_scrollController: ' + _scrollController.offset.toString());
        _scrollController.animateTo(_scrollController.offset, duration: new Duration(seconds: 2), curve: Curves.ease);
      }
      print(messageTotalList.length.toString() + 'build');
    }

    return Scaffold(
        appBar:AppBar(
          title: Text(this.user.userId, style: TextStyle(color: Colors.black)),
          centerTitle: true,
          backgroundColor: Colors.white,
          leading: Builder(builder:(BuildContext context){
            return IconButton(
              icon: new Icon(Icons.arrow_back,color: Colors.black),
                onPressed: (){
                  Navigator.pop(context);
                }
            );
          }),
          actions: <Widget>[
            // 隐藏的菜单
            new PopupMenuButton<String>(
              icon: new Icon(Icons.more_vert,color: Colors.black,),
              itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
                this.SelectView(Icons.delete, '删除记录', 'A'),
              ],
              onSelected: (String action) {
                // 点击选项的时候
                switch (action) {
                  case 'A': break;
                }
              },
            ),
          ],
        ),
        body: Container(
          child: Stack(
            children: <Widget>[
              SafeArea(
                child: Column(
                  children: <Widget>[
                    Flexible(
                      child: Column(
                        children: <Widget>[
                          Flexible(
                            child: ListView.builder(
                              key: UniqueKey(),
                              shrinkWrap: true,
                              reverse: true,
                              controller: _scrollController,
                              itemCount: messageTotalList.length,
                              itemBuilder: (BuildContext context, int index) {
                                if (messageTotalList.length != null && messageTotalList.length > 0) {
                                  return ChatItem(this,messageTotalList[index],_needShowTime(index));
                                } else {
                                  return WidgetUtil.buildEmptyWidget();
                                }
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      height: 110,
                      child: BottomInputBar(this),
                    ),
//                    _getExtentionWidget(),
                  ],
                ),
              ),
//              _buildExtraCenterWidget(),
            ],
          ),
        )
    );
  }

  SelectView(IconData icon, String text, String id) {
    return new PopupMenuItem<String>(
        value: id,
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Icon(icon, color: Colors.blue),
            new Text(text),
          ],
        )
    );
  }

  @override
  void initState() {
    super.initState();

    currentStatus = ChatStatus.Normal;

    EMClient.getInstance().chatManager().addMessageListener(this);
    EMClient.getInstance().chatManager().loadAllConversations();

    messageTotalList.clear();

    ///聊天类型 和 ID
    conversationType = arguments["conversationType"];
    toChatUsername = arguments["toChatUsername"];

    this.user = UserInfoDataSource.getUserInfo(toChatUsername);
    _onConversationInit();

    _scrollController.addListener(() {
      //此处要用 == 而不是 >= 否则会触发多次
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _loadMessage();
      }
    });

  }

  void _onConversationInit() async{
    messageList.clear();
    conversation = await EMClient.getInstance().chatManager().
    getConversation(id:toChatUsername,type:conversationType,createIfNotExists:true );
    conversation.markAllMessagesAsRead();
//    var cacheList =  await conversation.getAllMessages();
//    print(cacheList.length.toString() + '...oldList....');
//    allMsgCount = await conversation.getAllMsgCount();
//    print(allMsgCount.toString() + '...getAllMsgCount....');
//    msgCount = cacheList != null ? cacheList.length : 0;
//    print('conversationCount: '+ allMsgCount.toString() + '   msgCount: ' + msgCount.toString());
//    if (msgCount < allMsgCount && msgCount < _pageSize) {
//      var msgid = '';
//      if (cacheList != null && cacheList.length > 0) {
//        msgid = cacheList[0].msgId;
//      }
//      var loadList = await conversation.loadMoreMsgFromDB(startMsgId: msgid,pageSize:_pageSize - msgCount);
//      messageList.clear();
//      if(loadList.length > 0){
//        messageList  =  await conversation.getAllMessages();
//      }
//      print(messageList.length.toString() + '....messageList...');
//    }else{
//      messageList.clear();
//      messageList.addAll(cacheList);
//    }

    var msgListFromDB = await conversation.loadMoreMsgFromDB(startMsgId: msgStartId, pageSize: 20);
    msgStartId = msgListFromDB.first.msgId;
    messageList.addAll(msgListFromDB);
    isLoad = false;
    _refreshUI();
  }


  void _loadMessage() async {
    //todo 加载历史消息
    print('加载历史消息');
//    var msgid = '';
//    if(messageTotalList != null && messageTotalList.length > 0){
//      msgid = messageTotalList[messageTotalList.length - 1].msgId;
//    }
    var loadlist = await conversation.loadMoreMsgFromDB(startMsgId: msgStartId,pageSize:_pageSize);
    if(loadlist.length > 0){
//      messageList.clear();
//      messageTotalList.clear();
//      messageList  =  await conversation.getAllMessages();
//      print(messageList.length.toString() + 'load list');
//      messageList.sort((a, b) => b.msgTime.compareTo(a.msgTime));
      await Future.delayed(Duration(seconds: 1), () {
        setState(() {
          messageTotalList.addAll(loadlist);
        });
      });

      isLoad = true;
    }else{
      isLoad = true;
      print('没有更多数据了');
    }
    print(messageTotalList.length.toString() + '_loadMessage');
    _scrollController.animateTo(_scrollController.offset, duration: new Duration(seconds: 2), curve: Curves.ease);
  }

  /// 禁止随意调用 setState 接口刷新 UI，必须调用该接口刷新 UI
  void _refreshUI() {
    setState(() {
    });
  }

  Widget _getExtWidgets() {
    if(showExtWidget) {
      return Container(
          height: 180,
          child: GridView.count(
            physics: new NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            padding: EdgeInsets.all(10),
            children: extWidgetList,
          )
      );
    }else {
      return WidgetUtil.buildEmptyWidget();
    }
  }

  ///长按录制语音的 gif 动画
  Widget _buildExtraCenterWidget() {
    if(this.currentStatus == ChatStatus.VoiceRecorder) {
      return WidgetUtil.buildVoiceRecorderWidget();
    }else {
      return WidgetUtil.buildEmptyWidget();
    }
  }

  void _showExtraCenterWidget(ChatStatus status) {
    this.currentStatus = status;
    _refreshUI();
  }


  @override
  void onCmdMessageReceived(List<EMMessage> messages) {
    // TODO: implement onCmdMessageReceived
  }

  @override
  void onMessageChanged(EMMessage message, Object change) {
    // TODO: implement onMessageChanged
  }

  @override
  void onMessageDelivered(List<EMMessage> messages) {
    // TODO: implement onMessageDelivered
  }

  @override
  void onMessageRead(List<EMMessage> messages) {
    // TODO: implement onMessageRead
  }

  @override
  void onMessageRecalled(List<EMMessage> messages) {
    // TODO: implement onMessageRecalled
  }

  @override
  void onMessageReceived(List<EMMessage> messages) {
    // TODO: implement onMessageReceived
    for (var message in messages) {
      String username ;
      // group message
      if (message.chatType == ChatType.GroupChat || message.chatType == ChatType.ChatRoom) {
        username = message.to;
      } else {
        // single chat message
        username = message.from;
      }
      // if the message is for current conversation
      if(username == toChatUsername || message.to == toChatUsername || message.conversationId == toChatUsername) {
        conversation.markMessageAsRead(messageId:message.msgId);
      }
    }

    _onConversationInit();

  }

  @override
  void dispose() {
    super.dispose();
    EMClient.getInstance().chatManager().removeMessageListener(this);
    _scrollController.dispose();
    messageTotalList.clear();
  }

  bool _needShowTime(int index) {
    return true;
  }

  @override
  void onLongPressMessageItem(EMMessage message, Offset tapPos) {
    // TODO: implement didLongPressMessageItem
    print("长按了Item ");
  }

  @override
  void onTapMessageItem(EMMessage message) {
    // TODO: implement didTapMessageItem
    print("点击了Item ");
  }

  @override
  void onTapUserPortrait(String userId) {
    print("点击了用户头像 "+userId);
  }

  @override
  void onTapExtButton() {
    // TODO: implement didTapExtentionButton  点击了加号按钮
  }

  @override
  void inputStatusChanged(InputBarStatus status) {
    // TODO: implement inputStatusDidChange  输入工具栏状态发生变更
  }

  @override
  void sendText(String text) {
    // TODO: implement willSendText   发送文本消息
    EMMessage message = EMMessage.createSendMessage(EMMessageType.TXT);
    message.to = toChatUsername;
    message.chatType = getChatType(conversationType);
    EMTextMessageBody body = EMTextMessageBody(text);
    message.body = body;
    EMClient.getInstance().chatManager().sendMessage(message);
    _onConversationInit();
  }

  ChatType getChatType(EMConversationType conversationType){
    switch(conversationType){
      case EMConversationType.Chat:
        return ChatType.Chat;
      case EMConversationType.GroupChat:
        return ChatType.GroupChat;
      case EMConversationType.ChatRoom:
        return ChatType.ChatRoom;
      default:
        return ChatType.Chat;
    }
  }

  @override
  void sendVoice(String path, int duration) {

  }

  @override
  void startRecordVoice() {
    _showExtraCenterWidget(ChatStatus.VoiceRecorder);
  }

  @override
  void stopRecordVoice() {
    _showExtraCenterWidget(ChatStatus.Normal);
  }

}

enum ChatStatus{
  Normal,//正常
  VoiceRecorder,//语音输入，页面中间回弹出录音的 gif
}

