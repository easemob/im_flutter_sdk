import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../log/log_store.dart';
import '../registry/api_entry.dart';

/// API 调用页：JSON 参数 → 调真实 API → 结果 JSON 展示（可滚动、可一键复制），
/// 同一份结果写入日志（source 为 api.<API 全限定名>）。
class ApiCallPage extends StatefulWidget {
  final ApiEntry entry;
  const ApiCallPage({super.key, required this.entry});

  @override
  State<ApiCallPage> createState() => _ApiCallPageState();
}

class _ApiCallPageState extends State<ApiCallPage> {
  late final TextEditingController _paramsController;
  String? _result;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _paramsController = TextEditingController(text: widget.entry.paramsTemplate);
  }

  Future<void> _invoke() async {
    setState(() {
      _result = null;
      _running = true;
    });
    Map<String, dynamic> result;
    try {
      final params = jsonDecode(_paramsController.text);
      if (params is! Map<String, dynamic>) {
        throw const FormatException('参数必须是 JSON Object');
      }
      result = await runApi(widget.entry, params);
    } catch (e) {
      result = {'success': false, 'error': errorToJson(e)};
    }
    LogStore.instance.log('api.${widget.entry.name}', result);
    if (!mounted) return;
    setState(() {
      _result = const JsonEncoder.withIndent('  ').convert(result);
      _running = false;
    });
  }

  @override
  void dispose() {
    _paramsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.entry.name)),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Text(widget.entry.description),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: TextField(
              controller: _paramsController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '参数 JSON（必填字段模板）',
                alignLabelWithHint: true,
              ),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _running ? null : _invoke,
            child: Text(_running ? '调用中…' : '调用'),
          ),
          if (_result != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Expanded(
                  child: Text('结果', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                TextButton(
                  onPressed: () =>
                      Clipboard.setData(ClipboardData(text: _result!)),
                  child: const Text('复制全文'),
                ),
              ],
            ),
            Container(
              constraints: const BoxConstraints(maxHeight: 320),
              padding: const EdgeInsets.all(8),
              color: Colors.black12,
              child: SingleChildScrollView(
                child: SelectableText(
                  _result!,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
