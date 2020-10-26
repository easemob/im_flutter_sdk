import 'package:im_flutter_sdk/im_flutter_sdk.dart';

class EMConferenceStream {

  EMConferenceStream._private();

  factory EMConferenceStream.fromJson(Map map){
    if (map == null) return null;
    return EMConferenceStream._private()
      ..streamId = map['streamId']
      ..streamName = map['streamName']
      ..memberName = map['memberName']
      ..username = map['username']
      ..enableVoice = map.boolValue('enableVoice')
      ..enableVideo = map.boolValue('enableVideo')
      ..ext = map['ext']
      ..type = EMConferenceStreamType.values[map['type']];
  }

  Map toJson() {
    Map data = Map();
    data['streamId'] = streamId;
    data['streamName'] = streamName;
    data['memberName'] = memberName;
    data['username'] = username;
    data['enableVoice'] = enableVoice;
    data['enableVideo'] = enableVideo;
    data['ext'] = ext;
    data['type'] = type.index;
    return data;
  }

  String streamId;
  String streamName;
  String memberName;
  String username;
  bool enableVoice;
  bool enableVideo;
  String ext;
  EMConferenceStreamType type;
  EMRTCView localView;
}