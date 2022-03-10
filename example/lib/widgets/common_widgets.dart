import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' as screen_util;
import 'package:flutter_slidable/flutter_slidable.dart';

/// 注册登录用的输入框
Widget loginRegisterTextField({
  required String hintText,
  Color hintColor = Colors.black12,
  double fontSize = 18,
  double height = 100,
  Color textColor = Colors.black45,
  TextEditingController? controller,
  bool isPwd = false,
  Widget? rightIcon,
}) {
  return TextField(
    obscureText: isPwd,
    controller: controller,
    style: TextStyle(
      letterSpacing: 2,
      color: textColor,
      fontSize: sFontSize(fontSize),
    ),
    decoration: new InputDecoration(
      contentPadding: EdgeInsets.fromLTRB(25, 14, 0, 14),
      filled: true,
      fillColor: Colors.white,
      hintText: hintText,
      hintStyle: TextStyle(
        color: hintColor,
        fontSize: fontSize,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      suffixIcon: Padding(
        padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
        child: rightIcon,
      ),
    ),
  );
}

/// 注册登录的按钮
Widget loginRegisterButton({
  required VoidCallback onPressed,
  required String title,
  required Color beginColor,
  Color? endColor,
  Color? disableColor,
  double titleFontSize = 20,
  double letterSpacing = 10,
  Color titleColor = Colors.white,
  bool enable = true,
  double height = 50,
  EdgeInsets margin = EdgeInsets.zero,
}) {
  return Container(
    margin: margin,
    height: sHeight(height),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(sHeight(height)), //圆角
      gradient: LinearGradient(
        colors: enable
            ? <Color>[
                //背景渐变
                beginColor,
                endColor ?? beginColor,
              ]
            : [
                disableColor ?? beginColor,
                disableColor ?? beginColor,
              ],
      ),
    ),
    child: Row(
      children: [
        Expanded(
          child: TextButton(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                color: titleColor,
                fontSize: sFontSize(titleFontSize),
                letterSpacing: letterSpacing,
              ),
            ),
            onPressed: enable ? onPressed : () {},
          ),
        )
      ],
    ),
  );
}

/// 侧滑的Item
Widget slidableItem({
  required Widget child,
  required List<SlidableAction> actions,
  EdgeInsets margin = EdgeInsets.zero,
}) {
  return Container(
    margin: margin,
    child: Slidable(
      key: ValueKey(0),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: actions,
      ),
      child: child,
    ),
  );
}

/// 侧滑的"删除"类型action
SlidableAction slidableDeleteAction(
    {VoidCallback? onTap,
    Color? backgroundColor,
    Color foregroundColor = Colors.white}) {
  return SlidableAction(
    backgroundColor: Colors.red,
    foregroundColor: foregroundColor,
    icon: Icons.delete,
    label: "删除",
    onPressed: (context) => onTap?.call(),
  );
}

/// 未读数
Widget unreadCountWidget(int unreadCount) {
  if (unreadCount == 0) return Container();
  String count;
  if (unreadCount > 99) {
    count = '99+';
  } else {
    count = unreadCount.toString();
  }
  return Container(
    padding: EdgeInsets.only(left: sWidth(3), right: sWidth(3)),
    decoration: BoxDecoration(
      color: Colors.red,
      borderRadius: BorderRadius.all(
        Radius.circular(sWidth(15)),
      ),
    ),
    constraints: BoxConstraints(
      minWidth: sWidth(18),
      maxWidth: sWidth(30),
    ),
    child: Text(
      count,
      maxLines: 1,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: sFontSize(12),
        color: Colors.white,
      ),
    ),
  );
}

/// 屏幕宽度
double sWidth(double w) {
  return screen_util.ScreenUtil().setWidth(w);
}

/// 屏幕高度
double sHeight(double h) {
  return screen_util.ScreenUtil().setHeight(h);
}

/// 屏幕字体
double sFontSize(double size) {
  return screen_util.ScreenUtil().setSp(size);
}

/// 根据毫秒返回时间Str
String timeStrByMs(int ms, {bool showTime = false}) {
  String ret = '';
  // 是否当天
  // HH:mm
  if (DateUtil.isToday(ms)) {
    ret = DateUtil.formatDateMs(ms, format: 'HH:mm');
  }
  // // 是否本周
  // // 周一、周二、周三...
  // else if (DateUtil.isWeek(ms)) {
  //   ret = DateUtil.getWeekdayByMs(ms);
  // }

  // 是否本年
  // MM/dd
  else if (DateUtil.yearIsEqualByMs(ms, DateUtil.getNowDateMs())) {
    if (showTime) {
      ret = DateUtil.formatDateMs(ms, format: 'MM月dd日 HH:mm');
    } else {
      ret = DateUtil.formatDateMs(ms, format: 'MM月dd日');
    }
  }
  // yyyy/MM/dd
  else {
    if (showTime) {
      ret = DateUtil.formatDateMs(ms, format: 'yyyy年MM月dd日 HH:mm');
    } else {
      ret = DateUtil.formatDateMs(ms, format: 'yyyy年MM月dd日');
    }
  }

  return ret;
}

/// 时间转换string
