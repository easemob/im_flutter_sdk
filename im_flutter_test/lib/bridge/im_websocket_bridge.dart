import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import '../protocol/response_normalizer.dart';
import '../runner/runner_info.dart';
import 'interface_router.dart';

const String kDefaultBridgeWebSocketBaseUrl =
    'ws://140.143.132.6:2000/iov/websocket/dual';
const String kDefaultBridgeWebSocketTopic = 'adc';

typedef OnBridgeLog = void Function(String request, String response);

class IMWebSocketBridge {
  IMWebSocketBridge._();

  static final IMWebSocketBridge instance = IMWebSocketBridge._();

  final InterfaceRouter _router = const InterfaceRouter();
  WebSocket? _socket;
  StreamSubscription<dynamic>? _subscription;
  Timer? _helloTimer;
  Timer? _reconnectTimer;
  RunnerInfo? _runnerInfo;
  Uri? _connectUri;
  bool _managed = false;
  bool _connecting = false;
  bool _stopped = true;

  OnBridgeLog? onLog;

  Future<void> start({
    String? url,
    String? topic,
    String? deviceName,
    RunnerInfo? runnerInfo,
    bool managed = false,
  }) async {
    if (runnerInfo != null) {
      _runnerInfo = runnerInfo;
    } else if (_runnerInfo == null && deviceName != null) {
      _runnerInfo = RunnerInfo(
        runnerId: deviceName,
        deviceName: deviceName,
        platform: 'android',
        sdkVersion: 'unknown',
        appVersion: 'unknown',
        capabilities: const {},
      );
    }
    _managed = managed || (_runnerInfo?.managedWebSocket ?? false);
    final baseUrl = url ?? kDefaultBridgeWebSocketBaseUrl;
    _connectUri = Uri.parse(
      _managed || baseUrl.contains('?')
          ? baseUrl
          : '$baseUrl?topic=${Uri.encodeComponent(topic ?? kDefaultBridgeWebSocketTopic)}',
    );
    _stopped = false;
    await _connect();
  }

