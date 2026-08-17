import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:im_flutter_sdk_interface/im_flutter_sdk_interface.dart';

import '../support/recording_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Client originalClient;
  late RecordingClient recordingClient;

  setUp(() {
    originalClient = Client.instance;
    recordingClient = RecordingClient((manager, method, arguments) async {
      return <String, Object>{
        'error': <String, Object>{
          'code': 201,
          'description': 'platform-specific text',
        },
      };
    });
    Client.instance = recordingClient;
  });

  tearDown(() {
    Client.instance = originalClient;
  });

  test('publishPresence forwards description and preserves error code',
      () async {
    await expectLater(
      EMClient.getInstance.presenceManager.publishPresence('busy'),
      throwsA(isA<EMError>().having((error) => error.code, 'code', 201)),
    );
    _expectOnlyCall(
      recordingClient,
      'publishPresenceWithDescription',
      <String, Object>{'desc': 'busy'},
    );
  });

  test('fetchPresenceStatus forwards members and preserves error code',
      () async {
    await expectLater(
      EMClient.getInstance.presenceManager.fetchPresenceStatus(
        members: <String>['user-a'],
      ),
      throwsA(isA<EMError>().having((error) => error.code, 'code', 201)),
    );
    _expectOnlyCall(recordingClient, 'fetchPresenceStatus', <String, Object>{
      'members': <String>['user-a'],
    });
  });

  test('subscribe forwards members and expiry and preserves error code',
      () async {
    await expectLater(
      EMClient.getInstance.presenceManager.subscribe(
        members: <String>['user-a'],
        expiry: 60,
      ),
      throwsA(isA<EMError>().having((error) => error.code, 'code', 201)),
    );
    _expectOnlyCall(recordingClient, 'presenceSubscribe', <String, Object>{
      'members': <String>['user-a'],
      'expiry': 60,
    });
  });

  test('unsubscribe forwards members and preserves error code', () async {
    await expectLater(
      EMClient.getInstance.presenceManager.unsubscribe(
        members: <String>['user-a'],
      ),
      throwsA(isA<EMError>().having((error) => error.code, 'code', 201)),
    );
    _expectOnlyCall(recordingClient, 'presenceUnsubscribe', <String, Object>{
      'members': <String>['user-a'],
    });
  });

  test('fetchSubscribedMembers forwards page data and preserves error code',
      () async {
    await expectLater(
      EMClient.getInstance.presenceManager.fetchSubscribedMembers(
        pageNum: 2,
        pageSize: 50,
      ),
      throwsA(isA<EMError>().having((error) => error.code, 'code', 201)),
    );
    _expectOnlyCall(
        recordingClient, 'fetchSubscribedMembersWithPageNum', <String, Object>{
      'pageNum': 2,
      'pageSize': 50,
    });
  });
}

void _expectOnlyCall(
  RecordingClient recordingClient,
  String method,
  Map<String, Object> arguments,
) {
  expect(recordingClient.calls, hasLength(1));
  final call = recordingClient.calls.single;
  expect(call.manager, 'presence');
  expect(call.method, method);
  expect(call.arguments, arguments);
}
