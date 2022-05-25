import 'dart:async';

import 'package:flutter/services.dart';

import 'em_listeners.dart';
import 'internal/chat_method_keys.dart';
import 'internal/em_event_keys.dart';
import 'models/em_error.dart';

///
/// The contact manager class, which manages chat contacts such as adding, deleting, retrieving, and modifying contacts.
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

  final List<EMContactManagerListener> _contactManagerListeners = [];

  Future<void> _onContactChanged(Map event) async {
    var type = event['type'];
    String username = event['username'];
    String? reason = event['reason'];
    for (var listener in _contactManagerListeners) {
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
  /// Param [userId] (optional) The invitation message.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<void> addContact(
    String userId, [
    String reason = '',
  ]) async {
    Map req = {'username': userId, 'reason': reason};
    Map result = await _channel.invokeMethod(ChatMethodKeys.addContact, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Deletes a contact and all the related conversations.
  ///
  /// Param [username] The contact to be deleted.
  ///
  /// Param [keepConversation] Whether to retain conversations of the deleted contact.
  /// - `true`: Yes.
  /// - `false`: (default) No.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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
  /// Gets all the contacts from the server.
  ///
  /// **Return** The list of contacts.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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
  /// **Return** The contact list.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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
  /// Adds a user to the block list.
  /// You can send messages to the users on the block list, but cannot receive messages from them.
  ///
  /// Param [username] The user to be added to the block list.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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
  /// Param [username] The contact to be removed from the block list.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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
  /// Gets the block list from the server.
  ///
  /// **Return** The block list obtained from the server.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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
  /// Gets the block list from the local database.
  ///
  /// **Return** The block list obtained from the local database.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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
  /// Param [username] The user who sends the friend invitation.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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
  /// Param [username] The user who sends the friend invitation.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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
  /// Gets the unique IDs of the current user on the other devices. The ID is in the format of username + "/" + resource.
  ///
  /// **Return** The list of unique IDs of users on the other devices if the method succeeds.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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
  /// Param [contactListener] The contact listener to be registered: {@link EMContactEventListener}.
  ///
  void addContactListener(EMContactManagerListener contactListener) {
    _contactManagerListeners.add(contactListener);
  }

  ///
  /// Removes the contact listener.
  ///
  /// Param [contactListener] The contact listener to be removed.
  ///
  void removeContactListener(EMContactManagerListener contactListener) {
    if (_contactManagerListeners.contains(contactListener)) {
      _contactManagerListeners.remove(contactListener);
    }
  }
}
