import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:im_flutter_sdk_example/utils/style.dart';
import 'package:im_flutter_sdk_example/utils/theme_util.dart';
import 'package:im_flutter_sdk_example/utils/widget_util.dart';
import 'package:im_flutter_sdk_example/widgets/bottom_input_bar.dart';

import 'group_details_page.dart';
import 'items/chat_item.dart';


class ChatPage extends StatefulWidget {

  ChatPage({Key key, @required this.conversation}) : super(key: key);

  final EMConversation conversation;

  @override
  State<StatefulWidget> createState() => _ChatPageState(conversation: conversation);
}

class _ChatPageState extends State<ChatPage> implements
    EMMessageListener,
    ChatItemDelegate,
    BottomInputBarDelegate,
//    EMMessageStatusListener,
    EMCallStateChangeListener
{

  _ChatPageState({@required this.conversation});

  EMConversation conversation;

  bool _isLoad = false;
  bool _isDark = false;
  bool _singleChat;
  String _msgStartId = '';
  String _afterLoadMessageId = '';

  List<EMMessage> messageTotalList = new List();//消息数组
  List<EMMessage> messageList = new List();//消息数组
  List<EMMessage>  msgListFromDB = new List();
  List<Widget> extWidgetList = new List();//加号扩展栏的 widget 列表
  bool showExtWidget = false;//是否显示加号扩展栏内容

  ChatStatus currentStatus;//当前输入工具栏的状态

  ScrollController _scrollController = ScrollController();


  @override
  void initState() {
    super.initState();

    EMClient.getInstance.chatManager.addMessageListener(this);
//    EMClient.getInstance.chatManager.addMessageStatusListener(this);
    EMClient.getInstance.callManager.addCallStateChangeListener(this);

    currentStatus = ChatStatus.Normal;

    messageTotalList.clear();

    //增加加号扩展栏的 widget
    _initExtWidgets();

    if (conversation == null) {
      return;
    }


    _singleChat = conversation.type == EMConversationType.Chat;

//    if(conversation.type == EMConversationType.ChatRoom) {
//      _joinChatRoom();
//    }

    _scrollController.addListener(() {
      //此处要用 == 而不是 >= 否则会触发多次
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _loadMessages();
      }
    });

    // 设置全部已读
    _markMessagesAsRead();

    // load消息
    _loadMessages(onEnd:(){
      _listViewToEnd();
    });
  }

  @override
  Widget build(BuildContext context) {
    _isDark = ThemeUtils.isDark(context);
    if(messageList.length > 0 ){
      if(!_isLoad){
        messageTotalList.clear();
        messageTotalList.addAll(messageList);
        print(messageTotalList.length.toString() + 'after build true: ' + messageList.length.toString());
      }else{
        print( '_scrollController: ' + _scrollController.offset.toString());
        _scrollController.animateTo(_scrollController.offset, duration: new Duration(seconds: 2), curve: Curves.ease);
      }
      print(messageTotalList.length.toString() + 'build');
    }

    return WillPopScope(
      onWillPop: _willPop,
      child: new Scaffold(
          appBar:AppBar(
            title: Text(conversation.id, style: TextStyle(color: ThemeUtils.isDark(context) ? EMColor.darkText : EMColor.text)),
            centerTitle: true,
            backgroundColor:ThemeUtils.isDark(context) ? EMColor.darkAppMain : EMColor.appMain,
            leading: Builder(builder:(BuildContext context){
              return IconButton(
                  icon: new Icon(Icons.arrow_back,color: Colors.black),
                  onPressed: (){
                    Navigator.pop(context,true);
                  }
              );
            }),
            actions: <Widget>[
              // 隐藏的菜单
              new PopupMenuButton<String>(
                icon: new Icon(Icons.more_vert,color: Colors.black,),
                itemBuilder: _singleChat == true ?
                    (BuildContext context) => <PopupMenuItem<String>>[this.SelectView(Icons.delete, '删除记录', 'A'),] :
                    (BuildContext context) => <PopupMenuItem<String>>[this.SelectView(Icons.delete, '删除记录', 'A'), this.SelectView(Icons.people, '查看详情', 'B'),] ,
                onSelected: (String action) {
                  // 点击选项的时候
                  switch (action) {
                    case 'A':
                      _cleanAllMessage();
                      break;
                    case 'B':
                      _viewDetails();
                      break;
                  }
                },
              ),
            ],
          ),
          body: Container(
            color: _isDark ? EMColor.darkBorderLine : EMColor.borderLine,
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
//              _buildActionWidget(),
              ],
            ),
          )
      ),
    );
  }

  // ignore: non_constant_identifier_names
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


  void _onConversationInit() async{
    // TODO: conversation
    /*
    messageList.clear();
    conversation = await EMClient.getInstance.chatManager.
    getConversation(toChatUsername, fromEMConversationType(mType), true );

    if(conversation != null){
      conversation.markAllMessagesAsRead();
      msgListFromDB = await conversation.loadMoreMsgFromDB('', 20);
    }

    if(msgListFromDB != null && msgListFromDB.length > 0){
      afterLoadMessageId = msgListFromDB.first.msgId;
      messageList.addAll(msgListFromDB);
    }
    isLoad = false;
    _refreshUI();

     */
  }


  void _loadMessages({onEnd()}) async {
    try{
      List<EMMessage> loadList = await conversation.loadMessagesWithStartId(_afterLoadMessageId);
      _afterLoadMessageId = loadList.first.msgId;
      loadList.sort((a, b) => b.serverTime.compareTo(a.serverTime));
      setState(() {
        messageTotalList.addAll(loadList);
      });
      if(onEnd != null){
        onEnd();
      }
    }catch(e){

    }
  }

  void _markMessagesAsRead({String messageId = ''}) async {
    // 如果消息id是''，则表示全部已读
    try{
      if(messageId.length == 0) {
        try{
          conversation.markAllMessagesAsRead();
        }catch(e){

        }
      }else{
        try{
          conversation.markMessageAsRead(messageId: messageId);
        }catch(e){

        }
      }
    } catch (e) {

    }
  }

  void _listViewToEnd() {
    _scrollController.animateTo(_scrollController.offset, duration: new Duration(seconds: 1), curve: Curves.ease);
  }

