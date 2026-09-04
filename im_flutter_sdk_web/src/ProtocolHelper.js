function extractMessages(payload) {
  if (Array.isArray(payload)) return payload;
  if (Array.isArray(payload?.messages)) return payload.messages;
  if (payload?.message) return Array.isArray(payload.message) ? payload.message : [payload.message];
  return payload ? [payload] : [];
}

function canonicalWeb5Message(raw) {
  if (!raw || typeof raw !== "object" || Array.isArray(raw)) return raw;
  const normalized = { ...jsonSafe(raw) };
  const body = normalized.body;
  if (normalized.msgId == null && normalized.msgServerId != null) normalized.msgId = String(normalized.msgServerId);
  if (normalized.msgId == null && normalized.messageId != null) normalized.msgId = String(normalized.messageId);
  if (normalized.from == null && normalized.sender?.userId != null) normalized.from = String(normalized.sender.userId);
  if (normalized.convId == null && normalized.conversationId != null) normalized.convId = String(normalized.conversationId);
  if (normalized.chatType == null && normalized.conversationType != null) normalized.chatType = numericChatType(normalized.conversationType);
  if (normalized.isThread == null && typeof normalized.isChatThread === "boolean") normalized.isThread = normalized.isChatThread;
  if (body && typeof body === "object" && !Array.isArray(body) && body.type == null) {
    if (body.bodyType != null) body.type = body.bodyType;
  }
  return normalized;
}

function normalizeWeb5Reaction(raw, currentUser) {
  const items = Array.isArray(raw) ? raw : [raw];
  return {
    events: items.filter(Boolean).map((event) => {
      if (!event || typeof event !== "object" || Array.isArray(event)) return event;
      const result = { ...jsonSafe(event) };
      if (result.convId == null && result.conversationId != null) result.convId = result.conversationId;
      if (result.msgId == null && result.messageId != null) result.msgId = result.messageId;
      const operations = result.operations;
      if (Array.isArray(operations)) {
        result.operations = operations.map((item) => {
          if (!item || typeof item !== "object" || Array.isArray(item)) return item;
          const operation = { ...item };
          if (operation.userId == null && operation.operator != null) operation.userId = operation.operator;
          if (operation.operate == null && operation.reactionType != null) {
            operation.operate = operation.reactionType === "delete" ? 0 : 1;
          }
          return operation;
        });
      }
      if (Array.isArray(result.reactions)) {
        result.reactions = result.reactions.map((item) => {
          if (!item || typeof item !== "object" || Array.isArray(item)) return item;
          const reaction = { ...item };
          if (reaction.userList == null && Array.isArray(reaction.users)) reaction.userList = reaction.users;
          if (reaction.isAddedBySelf == null && Array.isArray(reaction.userList) && currentUser != null) {
            reaction.isAddedBySelf = reaction.userList.map(String).includes(String(currentUser));
          }
          return reaction;
        });
      }
      return result;
    }),
  };
}

function historyOptions(info) {
  const direction = info.searchDirection;
  const searchDirection = direction === 1 || direction === "down"
    ? "down"
    : "up";
  return { conversationId: String(info.convId || info.conversationId), conversationType: conversationType(info.chatType || info.conversationType), cursor: String(info.cursor || ""), pageSize: Number(info.pageSize || 20), searchDirection };
}

