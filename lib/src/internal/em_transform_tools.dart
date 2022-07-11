import 'inner_headers.dart';

EMMultiDevicesEvent? convertIntToEMMultiDevicesEvent(int? i) {
  switch (i) {
    case 2:
      return EMMultiDevicesEvent.CONTACT_REMOVE;
    case 3:
      return EMMultiDevicesEvent.CONTACT_ACCEPT;
    case 4:
      return EMMultiDevicesEvent.CONTACT_DECLINE;
    case 5:
      return EMMultiDevicesEvent.CONTACT_BAN;
    case 6:
      return EMMultiDevicesEvent.CONTACT_ALLOW;
    case 10:
      return EMMultiDevicesEvent.GROUP_CREATE;
    case 11:
      return EMMultiDevicesEvent.GROUP_DESTROY;
    case 12:
      return EMMultiDevicesEvent.GROUP_JOIN;
    case 13:
      return EMMultiDevicesEvent.GROUP_LEAVE;
    case 14:
      return EMMultiDevicesEvent.GROUP_APPLY;
    case 15:
      return EMMultiDevicesEvent.GROUP_APPLY_ACCEPT;
    case 16:
      return EMMultiDevicesEvent.GROUP_APPLY_DECLINE;
    case 17:
      return EMMultiDevicesEvent.GROUP_INVITE;
    case 18:
      return EMMultiDevicesEvent.GROUP_INVITE_ACCEPT;
    case 19:
      return EMMultiDevicesEvent.GROUP_INVITE_DECLINE;
    case 20:
      return EMMultiDevicesEvent.GROUP_KICK;
    case 21:
      return EMMultiDevicesEvent.GROUP_BAN;
    case 22:
      return EMMultiDevicesEvent.GROUP_ALLOW;
    case 23:
      return EMMultiDevicesEvent.GROUP_BLOCK;
    case 24:
      return EMMultiDevicesEvent.GROUP_UNBLOCK;
    case 25:
      return EMMultiDevicesEvent.GROUP_ASSIGN_OWNER;
    case 26:
      return EMMultiDevicesEvent.GROUP_ADD_ADMIN;
    case 27:
      return EMMultiDevicesEvent.GROUP_REMOVE_ADMIN;
    case 28:
      return EMMultiDevicesEvent.GROUP_ADD_MUTE;
    case 29:
      return EMMultiDevicesEvent.GROUP_REMOVE_MUTE;
    case 40:
      return EMMultiDevicesEvent.CHAT_THREAD_CREATE;
    case 41:
      return EMMultiDevicesEvent.CHAT_THREAD_DESTROY;
    case 42:
      return EMMultiDevicesEvent.CHAT_THREAD_JOIN;
    case 43:
      return EMMultiDevicesEvent.CHAT_THREAD_LEAVE;
    case 44:
      return EMMultiDevicesEvent.CHAT_THREAD_KICK;
    case 45:
      return EMMultiDevicesEvent.CHAT_THREAD_UPDATE;
  }
  return null;
}

String messageTypeToTypeStr(MessageType type) {
  switch (type) {
    case MessageType.TXT:
      return 'txt';
    case MessageType.LOCATION:
      return 'loc';
    case MessageType.CMD:
      return 'cmd';
    case MessageType.CUSTOM:
      return 'custom';
    case MessageType.FILE:
      return 'file';
    case MessageType.IMAGE:
      return 'img';
    case MessageType.VIDEO:
      return 'video';
    case MessageType.VOICE:
      return 'voice';
  }
}

int chatTypeToInt(ChatType type) {
  if (type == ChatType.ChatRoom) {
    return 2;
  } else if (type == ChatType.GroupChat) {
    return 1;
  } else {
    return 0;
  }
}

ChatType chatTypeFromInt(int? type) {
  if (type == 2) {
    return ChatType.ChatRoom;
  } else if (type == 1) {
    return ChatType.GroupChat;
  } else {
    return ChatType.Chat;
  }
}

int messageStatusToInt(MessageStatus status) {
  if (status == MessageStatus.FAIL) {
    return 3;
  } else if (status == MessageStatus.SUCCESS) {
    return 2;
  } else if (status == MessageStatus.PROGRESS) {
    return 1;
  } else {
    return 0;
  }
}

MessageStatus messageStatusFromInt(int? status) {
  if (status == 3) {
    return MessageStatus.FAIL;
  } else if (status == 2) {
    return MessageStatus.SUCCESS;
  } else if (status == 1) {
    return MessageStatus.PROGRESS;
  } else {
    return MessageStatus.CREATE;
  }
}

int downloadStatusToInt(DownloadStatus status) {
  if (status == DownloadStatus.DOWNLOADING) {
    return 0;
  } else if (status == DownloadStatus.SUCCESS) {
    return 1;
  } else if (status == DownloadStatus.FAILED) {
    return 2;
  } else {
    return 3;
  }
}

