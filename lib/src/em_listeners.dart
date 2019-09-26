abstract class EMConnectionListener {
  void onConnected();
  void onDisconnected();
}

abstract class EMMultiDeviceListener {
  void onContactEvent(EMContactGroupEvent event, String target, String ext);
  void onGroupEvent(
      EMContactGroupEvent event, String target, List<String> usernames);
}

enum EMContactGroupEvent {
  CONTACT_REMOV,
  CONTACT_ACCEP,
  CONTACT_DECLIN,
  CONTACT_BA,
  CONTACT_ALLO,
  GROUP_CREATE,
  GROUP_DESTROY,
  GROUP_JOIN,
  GROUP_LEAVE,
  GROUP_APPLY,
  GROUP_APPLY_ACCEPT,
  GROUP_APPLY_DECLINE,
  GROUP_INVITE,
  GROUP_INVITE_ACCEPT,
  GROUP_INVITE_DECLINE,
  GROUP_KICK,
  GROUP_BAN,
  GROUP_ALLOW,
  GROUP_BLOCK,
  GROUP_UNBLOCK,
  GROUP_ASSIGN_OWNER,
  GROUP_ADD_ADMIN,
  GROUP_REMOVE_ADMIN,
  GROUP_ADD_MUTE,
  GROUP_REMOVE_MUTE
}