function unreadOptions(info) { return { conversationId: String(info.convId || info.conversationId), conversationType: conversationType(info.chatType || info.conversationType) }; }
function groupOptions(info) { return { name: String(info.groupName || info.name || ""), description: info.description, memberIds: info.members || info.memberIds || [], isPublic: Boolean(info.isPublic), joinApprovalRequired: Boolean(info.joinApprovalRequired), allowInvites: Boolean(info.allowInvites) }; }
function bodyType(body) {
  const value = body?.type;
  if (value === 0 || value === "txt" || value === "text") return 0;
  if (value === 1 || value === "image") return 1;
  if (value === 2 || value === "video") return 2;
  if (value === 3 || value === "location") return 3;
  if (value === 4 || value === "voice") return 4;
  if (value === 5 || value === "file") return 5;
  if (value === 6 || value === "cmd" || value === "command") return 6;
  if (value === 7 || value === "custom") return 7;
  if (value === 8 || value === "combine") return 8;
  return Number(value || 0);
}
function webMessageType(body) { return bodyType(body) === 7 ? "custom" : "text"; }
function conversationType(value) { return Number(value) === 1 ? "groupChat" : Number(value) === 2 ? "chatRoom" : value === "groupChat" || value === "chatRoom" ? value : "singleChat"; }
function numericChatType(value) { return value === "groupChat" ? 1 : value === "chatRoom" ? 2 : 0; }
function jsonSafe(value) { if (value == null) return value; try { return JSON.parse(JSON.stringify(value)); } catch { return String(value); } }
function normalizeRecallEvent(payload) {
  const value = payload?.infos || payload?.recallInfos || payload?.messages || payload;
  const infos = Array.isArray(value) ? value : value ? [value] : [];
  return { infos: jsonSafe(infos) };
}

