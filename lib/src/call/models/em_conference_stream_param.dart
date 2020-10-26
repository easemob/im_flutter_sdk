import 'package:im_flutter_sdk/im_flutter_sdk.dart';

class EMStreamParam {

  EMStreamParam([this.streamName = '', this.steamType = EMConferenceStreamType.Normal, this.enableVideo = true, this.isBackCamera = false, this.ext = '']);

  String streamName;
  EMConferenceStreamType steamType;
  bool enableVideo;
  bool isMute;
  String ext;
  bool isBackCamera;

//  int maxVideoKbps;
//  int minVideoKbps;
//  int maxAudioKbps;

  EMRTCView localView;

  factory EMStreamParam.fromJson(Map map) {
    if(map == null) return null;
    return EMStreamParam()
      ..streamName = map['streamName']
      ..steamType = EMConferenceStreamType.values[map['steamType']]
      ..enableVideo = map.boolValue('streamName')
      ..isMute = map.boolValue('isMute')
      ..ext = map['ext']
      ..isBackCamera = map.boolValue('isBackCamera');
  }

  Map toJson() {
    Map data = Map();
    data[''] = streamName;
    data['steamType'] = steamType.index;
    data['steamType'] = enableVideo;
    data['isMute'] = isMute;
    data['ext'] = ext;
    data['isBackCamera'] = isBackCamera;
    data['view_id'] = localView.id;
    return data;
  }
}