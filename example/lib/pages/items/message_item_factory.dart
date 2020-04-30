import 'dart:io';

import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:im_flutter_sdk_example/utils/media_util.dart';

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
      widget = Image.network(msg.thumbnailUrl,width: 90,height: 100,fit: BoxFit.fill);
    } else {
      if(msg.localUrl != null) {
        String path = MediaUtil.instance.getCorrectedLocalPath(msg.localUrl);
        print('图片path -----');
        File file = File(path);
        if(file != null && file.existsSync()) {
          widget = Image.file(file,width: 90,height: 100,fit: BoxFit.fill);
          print('显示缩略图-----');
        }else {
          widget = Image.network(msg.localUrl,width: 90,height: 100,fit: BoxFit.fill);
          print('显示缩略图123 -----');
        }
      }else {
        widget = Image.network(msg.remoteUrl,width: 90,height: 100,fit: BoxFit.fill);
      }
    }
    return widget;
  }

  ///文件消息
  Widget fileMessageItem(){
    EMNormalFileMessageBody msg = message.body;

    Widget widget;
    List<Widget> list = new List();


    return Container(
      width: 230,
      height: 80,
      child: Row(

      ),
    );
  }

  Widget messageItem() {
    if (message.body is EMTextMessageBody) {
      return textMessageItem();
    } else if (message.body is EMImageMessageBody){
      return imageMessageItem();
    }  else {
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