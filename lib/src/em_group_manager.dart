import "dart:async";

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import "em_listeners.dart";
import 'em_log.dart';
import 'em_sdk_method.dart';

class EMGroupManager {
  static const _channelPrefix = 'com.easemob.im';
  static const MethodChannel _emGroupManagerChannel =
  const MethodChannel('$_channelPrefix/em_contact_manager', JSONMethodCodec());
  static EMGroupManager _instance;
  final EMLog log;
  final List<EMGroupEventListener> _groupChangeEventListeners =
  List<EMGroupEventListener>();

  EMGroupManager._internal(EMLog log) : log = log {
    _addNativeMethodCallHandler();
  }

  factory EMGroupManager.getInstance({@required EMLog log}) {
    return _instance = _instance ?? EMGroupManager._internal(log);
  }


  void _addNativeMethodCallHandler() {
    _emGroupManagerChannel.setMethodCallHandler((MethodCall call) {
      Map argMap = call.arguments;
      if (call.method == EMSDKMethod.onGroupChanged) {
        return _onGroupChanged(argMap);
      }
      return null;
    });
  }

  Future<void> _onGroupChanged(Map event) async {
    var type = event['type'] as EMGroupChangeEvent;
    Map group = event['group'];
    String groupId = event['groupId'];
    String username = event['username'];
    String inviter = event['inviter'];
    String invitee = event['invitee'];
    String message = event['message'];
    String reason = event['reason'];
    List groupList = event['groupList'];
    List mutedMembers = event['mutedMembers'];
    int muteExpire = event['muteExpire'];
    String admin = event['admin'];
    String newOwner = event['newOwner'];
    String oldOwner = event['oldOwner'];
    String announcement = event['announcement'];
    Map sharedFile = event['sharedFile'];
    for (var listener in _groupChangeEventListeners) {
      switch (type) {
        case EMGroupChangeEvent.GROUP_INVITATION_RECEIVE:
          listener.groupInvitationDidReceive(groupId, invitee, message);
          break;
        case EMGroupChangeEvent.GROUP_INVITATION_ACCEPT:
          listener.groupInvitationDidAccept(group, invitee);
          break;
        case EMGroupChangeEvent.GROUP_INVITATION_DECLINE:
          listener.groupInvitationDidDecline(group, inviter, reason);
          break;
        case EMGroupChangeEvent.GROUP_AUTOMATIC_AGREE_JOIN:
          listener.didJoinGroup(group, inviter, message);
          break;
        case EMGroupChangeEvent.GROUP_LEAVE:
          listener.didLeaveGroup(group, reason);
          break;
        case EMGroupChangeEvent.GROUP_JOIN_GROUP_REQUEST_RECEIVE:
          listener.joinGroupRequestDidReceive(group, username, reason);
          break;
        case EMGroupChangeEvent.GROUP_JOIN_GROUP_REQUEST_DECLINE:
          listener.joinGroupRequestDidDecline(groupId, reason);
          break;
        case EMGroupChangeEvent.GROUP_JOIN_GROUP_REQUEST_APPROVE:
          listener.joinGroupRequestDidApprove(group);
          break;
        case EMGroupChangeEvent.GROUP_LIST_UPDATE:
          listener.groupListDidUpdate(groupList);
          break;
        case EMGroupChangeEvent.GROUP_MUTE_LIST_UPDATE_ADDED:
          listener.groupMuteListDidUpdateWithAdded(group, mutedMembers, muteExpire);
          break;
        case EMGroupChangeEvent.GROUP_MUTE_LIST_UPDATE_REMOVED:
          listener.groupMuteListDidUpdateWithRemoved(group, mutedMembers);
          break;
        case EMGroupChangeEvent.GROUP_ADMIN_LIST_UPDATE_ADDED:
          listener.groupAdminListDidUpdateWithAdded(group, admin);
          break;
        case EMGroupChangeEvent.GROUP_ADMIN_LIST_UPDATE_REMOVED:
          listener.groupAdminListDidUpdateWithRemoved(group, admin);
          break;
        case EMGroupChangeEvent.GROUP_OWNER_UPDATE:
          listener.groupOwnerDidUpdate(group, newOwner, oldOwner);
          break;
        case EMGroupChangeEvent.GROUP_USER_JOIN:
          listener.userDidJoinGroup(group, username);
          break;
        case EMGroupChangeEvent.GROUP_USER_LEAVE:
          listener.userDidLeaveGroup(group, username);
          break;
        case EMGroupChangeEvent.GROUP_ANNOUNCEMENT_UPDATE:
          listener.groupAnnouncementDidUpdate(group, announcement);
          break;
        case EMGroupChangeEvent.GROUP_FILE_LIST_UPDATE_ADDED:
          listener.groupFileListDidUpdateWithAdded(group, groupId, invitee);
          break;
        case EMGroupChangeEvent.GROUP_FILE_LIST_UPDATE_REMOVED:
          listener.groupFileListDidUpdateWithRemoved(group, sharedFile);
          break;
        default:
      }
    }
  }


}
