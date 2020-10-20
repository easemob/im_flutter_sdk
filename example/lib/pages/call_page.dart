import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

class CallPage extends StatefulWidget {

  CallPage({Key key, @required this.session}) : super(key: key);

  final EMCallSession session;

  @override
  State<StatefulWidget> createState() => _CallPageStatus(session: session);
}

class _CallPageStatus extends State<CallPage>{

  bool _hasAnswer = false;

  _CallPageStatus({@required this.session});

  final EMCallSession session;

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
                  EMClient.getInstance.callManager.answerIncomingCall(session.callId);
                  setState(() {
                    _hasAnswer = true;
                  });
                },
                child: Text("接听"),
              ),
            Container(
                height: 200,
                child:  !_hasAnswer ? Text("我是占位") : EMRTCView(onCreated:(view, viewId) => session.setRemoteView(view), streamId: session.callId, viewType: EMRTCViewType.remote),
                )
            ],
          ),
        ),
      ),
    );
  }


  void dispose() {
    print('call view disposed');
    super.dispose();
  }
}