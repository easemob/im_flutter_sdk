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
  final OnMessageLongPress? longPress;

  /// 点击消息bubble
  final OnMessageTap? onTap;

  /// 重发按钮点击
  final OnErrorMessageTap? errorBtnOnTap;

  /// 头像按钮点击
  final Function(String eid)? avatarOnTap;

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
    return Builder(
      builder: (_) {
        _info() {
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

        Widget ret;
        if (isRecv && widget.msg.chatType != EMMessageChatType.Chat) {
          ret = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(
                  left: sWidth(25),
                ),
                child: Text(
                  widget.msg.from!,
                  style: TextStyle(
                    fontSize: sFontSize(11),
                    color: Colors.grey,
                  ),
                ),
              ),
              SizedBox(
                height: sHeight(3),
              ),
              _info(),
            ],
          );
        } else {
          ret = _info();
        }
        return ret;
      },
    );
  }

  void dispose() {
    widget.msg.dispose();
    super.dispose();
  }

  /// 头像 widget
  _avatarWidget() {
    return TextButton(
      style: ButtonStyle(
        padding: MaterialStateProperty.all(
          EdgeInsets.zero,
        ),
      ),
      onPressed: () {
        widget.avatarOnTap?.call(widget.msg.from!);
      },
      child: Image.asset(
        'images/contact_default_avatar.png',
      ),
    );
  }

  /// 消息 widget
  _messageWidget(bool isRecv) {
    return Builder(
      builder: (context) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            widget.onTap?.call(widget.msg);
          },
          onLongPress: () {
            if (widget.longPress != null) {
              widget.longPress?.call(widget.msg);
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
              child: _messageBubble(),
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
        return Builder(
          builder: (_) {
            if (widget.msg.status == EMMessageStatus.PROGRESS) {
              return Padding(
                padding: EdgeInsets.all(sWidth(10)),
                child: SizedBox(
                  width: sWidth(20),
                  height: sWidth(20),
                  child: CircularProgressIndicator(
                    strokeWidth: 1,
                  ),
                ),
              );
            } else if (widget.msg.status == EMMessageStatus.FAIL ||
                widget.msg.status == EMMessageStatus.CREATE) {
              return IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.error,
                  color: Colors.red,
                  size: sWidth(30),
                ),
                onPressed: () {
                  if (widget.errorBtnOnTap != null) {
                    widget.errorBtnOnTap?.call(widget.msg);
                  }
                },
              );
            }
            return Container();
          },
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

  _messageBubble() {
    EMMessageBody body = widget.msg.body!;
    bool isSend = widget.msg.direction != EMMessageDirection.RECEIVE;
    return Builder(builder: (_) {
      Widget bubble;
      switch (widget.msg.body!.type!) {
        case EMMessageBodyType.TXT:
          bubble = ChatTextBubble(body as EMTextMessageBody);
          break;
        case EMMessageBodyType.LOCATION:
          bubble = ChatLocationBubble(body as EMLocationMessageBody);
          break;
        case EMMessageBodyType.IMAGE:
          bubble = ChatImageBubble(body as EMImageMessageBody, isSend);
          break;
        case EMMessageBodyType.VOICE:
          bubble = Builder(builder: (context) {
            return Selector(
              selector: (_, ChatVoicePlayer player) {
                Tuple2<String, bool>(player.currentMsgId!, player.isPlaying);
              },
              builder: (_, data, __) => ChatVoiceBubble(
                body as EMVoiceMessageBody,
                isSend,
                true, //(data!.item1 == widget.msg.msgId) && data.item2,
              ),
            );
          });
          break;
        case EMMessageBodyType.VIDEO:
          bubble = ChatVideoBubble(body as EMVideoMessageBody);
          break;
        case EMMessageBodyType.FILE:
          bubble = ChatFileBubble(body as EMFileMessageBody);
          break;
        case EMMessageBodyType.CMD:
        case EMMessageBodyType.CUSTOM:
          bubble = Container();
      }
      return Container(
        color: isSend ? Color.fromRGBO(193, 227, 252, 1) : Colors.white,
        child: bubble,
      );
    });
  }
}