function pageSize(info) {
  const value = info?.pageSize ?? info?.limit;
  return Number(value ?? 20);
}
function pageOptions(info) {
  return {
    pageSize: pageSize(info),
    cursor: String(info.cursor || ""),
    pageNum: Number(info.pageNum ?? info.pageNo ?? 1),
  };
}
function conversationListOptions(info) {
  const options = {};
  if (typeof info?.isPinned === "boolean") options.isPinned = info.isPinned;
  if (Number.isInteger(info?.mark)) options.mark = info.mark;
  return options;
}
function protocolConversationType(info) {
  return conversationType(info?.chatType ?? info?.conversationType ?? info?.type);
}
function reactionListOptions(info) {
  const configuredIds = info?.msgIds ?? info?.messageIds;
  const messageId = configuredIds != null
    ? (Array.isArray(configuredIds) ? configuredIds.map(String) : String(configuredIds))
    : String(info?.msgId ?? info?.messageId ?? "");
  const options = {
    messageId,
    conversationType: protocolConversationType(info),
  };
  const groupId = info?.groupId ?? info?.group_id;
  if (groupId != null) options.groupId = String(groupId);
  return options;
}
function reactionDetailOptions(info) {
  const options = {
    messageId: String(info?.msgId ?? info?.messageId ?? ""),
    reaction: String(info?.reaction ?? ""),
  };
  if (info?.cursor != null) options.cursor = String(info.cursor);
  if (info?.pageSize != null || info?.limit != null) options.pageSize = pageSize(info);
  return options;
}
function normalizeReactionListResult(value) {
  if (!Array.isArray(value)) return value;
  const result = {};
  for (const item of value) {
    if (!item || typeof item !== "object" || Array.isArray(item)) continue;
    const messageId = item.messageId ?? item.msgId;
    if (messageId == null) continue;
    result[String(messageId)] = jsonSafe(item.reactions ?? item.reactionList ?? []);
  }
  return result;
}
function roomId(info) { return String(info.chatRoomId || info.roomId || info.id || ""); }
function normalizeChatRoomUserIdList(value) {
  const items = Array.isArray(value) ? value : [];
  return items.map((item) => {
    if (typeof item === "string") return item;
    const user = item?.user && typeof item.user === "object" ? item.user : item;
    return user?.userId ?? user?.username ?? user?.id ?? "";
  }).filter(Boolean).map(String);
}
function normalizeChatRoomPermissionType(value) {
  if (typeof value === "number") return value;
  switch (value) {
    case "none": return -1;
    case "member": return 0;
    case "admin": return 1;
    case "owner": return 2;
    default: return value;
  }
}
function normalizeChatRoomJoinResult(value) {
  const result = jsonSafe(value);
  if (result == null || typeof result !== "object" || Array.isArray(result)) return result;

  // Web 5.0's native join ACK uses names that differ from the common
  // Android/iOS protocol. These are real ACK fields; only roomId is carried
  // when the Web native ACK actually provides the corresponding field.
  const normalized = { ...result };
  if (normalized.roomId == null && result.chatRoomId != null) {
    normalized.roomId = result.chatRoomId;
  }
  if (normalized.isAllMemberMuted == null && typeof result.isAllMembersMuted === "boolean") {
    normalized.isAllMemberMuted = result.isAllMembersMuted;
  }
  if (normalized.isInWhitelist == null && typeof result.isInAllowlist === "boolean") {
    normalized.isInWhitelist = result.isInAllowlist;
  }
  return normalized;
}
function normalizeChatRoomSummary(value) {
  if (!value || typeof value !== "object" || Array.isArray(value)) return value;
  const source = value;
  const normalized = { ...source };

  const rename = (target, aliases, transform = (item) => item) => {
    if (Object.prototype.hasOwnProperty.call(source, target)) {
      normalized[target] = transform(source[target]);
      return;
    }
    const alias = aliases.find((key) => Object.prototype.hasOwnProperty.call(source, key));
    if (alias) {
      normalized[target] = transform(source[alias]);
      delete normalized[alias];
    }
  };

  rename("roomId", ["chatRoomId"], (item) => String(item));
  rename("owner", [], (item) => {
    if (!item || typeof item !== "object") return item;
    return item.userId ?? item.username ?? item.id ?? item;
  });
  rename("maxUsers", ["maxMembers"]);
  rename("permissionType", ["role"], normalizeChatRoomPermissionType);
  rename("isAllMemberMuted", ["isAllMembersMuted", "muteAllMembers"]);
  rename("memberCount", ["affiliations_count"]);
  rename("createTimestamp", ["createdAt"]);
  rename("isInWhitelist", ["inAllowlist"]);
  rename("desc", ["description"]);

  for (const key of ["adminList", "memberList", "muteList", "blockList"]) {
    if (Object.prototype.hasOwnProperty.call(normalized, key)) {
      normalized[key] = normalizeChatRoomUserIdList(normalized[key]);
    }
  }
  return normalized;
}
function normalizeChatRoomPageResult(value) {
  if (!value || typeof value !== "object" || Array.isArray(value)) return value;
  const source = value;
  const normalized = { ...source };
  if (!Object.prototype.hasOwnProperty.call(source, "list") && Array.isArray(source.items)) {
    normalized.list = source.items;
    delete normalized.items;
  }
  if (Array.isArray(normalized.list)) {
    normalized.list = normalized.list.map(normalizeChatRoomSummary);
  }
  if (!Object.prototype.hasOwnProperty.call(source, "count") && Object.prototype.hasOwnProperty.call(source, "total")) {
    normalized.count = source.total;
    delete normalized.total;
  }
  return normalized;
}
function normalizeChatRoomMembersResult(value) {
  if (!value || typeof value !== "object" || Array.isArray(value)) return value;
  const source = value;
  const normalized = { ...source };
  if (!Object.prototype.hasOwnProperty.call(source, "list") && Array.isArray(source.items)) {
    normalized.list = source.items;
    delete normalized.items;
  }
  if (Array.isArray(normalized.list)) {
    normalized.list = normalizeChatRoomUserIdList(normalized.list);
  }
  return normalized;
}
function normalizeChatRoomEvent(value) {
  const source = jsonSafe(value);
  if (!source || typeof source !== "object" || Array.isArray(source)) return source;
  const normalized = { ...source };
  if (normalized.roomId == null && normalized.chatRoomId != null) normalized.roomId = normalized.chatRoomId;
  if (normalized.roomName == null && normalized.chatRoomName != null) normalized.roomName = normalized.chatRoomName;
  if (normalized.members == null && Array.isArray(normalized.allowlist)) {
    normalized.members = normalized.allowlist
      .map((item) => typeof item === "string" ? item : item?.user?.userId ?? item?.userId ?? item?.username ?? item?.id)
      .filter(Boolean)
      .map(String);
  }
  if (normalized.room == null && normalized.chatRoomInfo && typeof normalized.chatRoomInfo === "object") {
    normalized.room = {
      ...normalized.chatRoomInfo,
      roomId: normalized.chatRoomInfo.roomId ?? normalized.chatRoomInfo.chatRoomId ?? normalized.chatRoomId,
    };
  }
  if (normalized.room && typeof normalized.room === "object" && !Array.isArray(normalized.room)) {
    normalized.room = normalizeChatRoomSummary(normalized.room);
  }
  for (const key of ["from", "participant", "admin", "newOwner", "oldOwner"]) {
    const item = normalized[key];
    if (item && typeof item === "object" && !Array.isArray(item)) {
      const userId = item.userId ?? item.username ?? item.id;
      if (userId != null) normalized[key] = String(userId);
    }
  }
  if (Array.isArray(normalized.mutes)) {
    normalized.mutes = normalized.mutes.map((item) => {
      if (typeof item === "string") return item;
      return String(item?.user?.userId ?? item?.userId ?? item?.username ?? item?.id ?? item);
    });
  }
  if (normalized.removedKeys == null && Array.isArray(normalized.keyList)) {
    normalized.removedKeys = normalized.keyList;
  }
  if (normalized.keys == null && Array.isArray(normalized.keyList)) {
    normalized.keys = normalized.keyList;
  }
  return normalized;
}
function normalizeGroupEvent(value) {
  const source = jsonSafe(value);
  if (!source || typeof source !== "object" || Array.isArray(source)) return source;
  const normalized = { ...source };
  if (normalized.groupId == null && normalized.group && typeof normalized.group === "object") {
    normalized.groupId = normalized.group.groupId ?? normalized.group.id;
  }
  for (const key of ["userIds", "members", "mutes", "allowlist", "adminList"]) {
    if (Array.isArray(normalized[key])) normalized[key] = normalizeChatRoomUserIdList(normalized[key]);
  }
  for (const key of ["operator", "user", "owner", "newOwner", "oldOwner"]) {
    const item = normalized[key];
    if (item && typeof item === "object" && !Array.isArray(item)) {
      normalized[key] = item.userId ?? item.username ?? item.id ?? item;
    }
  }
  if (normalized.sharedFile && typeof normalized.sharedFile === "object") {
    const sharedFile = { ...normalized.sharedFile };
    if (sharedFile.fileName == null && sharedFile.name != null) {
      sharedFile.fileName = sharedFile.name;
      delete sharedFile.name;
    }
    if (sharedFile.owner && typeof sharedFile.owner === "object") {
      sharedFile.owner = sharedFile.owner.userId ?? sharedFile.owner.username ?? sharedFile.owner.id ?? sharedFile.owner;
    }
    normalized.sharedFile = sharedFile;
  }
  return normalized;
}
function groupId(info) { return String(info.groupId || info.id || ""); }
function userId(info) {
  return String(
    info.userId
      || info.username
      || info.member
      || info.operator
      || info.admin
      || info.newOwner
      || info.owner
      || info.targetUserId
      || "",
  );
}
function userIds(info) {
  const values = info?.userIds || info?.usernames || info?.ids || [];
  return Array.isArray(values) ? values.map(String) : [String(values)];
}
function members(info) {
  return (
    info.members
      || info.userIds
      || info.usernames
      || info.muteMembers
      || info.unMuteMembers
      || info.blockMembers
      || info.unBlockMembers
      || info.removeMembers
      || []
  );
}
function contactUserIds(contacts) {
  return (Array.isArray(contacts) ? contacts : [])
    .map((contact) => typeof contact === "string" ? contact : contact?.userId)
    .filter(Boolean)
    .map(String);
}
function normalizeContactEvent(payload, includeReason = false) {
  if (!payload || typeof payload !== "object" || Array.isArray(payload)) return payload;
  const result = { ...jsonSafe(payload) };
  if (result.userId == null) {
    const userId = result.from ?? result.to ?? result.userInfo?.userId;
    if (userId != null) result.userId = String(userId);
  }
  if (includeReason && result.reason == null) {
    const reason = result.inviteMessage ?? result.message;
    if (reason != null) result.reason = reason;
  }
  return result;
}
function userInfoMap(profiles, requestedIds = []) {
  const result = Object.fromEntries(
    (Array.isArray(profiles) ? profiles : [])
      .filter((profile) => profile && profile.userId)
      .map((profile) => [String(profile.userId), normalizeUserInfoProfile(profile)]),
  );
  return result;
}
const USER_INFO_ATTRIBUTES = {
  0: "nickname",
  1: "avatarUrl",
  2: "mail",
  3: "phone",
  4: "gender",
  5: "sign",
  6: "birth",
  100: "ext",
};

