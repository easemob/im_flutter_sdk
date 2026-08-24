import WebIM from "easemob-websdk";

import { canonicalMessage, chatType, createEventAdapter } from "./event_adapter.js";

/**
 * Web SDK 4.23 adapter for the native-auto-test protocol.
 *
 * This package intentionally exposes Manager/cmd names used by pytest rather
 * than leaking Web SDK method names into case code.
 */
export function createWebSdkWrapper({ appKey, emit, onStatus = () => {} }) {
  let currentUser = "";
  const messages = new Map();
  const connection = new WebIM.connection({
    appKey,
    delivery: true,
    isFixedDeviceId: true,
  });
  const adapter = createEventAdapter({ emit, currentUser: () => currentUser });

  connection.addEventHandler("native-auto-test", {
    onConnected: () => onStatus("IM connected"),
    onDisconnected: () => onStatus("IM disconnected"),
    onTextMessage: (message) => {
      const canonical = adapter.onTextMessage(message);
      messages.set(canonical.msgId, canonical);
    },
    onDeliveredMessage: (message) => adapter.onDeliveredMessage(message),
    onReactionChange: (event) => adapter.onReactionChange(event),
    onError: (error) => adapter.onError(error),
  });

  return {
    async invoke(manager, cmd, info = {}) {
      if (manager === "Client") return invokeClient(cmd, info);
      if (manager === "ChatManager") return invokeChat(cmd, info);
      throw new Error(`Web Wrapper does not support ${manager}.${cmd}`);
    },
  };

  async function invokeClient(cmd, info) {
    if (cmd === "init" || cmd === "startCallback") return null;
    if (cmd === "isConnected") return connection.isOpened();
    if (cmd === "getCurrentDeviceId") return String(connection.deviceId || "");
    if (cmd === "login") {
      currentUser = String(info.userId || "");
      const result = await connection.open({
        user: currentUser,
        ...(info.isPassword === false
          ? { accessToken: info.pwdOrToken }
          : { pwd: info.pwdOrToken }),
      });
      return result || currentUser;
    }
    if (cmd === "logout") {
      connection.close();
      currentUser = "";
      return null;
    }
    throw new Error(`Web Wrapper does not support Client.${cmd}`);
  }

  async function invokeChat(cmd, info) {
    if (cmd === "sendMessage") {
      const body = info.body || {};
      if (body.type !== 0) throw new Error("Web Wrapper MVP only supports text messages");
      const raw = WebIM.message.create({
        chatType: chatType(info.chatType),
        type: "txt",
        to: info.to,
        msg: body.content,
      });
      const sent = await connection.send(raw);
      const tempId = String(sent.localMsgId || raw.id || "");
      const realId = String(sent.serverMsgId || tempId);
      const canonical = canonicalMessage(
        { ...raw, id: realId, from: currentUser, to: info.to, msg: body.content },
        { direction: 0, currentUser },
      );
      messages.set(realId, canonical);
      emit("onMessageSuccess", { msgId: tempId, msg: canonical });
      return { ...canonical, msgId: tempId };
    }
    if (cmd === "getMessage") return messages.get(String(info.msgId)) || null;
    if (cmd === "addReaction") {
      await connection.addReaction({
        messageId: String(info.msgId),
        reaction: String(info.reaction),
      });
      return null;
    }
    throw new Error(`Web Wrapper does not support ChatManager.${cmd}`);
  }
}
