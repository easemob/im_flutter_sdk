import 'dart:math';

import 'package:easeim_flutter_demo/widgets/common_widgets.dart';
import 'package:flutter/material.dart';

class ChatMoreView extends StatefulWidget {
  ChatMoreView(
    this.list, {
    int rowCount = 4,
    int columnCount = 2,
    bool autoHeight = true,
  })  : rowCount = rowCount,
        columnCount = columnCount,
        autoHeight = autoHeight;

  final List<ChatMoreViewItem> list;

  /// 横向总间隔
  final double allHorizontalPadding = sWidth(10);

  /// 纵向总间距
  final double allVerticalPadding = sHeight(10);

  /// 列数
  final int rowCount;

  /// 行数
  final int columnCount;

  /// 每个item高度
  final double itemHeight = sWidth(67);

  /// 当设置的item个数不满足行数的时候，自动适应高度
  final bool autoHeight;

  @override
  State<StatefulWidget> createState() => _ChatMoreViewState();
}

class _ChatMoreViewState extends State<ChatMoreView> {
  int _pageNum = 1;

  List<List<ChatMoreViewItem>> _lists = [];

  @override
  void initState() {
    super.initState();
    num pageItemCount = widget.rowCount * widget.columnCount;

    _pageNum = widget.list.length ~/ (widget.rowCount * widget.columnCount) + 1;
    for (var i = 0; i < _pageNum; i++) {
      int count = widget.list.length - (i + 1) * pageItemCount;
      List<ChatMoreViewItem> list;
      if (count >= 0) {
        list = widget.list.sublist(i * pageItemCount, pageItemCount);
      } else {
        list = widget.list.sublist(i * pageItemCount);
      }

      _lists.add(list);
    }
  }

  @override
  Widget build(BuildContext context) {
    double width =
        ((MediaQuery.of(context).size.width - widget.allHorizontalPadding) /
            widget.rowCount);
    double height = 0;
    if (widget.autoHeight && widget.list.length < widget.rowCount) {
      height = widget.allVerticalPadding +
          ((widget.list.length ~/ widget.rowCount) + 1) *
              max(widget.itemHeight, width);
    } else {
      height = widget.allVerticalPadding +
          widget.columnCount * max(widget.itemHeight, width);
    }

    return Container(
      color: Color.fromRGBO(248, 248, 248, 1),
      width: MediaQuery.of(context).size.width,
      height: height,
      child: PageView.builder(
        itemCount: _pageNum,
        itemBuilder: (BuildContext context, int index) {
          return GridView.count(
            physics: NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            crossAxisSpacing:
                widget.allHorizontalPadding / (widget.rowCount - 1),
            mainAxisSpacing: widget.allVerticalPadding,
            padding: EdgeInsets.only(
              left: sWidth(20),
              right: sWidth(20),
              top: sHeight(12),
              bottom: sHeight(12),
            ),
            crossAxisCount: widget.rowCount,
            childAspectRatio: width / max(widget.itemHeight, width),
            children: getItemWidgetList(index),
          );
        },
      ),
    );
  }

  List<Widget> getItemWidgetList(int index) {
    return _lists[index].map((item) => getItemWidget(item)).toList();
    // return widget.list.map((item) => getItemWidget(item)).toList();
  }

  Widget getItemWidget(ChatMoreViewItem item) {
    return Container(
      height: widget.itemHeight,
      // color: Colors.blue,
      child: GestureDetector(
        onTapUp: (TapUpDetails details) {
          if (item.onTap != null) item.onTap();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              padding: EdgeInsets.all(
                sWidth(10),
              ),
              width: sWidth(55),
              height: sWidth(55),
              child: Image.asset(item.imageName),
            ),
            SizedBox(
              height: sHeight(2),
            ),
            Text(
              item.label,
              style: TextStyle(
                color: Color.fromRGBO(153, 153, 153, 1),
                fontSize: sFontSize(10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMoreViewItem {
  ChatMoreViewItem(this.imageName, this.label, this.onTap);
  final String imageName;
  final String label;
  VoidCallback onTap;
}
