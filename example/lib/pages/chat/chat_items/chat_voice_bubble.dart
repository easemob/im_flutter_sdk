import 'package:easeim_flutter_demo/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'dart:math' as math;

class ChatVoiceBubble extends StatefulWidget {
  ChatVoiceBubble(
    this.body, [
    this.direction = EMMessageDirection.SEND,
    this.isPlaying = false,
  ]);
  final EMVoiceMessageBody body;
  final EMMessageDirection direction;
  final bool isPlaying;

  @override
  State<StatefulWidget> createState() => ChatVoiceBubbleState();
}

class ChatVoiceBubbleState extends State<ChatVoiceBubble>
    with SingleTickerProviderStateMixin {
  /// 最大长度
  final double maxSize = sWidth(220);

  /// 最小长度, 设置最小长度时要注意波纹图片的长度可能大于最小长度，所以不能设置的太小。
  final double minSize = sWidth(65);

  Animation<double> animation;
  AnimationController controller;

  initState() {
    super.initState();
    controller = new AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    //图片宽高从0变到300
    animation = new Tween(begin: 0.0, end: 3.0).animate(controller);
  }

  @override
  Widget build(BuildContext context) {
    //启动动画
    if (widget.isPlaying) {
      controller.repeat();
    } else {
      controller.stop();
      controller.reverse(from: 0);
    }
    double width = minSize * widget.body.duration / 15;
    if (width < minSize) width = minSize;
    if (width > maxSize) width = maxSize;
    return Container(
      padding: EdgeInsets.only(
        left: sWidth(10),
        right: sWidth(10),
      ),
      constraints: BoxConstraints(
        maxHeight: 40,
        maxWidth: width,
      ),
      child: Row(
        textDirection: widget.direction == EMMessageDirection.SEND
            ? TextDirection.ltr
            : TextDirection.rtl,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${widget.body.duration}s',
          ),
          Container(
            margin: EdgeInsets.only(
              top: sWidth(10),
              bottom: sWidth(10),
            ),
            child: Transform.rotate(
              angle: widget.direction != EMMessageDirection.SEND ? 0 : math.pi,
              child: SizedBox(
                width: sWidth(20),
                height: sWidth(15),
                child: AnimatedImage(
                  animation: animation,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  dispose() {
    //路由销毁时需要释放动画资源
    controller.dispose();
    super.dispose();
  }
}

class AnimatedImage extends AnimatedWidget {
  AnimatedImage({Key key, Animation<double> animation})
      : super(key: key, listenable: animation);

  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;

    String imgName = 'images/chat_bubble_voice_ripple00.png';
    switch (animation.value.toInt()) {
      case 0:
        imgName = 'images/chat_bubble_voice_ripple00.png';
        break;
      case 1:
        imgName = 'images/chat_bubble_voice_ripple01.png';
        break;
      case 2:
        imgName = 'images/chat_bubble_voice_ripple02.png';
        break;
      default:
    }
    return new Center(
      child: Image.asset(imgName),
    );
  }
}
