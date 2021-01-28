import 'dart:ui';

import 'package:easeim_flutter_demo/widgets/common_widgets.dart';
import 'package:easeim_flutter_demo/widgets/toast_widget.dart';
import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _usernameController;
  TextEditingController _pwdController;
  bool _hiddenPwd = true;
  bool _agreeProtocal = false;
  @override
  void initState() {
    super.initState();
    updateTextFieldController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: ConstrainedBox(
        constraints: BoxConstraints.expand(),
        child: GestureDetector(
          child: Container(
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              image: DecorationImage(
                colorFilter: ColorFilter.mode(
                  Color.fromRGBO(0, 0, 0, 0.3),
                  BlendMode.srcOver,
                ),
                alignment: Alignment.bottomCenter,
                image: AssetImage('images/login_bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Positioned(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 88,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              spreadRadius: 1.0,
                              offset: Offset(10, 10),
                              blurRadius: 30,
                              color: Colors.black12,
                            )
                          ],
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        width: 80,
                        height: 80,
                        child: Image.asset(
                          'images/login_icon.png',
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(33, 38, 33, 0),
                        child: loginRegistTextField(
                          hintText: '用户名',
                          controller: _usernameController,
                          rightIcon: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Image.asset(
                              'images/login_usename_clear.png',
                            ),
                            onPressed: () {
                              _usernameController.text = '';
                            },
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(33, 20, 33, 0),
                        child: loginRegistTextField(
                          hintText: '确认密码',
                          isPwd: _hiddenPwd,
                          controller: _pwdController,
                          rightIcon: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Image.asset(!_hiddenPwd
                                ? 'images/login_pwd_show.png'
                                : 'images/login_pwd_hidden.png'),
                            onPressed: () {
                              setState(() {
                                _hiddenPwd = !_hiddenPwd;
                              });
                            },
                          ),
                        ),
                      ),
                      Container(
                        height: 40,
                        margin: EdgeInsets.only(
                          top: 5,
                          left: 48,
                          right: 48,
                          bottom: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  setState(() {
                                    _agreeProtocal = !_agreeProtocal;
                                  });
                                },
                                icon: Image.asset(
                                  _agreeProtocal
                                      ? 'images/login_protocal_selected.png'
                                      : 'images/login_protocal_unselected.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 30,
                              child: FlatButton(
                                padding: EdgeInsets.only(left: 10),
                                child: Text(
                                  '同意 服务条款 与 隐私协议',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                onPressed: () => showPrivacyStatement(),
                              ),
                            )
                          ],
                        ),
                      ),
                      // 登录按钮
                      loginRegisterButton(
                        enable: _agreeProtocal,
                        margin: EdgeInsets.only(left: 33, right: 33),
                        beginColor: Colors.blue[400],
                        endColor: Colors.blue[800],
                        disabelColor: Colors.black38,
                        onPressed: () => loginAction(),
                        title: '登录',
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 30,
                  child: FlatButton(
                    child: Text(
                      '账号注册',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    onPressed: () => registerAccount(),
                  ),
                ),
              ],
            ),
          ),
          behavior: HitTestBehavior.translucent,
          onTap: () => hiddenKeyboard(),
        ),
      ),
    );
  }

  void updateTextFieldController() {
    _usernameController = TextEditingController();
    _usernameController.addListener(() {});
    _pwdController = TextEditingController();
    _pwdController.addListener(() {});
  }

  void showPrivacyStatement() {
    hiddenKeyboard();
  }

  loginAction() async {
    hiddenKeyboard();
    String username = _usernameController.text;
    String passwd = _pwdController.text;
    try {
      await EMClient.getInstance.login(username, passwd);

      Navigator.of(context).pushReplacementNamed(
        '/home',
      );
    } on EMError catch (e) {
      Toast.of(context).show(
        '登录失败 $e',
        duration: Duration(seconds: 3),
      );
    }
  }

  registerAccount() {
    hiddenKeyboard();
    Navigator.of(context).pushNamed('/register');
  }

  hiddenKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }
}
