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

/// AI 自动化脚本模式：`--dart-define=API_SCRIPT=<宿主机文件绝对路径>` 启动进入。
/// 自动执行 init → login → 串行 steps，全部结果走同一条结构化日志通道；
/// 任一步失败不中断，结束后输出 script.done，App 保持运行。
///
/// 测试数据与脚本分离：`--dart-define=API_CONFIG=<config.json 绝对路径>`，
/// 缺省取脚本同目录下的 config.json（不存在则按空配置处理）。
/// - init：config 中的 EMOptions 键（见 [_optionKeys]）为底，脚本 init 覆盖；
/// - login：脚本 login 优先，否则由 config 的 loginUser + loginToken/loginPassword 推导。
///
/// 参数字符串引用（恰好整个字符串匹配才替换，保留原值类型）：
/// - `$config.key` / `$config.key.sub`：取 config.json 中的值；
/// - `$prev` / `$prev.a.b`：上一步返回的 data，点路径可深入（列表用数字下标）；
/// - `$step.id` / `$step.id.a.b`：某个带 "id" 的 step 的 data，跨步引用。
class AutoMode {
  static const String scriptPath =
      String.fromEnvironment('API_SCRIPT', defaultValue: '');
  static const String configPath =
      String.fromEnvironment('API_CONFIG', defaultValue: '');

  static bool get enabled => scriptPath.isNotEmpty;

  /// 单步默认超时（可被 step 的 "timeoutMs" 覆盖）。
  static const int defaultStepTimeoutMs = 30000;

  /// init 允许从 config.json 继承的 EMOptions 键。
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

  /// 自动模式专用（不进注册表）：把 base64 内容写入文档目录，
  /// 供构造图片/语音消息的 localPath 使用。
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

    // config.json：脚本缺省 init/login 与 $config 引用的数据来源。
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

    // init：config 的 EMOptions 键为底，脚本 init 覆盖。
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
      await EMClient.getInstance.init(emOptionsFromJson(resolved));
      registerAllListeners();
      SdkState.instance.markInitialized(jsonEncode(resolved));
      store.log('api.EMClient.init', {'success': true});
    } catch (e) {
      store.log('api.EMClient.init', {
        'success': false,
        'error': errorToJson(e),
      });
    }

    // login：脚本 login 优先；否则由 config 推导（loginToken 优先于 loginPassword）。
    // 实测 4.22 native init 的 method channel 返回后 SDK 内部尚未就绪
    //（init 成功 2ms 后 login 报 "SDK has not initialize"），失败自动重试。
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
          await EMClient.getInstance.loginWithPassword(userId, password);
        } else {
          await EMClient.getInstance.loginWithToken(userId, token ?? '');
        }
        SdkState.instance.markLoggedIn(userId);
        store.log('api.EMClient.login', {
          'success': true,
          if (attempt > 1) 'attempt': attempt,
        });
        break;
      } catch (e) {
        store.log('api.EMClient.login', {
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
            // 每步超时保护：native 在某些状态下可能永不回调
            //（如实测未登录时 subscribeUsersInfo 挂死），不能让脚本整体卡死。
            // 超时不取消底层调用，只记录后继续。
            final timeoutMs = step['timeoutMs'] as int? ?? defaultStepTimeoutMs;
            result = await runApi(entry, params).timeout(
              Duration(milliseconds: timeoutMs),
              onTimeout: () => {
                'success': false,
                'error': {'code': -2, 'message': 'timeout after ${timeoutMs}ms'},
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
        // 单步解析/执行异常不中断脚本，计入 failed。
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
