import { createClientWrapper } from "./ClientWrapper.js";
import { createChatManagerWrapper } from "./ChatManagerWrapper.js";
import { createChatRoomManagerWrapper } from "./ChatRoomManagerWrapper.js";
import { createChatThreadManagerWrapper } from "./ChatThreadManagerWrapper.js";
import { createContactManagerWrapper } from "./ContactManagerWrapper.js";
import { createConversationWrapper } from "./ConversationWrapper.js";
import { createGroupManagerWrapper } from "./GroupManagerWrapper.js";
import { createMessageWrapper } from "./MessageWrapper.js";
import { createPresenceManagerWrapper } from "./PresenceManagerWrapper.js";
import { createPushManagerWrapper } from "./PushManagerWrapper.js";
import { createUserInfoManagerWrapper } from "./UserInfoManagerWrapper.js";
import * as protocolHelper from "./ProtocolHelper.js";

/**
 * Web 5.0 wrapper entry point. The native IIFE is loaded by the browser runner.
 */
export function createWebSdkWrapper({
  appKey,
  deviceId = "webim",
  emit,
  onStatus = () => {},
}) {
  return createWeb5SdkWrapper({ appKey, deviceId, emit, onStatus });
}

function createWeb5SdkWrapper({ appKey, deviceId, emit, onStatus }) {
  const sdk = globalThis.IMSDK;
  if (!sdk?.ChatClient?.init) throw new Error("Web 5.0 SDK global IMSDK is not loaded");

  let currentUser = "";
  const messages = new Map();
  const client = sdk.ChatClient.init({
    appKey,
    managers: [
      sdk.ChatManager,
      sdk.ChatRoomManager,
      sdk.ChatThreadManager,
      sdk.ContactManager,
      sdk.GroupManager,
      sdk.PresenceManager,
      sdk.PushManager,
      sdk.UserInfoManager,
    ].filter(Boolean),
    enableDeliveryReceipt: true,
    // Web 5.0 contact sync requires the userInfo:read capability, provided by
    // the registered UserInfoManager below. Keep contact state synchronized on
    // every device so topology cases can validate the complete account state.
    enableSyncData: ["conversation", "contact"],
    useFixedDeviceId: true,
    deviceId: String(deviceId || "webim"),
  });
  const chat = client.chatManager;
  const chatRooms = client.chatRoomManager;
  const chatThreads = client.chatThreadManager;
  const contacts = client.contactManager;
  const groups = client.groupManager;
  const presence = client.presenceManager;
  const push = client.pushManager;
  const userInfo = client.userInfoManager;

  const managers = {
    ChatManager: chat,
    ChatRoomManager: chatRooms,
    ChatThreadManager: chatThreads,
    ContactManager: contacts,
    GroupManager: groups,
    PresenceManager: presence,
    PushManager: push,
    UserInfoManager: userInfo,
  };

  const h = protocolHelper;

  const clientWrapper = createClientWrapper({
    client,
    emit,
    onStatus,
    getCurrentUser: () => currentUser,
    setCurrentUser: (value) => { currentUser = value; },
    messages,
  });
  const chatWrapper = createChatManagerWrapper({
    manager: chat,
    emit,
    registerEvents,
    h,
    currentUser: () => currentUser,
    messages,
  });
  const chatRoomWrapper = createChatRoomManagerWrapper({ manager: chatRooms, emit, registerEvents, h });
  const chatThreadWrapper = createChatThreadManagerWrapper({ manager: chatThreads, emit, registerEvents, h });
  const contactWrapper = createContactManagerWrapper({ manager: contacts, client, emit, registerEvents, h });
  const groupWrapper = createGroupManagerWrapper({ manager: groups, emit, registerEvents, h, currentUser: () => currentUser });
  const presenceWrapper = createPresenceManagerWrapper({ manager: presence, emit, registerEvents, h });
  const pushWrapper = createPushManagerWrapper({ manager: push, h });
  const userInfoWrapper = createUserInfoManagerWrapper({ manager: userInfo, currentUser: () => currentUser, h });
  const messageWrapper = createMessageWrapper({ chat, chatThreads, h });
  const conversationWrapper = createConversationWrapper({ chat, h });
  const managerWrappers = {
    ChatManager: chatWrapper,
    ChatRoomManager: chatRoomWrapper,
    ChatThreadManager: chatThreadWrapper,
    ContactManager: contactWrapper,
    GroupManager: groupWrapper,
    PresenceManager: presenceWrapper,
    PushManager: pushWrapper,
    UserInfoManager: userInfoWrapper,
  };
  const wrapperCommandMap = Object.fromEntries(
    Object.entries(managerWrappers).map(([name, wrapper]) => [name, wrapper.commands || {}]),
  );

  clientWrapper.registerManagerEvents();
  chatWrapper.registerManagerEvents();
  chatRoomWrapper.registerManagerEvents();
  chatThreadWrapper.registerManagerEvents();
  contactWrapper.registerManagerEvents();
  groupWrapper.registerManagerEvents();
  presenceWrapper.registerManagerEvents();

  async function invoke(manager, cmd, info = {}) {
    if (manager === "Client") return clientWrapper.invoke(cmd, info);
    if (manager === "MessageManager") return messageWrapper.invoke(cmd, info);
    if (manager === "ConversationManager") return conversationWrapper.invoke(cmd, info);
    if (manager === "ContactManager" && !hasMappedCommand(manager, cmd)) return contactWrapper.invoke(cmd, info);
    if (manager === "ChatManager" && !hasMappedCommand(manager, cmd)) return chatWrapper.invoke(cmd, info);
    if (hasMappedCommand(manager, cmd)) return invokeMapped(manager, cmd, info);
    throw new Error(`Web 5.0 wrapper does not support ${manager}.${cmd}`);
  }

  function hasMappedCommand(manager, cmd) {
    return Boolean(wrapperCommandMap[manager]?.[cmd]);
  }

  async function invokeMapped(manager, cmd, info) {
    const target = managers[manager];
    const operation = wrapperCommandMap[manager]?.[cmd];
    if (!target || !operation) throw new Error(`Web 5.0 wrapper does not support ${manager}.${cmd}`);
    const result = await operation(target, info);
    return h.jsonSafe(result);
  }

  function registerEvents(manager, entries) {
    if (!manager?.addEventHandler) return;
    const handler = {};
    for (const [name, callback] of entries) handler[name] = callback;
    const key = manager.constructor?.key || manager.constructor?.name || "manager";
    manager.addEventHandler(`native-auto-test-${key}`, handler);
  }

  return { invoke };
}
