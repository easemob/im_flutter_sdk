// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:async';

import 'package:flutter/services.dart';
import 'internal/inner_headers.dart';

/// ~english
/// The contact manager class, which manages chat contacts such as adding, deleting, retrieving, and modifying contacts.
/// ~end
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

  final Map<String, EMContactEventHandler> _eventHandlesMap = {};

  Future<void> _onContactChanged(Map event) async {
    var type = event['type'];
    String username = event['username'];
    String? reason = event['reason'];

    _eventHandlesMap.values.forEach((element) {
      switch (type) {
        case EMContactChangeEvent.CONTACT_ADD:
          element.onContactAdded?.call(username);
          break;
        case EMContactChangeEvent.CONTACT_DELETE:
          element.onContactDeleted?.call(username);
          break;
        case EMContactChangeEvent.INVITED:
          element.onContactInvited?.call(username, reason);
          break;
        case EMContactChangeEvent.INVITATION_ACCEPTED:
          element.onFriendRequestAccepted?.call(username);
          break;
        case EMContactChangeEvent.INVITATION_DECLINED:
          element.onFriendRequestDeclined?.call(username);
          break;
        default:
      }
    });
  }

  /// ~english
  /// Adds the contact event handler. After calling this method, you can handle for new contact event when they arrive.
  ///
  /// Param [identifier] The custom handler identifier, is used to find the corresponding handler.
  ///
  /// Param [handler] The handle for contact event. See [EMContactEventHandler].
  /// ~end
  void addEventHandler(
    String identifier,
    EMContactEventHandler handler,
  ) {
    _eventHandlesMap[identifier] = handler;
  }

  /// ~english
  /// Remove the contact event handler.
  ///
  /// Param [identifier] The custom handler identifier.
  /// ~end
  void removeEventHandler(String identifier) {
    _eventHandlesMap.remove(identifier);
  }

  /// ~english
  /// Get the contact event handler.
  ///
  /// Param [identifier] The custom handler identifier.
  ///
  /// **Return** The contact event handler.
  /// ~end
  EMContactEventHandler? getEventHandler(String identifier) {
    return _eventHandlesMap[identifier];
  }

  /// ~english
  /// Clear all contact event handlers.
  ///
  void clearEventHandlers() {
    _eventHandlesMap.clear();
  }

  /// ~english
  /// Adds a new contact.
  ///
  /// Param [userId] The user to be added.
  ///
  /// Param [reason] (optional) The invitation message.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  Future<void> addContact(
    String userId, {
    String? reason,
  }) async {
    Map req = {
      'username': userId,
    };
    req.add("reason", reason);

    Map result = await _channel.invokeMethod(ChatMethodKeys.addContact, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Deletes a contact and all the related conversations.
  ///
  /// Param [username] The contact to be deleted.
  ///
  /// Param [keepConversation] Whether to retain conversations of the deleted contact.
  /// - `true`: Yes.
  /// - `false`: (default) No.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  Future<void> deleteContact(
    String username, {
    bool keepConversation = false,
  }) async {
    Map req = {'username': username, 'keepConversation': keepConversation};
    Map result = await _channel.invokeMethod(ChatMethodKeys.deleteContact, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Gets all the contacts from the server.
  ///
  /// **Return** The list of contacts.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  Future<List<String>> getAllContactsFromServer() async {
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.getAllContactsFromServer);
    try {
      EMError.hasErrorFromResult(result);
      List<String> list = [];
      result[ChatMethodKeys.getAllContactsFromServer]?.forEach((element) {
        if (element is String) {
          list.add(element);
        }
      });
      return list;
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Gets the contact list from the local database.
  ///
  /// **Return** The contact list.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  Future<List<String>> getAllContactsFromDB() async {
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.getAllContactsFromDB);
    try {
      EMError.hasErrorFromResult(result);
      List<String> list = [];
      result[ChatMethodKeys.getAllContactsFromDB]?.forEach((element) {
        if (element is String) {
          list.add(element);
        }
      });

      return list;
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Adds a user to the block list.
  /// You can send messages to the users on the block list, but cannot receive messages from them.
  ///
  /// Param [username] The user to be added to the block list.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
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

  /// ~english
  /// Removes the contact from the block list.
  ///
  /// Param [username] The contact to be removed from the block list.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
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

  /// ~english
  /// Gets the block list from the server.
  ///
  /// **Return** The block list obtained from the server.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  Future<List<String>> getBlockListFromServer() async {
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.getBlockListFromServer);
    try {
      EMError.hasErrorFromResult(result);
      List<String> list = [];
      result[ChatMethodKeys.getBlockListFromServer]?.forEach((element) {
        if (element is String) {
          list.add(element);
        }
      });
      return list;
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Gets the block list from the local database.
  ///
  /// **Return** The block list obtained from the local database.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  Future<List<String>> getBlockListFromDB() async {
    Map result = await _channel.invokeMethod(ChatMethodKeys.getBlockListFromDB);
    try {
      EMError.hasErrorFromResult(result);
      List<String> list = [];
      result[ChatMethodKeys.getBlockListFromDB]?.forEach((element) {
        if (element is String) {
          list.add(element);
        }
      });
      return list;
    } on EMError catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Accepts a friend invitation。
  ///
  /// Param [username] The user who sends the friend invitation.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
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

  /// ~english
  /// Declines a friend invitation.
  ///
  /// Param [username] The user who sends the friend invitation.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
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

  /// ~english
  /// Gets the unique IDs of the current user on the other devices. The ID is in the format of username + "/" + resource.
  ///
  /// **Return** The list of unique IDs of users on the other devices if the method succeeds.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  Future<List<String>> getSelfIdsOnOtherPlatform() async {
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.getSelfIdsOnOtherPlatform);
    try {
      EMError.hasErrorFromResult(result);
      List<String> devices = [];
      result[ChatMethodKeys.getSelfIdsOnOtherPlatform]?.forEach((element) {
        devices.add(element);
      });
      return devices;
    } on EMError catch (e) {
      throw e;
    }
  }
}
