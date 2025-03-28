import { ChatMessage,
  ChatMessageReaction,
  Chatroom, Contact, Conversation, CursorResult, Group, GroupReadAck } from "@easemob/chatsdk";
import { SafetyValue } from "../SafetyMapTool";
import ChatMessageReactionHelper from "./ChatMessageReactionHelper";
import ContactHelper from "./ContactHelper";
import ConversationHelper from "./ConversationHelper";
import GroupHelper from "./GroupHelper";
import GroupReadAckHelper from "./GroupReadAckHelper";
import MessageHelper from "./MessageHelper";

export default class CursorResultHelper {
    static toJson<T>(result: CursorResult<T>):Map<string, Object> {
      let data = new Map<string, Object>();
      SafetyValue(result.getNextCursor(), (value)=>data.set("cursor", value));
      let list = Array<Object>();

      for (let index = 0; index < result.getResult().length; index++) {
        const element = result.getResult()[index];
        if(element == undefined) continue;
        if (element instanceof ChatMessage) {
          let item = MessageHelper.toJson(element);
          if(item){
            list.push(item);
          }
        }
        else if (element instanceof Group) {
          let item = GroupHelper.toJson(element);
          if(item){
            list.push(item);
          }
        }
        else if (element instanceof Chatroom) {

        }
        else if (element instanceof GroupReadAck) {
          let item = GroupReadAckHelper.toJson(element);
          if(item){
            list.push(item);
          }
        }
        else if (element instanceof ChatMessageReaction) {
          let item = ChatMessageReactionHelper.toJson(element);
          if(item){
            list.push(item);
          }
        }
        else if (element instanceof Conversation) {
          let item = ConversationHelper.toJson(element);
          if(item){
            list.push(item);
          }
        }
        else if (element instanceof Contact) {
          list.push(ContactHelper.toJson(element));
        }

        else if (typeof element === "string") {
          list.push(element);
        }
      }
      data.set("list", list);
      return data;
    }
}