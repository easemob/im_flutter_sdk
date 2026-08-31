/** Web 5.0 PresenceManager adapter and event registration. */
export function createPresenceManagerWrapper({ manager, emit, registerEvents, h }) {
  const commands = {
    fetchSubscribedMembersWithPageNum: (m, i) => m.getSubscribedPresenceList(h.pageOptions(i)),
    publishPresenceWithDescription: async (m, i) => {
      await m.publishPresence({ customStatus: String(i.desc ?? i.customStatus ?? "") });
      return true;
    },
    publishPresence: async (m, i) => {
      await m.publishPresence({ customStatus: String(i.desc ?? i.customStatus ?? "") });
      return true;
    },
    presenceSubscribe: async (m, i) => h.normalizePresenceResults(
      await m.subscribePresence(h.presenceSubscriptionOptions(i)),
    ),
    subscribePresence: async (m, i) => h.normalizePresenceResults(
      await m.subscribePresence(h.presenceSubscriptionOptions(i)),
    ),
    presenceUnsubscribe: (m, i) => m.unsubscribePresence({ userIds: h.presenceUserIds(i) }),
    unsubscribePresence: (m, i) => m.unsubscribePresence({ userIds: h.presenceUserIds(i) }),
    fetchPresenceStatus: async (m, i) => h.normalizePresenceResults(
      await m.getPresenceStatus({ userIds: h.presenceUserIds(i) }),
    ),
    getPresenceStatus: async (m, i) => h.normalizePresenceResults(
      await m.getPresenceStatus({ userIds: h.presenceUserIds(i) }),
    ),
  };

  function registerManagerEvents() {
    registerEvents(manager, [[
      "onPresenceStatusChange",
      (payload) => emit("onPresenceStatusChanged", h.jsonSafe(payload || {})),
    ]]);
  }

  async function invoke(cmd, info = {}) {
    if (cmd === "publishPresenceWithDescription" || cmd === "publishPresence") {
      await manager.publishPresence({ customStatus: String(info.desc ?? info.customStatus ?? "") });
      return true;
    }
    if (cmd === "presenceSubscribe" || cmd === "subscribePresence") {
      return h.normalizePresenceResults(await manager.subscribePresence(h.presenceSubscriptionOptions(info)));
    }
    if (cmd === "presenceUnsubscribe" || cmd === "unsubscribePresence") {
      return manager.unsubscribePresence({ userIds: h.presenceUserIds(info) });
    }
    if (cmd === "fetchPresenceStatus" || cmd === "getPresenceStatus") {
      return h.normalizePresenceResults(await manager.getPresenceStatus({ userIds: h.presenceUserIds(info) }));
    }
    throw new Error(`Web 5.0 wrapper does not support PresenceManager.${cmd}`);
  }

  return { commands, invoke, registerManagerEvents };
}
