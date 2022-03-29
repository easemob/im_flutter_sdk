import 'dart:async';

import 'package:flutter/services.dart';

import 'em_listeners.dart';
import 'internal/chat_method_keys.dart';
import 'internal/em_event_keys.dart';
import 'models/em_error.dart';

///
/// The `EMContactManager` is used to record, query, and modify contacts.
///
class EMContactManager {
  static const _channelPrefix = 'com.chat.im';
  static const MethodChannel _channel = const MethodChannel(
      '$_channelPrefix/chat_contact_manager', JSONMethodCodec());

  /// @nodoc
  EMContactManager() {
    _channel.setMethodCallHandler((MethodCall call) async {
      Map? argMap = call.arguments;
      if (call.method == ChatMethodKeys.onContactChanged) {
        return _onContactChanged(argMap!);
      }
      return null;
    });
  }

  final List<EMContactEventListener> _contactChangeEventListeners = [];

  Future<void> _onContactChanged(Map event) async {
    var type = event['type'];
    String? username = event['username'];
    String? reason = event['reason'];
    for (var listener in _contactChangeEventListeners) {
      switch (type) {
        case EMContactChangeEvent.CONTACT_ADD:
          listener.onContactAdded(username);
          break;
        case EMContactChangeEvent.CONTACT_DELETE:
          listener.onContactDeleted(username);
          break;
        case EMContactChangeEvent.INVITED:
          listener.onContactInvited(username, reason);
          break;
        case EMContactChangeEvent.INVITATION_ACCEPTED:
          listener.onFriendRequestAccepted(username);
          break;
        case EMContactChangeEvent.INVITATION_DECLINED:
          listener.onFriendRequestDeclined(username);
          break;
        default:
      }
    }
  }

  ///
  /// Adds a new contact.
  ///
  /// Param [username] The user to be added.
  ///
  /// Param [reason] (optional) The invitation message. Set the parameter as null if you want to ignore the information.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<void> addContact(
    String username, [
    String reason = '',
  ]) async {
    Map req = {'username': username, 'reason': reason};
    Map result = await _channel.invokeMethod(ChatMethodKeys.addContact, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Deletes a contact and all the conversations associated.
  ///
  /// Param [username] The contact to be deleted.
  ///
  /// Param [keepConversation] Whether to keep the associated conversation and messages.
  /// `true`: keep conversation and messages.
  /// `false`: (default) delete conversation and messages.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<void> deleteContact(
    String username, [
    bool keepConversation = false,
  ]) async {
    Map req = {'username': username, 'keepConversation': keepConversation};
    Map result = await _channel.invokeMethod(ChatMethodKeys.deleteContact, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Get all contacts from the server.
  ///
  /// **return** The list of contacts.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<List<String>> getAllContactsFromServer() async {
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.getAllContactsFromServer);
    try {
      EMError.hasErrorFromResult(result);
      List<String> contacts = [];
      result[ChatMethodKeys.getAllContactsFromServer]?.forEach((element) {
        contacts.add(element);
      });
      return contacts;
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Gets the contact list from the local database.
  ///
  /// **return** The contact list.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<List<String>> getAllContactsFromDB() async {
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.getAllContactsFromDB);
    try {
      EMError.hasErrorFromResult(result);
      List<String> contacts = [];
      result[ChatMethodKeys.getAllContactsFromDB]?.forEach((element) {
        contacts.add(element);
      });

      return contacts;
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Adds a user to block list.
  /// You can send message to the user in block list, but you can not receive the message sent by the other.
  ///
  /// Param [username] The user to be blocked.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<void> addUserToBlockList(
    String username,
  ) async {
    Map req = {'username': username};
    Map result = await _channel.invokeMethod(
      ChatMethodKeys.addUserToBlockList,
      req,
    );
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Removes the contact from the block list.
  ///
  /// Param [username] The user to be removed from the block list.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<void> removeUserFromBlockList(String username) async {
    Map req = {'username': username};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.removeUserFromBlockList, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Get all block list from the server.
  ///
  /// **return** The block list from the server.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<List<String>> getBlockListFromServer() async {
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.getBlockListFromServer);
    try {
      EMError.hasErrorFromResult(result);
      List<String> blockList = [];
      result[ChatMethodKeys.getBlockListFromServer]?.forEach((element) {
        blockList.add(element);
      });
      return blockList;
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Gets the local database block list.
  ///
  /// **return** The block list.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<List<String>> getBlockListFromDB() async {
    Map result = await _channel.invokeMethod(ChatMethodKeys.getBlockListFromDB);
    try {
      EMError.hasErrorFromResult(result);
      List<String> blockList = [];
      result[ChatMethodKeys.getBlockListFromDB]?.forEach((element) {
        blockList.add(element);
      });
      return blockList;
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Accepts a friend invitation。
  ///
  /// Param [username] The user who initiates the friend request.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<void> acceptInvitation(String username) async {
    Map req = {'username': username};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.acceptInvitation, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Declines a friend invitation.
  ///
  /// Param [username] The user who initiates the invitation.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<void> declineInvitation(String username) async {
    Map req = {'username': username};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.declineInvitation, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Get the unique IDs of current user on the other devices. The ID is username + "/" + resource.
  ///
  /// **return** The unique device ID list on the other devices if the method succeeds.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<List<String>?> getSelfIdsOnOtherPlatform() async {
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.getSelfIdsOnOtherPlatform);
    try {
      EMError.hasErrorFromResult(result);
      List<String>? devices =
          result[ChatMethodKeys.getSelfIdsOnOtherPlatform]?.cast<String>();
      return devices;
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Registers a new contact listener.
  ///
  /// Param [contactListener] The contact listener to be registered.
  ///
  void addContactListener(EMContactEventListener contactListener) {
    _contactChangeEventListeners.add(contactListener);
  }

  ///
  /// Removes the contact listener.
  ///
  /// Param [contactListener] The contact listener to be removed.
  ///
  void removeContactListener(EMContactEventListener contactListener) {
    if (_contactChangeEventListeners.contains(contactListener)) {
      _contactChangeEventListeners.remove(contactListener);
    }
  }
}
