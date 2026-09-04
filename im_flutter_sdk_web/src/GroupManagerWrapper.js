/** Web 5.0 GroupManager adapter and group event registration. */
export function createGroupManagerWrapper({ manager, emit, registerEvents, h, currentUser }) {
  const resolveMemberUserId = (info) => {
    const userId = h.userId(info);
    if (userId) return userId;
    return typeof currentUser === "function" ? String(currentUser() || "") : "";
  };

  const commands = {
    getJoinedGroups: (m, i) => m.getJoinedGroupList(i),
    getJoinedGroupList: (m, i) => m.getJoinedGroupList(i),
    getGroupMemberListFromServer: (m, i) => m.getGroupMemberList(i),
    getGroupMemberList: (m, i) => m.getGroupMemberList(i),
    getGroupWithId: (m, i) => h.jsonSafe(m.getGroup(h.groupId(i))),
    getGroup: (m, i) => h.jsonSafe(m.getGroup(h.groupId(i))),
    createGroup: (m, i) => {
      const options = i.options && typeof i.options === "object" ? i.options : {};
      return m.createGroup({
        name: String(i.groupName ?? i.name ?? ""),
        description: String(i.description ?? i.desc ?? ""),
        memberIds: i.members || i.memberIds || i.inviteMembers || [],
        public: Boolean(i.isPublic ?? options.isPublic),
        joinApprovalRequired: Boolean(i.joinApprovalRequired ?? options.joinApprovalRequired),
        allowInvites: Boolean(i.allowInvites ?? options.allowInvites),
        inviteNeedConfirm: Boolean(i.inviteNeedConfirm ?? options.inviteNeedConfirm),
        maxMembers: i.maxCount ?? options.maxCount,
        ext: i.ext ?? options.ext,
      });
    },
    acceptInvitationFromGroup: (m, i) => m.acceptInvitation({ groupId: h.groupId(i), invitee: h.userId(i) }),
    acceptJoinApplication: (m, i) => m.acceptGroupJoinRequest({ groupId: h.groupId(i), userId: h.userId(i) }),
    addAdmin: (m, i) => m.addGroupAdmin({ groupId: h.groupId(i), userId: h.userId(i) }),
    addWhiteList: (m, i) => m.addUsersToGroupAllowlist({ groupId: h.groupId(i), userIds: h.members(i) }),
    blockMembers: (m, i) => m.blockGroupMembers({ groupId: h.groupId(i), userIds: h.members(i) }),
    blockUser: (m, i) => m.blockGroupMembers({ groupId: h.groupId(i), userIds: [h.userId(i)] }),
    declineInvitationFromGroup: (m, i) => m.rejectInvitation({ groupId: h.groupId(i), invitee: h.userId(i) }),
    declineJoinApplication: (m, i) => m.rejectGroupJoinRequest({ groupId: h.groupId(i), userId: h.userId(i) }),
    downloadGroupSharedFile: (m, i) => m.downloadGroupSharedFile(i),
    fetchGroupBlackList: (m, i) => m.getGroupBlocklist({ groupId: h.groupId(i), pageSize: h.pageSize(i), cursor: i.cursor || "" }),
    fetchGroupMembersInfo: (m, i) => m.getGroupMemberList({ groupId: h.groupId(i), pageSize: h.pageSize(i), cursor: i.cursor || "" }),
    fetchMemberAttributesFromGroup: (m, i) => m.getGroupMembersAttributes({ groupId: h.groupId(i), userIds: [resolveMemberUserId(i)] }),
    fetchMembersAttributesFromGroup: (m, i) => m.getGroupMembersAttributes({ groupId: h.groupId(i), userIds: h.members(i) }),
    fetchMemberAllAttributes: (m, i) => m.getGroupMembersAttributes({ groupId: h.groupId(i), userIds: h.members(i) }),
    getGroupAnnouncementFromServer: (m, i) => m.getGroupAnnouncement({ groupId: h.groupId(i) }),
    getGroupBlockListFromServer: (m, i) => m.getGroupBlocklist({ groupId: h.groupId(i), pageSize: h.pageSize(i), cursor: i.cursor || "" }),
    getGroupFileListFromServer: (m, i) => m.getGroupSharedFileList({ groupId: h.groupId(i), pageSize: h.pageSize(i), cursor: i.cursor || "" }),
    getGroupMuteListFromServer: (m, i) => m.getGroupMuteList({ groupId: h.groupId(i), pageSize: h.pageSize(i), cursor: i.cursor || "" }),
    getGroupWhiteListFromServer: (m, i) => m.getGroupAllowlist({ groupId: h.groupId(i), pageSize: h.pageSize(i), cursor: i.cursor || "" }),
    inviterUser: (m, i) => m.inviteUsersToGroup({ groupId: h.groupId(i), userIds: h.members(i), welcomeMessage: i.message }),
    isMemberInGroupMuteList: (m, i) => m.checkIfInGroupMuteList({ groupId: h.groupId(i), userId: h.userId(i) }),
    isMemberInWhiteListFromServer: (m, i) => m.checkIfInGroupAllowList({ groupId: h.groupId(i), userId: h.userId(i) }),
    joinPublicGroup: (m, i) => m.joinGroup({ groupId: h.groupId(i), message: i.message }),
    joinGroup: (m, i) => m.joinGroup({ groupId: h.groupId(i), message: i.message }),
    leaveGroup: (m, i) => m.leaveGroup({ groupId: h.groupId(i) }),
    destroyGroup: (m, i) => m.destroyGroup({ groupId: h.groupId(i) }),
    addMembers: (m, i) => m.inviteUsersToGroup({ groupId: h.groupId(i), userIds: h.members(i) }),
    removeMembers: (m, i) => m.removeGroupMembers({ groupId: h.groupId(i), userIds: h.members(i) }),
    getGroupSpecificationFromServer: (m, i) => m.getGroupInfo({ groupId: h.groupId(i) }),
    muteAllMembers: (m, i) => m.muteAllGroupMembers({ groupId: h.groupId(i) }),
    muteMembers: (m, i) => m.muteGroupMembers({ groupId: h.groupId(i), userIds: h.members(i) }),
    removeAdmin: (m, i) => m.removeGroupAdmin({ groupId: h.groupId(i), userId: h.userId(i) }),
    removeGroupSharedFile: (m, i) => m.deleteGroupSharedFile({ groupId: h.groupId(i), fileId: String(i.fileId || i.id) }),
    removeUserFromGroup: (m, i) => m.removeGroupMembers({ groupId: h.groupId(i), userIds: [h.userId(i)] }),
    removeWhiteList: (m, i) => m.removeUsersFromGroupAllowlist({ groupId: h.groupId(i), userIds: h.members(i) }),
    requestToJoinPublicGroup: (m, i) => m.joinGroup({ groupId: h.groupId(i), message: i.message }),
    setMemberAttributesFromGroup: (m, i) => m.setGroupMemberAttributes({ groupId: h.groupId(i), userId: resolveMemberUserId(i), attributes: i.attributes || {} }),
    unMuteAllMembers: (m, i) => m.unmuteAllGroupMembers({ groupId: h.groupId(i) }),
    unMuteMembers: (m, i) => m.unmuteGroupMembers({ groupId: h.groupId(i), userIds: h.members(i) }),
    unblockMembers: (m, i) => m.unblockGroupMembers({ groupId: h.groupId(i), userIds: h.members(i) }),
    unblockUser: (m, i) => m.unblockGroupMembers({ groupId: h.groupId(i), userIds: [h.userId(i)] }),
    updateDescription: (m, i) => m.updateGroupInfo({ groupId: h.groupId(i), description: i.description || "" }),
    updateGroupAnnouncement: (m, i) => m.updateGroupAnnouncement({ groupId: h.groupId(i), announcement: i.announcement || "" }),
    updateGroupAvatar: (m, i) => m.updateGroupInfo({ groupId: h.groupId(i), avatar: i.avatar || i.avatarUrl || "" }),
    updateGroupConfigs: (m, i) => m.updateGroupInfo({ groupId: h.groupId(i), ...i.configs }),
    updateGroupExt: (m, i) => m.updateGroupInfo({ groupId: h.groupId(i), ext: i.ext || "" }),
    updateGroupExtension: (m, i) => m.updateGroupInfo({ groupId: h.groupId(i), ext: i.ext || "" }),
    updateGroupOwner: (m, i) => m.changeGroupOwner({ groupId: h.groupId(i), newOwner: h.userId(i) }),
    updateGroupSubject: (m, i) => m.updateGroupInfo({ groupId: h.groupId(i), name: i.subject || i.name || "" }),
    uploadGroupSharedFile: (m, i) => m.uploadGroupSharedFile(i),
  };

  function registerManagerEvents() {
    registerEvents(manager, [
      ["onInvitationReceived", (payload) => emit("onGroupInvitationReceived", h.normalizeGroupEvent(payload))],
      ["onRequestToJoinReceived", (payload) => emit("onGroupRequestToJoinReceived", h.normalizeGroupEvent(payload))],
      ["onRequestToJoinAccepted", (payload) => emit("onGroupRequestToJoinAccepted", h.normalizeGroupEvent(payload))],
      ["onRequestToJoinDeclined", (payload) => emit("onGroupRequestToJoinDeclined", h.normalizeGroupEvent(payload))],
      ["onInvitationAccepted", (payload) => emit("onGroupInvitationAccepted", h.normalizeGroupEvent(payload))],
      ["onInvitationDeclined", (payload) => emit("onGroupInvitationDeclined", h.normalizeGroupEvent(payload))],
      ["onUserRemoved", (payload) => emit("onGroupUserRemoved", h.normalizeGroupEvent(payload))],
      ["onGroupDestroyed", (payload) => emit("onGroupDestroyed", h.normalizeGroupEvent(payload))],
      ["onAutoAcceptInvitationFromGroup", (payload) => emit("onGroupAutoAcceptInvitation", h.normalizeGroupEvent(payload))],
      ["onMuteListAdded", (payload) => emit("onGroupMuteListAdded", h.normalizeGroupEvent(payload))],
      ["onMuteListRemoved", (payload) => emit("onGroupMuteListRemoved", h.normalizeGroupEvent(payload))],
      ["onAllowListAdded", (payload) => emit("onGroupWhiteListAdded", h.normalizeGroupEvent(payload))],
      ["onAllowListRemoved", (payload) => emit("onGroupWhiteListRemoved", h.normalizeGroupEvent(payload))],
      ["onAllMemberMuteStateChanged", (payload) => emit("onGroupAllMemberMuteStateChanged", h.normalizeGroupEvent(payload))],
      ["onAdminAdded", (payload) => emit("onGroupAdminAdded", h.normalizeGroupEvent(payload))],
      ["onAdminRemoved", (payload) => emit("onGroupAdminRemoved", h.normalizeGroupEvent(payload))],
      ["onOwnerChanged", (payload) => emit("onGroupOwnerChanged", h.normalizeGroupEvent(payload))],
      ["onMembersJoined", (payload) => emit("onGroupMembersJoined", h.normalizeGroupEvent(payload))],
      ["onMembersExited", (payload) => emit("onGroupMembersExited", h.normalizeGroupEvent(payload))],
      ["onAnnouncementChanged", (payload) => emit("onGroupAnnouncementChanged", h.normalizeGroupEvent(payload))],
      ["onSharedFileAdded", (payload) => emit("onGroupSharedFileAdded", h.normalizeGroupEvent(payload))],
      ["onSharedFileDeleted", (payload) => emit("onGroupSharedFileDeleted", h.normalizeGroupEvent(payload))],
      ["onGroupInfoChanged", (payload) => emit("onGroupSpecificationDidUpdate", h.normalizeGroupEvent(payload))],
      ["onGroupDisabledChanged", (payload) => emit("onGroupStateChanged", h.normalizeGroupEvent(payload))],
      ["onGroupMemberAttributeChanged", (payload) => emit("onGroupAttributesChangedOfMember", h.normalizeGroupEvent(payload))],
      ["onUserGroupNamecardUpdated", (payload) => emit("onUserGroupNamecardUpdated", h.normalizeGroupEvent(payload))],
    ]);
  }

  return { commands, registerManagerEvents };
}
