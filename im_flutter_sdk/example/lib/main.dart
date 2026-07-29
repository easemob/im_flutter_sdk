import 'package:flutter/material.dart';

import 'auto/auto_mode.dart';
import 'log/floating_log.dart';
import 'log/log_store.dart';
import 'pages/init_page.dart';
import 'sdk_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LogStore.instance.init();
  runApp(const ApiTesterApp());
}

/// 用于取 Navigator 内部的 Overlay（RootShell 在 Navigator 之上，
/// 直接用自身 context 找不到 Overlay）。
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

/// 顶部状态条：未初始化 / 已初始化，未登录 / 已登录：<userId>，不做硬性门控。
class StatusBar extends StatelessWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SdkState.instance,
      builder: (context, _) {
        return Container(
          width: double.infinity,
          color: Colors.blueGrey.shade700,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Text(
            SdkState.instance.statusText,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        );
      },
    );
  }
}

/// 根壳：状态条常显 + init 成功后插入悬浮日志（生命周期独立于页面）。
class RootShell extends StatefulWidget {
  final Widget? child;
  const RootShell({super.key, required this.child});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  bool _logShown = false;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SdkState.instance,
      builder: (context, _) {
        if (SdkState.instance.initialized && !_logShown) {
          _logShown = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final overlay = appNavigatorKey.currentState?.overlay;
            if (overlay != null) FloatingLog.show(overlay);
          });
        }
        return Column(
          children: [
            const SafeArea(bottom: false, child: StatusBar()),
            Expanded(child: widget.child ?? const SizedBox.shrink()),
          ],
        );
      },
    );
  }
}

class ApiTesterApp extends StatelessWidget {
  const ApiTesterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IM API Tester',
      navigatorKey: appNavigatorKey,
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      builder: (context, child) => RootShell(child: child),
      home: AutoMode.enabled ? const AutoHomePage() : const InitPage(),
    );
  }
}

/// 自动模式占位页：启动脚本，展示状态；日志走 stdout / 落盘通道。
class AutoHomePage extends StatefulWidget {
  const AutoHomePage({super.key});

  @override
  State<AutoHomePage> createState() => _AutoHomePageState();
}

class _AutoHomePageState extends State<AutoHomePage> {
  bool _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_started) {
        _started = true;
        AutoMode.run();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('自动脚本模式')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'API_SCRIPT=${AutoMode.scriptPath}\n\n脚本执行中，结果见 [APITEST] 结构化日志（stdout / api_test.log）。',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
