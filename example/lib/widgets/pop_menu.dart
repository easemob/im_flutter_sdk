import 'package:flutter/material.dart';

typedef PopMenuValueChange = Function(int selectedIndex);

class PopMenu {
  PopMenu.show(
    BuildContext context,
    List<PopMenuItem> items, {
    bool showBg = false,
    PopMenuValueChange callback,
  }) {
    Navigator.of(context).push(
      DialogRouter(
        _basePopMenus(
          child: _menusView(items),
        ),
      ),
    );
  }

  Widget _basePopMenus({
    @required Widget child,
  }) {
    return Container();
  }

  Widget _menusView(List<PopMenuItem> items) {
    return Container();
  }
}

class PopMenuItem {
  PopMenuItem(this.title, {this.image});
  final String title;
  final Image image;
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
