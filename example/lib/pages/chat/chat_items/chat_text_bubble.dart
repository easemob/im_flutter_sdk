import 'package:easeim_flutter_demo/unit/wx_expression.dart';
import 'package:easeim_flutter_demo/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

class ChatTextBubble extends StatelessWidget {
  ChatTextBubble(this.body);
  final EMTextMessageBody body;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: sWidth(13),
        right: sWidth(13),
        top: sHeight(9),
        bottom: sHeight(9),
      ),
      child: ExpressionText(
        body.content,
        TextStyle(
          color: Color.fromRGBO(51, 51, 51, 1),
          fontSize: sFontSize(17),
        ),
      ),
    );
  }
}
