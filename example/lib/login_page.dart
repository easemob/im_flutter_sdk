import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'utils/localizations.dart';
import 'register_page.dart';


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
    print('是否登录$isLoggedInBefore');
    isLogged = isLoggedInBefore;
    if(isLoggedInBefore){
      Navigator.of(context).pushNamed('home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scaffold(
            backgroundColor: Colors.white,
            body: Container(
              /// 背景图
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/star.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Align(
                alignment: Alignment(0, -0.4),
                child: loginBody(),
              ),
            )
        ),

        /// 注册账号
        Positioned(
          left: 33,
          bottom: 54,
          width: 100,
          height: 17,
          child: FlatButton(
            child: Text(
              '账号注册',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                decoration: TextDecoration.none,
                letterSpacing: 2,
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.left,
            ),
            onPressed: (){
              Navigator.of(context).pushNamed('register_page');
            },

          ),
        ),

        /// 服务器配置
        Positioned(
          right: 33,
          bottom: 54,
          width: 130,
          height: 17,
          child: FlatButton(
            child: Text(
              '服务器端配置',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                decoration: TextDecoration.none,
                letterSpacing: 2,
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.right,
            ),
            onPressed: (){

            },

          ),
        ),
      ],
    );
  }

  loginBody() => SingleChildScrollView(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[loginHeader(), loginFields()],
    ),
  );

  /// logo图标
  loginHeader() => Container(
    width: 76,
    height: 76,
    decoration: BoxDecoration(
//      borderRadius: BorderRadius.circular(150),
      image: DecorationImage(
        image: AssetImage('images/logo@2x.png'),
        fit: BoxFit.cover,
      ),
    ),
  );

  loginFields() => Container(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[

        SizedBox(height: 20),

        /// 用户名输入框
        Container(
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 33.0),
          child: TextField(
            controller: _usernameController,
            maxLines: 1,
            decoration: InputDecoration(
              hintText: "用户名",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(57),
                borderSide: BorderSide.none,
              ),
              fillColor: Colors.white,
              filled: true,
            ),
          ),
        ),

        /// 密码输入框
        Container(
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 33.0),
          child: TextField(
            controller: _pwdController,
            maxLines: 1,
            decoration: InputDecoration(
              hintText: "密码",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(57),
                borderSide: BorderSide.none,
              ),
              fillColor: Colors.white,
              filled: true,
            ),
          ),
        ),

        SizedBox(
          height: 10.0,
        ),

        /// 登录按钮
        Container(
          padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 33.0),
          width: double.infinity,
          height: 50.0,
          child: RaisedButton(
            padding: EdgeInsets.all(12.0),
            shape: StadiumBorder(),
            child: Text(
              '登 录',
//              DemoLocalizations.of(context).login,
              style: TextStyle(color: Colors.white, fontSize: 16.0),

            ),
            color: Color.fromRGBO(0, 0, 0, 0.1),
            onPressed: () {

//              Navigator.of(context).pushNamed('home');

              print('用户名${this._usernameController.text}');
              print('密码${this._pwdController.text}');
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
//    if(isLogged){
//      Navigator.of(context).pushNamed('home');
//      print('用户名${this._usernameController.text}');
//      print('密码${this._pwdController.text}');
//    }else {
      EMClient.getInstance().login(
//          userName: _usernameController.text,
//          password: _pwdController.text,

          userName: 'u15',
          password: '1',
          onSuccess: (username) {
            print("login succes");
            Navigator.of(context).pushNamed('home_page');
          },
          onError: (code, desc) {
            print("login error:" +
                code.toString() +
                "//" +
                desc.toString());
          });
//    }
  }
}