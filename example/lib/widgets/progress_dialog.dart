import 'package:flutter/material.dart';

/// 显示加载dialog
class ProgressDialog extends StatelessWidget {
  final bool loading;
  //进度提示内容
  final String msg;
  //加载中动画
  final Widget progress;
  //背景透明度
  final double alpha;
  //字体颜色
  final Color textColor;
  ProgressDialog({Key key,@required this.loading,this.msg,
    this.progress = const CircularProgressIndicator(),this.alpha = 0.6,
    this.textColor = Colors.white,})
      : assert(loading != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetList = [];
    //假如正在加载，则显示加载增加加载中布局
    if(loading) {
      Widget layoutProgress;
      if (msg == null) {
        layoutProgress = Center(
          child: progress,
        );
      }else {
        layoutProgress = Center(
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(4.0)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                progress,
                Container(
                  padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0),
                  child: Text(
                    msg, style: TextStyle(color: textColor, fontSize: 16.0, decoration: TextDecoration.none),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      widgetList.add(Opacity(
        opacity: alpha,
        child: new ModalBarrier(dismissible: false),
      )
      );
      widgetList.add(layoutProgress);
    }
    return Stack(
      children: widgetList,
    );
  }
}