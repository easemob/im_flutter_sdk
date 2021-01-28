import 'package:easeim_flutter_demo/unit/wx_expression.dart';
import 'package:easeim_flutter_demo/widgets/common_widgets.dart';
import 'package:flutter/material.dart';

typedef OnFaceTap = Function(Expression expression);
typedef OnSendTap = void Function();
typedef OnDeleteTap = void Function();

class ChatFaceView extends StatefulWidget {
  ChatFaceView(this.canDelete,
      {this.onFaceTap, this.onSendTap, this.onDeleteTap});

  final bool canDelete;
  final OnFaceTap onFaceTap;
  final OnSendTap onSendTap;
  final OnDeleteTap onDeleteTap;

  @override
  State<StatefulWidget> createState() => ChatFaceViewState();
}

class ChatFaceViewState extends State<ChatFaceView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Color.fromRGBO(242, 242, 242, 1.0),
      ),
      width: double.infinity,
      height: sHeight(250),
      child: Stack(
        children: [
          Positioned(
            child: WeChatExpression(
              (Expression expression) {
                if (widget.onFaceTap != null) {
                  widget.onFaceTap(expression);
                }
              },
            ),
          ),
          Positioned(
            bottom: sHeight(20),
            right: sWidth(10),
            child: Container(
              height: sWidth(40),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Color.fromRGBO(242, 242, 242, 1.0),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    offset: Offset(0, 0),
                    color: Color.fromRGBO(242, 242, 242, 1.0),
                    blurRadius: sWidth(10),
                    spreadRadius: sWidth(5),
                  ),
                  BoxShadow(
                    offset: Offset(0, 30),
                    color: Color.fromRGBO(242, 242, 242, 1.0),
                    spreadRadius: sWidth(20),
                  )
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: sWidth(60),
                    height: sWidth(45),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white,
                    ),
                    // 删除按钮
                    child: FlatButton(
                      child: Image.asset(
                        'images/chat_faces_delete.png',
                        color:
                            widget.canDelete ? Colors.black87 : Colors.black26,
                        width: sWidth(25),
                        height: sWidth(20),
                        fit: BoxFit.fill,
                      ),
                      onPressed: () {
                        if (widget.onDeleteTap != null) {
                          widget.onDeleteTap();
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    width: sWidth(5),
                  ),
                  Container(
                    width: sWidth(60),
                    height: sWidth(45),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: widget.canDelete
                          ? Color.fromRGBO(26, 184, 77, 1)
                          : Colors.white,
                    ),
                    // 发送按钮
                    child: FlatButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        if (widget.onSendTap != null) {
                          widget.onSendTap();
                        }
                      },
                      child: Text(
                        '发送',
                        style: TextStyle(
                          color:
                              widget.canDelete ? Colors.white : Colors.black26,
                          fontSize: sFontSize(16),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
