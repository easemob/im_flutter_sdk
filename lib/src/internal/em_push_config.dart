import 'inner_headers.dart';

/// The push configuration class, which contains the push configuration information, such as the push style.
class EMPushConfig {
  String? mzAppId = '';
  String? mzAppKey = '';

  String? oppoAppKey = '';
  String? oppoAppSecret = '';

  String? miAppId = '';
  String? miAppKey = '';

  String? fcmId = '';

  String? apnsCertName = '';

  bool? enableMeiZuPush = false;
  bool? enableOppoPush = false;
  bool? enableMiPush = false;

  bool? enableFCM = false;

  bool? enableVivoPush = false;
  bool? enableHWPush = false;

  bool? enableAPNS = false;

  EMPushConfig();

  /// @nodoc
  void updateFromJson(Map<String, dynamic> json) {
    miAppId = json.stringValue("mzAppId");
    mzAppKey = json.stringValue("mzAppKey");
    oppoAppKey = json.stringValue("oppoAppKey");
    oppoAppSecret = json.stringValue("oppoAppSecret");
    miAppId = json.stringValue("miAppId");
    miAppKey = json.stringValue("miAppKey");
    fcmId = json.stringValue("fcmId");
    apnsCertName = json.stringValue("apnsCertName");
    enableMeiZuPush = json.boolValue('enableMeiZuPush');
    enableOppoPush = json.boolValue('enableOppoPush');
    enableMiPush = json.boolValue('enableMiPush');
    enableFCM = json.boolValue('enableFCM');
    enableVivoPush = json.boolValue('enableVivoPush');
    enableHWPush = json.boolValue('enableHWPush');
    enableAPNS = json.boolValue('enableAPNS');
  }

  /// @nodoc
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data.setValueWithOutNull("mzAppId", mzAppId);
    data.setValueWithOutNull("mzAppKey", mzAppKey);
    data.setValueWithOutNull("oppoAppKey", oppoAppKey);
    data.setValueWithOutNull("oppoAppSecret", oppoAppSecret);
    data.setValueWithOutNull("miAppId", miAppId);
    data.setValueWithOutNull("miAppKey", miAppKey);
    data.setValueWithOutNull("fcmId", fcmId);
    data.setValueWithOutNull("apnsCertName", apnsCertName);
    data.setValueWithOutNull("enableMeiZuPush", enableMeiZuPush);
    data.setValueWithOutNull("enableOppoPush", enableOppoPush);
    data.setValueWithOutNull("enableMiPush", enableMiPush);
    data.setValueWithOutNull("enableFCM", enableFCM);
    data.setValueWithOutNull("enableHWPush", enableHWPush);
    data.setValueWithOutNull("enableVivoPush", enableVivoPush);
    data.setValueWithOutNull("enableAPNS", enableAPNS);

    return data;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
