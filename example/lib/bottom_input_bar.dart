import 'package:flutter/material.dart';


class BottomInputBar extends StatefulWidget {
  BottomInputBarDelegate delegate;
  BottomInputBar(BottomInputBarDelegate delegate) {
    this.delegate = delegate;
  }
  @override
  _BottomInputBarState createState() => _BottomInputBarState(this.delegate);
}

class _BottomInputBarState extends State<BottomInputBar> {
  BottomInputBarDelegate delegate;
  TextField textField;
  FocusNode focusNode = FocusNode();
  InputBarStatus inputBarStatus;

  String message;
  bool isChanged = false;
  bool isShowVoiceAction = false;

  var tabbarList = [
//    BottomNavigationBarItem(icon: new Icon(null)),
  ];


  final controller = new TextEditingController();

  _BottomInputBarState(BottomInputBarDelegate delegate) {
    this.delegate = delegate;
    this.inputBarStatus = InputBarStatus.Normal;

    this.textField = TextField(
      onSubmitted: _submittedMessage,
      controller: controller,
      decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding:EdgeInsets.fromLTRB(10,2,10,0),
//          hintText: '请输入信息......',
          hintStyle: TextStyle(
              fontSize:15,
          ),
      ),
      focusNode: focusNode,
      onChanged: (text) {//内容改变的回调
        message = text;
        isChanged = true;
      },
    );
  }

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      if(focusNode.hasFocus) {
        _notifyInputStatusChanged(InputBarStatus.Normal);
      }
    });

  }

  void _submittedMessage(String messageStr) {
    if (messageStr == null || messageStr.length <= 0) {
      print('不能为空');
      return;
    }
    if(this.delegate != null) {
      this.delegate.sendText(messageStr);
    }else {
      print("没有实现 BottomInputBarDelegate");
    }
    this.textField.controller.text = '';
  }

  switchVoice() {
    print("switchVoice");
    InputBarStatus status = InputBarStatus.Normal;
    if(this.inputBarStatus != InputBarStatus.Voice) {
      status = InputBarStatus.Voice;
    }
    _notifyInputStatusChanged(status);
  }

  switchExt() {
    print("switchExtention");
    if(focusNode.hasFocus) {
      focusNode.unfocus();
    }
    InputBarStatus status = InputBarStatus.Normal;
    if(this.inputBarStatus != InputBarStatus.Ext) {
      status = InputBarStatus.Ext;
    }
    if(this.delegate != null) {
      this.delegate.onTapExtButton();
    }else {
      print("没有实现 BottomInputBarDelegate");
    }
    _notifyInputStatusChanged(status);
  }

  sendMessages(){
    if (message.isEmpty || message.length <= 0) {
      print('不能为空');
      return;
    }
    if(this.delegate != null && isChanged) {
      print(message + '...');
      this.delegate.sendText(message);
    }else {
      print("没有实现 BottomInputBarDelegate");
    }
    this.textField.controller.text = '';
    this.message = '';
  }

  _onTapVoiceLongPress() {
    print("_onTapVoiceLongPress");
//    MediaUtil.instance.startRecordAudio();
//    if(this.delegate != null) {
//      this.delegate.willStartRecordVoice();
//    }else {
//      print("没有实现 BottomInputBarDelegate");
//    }
  }

  _onTapVoiceLongPressEnd() {
    print("_onTapVoiceLongPressEnd");
//    MediaUtil.instance.stopRecordAudio((String path,int duration) {
//      if(this.delegate != null) {
//        this.delegate.sendVoice(path,duration);
//      }else {
//        print("没有实现 BottomInputBarDelegate");
//      }
//    });
//    if(this.delegate != null) {
//      this.delegate.willStopRecordVoice();
//    }else {
//      print("没有实现 BottomInputBarDelegate");
//    }
  }

  Widget _getInputField(){

  }

  Widget _getMainInputField() {
    Widget widget ;
    if(this.inputBarStatus == InputBarStatus.Voice) {
      widget = Container(
        alignment: Alignment.center,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: Text("按住 说话",textAlign: TextAlign.center),
          onLongPress: () {
            _onTapVoiceLongPress();
          },
          onLongPressEnd: (LongPressEndDetails details) {
            _onTapVoiceLongPressEnd();
          },
        ),
      );
    }else {
      widget = Container(
        padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
      );
    }
    return Container(
      height: 45,
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
            margin: EdgeInsets.fromLTRB(0, 4, 0, 2),
            decoration: BoxDecoration(
                color: Color(0x1AFFFFFF),
                border:  new Border.all(color: Colors.black26, width: 0.3),
                borderRadius:  BorderRadius.circular(20)
            ),
          ),
          widget
        ],
      ),
    );
  }

  void _notifyInputStatusChanged(InputBarStatus status) {
    this.inputBarStatus = status;
    if(this.delegate != null) {
      this.delegate.inputStatusChanged(status);
    }else {
      print("没有实现 BottomInputBarDelegate");
    }
  }

  @override
  Widget build(BuildContext context) {
    tabbarList = [
//      BottomNavigationBarItem(),
    ];
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(15, 6,15, 2),
      child:Column(
        children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                    child: Container(
                          child: this.textField,
                          height: 34,
                          padding: EdgeInsets.fromLTRB(0,5,0,0),
                          decoration: BoxDecoration(
                          color: Color(0x1AFFFFFF),
                          border:  new Border.all(color: Colors.black26, width: 0.3),
                          borderRadius:  BorderRadius.circular(18)
                      ),
                    ),
                ),
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  child:IconButton(
                      icon: Icon(Icons.send,color: Colors.lightBlueAccent,),
                      iconSize: 24,
                      highlightColor: Colors.lightBlueAccent,
                      onPressed:() {
                        sendMessages();
                      } ,
                  ),
                ),

              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child:IconButton(
                    icon: Icon(Icons.keyboard_voice),
                    iconSize: 26,
                    onPressed:() {
                      isShowVoiceAction = true;
                    } ,
                  ),
                ),
                Expanded(
                  child:IconButton(
                      icon: Icon(Icons.phone),
                      iconSize: 26,
                      onPressed:() {
                        switchVoice();
                      } ,
                   ),
                ),
                Expanded(
                  child:IconButton(
                    icon: Icon(Icons.videocam),
                    iconSize: 26,
                    onPressed:() {
                      switchVoice();
                    } ,
                  ),
                ),
                Expanded(
                  child:IconButton(
                    icon: Icon(Icons.photo_camera),
                    iconSize: 26,
                    onPressed:() {
                      switchVoice();
                    } ,
                  ),
                ),
                Expanded(
                  child:IconButton(
                    icon: Icon(Icons.photo),
                    iconSize: 26,
                    onPressed:() {
                      switchVoice();
                    } ,
                  ),
                ),
                Expanded(
                  child:IconButton(
                    icon: Icon(Icons.tag_faces),
                    iconSize: 26,
                    onPressed:() {
                      switchVoice();
                    } ,
                  ),
                ),
                Expanded(
                  child:IconButton(
                    icon: Icon(Icons.add_circle_outline),
                    iconSize: 26,
                    onPressed:() {
                      switchVoice();
                    } ,
                  ),
                ),
               ],
            ),
//            Visibility(
//
//            )
        ],
      ),
    );
  }
}

enum InputBarStatus{
  Normal,//正常
  Voice,//语音输入
  Ext,//扩展栏
}

abstract class BottomInputBarDelegate {
  ///输入工具栏状态发生变更
  void inputStatusChanged(InputBarStatus status);
  ///发送消息
  void sendText(String text);
  ///发送语音
  void sendVoice(String path,int duration);
  ///开始录音
  void startRecordVoice();
  ///停止录音
  void stopRecordVoice();
  ///点击了加号按钮
  void onTapExtButton();
}



