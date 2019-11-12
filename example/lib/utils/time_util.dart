

class TimeUtil {

  //将 unix 时间戳转换为特定时间文本，如年月日
  static String convertTime(int timestamp) {
    DateTime msgTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    DateTime nowTime = DateTime.now();

    if(nowTime.year == msgTime.year) {//同一年
      if(nowTime.month == msgTime.month) {//同一月
        if(nowTime.day == msgTime.day) {//同一天 时:分
          return msgTime.hour.toString()+":"+msgTime.minute.toString();
        }else {
          if(nowTime.day - msgTime.day == 1) {//昨天
            return "昨天";
          }else if(nowTime.day - msgTime.day < 7) {
            return _getWeekday(msgTime.weekday);
          }
        }
      }
    }
    return msgTime.year.toString()+"/"+msgTime.month.toString()+"/"+msgTime.day.toString();
  }

  ///是否需要显示时间，相差 5 分钟
  static bool needShowTime(int sentTime1,int sentTime2) {
    return (sentTime1-sentTime2).abs() > 5 * 60 * 1000;
  }

  static String _getWeekday(int weekday) {
    switch (weekday) {
      case 1:return "星期一";
      case 2:return "星期二";
      case 3:return "星期三";
      case 4:return "星期四";
      case 5:return "星期五";
      case 6:return "星期六";
      default:return "星期日";
    }
  }
}