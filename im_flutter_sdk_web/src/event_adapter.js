/** Convert Web SDK callbacks into the native-auto-test cross-platform contract. */
export function createEventAdapter({ emit, currentUser }) {
  return {
    onTextMessage(message) {
      const canonical = canonicalMessage(message, { direction: 1, currentUser: currentUser() });
      emit("onMessagesReceived", { messages: [canonical] });
      return canonical;
    },
    onDeliveredMessage(message) {
      const canonical = canonicalMessage(message, { direction: 0, currentUser: currentUser() });
      emit("onMessagesDelivered", { messages: [canonical] });
      return canonical;
    },
    onReactionChange(event) {
      emit("messageReactionDidChange", {
        events: normalizeReactionEvent(event, currentUser()),
      });
    },
    onError(error) {
      emit("onError", { error: jsonSafe(error) });
    },
  };
}

export function canonicalMessage(raw, { direction, currentUser }) {
  const msgId = String(raw.id || raw.msgId || raw.messageId || "");
  const content = raw.msg || raw.content || raw.body?.content || "";
  const from = String(raw.from || (direction === 0 ? currentUser : ""));
  const to = String(raw.to || (direction === 0 ? raw.to : currentUser));
  return {
    msgId,
    from,
    to,
    convId: direction === 0 ? to : from,
    chatType: 0,
    direction,
    status: 2,
    hasRead: direction === 0,
    hasReadAck: false,
    // 测试协议中，已投递到当前接收端的入站消息标记为 true；它描述
    // 当前消息对象的投递态，不用于替代发送端的全端送达回执计数。
    hasDeliverAck: direction === 1,
    needGroupAck: false,
    isThread: false,
    isContentReplaced: false,
    deliverOnlineOnly: false,
    body: { type: 0, content },
  };
}

export function chatType(value) {
  return Number(value) === 1 ? "groupChat" : Number(value) === 2 ? "chatRoom" : "singleChat";
}

/** Web `onReactionChange` → Android/iOS reaction event contract. */
export function normalizeReactionEvent(raw, currentUser) {
  const source = Array.isArray(raw) ? raw : [raw];
  return source.filter(Boolean).map((event) => {
    const from = String(event.from || "");
    const to = String(event.to || "");
    const reactions = Array.isArray(event.reactions) ? event.reactions : [];
    const operations = reactions.flatMap((item) =>
      (Array.isArray(item.op) ? item.op : []).map((op) => ({
        userId: String(op.operator || ""),
        reaction: String(item.reaction || ""),
        operate: op.reactionType === "create" ? 1 : 0,
      })),
    );
    return {
      convId: currentUser === from ? to : from,
      msgId: String(event.messageId || event.msgId || ""),
      operations,
      reactions: reactions.map((item) => ({
        reaction: String(item.reaction || ""),
        count: Number(item.count || 0),
        isAddedBySelf: (item.userList || []).includes(currentUser),
        userList: Array.isArray(item.userList) ? item.userList.map(String) : [],
      })),
    };
  });
}

export function jsonSafe(value) {
  return JSON.parse(JSON.stringify(value));
}
