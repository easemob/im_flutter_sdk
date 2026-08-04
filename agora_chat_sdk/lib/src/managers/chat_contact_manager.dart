import 'package:flutter/services.dart';
import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:agora_chat_sdk/src/tools/chat_extension.dart';
import 'package:agora_chat_sdk/src/tools/chat_log.dart';

import 'package:agora_chat_sdk_interface/agora_chat_sdk_interface.dart' as platform_interface;

/// ~english
/// The contact manager class, which manages chat contacts such as adding, deleting, retrieving, and modifying contacts.
/// ~end
///
/// ~chinese
/// 联系人管理类，用于记录、查询和修改用户的联系人列表。
/// ~end
class ChatContactManager {
  final Map<String, ChatContactEventHandler> _eventHandlesMap = {};

  ChatContactManager() {
    platform_interface.Client.instance.contactManager.updateNativeHandler((MethodCall call) async {
      ChatLog.d("${call.method}: arguments: ${call.arguments}");
      Map? argMap = call.arguments;
      if (call.method == ChatMethodKeys.onContactChanged) {
        return _onContactChanged(argMap!);
      }
    });
  }

  Future<void> _onContactChanged(Map event) async {
    var type = event['type'];
    String username = event['userId'];
    String? reason = event['reason'];

    for (var element in _eventHandlesMap.values) {
      switch (type) {
        case ChatContactChangeEvent.CONTACT_ADD:
          element.onContactAdded?.call(username);
          break;
        case ChatContactChangeEvent.CONTACT_DELETE:
          element.onContactDeleted?.call(username);
          break;
        case ChatContactChangeEvent.INVITED:
          element.onContactInvited?.call(username, reason);
          break;
        case ChatContactChangeEvent.INVITATION_ACCEPTED:
          element.onFriendRequestAccepted?.call(username);
          break;
        case ChatContactChangeEvent.INVITATION_DECLINED:
          element.onFriendRequestDeclined?.call(username);
          break;
        default:
      }
    }
  }

  /// ~english
  /// Adds the contact event handler. After calling this method, you can handle for new contact event when they arrive.
  ///
  /// Param [identifier] The custom handler identifier, is used to find the corresponding handler.
  ///
  /// Param [handler] The handle for contact event. See [ChatContactEventHandler].
  /// ~end
  ///
  /// ~chinese
  /// 添加联系人事件处理程序。调用此方法后，您可以在新的联系人事件到达时处理它们。
  ///
  /// Param [identifier] 自定义处理程序标识符，用于查找相应的处理程序。
  ///
  /// Param [handler] 事件的句柄. See [ChatContactEventHandler].
  /// ~end
  void addEventHandler(
    String identifier,
    ChatContactEventHandler handler,
  ) {
    _eventHandlesMap[identifier] = handler;
  }

  /// ~english
  /// Remove the contact event handler.
  ///
  /// Param [identifier] The custom handler identifier.
  /// ~end
  ///
  /// ~chinese
  /// 删除联系人事件处理程序。
  ///
  /// Param [identifier] 自定义处理程序标识符。
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
  ///
  /// ~chinese
  /// 获取联系人事件处理程序。
  ///
  /// Param [identifier] 自定义处理程序标识符。
  ///
  /// **Return** 事件的句柄。
  /// ~end
  ChatContactEventHandler? getEventHandler(String identifier) {
    return _eventHandlesMap[identifier];
  }

  /// ~english
  /// Clear all contact event handlers.
  /// ~end
  ///
  /// ~chinese
  /// 清除所有联系人事件处理程序。
  /// ~end
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
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 添加联系人
  ///
  /// Param [userId] 要添加的好友的用户 ID。
  ///
  /// Param [reason] （可选）添加为好友的原因。
  ///
  /// **Throws**  如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [ChatError]。
  /// ~end

