import { ChatMessageReaction } from "@easemob/chatsdk";
import { SafetyValue } from "../SafetyMapTool";

export default class ChatMessageReactionHelper {
  static toJson(reaction: ChatMessageReaction): Map<string, Object> {
    let data = new Map<string, Object>();
    SafetyValue(reaction.reaction(), (value)=> data.set("reaction", value));
    SafetyValue(reaction.userCount(), (value)=> data.set("count", value));
    SafetyValue(reaction.isAddedBySelf(), (value)=> data.set("isAddedBySelf", value));
    SafetyValue(reaction.userIds(), (value)=> data.set("userList", value));
    return data;
  }

  static listToJson(reactions: ChatMessageReaction[]): Map<string, Object>[] {
    let list = new Array<Map<string, Object>>();
    for (let index = 0; index < reactions.length; index++) {
      const reaction = reactions[index];
      list.push(ChatMessageReactionHelper.toJson(reaction));
    }
    return list;
  }
}