/// @nodoc
import 'inner_headers.dart';

/// ~english
/// The push configuration class, which contains the push configuration information, such as the push style.
/// ~end
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
    enableHWPush = json.boolValue('enableHWPush');
    enableAPNS = json.boolValue('enableAPNS');
  }

  /// @nodoc
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data.add("mzAppId", mzAppId);
    data.add("mzAppKey", mzAppKey);
    data.add("oppoAppKey", oppoAppKey);
    data.add("oppoAppSecret", oppoAppSecret);
    data.add("miAppId", miAppId);
    data.add("miAppKey", miAppKey);
    data.add("fcmId", fcmId);
    data.add("apnsCertName", apnsCertName);
    data.add("enableMeiZuPush", enableMeiZuPush);
    data.add("enableOppoPush", enableOppoPush);
    data.add("enableMiPush", enableMiPush);
    data.add("enableFCM", enableFCM);
    data.add("enableHWPush", enableHWPush);
    data.add("enableVivoPush", enableVivoPush);
    data.add("enableAPNS", enableAPNS);

    return data;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
