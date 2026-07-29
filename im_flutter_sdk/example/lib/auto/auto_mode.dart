import 'dart:convert';
import 'dart:io';

import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import '../listeners.dart';
import '../log/log_store.dart';
import '../options_codec.dart';
import '../registry/api_entry.dart';
import '../registry/registry.dart';
import '../sdk_state.dart';

/// AI 自动化脚本模式：`--dart-define=API_SCRIPT=<宿主机文件绝对路径>` 启动进入。
/// 自动执行 init → login → 串行 steps，全部结果走同一条结构化日志通道；
/// 任一步失败不中断，结束后输出 script.done，App 保持运行。
class AutoMode {
  static const String scriptPath =
      String.fromEnvironment('API_SCRIPT', defaultValue: '');

  static bool get enabled => scriptPath.isNotEmpty;

  /// params 中字符串值恰好为 "$prev" 时替换为上一步返回的 data。
  static Object? _resolvePrev(Object? v, Object? prev) {
    if (v is String && v == r'$prev') return prev;
    if (v is Map) {
      return v.map((k, val) => MapEntry(k, _resolvePrev(val, prev)));
    }
    if (v is List) return v.map((e) => _resolvePrev(e, prev)).toList();
    return v;
  }

  static Future<void> run() async {
    final store = LogStore.instance;
    Map<String, dynamic> script;
    try {
      script = jsonDecode(await File(scriptPath).readAsString())
          as Map<String, dynamic>;
    } catch (e) {
      store.log('script.error', {'stage': 'read', 'error': errorToJson(e)});
      store.log('script.done', {'total': 0, 'failed': 0});
      return;
    }
    store.log('script.start', {'path': scriptPath});

    // init
    try {
      final initJson =
          Map<String, dynamic>.from(script['init'] as Map? ?? {});
      await EMClient.getInstance.init(emOptionsFromJson(initJson));
      registerAllListeners();
      SdkState.instance.markInitialized(jsonEncode(initJson));
      store.log('api.EMClient.init', {'success': true});
    } catch (e) {
      store.log('api.EMClient.init', {
        'success': false,
        'error': errorToJson(e),
      });
    }

    // login（password 或 token 二选一）
    try {
      final loginJson =
          Map<String, dynamic>.from(script['login'] as Map? ?? {});
      final userId = loginJson['userId'] as String? ?? '';
      final password = loginJson['password'] as String?;
      final token = loginJson['token'] as String?;
      if (password != null) {
        await EMClient.getInstance.loginWithPassword(userId, password);
      } else {
        await EMClient.getInstance.loginWithToken(userId, token ?? '');
      }
      SdkState.instance.markLoggedIn(userId);
      store.log('api.EMClient.login', {'success': true});
    } catch (e) {
      store.log('api.EMClient.login', {
        'success': false,
        'error': errorToJson(e),
      });
    }

    // steps
    final rawSteps = script['steps'];
    final steps = rawSteps is List ? rawSteps : const [];
    var failed = 0;
    Object? prev;
    for (final raw in steps) {
      var name = '';
      try {
        final step = Map<String, dynamic>.from(raw as Map);
        name = step['api'] as String? ?? '';
        final entry = findApi(name);
        Map<String, dynamic> result;
        if (entry == null) {
          result = {
            'success': false,
            'error': {'code': -1, 'message': '未注册的 API：$name'},
          };
        } else {
          final params = Map<String, dynamic>.from(
            _resolvePrev(step['params'] as Map? ?? {}, prev) as Map,
          );
          result = await runApi(entry, params);
        }
        store.log('api.$name', result);
        prev = result['data'];
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
