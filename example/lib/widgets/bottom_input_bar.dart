import 'package:flutter/material.dart';
import 'package:im_flutter_sdk_example/utils/media_util.dart';
import 'package:im_flutter_sdk_example/utils/style.dart';
import 'package:im_flutter_sdk_example/utils/theme_util.dart';
import 'package:im_flutter_sdk_example/widgets/ease_button_widget.dart';


// ignore: must_be_immutable
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
  bool _isDark;


  final controller = new TextEditingController();

  _BottomInputBarState(BottomInputBarDelegate delegate) {
    this.delegate = delegate;
    this.inputBarStatus = InputBarStatus.Normal;

    this.textField = TextField(
      onSubmitted: _submittedMessage,
      controller: controller,
      decoration: InputDecoration(
          border: InputBorder.none,
          fillColor: Color(0x1F000000),
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
    this.message = '';
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
  }

  _onTapVoiceLongPressEnd() {
    print("_onTapVoiceLongPressEnd");
  }


  void _notifyInputStatusChanged(InputBarStatus status) {
    this.inputBarStatus = status;
    if(this.delegate != null) {
      this.delegate.inputStatusChanged(status);
    }else {
      print("没有实现 BottomInputBarDelegate");
    }
  }

  ///点击相册 选择图片
  void  _selectPicture() async{
    String imgPath = await MediaUtil.instance.pickImage();
    if(imgPath == null) {
      return;
    }
    this.delegate.onTapItemPicture(imgPath);
  }

  ///点击相机拍照
  void  _takePicture() async{
    String imgPath = await MediaUtil.instance.takePhoto();
    if(imgPath == null) {
      return;
    }
    this.delegate.onTapItemCamera(imgPath);
  }

  ///点击表情item
  void  _selectEmojicon() async{
    print("_selectEmojicon_");
    this.delegate.onTapItemEmojicon();
  }

  ///点击音频item
  void  _makeVoiceCall() async{
    print("_makeVoiceCall_");
    this.delegate.onTapItemPhone();
  }

  ///点击文件item
  void  _makeFileCall() async{
    print("_makeFileCall_");
    this.delegate.onTapItemFile();
  }

  ///点击语音消息item
  void  _sendVoiceMessage() async{
    print("_sendVoiceMessage_");
    this.delegate.sendVoice('', 0);
  }


  @override
  Widget build(BuildContext context) {
    _isDark = ThemeUtils.isDark(context);
    return Container(
      color:  ThemeUtils.isDark(context)? EMColor.darkAppMain : EMColor.appMain,
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
                          color: _isDark ? EMColor.darkBorderLine : EMColor.borderLine,
                          border:  new Border.all(color: Colors.black26, width: 0.3),
                          borderRadius:  BorderRadius.circular(18)
                      ),
                    ),
                ),
                Container(
                  width: 50,
                  height: 50,
                  color: Colors.white,
                  alignment: Alignment.center,
                  child:RaisedButton(
                      shape:CircleBorder(side: BorderSide(color: Colors.white)),
                      child: Image.asset('images/send.png',),
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
                   child: SimpleImageButton(
                     normalImage: 'images/voice.png',
                     pressedImage: 'images/voice_select.png',
                     width: 40,
                     onPressed: (){
                        isShowVoiceAction = true;
                        _sendVoiceMessage();
                     },
                   ),
                ),
                Expanded(
                  child: SimpleImageButton(
                    normalImage: 'images/phone.png',
                    pressedImage: 'images/phone_select.png',
                    width: 40,
                    onPressed: (){
                      _makeVoiceCall();
                    },
                  ),
                ),
                Expanded(
                  child: SimpleImageButton(
                    normalImage: 'images/file.png',
                    pressedImage: 'images/file_select.png',
                    width: 40,
                    onPressed: (){
                      _makeFileCall();
                    },
                  ),
                ),
                Expanded(
                  child: SimpleImageButton(
                    normalImage: 'images/camera.png',
                    pressedImage: 'images/camera_select.png',
                    width: 40,
                    onPressed: (){
                      _takePicture();
                    },
                  ),
                ),
                Expanded(
                  child: SimpleImageButton(
                    normalImage: 'images/picture.png',
                    pressedImage: 'images/picture_select.png',
                    width: 40,
                    onPressed: (){
                      _selectPicture();
                    },
                  ),
                ),
                Expanded(
                  child: SimpleImageButton(
                    normalImage: 'images/emojicon.png',
                    pressedImage: 'images/emojicon_select.png',
                    width: 40,
                    onPressed: (){
                      _selectEmojicon();
                    },
                  ),
                ),
                Expanded(
                  child: SimpleImageButton(
                    normalImage: 'images/add.png',
                    pressedImage: 'images/add_select.png',
                    width: 40,
                    onPressed: (){
                      switchExt();
                    },
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
  ///点击了相机
  void onTapItemCamera(String imgPath);
  ///点击了相册
  void onTapItemPicture(String imgPath);
  ///点击了表情
  void onTapItemEmojicon();
  ///点击音频
  void onTapItemPhone();
  ///点击文件
  void onTapItemFile();

}



