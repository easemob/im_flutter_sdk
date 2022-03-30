import '../models/em_message.dart';

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

int downloadStatusToInt(EMDownloadStatus status) {
  if (status == EMDownloadStatus.DOWNLOADING) {
    return 0;
  } else if (status == EMDownloadStatus.SUCCESS) {
    return 1;
  } else if (status == EMDownloadStatus.FAILED) {
    return 2;
  } else {
    return 3;
  }
}