function userInfoAttribute(value) {
  if (typeof value === "number" || (typeof value === "string" && /^\d+$/.test(value))) {
    return USER_INFO_ATTRIBUTES[Number(value)] || String(value);
  }
  return String(value || "");
}

function userInfoAttributes(info) {
  const values = info?.attributes || info?.userInfoTypes || info?.type || [];
  return (Array.isArray(values) ? values : [values]).map(userInfoAttribute);
}

function normalizeUserInfoInput(value) {
  const input = value && typeof value === "object" ? value : {};
  const output = { ...input };
  if (Object.prototype.hasOwnProperty.call(output, "nickName")) {
    output.nickname = output.nickName;
    delete output.nickName;
  }
  return output;
}

function normalizeUserInfoProfile(profile) {
  if (!profile || typeof profile !== "object") return profile;
  const output = { ...profile };
  if (!Object.prototype.hasOwnProperty.call(output, "nickName") && Object.prototype.hasOwnProperty.call(output, "nickname")) {
    output.nickName = output.nickname;
    delete output.nickname;
  }
  return output;
}

function normalizeUserInfoForTypeResult(profile) {
  if (!profile || typeof profile !== "object") return profile;
  const output = { ...profile };
  if (!Object.prototype.hasOwnProperty.call(output, "nickname") && Object.prototype.hasOwnProperty.call(output, "nickName")) {
    output.nickname = output.nickName;
    delete output.nickName;
  }
  return output;
}
function readReceiptOptions(info) {
  const messageId = String(info.msgId || info.messageId || "");
  const configuredMessageIds = info.msgIds || info.messageIds;
  const messageIds = Array.isArray(configuredMessageIds)
    ? configuredMessageIds.map(String)
    : messageId
      ? [messageId]
      : [];
  const conversationId = String(
    info.convId
      || info.conversationId
      || info.to
      || info.group_id
      || info.groupId
      || "",
  );
  const rawConversationType = info.chatType
    ?? info.conversationType
    ?? (info.group_id != null || info.groupId != null ? 1 : 0);
  return {
    conversationId,
    conversationType: conversationType(rawConversationType),
    messageIds,
  };
}
function groupReceiptOptions(info) {
  const configuredMessageIds = info.msgIds ?? info.messageIds;
  const messageId = info.msgId ?? info.messageId;
  const messageIds = Array.isArray(configuredMessageIds)
    ? configuredMessageIds.map(String)
    : messageId == null || String(messageId).length === 0
      ? []
      : [String(messageId)];
  return {
    messageIds,
    groupId: groupId(info),
  };
}
function conversationMarkOptions(info) {
  return {
    conversationId: String(info.convId || info.conversationId || ""),
    conversationType: conversationType(info.chatType || info.conversationType),
    mark: info.mark || info.markId || info.conversationMark,
  };
}
function historyDeleteOptions(info) {
  return {
    conversationId: String(info.convId || info.conversationId || ""),
    conversationType: protocolConversationType(info),
    beforeTimestamp: info.timestamp ?? info.ts,
  };
}
function downloadOptions(info) {
  return {
    messageId: String(info.msgId || info.messageId || ""),
    remoteUrl: info.remoteUrl || info.url,
    localPath: info.localPath || info.filePath,
    secretKey: info.secretKey,
    isThumbnail: Boolean(info.isThumbnail || info.thumbnail),
  };
}
function searchOptions(info) {
  return {
    conversationId: String(info.convId || info.conversationId || ""),
    conversationType: conversationType(info.chatType || info.conversationType),
    keywords: String(info.keyword || info.keywords || ""),
    pageSize: pageSize(info),
    cursor: String(info.cursor || ""),
    searchDirection: info.searchDirection,
  };
}
function pushConversation(info) {
  return {
    conversationId: String(info.convId || info.conversationId || ""),
    conversationType: conversationType(info.chatType || info.conversationType),
    rule: silentModeRule(info),
  };
}

