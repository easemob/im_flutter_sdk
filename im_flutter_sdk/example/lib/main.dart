import 'package:flutter/material.dart';

import 'auto/auto_mode.dart';
import 'log/floating_log.dart';
import 'log/log_store.dart';
import 'pages/init_page.dart';
import 'sdk_state.dart';
import 'tools/floating_attachment.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LogStore.instance.init();
  runApp(const ApiTesterApp());
}

/// Used to get the Overlay inside Navigator (RootShell is above Navigator,
/// cannot find Overlay with its own context directly).
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

/// Top status bar: not initialized / initialized, not logged in / logged in: <userId>; no hard gating.
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

/// Root shell: status bar always visible + floating log/attachment inserted after init (lifecycle independent of pages).
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
            if (overlay != null) {
              FloatingLog.show(overlay);
              FloatingAttachment.show(overlay);
            }
          });
        }
        return Column(
          children: [
            // Color wraps outside SafeArea so the notch/status bar area matches the status bar color.
            Container(
              color: Colors.blueGrey.shade700,
              child: const SafeArea(bottom: false, child: StatusBar()),
            ),
            // Status bar already handles top inset; remove the redundant page padding,
            // otherwise a blank space appears above the AppBar.
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: widget.child ?? const SizedBox.shrink(),
              ),
            ),
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

/// Auto-mode placeholder page: starts the script, shows status; logs go to stdout / file channel.
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