  Future<void> addContact(
    String userId, {
    String? reason,
  }) async {
    try {
      Map req = {
        'userId': userId,
      };
      req.putIfNotNull("reason", reason);
      Map result = await platform_interface.Client.instance.contactManager
          .callNativeMethod(ChatMethodKeys.addContact, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Deletes a contact and all the related conversations.
  ///
  /// Param [userId] The contact to be deleted.
  ///
  /// Param [keepConversation] Whether to retain conversations of the deleted contact.
  /// - `true`: Yes.
  /// - `false`: (default) No.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 删除联系人及其相关的会话。
  ///
  /// Param [userId] 要删除的联系人用户 ID。
  ///
  /// Param [keepConversation] 是否保留要删除的联系人的会话。
  /// - `true`：是；
  /// - （默认）`false`：否。
  ///
  /// **Throws**  如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [ChatError]。
  /// ~end

  Future<void> deleteContact(
    String userId, {
    bool keepConversation = false,
  }) async {
    try {
      Map req = {'userId': userId, 'keepConversation': keepConversation};
      Map result = await platform_interface.Client.instance.contactManager
          .callNativeMethod(ChatMethodKeys.deleteContact, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  @Deprecated('Use fetchAllContactIds instead.')

  /// ~english
  /// Gets all the contact ids from the server.
  ///
  /// **Return** The list of contact ids.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 从服务器获取联系人列表。
  ///
  /// **Return** 联系人列表。
  ///
  /// **Throws**  如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [ChatError]。
  /// ~end
  Future<List<String>> getAllContactsFromServer() async {
    try {
      Map result = await platform_interface.Client.instance.contactManager
          .callNativeMethod(ChatMethodKeys.getAllContactsFromServer);
      ChatError.hasErrorFromResult(result);
      List<String> list = [];
      result[ChatMethodKeys.getAllContactsFromServer]?.forEach((element) {
        if (element is String) {
          list.add(element);
        }
      });
      return list;
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Gets all the contact ids from the server.
  ///
  /// **Return** The list of contact ids.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 从服务器获取联系人列表。
  ///
  /// **Return** 联系人列表。
  ///
  /// **Throws**  如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [ChatError]。
  /// ~end

  Future<List<String>> fetchAllContactIds() async {
    try {
      Map result = await platform_interface.Client.instance.contactManager
          .callNativeMethod(ChatMethodKeys.getAllContactsFromServer);
      ChatError.hasErrorFromResult(result);
      List<String> list = [];
      result[ChatMethodKeys.getAllContactsFromServer]?.forEach((element) {
        if (element is String) {
          list.add(element);
        }
      });
      return list;
    } catch (e) {
      rethrow;
    }
  }

  @Deprecated('Use getAllContactIds instead.')

  /// ~english
  /// Gets the contact ids from the local database.
  ///
  /// **Return** The contact list ids.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 从数据库获取好友列表。
  ///
  /// **Return** 调用成功会返回好友列表。
  ///
  /// **Throws**  如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [ChatError]。
  /// ~end
  Future<List<String>> getAllContactsFromDB() async {
    try {
      Map result = await platform_interface.Client.instance.contactManager
          .callNativeMethod(ChatMethodKeys.getAllContactsFromDB);
      ChatError.hasErrorFromResult(result);
      List<String> list = [];
      result[ChatMethodKeys.getAllContactsFromDB]?.forEach((element) {
        if (element is String) {
          list.add(element);
        }
      });

      return list;
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Gets the contact ids from the local database.
  ///
  /// **Return** The contact ids.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 从数据库获取好友列表。
  ///
  /// **Return** 调用成功会返回好友列表。
  ///
  /// **Throws**  如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [ChatError]。
  /// ~end

  Future<List<String>> getAllContactIds() async {
    try {
      Map result = await platform_interface.Client.instance.contactManager
          .callNativeMethod(ChatMethodKeys.getAllContactsFromDB);
      ChatError.hasErrorFromResult(result);
      List<String> list = [];
      result[ChatMethodKeys.getAllContactsFromDB]?.forEach((element) {
        if (element is String) {
          list.add(element);
        }
      });

      return list;
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Adds a user to the block list.
  /// You can send messages to the users on the block list, but cannot receive messages from them.
  ///
  /// Param [userId] The user to be added to the block list.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 将指定用户加入黑名单。
  /// 你可以向黑名单中用户发消息，但是接收不到对方发送的消息。
  ///
  /// Param [userId] 要加入黑名单的用户的用户 ID。
  ///
  /// **Throws**  如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [ChatError]。
  /// ~end

  Future<void> addUserToBlockList(
    String userId,
  ) async {
    try {
      Map req = {'userId': userId};
      Map result = await platform_interface.Client.instance.contactManager.callNativeMethod(
        ChatMethodKeys.addUserToBlockList,
        req,
      );
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Removes the contact from the block ids.
  ///
  /// Param [userId] The contact to be removed from the block list.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 将指定用户移除黑名单。
  ///
  /// Param [userId] 要在黑名单中移除的用户 ID。
  ///
  /// **Throws**  如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [ChatError]。
  /// ~end

  Future<void> removeUserFromBlockList(String userId) async {
    try {
      Map req = {'userId': userId};
      Map result = await platform_interface.Client.instance.contactManager
          .callNativeMethod(ChatMethodKeys.removeUserFromBlockList, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  @Deprecated('Use fetchBlockIds instead.')

  /// ~english
  /// Gets the block list from the server.
  ///
  /// **Return** The block list obtained from the server.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 从服务器获取黑名单列表。
  ///
  /// **Return** 该方法调用成功会返回黑名单列表。
  ///
  /// **Throws**  如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [ChatError]。
  /// ~end
  Future<List<String>> getBlockListFromServer() async {
    try {
      Map result = await platform_interface.Client.instance.contactManager
          .callNativeMethod(ChatMethodKeys.getBlockListFromServer);
      ChatError.hasErrorFromResult(result);
      List<String> list = [];
      result[ChatMethodKeys.getBlockListFromServer]?.forEach((element) {
        if (element is String) {
          list.add(element);
        }
      });
      return list;
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Gets the block ids from the server.
  ///
  /// **Return** The block ids obtained from the server.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 从服务器获取黑名单列表。
  ///
  /// **Return** 该方法调用成功会返回黑名单列表。
  ///
  /// **Throws**  如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [ChatError]。
  /// ~end

  Future<List<String>> fetchBlockIds() async {
    try {
      Map result = await platform_interface.Client.instance.contactManager
          .callNativeMethod(ChatMethodKeys.getBlockListFromServer);
      ChatError.hasErrorFromResult(result);
      List<String> list = [];
      result[ChatMethodKeys.getBlockListFromServer]?.forEach((element) {
        if (element is String) {
          list.add(element);
        }
      });
      return list;
    } catch (e) {
      rethrow;
    }
  }

  @Deprecated('Use getBlockIds instead.')

  /// ~english
  /// Gets the block list from the local database.
  ///
  /// **Return** The block list obtained from the local database.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 从本地数据库获取黑名单列表。
  ///
  /// **Return** 该方法调用成功会返回黑名单列表。
  ///
  /// **Throws**  如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [ChatError]。
  /// ~end
  Future<List<String>> getBlockListFromDB() async {
    try {
      Map result = await platform_interface.Client.instance.contactManager
          .callNativeMethod(ChatMethodKeys.getBlockListFromDB);
      ChatError.hasErrorFromResult(result);
      List<String> list = [];
      result[ChatMethodKeys.getBlockListFromDB]?.forEach((element) {
        if (element is String) {
          list.add(element);
        }
      });
      return list;
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Gets the block ids from the local database.
  ///
  /// **Return** The block list obtained from the local database.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 从本地数据库获取黑名单列表。
  ///
  /// **Return** 该方法调用成功会返回黑名单列表。
  ///
  /// **Throws**  如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [ChatError]。
  /// ~end

  Future<List<String>> getBlockIds() async {
    try {
      Map result = await platform_interface.Client.instance.contactManager
          .callNativeMethod(ChatMethodKeys.getBlockListFromDB);
      ChatError.hasErrorFromResult(result);
      List<String> list = [];
      result[ChatMethodKeys.getBlockListFromDB]?.forEach((element) {
        if (element is String) {
          list.add(element);
        }
      });
      return list;
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Accepts a friend invitation。
  ///
  /// Param [userId] The user who sends the friend invitation.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 接受加好友的邀请。
  ///
  /// Param [userId] 发起好友邀请的用户 ID。
  ///
  /// **Throws**  如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [ChatError]。
  /// ~end

  Future<void> acceptInvitation(String userId) async {
    try {
      Map req = {'userId': userId};
      Map result = await platform_interface.Client.instance.contactManager
          .callNativeMethod(ChatMethodKeys.acceptInvitation, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Declines a friend invitation.
  ///
  /// Param [userId] The user who sends the friend invitation.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 拒绝加好友的邀请。
  ///
  /// Param [userId] 发起好友邀请的用户 ID。
  ///
  /// **Throws**  如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [ChatError]。
  /// ~end

  Future<void> declineInvitation(String userId) async {
    try {
      Map req = {'userId': userId};
      Map result = await platform_interface.Client.instance.contactManager
          .callNativeMethod(ChatMethodKeys.declineInvitation, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Gets the unique IDs of the current user on the other devices. The ID is in the format of username + "/" + resource.
  ///
  /// **Return** The list of unique IDs of users on the other devices if the method succeeds.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 获取登录用户在其他登录设备上唯一 ID，该 ID 由 username + "/" + resource 组成。
  ///
  /// **Return** 该方法调用成功会返回 ID 列表。
  ///
  /// **Throws**  如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [ChatError]。
  /// ~end

  Future<List<String>> getSelfIdsOnOtherPlatform() async {
    try {
      Map result = await platform_interface.Client.instance.contactManager
          .callNativeMethod(ChatMethodKeys.getSelfIdsOnOtherPlatform);
      ChatError.hasErrorFromResult(result);
      List<String> devices = [];
      result[ChatMethodKeys.getSelfIdsOnOtherPlatform]?.forEach((element) {
        devices.add(element);
      });
      return devices;
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Gets all contacts from the local database.
  ///
  /// **Return** The contact list.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 获取本地存储的所有好友。
  ///
  /// **Return** 好友列表。
  ///
  /// **Throws** 如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [ChatError]。
  /// ~end

  Future<List<ChatContact>> getAllContacts() async {
    Map result = await platform_interface.Client.instance.contactManager
        .callNativeMethod(ChatMethodKeys.getAllContacts);
    try {
      ChatError.hasErrorFromResult(result);
      List<ChatContact> list = [];
      result[ChatMethodKeys.getAllContacts]?.forEach((element) {
        list.add(ChatContact.fromJson(element));
      });
      return list;
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Set the contact's remark.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 设置联系人备注。
  ///
  /// **Throws** 如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [ChatError]。
  /// ~end

  Future<void> setContactRemark({
    required String userId,
    required String remark,
  }) async {
    try {
      Map req = {'userId': userId, "remark": remark};
      Map result = await platform_interface.Client.instance.contactManager
          .callNativeMethod(ChatMethodKeys.setContactRemark, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Gets contact by userId.
  ///
  /// Param [userId] user id。
  ///
  /// **Return** The contact.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 获取联系人信息。
  ///
  /// Param [userId] 联系人Id。
  ///
  /// **Return** 联系下信息。
  ///
  /// **Throws** 如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [ChatError]。
  /// ~end

  Future<ChatContact?> getContact({required String userId}) async {
    try {
      Map req = {'userId': userId};
      Map result = await platform_interface.Client.instance.contactManager
          .callNativeMethod(ChatMethodKeys.getContact, req);
      ChatError.hasErrorFromResult(result);
      if (result.containsKey(ChatMethodKeys.getContact)) {
        return ChatContact.fromJson(result[ChatMethodKeys.getContact]);
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Gets all contacts from the server.
  ///
  /// **Return** The contact list.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 从服务器获取所有的好友。
  ///
  /// **Return** 好友列表。
  ///
  /// **Throws** 如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [ChatError]。
  /// ~end

  Future<List<ChatContact>> fetchAllContacts() async {
    try {
      Map result = await platform_interface.Client.instance.contactManager
          .callNativeMethod(ChatMethodKeys.fetchAllContacts);
      ChatError.hasErrorFromResult(result);
      List<ChatContact> list = [];
      result[ChatMethodKeys.fetchAllContacts]?.forEach((element) {
        list.add(ChatContact.fromJson(element));
      });
      return list;
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Gets the contact list from the server by page.
  ///
  /// Param [cursor] The cursor of the page, the first page can be passed in null.
  ///
  /// Param [pageSize] The size of the page.
  ///
  /// **Return** The contact result.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 从服务器分页获取友。
  ///
  /// Param [cursor] 分页的游标，第一页可以不传。
  ///
  /// Param [pageSize] 分页的大小。
  ///
  /// **Return** 好友列表获取结果。
  ///
  /// **Throws** 如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [ChatError]。
  /// ~end

  Future<ChatCursorResult<ChatContact>> fetchContacts({
    String? cursor,
    int pageSize = 20,
  }) async {
    try {
      Map map = {"pageSize": pageSize};
      map.putIfNotNull('cursor', cursor);
      Map result = await platform_interface.Client.instance.contactManager.callNativeMethod(
        ChatMethodKeys.fetchContacts,
        map,
      );
      ChatError.hasErrorFromResult(result);
      return ChatCursorResult.fromJson(result[ChatMethodKeys.fetchContacts],
          dataItemCallback: (map) {
        return ChatContact.fromJson(map);
      });
    } catch (e) {
      rethrow;
    }
  }
}
