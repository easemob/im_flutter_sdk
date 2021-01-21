import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:im_flutter_sdk_example/ease_user_info.dart';
import 'package:im_flutter_sdk_example/utils/style.dart';
import 'package:im_flutter_sdk_example/utils/theme_util.dart';
import 'package:im_flutter_sdk_example/utils/widget_util.dart';
import 'package:im_flutter_sdk_example/widgets/bottom_input_bar.dart';
import "package:scroll_to_index/scroll_to_index.dart";

import 'group_details_page.dart';
import 'items/chat_item.dart';

// ignore: must_be_immutable
class ChatPage extends StatefulWidget {
  var arguments;
  ChatPage({Key key, this.arguments}) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _ChatPageState(arguments: this.arguments);
}

class _ChatPageState extends State<ChatPage>
    implements
        EMMessageListener,
        ChatItemDelegate,
        BottomInputBarDelegate,
        EMMessageStatus,
        EMCallStateChangeListener {
  var arguments;
  int mType;
  String toChatUsername;
  EMConversation conversation;

  UserInfo user;
  int _pageSize = 10;
  bool isLoad = false;
  bool isJoinRoom = false;
  bool _isDark = false;
  bool _singleChat;
  String msgStartId = '';
  String afterLoadMessageId = '';

  List<EMMessage> messageTotalList = new List(); //消息数组
  List<EMMessage> messageList = new List(); //消息数组
  List<EMMessage> msgListFromDB = new List();
  List<Widget> extWidgetList = new List(); //加号扩展栏的 widget 列表
  bool showExtWidget = false; //是否显示加号扩展栏内容
  var loadMsgIndex = 0;

  ChatStatus currentStatus; //当前输入工具栏的状态

  _ChatPageState({this.arguments});

//  PersonNotifier _valueListenable = PersonNotifier([]);

  AutoScrollController _autoScrollController;
  InputBarStatus _inputBarStatus = InputBarStatus.Normal;

  @override
  Widget build(BuildContext context) {
    _isDark = ThemeUtils.isDark(context);
    print("------build---------");
    if (messageTotalList.length > 0 &&
        afterLoadMessageId != '' &&
        _inputBarStatus != InputBarStatus.GetFocus) {
      _scrollToIndex(loadMsgIndex);
    }

    return WillPopScope(
      onWillPop: _willPop,
      child: new Scaffold(
          appBar: AppBar(
            title: Text(this.user.userId,
                style: TextStyle(
                    color: ThemeUtils.isDark(context)
                        ? EMColor.darkText
                        : EMColor.text)),
            centerTitle: true,
            backgroundColor: ThemeUtils.isDark(context)
                ? EMColor.darkAppMain
                : EMColor.appMain,
            leading: Builder(builder: (BuildContext context) {
              return IconButton(
                  icon: new Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.pop(context, true);
                  });
            }),
            actions: <Widget>[
              // 隐藏的菜单
              new PopupMenuButton<String>(
                icon: new Icon(
                  Icons.more_vert,
                  color: Colors.black,
                ),
                itemBuilder: _singleChat == true
                    ? (BuildContext context) => <PopupMenuItem<String>>[
                          this.SelectView(Icons.delete, '删除记录', 'A'),
                        ]
                    : (BuildContext context) => <PopupMenuItem<String>>[
                          this.SelectView(Icons.delete, '删除记录', 'A'),
                          this.SelectView(Icons.people, '查看详情', 'B'),
                        ],
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
                    child: GestureDetector(
                  onTap: () => global.emit(GlobalEvent.HindInput),
                  onDoubleTap: () => global.emit(GlobalEvent.HindInput),
                  child: Column(
                    children: <Widget>[
                      Flexible(
                        child: Column(
                          children: <Widget>[
//                                ValueListenableBuilder(
//                                  valueListenable: _valueListenable,
//                                  builder: (BuildContext context, List<EMMessage> value, Widget child) {
                            Flexible(
                              child: ListView.builder(
                                key: UniqueKey(),
                                shrinkWrap: true,
                                reverse: true,
                                controller: _autoScrollController,
                                itemCount: messageTotalList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  if (messageTotalList.length != null &&
                                      messageTotalList.length > 0) {
//                                            value.forEach((element) { print(" 000>>"  + element.toString() + " --serveMsgId-->" + element.msgId);});
                                    return AutoScrollTag(
                                      key: ValueKey(index),
                                      controller: _autoScrollController,
                                      index: index,
                                      child: ChatItem(
                                          this,
                                          messageTotalList[index],
                                          _isShowTime(index)),
                                    );
//                                            return ChatItem(this,messageTotalList[index],_isShowTime(index));
                                  } else {
                                    return WidgetUtil.buildEmptyWidget();
                                  }
                                },
                              ),
                            )
//                                  },
//                                ),
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
                )),
//              _buildActionWidget(),
              ],
            ),
          )),
    );
  }

  // ignore: non_constant_identifier_names
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
        ));
  }

  @override
  void initState() {
    super.initState();
    afterLoadMessageId = '';
    currentStatus = ChatStatus.Normal;

    EMClient.getInstance().chatManager().addMessageListener(this);
    EMClient.getInstance().chatManager().addMessageStatusListener(this);
    EMClient.getInstance().callManager().addCallStateChangeListener(this);

    _autoScrollController = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical);

    messageTotalList.clear();

    mType = arguments["mType"];
    toChatUsername = arguments["toChatUsername"];

    //增加加号扩展栏的 widget
    _initExtWidgets();

    if (fromChatType(mType) == ChatType.Chat) {
      _singleChat = true;
    }

    if (fromChatType(mType) == ChatType.ChatRoom && !isJoinRoom) {
      _joinChatRoom();
    }

    this.user = UserInfoDataSource.getUserInfo(toChatUsername);
    _onConversationInit();

    _autoScrollController.addListener(() {
      //此处要用 == 而不是 >= 否则会触发多次
      if (_autoScrollController.position.pixels ==
              _autoScrollController.position.maxScrollExtent &&
          messageTotalList.length >= _pageSize) {
        _loadMessage();
      }
    });
  }

  void _onConversationInit() async {
    messageList.clear();
    messageTotalList.clear();

    conversation = await EMClient.getInstance()
        .chatManager()
        .getConversation(toChatUsername, fromEMConversationType(mType), true);

    if (conversation != null) {
      conversation.markAllMessagesAsRead();
    }
    _loadMessage();
  }

  void _loadMessage() async {
    List<EMMessage> loadList =
        await conversation.loadMoreMsgFromDB(afterLoadMessageId, _pageSize);

    if (loadList.length == 0) {
      // 拉取数据长度为0 不刷新
      print('没有更多数据了');
      return;
    } else {
      loadList.sort((a, b) => b.msgTime.compareTo(a.msgTime));

      setState(() {
        messageTotalList.addAll(loadList);
      });

      afterLoadMessageId = loadList.last.msgId;
      print('afterLoadMessageId load: ' + afterLoadMessageId);

      for (int i = 0; i < messageTotalList.length; i++) {
        print('/n' +
            '  indexs: ' +
            i.toString() +
            'msgid: ' +
            messageTotalList[i].msgId +
            ' ' +
            messageTotalList[i].toString());
        if (messageTotalList[i].msgId == afterLoadMessageId) {
          loadMsgIndex = i - 3;
        }
      }
    }
  }

  Future _scrollToIndex(int index) async {
    await _autoScrollController.scrollToIndex(index,
        duration: Duration(milliseconds: 100),
        preferPosition: AutoScrollPosition.end);
  }

  ///如果是聊天室类型 先加入聊天室
  _joinChatRoom() {
    EMClient.getInstance().chatRoomManager().joinChatRoom(toChatUsername,
        onSuccess: () {
      isJoinRoom = true;
    }, onError: (int errorCode, String errorString) {
      print('errorCode: ' +
          errorCode.toString() +
          ' errorString: ' +
          errorString);
    });
  }

  ///清除记录
  _cleanAllMessage() {
    if (null != conversation) {
      conversation.clearAllMessages();
      setState(() {
        messageTotalList = [];
      });
    }
  }

  ///查看详情
  _viewDetails() async {
    switch (fromChatType(mType)) {
      case ChatType.GroupChat:
        Navigator.push<bool>(context,
            new MaterialPageRoute(builder: (BuildContext context) {
          return EMGroupDetailsPage(this.toChatUsername);
        })).then((bool _isRefresh) {
          if (_isRefresh) {
            Navigator.pop(context, true);
          }
        });
        break;
      case ChatType.ChatRoom:
        break;
    }
  }

  /// 禁止随意调用 setState 接口刷新 UI，必须调用该接口刷新 UI
  void _refreshUI() {
    setState(() {});
  }

  Widget _getExtWidgets() {
    if (showExtWidget) {
      return Container(
          height: 110,
          color: _isDark ? EMColor.darkBorderLine : EMColor.unreadCount,
          child: GridView.count(
            physics: new NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            padding: EdgeInsets.all(10),
            children: extWidgetList,
          ));
    } else {
      return WidgetUtil.buildEmptyWidget();
    }
  }

  void _showExtraCenterWidget(ChatStatus status) {
    this.currentStatus = status;
    _refreshUI();
  }

  void checkOutRoom() {
    EMClient.getInstance().chatRoomManager().leaveChatRoom(toChatUsername,
        onSuccess: () {
      print('退出聊天室成功');
    }, onError: (int errorCode, String errorString) {
      print('errorCode: ' +
          errorCode.toString() +
          ' errorString: ' +
          errorString);
    });
  }

  void _initExtWidgets() {
    Widget videoWidget = WidgetUtil.buildExtentionWidget(
        'images/video_item.png', '视频', _isDark, () async {
      EMClient.getInstance().callManager().startCall(
            toChatUsername,
            callType: EMCallType.Video,
            isMerge: true,
            recordOnServer: true,
            ext: 'test ext',
            onSuccess: () => print('呼叫成功'),
            onError: (code, desc) => print('呼叫失败 $desc'),
          );
    });
    Widget locationWidget = WidgetUtil.buildExtentionWidget(
        'images/location.png', '位置', _isDark, () async {
      WidgetUtil.hintBoxWithDefault('发送位置消息待实现!');
    });
    extWidgetList.add(videoWidget);
    extWidgetList.add(locationWidget);
  }

  @override
  void onCmdMessageReceived(List<EMMessage> messages) {}

  @override
  void onMessageChanged(EMMessage message) {}

  @override
  void onMessageDelivered(List<EMMessage> messages) {}

  @override
  void onMessageRead(List<EMMessage> messages) {}

  @override
  void onMessageRecalled(List<EMMessage> messages) {}

  @override
  void onMessageReceived(List<EMMessage> messages) {
    for (var message in messages) {
      String username;
      // group message
      if (message.chatType == ChatType.GroupChat ||
          message.chatType == ChatType.ChatRoom) {
        username = message.to;
      } else {
        // single chat message
        username = message.from;
      }
      // if the message is for current conversation
      if (username == toChatUsername ||
          message.to == toChatUsername ||
          message.conversationId == toChatUsername) {
        insertMessage(message);
      }
    }
  }

  @override
  void dispose() {
    _autoScrollController.dispose();
    super.dispose();
    EMClient.getInstance().chatManager().removeMessageListener(this);
    if (isJoinRoom) {
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
    print("长按了Item ");
  }

  @override
  void onTapMessageItem(EMMessage message) {
    if (message.direction == Direction.RECEIVE) {
      if (message.ext() != null && message.ext()['conferenceId'] != null) {
        String conferenceId;
        String password;
        if (message.ext()['conferenceId'] != null &&
            message.ext()['conferenceId'].length > 0) {
          conferenceId = message.ext()['conferenceId'];
        } else if (message.ext()['em_conference_id'] != null) {
          conferenceId = message.ext()['em_conference_id'];
        }

        if (message.ext()['password'] != null) {
          password = message.ext()['password'];
        } else if (message.ext()['em_conference_password'] != null) {
          password = message.ext()['em_conference_password'];
        }

        EMClient.getInstance().conferenceManager().joinConference(
            conferenceId, password, onSuccess: (EMConference conf) {
          print('加入会议成功 --- ' + conf.getConferenceId());
        }, onError: (code, desc) {
          print('加入会议失败 --- $desc');
        });
      }
    }
  }

  @override
  void onTapUserPortrait(String userId) {
    print("点击了用户头像 " + userId);
  }

  @override
  void onTapExtButton() {}

  @override
  void inputStatusChanged(InputBarStatus status) {
    print('inputStatusChanged' + status.toString());
    if (status == InputBarStatus.Ext) {
      showExtWidget = true;
    } else if (status == InputBarStatus.GetFocus) {
      _inputBarStatus = InputBarStatus.GetFocus;
    } else if (status == InputBarStatus.LoseFocus) {
      _inputBarStatus = InputBarStatus.LoseFocus;
    } else {
      showExtWidget = false;
    }
    _refreshUI();
  }

  @override
  void onTapItemPicture(String imgPath) {
    print('onTapItemPicture' + imgPath);

    EMMessage imageMessage = EMMessage.createImageSendMessage(
        userName: toChatUsername, filePath: imgPath, sendOriginalImage: true);
    imageMessage.chatType = fromChatType(mType);
    EMClient.getInstance().chatManager().sendMessage(imageMessage,
        onSuccess: () {
      print('-----------success---------->');
      insertMessage(imageMessage);
    });
  }

  @override
  void onTapItemCamera(String imgPath) {
    print('onTapItemCamera' + imgPath);
    EMMessage imageMessage = EMMessage.createImageSendMessage(
        userName: toChatUsername, filePath: imgPath, sendOriginalImage: true);
    imageMessage.chatType = fromChatType(mType);
    EMClient.getInstance().chatManager().sendMessage(imageMessage,
        onSuccess: () {
      print('-----------success---------->');
      insertMessage(imageMessage);
    });
  }

  @override
  void onTapItemEmojicon() {
    WidgetUtil.hintBoxWithDefault('发送表情待实现!');
  }

  @override
  void onTapItemPhone() {
    EMClient.getInstance().callManager().startCall(
          toChatUsername,
          callType: EMCallType.Voice,
          isMerge: true,
          recordOnServer: true,
          ext: 'test ext',
          onSuccess: () => print('呼叫成功'),
          onError: (code, desc) => print('呼叫失败 $desc'),
        );
  }

  @override
  void onTapItemFile() {
    WidgetUtil.hintBoxWithDefault('选择文件待实现!');
  }

  @override
  void sendText(String text) {
    EMMessage message =
        EMMessage.createTxtSendMessage(userName: toChatUsername, content: text);
    message.chatType = fromChatType(mType);

    print('-----------LocalID---------->' + message.msgId);
    EMClient.getInstance().chatManager().sendMessage(message, onSuccess: () {
      print('-----------ServerID---------->' + message.msgId);
      print('-----------MessageStatus---------->' + message.status.toString());
      insertMessage(message);
    });
  }

  insertMessage(EMMessage message) {
    setState(() {
      messageTotalList.insert(0, message);
      afterLoadMessageId = messageTotalList.last.msgId;
    });
  }

  @override
  void sendVoice(String path, int duration) async {
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

  Future<bool> _willPop() {
    //返回值必须是Future<bool>
    Navigator.of(context).pop(false);
    return Future.value(false);
  }

  @override
  void onProgress(int progress, String status) {
    print('-----------onProgress---------->' + ': ' + progress.toString());
  }

  @override
  void onAccepted() async {
    // var callId = await EMClient.getInstance().callManager().getCallId();
    // var getExt = await EMClient.getInstance().callManager().getExt();
    // var isRecordOnServer =
    //     await EMClient.getInstance().callManager().isRecordOnServer();
    // var getConnectType =
    //     await EMClient.getInstance().callManager().getConnectType();
    // print(' onAcceptedinfo:  ' +
    //     ' callId: ' +
    //     callId.toString() +
    //     ' getExt: ' +
    //     getExt.toString() +
    //     ' isRecordOnServer: ' +
    //     isRecordOnServer.toString() +
    //     ' getConnectType: ' +
    //     getConnectType.toString());
    // print('-----------EMCallStateChangeListener---------->' + ': onAccepted');
  }

  @override
  void onConnected() {
    print('-----------EMCallStateChangeListener---------->' + ': onConnected');
  }

  @override
  void onConnecting() {
    print('-----------EMCallStateChangeListener---------->' + ': onConnecting');
  }

  @override
  void onDisconnected(CallReason reason) async {}

  @override
  void onNetVideoPause() {
    print('-----------EMCallStateChangeListener---------->' +
        ': onNetVideoPause');
  }

  @override
  void onNetVideoResume() {
    print('-----------EMCallStateChangeListener---------->' +
        ': onNetVideoResume');
  }

  @override
  void onNetVoicePause() {
    print('-----------EMCallStateChangeListener---------->' +
        ': onNetVoicePause');
  }

  @override
  void onNetVoiceResume() {
    print('-----------EMCallStateChangeListener---------->' +
        ': onNetVoiceResume');
  }

  @override
  void onNetworkDisconnected() {
    print('-----------EMCallStateChangeListener---------->' +
        ': onNetworkDisconnected');
  }

  @override
  void onNetworkNormal() {
    print('-----------EMCallStateChangeListener---------->' +
        ': onNetworkNormal');
  }

  @override
  void onNetworkUnstable() {
    print('-----------EMCallStateChangeListener---------->' +
        ': onNetworkUnstable');
  }
}

//class PersonNotifier extends ValueNotifier<List<EMMessage>>{
//  PersonNotifier(List<EMMessage> value) : super(value);
//
//  void changeMessage(List<EMMessage> newMessage){
//    if (newMessage.length > 0) {
//      value = newMessage;
//    }
//    notifyListeners();
//  }
//}

enum ChatStatus {
  Normal, //正常
  VoiceRecorder, //语音输入，页面中间回弹出录音的 gif
}
