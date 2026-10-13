import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/rest_resource_client.dart';

void main() {
  test('REST resource client creates and deletes reusable resources', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final requests = <Map<String, Object?>>[];
    final serverDone = server.forEach((request) async {
      final text = await utf8.decoder.bind(request).join();
      requests.add({
        'method': request.method,
        'path': request.uri.path,
        'authorization': request.headers.value(HttpHeaders.authorizationHeader),
        'body': text.isEmpty ? null : jsonDecode(text),
      });
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode(_responseFor(request.uri.path)));
      await request.response.close();
    });
    final client = RestResourceClient(
      restApi: 'http://${server.address.host}:${server.port}',
      appKey: 'org#app',
      appToken: 'app-token',
    );

    try {
      expect(
        await client.createGroup(
          owner: 'user-a',
          name: 'group',
          members: const ['user-b'],
        ),
        'group-id',
      );
      expect(
        await client.createChatRoom(
          owner: 'user-a',
          name: 'room',
          description: 'description',
        ),
        'room-id',
      );
      expect(
        await client.sendGroupTextMessage(
          from: 'user-a',
          groupId: 'group-id',
          text: 'root',
        ),
        'message-id',
      );
      expect(
        await client.createThread(
          groupId: 'group-id',
          name: 'thread',
          owner: 'user-a',
          messageId: 'message-id',
        ),
        'thread-id',
      );
      await client.addThreadMembers('thread-id', const ['user-b']);
      await client.deleteThread('thread-id');
      await client.deleteChatRoom('room-id');
      await client.deleteGroup('group-id');
    } finally {
      client.close();
      await server.close(force: true);
      await serverDone;
    }

    expect(requests, hasLength(8));
    expect(
      requests.map((request) => '${request['method']} ${request['path']}'),
      <String>[
        'POST /org/app/chatgroups',
        'POST /org/app/chatrooms',
        'POST /org/app/messages/chatgroups',
        'POST /org/app/thread',
        'POST /org/app/thread/thread-id/users',
        'DELETE /org/app/thread/thread-id',
        'DELETE /org/app/chatrooms/room-id',
        'DELETE /org/app/chatgroups/group-id',
      ],
    );
    expect(
      requests.every(
        (request) => request['authorization'] == 'Bearer app-token',
      ),
      isTrue,
    );
    expect(
      (requests.first['body'] as Map)['members'],
      <String>['user-b'],
    );
  });

  test('REST resource client rejects an empty thread member batch', () {
    final client = RestResourceClient(
      restApi: 'https://example.invalid',
      appKey: 'org#app',
      appToken: 'app-token',
    );
    addTearDown(client.close);

    expect(
      () => client.addThreadMembers('thread-id', const []),
      throwsArgumentError,
    );
  });
}

Map<String, Object?> _responseFor(String path) {
  if (path.endsWith('/messages/chatgroups')) {
    return {
      'data': {'group-id': 'message-id'},
    };
  }
  if (path.endsWith('/chatgroups')) {
    return {
      'data': {'groupid': 'group-id'},
    };
  }
  if (path.endsWith('/chatrooms')) {
    return {
      'data': {'id': 'room-id'},
    };
  }
  if (path.endsWith('/thread')) {
    return {
      'data': {'thread_id': 'thread-id'},
    };
  }
  return {
    'data': {'status': 'ok'},
  };
}
