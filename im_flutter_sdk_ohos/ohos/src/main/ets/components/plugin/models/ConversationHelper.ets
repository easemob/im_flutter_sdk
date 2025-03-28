import { Conversation } from "@easemob/chatsdk";
import EnumTool from "../EnumTool";
import { SafetyValue } from "../SafetyMapTool";

export default class ConversationHelper {
  static toJson(conv: Conversation | undefined): Map<string, Object> | null{
    if(!conv) return null;
    let ret = new Map<string, Object>();
    SafetyValue(conv.conversationId(), (value)=>ret.set("convId", value));
    SafetyValue(conv.getType(), (value)=>ret.set("type", EnumTool.conversationTypeToInt(value)));
    SafetyValue(conv.getPinnedTime(), (value)=>ret.set("pinnedTime", value));
    SafetyValue(conv.isPinned(), (value)=>ret.set("isPinned", value));
    SafetyValue(conv.marks(), (value)=> ret.set("marks", value));
    let str = conv.getExtField();
    if(str.length > 0) {
      SafetyValue(conv.getExtField(), (value)=> ret.set("ext", JSON.parse(value)));
    }

    ret.set("isThread", false);
    return ret;
  }

  static listToJson(conversations: Conversation[] | undefined): Map<string, Object>[] {
    let list = new Array<Map<string, Object>>();
    if(conversations) {
      for (let index = 0; index < conversations.length; index++) {
        const conversation = conversations[index];
        let conv = ConversationHelper.toJson(conversation);
        if(conv) {
          list.push(conv);
        }
      }
    }
    return list;
  }
}