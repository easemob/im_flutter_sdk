import { ChatMessagePinInfo } from "@easemob/chatsdk";
import { SafetyValue } from "../SafetyMapTool";

export default class ChatMessagePinInfoHelper {
  static toJson(info: ChatMessagePinInfo): Map<string, Object> {
    let data = new Map<string, Object>();
    SafetyValue(info.pinTime(), (value)=> data.set("pinTime", value));
    SafetyValue(info.operatorId(), (value)=> data.set("operatorId", value));
    return data;
  }
}