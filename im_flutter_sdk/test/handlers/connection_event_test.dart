import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:im_flutter_sdk_interface/im_flutter_sdk_interface.dart';

/// Captures the native-event handler [ChatClient] registers so a test can replay
/// exactly what the platform sends for a disconnection.
final class _CapturingClient extends Client {
  Future<dynamic> Function(MethodCall call)? nativeEventHandler;

  @override
  void updateNativeHandler(
    Future<dynamic> Function(MethodCall call)? handler,
  ) {
    nativeEventHandler = handler;
  }

  @override
  Future<dynamic> callNativeMethod(String method, [dynamic params]) async {
    return <String, Object?>{};
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final capturingClient = _CapturingClient();
  late Future<dynamic> Function(MethodCall call) dispatch;
  late ChatClient client;

  setUpAll(() {
    // ChatClient registers its native-event handler when the singleton is first
    // created, so the capturing client must be installed before that.
    Client.instance = capturingClient;
    client = ChatClient.getInstance;
    dispatch = capturingClient.nativeEventHandler!;
  });

  late List<int?> receivedCodes;
  late List<LoginExtensionInfo?> receivedInfos;

  setUp(() {
    receivedCodes = <int?>[];
    receivedInfos = <LoginExtensionInfo?>[];
    client.addConnectionEventHandler(
      'connection-event-test',
      ConnectionEventHandler(
        onDisconnected: (errorCode, info) {
          receivedCodes.add(errorCode);
          receivedInfos.add(info);
        },
      ),
    );
  });

  tearDown(() {
    client.removeConnectionEventHandler('connection-event-test');
  });

  Future<void> sendDisconnected(Object? arguments) {
    return dispatch(MethodCall(ChatMethodKeys.onDisconnected, arguments));
  }

  test('passes the platform reason code through unchanged', () async {
    // 300 is the most common reason under an unstable network, 104 and 213 are
    // reasons that used to be dropped or mistaken for a network disconnection.
    for (final code in <int>[
      ChatDisconnectErrorCode.SERVER_NOT_REACHABLE,
      ChatDisconnectErrorCode.INVALID_TOKEN,
      ChatDisconnectErrorCode.USER_BIND_ANOTHER_DEVICE,
      ChatDisconnectErrorCode.APP_ACTIVE_NUMBER_REACH_LIMITATION,
    ]) {
      receivedCodes.clear();
      receivedInfos.clear();
      await sendDisconnected(<String, Object?>{'errorCode': code});
      expect(receivedCodes, <int?>[code], reason: 'reason code $code');
      expect(receivedInfos, <LoginExtensionInfo?>[null]);
    }
  });

  test('carries the device information of a login on another device', () async {
    await sendDisconnected(<String, Object?>{
      'errorCode': ChatDisconnectErrorCode.USER_LOGIN_ANOTHER_DEVICE,
      'deviceName': 'Pixel 8',
      'ext': '{"from":"other"}',
    });

    expect(receivedCodes, <int?>[206]);
    expect(receivedInfos.single?.deviceName, 'Pixel 8');
    expect(receivedInfos.single?.ext, '{"from":"other"}');
  });

  test('ignores the device information when the device name is empty',
      () async {
    await sendDisconnected(<String, Object?>{
      'errorCode': ChatDisconnectErrorCode.USER_LOGIN_ANOTHER_DEVICE,
      'deviceName': '',
      'ext': '',
    });

    expect(receivedCodes, <int?>[206]);
    expect(receivedInfos, <LoginExtensionInfo?>[null]);
  });

  test('a platform disconnection without a reason code yields null', () async {
    // iOS reports several disconnections without a reason code.
    await sendDisconnected(null);

    expect(receivedCodes, <int?>[null]);
    expect(receivedInfos, <LoginExtensionInfo?>[null]);
  });

  test('an unexpected payload neither throws nor invents a reason code',
      () async {
    // The reason code is only taken from an integer field, and the device
    // information is only built from a non-empty device name.
    final cases = <Object?, int?>{
      null: null,
      <String, Object?>{}: null,
      <String, Object?>{'deviceName': 'Pixel 8'}: null,
      <String, Object?>{'errorCode': 'not-a-number'}: null,
      <String, Object?>{'errorCode': null, 'deviceName': null, 'ext': null}:
          null,
      <String, Object?>{'errorCode': 206.0}: null,
    };
    for (final entry in cases.entries) {
      receivedCodes.clear();
      receivedInfos.clear();
      await sendDisconnected(entry.key);
      expect(receivedCodes, <int?>[entry.value],
          reason: 'payload ${entry.key}');
    }

    // A payload without a reason code but with a device name keeps the device
    // name, because the SDK passes the platform data through as it is.
    receivedCodes.clear();
    receivedInfos.clear();
    await sendDisconnected(<String, Object?>{'deviceName': 'Pixel 8'});
    expect(receivedCodes, <int?>[null]);
    expect(receivedInfos.single?.deviceName, 'Pixel 8');
  });

  test('the logout reason set matches the spec', () {
    // See docs/spec/2026-09-21-connection-event-normalization-spec.md §5.1.
    const expected = <int>{
      8,
      104,
      110,
      204,
      206,
      207,
      213,
      214,
      216,
      217,
      220,
      304,
      305,
    };
    expect(
      <int>{
        ChatDisconnectErrorCode.APP_ACTIVE_NUMBER_REACH_LIMITATION,
        ChatDisconnectErrorCode.INVALID_TOKEN,
        ChatDisconnectErrorCode.INVALID_PARAM,
        ChatDisconnectErrorCode.USER_NOT_FOUND,
        ChatDisconnectErrorCode.USER_LOGIN_ANOTHER_DEVICE,
        ChatDisconnectErrorCode.USER_REMOVED,
        ChatDisconnectErrorCode.USER_BIND_ANOTHER_DEVICE,
        ChatDisconnectErrorCode.USER_LOGIN_TOO_MANY_DEVICES,
        ChatDisconnectErrorCode.USER_KICKED_BY_CHANGE_PASSWORD,
        ChatDisconnectErrorCode.USER_KICKED_BY_OTHER_DEVICE,
        ChatDisconnectErrorCode.USER_DEVICE_CHANGED,
        ChatDisconnectErrorCode.SERVER_GET_DNSLIST_FAILED,
        ChatDisconnectErrorCode.SERVER_SERVICE_RESTRICTED,
      },
      expected,
    );
  });
}
