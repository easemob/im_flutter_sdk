import { LoginExtInfo } from "@easemob/chatsdk";
import { SafetyValue } from "../SafetyMapTool";

export default class LoginExtensionInfoHelper {
  static toJson(info: LoginExtInfo): Map<string, Object> {
    let ret = new Map<string, Object>();
    SafetyValue(info.deviceInfo, (value)=>ret.set("deviceName", value));
    SafetyValue(info.deviceExt, (value)=>ret.set("ext", value));
    return ret;
  }
}