function silentModeRule(info) {
  const source = info?.rule || info?.param || info?.silentMode || info?.silentModeParam || info || {};
  if (source.mode) return source;
  const paramType = Number(source.paramType ?? 0);
  if (paramType === 1) {
    return { mode: "DURATION", duration: Number(source.duration || 0) };
  }
  if (paramType === 2) {
    return {
      mode: "INTERVAL",
      startTime: silentModeTime(source.startTime),
      endTime: silentModeTime(source.endTime),
    };
  }
  return {
    mode: "REMIND_TYPE",
    remindType: remindTypeName(source.remindType),
  };
}

function remindTypeName(value) {
  if (value === "ALL" || value === "AT" || value === "NONE") return value;
  if (Number(value) === 1) return "AT";
  if (Number(value) === 2) return "NONE";
  return "ALL";
}

function silentModeTime(value) {
  const source = value || {};
  return {
    hours: Number(source.hours ?? source.hour ?? 0),
    minutes: Number(source.minutes ?? source.minute ?? 0),
  };
}

function silentModeConversationList(info) {
  if (Array.isArray(info?.conversationList)) return info.conversationList;
  const values = info?.conversationIds || info?.convIds;
  if (Array.isArray(values)) {
    return values.map((value) => ({
      conversationId: String(value),
      conversationType: "singleChat",
    }));
  }
  return Object.entries(info || {}).map(([conversationId, value]) => ({
    conversationId: String(conversationId),
    conversationType: conversationType(value),
  }));
}

