import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../integration_test/support/rest_fixture.dart';

void main() {
  const groupId = 'owned-ci-group';
  const existingGroup = <String, Object?>{
    'id': groupId,
    'name': 'CI group',
    'owner': 'owner-user',
  };
  late HttpServer server;
  late Future<void> serverDone;
  late CiRestFixture fixture;
  late _Reply reply;
  final requests = <({String method, Uri uri})>[];
  _Reply Function(HttpRequest)? respond;

  setUp(() async {
    requests.clear();
    respond = null;
    reply = _Reply.json({'data': <Object?>[]});
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    serverDone = server.forEach((request) async {
      await request.drain<void>();
      requests.add((method: request.method, uri: request.uri));
      final response = respond?.call(request) ?? reply;
      request.response
        ..statusCode = response.status
        ..headers.contentType = ContentType.json
        ..write(response.body);
      await request.response.close();
    });
    fixture = CiRestFixture(
      restApi: 'http://${server.address.host}:${server.port}',
      appKey: 'test-org#test-app',
      appToken: 'local-test-token',
    );
  });

  tearDown(() async {
    fixture.close();
    await server.close(force: true);
    await serverDone;
  });

  group('group absence evidence', () {
    test('valid detail is an existing group, not absence', () async {
      reply = _Reply.json({
        'data': [existingGroup]
      });
      expect(await fixture.group(groupId), existingGroup);
      expect(requests.single.method, 'GET');
      expect(
          requests.single.uri.path, '/test-org/test-app/chatgroups/$groupId');
    });

    test('accepts a matching groupid detail identifier', () async {
      final detail = {...existingGroup}..remove('id');
      detail['groupid'] = groupId;
      reply = _Reply.json({
        'data': [detail]
      });
      expect(await fixture.group(groupId), detail);
    });

    test('explicit 404 group_not_found proves absence', () async {
      reply = _Reply.json(
        {'error': 'group_not_found', 'error_description': 'No such group'},
        status: HttpStatus.notFound,
      );
      expect(await fixture.group(groupId), isNull);
      await fixture.verifyGroupAbsent(groupId);
      expect(requests, hasLength(2));
    });

    test('explicit service absence identifies the requested group', () async {
      reply = _Reply.json(
        {
          'error': 'service_resource_not_found',
          'error_description': 'do not find this group:$groupId',
        },
        status: HttpStatus.notFound,
      );
      expect(await fixture.group(groupId), isNull);
      await fixture.verifyGroupAbsent(groupId);
      expect(requests, hasLength(2));
    });

    for (final description in [
      'do not find this group:another-group',
      'do not find this group:${groupId}_another',
      'service unavailable',
    ]) {
      test('service 404 cannot prove cleanup with "$description"', () async {
        reply = _Reply.json(
          {
            'error': 'service_resource_not_found',
            'error_description': description,
          },
          status: HttpStatus.notFound,
        );
        await expectLater(
          fixture.verifyGroupAbsent(groupId),
          throwsA(predicate<Object>(
            (error) => error.toString().contains('HTTP 404'),
          )),
        );
        expect(requests, hasLength(1));
      });
    }

    test(
        'service absence text cannot turn an authentication failure into cleanup',
        () async {
      reply = _Reply.json(
        {
          'error': 'service_resource_not_found',
          'error_description': 'do not find this group:$groupId',
        },
        status: HttpStatus.unauthorized,
      );
      await expectLater(
        fixture.verifyGroupAbsent(groupId),
        throwsA(predicate<Object>(
          (error) => error.toString().contains('HTTP 401'),
        )),
      );
      expect(requests, hasLength(1));
    });

    test('matching resource-level missing result proves absence', () async {
      reply = _Reply.json({
        'data': [
          {'id': groupId, 'error': "group id doesn't exist"},
        ],
      });
      expect(await fixture.group(groupId), isNull);
      await fixture.verifyGroupAbsent(groupId);
      expect(requests, hasLength(2));
    });

    test('waits for explicit absence after observing an existing group',
        () async {
      respond = (_) => requests.length == 1
          ? _Reply.json({
              'data': [existingGroup]
            })
          : _Reply.json({'error': 'group_not_found'},
              status: HttpStatus.notFound);
      await fixture.verifyGroupAbsent(groupId);
      expect(requests, hasLength(2));
      expect(requests.every((request) => request.method == 'GET'), isTrue);
    });

    for (final failure in [
      (
        name: 'authentication failure',
        status: HttpStatus.unauthorized,
        code: 'invalid_token'
      ),
      (
        name: 'forbidden even with a missing-resource code',
        status: HttpStatus.forbidden,
        code: 'group_not_found'
      ),
      (
        name: 'unknown 404',
        status: HttpStatus.notFound,
        code: 'resource_not_found'
      ),
      (
        name: 'server failure even with a missing-resource code',
        status: HttpStatus.internalServerError,
        code: 'group_not_found'
      ),
    ]) {
      test('${failure.name} cannot prove cleanup', () async {
        reply = _Reply.json({'error': failure.code}, status: failure.status);
        await expectLater(
          fixture.verifyGroupAbsent(groupId),
          throwsA(predicate<Object>(
            (error) => error.toString().contains('HTTP ${failure.status}'),
            'REST failure with HTTP ${failure.status}',
          )),
        );
        expect(requests, hasLength(1),
            reason: 'Invalid evidence must fail immediately');
      });
    }

    for (final malformed in <({String name, Object? data})>[
      (name: 'missing data', data: null),
      (name: 'object instead of a list', data: existingGroup),
      (name: 'empty detail list', data: <Object?>[]),
      (name: 'multiple details', data: [existingGroup, existingGroup]),
      (name: 'non-object detail', data: ['missing']),
      (
        name: 'wrong resource ID',
        data: [
          {...existingGroup, 'id': 'another-group'}
        ]
      ),
      (
        name: 'missing resource ID',
        data: [
          {'name': 'CI group', 'owner': 'owner-user'}
        ]
      ),
      (
        name: 'missing owner',
        data: [
          {'id': groupId, 'name': 'CI group'}
        ]
      ),
      (
        name: 'invalid name',
        data: [
          {'id': groupId, 'name': 1, 'owner': 'owner-user'}
        ]
      ),
      (
        name: 'missing result for a different resource',
        data: [
          {'id': 'another-group', 'error': "group id doesn't exist"}
        ]
      ),
    ]) {
      test('${malformed.name} cannot prove cleanup', () async {
        reply = _Reply.json({'data': malformed.data});
        await expectLater(
            fixture.verifyGroupAbsent(groupId), throwsFormatException);
        expect(requests, hasLength(1));
      });
    }

    test('unknown resource-level error cannot prove cleanup', () async {
      reply = _Reply.json({
        'data': [
          {'id': groupId, 'error': 'backend unavailable'},
        ],
      });
      await expectLater(fixture.verifyGroupAbsent(groupId), throwsStateError);
      expect(requests, hasLength(1));
    });

    for (final invalid in [
      (name: 'invalid JSON', body: '<html>gateway error</html>'),
      (name: 'non-object JSON', body: '[]'),
    ]) {
      test('${invalid.name} cannot prove cleanup', () async {
        reply = _Reply(HttpStatus.notFound, invalid.body);
        await expectLater(
            fixture.verifyGroupAbsent(groupId), throwsFormatException);
        expect(requests, hasLength(1));
      });
    }

    test('a tolerated DELETE 404 does not replace independent absence proof',
        () async {
      respond = (_) =>
          _Reply.json({'error': 'unknown_route'}, status: HttpStatus.notFound);
      await fixture.deleteGroup(groupId);
      await expectLater(
        fixture.verifyGroupAbsent(groupId),
        throwsA(predicate<Object>(
            (error) => error.toString().contains('HTTP 404'))),
      );
      expect(requests.map((request) => request.method), ['DELETE', 'GET']);
    });
  });

  group('chatroom absence evidence', () {
    const roomId = 'owned-ci-room';
    test('reads the requested room and verifies its resource identity',
        () async {
      final room = {'id': roomId, 'name': 'CI room', 'owner': 'owner-user'};
      reply = _Reply.json({
        'data': [room]
      });
      expect(await fixture.chatRoom(roomId), room);
      expect(requests.single.uri.path, '/test-org/test-app/chatrooms/$roomId');
    });

    test('explicit resource missing response proves room absence', () async {
      reply = _Reply.json({'error': 'chatroom_not_found'},
          status: HttpStatus.notFound);
      await fixture.verifyChatRoomAbsent(roomId);
    });

    test('observed service absence uses group wording with the exact room ID',
        () async {
      reply = _Reply.json({
        'error': 'service_resource_not_found',
        'error_description': 'do not find this group:$roomId',
      }, status: HttpStatus.notFound);
      await fixture.verifyChatRoomAbsent(roomId);
      expect(requests, hasLength(1));
    });

    for (final description in [
      'do not find this group:another-room',
      'do not find this group:${roomId}_another',
      'service unavailable',
    ]) {
      test('unmatched service absence "$description" cannot prove room cleanup',
          () async {
        reply = _Reply.json({
          'error': 'service_resource_not_found',
          'error_description': description,
        }, status: HttpStatus.notFound);
        await expectLater(
            fixture.verifyChatRoomAbsent(roomId),
            throwsA(
              predicate<Object>(
                  (error) => error.toString().contains('HTTP 404')),
            ));
        expect(requests, hasLength(1));
      });
    }

    test(
        'matching service absence text cannot hide room authentication failure',
        () async {
      reply = _Reply.json({
        'error': 'service_resource_not_found',
        'error_description': 'do not find this group:$roomId',
      }, status: HttpStatus.unauthorized);
      await expectLater(
          fixture.verifyChatRoomAbsent(roomId),
          throwsA(
            predicate<Object>((error) => error.toString().contains('HTTP 401')),
          ));
      expect(requests, hasLength(1));
    });

    test('matching resource-level missing result proves room absence',
        () async {
      reply = _Reply.json({
        'data': [
          {'id': roomId, 'error': "chatroom id doesn't exist"}
        ]
      });
      await fixture.verifyChatRoomAbsent(roomId);
    });

    for (final failure in [
      (status: HttpStatus.unauthorized, code: 'chatroom_not_found'),
      (status: HttpStatus.forbidden, code: 'chatroom_not_found'),
      (status: HttpStatus.notFound, code: 'unknown_route'),
      (status: HttpStatus.internalServerError, code: 'chatroom_not_found'),
    ]) {
      test('HTTP ${failure.status} ${failure.code} cannot prove room cleanup',
          () async {
        reply = _Reply.json({'error': failure.code}, status: failure.status);
        await expectLater(
            fixture.verifyChatRoomAbsent(roomId),
            throwsA(
              predicate<Object>((error) =>
                  error.toString().contains('HTTP ${failure.status}')),
            ));
        expect(requests, hasLength(1));
      });
    }

    test('missing evidence for a different room cannot prove cleanup',
        () async {
      reply = _Reply.json({
        'data': [
          {'id': 'different-room', 'error': "chatroom id doesn't exist"}
        ]
      });
      await expectLater(
          fixture.verifyChatRoomAbsent(roomId), throwsFormatException);
    });

    test('empty detail list cannot prove room cleanup', () async {
      reply = _Reply.json({'data': <Object?>[]});
      await expectLater(
          fixture.verifyChatRoomAbsent(roomId), throwsFormatException);
    });
  });

  group('group membership evidence', () {
    test('reads each supported role and requests the complete small-group page',
        () async {
      reply = _Reply.json({
        'data': [
          {'owner': 'owner-user'},
          {'member': 'member-user'},
          {'admin': 'admin-user'},
        ],
        'cursor': '',
      });
      expect(await fixture.groupMembers(groupId),
          {'owner-user', 'member-user', 'admin-user'});
      expect(requests.single.uri.path,
          '/test-org/test-app/chatgroups/$groupId/users');
      expect(requests.single.uri.queryParameters, {'limit': '1000'});
    });

    for (final invalid in <({String name, Object? data})>[
      (name: 'non-list members', data: {'owner': 'owner-user'}),
      (name: 'plain user ID', data: ['member-user']),
      (
        name: 'unknown role',
        data: [
          {'moderator': 'member-user'}
        ]
      ),
      (name: 'empty object', data: [<String, Object?>{}]),
      (
        name: 'multiple role pairs',
        data: [
          {'owner': 'owner-user', 'member': 'member-user'}
        ]
      ),
      (
        name: 'empty user',
        data: [
          {'member': ''}
        ]
      ),
      (
        name: 'non-string user',
        data: [
          {'member': 42}
        ]
      ),
      (
        name: 'duplicate user across roles',
        data: [
          {'owner': 'same-user'},
          {'member': 'same-user'}
        ]
      ),
    ]) {
      test('rejects ${invalid.name}', () async {
        reply = _Reply.json({'data': invalid.data});
        await expectLater(fixture.groupMembers(groupId), throwsFormatException);
      });
    }

    test('an unfinished member page is not a complete membership result',
        () async {
      reply = _Reply.json({
        'data': [
          {'owner': 'owner-user'},
        ],
        'cursor': 'another-page',
      });
      await expectLater(fixture.groupMembers(groupId), throwsStateError);
    });
  });
}

final class _Reply {
  const _Reply(this.status, this.body);

  factory _Reply.json(Object? body, {int status = HttpStatus.ok}) =>
      _Reply(status, jsonEncode(body));

  final int status;
  final String body;
}
