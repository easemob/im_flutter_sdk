import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import '../listeners.dart';
import '../options_codec.dart';
import '../sdk_state.dart';
import 'command_service.dart';
import 'control_server.dart';
import 'evidence_store.dart';

/// Agent-mode home: composition root for the control service. Owns the
/// [EvidenceStore], [CommandService] and [ControlServer] lifecycles and
/// shows their state. Deliberately offers NO SDK operation entry — manual
/// interference during a driven run is prevented by mode isolation
/// (agent-service §5).
class AgentHomePage extends StatefulWidget {
  const AgentHomePage({super.key});

  @override
  State<AgentHomePage> createState() => _AgentHomePageState();
}

class _AgentHomePageState extends State<AgentHomePage> {
  EvidenceStore? _evidence;
  CommandService? _service;
  ControlServer? _server;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  Future<void> _boot() async {
    try {
      final evidence = EvidenceStore();
      final service = CommandService.production(
        initHandler: agentInitHandler,
        instanceId: DateTime.now().microsecondsSinceEpoch.toRadixString(16),
      );
      final server = await ControlServer.start(
        service: service,
        evidence: evidence,
      );
      setState(() {
        _evidence = evidence;
        _service = service;
        _server = server;
      });
    } catch (e) {
      setState(() => _error = '控制服务启动失败：$e');
    }
  }

  @override
  void dispose() {
    _server?.stop();
    _evidence?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final server = _server;
    return Scaffold(
      appBar: AppBar(title: const Text('监听交互模式（agent）')),
      body: _error != null
          ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_error!)))
          : server == null
              ? const Center(child: CircularProgressIndicator())
              : ListenableBuilder(
                  listenable: Listenable.merge([_service, _evidence]),
                  builder: (context, _) {
                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '连接信息（文本可长按选择复制）',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                _row('端点', 'http://127.0.0.1:${server.port}'),
                                _row('token', server.token),
                                _row('instanceId', _service!.instanceId),
                                _row('服务状态', _service!.state.name),
                                _row('已缓存事件',
                                    '${_evidence!.count} (firstSeq ${_evidence!.firstAvailableSeq}, lastSeq ${_evidence!.lastSeq})'),
                                if (_evidence!.degraded)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text(
                                      '证据缓冲已溢出（degraded）',
                                      style: TextStyle(color: Colors.orange),
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                OutlinedButton.icon(
                                  onPressed: () =>
                                      _copy(_curlCommand(server), 'curl 命令'),
                                  icon: const Icon(Icons.copy, size: 18),
                                  label: const Text('复制 curl（GET /v1/info）'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '本页面不提供 SDK 操作入口。宿主（flow_runner）通过 '
                          '[AGENT_CONTROL] 输出的端口与凭据连接；命令执行结果与事件'
                          '见宿主侧报告。\n'
                          '人工排查：点上方按钮复制 curl 命令直接探测（已带 '
                          '--noproxy，避免本地代理劫持 127.0.0.1）；'
                          'Android 模拟器需先 adb forward tcp:<port> tcp:<port>。',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    );
                  },
                ),
    );
  }

  /// A ready-to-paste probe command for manual debugging. --noproxy is
  /// required when a local proxy (http_proxy env) is present, otherwise the
  /// request to 127.0.0.1 is hijacked and mangled.
  String _curlCommand(ControlServer server) =>
      "curl --noproxy '*' -s -H 'Authorization: Bearer ${server.token}' "
      "http://127.0.0.1:${server.port}/v1/info";

  Future<void> _copy(String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('已复制$label'),
        duration: const Duration(milliseconds: 1200),
      ));
  }

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 96,
              child: Text(k, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: SelectableText(
                v,
                style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
      );
}

/// ChatClient.init special case (agent-service §6): the command params carry
/// `config` (environment map) + `overrides`; the app's options assembly
/// merges them (business knowledge stays in the app). On success listeners
/// are registered and the SDK state marked initialized — same behavior as
/// AutoMode.
Future<Map<String, dynamic>> agentInitHandler(Map<String, dynamic> params) async {
  try {
    final config = params['config'] is Map
        ? Map<String, dynamic>.from(params['config'] as Map)
        : <String, dynamic>{};
    final overrides = params['overrides'] is Map
        ? Map<String, dynamic>.from(params['overrides'] as Map)
        : <String, dynamic>{};
    final initJson = chatOptionsJsonFromEnvironment(config);
    initJson.addAll(overrides);
    await ChatClient.getInstance.init(emOptionsFromJson(initJson));
    // Required by the SDK contract: without startCallback() the native side
    // gates contact/group/chatroom events behind ListenerHandle and never
    // dispatches them to Dart.
    await ChatClient.getInstance.startCallback();
    registerAllListeners();
    SdkState.instance.markInitialized(jsonEncode(initJson));
    return {'success': true};
  } catch (e) {
    return {
      'success': false,
      'failureKind': e is ChatError ? 'sdk' : 'tool',
      'error': e is ChatError
          ? {'code': e.code, 'message': e.description}
          : {'code': -1, 'message': e.toString()},
    };
  }
}

/// Shown when both automated entry points are set: the app refuses to start
/// either (three-mode mutex, agent-service §4).
class ModeConflictPage extends StatelessWidget {
  const ModeConflictPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'API_SCRIPT 与 API_CONTROL 同时设置：拒绝启动双执行入口。\n'
            '三种运行模式（人工 / 脚本 / 监听交互）同一时刻只能启用一种，'
            '请只保留一个 dart-define 后重启应用。',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
