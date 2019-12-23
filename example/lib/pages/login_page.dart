import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:im_flutter_sdk_example/widgets/progress_dialog.dart';

import 'package:im_flutter_sdk_example/utils/localizations.dart';
import 'package:im_flutter_sdk_example/utils/widget_util.dart';
import 'package:im_flutter_sdk_example/common/common.dart';
import 'package:image_picker/image_picker.dart';


class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _pwdController = TextEditingController();

  bool _loading = false;


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
      Navigator.of(context).pop();
      Navigator.of(context).pushNamed(Constant.toHomePage);
    }
  }

  @override
  Widget build(BuildContext context) {
    Map arguments = ModalRoute.of(context).settings.arguments;
    if(arguments != null) {
      _usernameController.text = arguments['username'];
      _pwdController.text = arguments['password'];
    }
    return WillPopScope(
      onWillPop: () async{
        SystemNavigator.pop();
      },
      child: Stack(
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
                Navigator.of(context).pushNamed(Constant.toRegisterPage);
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

          ProgressDialog(loading: _loading, msg: DemoLocalizations.of(context).inLogin,),
        ],
      ),
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
            obscureText : true,
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
              DemoLocalizations.of(context).login,
              style: TextStyle(color: Colors.white, fontSize: 16.0),
            ),
            color: Color.fromRGBO(0, 0, 0, 0.1),
            onPressed: () {
                if(this._usernameController.text.isEmpty || this._pwdController.text.isEmpty) {
                  WidgetUtil.hintBoxWithDefault('用户ID或密码不能为空!');
                  return ;
                } else if(WidgetUtil.isChinese(this._usernameController.text)) {
                  WidgetUtil.hintBoxWithDefault('用户ID不能使用中文!');
                  return ;
                }

                login(this._usernameController.text,this._pwdController.text);
            },
          ),
        ),
      ],
    ),
  );

void login(String username , String password){
    print(username+':'+password);
    _refreshUI(true);
      EMClient.getInstance().login(
          username,
          password,
          onSuccess: (username) {
            print("login succes");
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed(Constant.toHomePage);

          },
          onError: (code, desc) {
            _refreshUI(false);
            switch(code) {
              case 2: {
                WidgetUtil.hintBoxWithDefault('网络未连接!');
              }
              break;

              case 202: {
                WidgetUtil.hintBoxWithDefault('密码错误!');
              }
              break;

              case 204: {
                WidgetUtil.hintBoxWithDefault('用户ID不存在!');
              }
              break;

              case 300: {
                WidgetUtil.hintBoxWithDefault('无法连接服务器!');
              }
              break;

              default: {
                WidgetUtil.hintBoxWithDefault(desc);
              }
              break;
            }

            print("login error:" +
                code.toString() +
                "//" +
                desc.toString());
          });
  }

  void _refreshUI(bool loading){
    _loading = loading;
    setState(() {

    });
  }
}