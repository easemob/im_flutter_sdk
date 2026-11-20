import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import '../../tool/rest_resource_client.dart';
import '../support/ci_test.dart';

import '../support/rest_fixture.dart';

void registerMessageCases({
  required ChatClient client,
  required String userId,
  required String peerId,
  required CiRestFixture rest,
}) {
  final manager = client.chatManager;
  var sequence = 0;

  String unique(String label) =>
      'ci_msg_${DateTime.now().microsecondsSinceEpoch}_${sequence++}_$label';

  String ownedConversation(String label) {
    final id = unique(label);
    addTearDown(() async {
      await manager.deleteConversation(id, deleteMessages: true);
      expect(await manager.getConversation(id, createIfNeed: false), isNull);
    });
    return id;
  }

  ChatMessage localMessage(
    String conversationId,
    String text, {
    required int timestamp,
    bool outgoing = false,
    bool custom = false,
  }) {
    final ChatMessageBody body = custom
        ? ChatCustomMessageBody(event: text)
        : ChatTextMessageBody(content: text);
    final message = outgoing
        ? ChatMessage.createSendMessage(to: conversationId, body: body)
        : ChatMessage.createReceiveMessage(body: body);
    message
      ..from = outgoing ? userId : conversationId
      ..to = outgoing ? conversationId : userId
      ..conversationId = conversationId
      ..status = MessageStatus.SUCCESS
      ..localTime = timestamp
      ..serverTime = timestamp
      ..attributes = <String, dynamic>{
        'fixture': conversationId,
        'time': timestamp
      };
    return ChatMessage.fromJson(<String, dynamic>{
      ...message.toJson(),
      'msgId': unique('local'),
    });
  }

  void expectMessage(ChatMessage? actual, ChatMessage expected) {
    expect(actual, isNotNull);
    expect(actual!.msgId, expected.msgId);
    expect(actual.conversationId, expected.conversationId);
    expect(actual.from, expected.from);
    expect(actual.to, expected.to);
    expect(actual.direction, expected.direction);
    expect(actual.body.type, expected.body.type);
    if (expected.body is ChatTextMessageBody) {
      expect(
        (actual.body as ChatTextMessageBody).content,
        (expected.body as ChatTextMessageBody).content,
      );
    } else if (expected.body is ChatCustomMessageBody) {
      expect(
        (actual.body as ChatCustomMessageBody).event,
        (expected.body as ChatCustomMessageBody).event,
      );
    }
    expect(actual.attributes, expected.attributes);
  }

  void expectMessages(List<ChatMessage> actual, List<ChatMessage> expected) {
    expect(
      actual.map((message) => message.msgId),
      unorderedEquals(expected.map((message) => message.msgId)),
    );
    for (final message in expected) {
      expectMessage(
        actual.singleWhere((item) => item.msgId == message.msgId),
        message,
      );
    }
  }

  /// Sends [message] and waits for the final callback correlated by local ID.
  /// Method completion alone only acknowledges submission.
  Future<ChatMessage> sendAndAwait(ChatMessage message, String caseId) async {
    final localId = message.msgId;
    final handlerId = unique('${caseId}_send_handler');
    final completion = Completer<({ChatMessage message, ChatError? error})>();
    manager.addMessageEvent(
      handlerId,
      ChatMessageEvent(
        onSuccess: (id, confirmed) {
          if (id == localId && !completion.isCompleted) {
            completion.complete((message: confirmed, error: null));
          }
        },
        onError: (id, failed, error) {
          if (id == localId && !completion.isCompleted) {
            completion.complete((message: failed, error: error));
          }
        },
      ),
    );
    addTearDown(() => manager.removeMessageEvent(handlerId));
    await manager.sendMessage(message).timeout(const Duration(seconds: 30));
    final result = await completion.future.timeout(
      const Duration(seconds: 90),
      onTimeout: () => throw TimeoutException(
        'No final send callback for $caseId local message $localId',
      ),
    );
    expect(result.error, isNull, reason: '$caseId server rejected the message');
    return result.message;
  }

  group('message positive', () {
    // Test: Prepare an unblocked friend, register a listener, and send it text
    // with known attributes; restore the original friendship/blacklists later.
    // Expected: The matching final callback succeeds with SUCCESS, a nonempty
    // ID, the configured sender/recipient, and original content/attributes; it is
    // readable locally and its conversation exists in the local list.
    // Server send confirmation does not prove delivery to the peer device.
    ciTestWidgets('FL-MSG-001 positive send receives final server confirmation',
        (
      tester,
    ) async {
      expect(peerId, isNotEmpty, reason: 'A prepared recipient is required');
      expect(peerId, isNot(userId));
      final relationship = await rest.snapshotContacts(userId, peerId);
      final userBlocks = await rest.blockIds(userId);
      final peerBlocks = await rest.blockIds(peerId);

      // Restore the relationship before restoring blocks. Separate callbacks
      // ensure that one restoration failure cannot prevent the others.
      addTearDown(() async {
        await rest.setBlocked(userId, peerId, userBlocks.contains(peerId));
        final restored = await waitForCi(
          'FL-MSG-001 original sender blacklist',
          () => rest.blockIds(userId),
          (ids) => setEquals(ids.toSet(), userBlocks.toSet()),
        );
        expect(restored, unorderedEquals(userBlocks));
        expect(await client.contactManager.fetchBlockIds(),
            unorderedEquals(userBlocks));
        debugPrint('CI FL-MSG-001 cleanup verified: sender blacklist');
      });
      addTearDown(() async {
        await rest.setBlocked(peerId, userId, peerBlocks.contains(userId));
        final restored = await waitForCi(
          'FL-MSG-001 original recipient blacklist',
          () => rest.blockIds(peerId),
          (ids) => setEquals(ids.toSet(), peerBlocks.toSet()),
        );
        expect(restored, unorderedEquals(peerBlocks));
        debugPrint('CI FL-MSG-001 cleanup verified: recipient blacklist');
      });
      addTearDown(() async {
        await rest.restoreContacts(userId, peerId, relationship);
        debugPrint('CI FL-MSG-001 cleanup verified: bilateral friendship');
      });

      await rest.setBlocked(userId, peerId, false);
      await rest.setBlocked(peerId, userId, false);
      final unblockedUser = userBlocks.where((id) => id != peerId).toSet();
      final unblockedPeer = peerBlocks.where((id) => id != userId).toSet();
      expect(await rest.blockIds(userId), unorderedEquals(unblockedUser));
      expect(await rest.blockIds(peerId), unorderedEquals(unblockedPeer));
      expect(await client.contactManager.fetchBlockIds(),
          unorderedEquals(unblockedUser));
      await rest.setContacts(userId, peerId, true);
      expect(await rest.contactIds(userId),
          unorderedEquals({...relationship.userIds, peerId}));
      expect(await rest.contactIds(peerId),
          unorderedEquals({...relationship.peerIds, userId}));
      debugPrint('CI FL-MSG-001 prepare verified: bilateral friendship and '
          'unblocked sender/recipient; unrelated members preserved');

      final content = unique('send');
      final message = ChatMessage.createTxtSendMessage(
        targetId: peerId,
        content: content,
      )..attributes = <String, dynamic>{'ciCase': 'FL-MSG-001', 'run': content};
      final localId = message.msgId;
      final handlerId = unique('send_handler');
      final completion = Completer<({ChatMessage message, ChatError? error})>();
      manager.addMessageEvent(
        handlerId,
        ChatMessageEvent(
          onSuccess: (id, confirmed) {
            if (id == localId && !completion.isCompleted) {
              completion.complete((message: confirmed, error: null));
            }
          },
          onError: (id, failed, error) {
            if (id == localId && !completion.isCompleted) {
              completion.complete((message: failed, error: error));
            }
          },
        ),
      );
      addTearDown(() => manager.removeMessageEvent(handlerId));

      // Method completion only acknowledges submission. The listener is already
      // installed, including when the final callback precedes the method result.
      debugPrint('CI FL-MSG-001 verify: correlated final server send callback');
      await manager.sendMessage(message).timeout(const Duration(seconds: 30));
      final result = await completion.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException(
          'No final send callback for FL-MSG-001 local message $localId',
        ),
      );
      expect(result.error, isNull, reason: 'Server rejected the message');
      final confirmed = result.message;
      expect(confirmed.status, MessageStatus.SUCCESS);
      expect(confirmed.msgId, isNotEmpty);
      expect(confirmed.from, userId);
      expect(confirmed.to, peerId);
      expect(confirmed.conversationId, peerId);
      expect((confirmed.body as ChatTextMessageBody).content, content);
      expect(confirmed.attributes, message.attributes);

      final conversation = await manager.getConversation(
        peerId,
        createIfNeed: false,
      );
      expect(conversation, isNotNull);
      expect(conversation!.id, peerId);
      expectMessage(await manager.loadMessage(confirmed.msgId), confirmed);
      expect(
        (await manager.loadAllConversations()).map((item) => item.id),
        contains(peerId),
      );
      debugPrint('CI FL-MSG-001 verify passed');
      // This peer can have preexisting history. Do not delete its conversation;
      // message/conversation global reclamation is outside this suite's scope.
    });

    // Test: Import three local messages, read selected IDs, then update one
    // message's body and full attributes map through ChatManager.
    // Expected: Reads match only the requested messages; the update persists
    // under the same ID and leaves the other two messages unchanged.
    ciTestWidgets('FL-MSG-002 positive import reads and updates owned messages',
        (
      tester,
    ) async {
      final id = ownedConversation('import');
      final first = localMessage(id, 'import incoming', timestamp: 1000);
      final second = localMessage(
        id,
        'import outgoing',
        timestamp: 2000,
        outgoing: true,
      );
      final unselected = localMessage(id, 'not requested', timestamp: 3000);
      await manager.importMessages(<ChatMessage>[first, second, unselected]);
      expectMessage(await manager.loadMessage(first.msgId), first);
      expectMessage(await manager.loadMessage(second.msgId), second);
      expectMessages(
        await manager
            .loadMessagesWithIds(<String>[second.msgId, first.msgId], id),
        <ChatMessage>[first, second],
      );

      final originalId = second.msgId;
      second
        ..body = ChatTextMessageBody(content: 'updated outgoing')
        // Submit the complete map; deletion by omission has no public contract.
        ..attributes = <String, dynamic>{
          ...?second.attributes,
          'time': 2001,
          'revision': 2,
        };
      await manager.updateMessage(second);
      final updated = await manager.loadMessage(originalId);
      expectMessage(updated, second);
      expect(updated!.msgId, originalId);
      expectMessage(await manager.loadMessage(first.msgId), first);
      expectMessage(await manager.loadMessage(unselected.msgId), unselected);
    });

    // Test: Import matching/nonmatching text across two conversations and query
    // loadMessagesWithKeyword with sender and Up/Down timestamp filters.
    // Expected: Each result has exactly the matching messages and their stored
    // fields; a unique absent keyword returns an empty list.
    ciTestWidgets('FL-MSG-003 positive keyword search filters sender and time',
        (
      tester,
    ) async {
      final a = ownedConversation('keyword_a');
      final b = ownedConversation('keyword_b');
      final keyword = unique('needle');
      final first = localMessage(a, '$keyword alpha', timestamp: 1000);
      final unrelated = localMessage(a, 'ordinary content', timestamp: 2000);
      final otherSender = localMessage(b, '$keyword beta', timestamp: 3000);
      final outgoing = localMessage(
        a,
        '$keyword gamma',
        timestamp: 4000,
        outgoing: true,
      );
      await manager.importMessages(<ChatMessage>[
        first,
        unrelated,
        otherSender,
        outgoing,
      ]);
      expectMessages(
        await manager.loadMessagesWithKeyword(keyword, count: 10),
        <ChatMessage>[first, otherSender, outgoing],
      );
      expectMessages(
        await manager.loadMessagesWithKeyword(keyword, sender: a, count: 10),
        <ChatMessage>[first],
      );
      expectMessages(
        await manager.loadMessagesWithKeyword(
          keyword,
          timestamp: 2500,
          count: 10,
          direction: ChatSearchDirection.Up,
        ),
        <ChatMessage>[first],
      );
      expectMessages(
        await manager.loadMessagesWithKeyword(
          keyword,
          timestamp: 2500,
          count: 10,
          direction: ChatSearchDirection.Down,
        ),
        <ChatMessage>[otherSender, outgoing],
      );
      expect(await manager.loadMessagesWithKeyword(unique('absent')), isEmpty);
    });

    // Test: Import text/custom messages from different senders and query
    // searchMsgsByOptions with type sets, sender, timestamp, and direction.
    // Expected: Results contain exactly the matching messages with their stored
    // fields, excluding other senders/types and the opposite time direction.
    ciTestWidgets(
        'FL-MSG-004 positive options search filters type sender and time', (
      tester,
    ) async {
      final a = ownedConversation('options_a');
      final b = ownedConversation('options_b');
      final first = localMessage(a, 'first text', timestamp: 1000);
      final second = localMessage(a, 'second text', timestamp: 2000);
      final custom =
          localMessage(a, 'ci_custom', timestamp: 3000, custom: true);
      final outgoing = localMessage(
        a,
        'outgoing text',
        timestamp: 4000,
        outgoing: true,
      );
      final otherSender = localMessage(b, 'other sender', timestamp: 5000);
      await manager.importMessages(<ChatMessage>[
        first,
        second,
        custom,
        outgoing,
        otherSender,
      ]);
      expectMessages(
        await manager.searchMsgsByOptions(
          MessageSearchOptions(
              types: const <MessageType>[MessageType.TXT], from: a),
        ),
        <ChatMessage>[first, second],
      );
      expectMessages(
        await manager.searchMsgsByOptions(
          MessageSearchOptions(
              types: const <MessageType>[MessageType.CUSTOM], from: a),
        ),
        <ChatMessage>[custom],
      );
      expectMessages(
        await manager.searchMsgsByOptions(
          MessageSearchOptions(
            types: const <MessageType>[MessageType.TXT, MessageType.CUSTOM],
            from: a,
          ),
        ),
        <ChatMessage>[first, second, custom],
      );
      expectMessages(
        await manager.searchMsgsByOptions(
          MessageSearchOptions(
            types: const <MessageType>[MessageType.TXT],
            from: a,
            ts: 1500,
          ),
        ),
        <ChatMessage>[first],
      );
      expectMessages(
        await manager.searchMsgsByOptions(
          MessageSearchOptions(
            types: const <MessageType>[MessageType.TXT],
            from: a,
            ts: 1500,
            direction: ChatSearchDirection.Down,
          ),
        ),
        <ChatMessage>[second],
      );
    });

    // Test: Seed matching/nonmatching messages in three conversations and query
    // loadConversationMessagesWithKeyword, including sender and time filters.
    // Expected: The map contains exactly matching conversation IDs and message
    // IDs, excluding nonmatches; an absent keyword returns an empty map.
    ciTestWidgets('FL-MSG-005 positive keyword aggregation maps matching IDs', (
      tester,
    ) async {
      final a = ownedConversation('aggregate_a');
      final b = ownedConversation('aggregate_b');
      final c = ownedConversation('aggregate_nonmatching');
      final keyword = unique('aggregate_needle');
      final first = localMessage(a, '$keyword alpha', timestamp: 1000);
      final second = localMessage(a, '$keyword beta', timestamp: 2000);
      final third = localMessage(b, '$keyword gamma', timestamp: 3000);
      final sameConversationNonmatch =
          localMessage(a, 'ordinary', timestamp: 4000);
      final nonmatching = localMessage(c, 'ordinary', timestamp: 5000);
      await manager.importMessages(<ChatMessage>[
        first,
        second,
        third,
        sameConversationNonmatch,
        nonmatching,
      ]);
      final matches = await manager.loadConversationMessagesWithKeyword(
        keyword: keyword,
      );
      expect(matches.keys, unorderedEquals(<String>[a, b]));
      expect(matches[a], unorderedEquals(<String>[first.msgId, second.msgId]));
      expect(matches[b], <String>[third.msgId]);

      final senderMatches = await manager.loadConversationMessagesWithKeyword(
        keyword: keyword,
        sender: a,
      );
      expect(senderMatches.keys, <String>[a]);
      expect(senderMatches[a],
          unorderedEquals(<String>[first.msgId, second.msgId]));

      final older = await manager.loadConversationMessagesWithKeyword(
        keyword: keyword,
        timestamp: 1500,
        direction: ChatSearchDirection.Up,
      );
      expect(older, <String, List<String>>{
        a: <String>[first.msgId]
      });
      expect(
        await manager.loadConversationMessagesWithKeyword(
            keyword: unique('absent')),
        isEmpty,
      );
    });
  });
  // Test: Consume one correlated REST group message, delete only that local
  // message, then prime the conversation cache with an older local sentinel.
  // Fetch history once with needSave=true.
  // Expected: The fetched history contains the correlated server message and
  // latestMessage advances from the sentinel to that message after saving.
  // Cleanup removes this case's remote group and local conversation.
  // An empty cache would miss the old Android bug because latestMessage could
  // read the new message from the DB.
  // The peer is an offline REST sender, not a second running SDK client.
  ciTestWidgets(
    'FL-MSG-010 saved server history replaces a stale latest message',
    (_) async {
      final resources = RestResourceClient(
        restApi: const String.fromEnvironment('E2E_REST_API'),
        appKey: const String.fromEnvironment('E2E_APP_KEY'),
        appToken: const String.fromEnvironment('E2E_APP_TOKEN'),
      );
      addTearDown(resources.close);
      final manager = client.chatManager;
      final run = 'ci_history_${DateTime.now().microsecondsSinceEpoch}';
      final ownedGroupIds = <String>{};
      String? groupId;

      // Register independent cleanup before creation. The remote cleanup runs
      // first and can discover an interrupted creation before local cleanup.
      addTearDown(() async {
        for (final id in ownedGroupIds) {
          await manager
              .deleteConversation(id, deleteMessages: true)
              .timeout(const Duration(seconds: 15));
          expect(
              await manager.getConversation(id,
                  type: ChatConversationType.GroupChat, createIfNeed: false),
              isNull);
        }
        debugPrint('CI FL-MSG-010 cleanup verified: owned local conversations');
      });
      addTearDown(() async {
        final ids = groupId == null
            ? await rest.groupIdsNamed(owner: userId, name: run)
            : [groupId];
        if (groupId == null && ids.isEmpty) {
          throw StateError('FL-MSG-010 cleanup unresolved creation: '
              'owner=$userId name=$run');
        }
        for (final id in ids) {
          final remote = await rest.group(id);
          if (remote != null) {
            if (remote['owner'] != userId ||
                remote['name'] != run ||
                remote['description'] != run) {
              throw StateError('FL-MSG-010 cleanup ownership mismatch: $id');
            }
            ownedGroupIds.add(id);
            await rest.deleteGroup(id);
          }
          await rest.verifyGroupAbsent(id);
        }
        debugPrint('CI FL-MSG-010 cleanup verified: owned REST groups');
      });

      groupId = await resources.createGroup(
          owner: userId,
          name: run,
          description: run,
          members: [peerId]).timeout(const Duration(seconds: 20));
      final id = groupId;
      ownedGroupIds.add(id);
      final expectedMembers = <String>{userId}..add(peerId);
      await waitForCi(
          'History fixture owner and peer are group members',
          () => rest.groupMembers(id),
          (members) => setEquals(members, expectedMembers));
      final detail = await client.groupManager
          .fetchGroupInfoFromServer(id)
          .timeout(const Duration(seconds: 20));
      expect(detail.groupId, id);
      expect(detail.owner, userId);

      final received = Completer<ChatMessage>();
      var consumedDelivery = false;
      final lateDeliveries = <String>[];
      manager.addEventHandler(
        run,
        ChatEventHandler(onMessagesReceived: (messages) {
          for (final message in messages) {
            final body = message.body;
            if (message.conversationId != id ||
                message.from != peerId ||
                message.chatType != ChatType.GroupChat ||
                body is! ChatTextMessageBody ||
                body.content != run) {
              continue;
            }
            if (consumedDelivery) lateDeliveries.add(message.msgId);
            if (!received.isCompleted) received.complete(message);
          }
        }),
      );
      addTearDown(() => manager.removeEventHandler(run));

      debugPrint('CI FL-MSG-010 prepare: REST group=$id, unique incoming text');
      final serverId = await resources
          .sendGroupTextMessage(from: peerId, groupId: id, text: run)
          .timeout(const Duration(seconds: 20));
      final incoming =
          await received.future.timeout(const Duration(seconds: 30));
      expect(incoming.msgId, serverId,
          reason: 'Consume this exact online delivery before deleting locally');
      expect(incoming.status, MessageStatus.SUCCESS);
      consumedDelivery = true;

      final conversation = await manager.getConversation(id,
          type: ChatConversationType.GroupChat, createIfNeed: false);
      expect(conversation, isNotNull);
      await conversation!.deleteMessage(serverId);
      final sentinelBody = ChatMessage.createTxtSendMessage(
        targetId: id,
        content: '$run local old sentinel',
        chatType: ChatType.GroupChat,
      )
        ..from = userId
        ..conversationId = id
        ..localTime = 1
        ..serverTime = 1
        ..status = MessageStatus.SUCCESS;
      final sentinel = ChatMessage.fromJson({
        ...sentinelBody.toJson(),
        'msgId': '${run}_sentinel',
      });
      await conversation.insertMessage(sentinel);
      expect((await conversation.latestMessage())?.msgId, sentinel.msgId,
          reason: 'A stale populated cache is the precondition under test');
      expect(lateDeliveries, isEmpty,
          reason: 'A repeated live delivery invalidates the history fixture');

      debugPrint('CI FL-MSG-010 verify: fetch once with needSave=true');
      final page = await manager
          .fetchHistoryMessagesByOption(
            id,
            ChatConversationType.GroupChat,
            options: const FetchMessageOptions(needSave: true),
            pageSize: 20,
          )
          .timeout(const Duration(seconds: 30));
      final matches = page.data.where((message) => message.msgId == serverId);
      expect(matches, hasLength(1));
      final fetched = matches.single;
      expect(fetched.conversationId, id);
      expect(fetched.from, peerId);
      expect((fetched.body as ChatTextMessageBody).content, run);
      expect(fetched.serverTime, greaterThan(sentinel.serverTime));
      final latest = await conversation.latestMessage();
      expect(lateDeliveries, isEmpty,
          reason:
              'Live delivery must not satisfy the history update assertion');
      expect(latest?.msgId, serverId);
      expect((latest!.body as ChatTextMessageBody).content, run);
      debugPrint(
          'CI FL-MSG-010 verify passed: stale cache advanced to REST ID');
    },
  );

  // Test: Upload one real file and one real image to the prepared peer and
  // await each correlated final callback.
  // Expected: Both final callbacks succeed with server IDs; stored file and
  // image bodies carry server paths, secrets and sizes, and loading them back
  // keeps the server attachment fields. This is local persistence plus upload
  // confirmation, not delivery to a second online client.
  ciTestWidgets(
    'FL-MSG-011 positive file and image uploads expose server attachment',
    (_) async {
      final dir = Directory.systemTemp.createTempSync('ci_msg11_');
      addTearDown(() => dir.deleteSync(recursive: true));
      final run = unique('upload');
      final payload = List<int>.generate(512, (index) => index % 251);
      final source = File('${dir.path}/$run.txt');
      await source.writeAsBytes(payload);
      final fileMessage = ChatMessage.createFileSendMessage(
        targetId: peerId,
        filePath: source.path,
        displayName: '$run.txt',
        fileSize: payload.length,
      );
      final fileConfirmed = await sendAndAwait(fileMessage, 'FL-MSG-011 file');
      expect(fileConfirmed.status, MessageStatus.SUCCESS);
      expect(fileConfirmed.msgId, isNotEmpty);
      final fileBody = fileConfirmed.body as ChatFileMessageBody;
      expect(fileBody.type, MessageType.FILE);
      expect(fileBody.displayName, '$run.txt');
      expect(fileBody.fileSize, payload.length);
      expect(fileBody.remotePath, isNotNull);
      expect(fileBody.secret, isNotNull);
      final storedFile = await manager.loadMessage(fileConfirmed.msgId);
      expect(storedFile, isNotNull);
      final storedFileBody = storedFile!.body as ChatFileMessageBody;
      expect(storedFileBody.remotePath, fileBody.remotePath);
      expect(storedFileBody.secret, fileBody.secret);
      expect(storedFileBody.fileSize, payload.length);

      final png = base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR4'
        '2mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
      );
      final image = File('${dir.path}/$run.png');
      await image.writeAsBytes(png);
      final imageMessage = ChatMessage.createImageSendMessage(
        targetId: peerId,
        filePath: image.path,
        displayName: '$run.png',
        fileSize: png.length,
        width: 1,
        height: 1,
      );
      final imageConfirmed =
          await sendAndAwait(imageMessage, 'FL-MSG-011 image');
      expect(imageConfirmed.status, MessageStatus.SUCCESS);
      final imageBody = imageConfirmed.body as ChatImageMessageBody;
      expect(imageBody.type, MessageType.IMAGE);
      // Native may normalize or re-encode an image, so only the presence and
      // positivity of the reported size are guaranteed here.
      expect(imageBody.fileSize, isNotNull);
      expect(imageBody.fileSize, greaterThan(0));
      expect(imageBody.remotePath, isNotNull);
      expect(imageBody.secret, isNotNull);
      expect(imageBody.width, 1);
      expect(imageBody.height, 1);
    },
  );

  // Test: Upload a real file to the peer, import a received copy pointing at a
  // fresh local path, remove that file, then download the attachment.
  // Expected: downloadAttachment reports a terminal success callback and the
  // local file is restored with bytes identical to the uploaded payload; the
  // returned method result alone is not used as completion evidence.
  ciTestWidgets(
    'FL-MSG-012 positive attachment download restores the local file',
    (_) async {
      final dir = Directory.systemTemp.createTempSync('ci_msg12_');
      addTearDown(() => dir.deleteSync(recursive: true));
      final run = unique('download');
      final payload = List<int>.generate(256, (index) => 255 - index % 256);
      final source = File('${dir.path}/$run.source');
      await source.writeAsBytes(payload);
      final draft = ChatMessage.createFileSendMessage(
        targetId: peerId,
        filePath: source.path,
        displayName: '$run.source',
        fileSize: payload.length,
      );
      final confirmed = await sendAndAwait(draft, 'FL-MSG-012 upload');
      final uploaded = confirmed.body as ChatFileMessageBody;
      expect(uploaded.remotePath, isNotNull);
      expect(uploaded.secret, isNotNull);

      final conversationId = ownedConversation('download_target');
      final localPath = '${dir.path}/$run.received';
      final localId = unique('download_received');
      final json = Map<String, dynamic>.from(confirmed.toJson());
      final body = Map<String, dynamic>.from(json['body'] as Map);
      body['localPath'] = localPath;
      body['fileStatus'] = DownloadStatus.PENDING.index;
      json['body'] = body;
      json['msgId'] = localId;
      json['conversationId'] = conversationId;
      json['from'] = peerId;
      json['to'] = userId;
      json['direction'] = MessageDirection.RECEIVE.index;
      json['status'] = MessageStatus.SUCCESS.index;
      final received = ChatMessage.fromJson(json);
      await manager.importMessages(<ChatMessage>[received]);
      final loaded = await manager.loadMessage(localId);
      expect(loaded, isNotNull);
      final loadedBody = loaded!.body as ChatFileMessageBody;
      expect(loadedBody.remotePath, uploaded.remotePath);
      expect(loadedBody.secret, uploaded.secret);
      final target = File(localPath);
      if (target.existsSync()) {
        target.deleteSync();
      }
      expect(target.existsSync(), isFalse);

      final handlerId = unique('download_handler');
      final completion = Completer<({ChatMessage message, ChatError? error})>();
      manager.addMessageEvent(
        handlerId,
        ChatMessageEvent(
          onSuccess: (id, message) {
            if (id == localId && !completion.isCompleted) {
              completion.complete((message: message, error: null));
            }
          },
          onError: (id, message, error) {
            if (id == localId && !completion.isCompleted) {
              completion.complete((message: message, error: error));
            }
          },
        ),
      );
      addTearDown(() => manager.removeMessageEvent(handlerId));
      await manager
          .downloadAttachment(loaded)
          .timeout(const Duration(seconds: 30));
      final result = await completion.future.timeout(
        const Duration(seconds: 90),
        onTimeout: () => throw TimeoutException(
          'No attachment download callback for $localId',
        ),
      );
      expect(result.error, isNull);
      final downloadedBody = result.message.body as ChatFileMessageBody;
      expect(downloadedBody.fileStatus, DownloadStatus.SUCCESS);
      expect(downloadedBody.localPath, isNotEmpty);
      // Native may resolve the payload path itself, so verify the file at the
      // path it reports rather than assuming the requested path was kept.
      final restored = downloadedBody.localPath == localPath
          ? target
          : File(downloadedBody.localPath);
      await waitForCi(
        'downloaded file exists at the reported local path',
        () async => restored.existsSync(),
        (value) => value,
      );
      expect(await restored.readAsBytes(), payload);
    },
  );

  // Test: Deliver five real one-to-one messages from the offline peer over
  // REST, then page server history with pageSize=2 until the empty cursor.
  // Expected: Each delivered ID appears exactly once, pages respect the limit
  // and cursors never repeat, every timestamp sequence stays monotonic across
  // pages, and the traversal needs more than one page.
  ciTestWidgets(
    'FL-MSG-013 positive server history pagination is complete and ordered',
    (_) async {
      final run = unique('history_page');
      final ids = <String>[];
      for (var index = 0; index < 5; index++) {
        ids.add(await rest.sendTextMessage(
          from: peerId,
          to: userId,
          text: '$run $index',
        ));
      }
      expect(ids.toSet(), hasLength(5));
      await waitForCi(
        'server history contains all five delivered messages',
        () async {
          final page = await manager.fetchHistoryMessagesByOption(
            peerId,
            ChatConversationType.Chat,
            pageSize: 25,
          );
          final seen = page.data.map((message) => message.msgId).toSet();
          return ids.every(seen.contains);
        },
        (value) => value,
      );

      final seen = <String>{};
      final ordered = <ChatMessage>[];
      var cursor = '';
      var reachedEnd = false;
      var pageCount = 0;
      for (var index = 0; index < 200; index++) {
        final page = cursor.isEmpty
            ? await manager.fetchHistoryMessagesByOption(
                peerId,
                ChatConversationType.Chat,
                pageSize: 2,
              )
            : await manager.fetchHistoryMessagesByOption(
                peerId,
                ChatConversationType.Chat,
                cursor: cursor,
                pageSize: 2,
              );
        pageCount++;
        expect(page.data.length, lessThanOrEqualTo(2));
        for (final message in page.data) {
          expect(seen.add(message.msgId), isTrue,
              reason: 'Server history repeated ${message.msgId}');
          ordered.add(message);
        }
        final next = page.cursor;
        if (next == null || next.isEmpty) {
          reachedEnd = true;
          break;
        }
        expect(next, isNot(cursor), reason: 'Server history repeated a cursor');
        cursor = next;
      }
      expect(reachedEnd, isTrue,
          reason: 'Server history did not terminate within 200 pages');
      expect(pageCount, greaterThan(1),
          reason: 'Fixture must span more than one server page');
      final ours =
          ordered.where((message) => ids.contains(message.msgId)).toList();
      expect(ours, hasLength(5));

      var descending = true;
      var ascending = true;
      for (var index = 1; index < ordered.length; index++) {
        if (ordered[index].serverTime > ordered[index - 1].serverTime) {
          descending = false;
        }
        if (ordered[index].serverTime < ordered[index - 1].serverTime) {
          ascending = false;
        }
      }
      expect(descending || ascending, isTrue,
          reason: 'Server history pages must not interleave timestamps');
    },
  );

  // Test: Send one real message, pin it, read the server pinned list and the
  // pin metadata, then unpin it.
  // Expected: The pinned list reports the message with this operator and a
  // positive pin time, and drops it after unpinning. This is the server pin
  // round-trip; it does not prove another client's pinned view.
  ciTestWidgets(
    'FL-MSG-014 positive pins and unpins a server message',
    (_) async {
      final run = unique('pin');
      final sent = await sendAndAwait(
        ChatMessage.createTxtSendMessage(
          targetId: peerId,
          content: '$run text',
        ),
        'FL-MSG-014 send',
      );
      expect(sent.status, MessageStatus.SUCCESS);
      final id = sent.msgId;
      var pinned = false;
      addTearDown(() async {
        if (!pinned) return;
        try {
          await manager.unpinMessage(messageId: id);
        } catch (_) {
          // Best effort; the primary assertion already ran.
        }
      });
      await manager.pinMessage(messageId: id);
      pinned = true;
      final pinnedList = await waitForCi(
        'server pinned list contains the sent message',
        () => manager.fetchPinnedMessages(conversationId: peerId),
        (list) => list.any((message) => message.msgId == id),
      );
      final stored = pinnedList.singleWhere((message) => message.msgId == id);
      final info = await stored.pinInfo();
      expect(info, isNotNull);
      expect(info!.operatorId, userId);
      expect(info.pinTime, greaterThan(0));
      await manager.unpinMessage(messageId: id);
      pinned = false;
      await waitForCi(
        'server pinned list drops the unpinned message',
        () => manager.fetchPinnedMessages(conversationId: peerId),
        (list) => !list.any((message) => message.msgId == id),
      );
    },
  );

  // Test: Send one real message, add a Reaction, read it through the server
  // list, the detail page and the loaded local message, then remove it.
  // Expected: The Reaction is reported once as added by this user with the
  // user in the detail page and disappears from the server list on removal.
  ciTestWidgets(
    'FL-MSG-015 positive adds and removes a message reaction',
    (_) async {
      final run = unique('reaction');
      const reaction = 'ci_like';
      final sent = await sendAndAwait(
        ChatMessage.createTxtSendMessage(
          targetId: peerId,
          content: '$run text',
        ),
        'FL-MSG-015 send',
      );
      final id = sent.msgId;
      var added = false;
      addTearDown(() async {
        if (!added) return;
        try {
          await manager.removeReaction(messageId: id, reaction: reaction);
        } catch (_) {
          // Best effort; the primary assertion already ran.
        }
      });
      await manager.addReaction(messageId: id, reaction: reaction);
      added = true;
      final reactions = await waitForCi(
        'server reaction list reports the added reaction',
        () => manager
            .fetchReactionList(messageIds: [id], chatType: ChatType.Chat),
        (map) => (map[id] ?? const <ChatMessageReaction>[]).any((item) =>
            item.reaction == reaction &&
            item.isAddedBySelf &&
            item.userCount >= 1),
      );
      final item = (reactions[id] ?? const <ChatMessageReaction>[])
          .singleWhere((entry) => entry.reaction == reaction);
      expect(item.userCount, greaterThanOrEqualTo(1));
      final detail = await manager.fetchReactionDetail(
        messageId: id,
        reaction: reaction,
      );
      expect(detail.data.map((entry) => entry.reaction), contains(reaction));
      expect(detail.data.expand((entry) => entry.userList), contains(userId));
      final local = await manager.loadMessage(id);
      expect(local, isNotNull);
      expect(
        (await local!.reactionList()).map((entry) => entry.reaction),
        contains(reaction),
      );
      await manager.removeReaction(messageId: id, reaction: reaction);
      added = false;
      await waitForCi(
        'server reaction list drops the removed reaction',
        () => manager
            .fetchReactionList(messageIds: [id], chatType: ChatType.Chat),
        (map) => !(map[id] ?? const <ChatMessageReaction>[])
            .any((entry) => entry.reaction == reaction && entry.isAddedBySelf),
      );
    },
  );
}