function pushTokenOptions(info, notifierName = "") {
  return {
    deviceId: String(info.deviceId || "webim"),
    deviceToken: String(info.token || info.deviceToken || ""),
    notifierName: String(info.notifierName || notifierName || ""),
  };
}

function presenceUserIds(info) {
  const values = info?.members || info?.userIds || info?.usernames || [];
  return Array.isArray(values) ? values.map(String) : [String(values)];
}

function presenceSubscriptionOptions(info) {
  return {
    userIds: presenceUserIds(info),
    expiry: Number(info.expiry || 0),
  };
}

function normalizePresenceResults(results) {
  if (!Array.isArray(results)) return results;
  return results.map((item) => {
    if (!item || typeof item !== "object" || Array.isArray(item)) return item;
    const result = { ...jsonSafe(item) };
    if (result.statusDescription == null && result.ext != null) result.statusDescription = result.ext;
    if (result.publisher == null && result.uid != null) result.publisher = String(result.uid);
    if (result.expiryTime == null && result.expiry != null) result.expiryTime = result.expiry;
    if (result.statusDetails == null && result.statusList != null) result.statusDetails = result.statusList;
    if (result.lastTime == null && result.latestTime != null) result.lastTime = result.latestTime;
    return result;
  });
}

function normalizeSilentModeResult(value) {
  if (!value || typeof value !== "object" || Array.isArray(value)) return value;
  const raw = jsonSafe(value);
  const nested = raw.data && typeof raw.data === "object" && !Array.isArray(raw.data)
    ? raw.data
    : null;
  const result = nested ? { ...raw, ...nested } : { ...raw };
  if (result.convId == null && result.conversationId != null) result.convId = result.conversationId;
  if (result.conversationType == null && value.chatType != null) result.conversationType = value.chatType;
  if (typeof result.conversationType === "string") {
    result.conversationType = numericChatType(result.conversationType);
  }
  if (result.expireTs == null && result.expireTimestamp != null) {
    result.expireTs = Number(result.expireTimestamp);
  }
  if (result.startTime == null && result.silentModeStartTime != null) {
    result.startTime = silentModeResultTime(result.silentModeStartTime);
  }
  if (result.endTime == null && result.silentModeEndTime != null) {
    result.endTime = silentModeResultTime(result.silentModeEndTime);
  }
  if (result.remindType != null) result.remindType = remindTypeNumber(result.remindType);
  const rule = result.rule || result.silentModeRule;
  if (rule && typeof rule === "object" && !Array.isArray(rule)) {
    const normalizedRule = { ...rule };
    if (normalizedRule.expireTs == null && normalizedRule.expireTimestamp != null) {
      normalizedRule.expireTs = normalizedRule.expireTimestamp;
    }
    if (normalizedRule.startTime == null && normalizedRule.silentModeStartTime != null) {
      normalizedRule.startTime = normalizedRule.silentModeStartTime;
    }
    if (normalizedRule.endTime == null && normalizedRule.silentModeEndTime != null) {
      normalizedRule.endTime = normalizedRule.silentModeEndTime;
    }
    result.rule = normalizedRule;
    const expireTs = result.expireTs ?? normalizedRule.expireTs;
    if (expireTs != null) result.expireTs = Number(expireTs);
    const startTime = normalizedRule.startTime ?? result.startTime;
    if (startTime != null) result.startTime = silentModeResultTime(startTime);
    const endTime = normalizedRule.endTime ?? result.endTime;
    if (endTime != null) result.endTime = silentModeResultTime(endTime);
    const remindType = normalizedRule.remindType ?? normalizedRule.type ?? result.remindType;
    if (remindType != null) result.remindType = remindTypeNumber(remindType);
  }
  return result;
}

