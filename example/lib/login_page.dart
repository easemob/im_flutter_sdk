import 'package:flutter/material.dart';

import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import 'utils/localizations.dart';
import 'common/common.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _pwdController = TextEditingController();
 bool isLogged;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoggedInBefore();
  }

  void isLoggedInBefore() async{
    bool isLoggedInBefore = await EMClient.getInstance().isLoggedInBefore();
    print(isLoggedInBefore);
    isLogged = isLoggedInBefore;
    if(isLoggedInBefore){
      Navigator.of(context).pushNamed(Constant.toHomePage);
    }
  }

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
        Container(
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 30.0),
          child: TextField(
            controller: _pwdController,
            maxLines: 1,
            obscureText: true,
            decoration: InputDecoration(
              hintText: "请输入密码",
              labelText: "密码",
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
              DemoLocalizations.of(context).login,
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

  void login(BuildContext context){
    if(isLogged){
      Navigator.of(context).pushNamed('home');
    }else {
      EMClient.getInstance().login(
          userName: _usernameController.text,
          password: _pwdController.text,
          onSuccess: (username) {
            EMClient.getInstance()
                .groupManager()
                .getJoinedGroupsFromServer();
            print("login succes");
            Navigator.of(context).pushNamed(Constant.toHomePage);
          },
          onError: (code, desc) {
            print("login error:" +
                code.toString() +
                "//" +
                desc.toString());
          });
    }
  }
}