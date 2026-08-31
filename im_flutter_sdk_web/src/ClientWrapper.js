/** Web 5.0 Client adapter. */
export function createClientWrapper({ client, emit, onStatus, getCurrentUser, setCurrentUser, messages }) {
  function registerManagerEvents() {
    if (!client?.addEventHandler) return;
    client.addEventHandler("native-auto-test", {
      onConnecting: () => onStatus("IM connecting"),
      onConnected: () => { onStatus("IM connected"); emit("onConnected", {}); },
      onDisconnected: () => { onStatus("IM disconnected"); emit("onDisconnected", {}); },
      onReconnectFailed: (error) => emit("onError", { error: jsonSafe(error) }),
      onTokenWillExpire: () => emit("onTokenWillExpire", {}),
      onTokenExpired: () => emit("onTokenDidExpire", {}),
      onOfflineMessageSyncStart: () => {
        emit("onOfflineMessageSyncStart", {});
        emit("onDataSyncStart", { type: "message" });
      },
      onOfflineMessageSyncFinish: () => {
        emit("onOfflineMessageSyncFinish", {});
        emit("onDataSyncFinish", { type: "message" });
      },
      onSyncDataStart: (data) => emit("onDataSyncStart", jsonSafe(data || {})),
      onSyncDataFinished: (data) => emit("onDataSyncFinish", jsonSafe(data || {})),
      onGroupNotify: (payload) => emit("onGroupNotify", jsonSafe(payload || {})),
      onOwnInfoUpdated: (payload) => emit("onSelfUserInfoUpdate", jsonSafe(payload || {})),
      onUserInfoUpdated: (payload) => {
        const values = Array.isArray(payload) ? payload : [payload];
        for (const value of values.filter(Boolean)) emit("onUserInfoUpdate", jsonSafe(value));
      },
    });
  }

  async function invoke(cmd, info = {}) {
    if (cmd === "init") return null;
    if (cmd === "isConnected") return client.getConnectionState() === "connected";
    if (cmd === "getCurrentDeviceId") return String(client.getClientResource?.() || "webim");
    if (cmd === "getCurrentUser") return { userId: client.getCurrentUserId() || getCurrentUser() };
    if (cmd === "getUserIdsWithRTCUids") return client.getUserIdsWithRTCUids(info);
    if (cmd === "getRTCTokenInfoWithChannelName") return client.getRTCTokenInfo(info);
    if (cmd === "login") {
      const userId = String(info.userId || "");
      const result = await client.login({ userId, token: String(info.pwdOrToken || info.token || "") });
      setCurrentUser(userId);
      return result;
    }
    if (cmd === "renewToken") return client.renewToken(String(info.token || info.pwdOrToken || ""));
    if (cmd === "logout") {
      await client.logout();
      setCurrentUser("");
      messages.clear();
      return true;
    }
    throw new Error(`Web 5.0 wrapper does not support Client.${cmd}`);
  }

  return { invoke, registerManagerEvents };
}

function jsonSafe(value) {
  if (value == null) return value;
  try { return JSON.parse(JSON.stringify(value)); } catch { return String(value); }
}
