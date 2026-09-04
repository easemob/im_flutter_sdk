/** Web 5.0 ChatRoomManager adapter and native chat-room event registration. */
export function createChatRoomManagerWrapper({ manager, emit, registerEvents, h }) {
  const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

  const isChatRoomNotReady = (error) => (
    Number(error?.code) === 606
    || String(error?.message || "").toLowerCase().includes("group does not exist")
  );

  const joinChatRoom = async (m, i) => {
    const chatRoomId = h.roomId(i);
    const options = {
      chatRoomId,
      ext: i.ext ?? i.message,
      leaveOtherRooms: i.leaveOtherRooms,
    };
    const deadline = Date.now() + 10_000;
    let joined;

    while (true) {
      try {
        joined = await m.joinChatRoom(options);
        break;
      } catch (error) {
        if (!isChatRoomNotReady(error) || Date.now() >= deadline) throw error;
        await sleep(Math.min(500, deadline - Date.now()));
      }
    }

    return h.normalizeChatRoomJoinResult(joined);
  };

  const fetchChatRoomInfo = async (m, i) => {
    const chatRoomId = h.roomId(i);
    const info = await m.getChatRoomInfo({ chatRoomId });
    return h.normalizeChatRoomSummary(info);
  };

  const fetchChatRoomAttributes = async (m, i) => {
    const params = { chatRoomId: h.roomId(i) };
    if (Array.isArray(i.keys) && i.keys.length > 0) params.keys = i.keys;
    const result = await m.getAttributes(params);
    return result?.attributes ?? result;
  };

  const commands = {
    fetchPublicChatRoomsFromServer: async (m, i) => h.normalizeChatRoomPageResult(
      await m.getChatRoomList(h.pageOptions(i)),
    ),
    fetchChatRoomInfoFromServer: fetchChatRoomInfo,
    getChatRoom: async (m, i) => h.normalizeChatRoomSummary(await m.getChatRoom(h.roomId(i))),
    fetchChatRoomMembers: async (m, i) => h.normalizeChatRoomMembersResult(
      await m.getMemberList({ chatRoomId: h.roomId(i), pageSize: h.pageSize(i), cursor: i.cursor || "" }),
    ),
    fetchChatRoomMuteList: async (m, i) => h.normalizeChatRoomUserIdList(
      await m.getMuteList({ chatRoomId: h.roomId(i) }),
    ),
    fetchChatRoomBlockList: async (m, i) => h.normalizeChatRoomUserIdList(
      await m.getBlocklist({ chatRoomId: h.roomId(i) }),
    ),
    fetchChatRoomWhiteListFromServer: async (m, i) => h.normalizeChatRoomUserIdList(
      await m.getAllowlist({ chatRoomId: h.roomId(i) }),
    ),
    isMemberInChatRoomMuteList: (m, i) => m.checkIfInMuteList({ chatRoomId: h.roomId(i), userId: h.userId(i) }),
    isMemberInChatRoomWhiteListFromServer: (m, i) => m.checkIfInAllowList({ chatRoomId: h.roomId(i), userId: h.userId(i) }),
    joinChatRoom,
    leaveChatRoom: (m, i) => m.leaveChatRoom({ chatRoomId: h.roomId(i) }),
    muteAllChatRoomMembers: (m, i) => m.muteAllMembers({ chatRoomId: h.roomId(i) }),
    unMuteAllChatRoomMembers: (m, i) => m.unmuteAllMembers({ chatRoomId: h.roomId(i) }),
    muteChatRoomMembers: (m, i) => m.muteMembers({
      chatRoomId: h.roomId(i), userIds: h.members(i), duration: i.duration ?? i.muteDuration,
    }),
    unMuteChatRoomMembers: (m, i) => m.unmuteMembers({ chatRoomId: h.roomId(i), userIds: h.members(i) }),
    blockChatRoomMembers: (m, i) => m.blockMembers({ chatRoomId: h.roomId(i), userIds: h.members(i) }),
    unBlockChatRoomMembers: (m, i) => m.unblockMembers({ chatRoomId: h.roomId(i), userIds: h.members(i) }),
    removeChatRoomMembers: (m, i) => m.removeMembers({ chatRoomId: h.roomId(i), userIds: h.members(i) }),
    addMembersToChatRoomWhiteList: (m, i) => m.addUsersToAllowlist({ chatRoomId: h.roomId(i), userIds: h.members(i) }),
    removeMembersFromChatRoomWhiteList: (m, i) => m.removeUsersFromAllowlist({ chatRoomId: h.roomId(i), userIds: h.members(i) }),
    addChatRoomAdmin: (m, i) => m.addAdmin({ chatRoomId: h.roomId(i), userId: h.userId(i) }),
    removeChatRoomAdmin: (m, i) => m.removeAdmin({ chatRoomId: h.roomId(i), userId: h.userId(i) }),
    fetchChatRoomAllAttributesFromServer: fetchChatRoomAttributes,
    fetchChatRoomAttributes,
    setChatRoomAttributes: (m, i) => m.setAttributes({ chatRoomId: h.roomId(i), attributes: i.attributes || {} }),
    removeChatRoomAttributes: (m, i) => m.removeAttributes({ chatRoomId: h.roomId(i), keys: i.keys || [] }),
    removeChatRoomAttributeFromServer: (m, i) => m.removeAttributes({ chatRoomId: h.roomId(i), keys: [String(i.attribute || i.key || "")] }),
    removeChatRoomAttributeFromServerForced: (m, i) => m.removeAttributes({ chatRoomId: h.roomId(i), keys: [String(i.attribute || i.key || "")] }),
    updateChatRoomAnnouncement: (m, i) => m.updateAnnouncement({ chatRoomId: h.roomId(i), announcement: String(i.announcement || "") }),
    fetchChatRoomAnnouncement: async (m, i) => {
      const result = await m.getAnnouncement({ chatRoomId: h.roomId(i) });
      return result?.announcement ?? result;
    },
    changeChatRoomSubject: (m, i) => m.updateChatRoomInfo({
      chatRoomId: h.roomId(i),
      name: i.subject ?? i.name ?? "",
    }),
    changeChatRoomDescription: (m, i) => m.updateChatRoomInfo({ chatRoomId: h.roomId(i), description: i.description || "" }),
    // Web 5.0 exposes no native ChatRoomManager owner-transfer API. Keep this
    // explicit so it is not mistaken for updateChatRoomInfo support.
    changeChatRoomOwner: () => {
      throw new Error("Web 5.0 ChatRoomManager.changeChatRoomOwner is not supported by the native Web SDK");
    },
  };

  function registerManagerEvents() {
    registerEvents(manager, [
      ["onChatRoomDestroyed", (payload) => emit("onRoomDestroyed", h.normalizeChatRoomEvent(payload))],
      ["onMembersJoined", (payload) => emit("onRoomMemberJoined", h.normalizeChatRoomEvent(payload))],
      ["onMembersExited", (payload) => emit("onRoomMemberExited", h.normalizeChatRoomEvent(payload))],
      ["onRemovedFromChatRoom", (payload) => emit("onRoomRemoved", h.normalizeChatRoomEvent(payload))],
      ["onMuteListAdded", (payload) => emit("onRoomMuteListAdded", h.normalizeChatRoomEvent(payload))],
      ["onMuteListRemoved", (payload) => emit("onRoomMuteListRemoved", h.normalizeChatRoomEvent(payload))],
      ["onAllowListAdded", (payload) => emit("onRoomWhiteListAdded", h.normalizeChatRoomEvent(payload))],
      ["onAllowListRemoved", (payload) => emit("onRoomWhiteListRemoved", h.normalizeChatRoomEvent(payload))],
      ["onAllMemberMuteStateChanged", (payload) => emit("onRoomAllMemberMuteStateChanged", h.normalizeChatRoomEvent(payload))],
      ["onAdminAdded", (payload) => emit("onRoomAdminAdded", h.normalizeChatRoomEvent(payload))],
      ["onAdminRemoved", (payload) => emit("onRoomAdminRemoved", h.normalizeChatRoomEvent(payload))],
      ["onOwnerChanged", (payload) => emit("onRoomOwnerChanged", h.normalizeChatRoomEvent(payload))],
      ["onAnnouncementChanged", (payload) => emit("onRoomAnnouncementChanged", h.normalizeChatRoomEvent(payload))],
      ["onChatRoomInfoChanged", (payload) => emit("onRoomSpecificationChanged", h.normalizeChatRoomEvent(payload))],
      ["onAttributesUpdate", (payload) => emit("onRoomAttributesDidUpdated", h.normalizeChatRoomEvent(payload))],
      ["onAttributesRemoved", (payload) => emit("onRoomAttributesDidRemoved", h.normalizeChatRoomEvent(payload))],
    ]);
  }

  return { commands, registerManagerEvents };
}
