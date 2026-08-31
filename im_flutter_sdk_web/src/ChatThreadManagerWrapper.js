/** Web 5.0 ChatThreadManager adapter and event registration. */
export function createChatThreadManagerWrapper({ manager, emit, registerEvents, h }) {
  const commands = {
    createChatThread: (m, i) => m.createChatThread({ parentMessageId: String(i.msgId || i.parentMessageId), name: i.name || i.subject || "", message: i.message }),
    destroyChatThread: (m, i) => m.destroyChatThread({ chatThreadId: String(i.threadId || i.chatThreadId) }),
    fetchChatThreadDetail: (m, i) => m.getChatThreadInfo({ chatThreadId: String(i.threadId || i.chatThreadId) }),
    fetchChatThreadMember: (m, i) => m.getChatThreadMemberList({ chatThreadId: String(i.threadId || i.chatThreadId), pageSize: h.pageSize(i), cursor: i.cursor || "" }),
    fetchChatThreadsWithParentId: (m, i) => m.getChatThreadList({ parentMessageId: String(i.msgId || i.parentMessageId), pageSize: h.pageSize(i), cursor: i.cursor || "" }),
    fetchJoinedChatThreads: (m, i) => m.getJoinedChatThreadList(h.pageOptions(i)),
    fetchJoinedChatThreadsWithParentId: (m, i) => m.getJoinedChatThreadList({ ...h.pageOptions(i), parentMessageId: String(i.msgId || i.parentMessageId) }),
    fetchLastMessageWithChatThreads: (m, i) => m.getChatThreadLastMessageList({ threadIds: i.threadIds || [] }),
    joinChatThread: (m, i) => m.joinChatThread({ chatThreadId: String(i.threadId || i.chatThreadId) }),
    leaveChatThread: (m, i) => m.leaveChatThread({ chatThreadId: String(i.threadId || i.chatThreadId) }),
    removeMemberFromChatThread: (m, i) => m.removeChatThreadMember({ chatThreadId: String(i.threadId || i.chatThreadId), userId: h.userId(i) }),
    updateChatThreadSubject: (m, i) => m.updateChatThreadName({ chatThreadId: String(i.threadId || i.chatThreadId), name: i.subject || i.name || "" }),
  };

  function registerManagerEvents() {
    registerEvents(manager, [["onChatThreadNotify", (payload) => {
      const data = h.jsonSafe(payload || {});
      const value = String(data.type || data.eventType || data.action || data.operation || "").toLowerCase();
      const eventType = value.includes("destroy") || value.includes("delete")
        ? "onChatThreadDestroy"
        : value.includes("create") || value.includes("add")
          ? "onChatThreadCreate"
          : value.includes("kick") || value.includes("remove")
            ? "onUserKickOutOfChatThread"
            : "onChatThreadUpdate";
      emit(eventType, data);
    }]]);
  }

  return { commands, registerManagerEvents };
}
