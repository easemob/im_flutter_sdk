import 'dart:convert';
import 'dart:io';

import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:path_provider/path_provider.dart';

import '../listeners.dart';
import '../log/log_store.dart';
import '../options_codec.dart';
import '../registry/api_entry.dart';
import '../registry/registry.dart';
import '../sdk_state.dart';

/// AI automation script mode: enter via `--dart-define=API_SCRIPT=<host file absolute path>`.
/// Automatically executes init -> login -> sequential steps; all results go through the same structured log channel;
/// no step failure interrupts the flow; outputs script.done on completion; App keeps running.
///
/// Test data is separated from the script: `--dart-define=API_CONFIG=<config.json absolute path>`,
/// defaults to config.json in the same directory as the script (empty config if not found).
/// - init: ChatOptions keys in config (see [_optionKeys]) as base, script init overrides;
/// - login: script login takes priority, otherwise derived from config loginUser + loginToken/loginPassword.
///
/// Parameter string references (replaced only on exact full-string match, preserving original value types):
/// - `$config.key` / `$config.key.sub`: value from config.json;
/// - `$prev` / `$prev.a.b`: data returned by the previous step, dot path for nesting (numeric index for lists);
/// - `$step.id` / `$step.id.a.b`: data from a step with "id", cross-step reference.
class AutoMode {
  static const String scriptPath =
      String.fromEnvironment('API_SCRIPT', defaultValue: '');
  static const String configPath =
      String.fromEnvironment('API_CONFIG', defaultValue: '');

  static bool get enabled => scriptPath.isNotEmpty;

  /// Default per-step timeout (can be overridden by step's "timeoutMs").
  static const int defaultStepTimeoutMs = 30000;

  /// ChatOptions keys that init can inherit from config.json.
  static const List<String> _optionKeys = [
    'appKey',
    'autoLogin',
    'debugMode',
    'enableUserInfo',
    'enableAutoSyncContacts',
  ];

  static Object? _dig(Object? v, List<String> path) {
    var cur = v;
    for (final key in path) {
      if (cur is Map) {
        cur = cur[key];
      } else if (cur is List) {
        final i = int.tryParse(key);
        if (i == null || i < 0 || i >= cur.length) return null;
        cur = cur[i];
      } else {
        return null;
      }
    }
    return cur;
  }

  static Object? _resolveRefs(
    Object? v,
    Object? prev,
    Map<String, dynamic> config,
    Map<String, Object?> stepData,
  ) {
    if (v is String) {
      if (v == r'$prev') return prev;
      if (v.startsWith(r'$prev.')) return _dig(prev, v.substring(6).split('.'));
      if (v == r'$config') return config;
      if (v.startsWith(r'$config.')) {
        return _dig(config, v.substring(8).split('.'));
      }
      if (v.startsWith(r'$step.')) {
        final parts = v.substring(6).split('.');
        return _dig(stepData[parts.first], parts.sublist(1));
      }
      return v;
    }
    if (v is Map) {
      return v.map(
        (k, val) => MapEntry(k, _resolveRefs(val, prev, config, stepData)),
      );
    }
    if (v is List) {
      return v.map((e) => _resolveRefs(e, prev, config, stepData)).toList();
    }
    return v;
  }

  static Future<Map<String, dynamic>> _loadJsonFile(String path) async {
    return Map<String, dynamic>.from(
      jsonDecode(await File(path).readAsString()) as Map,
    );
  }

