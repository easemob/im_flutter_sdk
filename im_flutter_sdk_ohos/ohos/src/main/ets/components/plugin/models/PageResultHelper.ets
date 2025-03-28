import {
  ChatMessage,
  Chatroom, Group, GroupReadAck } from "@easemob/chatsdk";
import ChatRoomHelper from "./ChatRoomHelper";
import GroupHelper from "./GroupHelper";
import MessageHelper from "./MessageHelper";

export default class PageResultHelper {
  static toJson(result: Chatroom[]):Map<string, Object> {
    let data = new Map<string, Object>();
    let list = Array<Object>();
    data.set("count", result.length);
    for (let index = 0; index < result.length; index++) {
      const element = result[index];
      if(element == undefined) continue;
      if (element instanceof Chatroom) {
        let item = ChatRoomHelper.toJson(element);
        if(item){
          list.push(item);
        }
      } if (element instanceof ChatMessage) {
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
    }
    data.set("list", list);
    return data;
  }
}