  Future<void> _connect() async {
    if (_stopped || _connecting || isConnected || _connectUri == null) return;
    _connecting = true;
    try {
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 10);
      final socket = await WebSocket.connect(
        _connectUri.toString(),
        customClient: client,
      );
      if (_stopped) {
        await socket.close();
        return;
      }
      socket.pingInterval = const Duration(seconds: 20);
      _socket = socket;
      _subscription = socket.listen(
        _onMessage,
        onError: (Object error, StackTrace stackTrace) {
          _log('WebSocket error: $error');
        },
        onDone: () {
          _cleanupConnection();
          _scheduleReconnect();
        },
        cancelOnError: false,
      );
      _sendHello();
      _helloTimer?.cancel();
      _helloTimer = Timer.periodic(
        const Duration(seconds: 10),
        (_) => _sendHello(),
      );
      _log('connected: $_connectUri');
    } catch (error, stackTrace) {
      _log('connect failed: $error\n$stackTrace');
      _scheduleReconnect();
    } finally {
      _connecting = false;
    }
  }

  void _scheduleReconnect() {
    if (_stopped || _reconnectTimer?.isActive == true) return;
    _reconnectTimer = Timer(const Duration(seconds: 3), _connect);
  }

  Future<void> _onMessage(dynamic raw) async {
    final text = raw is String
        ? raw
        : raw is List<int>
            ? utf8.decode(raw)
            : raw?.toString() ?? '';
    if (text.isEmpty) return;

    Map<String, dynamic>? request;
    try {
      final decoded = jsonDecode(text);
      if (decoded is Map) {
        request = Map<String, dynamic>.from(decoded);
      }
    } catch (error) {
      final response = ResponseNormalizer.frameworkError(
        null,
        'Invalid JSON: $error',
      );
      _send(response);
      onLog?.call(text, jsonEncode(response));
      return;
    }
    if (request == null || _isResponseOrEvent(request)) return;

    final targetRunner = request['targetRunnerId']?.toString();
    final currentRunner = _runnerInfo?.runnerId;
    final targetDevice = request['device']?.toString();
    final currentDevice = _runnerInfo?.deviceName;
    if ((targetRunner != null &&
            currentRunner != null &&
            targetRunner != currentRunner) ||
        (targetDevice != null &&
            currentDevice != null &&
            targetDevice != currentDevice)) {
      return;
    }

    final manager = request['manager']?.toString();
    final cmd = request['cmd']?.toString();
    if (manager == null || cmd == null) {
      final response = ResponseNormalizer.frameworkError(
        request,
        'Missing manager or cmd',
      );
      _send(response);
      onLog?.call(text, jsonEncode(response));
      return;
    }

    Map<String, dynamic> response;
    try {
      _log(
        'requestId=${request['id']} manager=$manager cmd=$cmd '
        'platform=${_runnerInfo?.platform} sdkVersion=${_runnerInfo?.sdkVersion}',
      );
      final result = await _router.invokeSdkMethod(
        manager: manager,
        cmd: cmd,
        info: request['info'],
      );
      response = ResponseNormalizer.success(request, result);
    } catch (error, stackTrace) {
      response = ResponseNormalizer.frameworkError(
        request,
        error.toString(),
      );
      _log('invoke failed: $error\n$stackTrace');
    }
    _send(response);
    onLog?.call(text, jsonEncode(response));
  }

  bool _isResponseOrEvent(Map<String, dynamic> message) {
    return message['type'] == 'event' ||
        message['type'] == 'hello' ||
        message.containsKey('result') ||
        message.containsKey('error') ||
        message.containsKey('success');
  }

  void _sendHello() {
    final info = _runnerInfo;
    if (info == null || !isConnected) return;
    if (_managed) {
      _send({
        'type': 'hello',
        'protocolVersion': 1,
        ...info.toJson(),
      });
    } else {
      _send({
        // 旧中转服务兼容信封。
        'type': 'event',
        'eventType': 'runnerHello',
        'data': info.toJson(),
        'runnerHello': true,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  void sendEvent(String eventType, Map<String, dynamic> data) {
    if (!isConnected) return;
    _log('eventType=$eventType runnerId=${_runnerInfo?.runnerId}');
    _send({
      'type': 'event',
      'eventType': eventType,
      'data': ResponseNormalizer.jsonSafe(data),
      'runId': _runnerInfo?.runId,
      'runnerId': _runnerInfo?.runnerId,
      'device': _runnerInfo?.deviceName,
      'platform': _runnerInfo?.platform,
      'sdkVersion': _runnerInfo?.sdkVersion,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  void _send(Map<String, dynamic> payload) {
    final socket = _socket;
    if (socket == null || socket.closeCode != null) return;
    try {
      socket.add(jsonEncode(payload));
      if (payload.containsKey('result') || payload.containsKey('error')) {
        _log(
          'responseId=${payload['id']} manager=${payload['manager']} '
          'cmd=${payload['cmd']}',
        );
      }
    } catch (error) {
      _log('send failed: $error');
    }
  }

  Future<void> stop() async {
    _stopped = true;
    _reconnectTimer?.cancel();
    _helloTimer?.cancel();
    await _subscription?.cancel();
    await _socket?.close();
    _cleanupConnection();
  }

  void _cleanupConnection() {
    _subscription = null;
    _socket = null;
    _helloTimer?.cancel();
    _helloTimer = null;
  }

  bool get isConnected => _socket != null && _socket!.closeCode == null;

  void _log(String message) {
    developer.log(message, name: 'IMWebSocketBridge');
    // Android 实机验收时可直接通过 `adb logcat -s flutter` 定位连接问题。
    // ignore: avoid_print
    print('IMWebSocketBridge: $message');
  }
}
