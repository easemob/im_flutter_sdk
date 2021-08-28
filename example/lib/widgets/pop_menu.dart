import 'package:easeim_flutter_demo/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

typedef PopMenuValueChange = Function(int selectedIndex);

class PopMenu {
  static show(
    BuildContext context,
    List<PopMenuItem> items, {
    Color bgColor = Colors.black87,
    Color textColor = Colors.white,
    Color lineColor = Colors.transparent,
    PopMenuValueChange callback,
  }) {
    // 定义item
    Widget _menuViewItem(PopMenuItem item) {
      List<Widget> widgetsList = [];
      if (item.imageName != null) {
        widgetsList.add(Image.asset(item.imageName));
      }
      widgetsList.add(
        Container(
          height: 60,
          child: Center(
            child: Text(
              item.title,
              style: TextStyle(
                color: textColor,
                fontSize: sFontSize(15),
              ),
            ),
          ),
        ),
      );

      if (widgetsList.length == 2) {
        widgetsList.insert(1, SizedBox(width: 30));
      }

      return Row(
        mainAxisAlignment: widgetsList.length > 1
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: widgetsList,
      );
    }

    // 定义MenuView
    Widget _menuView(List<PopMenuItem> items) {
      return ListView.separated(
        padding: const EdgeInsets.only(left: 10, right: 10),
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: ((_, index) {
          return InkWell(
            onTap: () {
              Navigator.pop(context);
              callback(index);
            },
            child: _menuViewItem(items[index]),
          );
        }),
        separatorBuilder: ((_, index) {
          return Divider(
            height: .5,
            // indent: 5,
            // endIndent: 0,
            color: lineColor,
          );
        }),
        itemCount: items.length,
      );
    }

    double top =
        MediaQueryData.fromWindow(ui.window).padding.top + kToolbarHeight - 10;

    Widget _arrowRounder(List<PopMenuItem> items) {
      var cellH = items.length * 60;
      return Positioned(
        right: 10,
        top: top,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Image.asset('menu_up_arrow.png', width: 28, height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Container(
                color: bgColor,
                width: 130,
                height: cellH.toDouble(),
                child: _menuView(items),
              ),
            ),
          ],
        ),
      );
    }

    Navigator.of(context).push(
      DialogRouter(
        BasePopMenus(
          child: _arrowRounder(items),
        ),
      ),
    );
  }
}

class BasePopMenus extends Dialog {
  BasePopMenus({
    Key key,
    this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          GestureDetector(onTap: () => Navigator.pop(context)),
          //内容
          child
        ],
      ),
    );
  }
}

class PopMenuItem {
  PopMenuItem(this.title, {this.imageName});
  final String title;
  final String imageName;
}

class DialogRouter extends PageRouteBuilder {
  final Widget page;

  DialogRouter(this.page)
      : super(
          opaque: false,
          barrierColor: Colors.white10.withAlpha(1),
          transitionDuration: const Duration(milliseconds: 150),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              child,
        );
}
