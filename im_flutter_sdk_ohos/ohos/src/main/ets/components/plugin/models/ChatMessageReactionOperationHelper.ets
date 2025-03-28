import { ChatMessageReactionOperation } from "@easemob/chatsdk";
import EnumTool from "../EnumTool";
import { SafetyValue } from "../SafetyMapTool";

export default class ChatMessageReactionOperationHelper {
  static toJson(operation: ChatMessageReactionOperation): Map<string, Object> {
    let data = new Map<string, Object>();
    SafetyValue(operation.userId(), (value)=> data.set("userId", value));
    SafetyValue(operation.reaction(), (value)=> data.set("reaction", value));
    SafetyValue(operation.operation(), (value)=> data.set("operate", EnumTool.reactionOperationToInt(value)));
    return data;
  }


  static listToJson(operations: ChatMessageReactionOperation[]): Map<string, Object>[] {
    let list = new Array<Map<string, Object>>();
    for (let index = 0; index < operations.length; index++) {
      const operation = operations[index];
      list.push(ChatMessageReactionOperationHelper.toJson(operation));
    }
    return list;
  }
}