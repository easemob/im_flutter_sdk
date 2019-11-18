import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class ThemeUtils {
  ///判断深色模式
  static bool isDark(BuildContext context){
    final Brightness brightnessValue = MediaQuery.of(context).platformBrightness;
    return brightnessValue == Brightness.dark;
  }
}