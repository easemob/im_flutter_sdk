import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:im_flutter_sdk_interface/im_flutter_sdk_interface.dart';

/// Captures the native-event handler [ChatClient] registers so a test can replay
/// exactly what the platform sends for a connection event.
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

  final received = <String>[];
  LoginExtensionInfo? receivedInfo;

  setUp(() {
    received.clear();
    receivedInfo = null;
    client.addConnectionEventHandler(
      'connection-event-test',
      ConnectionEventHandler(
        onConnected: () => received.add('onConnected'),
        onDisconnected: () => received.add('onDisconnected'),
        onUserDidLoginFromOtherDevice: (info) {
          received.add('onUserDidLoginFromOtherDevice');
          receivedInfo = info;
        },
        onUserDidRemoveFromServer: () =>
            received.add('onUserDidRemoveFromServer'),
        onUserDidForbidByServer: () => received.add('onUserDidForbidByServer'),
        onUserDidChangePassword: () => received.add('onUserDidChangePassword'),
        onUserDidLoginTooManyDevice: () =>
            received.add('onUserDidLoginTooManyDevice'),
        onUserKickedByOtherDevice: () =>
            received.add('onUserKickedByOtherDevice'),
        onUserAuthenticationFailed: () =>
            received.add('onUserAuthenticationFailed'),
      ),
    );
  });

  tearDown(() {
    client.removeConnectionEventHandler('connection-event-test');
  });

  test('forwards connected and disconnected to the matching callbacks',
      () async {
    await dispatch(const MethodCall(ChatMethodKeys.onConnected));
    await dispatch(const MethodCall(ChatMethodKeys.onDisconnected));

    expect(received, <String>['onConnected', 'onDisconnected']);
  });

  test('carries the device information of a login on another device', () async {
    await dispatch(const MethodCall(
      ChatMethodKeys.onUserDidLoginFromOtherDevice,
      <String, Object?>{'deviceName': 'Pixel 8', 'ext': '{"from":"other"}'},
    ));

    expect(received, <String>['onUserDidLoginFromOtherDevice']);
    expect(receivedInfo?.deviceName, 'Pixel 8');
    expect(receivedInfo?.ext, '{"from":"other"}');
  });

  test('forwards every server-side account event to its own callback',
      () async {
    const cases = <String, String>{
      ChatMethodKeys.onUserDidRemoveFromServer: 'onUserDidRemoveFromServer',
      ChatMethodKeys.onUserDidForbidByServer: 'onUserDidForbidByServer',
      ChatMethodKeys.onUserDidChangePassword: 'onUserDidChangePassword',
      ChatMethodKeys.onUserDidLoginTooManyDevice: 'onUserDidLoginTooManyDevice',
      ChatMethodKeys.onUserKickedByOtherDevice: 'onUserKickedByOtherDevice',
    };
    for (final entry in cases.entries) {
      received.clear();
      await dispatch(MethodCall(entry.key));
      expect(received, <String>[entry.value], reason: entry.key);
    }
  });

  test('authentication failure surfaces as a disconnection', () async {
    await dispatch(const MethodCall(ChatMethodKeys.onUserAuthenticationFailed));

    expect(received, <String>['onDisconnected']);
  });
}
