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
    case 52:
      return EMMultiDevicesEvent.GROUP_MEMBER_ATTRIBUTES_CHANGED;
    case 60:
      return EMMultiDevicesEvent.CONVERSATION_PINNED;
    case 61:
      return EMMultiDevicesEvent.CONVERSATION_UNPINNED;
    case 62:
      return EMMultiDevicesEvent.CONVERSATION_DELETE;
    case 63:
      return EMMultiDevicesEvent.CONVERSATION_UPDATE_MARK;
    case 64:
      return EMMultiDevicesEvent.CONVERSATION_MUTE_INFO_CHANGED;
  }
  return null;
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
