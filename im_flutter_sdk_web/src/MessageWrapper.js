/** Web 5.0 compatibility adapter for the legacy MessageManager protocol. */
export function createMessageWrapper({ chat, chatThreads, h }) {
  async function invoke(cmd, info = {}) {
    if (cmd === "chatThread") return chatThreads?.getChatThread(String(info.threadId || info.chatThreadId)) || null;
    if (cmd === "getPinInfo") return chat.getPinnedMessageList(h.unreadOptions(info));
    if (cmd === "getReactionList") return chat.getReactionList({ messageId: String(info.msgId || info.messageId) });
    if (cmd === "groupAckCount" || cmd === "readReceiptCount") {
      const messageId = String(info.msgId || info.messageId || "");
      const receipts = await chat.getGroupMessageReadReceipts(h.groupReceiptOptions(info));
      const receipt = Array.isArray(receipts)
        ? receipts.find((item) => String(item?.messageId || "") === messageId)
        : null;
      return receipt?.count ?? 0;
    }
    throw new Error(`Web 5.0 wrapper does not support MessageManager.${cmd}`);
  }
  return { invoke };
}
