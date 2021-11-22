import 'dart:convert';
import 'dart:io';

import 'package:ease_call_kit/ease_call_kit.dart';
import 'package:easeim_flutter_demo/pages/chat/chat_input_bar.dart';
import 'package:easeim_flutter_demo/unit/chat_voice_player.dart';
import 'package:easeim_flutter_demo/widgets/common_widgets.dart';
import 'package:easeim_flutter_demo/widgets/demo_app_bar.dart';
import 'package:easeim_flutter_demo/widgets/show_large_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:provider/provider.dart';
// import 'package:record_amr/record_amr.dart';
import 'chat_face_view.dart';
import 'chat_items/chat_item.dart';
import 'chat_more_view.dart';
import 'dart:convert' as convert;

class ChatPage extends StatefulWidget {
  ChatPage(
    this.titleStr,
    EMConversation conversation,
  ) : conv = conversation;
  final EMConversation conv;
  final String titleStr;
  @override
  State<StatefulWidget> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
    implements
        ChatInputBarListener,
        EMChatManagerListener,
        EMChatRoomEventListener,
        EaseCallKitListener {
  List<ChatMoreViewItem> items;

  final _scrollController = ScrollController();

  /// 时间显示间隔为1分钟
  final int _timeInterval = 60 * 1000;

  ChatInputBar _inputBar;
  // 用来决定是否显示时间
  int _adjacentTime = 0;
  ChatInputBarType _inputBarType = ChatInputBarType.normal;
  ChatVoicePlayer _voicePlayer = ChatVoicePlayer();
  ChatMoreView _moreView;
  TextEditingController _inputBarEditingController = TextEditingController();
  int _subscribeId;
  bool _keyboardVisible = false;

  /// 消息List
  List<EMMessage> _msgList = [];

  @override
  void initState() {
    super.initState();
    EaseCallKit.listener = this;
    // 监听键盘弹起收回
    _subscribeId = KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        _keyboardVisible = visible;
        _setStateAndMoreToListViewEnd();
      },
    );

    items = [
      ChatMoreViewItem(
          'images/chat_input_more_photo.png', '相册', _moreViewPhotoBtnOnTap),
      ChatMoreViewItem(
          'images/chat_input_more_camera.png', '相机', _moreCameraBtnOnTap),
      ChatMoreViewItem(
          'images/chat_input_more_loc.png', '位置', _moreLocalBtnOnTap),
      ChatMoreViewItem(
          'images/chat_input_more_file.png', '文件', _moreFileBtnOnTap),
      ChatMoreViewItem(
          'images/chat_input_more_pin.png', '语音', _moreVoiceCallBtnOnTap),
      ChatMoreViewItem(
          'images/chat_input_more_pin.png', '视频', _moreVideoCallBtnOnTap),
    ];

