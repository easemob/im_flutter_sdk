
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:im_flutter_sdk_example/widgets/ease_button_widget.dart';

import 'style.dart';
import 'theme_util.dart';
import 'time_util.dart';

enum PromptBoxLocation { TOP, BOTTOM, CENTER }

class WidgetUtil {

  static const int INTERVAL_IN_MILLISECONDS = 60 * 1000;

  /// 会话页面加号扩展栏里面的 widget，上面图片，下面文本
  static Widget buildExtentionWidget(String iconPath,String text,bool _isDark,Function()clicked) {
    return Container(
      margin:  EdgeInsets.fromLTRB(1,0,1,0),
      decoration: BoxDecoration(
        border: Border.all(width: 6, color: EMColor.borderLine),
        borderRadius: const BorderRadius.all(const Radius.circular(8)),
        color: _isDark ? EMColor.borderLine : EMColor.unreadCount,
      ),
       padding: EdgeInsets.fromLTRB(0,5,0,0),
       child: ImageButton(
           normalImage: Image.asset(iconPath),
           pressedImage: Image.asset(iconPath),
           title: text ,
           padding: 5 ,
           normalStyle: new TextStyle(),
           onPressed: (){
               if(clicked != null){
                 clicked();
               }
           },
       ),
    );
  }

  /// 用户头像
  static Widget buildUserPortrait(String path) {
    Widget protraitWidget = Image.asset("images/default_avatar.png",fit: BoxFit.fill);
    if(path.startsWith("http")) {
      protraitWidget = CachedNetworkImage(
        fit: BoxFit.fill,
        imageUrl: path,
      );
    }else {
      File file = File(path);
      if(file.existsSync()) {
        protraitWidget = Image.file(file,fit: BoxFit.fill,);
      }
    }
    return ClipOval(
      child: Container(
        height: EMLayout.emConListPortraitSize,
        width: EMLayout.emConListPortraitSize,
        child: protraitWidget,
      ),
    );
  }

  /// 会话页面录音时的 widget，gif 动画
  static Widget buildVoiceRecorderWidget() {
    return Container(
      padding: EdgeInsets.fromLTRB(50, 0, 50, 200),
      alignment: Alignment.center,
      child: Container(
        width: 150,
        height: 150,
        child: Image.asset("assets/images/voice_recoder.gif"),
      ),
    );
  }

  /// 消息 item 上的时间
  static Widget buildMessageTimeWidget(String sentTime) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Container(
          alignment: Alignment.center,
          width: 80,
          height: 22,
          color: Color(0xffC8C8C8),
          child: Text(TimeUtil.convertTime(int.parse(sentTime)),style: TextStyle(color: Colors.white,fontSize: 12),),
        ),
      );
  }

  /// 长按的 menu，用于处理会话列表页面和会话页面的长按
  static void showLongPressMenu(BuildContext context,Offset tapPos,Map<String,String> map,Function(String key)onSelected) {
    final RenderBox overlay =Overlay.of(context).context.findRenderObject();
    final RelativeRect position = RelativeRect.fromLTRB(
        tapPos.dx, tapPos.dy,
        overlay.size.width - tapPos.dx,
        overlay.size.height - tapPos.dy
    );
    List<PopupMenuEntry<String>>  items = new List();
    map.keys.forEach((String key) {
      PopupMenuItem<String> p = PopupMenuItem(
        child: Container(
          alignment: Alignment.center,
          child: Text(map[key],textAlign: TextAlign.center,),
        ),
        value: key,
      );
      items.add(p);
    });
    showMenu<String>(
        context: context,
        position: position,
        items: items
    ).then<String>((String selectedStr) {
      if(onSelected != null) {
        if(selectedStr == null) {
          selectedStr = "UndefinedKey";
        }
        onSelected(selectedStr);
      }
      return selectedStr;
    });
  }


  /// 空白 widget ，用于处理非法参数时的占位
  static Widget buildEmptyWidget() {
    return Container(
      height: 1,
      width: 1,
    );
  }

  static bool isChinese(String str) {
    for(int i = 0; i < str.length;i ++) {
      int a = str.codeUnitAt(i);
      if(a > 0x4e00 && a < 0x9fff) {
        return true;
      }
    }
    return false;
  }

  /// 提示框
  static hintBoxWithDefault(String msg) {
//    Future.sync((){
//    });
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 2,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 15.0
    );
  }

  static hintBoxWithCustom(String msg, PromptBoxLocation location,int timeInSecForIos, Color backgroundColor, Color textColor, double fontSize) {
    ToastGravity gravity;
    if(location == PromptBoxLocation.TOP) {
      gravity = ToastGravity.TOP;
    } else if(location == PromptBoxLocation.CENTER){
      gravity = ToastGravity.CENTER;
    } else {
      gravity = ToastGravity.BOTTOM;
    }
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: gravity,
        timeInSecForIos: timeInSecForIos,
        backgroundColor: backgroundColor,
        textColor: textColor,
        fontSize: fontSize
    );
  }

  ///判断消息时间间隔
  static bool isCloseEnough(String time1,String time2) {
    int lastTime = int.parse(time1);
    int afterTime = int.parse(time2);
    int delta = lastTime - afterTime;
    if (delta < 0) {
      delta = -delta;
    }
    return delta > INTERVAL_IN_MILLISECONDS;
  }

  static AppBar buildAppBar(BuildContext context, String title){
    return AppBar(
      elevation: 0,
      centerTitle : true,
      backgroundColor: ThemeUtils.isDark(context) ? EMColor.darkAppMain : EMColor.appMain,
      title: Text(title, style: TextStyle(fontSize:EMFont.emAppBarTitleFont, color: ThemeUtils.isDark(context) ? EMColor.darkText : EMColor.text)),
    );
  }
}

