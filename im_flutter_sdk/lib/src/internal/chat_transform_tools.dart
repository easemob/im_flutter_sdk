import 'inner_headers.dart';

ChatMultiDevicesEvent? convertIntToChatMultiDevicesEvent(int? i) {
  switch (i) {
    case -1:
      return ChatMultiDevicesEvent.UnKnow;
    case 2:
      return ChatMultiDevicesEvent.CONTACT_REMOVE;
    case 3:
      return ChatMultiDevicesEvent.CONTACT_ACCEPT;
    case 4:
      return ChatMultiDevicesEvent.CONTACT_DECLINE;
    case 5:
      return ChatMultiDevicesEvent.CONTACT_BAN;
    case 6:
      return ChatMultiDevicesEvent.CONTACT_ALLOW;
    case 10:
      return ChatMultiDevicesEvent.GROUP_CREATE;
    case 11:
      return ChatMultiDevicesEvent.GROUP_DESTROY;
    case 12:
      return ChatMultiDevicesEvent.GROUP_JOIN;
    case 13:
      return ChatMultiDevicesEvent.GROUP_LEAVE;
    case 14:
      return ChatMultiDevicesEvent.GROUP_APPLY;
    case 15:
      return ChatMultiDevicesEvent.GROUP_APPLY_ACCEPT;
    case 16:
      return ChatMultiDevicesEvent.GROUP_APPLY_DECLINE;
    case 17:
      return ChatMultiDevicesEvent.GROUP_INVITE;
    case 18:
      return ChatMultiDevicesEvent.GROUP_INVITE_ACCEPT;
    case 19:
      return ChatMultiDevicesEvent.GROUP_INVITE_DECLINE;
    case 20:
      return ChatMultiDevicesEvent.GROUP_KICK;
    case 21:
      return ChatMultiDevicesEvent.GROUP_BAN;
    case 22:
      return ChatMultiDevicesEvent.GROUP_ALLOW;
    case 23:
      return ChatMultiDevicesEvent.GROUP_BLOCK;
    case 24:
      return ChatMultiDevicesEvent.GROUP_UNBLOCK;
    case 25:
      return ChatMultiDevicesEvent.GROUP_ASSIGN_OWNER;
    case 26:
      return ChatMultiDevicesEvent.GROUP_ADD_ADMIN;
    case 27:
      return ChatMultiDevicesEvent.GROUP_REMOVE_ADMIN;
    case 28:
      return ChatMultiDevicesEvent.GROUP_ADD_MUTE;
    case 29:
      return ChatMultiDevicesEvent.GROUP_REMOVE_MUTE;
    case 40:
      return ChatMultiDevicesEvent.CHAT_THREAD_CREATE;
    case 41:
      return ChatMultiDevicesEvent.CHAT_THREAD_DESTROY;
    case 42:
      return ChatMultiDevicesEvent.CHAT_THREAD_JOIN;
    case 43:
      return ChatMultiDevicesEvent.CHAT_THREAD_LEAVE;
    case 44:
      return ChatMultiDevicesEvent.CHAT_THREAD_KICK;
    case 45:
      return ChatMultiDevicesEvent.CHAT_THREAD_UPDATE;
    case 52:
      return ChatMultiDevicesEvent.GROUP_MEMBER_ATTRIBUTES_CHANGED;
    case 60:
      return ChatMultiDevicesEvent.CONVERSATION_PINNED;
    case 61:
      return ChatMultiDevicesEvent.CONVERSATION_UNPINNED;
    case 62:
      return ChatMultiDevicesEvent.CONVERSATION_DELETE;
    case 63:
      return ChatMultiDevicesEvent.CONVERSATION_UPDATE_MARK;
    case 64:
      return ChatMultiDevicesEvent.CONVERSATION_MUTE_INFO_CHANGED;
  }
  return null;
}

ChatGroupStyle groupStyleTypeFromInt(int? type) {
  ChatGroupStyle ret = ChatGroupStyle.PrivateOnlyOwnerInvite;
  switch (type) {
    case 0:
      {
        ret = ChatGroupStyle.PrivateOnlyOwnerInvite;
      }
      break;
    case 1:
      {
        ret = ChatGroupStyle.PrivateMemberCanInvite;
      }
      break;
    case 2:
      {
        ret = ChatGroupStyle.PublicJoinNeedApproval;
      }
      break;
    case 3:
      {
        ret = ChatGroupStyle.PublicOpenJoin;
      }
      break;
  }
  return ret;
}

int groupStyleTypeToInt(ChatGroupStyle? type) {
  int ret = 0;
  if (type == null) return ret;
  switch (type) {
    case ChatGroupStyle.PrivateOnlyOwnerInvite:
      {
        ret = 0;
      }
      break;
    case ChatGroupStyle.PrivateMemberCanInvite:
      {
        ret = 1;
      }
      break;
    case ChatGroupStyle.PublicJoinNeedApproval:
      {
        ret = 2;
      }
      break;
    case ChatGroupStyle.PublicOpenJoin:
      {
        ret = 3;
      }
      break;
  }
  return ret;
}
