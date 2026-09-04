/** Web 5.0 compatibility adapter for the legacy ConversationManager protocol. */
export function createConversationWrapper({ chat, h }) {
  async function invoke(cmd, info = {}) {
    if (cmd === "clearAllMessages") {
      await chat.clearAllMessagesAndConversations();
      return true;
    }
    if (cmd === "markAllMessagesAsRead") {
      await chat.clearConversationUnreadMessageCount(h.unreadOptions(info));
      return true;
    }
    if (cmd === "getUnreadMsgCount") {
      const conversationId = String(info.convId || info.conversationId || "");
      const conversationType = h.conversationType(info);
      const conversation = chat.getConversationList().find(
        (item) => item.conversationId === conversationId
          && item.conversationType === conversationType,
      );
      return conversation?.unreadCount ?? 0;
    }
    if (cmd === "pinnedMessages") return chat.getPinnedMessageList(h.unreadOptions(info));
    throw new Error(`Web 5.0 wrapper does not support ConversationManager.${cmd}`);
  }
  return { invoke };
}
