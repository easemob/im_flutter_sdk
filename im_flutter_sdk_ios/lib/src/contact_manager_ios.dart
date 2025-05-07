import 'package:im_flutter_sdk_interface/im_flutter_sdk_interface.dart';

class ContactManagerIOS extends ContactManager {
  /// ~english
  /// Adds a new contact.
  ///
  /// Param [userId] The user to be added.
  ///
  /// Param [reason] (optional) The invitation message.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 添加联系人
  ///
  /// Param [userId] 要添加的好友的用户 ID。
  ///
  /// Param [reason] （可选）添加为好友的原因。
  ///
  /// **Throws**  如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [EMError]。
  /// ~end
  @override
  Future<void> addContact(
    String userId, {
    String? reason,
  }) async {
    Map req = {
      'userId': userId,
    };
    req.putIfNotNull("reason", reason);

    Map result =
        await ContactChannel.invokeMethod(ChatMethodKeys.addContact, req);
    try {
      EMError.hasErrorFromResult(result);
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
  /// **Throws** A description of the exception. See [EMError].
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
  /// **Throws**  如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [EMError]。
  /// ~end
  @override
  Future<void> deleteContact(
    String userId, {
    bool keepConversation = false,
  }) async {
    Map req = {'userId': userId, 'keepConversation': keepConversation};
    Map result =
        await ContactChannel.invokeMethod(ChatMethodKeys.deleteContact, req);
    try {
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  @override
  @Deprecated('Use fetchAllContactIds instead.')

  /// ~english
  /// Gets all the contact ids from the server.
  ///
  /// **Return** The list of contact ids.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 从服务器获取联系人列表。
  ///
  /// **Return** 联系人列表。
  ///
  /// **Throws**  如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [EMError]。
  /// ~end
  Future<List<String>> getAllContactsFromServer() async {
    Map result = await ContactChannel.invokeMethod(
        ChatMethodKeys.getAllContactsFromServer);
    try {
      EMError.hasErrorFromResult(result);
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
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 从服务器获取联系人列表。
  ///
  /// **Return** 联系人列表。
  ///
  /// **Throws**  如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [EMError]。
  /// ~end
  @override
  Future<List<String>> fetchAllContactIds() async {
    Map result = await ContactChannel.invokeMethod(
        ChatMethodKeys.getAllContactsFromServer);
    try {
      EMError.hasErrorFromResult(result);
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

  @override
  @Deprecated('Use getAllContactIds instead.')

  /// ~english
  /// Gets the contact ids from the local database.
  ///
  /// **Return** The contact list ids.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 从数据库获取好友列表。
  ///
  /// **Return** 调用成功会返回好友列表。
  ///
  /// **Throws**  如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [EMError]。
  /// ~end
  Future<List<String>> getAllContactsFromDB() async {
    Map result =
        await ContactChannel.invokeMethod(ChatMethodKeys.getAllContactsFromDB);
    try {
      EMError.hasErrorFromResult(result);
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
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 从数据库获取好友列表。
  ///
  /// **Return** 调用成功会返回好友列表。
  ///
  /// **Throws**  如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [EMError]。
  /// ~end
  @override
  Future<List<String>> getAllContactIds() async {
    Map result =
        await ContactChannel.invokeMethod(ChatMethodKeys.getAllContactsFromDB);
    try {
      EMError.hasErrorFromResult(result);
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
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 将指定用户加入黑名单。
  /// 你可以向黑名单中用户发消息，但是接收不到对方发送的消息。
  ///
  /// Param [userId] 要加入黑名单的用户的用户 ID。
  ///
  /// **Throws**  如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [EMError]。
  /// ~end
  @override
  Future<void> addUserToBlockList(
    String userId,
  ) async {
    Map req = {'userId': userId};
    Map result = await ContactChannel.invokeMethod(
      ChatMethodKeys.addUserToBlockList,
      req,
    );
    try {
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Removes the contact from the block ids.
  ///
  /// Param [userId] The contact to be removed from the block list.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 将指定用户移除黑名单。
  ///
  /// Param [userId] 要在黑名单中移除的用户 ID。
  ///
  /// **Throws**  如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [EMError]。
  /// ~end
  @override
  Future<void> removeUserFromBlockList(String userId) async {
    Map req = {'userId': userId};
    Map result = await ContactChannel.invokeMethod(
        ChatMethodKeys.removeUserFromBlockList, req);
    try {
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  @override
  @Deprecated('Use fetchBlockIds instead.')

  /// ~english
  /// Gets the block list from the server.
  ///
  /// **Return** The block list obtained from the server.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 从服务器获取黑名单列表。
  ///
  /// **Return** 该方法调用成功会返回黑名单列表。
  ///
  /// **Throws**  如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [EMError]。
  /// ~end
  Future<List<String>> getBlockListFromServer() async {
    Map result = await ContactChannel.invokeMethod(
        ChatMethodKeys.getBlockListFromServer);
    try {
      EMError.hasErrorFromResult(result);
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
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 从服务器获取黑名单列表。
  ///
  /// **Return** 该方法调用成功会返回黑名单列表。
  ///
  /// **Throws**  如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [EMError]。
  /// ~end
  @override
  Future<List<String>> fetchBlockIds() async {
    Map result = await ContactChannel.invokeMethod(
        ChatMethodKeys.getBlockListFromServer);
    try {
      EMError.hasErrorFromResult(result);
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

  @override
  @Deprecated('Use getBlockIds instead.')

  /// ~english
  /// Gets the block list from the local database.
  ///
  /// **Return** The block list obtained from the local database.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 从本地数据库获取黑名单列表。
  ///
  /// **Return** 该方法调用成功会返回黑名单列表。
  ///
  /// **Throws**  如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [EMError]。
  /// ~end
  Future<List<String>> getBlockListFromDB() async {
    Map result =
        await ContactChannel.invokeMethod(ChatMethodKeys.getBlockListFromDB);
    try {
      EMError.hasErrorFromResult(result);
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
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 从本地数据库获取黑名单列表。
  ///
  /// **Return** 该方法调用成功会返回黑名单列表。
  ///
  /// **Throws**  如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [EMError]。
  /// ~end
  @override
  Future<List<String>> getBlockIds() async {
    Map result =
        await ContactChannel.invokeMethod(ChatMethodKeys.getBlockListFromDB);
    try {
      EMError.hasErrorFromResult(result);
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
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 接受加好友的邀请。
  ///
  /// Param [userId] 发起好友邀请的用户 ID。
  ///
  /// **Throws**  如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [EMError]。
  /// ~end
  @override
  Future<void> acceptInvitation(String userId) async {
    Map req = {'userId': userId};
    Map result =
        await ContactChannel.invokeMethod(ChatMethodKeys.acceptInvitation, req);
    try {
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Declines a friend invitation.
  ///
  /// Param [userId] The user who sends the friend invitation.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 拒绝加好友的邀请。
  ///
  /// Param [userId] 发起好友邀请的用户 ID。
  ///
  /// **Throws**  如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [EMError]。
  /// ~end
  @override
  Future<void> declineInvitation(String userId) async {
    Map req = {'userId': userId};
    Map result = await ContactChannel.invokeMethod(
        ChatMethodKeys.declineInvitation, req);
    try {
      EMError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Gets the unique IDs of the current user on the other devices. The ID is in the format of username + "/" + resource.
  ///
  /// **Return** The list of unique IDs of users on the other devices if the method succeeds.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 获取登录用户在其他登录设备上唯一 ID，该 ID 由 username + "/" + resource 组成。
  ///
  /// **Return** 该方法调用成功会返回 ID 列表。
  ///
  /// **Throws**  如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [EMError]。
  /// ~end
  @override
  Future<List<String>> getSelfIdsOnOtherPlatform() async {
    Map result = await ContactChannel.invokeMethod(
        ChatMethodKeys.getSelfIdsOnOtherPlatform);
    try {
      EMError.hasErrorFromResult(result);
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
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 获取本地存储的所有好友。
  ///
  /// **Return** 好友列表。
  ///
  /// **Throws** 如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [EMError]。
  /// ~end
  @override
  Future<List<EMContact>> getAllContacts() async {
    Map result =
        await ContactChannel.invokeMethod(ChatMethodKeys.getAllContacts);
    try {
      EMError.hasErrorFromResult(result);
      List<EMContact> list = [];
      result[ChatMethodKeys.getAllContacts]?.forEach((element) {
        list.add(EMContact.fromJson(element));
      });
      return list;
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Set the contact's remark.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 设置联系人备注。
  ///
  /// **Throws** 如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [EMError]。
  /// ~end
  @override
  Future<void> setContactRemark({
    required String userId,
    required String remark,
  }) async {
    Map req = {'userId': userId, "remark": remark};
    Map result =
        await ContactChannel.invokeMethod(ChatMethodKeys.setContactRemark, req);
    try {
      EMError.hasErrorFromResult(result);
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
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 获取联系人信息。
  ///
  /// Param [userId] 联系人Id。
  ///
  /// **Return** 联系下信息。
  ///
  /// **Throws** 如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [EMError]。
  /// ~end
  @override
  Future<EMContact?> getContact({required String userId}) async {
    Map req = {'userId': userId};
    Map result =
        await ContactChannel.invokeMethod(ChatMethodKeys.getContact, req);
    try {
      EMError.hasErrorFromResult(result);
      if (result.containsKey(ChatMethodKeys.getContact)) {
        return EMContact.fromJson(result[ChatMethodKeys.getContact]);
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
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 从服务器获取所有的好友。
  ///
  /// **Return** 好友列表。
  ///
  /// **Throws** 如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [EMError]。
  /// ~end
  @override
  Future<List<EMContact>> fetchAllContacts() async {
    Map result =
        await ContactChannel.invokeMethod(ChatMethodKeys.fetchAllContacts);
    try {
      EMError.hasErrorFromResult(result);
      List<EMContact> list = [];
      result[ChatMethodKeys.fetchAllContacts]?.forEach((element) {
        list.add(EMContact.fromJson(element));
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
  /// **Throws** A description of the exception. See [EMError].
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
  /// **Throws** 如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 [EMError]。
  /// ~end
  @override
  Future<EMCursorResult<EMContact>> fetchContacts({
    String? cursor,
    int pageSize = 20,
  }) async {
    Map map = {"pageSize": pageSize};
    map.putIfNotNull('cursor', cursor);
    Map result = await ContactChannel.invokeMethod(
      ChatMethodKeys.fetchContacts,
      map,
    );
    try {
      EMError.hasErrorFromResult(result);
      return EMCursorResult.fromJson(result[ChatMethodKeys.fetchContacts],
          dataItemCallback: (map) {
        return EMContact.fromJson(map);
      });
    } catch (e) {
      rethrow;
    }
  }
}