function silentModeResultTime(value) {
  const source = value || {};
  return {
    hour: Number(source.hour ?? source.hours ?? 0),
    minute: Number(source.minute ?? source.minutes ?? 0),
  };
}

function normalizeSilentModeConversations(value) {
  const result = {};
  for (const conversation of value?.conversations || []) {
    result[String(conversation.conversationId)] = normalizeSilentModeResult(conversation);
  }
  return result;
}

function remindTypeNumber(value) {
  if (value === "AT" || value === "MENTION_ONLY" || Number(value) === 1) return 1;
  if (value === "NONE" || Number(value) === 2) return 2;
  return 0;
}
function modifyOptions(info) {
  const source = info.message || {};
  return {
    conversationId: String(info.convId || info.conversationId || source.conversationId || ""),
    conversationType: conversationType(info.chatType || info.conversationType || source.conversationType),
    messageId: String(info.msgId || info.messageId || source.messageId || ""),
    message: {
      type: webMessageType(info.body || source.body || {}),
      body: info.body || source.body || {},
      ext: info.ext || source.ext,
    },
  };
}



export { extractMessages, canonicalWeb5Message, normalizeWeb5Reaction, historyOptions, unreadOptions, groupOptions, bodyType, webMessageType, conversationType, numericChatType, jsonSafe, normalizeRecallEvent, pageSize, pageOptions, conversationListOptions, protocolConversationType, reactionListOptions, reactionDetailOptions, normalizeReactionListResult, roomId, normalizeChatRoomJoinResult, normalizeChatRoomSummary, normalizeChatRoomPageResult, normalizeChatRoomMembersResult, normalizeChatRoomUserIdList, normalizeChatRoomEvent, normalizeGroupEvent, groupId, userId, userIds, members, contactUserIds, normalizeContactEvent, userInfoMap, userInfoAttribute, userInfoAttributes, normalizeUserInfoInput, normalizeUserInfoProfile, normalizeUserInfoForTypeResult, readReceiptOptions, groupReceiptOptions, conversationMarkOptions, historyDeleteOptions, downloadOptions, searchOptions, pushConversation, silentModeRule, remindTypeName, silentModeTime, silentModeConversationList, pushTokenOptions, presenceUserIds, presenceSubscriptionOptions, normalizePresenceResults, normalizeSilentModeResult, normalizeSilentModeConversations, remindTypeNumber, modifyOptions };
