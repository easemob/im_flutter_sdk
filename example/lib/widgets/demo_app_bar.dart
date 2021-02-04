import 'package:flutter/material.dart';

class DemoAppBar {
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
