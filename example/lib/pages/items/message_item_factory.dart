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
      padding: EdgeInsets.all(2),
      child: Text(msg.content,style: TextStyle(fontSize: 13),),
    );
  }

  ///图片消息 item
  ///优先读缩略图，否则读本地路径图，否则读网络图
  Widget imageMessageItem() {
    EMImageMessageBody msg = message.body;

    Widget widget;
    if (msg.thumbnailLocalPath != null && msg.thumbnailRemotePath.length > 0) {
      widget = Image.network(msg.thumbnailRemotePath,width: 90,height: 100,fit: BoxFit.fill);
    } else {
      if(msg.localPath != null) {
        String path = MediaUtil.instance.getCorrectedLocalPath(msg.localPath);
        File file = File(path);
        if(file != null && file.existsSync()) {
          widget = Image.file(file,width: 90,height: 100,fit: BoxFit.fill);
        }else {
          widget = Image.network(msg.localPath,width: 90,height: 100,fit: BoxFit.fill);
        }
      }else {
        widget = Image.network(msg.remotePath,width: 90,height: 100,fit: BoxFit.fill);
      }
    }
    return widget;
  }

  ///文件消息
  Widget fileMessageItem(){

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
    } else if (message.body is EMCustomMessageBody){
      return Text("自定义消息 " ,style: TextStyle(fontSize: 13));
    } else {
      return Text("无法识别消息 ",style: TextStyle(fontSize: 13));
    }
  }

  Color _getMessageWidgetBGColor(int messageDirection) {
    Color color = Color(0xffC8E9FD);
    if(message.direction == EMMessageDirection.RECEIVE) {
      color = Color(0xffffffff);
    }
    return color;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      color: _getMessageWidgetBGColor(message.direction == EMMessageDirection.SEND ? 0 : 1),
      child: messageItem(),
    );
  }
}