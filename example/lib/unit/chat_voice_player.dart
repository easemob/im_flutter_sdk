import 'package:flutter/foundation.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:record_amr/record_amr.dart';

class ChatVoicePlayer extends ChangeNotifier {
  String currentMsgId = '';
  bool isPlaying = false;

  playVoice(EMMessage msg) async {
    if (currentMsgId != null) {
      isPlaying = false;
      notifyListeners();
      currentMsgId = null;
    }

    EMVoiceMessageBody body = msg.body as EMVoiceMessageBody;
    isPlaying = await RecordAmr.play(body.localPath, (path) {
      isPlaying = false;
      notifyListeners();
      currentMsgId = null;
    });
    if (isPlaying) {
      currentMsgId = msg.msgId;
    }
    notifyListeners();
  }

  stopPlay() async {
    if (currentMsgId != null) {
      isPlaying = false;
      notifyListeners();
      currentMsgId = null;
    }

    RecordAmr.stop();
  }
}
