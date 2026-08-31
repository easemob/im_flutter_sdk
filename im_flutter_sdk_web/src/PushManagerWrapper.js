/** Web 5.0 PushManager adapter. */
export function createPushManagerWrapper({ manager, h }) {
  const commands = {
    bindDeviceToken: (m, i) => m.uploadPushToken(h.pushTokenOptions(i)),
    fetchConversationSilentMode: async (m, i) => h.normalizeSilentModeResult(await m.getConversationSilentMode(h.pushConversation(i)), i),
    fetchPreferredNotificationLanguage: async (m) => {
      const result = await m.getPushLanguage();
      return result?.language ?? result;
    },
    fetchSilentModeForAll: async (m) => h.normalizeSilentModeResult(await m.getGlobalSilentMode()),
    fetchSilentModeForConversations: async (m, i) => h.normalizeSilentModeConversations(
      await m.getConversationSilentModes({ conversationList: h.silentModeConversationList(i) }),
    ),
    removeConversationSilentMode: async (m, i) => {
      await m.clearConversationRemindType(h.pushConversation(i));
      return null;
    },
    setConversationSilentMode: async (m, i) => {
      await m.setConversationSilentMode(h.pushConversation(i));
      return null;
    },
    setPreferredNotificationLanguage: (m, i) => m.setPushLanguage({ language: String(i.language || i.code || "") }),
    setSilentModeForAll: async (m, i) => {
      await m.setGlobalSilentMode({ rule: h.silentModeRule(i) });
      return null;
    },
    updateFCMPushToken: (m, i) => m.uploadPushToken(h.pushTokenOptions(i, "fcm")),
    updateHMSPushToken: (m, i) => m.uploadPushToken(h.pushTokenOptions(i, "hms")),
  };

  return { commands };
}
