import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';


class CallPage extends StatefulWidget {

  CallPage({Key key, this.callType, this.otherUser, this.isCaller = false}) : super(key: key);

  final EMCallType callType;
  final String otherUser;
  bool isCaller;

  @override
  State<StatefulWidget> createState() => _CallPageStatus(callType, otherUser, isCaller);
}

class _CallPageStatus extends State<CallPage> implements EMCallSessionListener{

  bool _hasAnswer = false;
  Widget _localView;
  Widget _remoteView;

  _CallPageStatus(this.callType, this.otherUser, this.isCaller);

  final EMCallType callType;
  final String otherUser;
  bool isCaller;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("提示"),
      ),
      body: Padding(
        padding: EdgeInsets.all(18),
        child: Center(
          child: Column(
            children: <Widget>[
              Text(callType == EMCallType.Video ? '视频' : '语音'),
              RaisedButton(
                onPressed: (){
                  try{
                    if(!_hasAnswer && !isCaller) { // 还没接听，并且当前账户不是主叫
                      _answerCall();
                    }else {
                      _hangupCall();
                    }
                  }on EMError catch(e){

                  }finally {

                  }
                },
                child: Text(!_hasAnswer && !isCaller ? "接听" : "挂断"),
              ),
              Container(
                height: 200,
                child:  !_hasAnswer ? Text("local占位") : EMRTCLocalView((view, viewId) => EMClient.getInstance.callManager.setLocalSurfaceView(view)),
              ),
              Container(
                height: 200,
                child:  !_hasAnswer ? Text("remote占位") : EMRTCRemoteView((view, viewId) => EMClient.getInstance.callManager.setRemoteSurfaceView(view)),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _answerCall() async {
    try{
      await EMClient.getInstance.callManager.answerCall();
      setState(() {
        _hasAnswer = true;
      });
    }on EMError catch(e) {

    }
  }

  void _hangupCall() async {
    try{
      await EMClient.getInstance.callManager.endCall();
    }on EMError catch (e) {

    }
  }

  void dispose() {
    print('call view disposed');
    super.dispose();
  }

  @override
  void onCallSessionDidConnect() {

  }

  @override
  void onCallSessionDidAccept() {
    setState(() {
      _hasAnswer = true;
    });
  }

  @override
  void onCallSessionNetworkDidChange(EMCallNetworkStatus status) {

  }

  @override
  void onCallSessionStateDidChange(EMCallStreamingStatus status) {

  }

  @override
  void onCallSessionDidEnd(int reason, [EMError error]) {

  }
}