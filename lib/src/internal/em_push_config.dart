import 'inner_headers.dart';

/// ~english
/// The push configuration class, which contains the push configuration information, such as the push style.
/// ~end
class EMPushConfig {
  String mzAppId = '';
  String mzAppKey = '';

  String oppoAppKey = '';
  String oppoAppSecret = '';

  String miAppId = '';
  String miAppKey = '';

  String fcmId = '';

  String apnsCertName = '';

  bool enableMeiZuPush = false;
  bool enableOppoPush = false;
  bool enableMiPush = false;

  bool enableFCM = false;

  bool enableVivoPush = false;
  bool agreePrivacyStatement = false;
  bool enableHWPush = false;
  bool enableHonorPush = false;
  bool enableAPNS = false;

  EMPushConfig();

  void updateFromJson(Map<String, dynamic> json) {
    miAppId = json["mzAppId"];
    mzAppKey = json["mzAppKey"];
    oppoAppKey = json["oppoAppKey"];
    oppoAppSecret = json["oppoAppSecret"];
    miAppId = json["miAppId"];
    miAppKey = json["miAppKey"];
    fcmId = json["fcmId"];
    apnsCertName = json["apnsCertName"];
    enableMeiZuPush = json.boolValue('enableMeiZuPush');
    enableOppoPush = json.boolValue('enableOppoPush');
    enableMiPush = json.boolValue('enableMiPush');
    enableFCM = json.boolValue('enableFCM');
    enableVivoPush = json.boolValue('enableVivoPush');
    agreePrivacyStatement = json.boolValue('agreePrivacyStatement');
    enableHWPush = json.boolValue('enableHWPush');
    enableAPNS = json.boolValue('enableAPNS');
    enableHonorPush = json.boolValue('enableHonorPush');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data.putIfNotNull("mzAppId", mzAppId);
    data.putIfNotNull("mzAppKey", mzAppKey);
    data.putIfNotNull("oppoAppKey", oppoAppKey);
    data.putIfNotNull("oppoAppSecret", oppoAppSecret);
    data.putIfNotNull("miAppId", miAppId);
    data.putIfNotNull("miAppKey", miAppKey);
    data.putIfNotNull("fcmId", fcmId);
    data.putIfNotNull("apnsCertName", apnsCertName);
    data.putIfNotNull("enableMeiZuPush", enableMeiZuPush);
    data.putIfNotNull("enableOppoPush", enableOppoPush);
    data.putIfNotNull("enableMiPush", enableMiPush);
    data.putIfNotNull("enableFCM", enableFCM);
    data.putIfNotNull("enableHWPush", enableHWPush);
    data.putIfNotNull("enableVivoPush", enableVivoPush);
    data.putIfNotNull('agreePrivacyStatement', agreePrivacyStatement);
    data.putIfNotNull("enableAPNS", enableAPNS);
    data.putIfNotNull("enableHonorPush", enableHonorPush);

    return data;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
