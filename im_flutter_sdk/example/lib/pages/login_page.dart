import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import '../log/log_store.dart';
import '../registry/api_entry.dart';
import '../sdk_state.dart';
import 'search_page.dart';

/// 登录页：密码 / token 两种方式，登录成功后 push 搜索页（可返回换号 / 退出）。
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userController = TextEditingController();
  final _secretController = TextEditingController();
  bool _usePassword = true;
  String? _result;
  bool _running = false;

  /// 执行登录/退出动作并记录结果，返回是否成功。
  Future<bool> _run(String label, Future<void> Function() action) async {
    setState(() {
      _result = null;
      _running = true;
    });
    Map<String, dynamic> r;
    try {
      await action();
      r = {'success': true};
    } catch (e) {
      r = {'success': false, 'error': errorToJson(e)};
    }
    LogStore.instance.log('api.$label', r);
    if (mounted) {
      setState(() {
        _result = const JsonEncoder.withIndent('  ').convert(r);
        _running = false;
      });
    }
    return r['success'] == true;
  }

  Future<void> _login() async {
    final userId = _userController.text.trim();
    final secret = _secretController.text;
    final ok = await _run('ChatClient.login', () async {
      if (_usePassword) {
        await ChatClient.getInstance.loginWithPassword(userId, secret);
      } else {
        await ChatClient.getInstance.loginWithToken(userId, secret);
      }
      SdkState.instance.markLoggedIn(userId);
    });
    if (ok && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SearchPage()),
      );
    }
  }

  Future<void> _logout() async {
    await _run('ChatClient.logout', () async {
      await ChatClient.getInstance.logout();
      SdkState.instance.markLoggedOut();
    });
  }

  @override
  void dispose() {
    _userController.dispose();
    _secretController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('登录')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          if (SdkState.instance.initJsonSnapshot != null)
            Card(
              child: ExpansionTile(
                title: const Text('初始化 JSON 快照'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      SdkState.instance.initJsonSnapshot!,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('密码')),
              ButtonSegment(value: false, label: Text('Token')),
            ],
            selected: {_usePassword},
            onSelectionChanged: (s) => setState(() => _usePassword = s.first),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _userController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'username',
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _secretController,
            obscureText: true,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: _usePassword ? 'password' : 'token',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: _running ? null : _login,
                  child: const Text('登录'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: _running ? null : _logout,
                  child: const Text('退出'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListenableBuilder(
            listenable: SdkState.instance,
            builder: (context, _) =>
                Text('当前状态：${SdkState.instance.statusText}'),
          ),
          if (_result != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.black12,
                child: SelectableText(
                  _result!,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
