import 'package:easeim_flutter_demo/pages/chat/chat_items/chat_file_bubble.dart';
import 'package:easeim_flutter_demo/pages/chat/chat_items/chat_image_bubble.dart';
import 'package:easeim_flutter_demo/pages/chat/chat_items/chat_location_bubble.dart';
import 'package:easeim_flutter_demo/pages/chat/chat_items/chat_text_bubble.dart';
import 'package:easeim_flutter_demo/pages/chat/chat_items/chat_video_bubble.dart';
import 'package:easeim_flutter_demo/pages/chat/chat_items/chat_voice_bubble.dart';
import 'package:easeim_flutter_demo/unit/chat_voice_player.dart';
import 'package:easeim_flutter_demo/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

typedef OnErrorMessageTap = Function(EMMessage msg);
typedef OnMessageLongPress = Function(EMMessage msg);
typedef OnMessageTap = Function(EMMessage msg);

class ChatItem extends StatefulWidget {
  const ChatItem(
    this.msg, {
    this.onTap,
    this.longPress,
    this.errorBtnOnTap,
    this.avatarOnTap,
  });
  final EMMessage msg;

  /// 长按消息bubble
  final OnMessageLongPress longPress;

  /// 点击消息bubble
  final OnMessageTap onTap;

  /// 重发按钮点击
  final OnErrorMessageTap errorBtnOnTap;

  /// 头像按钮点击
  final Function(String eid) avatarOnTap;

  @override
  State<StatefulWidget> createState() => ChatItemState();
}

class ChatItemState extends State<ChatItem> implements EMMessageStatusListener {
  void initState() {
    super.initState();
    widget.msg.setMessageListener(this);
  }

  @override
  Widget build(context) {
    bool isRecv = widget.msg.direction == EMMessageDirection.RECEIVE;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      textDirection: isRecv ? TextDirection.ltr : TextDirection.rtl,
      children: [
        Container(
          height: sWidth(42),
          width: sWidth(42),
          margin: EdgeInsets.only(
            left: sWidth(isRecv ? 20 : 10),
            right: sWidth(!isRecv ? 20 : 10),
          ),
          child: _avatarWidget(),
        ),
        _messageWidget(isRecv),
        _messageStateWidget(isRecv),
      ],
    );
  }

  /// 头像 widget
  _avatarWidget() {
    return FlatButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        if (widget.avatarOnTap != null) {
          widget.avatarOnTap(widget.msg.from);
        }
      },
      child: Image.asset(
        'images/contact_default_avatar.png',
      ),
    );
  }

  /// 消息 widget
  _messageWidget(bool isRecv) {
    EMMessageBody body = widget.msg.body;
    return Builder(
      builder: (context) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (widget.onTap != null) {
              widget.onTap(widget.msg);
            }
          },
          onLongPress: () {
            if (widget.longPress != null) {
              widget.longPress(widget.msg);
            }
          },
          child: Container(
            constraints: BoxConstraints(
              maxWidth: sWidth(220),
            ),
            margin: EdgeInsets.only(
              top: sHeight(5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(!isRecv ? 10 : 0),
                topRight: Radius.circular(isRecv ? 10 : 0),
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
              child: ChatMessageBubble(
                widget.msg.msgId,
                body,
                widget.msg.direction,
              ),
            ),
          ),
        );
      },
    );
  }

  /// 消息状态，
  /// 单聊发送方：消息状态和对方是否已读；
  ///
  /// 群聊发送方：消息状态；
  _messageStateWidget(bool isRecv) {
    // 发出的消息
    if (!isRecv) {
      // 对方已读
      if (widget.msg.hasReadAck) {
        return Container(
          margin: EdgeInsets.only(
            left: sWidth(5),
            right: sWidth(5),
            bottom: sWidth(10),
            top: sWidth(10),
          ),
          child: Center(
            child: Text(
              '已读',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
        );
      } else {
        return Padding(
          padding: EdgeInsets.all(sWidth(10)),
          child: SizedBox(
            width: sWidth(15),
            height: sWidth(15),
            child: Builder(
              builder: (_) {
                if (widget.msg.status == EMMessageStatus.PROGRESS) {
                  return CircularProgressIndicator(
                    strokeWidth: 1,
                  );
                } else if (widget.msg.status == EMMessageStatus.FAIL) {
                  return IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.error,
                      color: Colors.red,
                      size: sWidth(30),
                    ),
                    onPressed: () {
                      if (widget.errorBtnOnTap != null) {
                        widget.errorBtnOnTap(widget.msg);
                      }
                    },
                  );
                }
                return Container();
              },
            ),
          ),
        );
      }
    }
    return Container();
  }

  @override
  void onDeliveryAck() {}

  @override
  void onError(EMError error) {
    setState(() {});
    print('发送失败');
  }

  @override
  void onProgress(int progress) {
    print('progress --- $progress');
  }

  @override
  void onReadAck() {
    setState(() {});
    print('收到已读回调');
  }

  @override
  void onStatusChanged() {}

  @override
  void onSuccess() {
    setState(() {});
    print('发送成功');
  }
}

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble(
    this.msgId,
    this.body, [
    this.direction = EMMessageDirection.SEND,
  ]);
  final EMMessageBody body;
  final EMMessageDirection direction;
  final String msgId;
  @override
  Widget build(context) {
    Widget bubble;
    switch (body.type) {
      case EMMessageBodyType.TXT:
        bubble = ChatTextBubble(body);
        break;
      case EMMessageBodyType.LOCATION:
        bubble = ChatLocationBubble(body);
        break;
      case EMMessageBodyType.IMAGE:
        bubble = ChatImageBubble(body, direction);
        break;
      case EMMessageBodyType.VOICE:
        bubble = Builder(builder: (context) {
          return Selector(
            selector: (_, ChatVoicePlayer player) =>
                Tuple2<String, bool>(player.currentMsgId, player.isPlaying),
            builder: (_, data, __) => ChatVoiceBubble(
                body, direction, (data.item1 == this.msgId) && data.item2),
          );
        });
        break;
      case EMMessageBodyType.VIDEO:
        bubble = ChatVideoBubble(body);
        break;
      case EMMessageBodyType.FILE:
        bubble = ChatFileBubble(body);
        break;
      case EMMessageBodyType.CMD:
      case EMMessageBodyType.CUSTOM:
        bubble = Container();
    }
    return Container(
      color: direction == EMMessageDirection.RECEIVE
          ? Colors.white
          : Color.fromRGBO(193, 227, 252, 1),
      child: bubble,
    );
  }
}
