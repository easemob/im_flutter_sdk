import 'package:easeim_flutter_demo/widgets/common_widgets.dart';
import 'package:flutter/material.dart';

class ContactItem extends StatelessWidget {
  ContactItem(
    this.title, {
    this.avatar,
    this.unreadCount = 0,
  });
  final String title;
  final Image? avatar;
  final unreadCount;
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(
            left: 15,
            top: 10,
            bottom: 10,
          ),
          width: 45,
          height: 50,
          child: avatar ?? Image.asset('images/logo.png'),
        ),
        Container(
          alignment: Alignment.centerLeft,
          height: 50,
          margin: EdgeInsets.only(
            top: 5,
            bottom: 5,
            left: 15,
            right: 5,
          ),
          child: Text(
            title,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: sFontSize(17),
              color: Colors.black,
            ),
            maxLines: 1,
          ),
        ),
        Expanded(
          child: SizedBox(),
        ),
        Container(
          margin: EdgeInsets.only(
            right: sWidth(40),
          ),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: unreadCountWidget(unreadCount),
        ),
      ],
    );
  }
}
