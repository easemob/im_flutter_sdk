import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:im_flutter_sdk_example/ease_user_info.dart';
import 'package:im_flutter_sdk_example/utils/widget_util.dart';
import 'package:im_flutter_sdk_example/widgets/bottom_input_bar.dart';

import 'items/chat_item.dart';


// ignore: must_be_immutable
class ChatPage extends StatefulWidget {
  var arguments;
  ChatPage({Key key, this.arguments}) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _ChatPageState(arguments: this.arguments);
}

class _ChatPageState extends State<ChatPage> implements EMMessageListener,ChatItemDelegate,BottomInputBarDelegate{
  var arguments;
  int mType;
  String toChatUsername;
  EMConversation conversation;

  UserInfo user;
  int _pageSize = 10;
  bool isLoad = false;
  bool isJoinRoom = false;
  String msgStartId = '';
  String afterLoadMessageId = '';

  List<EMMessage> messageTotalList = new List();//消息数组
  List<EMMessage> messageList = new List();//消息数组
  List<EMMessage>  msgListFromDB = new List();
  List<Widget> extWidgetList = new List();//加号扩展栏的 widget 列表
  bool showExtWidget = false;//是否显示加号扩展栏内容

  ChatStatus currentStatus;//当前输入工具栏的状态

  ScrollController _scrollController = ScrollController();

  _ChatPageState({this.arguments});

  @override
  Widget build(BuildContext context) {

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
                  case 'A':
                    _cleanAllMessage();
                    break;
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
                                  return ChatItem(this,messageTotalList[index],_isShowTime(index));
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
                    _getExtWidgets(),
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
            // ignore: non_constant_identifier_names
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

    mType = arguments["mType"];
    toChatUsername = arguments["toChatUsername"];

    if(fromChatType(mType) == ChatType.ChatRoom && !isJoinRoom){
      _joinChatRoom();
    }

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
    getConversation(id:toChatUsername,type:fromEMConversationType(mType),createIfNotExists:true );
    conversation.markAllMessagesAsRead();

    if(null != conversation){
      conversation.markAllMessagesAsRead();
      msgListFromDB = await conversation.loadMoreMsgFromDB(startMsgId: '', pageSize: 20);
    }

    if(msgListFromDB != null && msgListFromDB.length > 0){
      afterLoadMessageId = msgListFromDB.first.msgId;
        messageList.addAll(msgListFromDB);
    }
    isLoad = false;
    _refreshUI();
  }


  void _loadMessage() async {
    var loadlist = await conversation.loadMoreMsgFromDB(startMsgId: afterLoadMessageId ,pageSize:_pageSize);
    if(loadlist.length > 0){
      afterLoadMessageId = loadlist.first.msgId;
      loadlist.sort((a, b) => b.msgTime.compareTo(a.msgTime));
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

  ///如果是聊天室类型 先加入聊天室
  _joinChatRoom(){
    EMClient.getInstance().chatRoomManager().joinChatRoom(roomId: toChatUsername ,
        onSuccess: (){
          isJoinRoom = true;
        },
        onError: (int errorCode,String errorString){
          print('errorCode: ' + errorCode.toString() + ' errorString: ' + errorString);
        });
  }

  _cleanAllMessage(){
     if(null != conversation){
        conversation.clearAllMessages();
        setState(() {
          messageList = [];
          messageTotalList = [];
        });
     }
  }

  /// 禁止随意调用 setState 接口刷新 UI，必须调用该接口刷新 UI
  void _refreshUI() {
    setState(() {
    });
  }

  Widget _getExtWidgets() {
    if(showExtWidget) {
      return Container(
          height: 110,
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

  void _showExtraCenterWidget(ChatStatus status) {
    this.currentStatus = status;
    _refreshUI();
  }

  void checkOutRoom(){
    EMClient.getInstance().chatRoomManager().leaveChatRoom(roomId: toChatUsername,
        onSuccess: (){
          print('退出聊天室成功');
        },
        onError: (int errorCode,String errorString){
          print('errorCode: ' + errorCode.toString() + ' errorString: ' + errorString);
        });
  }


  @override
  void onCmdMessageReceived(List<EMMessage> messages) {
    // TODO: implement onCmdMessageReceived
  }

  @override
  void onMessageChanged(EMMessage message) {
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
    if(isJoinRoom){
      checkOutRoom();
    }
  }

  /// 判断时间间隔在60秒内不需要显示时间
  bool _isShowTime(int index) {
//    if(index == 0){
//      return true;
//    }
//    print(messageTotalList.toString());
//    print(index);
//    String lastTime = messageTotalList[index - 1].msgTime;
//    print('before' + messageTotalList[index - 1].body.toString() + ' beforeTime:'+lastTime);
//    String afterTime = messageTotalList[index].msgTime;
//    print('after' + messageTotalList[index].body.toString() + ' afterTime:'+afterTime);
//    return WidgetUtil.isCloseEnough(lastTime,afterTime);
    return false;
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
    if(status == InputBarStatus.Ext) {
      showExtWidget = true;
    }else {
      showExtWidget = false;
    }
    _refreshUI();
  }

  @override
  void onTapItemPicture(String imgPath){
    print('onTapItemPicture' + imgPath);

    EMMessage imageMessage = EMMessage.createImageSendMessage(imgPath, true, toChatUsername);
    imageMessage.chatType = fromChatType(mType);
    EMClient.getInstance().chatManager().sendMessage(imageMessage,onSuccess:(){
       print('-----------success---------->' );
       _onConversationInit();
    });
    _onConversationInit();
  }

  @override
  void onTapItemCamera(String imgPath) {
    print('onTapItemCamera' + imgPath);
    EMMessage imageMessage = EMMessage.createImageSendMessage(imgPath, true, toChatUsername);
    imageMessage.chatType = fromChatType(mType);
    EMClient.getInstance().chatManager().sendMessage(imageMessage,onSuccess:(){
      print('-----------success---------->' );
      _onConversationInit();
    });
    _onConversationInit();
  }


  @override
  void onTapItemEmojicon() {
    // TODO: implement onTapItemEmojicon
    WidgetUtil.hintBoxWithDefault('发送表情待实现!');
  }

  @override
  void onTapItemPhone() {
    // TODO: implement onTapItemPhone
    WidgetUtil.hintBoxWithDefault('音频通话待实现!');
  }

  @override
  void onTapItemVideo() {
    // TODO: implement onTapItemVideo
    WidgetUtil.hintBoxWithDefault('视频通话待实现!');
  }

  @override
  void sendText(String text) {
    // TODO: implement willSendText   发送文本消息
    EMMessage message = EMMessage.createSendMessage(EMMessageType.TXT);
    message.to = toChatUsername;
    message.chatType = fromChatType(mType);
    EMTextMessageBody body = EMTextMessageBody(text);
    message.body = body;
    EMClient.getInstance().chatManager().sendMessage(message);
    _onConversationInit();
  }

  @override
  void sendVoice(String path, int duration) {
    WidgetUtil.hintBoxWithDefault('语音消息待实现!');
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

