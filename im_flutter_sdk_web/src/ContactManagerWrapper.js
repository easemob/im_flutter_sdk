/** Web 5.0 ContactManager adapter and contact event registration. */
export function createContactManagerWrapper({ manager, client, emit, registerEvents, h }) {
  const commands = {
    fetchAllContacts: (m) => m.getContacts(),
    getBlockListFromServer: async (m) => h.contactUserIds(await m.getBlocklist()),
    getSelfIdsOnOtherPlatform: (m) => client.getSelfIdsOnOtherPlatform(),
  };

  function registerManagerEvents() {
    registerEvents(manager, [
      ["onMultiDeviceContact", (payload) => {
        // Android/iOS 原生 SDK 会在多设备好友变更后更新本地联系人库。
        // Web SDK 只分发事件，因此补一次联系人同步，保证 getContacts() 读取到最新缓存。
        const sync = client?.refreshContactSnapshot?.();
        if (sync?.catch) void sync.catch(() => {});
        emit("onContactChanged", h.jsonSafe(payload || {}));
      }],
      ["onContactInvited", (payload) => emit("onContactInvited", h.normalizeContactEvent(payload, true))],
      ["onContactDeleted", (payload) => emit("onContactDeleted", h.normalizeContactEvent(payload))],
      ["onContactAdded", (payload) => emit("onContactAdded", h.normalizeContactEvent(payload))],
      ["onContactRefuse", (payload) => emit("onFriendRequestDeclined", h.normalizeContactEvent(payload))],
      ["onContactAgreed", (payload) => {
        const event = h.normalizeContactEvent(payload);
        emit("onFriendRequestAccepted", event);
        emit("onContactAdded", event);
      }],
      ["onContactInfoUpdated", (payload) => emit("onContactInfoUpdate", h.jsonSafe(payload || {}))],
    ]);
  }

  async function invoke(cmd, info = {}) {
    const targetUserId = String(info.userId || "");
    if (cmd === "getAllContacts" || cmd === "getContacts") return manager.getContacts();
    if (cmd === "addContact") {
      await manager.addContact({ userId: targetUserId, message: info.reason ?? info.message });
      return targetUserId;
    }
    if (cmd === "deleteContact") {
      await manager.deleteContact({ userId: targetUserId });
      return targetUserId;
    }
    if (cmd === "acceptInvitation") {
      await manager.acceptContactInvite({ userId: targetUserId });
      return targetUserId;
    }
    if (cmd === "declineInvitation") {
      await manager.declineContactInvite({ userId: targetUserId });
      return targetUserId;
    }
    if (cmd === "setContactRemark") {
      return manager.setContactRemark({ userId: targetUserId, remark: String(info.remark || "") });
    }
    if (cmd === "getBlockListFromDB") return h.contactUserIds(await manager.getBlocklist());
    if (cmd === "addUserToBlockList") {
      return manager.addUsersToBlocklist({ userIds: [targetUserId] });
    }
    if (cmd === "removeUserFromBlockList") {
      await manager.removeUserFromBlocklist({ userIds: [targetUserId] });
      return targetUserId;
    }
    throw new Error(`Web 5.0 wrapper does not support ContactManager.${cmd}`);
  }

  return { commands, invoke, registerManagerEvents };
}
