import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';


class CallPage extends StatefulWidget {

  CallPage({Key key, @required this.session}) : super(key: key);

  final EMCallSession session;

  @override
  State<StatefulWidget> createState() => _CallPageStatus(session: session);
}

class _CallPageStatus extends State<CallPage> implements EMCallSessionListener{

  bool _hasAnswer = false;

  _CallPageStatus({@required this.session});

  final EMCallSession session;

  @override
  void initState() {
    session.listener = this;
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
              Text(session.callType == EMCallType.Video ? '视频' : '语音'),
              RaisedButton(
                onPressed: (){
                  try{
                    if(!_hasAnswer && !session.isCaller) { // 还没接听，并且当前账户不是主叫
                      _answerCall();
                    }else {
                      _hangupCall();
                    }
                  }on EMError catch(e){

                  }finally {

                  }
                },
                child: Text(!_hasAnswer && !session.isCaller ? "接听" : "挂断"),
              ),
              Container(
                height: 200,
                child:  !_hasAnswer ? Text("remote占位") : EMRTCView(onCreated:(view, viewId) => session.setRemoteView(view), streamId: session.callId, viewType: EMRTCViewType.remote),
              ),
              Container(
                height: 200,
                child:  !_hasAnswer ? Text("local占位") : EMRTCView(onCreated:(view, viewId) => session.setLocalView(view), streamId: session.callId, viewType: EMRTCViewType.local),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _answerCall() async {
    try{
      await EMClient.getInstance.callManager.answerIncomingCall(session.callId);
      setState(() {
        _hasAnswer = true;
      });
    }on EMError catch(e) {

    }
  }

  void _hangupCall() async {
    try{
      await EMClient.getInstance.callManager.endCall(session.callId);
    }on EMError catch (e) {

    }
  }

  void dispose() {
    print('call view disposed');
    session.listener = null;
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