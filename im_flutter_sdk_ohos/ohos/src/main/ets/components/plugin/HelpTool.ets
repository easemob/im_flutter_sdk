import { ChatMessage } from "@easemob/chatsdk";

export default class HelpTool {
  static mergeMessage(msg: ChatMessage, dbMsg: ChatMessage) {
    dbMsg.setServerTimestamp(msg.getServerTimestamp());
    dbMsg.setLocalTimestamp(msg.getLocalTimestamp());
    dbMsg.setStatus(msg.getStatus());
    dbMsg.setReceiverRead(msg.isReceiverRead());
    dbMsg.setIsNeedGroupAck(msg.isNeedGroupAck());
    dbMsg.setUnread(msg.isUnread());
    dbMsg.setIsListened(msg.isListened());
    dbMsg.setReceiverList(msg.receiverList());
    dbMsg.deliverOnlineOnly(msg.isDeliverOnlineOnly());
    dbMsg.setExt(msg.ext());
    dbMsg.setBody(msg.getBody());
  }
}