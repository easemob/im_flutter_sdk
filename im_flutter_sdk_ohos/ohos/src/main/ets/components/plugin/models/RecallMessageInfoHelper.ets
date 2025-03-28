import { RecallMessageInfo } from "@easemob/chatsdk";
import { SafetyValue } from "../SafetyMapTool";
import MessageHelper from "./MessageHelper";

export default class RecallMessageInfoHelper {
  static toJson(info: RecallMessageInfo): Map<string, Object> {
    let data = new Map<string, Object>();
    SafetyValue(info.getRecallMessageId(), (value)=> data.set("recallMsgId", value));
    SafetyValue(info.getRecallBy(), (value)=> data.set("recallBy", value));
    SafetyValue(info.getExt(), (value)=> data.set("ext", value));
    SafetyValue(info.getRecallMessage(), (value)=> data.set("msg", MessageHelper.toJson(value)!));
    SafetyValue(info.getConversationId(), (value)=> data.set("conversationId", value));
    return data;
  }

  static listToJson(infos: RecallMessageInfo[]): Map<string, Object>[] {
    let list = new Array<Map<string, Object>>();
    for (let index = 0; index < infos.length; index++) {
      const info = infos[index];
      list.push(RecallMessageInfoHelper.toJson(info));
    }
    return list;
  }
}