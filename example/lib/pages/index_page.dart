import 'dart:async';

import 'package:flutter/material.dart';
import 'package:easeim_flutter_demo/widgets/common_widgets.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

class IndexPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => IndexPageState();
}

/// 欢迎页
class IndexPageState extends State<IndexPage> {
  final _totalTime = 3.0;
  Timer _timer;
  num _value;

  @override
  void initState() {
    super.initState();
    _value = _totalTime;
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_value == 0) {
        _timer.cancel();
        toNextPage();
        return;
      }
      setState(() {
        _value--;
      });
    });
  }

  void toNextPage() {
    if (EMClient.getInstance.isLoginBefore == true) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            alignment: Alignment.bottomCenter,
            image: AssetImage('images/launch.jpg'),
          ),
        ),
        child: SafeArea(
          child: Align(
            alignment: Alignment(0.9, -0.95),
            child: SizedBox(
              width: sWidth(40),
              height: sHeight(40),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    child: CircularProgressIndicator(
                      value: (_totalTime - _value) / _totalTime,
                      backgroundColor: Colors.red,
                      strokeWidth: 1.5,
                    ),
                  ),
                  Positioned(
                    child: Text(
                      '${_value.toInt()}s',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: sFontSize(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    super.dispose();
  }
}