    _moreView = ChatMoreView(items);
    // 添加环信回调监听
    EMClient.getInstance.chatManager.addListener(this);
    EMClient.getInstance.chatRoomManager.addChatRoomChangeListener(this);
    // 设置所有消息已读
    widget.conv?.markAllMessagesAsRead();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.minScrollExtent) {
        _loadMessages(moveBottom: false);
      }
    });
    if (widget.conv?.type == EMConversationType.ChatRoom) {
      joinChatRoom();
    } else {
      _loadMessages();
    }
  }

  void joinChatRoom() async {
    try {
      await EMClient.getInstance.chatRoomManager.joinChatRoom(widget.conv?.id);
      _loadMessages();
    } on EMError catch (e) {
      print("加入房间失败 -- " + e.toString());
    }
  }

  void dispose() {
    // 移除键盘监听
    KeyboardVisibilityNotification().removeListener(_subscribeId);
    // 移除环信回调监听
    EMClient.getInstance.chatManager.removeListener(this);
    _scrollController.dispose();
    _inputBarEditingController.dispose();
    if (widget.conv?.type == EMConversationType.ChatRoom) {
      EMClient.getInstance.chatRoomManager.leaveChatRoom(widget.conv?.id);
    }
    EaseCallKit.dispose();
    super.dispose();
  }

  @override
  Widget build(context) {
    _inputBar = ChatInputBar(
      listener: this,
      barType: _inputBarType,
      textController: _inputBarEditingController,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: DemoAppBar(
        widget.titleStr,
      ),
      body: GestureDetector(
        // 点击背景隐藏键盘
        onTap: () {
          if (_keyboardVisible) {
            _inputBarType = ChatInputBarType.normal;
            SystemChannels.textInput.invokeMethod('TextInput.hide');
            setState(() {});
          }
        },
        child: SafeArea(
          child: Column(
            children: <Widget>[
              // 消息内容
              Flexible(
                child: Container(
                  // padding: EdgeInsets.only(bottom: 20),
                  color: Color.fromRGBO(242, 242, 242, 1.0),
                  child: Builder(builder: (context) {
                    return CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, int index) {
                              return ChangeNotifierProvider<
                                  ChatVoicePlayer>.value(
                                value: _voicePlayer,
                                child: _chatItemFromMessage(
                                    _msgList[index], index),
                              );
                            },
                            childCount: _msgList.length,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
              // 间隔线
              Divider(height: 1.0),
              // 输入框
              Container(
                // 限制输入框高度
                constraints: BoxConstraints(
                  maxHeight: sHeight(90),
                  minHeight: sHeight(44),
                ),
                decoration: new BoxDecoration(
                  color: Theme.of(context).cardColor,
                ),
                child: _inputBar,
              ),
              _bottomWidget(),
            ],
          ),
        ),
      ),
    );
  }

  /// 返回消息item
  _chatItemFromMessage(EMMessage msg, int index) {
    _makeMessageAsRead(msg);
    bool needShowTime = false;
    if (_adjacentTime == 0 ||
        (msg.serverTime - _adjacentTime).abs() > _timeInterval ||
        index == 0) {
      needShowTime = true;
    }

    _adjacentTime = msg.serverTime;

    List<Widget> widgetsList = [];

    if (needShowTime) {
      widgetsList.add(
        Container(
          margin: EdgeInsets.only(top: sHeight(10)),
          child: Text(
            timeStrByMs(msg.serverTime, showTime: true),
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    widgetsList.add(
      Container(
        constraints: BoxConstraints(
          minWidth: double.infinity,
        ),
        child: ChatItem(
          msg,
          onTap: (message) => _messageBubbleOnTap(message),
          errorBtnOnTap: (message) => _resendMessage(message),
          longPress: (message) => _messageOnLongPress(message),
          avatarOnTap: (eid) => {print('$eid 头像被点击')},
        ),
        margin: EdgeInsets.only(
          top: sHeight(20),
          bottom: sHeight(20),
        ),
      ),
    );
    return Column(
      children: widgetsList,
    );
  }

  /// 发送消息已读回执
  _makeMessageAsRead(EMMessage msg) async {
    if (msg.chatType == EMMessageChatType.Chat &&
        msg.direction == EMMessageDirection.RECEIVE) {
      if (msg.hasReadAck == false) {
        try {
          await EMClient.getInstance.chatManager.sendMessageReadAck(msg);
        } on EMError {}
      }
      if (msg.hasRead == false) {
        try {
          await widget.conv.markMessageAsRead(msg.msgId);
        } on EMError {}
      }
    }
  }

  /// 输入框下部分View
  _bottomWidget() {
    if (_inputBarType == ChatInputBarType.more) {
      return _moreView;
    } else if (_inputBarType == ChatInputBarType.emoji) {
      return ChatFaceView(
        _inputBarEditingController.text.length > 0,
        onFaceTap: (expression) {
          _inputBarEditingController.text =
              _inputBarEditingController.text + '[${expression.name}]';
          setState(() {});
        },
        onDeleteTap: () {
          if (_inputBarEditingController.text.length > 0) {
            _inputBarEditingController.text = _inputBarEditingController.text
                .substring(0, _inputBarEditingController.text.length - 1);
          }
        },
        onSendTap: () => _sendTextMessage(_inputBarEditingController.text),
      );
    } else {
      return Container();
    }
  }

  /// 下拉加载更多消息
  _loadMessages({int count = 20, bool moveBottom = true}) async {
    try {
      List<EMMessage> msgs = await widget.conv.loadMessages(
          startMsgId: _msgList.length > 0 ? _msgList.first.msgId : '',
          loadCount: count);
      _msgList.insertAll(0, msgs);
    } on EMError {
    } finally {
      if (moveBottom) {
        _setStateAndMoreToListViewEnd();
      } else {
        setState(() {});
      }
    }
  }

  /// 刷新View并滑动到最底部
  _setStateAndMoreToListViewEnd() {
    setState(() {});
    Future.delayed(Duration(milliseconds: 100), () {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  /// 点击bubble
  _messageBubbleOnTap(EMMessage msg) async {
    switch (msg.body.type) {
      case EMMessageBodyType.TXT:
        break;
      case EMMessageBodyType.IMAGE:
        {
          EMImageMessageBody body = msg.body as EMImageMessageBody;
          Image img;
          if (body.fileStatus != EMDownloadStatus.SUCCESS) {
            img = Image.network(
              body.remotePath,
              fit: BoxFit.cover,
            );
          } else {
            img = Image.file(
              File(body.localPath),
              fit: BoxFit.cover,
            );
          }
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) {
                return ShowLargeImage(img);
              },
            ),
          );
        }
        break;
      case EMMessageBodyType.VOICE:
        {
          if (_voicePlayer.currentMsgId == msg.msgId) {
            _voicePlayer.stopPlay();
          } else {
            _voicePlayer.playVoice(msg);
          }
        }
        break;
      case EMMessageBodyType.VIDEO:
        break;
      case EMMessageBodyType.LOCATION:
        break;
      case EMMessageBodyType.FILE:
        break;
      case EMMessageBodyType.CMD:
        break;
      case EMMessageBodyType.CUSTOM:
        break;
    }
  }

  /// 消息长按
  _messageOnLongPress(EMMessage msg) async {
    print('长按消息 $msg');
  }

  /// 发送文字消息
  _sendTextMessage(String txt) async {
    if (txt.length == 0) return;
    EMMessage msg = EMMessage.createTxtSendMessage(
      widget.conv.id,
      txt,
    );

    _sendMessage(msg);
    _setStateAndMoreToListViewEnd();
    _inputBarEditingController.text = '';
  }

  /// 发送图片消息
  _sendImageMessage(String imagePath, [String fileName = '']) {
    Image.file(
      File(imagePath),
      fit: BoxFit.contain,
    )
        .image
        .resolve(ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      EMMessage msg = EMMessage.createImageSendMessage(
        username: widget.conv.id,
        filePath: imagePath,
        displayName: fileName,
      );
      EMImageMessageBody body = msg.body;
      body.height = info.image.height.toDouble();
      body.width = info.image.width.toDouble();
      msg.body = body;
      _sendMessage(msg);
    }));
  }

  /// 发消息方法
  _sendMessage(EMMessage msg) async {
    _chatType() {
      EMMessageChatType type = EMMessageChatType.Chat;
      switch (widget.conv.type) {
        case EMConversationType.Chat:
          type = EMMessageChatType.Chat;
          break;
        case EMConversationType.ChatRoom:
          type = EMMessageChatType.ChatRoom;
          break;
        case EMConversationType.GroupChat:
          type = EMMessageChatType.GroupChat;
          break;
        default:
      }
      return type;
    }

    msg.chatType = _chatType();
    _msgList.add(msg);
    await EMClient.getInstance.chatManager.sendMessage(msg);
    _setStateAndMoreToListViewEnd();
  }

  /// 重发消息
  void _resendMessage(EMMessage msg) async {
    _msgList.remove(msg);

    await EMClient.getInstance.chatManager.resendMessage(msg);
    _msgList.add(msg);
  }

  /// 相册按钮被点击
  _moreViewPhotoBtnOnTap() async {
    PickedFile pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _sendImageMessage(
        pickedFile.path,
      );
    }
  }

  /// 拍照按钮被点击
  _moreCameraBtnOnTap() {
    print('_moreCameraBtnOnTap');
    widget.conv.deleteAllMessages();
    _msgList.clear();
    setState(() {});
  }

  /// 位置按钮被点击
  _moreLocalBtnOnTap() {
    print('_moreLocalBtnOnTap');
  }

  /// 文件按钮被点击
  _moreFileBtnOnTap() async {
    print('_moreFileBtnOnTap');
  }

  /// 大头针按钮被点击
  _moreVoiceCallBtnOnTap() {
    if (widget.conv.type == EMConversationType.Chat) {
      EaseCallKit.startSingleCall(widget.conv.id);
    }
  }

  _moreVideoCallBtnOnTap() {
    if (widget.conv.type == EMConversationType.Chat) {
      EaseCallKit.startSingleCall(widget.conv.id,
          callType: EaseCallType.SingeVideo);
    }
  }

  @override
  void voiceBtnDragInside() {
    print('录音按钮内部');
  }

  @override
  void voiceBtnDragOutside() {
    print('录音按钮外部');
  }

  @override
  void voiceBtnTouchDown() async {
    // TODO: start record;
    // await Record.start(
    //   path: 'aFullPath/myFile.m4a', // required
    //   encoder: AudioEncoder.AAC, // by default
    //   bitRate: 128000, // by default
    //   sampleRate: 44100, // by default
    // );

    // RecordAmr.startVoiceRecord((volume) {
    //   print('volume -- $volume');
    // }).then((value) {
    //   if (value) {
    //     print('录制开始');
    //   } else {
    //     print('录制失败');
    //   }
    // });
  }

  @override
  void voiceBtnTouchUpInside() {
    // TODO: end record and send message;
    // RecordAmr.stopVoiceRecord((path, duration) {
    //   if (path != null && duration > 0) {
    //     EMMessage msg = EMMessage.createVoiceSendMessage(username: widget.conv.id, filePath: path, duration: duration);
    //     _sendMessage(msg);
    //   } else {
    //     print('录制时间太短');
    //   }
    // });
  }

  @override
  void voiceBtnTouchUpOutside() {
    // TODO: cancel record
    print('录音按钮被外部抬起');
    _setStateAndMoreToListViewEnd();
  }

  @override
  void emojiBtnOnTap() {
    if (_inputBarType == ChatInputBarType.emoji) {
      _inputBarType = ChatInputBarType.input;
    } else {
      _inputBarType = ChatInputBarType.emoji;
    }
    _setStateAndMoreToListViewEnd();
  }

  @override
  void moreBtnOnTap() {
    if (_inputBarType == ChatInputBarType.more) {
      _inputBarType = ChatInputBarType.input;
    } else {
      _inputBarType = ChatInputBarType.more;
    }
    _setStateAndMoreToListViewEnd();
  }

  @override
  void textFieldOnTap() {
    _inputBarType = ChatInputBarType.input;
    _setStateAndMoreToListViewEnd();
  }

  @override
  void recordOrTextBtnOnTap({bool isRecord = false}) {
    if (_inputBarType == ChatInputBarType.normal) {
      _inputBarType = ChatInputBarType.input;
    } else {
      _inputBarType = ChatInputBarType.normal;
    }

    _setStateAndMoreToListViewEnd();
  }

  @override
  void sendBtnOnTap(String str) => _sendTextMessage(str);

  @override
  onCmdMessagesReceived(List<EMMessage> messages) {}

  @override
  onMessagesDelivered(List<EMMessage> messages) {}

  @override
  onMessagesRead(List<EMMessage> messages) {}

  @override
  onMessagesRecalled(List<EMMessage> messages) {}

  @override
  onMessagesReceived(List<EMMessage> messages) {
    for (var msg in messages) {
      if (msg.conversationId == widget.conv.id) {
        _msgList.add(msg);
      }
    }
    _setStateAndMoreToListViewEnd();
  }

  @override
  onConversationsUpdate() {}

  @override
  onConversationRead(String from, String to) {}

  @override
  void onAdminAddedFromChatRoom(String roomId, String admin) {}

  @override
  void onAdminRemovedFromChatRoom(String roomId, String admin) {}

  @override
  void onAnnouncementChangedFromChatRoom(String roomId, String announcement) {}

  @override
  void onChatRoomDestroyed(String roomId, String roomName) {
    print('聊天室解散 -- $roomId, $roomName');
  }

  @override
  void onMemberExitedFromChatRoom(
      String roomId, String roomName, String participant) {}

  @override
  void onMemberJoinedFromChatRoom(String roomId, String participant) {}

  @override
  void onMuteListAddedFromChatRoom(
      String roomId, List<String> mutes, String expireTime) {}

  @override
  void onMuteListRemovedFromChatRoom(String roomId, List<String> mutes) {}

  @override
  void onOwnerChangedFromChatRoom(
      String roomId, String newOwner, String oldOwner) {}

  @override
  void onRemovedFromChatRoom(
      String roomId, String roomName, String participant) {}

  @override
  void onAllChatRoomMemberMuteStateChanged(String roomId, bool isAllMuted) {}

  @override
  void onWhiteListAddedFromChatRoom(String roomId, List<String> members) {}

  @override
  void onWhiteListRemovedFromChatRoom(String roomId, List<String> members) {}

  @override
  void callDidEnd(String channelName, EaseCallEndReason reason, int time,
      EaseCallType callType) {}

  @override
  void callDidJoinChannel(String channelName, int uid) {}

  @override
  void callDidOccurError(EaseCallError error) {}

  @override
  void callDidReceive(EaseCallType callType, String inviter, Map ext) {}

  @override
  void callDidRequestRTCToken(
      String appId, String channelName, String eid) async {
    String emUsername = EMClient.getInstance.currentUsername;
    await fetchRTCToken(channelName, emUsername);
  }

  @override
  void multiCallDidInviting(List<String> excludeUsers, Map ext) {}

  @override
  void remoteUserDidJoinChannel(String channelName, int uid, String eid) {}

  Future<void> fetchRTCToken(String channelName, String username) async {
    String token = EMClient.getInstance.accessToken;
    if (token == null) return null;
    var httpClient = new HttpClient();
    var uri = Uri.http("a1.easemob.com", "/token/rtcToken/v1", {
      "userAccount": username,
      "channelName": channelName,
      "appkey": EMClient.getInstance.options.appKey,
    });
    var request = await httpClient.getUrl(uri);
    request.headers.add("Authorization", "Bearer $token");
    HttpClientResponse response = await request.close();
    httpClient.close();
    if (response.statusCode == HttpStatus.ok) {
      var _content = await response.transform(Utf8Decoder()).join();
      debugPrint(_content);
      Map<String, dynamic> map = convert.jsonDecode(_content);
      if (map != null) {
        if (map["code"] == "RES_0K") {
          debugPrint("获取数据成功: $map");
          String rtcToken = map["accessToken"];
          int agoraUserId = map["agoraUserId"];
          await EaseCallKit.setRTCToken(rtcToken, channelName, agoraUserId);
        }
      }
    }
  }
}