//  ///如果是聊天室类型 先加入聊天室
//  _joinChatRoom(){
//    EMClient.getInstance.chatRoomManager.joinChatRoom(
//        conversation.id ,
//        onError: (int errorCode,String errorString) {
//          //TODO: 弹出加入失败toast;
//        });
//  }

  ///清除记录
  _cleanAllMessage() async {
    try {
      conversation.deleteAllMessages();
      setState(() {
        messageList.clear();
        messageTotalList.clear();
      });
    } catch (e) {

    }
  }

  ///查看详情
  _viewDetails() async {

    if(conversation.type == EMConversationType.GroupChat) {
      Navigator.push<bool>(context, MaterialPageRoute(builder: (BuildContext context) {
            return EMGroupDetailsPage(conversation.id);
          })).then((bool _isRefresh){
            if(_isRefresh){
              Navigator.pop(context, true);
            }
      });
    }
    // TODO: 查看聊天室详情
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
          color: _isDark ? EMColor.darkBorderLine : EMColor.unreadCount,
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

  void checkOutRoom() async{
    try {
      await EMClient.getInstance.chatRoomManager.leaveChatRoom(conversation.id);
    }catch (e) {

    }
  }

  void toStringInfo() async{

  }

  void _initExtWidgets(){
    Widget videoWidget = WidgetUtil.buildExtentionWidget('images/video_item.png','视频',_isDark,() async {
//      WidgetUtil.hintBoxWithDefault('视频通话待实现!');

      EMClient.getInstance.callManager.startCall(EMCallType.Video, conversation.id, true, true, "1323",
          onSuccess:() {
          } ,
          onError:(code, desc){
            print('拨打通话失败 --- $desc');
          } );
    });
    Widget locationWidget = WidgetUtil.buildExtentionWidget('images/location.png','位置',_isDark,() async {
      WidgetUtil.hintBoxWithDefault('发送位置消息待实现!');
    });
    extWidgetList.add(videoWidget);
    extWidgetList.add(locationWidget);
  }


  @override
  void onCmdMessagesReceived(List<EMMessage> messages) {
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
  void onMessagesReceived(List<EMMessage> messages) {
    setState(() {
      messageTotalList.insertAll(0, messages);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    messageTotalList.clear();
    super.dispose();
    EMClient.getInstance.chatManager.removeMessageListener(this);
    if (conversation.type == EMConversationType.ChatRoom) {
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
    if (message.direction == EMMessageDirection.RECEIVE) {
      if (message.attributes != null) {
        String conferenceId;
        String password;
        if (message.attributes['conferenceId'] != null && message.attributes['conferenceId'].length > 0) {
          conferenceId = message.attributes['conferenceId'];
        } else if (message.attributes['em_conference_id'] != null) {
          conferenceId = message.attributes['em_conference_id'];
        }

        if (message.attributes['password'] != null) {
          password = message.attributes['password'];
        } else if(message.attributes['em_conference_password'] != null) {
          password = message.attributes['em_conference_password'];
        }

        EMClient.getInstance.conferenceManager.joinConference(conferenceId, password,
            onSuccess:(EMConference conf) {
              print('加入会议成功 --- ' + conf.getConferenceId());
            }, onError:(code, desc) {
              print('加入会议失败 --- $desc');
            });
      }
    }
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
  void onTapItemPicture(String imgPath) async{
    print('onTapItemPicture' + imgPath);
    EMMessage imageMessage = EMMessage.createImageSendMessage(username: conversation.id, filePath: imgPath, sendOriginalImage: true);

    setState(() {
      messageTotalList.insert(0, imageMessage);
    });

    sendMessage(imageMessage);
  }

  @override
  void onTapItemCamera(String imgPath) {
    print('onTapItemCamera' + imgPath);
    EMMessage imageMessage = EMMessage.createImageSendMessage(username: conversation.id, filePath: imgPath, sendOriginalImage: true);
    sendMessage(imageMessage);
  }


  @override
  void onTapItemEmojicon() {
    // TODO: implement onTapItemEmojicon
    WidgetUtil.hintBoxWithDefault('发送表情待实现!');
  }

  @override
  void onTapItemPhone() {
    // TODO: implement onTapItemPhone
    EMClient.getInstance.callManager.startCall(EMCallType.Video, conversation.id, false, false, "123",
        onSuccess:(){
          print('拨打通话成功 --- ');
        } ,
        onError:(code, desc){
          print('拨打通话失败 --- $desc');
        } );
//    WidgetUtil.hintBoxWithDefault('音频通话待实现!');
  }

  @override
  void onTapItemFile() {
    // TODO: implement onTapItemVideo
    WidgetUtil.hintBoxWithDefault('选择文件待实现!');
  }

  @override
  void sendText(String text) async {
    EMMessage message = EMMessage.createTxtSendMessage(username: conversation.id, content: text);
    setState(() {
      messageTotalList.insert(0, message);
    });
    sendMessage(message);
  }


  void sendMessage(EMMessage message) {
    try{
      EMClient.getInstance.chatManager.sendMessage(message: message);
    }catch(e){

    }finally {
      _loadMessages();
    }
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

  Future<bool> _willPop () { // 返回值必须是Future<bool>
    Navigator.of(context).pop(false);
    return Future.value(false);
  }

  @override
  void onProgress(int progress, String status) {
    // TODO: implement onProgress
    print('-----------onProgress---------->'+ ': '+ progress.toString());
  }

  @override
  void onAccepted() async{
    // TODO: implement onAccepted
    var callId = await EMClient.getInstance.callManager.getCallId();
    var getExt = await EMClient.getInstance.callManager.getExt();
    var getLocalName = await EMClient.getInstance.callManager.getLocalName();
    var getRemoteName = await EMClient.getInstance.callManager.getRemoteName();
    var isRecordOnServer = await EMClient.getInstance.callManager.isRecordOnServer();
    var getConnectType = await EMClient.getInstance.callManager.getConnectType();
    var getCallType = await EMClient.getInstance.callManager.getCallType();
    print(' onAcceptedinfo:  ' + ' callId: '
        + callId.toString()  + ' getExt: '
        + getExt.toString() + ' getLocalName: '
        + getLocalName.toString() + ' getRemoteName: '
        + getRemoteName.toString() + ' isRecordOnServer: '
        + isRecordOnServer.toString() + ' getConnectType: '
        + getConnectType.toString() + ' getCallType: '
        + getCallType.toString()
    );
    print('-----------EMCallStateChangeListener---------->'+ ': onAccepted');
  }

  @override
  void onConnected() {
    // TODO: implement onConnected
    print('-----------EMCallStateChangeListener---------->'+ ': onConnected');
  }

  @override
  void onConnecting() {
    // TODO: implement onConnecting
    print('-----------EMCallStateChangeListener---------->'+ ': onConnecting');
  }

  @override
  void onDisconnected(CallReason reason) async{
    // TODO: implement onDisconnected
    Future.delayed(Duration(milliseconds: 500), () {
      messageTotalList.clear();
      _onConversationInit();
    });
    var getServerRecordId = await EMClient.getInstance.callManager.getServerRecordId();
    print('-----------getServerRecordId----------> '+ getServerRecordId);
    print('-----------EMCallStateChangeListener---------->'+ ': onDisconnected' + reason.toString());
  }

  @override
  void onNetVideoPause() {
    // TODO: implement onNetVideoPause
    print('-----------EMCallStateChangeListener---------->'+ ': onNetVideoPause');
  }

  @override
  void onNetVideoResume() {
    // TODO: implement onNetVideoResume
    print('-----------EMCallStateChangeListener---------->'+ ': onNetVideoResume');
  }

  @override
  void onNetVoicePause() {
    // TODO: implement onNetVoicePause
    print('-----------EMCallStateChangeListener---------->'+ ': onNetVoicePause');
  }

  @override
  void onNetVoiceResume() {
    // TODO: implement onNetVoiceResume
    print('-----------EMCallStateChangeListener---------->'+ ': onNetVoiceResume');
  }

  @override
  void onNetWorkDisconnected() {
    // TODO: implement onNetWorkDisconnected
    print('-----------EMCallStateChangeListener---------->'+ ': onNetWorkDisconnected');
  }

  @override
  void onNetWorkNormal() {
    // TODO: implement onNetWorkNormal
    print('-----------EMCallStateChangeListener---------->'+ ': onNetWorkNormal');
  }

  @override
  void onNetworkUnstable() {
    // TODO: implement onNetworkUnstable
    print('-----------EMCallStateChangeListener---------->'+ ': onNetworkUnstable');
  }

}

enum ChatStatus{
  Normal,//正常
  VoiceRecorder,//语音输入，页面中间回弹出录音的 gif
}

