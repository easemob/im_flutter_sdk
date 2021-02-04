import 'package:flutter/material.dart';

class DemoAppBar {
  DemoAppBar(String s);

  static AppBar normal(
    String text, {
    List<Widget> actions,
  }) {
    return AppBar(
      title: Title(
        color: Colors.white,
        child: Text(
          text,
        ),
      ),
      actions: actions,
      centerTitle: true,
    );
  }
}
