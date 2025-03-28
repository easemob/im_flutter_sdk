import { ChatMessageReactionChange } from "@easemob/chatsdk";
import { SafetyValue } from "../SafetyMapTool";
import ChatMessageReactionHelper from "./ChatMessageReactionHelper";
import ChatMessageReactionOperationHelper from "./ChatMessageReactionOperationHelper";

export default class ChatMessageReactionChangeHelper {
  static toJson(change: ChatMessageReactionChange): Map<string, Object> {
    let data = new Map<string, Object>();
    SafetyValue(change.conversationId(), (value)=> data.set("conversationId", value));
    SafetyValue(change.messageId(), (value)=> data.set("messageId", value));
    SafetyValue(change.reactions(), (value)=> data.set("reactions", ChatMessageReactionHelper.listToJson(value)));
    SafetyValue(change.operations(), (value)=> data.set("reactions", ChatMessageReactionOperationHelper.listToJson(value)));

    return data;
  }

  static listToJson(changes: ChatMessageReactionChange[]): Map<string, Object>[] {
    let list = new Array<Map<string, Object>>();
    for (let index = 0; index < changes.length; index++) {
      const change = changes[index];
      list.push(ChatMessageReactionChangeHelper.toJson(change));
    }
    return list;
  }
}
