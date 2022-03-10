import 'package:flutter/material.dart';

class DemoAppBar extends AppBar {
  DemoAppBar(String title, {List<Widget>? rightWidgets})
      : super(
          title: Title(
            color: Colors.white,
            child: Text(title),
          ),
          actions: rightWidgets,
        );
}

// class DemoAppBar {
//   DemoAppBar(String s);

//   static AppBar normal(
//     String text, {
//     List<Widget> actions,
//   }) {
//     return AppBar(
//       title: Title(
//         color: Colors.white,
//         child: Text(
//           text,
//         ),
//       ),
//       actions: actions,
//       centerTitle: true,
//     );
//   }
// }
