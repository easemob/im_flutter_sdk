import 'dart:convert';
import 'dart:io';

import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:path_provider/path_provider.dart';

import '../env.dart';
import '../listeners.dart';
import '../log/log_store.dart';
import '../options_codec.dart';
import '../registry/api_entry.dart';
import '../registry/registry.dart';
import '../sdk_state.dart';
import 'step_dependencies.dart';
import 'step_expectation.dart';

/// AI automation script mode: enter via `--dart-define=API_SCRIPT=<host file absolute path>`.
/// Automatically executes init -> login -> sequential steps; all results go through the same structured log channel;
/// independent step failures do not interrupt the flow; steps that reference failed
/// producers are skipped; outputs script.done on completion; App keeps running.
///
/// Test data defaults to the generated env.dart. An external JSON file passed with
/// `--dart-define=API_CONFIG=<absolute path>` overrides the generated environment.
/// - init: ChatOptions keys in the environment as base, script init overrides;
/// - login: script login takes priority, otherwise the first environment account is used.
///
/// Parameter string references (replaced only on exact full-string match, preserving original value types):
/// - `$config.key` / `$config.key.sub`: value from env.dart or API_CONFIG;
/// - `$prev` / `$prev.a.b`: data returned by the previous step, dot path for nesting (numeric index for lists);
/// - `$step.id` / `$step.id.a.b`: data from a step with "id", cross-step reference.
class AutoMode {
  static const String scriptPath = String.fromEnvironment(
    'API_SCRIPT',
    defaultValue: '',
  );
  static const String configPath = String.fromEnvironment(
    'API_CONFIG',
    defaultValue: '',
  );

  static bool get enabled => scriptPath.isNotEmpty;

  /// Default per-step timeout (can be overridden by step's "timeoutMs").
  static const int defaultStepTimeoutMs = 30000;

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
      return {'success': false, 'error': errorToJson(e)};
    }
  }

  static Future<void> run() async {
    final store = LogStore.instance;

    // Generated env.dart is the default source for init/login and $config refs.
    var config = Map<String, dynamic>.from(environment);
    if (configPath.isNotEmpty) {
      try {
        config = await _loadJsonFile(configPath);
        store.log('config.load', {
          'path': configPath,
          'keys': config.keys.toList(),
        });
      } catch (e) {
        store.log('config.load', {
          'path': configPath,
          'error': errorToJson(e),
        });
      }
    } else {
      store.log('config.load', {
        'source': 'env.dart',
        'cluster': config['cluster'],
        'keys': config.keys.toList(),
      });
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
      final initJson = chatOptionsJsonFromEnvironment(config);
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

    // login: script login takes priority; otherwise use the first generated account.
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
          final accounts = config['accounts'];
          final account = accounts is List && accounts.isNotEmpty
              ? accounts.first
              : const <String, dynamic>{};
          loginJson = account is Map
              ? {
                  'userId': account['id'] ?? '',
                  'token': account['token'] ?? '',
                }
              : {'userId': '', 'token': ''};
        }
        final resolved = Map<String, dynamic>.from(
          _resolveRefs(loginJson, null, config, const {}) as Map,
        );
        final userId = resolved['userId'] as String? ?? '';
        final token = resolved['token'] as String?;
        await ChatClient.getInstance.loginWithToken(userId, token ?? '');
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
    var blocked = 0;
    Object? prev;
    final stepData = <String, Object?>{};
    final stepSucceeded = <String, bool>{};
    for (final raw in steps) {
      var name = '';
      String? id;
      try {
        final step = Map<String, dynamic>.from(raw as Map);
        name = step['api'] as String? ?? '';
        id = step['id'] as String?;
        final rawParams = step['params'] as Map? ?? {};
        final blockedBy = failedStepDependency(rawParams, stepSucceeded);
        Map<String, dynamic> result;
        if (blockedBy != null) {
          result = skippedStepResult(blockedBy);
          blocked++;
        } else {
          final params = Map<String, dynamic>.from(
            _resolveRefs(rawParams, prev, config, stepData) as Map,
          );
          if (name == 'TestUtil.writeBase64File') {
            result = await _writeBase64File(params);
          } else {
            final entry = findApi(name);
            if (entry == null) {
              result = {
                'success': false,
                'error': {
                  'code': -1,
                  'message': '未注册的 API：$name',
                },
              };
            } else {
              // Per-step timeout guard: native may never call back in certain states
              //(e.g. subscribeUsersInfo hangs when not logged in); prevents the entire script from stalling.
              // Timeout does not cancel the underlying call; just logs and continues.
              final timeoutMs =
                  step['timeoutMs'] as int? ?? defaultStepTimeoutMs;
              result = await runApi(entry, params).timeout(
                Duration(milliseconds: timeoutMs),
                onTimeout: () => {
                  'success': false,
                  'error': {
                    'code': -2,
                    'message': 'timeout after ${timeoutMs}ms',
                  },
                },
              );
            }
          }
        }
        store.log('api.$name', result);
        prev = result['data'];
        if (id != null) {
          stepData[id] = result['data'];
          stepSucceeded[id] = result['success'] == true;
        }
        if (blockedBy == null &&
            !stepResultMatchesExpectation(result, step['expect'])) {
          failed++;
        }
        final delay = step['delayAfterMs'] as int?;
        if (delay != null && delay > 0) {
          await Future.delayed(Duration(milliseconds: delay));
        }
      } catch (e) {
        // Per-step parse/execution errors do not interrupt the script; counted as failed.
        failed++;
        if (id != null) stepSucceeded[id] = false;
        store.log('api.$name', {'success': false, 'error': errorToJson(e)});
      }
    }
    store.log('script.done', {
      'total': steps.length,
      'failed': failed,
      'blocked': blocked,
    });
  }
}
