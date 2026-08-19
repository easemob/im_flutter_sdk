import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import '../listeners.dart';
import '../log/log_store.dart';
import '../options_codec.dart';
import '../registry/api_entry.dart';
import '../sdk_state.dart';
import 'login_page.dart';

/// 初始化页（一次性）：init 成功后不可返回重做，换配置需杀 App 重启。
class InitPage extends StatefulWidget {
  const InitPage({super.key});

  @override
  State<InitPage> createState() => _InitPageState();
}

class _InitPageState extends State<InitPage> {
  final _controller = TextEditingController(text: emOptionsTemplate);
  String? _error;
  bool _running = false;

  Future<void> _init() async {
    setState(() {
      _error = null;
      _running = true;
    });
    try {
      final json = jsonDecode(_controller.text) as Map<String, dynamic>;
      await ChatClient.getInstance.init(emOptionsFromJson(json));
      registerAllListeners();
      LogStore.instance.log('api.ChatClient.init', {'success': true});
      SdkState.instance.markInitialized(_controller.text);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    } catch (e) {
      final err = errorToJson(e);
      LogStore.instance.log('api.ChatClient.init', {
        'success': false,
        'error': err,
      });
      if (mounted) {
        setState(
            () => _error = const JsonEncoder.withIndent('  ').convert(err));
      }
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('初始化 ChatClient.init')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'ChatOptions JSON（appKey 必填，可加 enableUserInfo 等可选键）',
                  alignLabelWithHint: true,
                ),
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  _error!,
                  style: const TextStyle(
                      color: Colors.red, fontFamily: 'monospace'),
                ),
              ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _running ? null : _init,
              child: Text(_running ? '初始化中…' : '初始化'),
            ),
          ],
        ),
      ),
    );
  }
}