  /// Auto-mode only (not registered): writes base64 content to the documents directory,
  /// for use as localPath when constructing image/voice messages.
  static Future<Map<String, dynamic>> _writeBase64File(
    Map<String, dynamic> p,
  ) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final fileName = p['fileName'] as String;
      final bytes = base64Decode(p['base64'] as String);
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes, flush: true);
      return {
        'success': true,
        'data': {'path': file.path, 'bytes': bytes.length},
      };
    } catch (e) {
      return {
        'success': false,
        'error': errorToJson(e),
      };
    }
  }

  static Future<void> run() async {
    final store = LogStore.instance;

    // config.json: default init/login and $config reference data source for the script.
    var config = <String, dynamic>{};
    var effectiveConfigPath = configPath;
    if (effectiveConfigPath.isEmpty) {
      final sibling = '${File(scriptPath).parent.path}/config.json';
      if (File(sibling).existsSync()) effectiveConfigPath = sibling;
    }
    if (effectiveConfigPath.isNotEmpty) {
      try {
        config = await _loadJsonFile(effectiveConfigPath);
        store.log('config.load', {
          'path': effectiveConfigPath,
          'keys': config.keys.toList(),
        });
      } catch (e) {
        store.log('config.load', {
          'path': effectiveConfigPath,
          'error': errorToJson(e),
        });
      }
    }

    Map<String, dynamic> script;
    try {
      script = await _loadJsonFile(scriptPath);
    } catch (e) {
      store.log('script.error', {'stage': 'read', 'error': errorToJson(e)});
      store.log('script.done', {'total': 0, 'failed': 0});
      return;
    }
    store.log('script.start', {'path': scriptPath});

    // init: ChatOptions keys from config as base, script init overrides.
    try {
      final initJson = <String, dynamic>{
        for (final k in _optionKeys)
          if (config.containsKey(k)) k: config[k],
      };
      final sInit = script['init'];
      if (sInit is Map) initJson.addAll(Map<String, dynamic>.from(sInit));
      final resolved = Map<String, dynamic>.from(
        _resolveRefs(initJson, null, config, const {}) as Map,
      );
      await ChatClient.getInstance.init(emOptionsFromJson(resolved));
      registerAllListeners();
      SdkState.instance.markInitialized(jsonEncode(resolved));
      store.log('api.ChatClient.init', {'success': true});
    } catch (e) {
      store.log('api.ChatClient.init', {
        'success': false,
        'error': errorToJson(e),
      });
    }

    // login: script login takes priority; otherwise derived from config (loginToken over loginPassword).
    // Observed in 4.22: SDK internals not ready after native init method channel returns
    //(login reports "SDK has not initialize" 2ms after init succeeds); auto-retry on failure.
    const maxLoginAttempts = 5;
    for (var attempt = 1; attempt <= maxLoginAttempts; attempt++) {
      try {
        Map<String, dynamic> loginJson;
        final sLogin = script['login'];
        if (sLogin is Map) {
          loginJson = Map<String, dynamic>.from(sLogin);
        } else {
          loginJson = {'userId': config['loginUser'] ?? ''};
          final token = config['loginToken'];
          if (token is String && token.isNotEmpty) {
            loginJson['token'] = token;
          } else {
            loginJson['password'] = config['loginPassword'] ?? '';
          }
        }
        final resolved = Map<String, dynamic>.from(
          _resolveRefs(loginJson, null, config, const {}) as Map,
        );
        final userId = resolved['userId'] as String? ?? '';
        final password = resolved['password'] as String?;
        final token = resolved['token'] as String?;
        if (password != null) {
          await ChatClient.getInstance.loginWithPassword(userId, password);
        } else {
          await ChatClient.getInstance.loginWithToken(userId, token ?? '');
        }
        SdkState.instance.markLoggedIn(userId);
        store.log('api.ChatClient.login', {
          'success': true,
          if (attempt > 1) 'attempt': attempt,
        });
        break;
      } catch (e) {
        store.log('api.ChatClient.login', {
          'success': false,
          'attempt': attempt,
          'error': errorToJson(e),
        });
        if (attempt < maxLoginAttempts) {
          await Future.delayed(const Duration(seconds: 1));
        }
      }
    }

    // steps
    final rawSteps = script['steps'];
    final steps = rawSteps is List ? rawSteps : const [];
    var failed = 0;
    Object? prev;
    final stepData = <String, Object?>{};
    for (final raw in steps) {
      var name = '';
      try {
        final step = Map<String, dynamic>.from(raw as Map);
        name = step['api'] as String? ?? '';
        final id = step['id'] as String?;
        final params = Map<String, dynamic>.from(
          _resolveRefs(step['params'] as Map? ?? {}, prev, config, stepData)
              as Map,
        );
        Map<String, dynamic> result;
        if (name == 'TestUtil.writeBase64File') {
          result = await _writeBase64File(params);
        } else {
          final entry = findApi(name);
          if (entry == null) {
            result = {
              'success': false,
              'error': {'code': -1, 'message': '未注册的 API：$name'},
            };
          } else {
            // Per-step timeout guard: native may never call back in certain states
            //(e.g. subscribeUsersInfo hangs when not logged in); prevents the entire script from stalling.
            // Timeout does not cancel the underlying call; just logs and continues.
            final timeoutMs = step['timeoutMs'] as int? ?? defaultStepTimeoutMs;
            result = await runApi(entry, params).timeout(
              Duration(milliseconds: timeoutMs),
              onTimeout: () => {
                'success': false,
                'error': {
                  'code': -2,
                  'message': 'timeout after ${timeoutMs}ms'
                },
              },
            );
          }
        }
        store.log('api.$name', result);
        prev = result['data'];
        if (id != null) stepData[id] = result['data'];
        if (result['success'] != true) failed++;
        final delay = step['delayAfterMs'] as int?;
        if (delay != null && delay > 0) {
          await Future.delayed(Duration(milliseconds: delay));
        }
      } catch (e) {
        // Per-step parse/execution errors do not interrupt the script; counted as failed.
        failed++;
        store.log('api.$name', {
          'success': false,
          'error': errorToJson(e),
        });
      }
    }
    store.log('script.done', {'total': steps.length, 'failed': failed});
  }
}
