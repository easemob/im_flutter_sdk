import 'dart:io';

import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'dart:typed_data';
import 'dart:convert';

class MessageItemFactory extends StatelessWidget {
  final EMMessage message;
  const MessageItemFactory({Key key, this.message}) : super(key: key);

  ///文本消息 item
  Widget textMessageItem() {
    EMTextMessageBody msg = message.body;
    return Container(
      padding: EdgeInsets.all(10),
      child: Text(msg.message,style: TextStyle(fontSize: 13),),
    );
  }

  ///图片消息 item
  ///优先读缩略图，否则读本地路径图，否则读网络图
  Widget imageMessageItem() {
    EMImageMessageBody msg = message.body;

    Widget widget;
    if (msg.thumbnailUrl != null && msg.thumbnailUrl.length > 0) {
      Uint8List bytes = base64.decode(msg.thumbnailUrl);
      widget = Image.memory(bytes);
    } else {
      if(msg.localUrl != null) {
//        String path = MediaUtil.instance.getCorrectedLocalPath(msg.localUrl);
//        File file = File(path);
//        if(file != null && file.existsSync()) {
//          widget = Image.file(file);
//        }else {
//          widget = Image.network(msg.imageUri);
//        }
      }else {
//        widget = Image.network(msg.imageUri);
      }
    }
    return widget;
  }

  ///语音消息 item
  Widget voiceMessageItem() {
    EMVoiceMessageBody msg = message.body;
    List<Widget> list = new List();
    if(message.direction == Direction.SEND) {
      list.add(SizedBox(width: 6,));
      list.add(Text("语音时长",style: TextStyle(fontSize: 13),));
      list.add(SizedBox(width: 20,));
      list.add(Container(
        width: 20,
        height: 20,
        child: Image.asset("assets/images/voice_icon.png"),
      ));
    }else {
      list.add(SizedBox(width: 6,));
      list.add(Container(
        width: 20,
        height: 20,
        child: Image.asset("assets/images/voice_icon_reverse.png"),
      ));
      list.add(SizedBox(width: 20,));
      list.add(Text("语音时长"));
    }

    return Container(
      width: 80,
      height: 44,
      child: Row(
          children:list
      ) ,
    );
  }

  Widget messageItem() {
    if (message.body is EMTextMessageBody) {
      return textMessageItem();
    } else if (message.body is EMImageMessageBody){
      return imageMessageItem();
    } else if (message.body is EMVoiceMessageBody) {
      return voiceMessageItem();
    } else {
      return Text("无法识别消息 ");
    }
  }

  Color _getMessageWidgetBGColor(int messageDirection) {
    Color color = Color(0xffC8E9FD);
    if(message.direction == Direction.RECEIVE) {
      color = Color(0xffffffff);
    }
    return color;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _getMessageWidgetBGColor(toDirect(message.direction)),
      child: messageItem(),
    );
  }
}