EMGroupPermissionType permissionTypeFromInt(int? type) {
  EMGroupPermissionType ret = EMGroupPermissionType.Member;
  switch (type) {
    case -1:
      {
        ret = EMGroupPermissionType.None;
      }
      break;
    case 0:
      {
        ret = EMGroupPermissionType.Member;
      }
      break;
    case 1:
      {
        ret = EMGroupPermissionType.Admin;
      }
      break;
    case 2:
      {
        ret = EMGroupPermissionType.Owner;
      }
      break;
  }
  return ret;
}

int permissionTypeToInt(EMGroupPermissionType? type) {
  int ret = 0;
  if (type == null) return ret;
  switch (type) {
    case EMGroupPermissionType.None:
      {
        ret = -1;
      }
      break;
    case EMGroupPermissionType.Member:
      {
        ret = 0;
      }
      break;
    case EMGroupPermissionType.Admin:
      {
        ret = 1;
      }
      break;
    case EMGroupPermissionType.Owner:
      {
        ret = 2;
      }
      break;
  }
  return ret;
}

EMGroupStyle groupStyleTypeFromInt(int? type) {
  EMGroupStyle ret = EMGroupStyle.PrivateOnlyOwnerInvite;
  switch (type) {
    case 0:
      {
        ret = EMGroupStyle.PrivateOnlyOwnerInvite;
      }
      break;
    case 1:
      {
        ret = EMGroupStyle.PrivateMemberCanInvite;
      }
      break;
    case 2:
      {
        ret = EMGroupStyle.PublicJoinNeedApproval;
      }
      break;
    case 3:
      {
        ret = EMGroupStyle.PublicOpenJoin;
      }
      break;
  }
  return ret;
}

int groupStyleTypeToInt(EMGroupStyle? type) {
  int ret = 0;
  if (type == null) return ret;
  switch (type) {
    case EMGroupStyle.PrivateOnlyOwnerInvite:
      {
        ret = 0;
      }
      break;
    case EMGroupStyle.PrivateMemberCanInvite:
      {
        ret = 1;
      }
      break;
    case EMGroupStyle.PublicJoinNeedApproval:
      {
        ret = 2;
      }
      break;
    case EMGroupStyle.PublicOpenJoin:
      {
        ret = 3;
      }
      break;
  }
  return ret;
}

EMChatRoomPermissionType chatRoomPermissionTypeFromInt(int? type) {
  EMChatRoomPermissionType ret = EMChatRoomPermissionType.Member;
  switch (type) {
    case -1:
      return EMChatRoomPermissionType.None;
    case 0:
      return EMChatRoomPermissionType.Member;
    case 1:
      return EMChatRoomPermissionType.Admin;
    case 2:
      return EMChatRoomPermissionType.Owner;
  }
  return ret;
}

int chatRoomPermissionTypeToInt(EMChatRoomPermissionType type) {
  int ret = 0;
  switch (type) {
    case EMChatRoomPermissionType.None:
      ret = -1;
      break;
    case EMChatRoomPermissionType.Member:
      ret = 0;
      break;
    case EMChatRoomPermissionType.Admin:
      ret = 1;
      break;
    case EMChatRoomPermissionType.Owner:
      ret = 2;
      break;
  }
  return ret;
}

int conversationTypeToInt(EMConversationType? type) {
  int ret = 0;
  if (type == null) return ret;
  switch (type) {
    case EMConversationType.Chat:
      ret = 0;
      break;
    case EMConversationType.GroupChat:
      ret = 1;
      break;
    case EMConversationType.ChatRoom:
      ret = 2;
      break;
  }
  return ret;
}

EMConversationType conversationTypeFromInt(int? type) {
  EMConversationType ret = EMConversationType.Chat;
  switch (type) {
    case 0:
      ret = EMConversationType.Chat;
      break;
    case 1:
      ret = EMConversationType.GroupChat;
      break;
    case 2:
      ret = EMConversationType.ChatRoom;
      break;
  }
  return ret;
}

int? chatSilentModeParamTypeToInt(ChatSilentModeParamType? type) {
  int? ret;
  if (type == null) {
    return ret;
  }
  switch (type) {
    case ChatSilentModeParamType.REMIND_TYPE:
      ret = 0;
      break;
    case ChatSilentModeParamType.SILENT_MODE_DURATION:
      ret = 1;
      break;
    case ChatSilentModeParamType.SILENT_MODE_INTERVAL:
      ret = 2;
      break;
  }
  return ret;
}

int? chatPushRemindTypeToInt(ChatPushRemindType? type) {
  int? ret;
  if (type == null) {
    return ret;
  }
  switch (type) {
    case ChatPushRemindType.ALL:
      ret = 0;
      break;
    case ChatPushRemindType.MENTION_ONLY:
      ret = 1;
      break;
    case ChatPushRemindType.NONE:
      ret = 2;
      break;
  }
  return ret;
}

ChatPushRemindType chatPushRemindTypeFromInt(int iRemindType) {
  ChatPushRemindType type = ChatPushRemindType.ALL;
  switch (iRemindType) {
    case 0:
      type = ChatPushRemindType.ALL;
      break;
    case 1:
      type = ChatPushRemindType.MENTION_ONLY;
      break;
    case 2:
      type = ChatPushRemindType.NONE;
      break;
  }
  return type;
}
