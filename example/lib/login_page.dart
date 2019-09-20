import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _pwdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: loginBody(),
      ),
    );
  }

  loginBody() => SingleChildScrollView(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[loginHeader(), loginFields()],
    ),
  );

  loginHeader() => Column(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      FlutterLogo(
        colors: Colors.green,
        size: 80.0,
      ),
      SizedBox(
        height: 30.0,
      ),
      Text(
        "欢迎使用环信",
        style: TextStyle(fontWeight: FontWeight.w700, color: Colors.green),
      ),
      SizedBox(
        height: 5.0,
      ),
      Text(
        "登陆并继续",
        style: TextStyle(color: Colors.grey),
      ),
    ],
  );

  loginFields() => Container(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 30.0),
          child: TextField(
            controller: _usernameController,
            maxLines: 1,
            decoration: InputDecoration(
              hintText: "请输入用户名",
              labelText: "用户名",
            ),
          ),
        ),
        SizedBox(
          height: 30.0,
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 30.0),
          width: double.infinity,
          child: RaisedButton(
            padding: EdgeInsets.all(12.0),
            shape: StadiumBorder(),
            child: Text(
              "登陆",
              style: TextStyle(color: Colors.white),
            ),
            color: Colors.green,
            onPressed: () {
              login(context);
            },
          ),
        ),
      ],
    ),
  );

  saveCurrentUser(String currentUser) async {
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    await prefs.setString('currentUser', currentUser);
//    User.currentUser = currentUser;
  }

  Future<void> onLoginClick(String currentUser) async {
//    ImLeancloudPlugin ImleancloudPlugin = ImLeancloudPlugin.getInstance();
//    // ImleancloudPlugin.onLoginClick(currentUser);
//    bool islogin = await ImleancloudPlugin.onLoginClick(currentUser);
//    if (islogin) {
//      User.isloginLcchat = true;
//    }
  }

  void login(BuildContext context) async {
//    await saveCurrentUser(_usernameController.text);
//    onLoginClick(_usernameController.text);
//    Navigator.of(context).pushReplacementNamed('/contact');
  }
}