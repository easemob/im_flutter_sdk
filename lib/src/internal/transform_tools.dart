import 'inner_headers.dart';

MultiDevicesEvent? convertIntToMultiDevicesEvent(int? i) {
  switch (i) {
    case 2:
      return MultiDevicesEvent.CONTACT_REMOVE;
    case 3:
      return MultiDevicesEvent.CONTACT_ACCEPT;
    case 4:
      return MultiDevicesEvent.CONTACT_DECLINE;
    case 5:
      return MultiDevicesEvent.CONTACT_BAN;
    case 6:
      return MultiDevicesEvent.CONTACT_ALLOW;
    case 10:
      return MultiDevicesEvent.GROUP_CREATE;
    case 11:
      return MultiDevicesEvent.GROUP_DESTROY;
    case 12:
      return MultiDevicesEvent.GROUP_JOIN;
    case 13:
      return MultiDevicesEvent.GROUP_LEAVE;
    case 14:
      return MultiDevicesEvent.GROUP_APPLY;
    case 15:
      return MultiDevicesEvent.GROUP_APPLY_ACCEPT;
    case 16:
      return MultiDevicesEvent.GROUP_APPLY_DECLINE;
    case 17:
      return MultiDevicesEvent.GROUP_INVITE;
    case 18:
      return MultiDevicesEvent.GROUP_INVITE_ACCEPT;
    case 19:
      return MultiDevicesEvent.GROUP_INVITE_DECLINE;
    case 20:
      return MultiDevicesEvent.GROUP_KICK;
    case 21:
      return MultiDevicesEvent.GROUP_BAN;
    case 22:
      return MultiDevicesEvent.GROUP_ALLOW;
    case 23:
      return MultiDevicesEvent.GROUP_BLOCK;
    case 24:
      return MultiDevicesEvent.GROUP_UNBLOCK;
    case 25:
      return MultiDevicesEvent.GROUP_ASSIGN_OWNER;
    case 26:
      return MultiDevicesEvent.GROUP_ADD_ADMIN;
    case 27:
      return MultiDevicesEvent.GROUP_REMOVE_ADMIN;
    case 28:
      return MultiDevicesEvent.GROUP_ADD_MUTE;
    case 29:
      return MultiDevicesEvent.GROUP_REMOVE_MUTE;
    case 40:
      return MultiDevicesEvent.CHAT_THREAD_CREATE;
    case 41:
      return MultiDevicesEvent.CHAT_THREAD_DESTROY;
    case 42:
      return MultiDevicesEvent.CHAT_THREAD_JOIN;
    case 43:
      return MultiDevicesEvent.CHAT_THREAD_LEAVE;
    case 44:
      return MultiDevicesEvent.CHAT_THREAD_KICK;
    case 45:
      return MultiDevicesEvent.CHAT_THREAD_UPDATE;
    case 52:
      return MultiDevicesEvent.GROUP_MEMBER_ATTRIBUTES_CHANGED;
    case 60:
      return MultiDevicesEvent.CONVERSATION_PINNED;
    case 61:
      return MultiDevicesEvent.CONVERSATION_UNPINNED;
    case 62:
      return MultiDevicesEvent.CONVERSATION_DELETE;
    case 63:
      return MultiDevicesEvent.CONVERSATION_UPDATE_MARK;
    case 64:
      return MultiDevicesEvent.CONVERSATION_MUTE_INFO_CHANGED;
  }
  return null;
}

GroupStyle groupStyleTypeFromInt(int? type) {
  GroupStyle ret = GroupStyle.PrivateOnlyOwnerInvite;
  switch (type) {
    case 0:
      {
        ret = GroupStyle.PrivateOnlyOwnerInvite;
      }
      break;
    case 1:
      {
        ret = GroupStyle.PrivateMemberCanInvite;
      }
      break;
    case 2:
      {
        ret = GroupStyle.PublicJoinNeedApproval;
      }
      break;
    case 3:
      {
        ret = GroupStyle.PublicOpenJoin;
      }
      break;
  }
  return ret;
}

int groupStyleTypeToInt(GroupStyle? type) {
  int ret = 0;
  if (type == null) return ret;
  switch (type) {
    case GroupStyle.PrivateOnlyOwnerInvite:
      {
        ret = 0;
      }
      break;
    case GroupStyle.PrivateMemberCanInvite:
      {
        ret = 1;
      }
      break;
    case GroupStyle.PublicJoinNeedApproval:
      {
        ret = 2;
      }
      break;
    case GroupStyle.PublicOpenJoin:
      {
        ret = 3;
      }
      break;
  }
  return ret;
}
