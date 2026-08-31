/** Web 5.0 compatibility adapter for the legacy ConversationManager protocol. */
export function createConversationWrapper({ chat, h }) {
  async function invoke(cmd, info = {}) {
    if (cmd === "markAllMessagesAsRead") return chat.clearAllConversationUnreadMessageCount();
    if (cmd === "pinnedMessages") return chat.getPinnedMessageList(h.unreadOptions(info));
    throw new Error(`Web 5.0 wrapper does not support ConversationManager.${cmd}`);
  }
  return { invoke };
}
