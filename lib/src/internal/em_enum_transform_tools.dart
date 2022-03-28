import '../em_listeners.dart';

EMContactGroupEvent? convertIntToEMContactGroupEvent(int? i) {
  switch (i) {
    case 2:
      return EMContactGroupEvent.CONTACT_REMOVE;
    case 3:
      return EMContactGroupEvent.CONTACT_ACCEPT;
    case 4:
      return EMContactGroupEvent.CONTACT_DECLINE;
    case 5:
      return EMContactGroupEvent.CONTACT_BAN;
    case 6:
      return EMContactGroupEvent.CONTACT_ALLOW;
    case 10:
      return EMContactGroupEvent.GROUP_CREATE;
    case 11:
      return EMContactGroupEvent.GROUP_DESTROY;
    case 12:
      return EMContactGroupEvent.GROUP_JOIN;
    case 13:
      return EMContactGroupEvent.GROUP_LEAVE;
    case 14:
      return EMContactGroupEvent.GROUP_APPLY;
    case 15:
      return EMContactGroupEvent.GROUP_APPLY_ACCEPT;
    case 16:
      return EMContactGroupEvent.GROUP_APPLY_DECLINE;
    case 17:
      return EMContactGroupEvent.GROUP_INVITE;
    case 18:
      return EMContactGroupEvent.GROUP_INVITE_ACCEPT;
    case 19:
      return EMContactGroupEvent.GROUP_INVITE_DECLINE;
    case 20:
      return EMContactGroupEvent.GROUP_KICK;
    case 21:
      return EMContactGroupEvent.GROUP_BAN;
    case 22:
      return EMContactGroupEvent.GROUP_ALLOW;
    case 23:
      return EMContactGroupEvent.GROUP_BLOCK;
    case 24:
      return EMContactGroupEvent.GROUP_UNBLOCK;
    case 25:
      return EMContactGroupEvent.GROUP_ASSIGN_OWNER;
    case 26:
      return EMContactGroupEvent.GROUP_ADD_ADMIN;
    case 27:
      return EMContactGroupEvent.GROUP_REMOVE_ADMIN;
    case 28:
      return EMContactGroupEvent.GROUP_ADD_MUTE;
    case 29:
      return EMContactGroupEvent.GROUP_REMOVE_MUTE;
    default:
      return null;
  }
}
