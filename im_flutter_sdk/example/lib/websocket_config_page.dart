import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

/// WebSocket 桥接配置页：配置 URL/topic、手动连接/断开、查看与清空请求响应列表。
class WebSocketConfigPage extends StatefulWidget {
  const WebSocketConfigPage({super.key});

  @override
  State<WebSocketConfigPage> createState() => _WebSocketConfigPageState();
}

class _WebSocketConfigPageState extends State<WebSocketConfigPage> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _deviceController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<BridgeLogItem> _logs = [];
  bool _connecting = false;

  @override
  void initState() {
    super.initState();
    _urlController.text = kDefaultBridgeWebSocketBaseUrl;
    _topicController.text = kDefaultBridgeWebSocketTopic;
    _deviceController.text = 'deviceA';
    IMWebSocketBridge.instance.onLog = _onLog;
  }

  @override
  void dispose() {
    IMWebSocketBridge.instance.onLog = null;
    _urlController.dispose();
    _topicController.dispose();
    _deviceController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onLog(String request, String response) {
    if (!mounted) return;
    setState(() {
      _logs.add(BridgeLogItem(
        time: DateTime.now(),
        request: request,
        response: response,
      ));
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> _connect() async {
    final url = _urlController.text.trim();
    final topic = _topicController.text.trim();
    final deviceName = _deviceController.text.trim();
    if (url.isEmpty) {
      _showSnack('请输入 URL');
      return;
    }
    setState(() => _connecting = true);
    try {
      final String connectUrl = url.contains('?')
          ? url
          : (topic.isEmpty ? url : '$url?topic=${Uri.encodeComponent(topic)}');
      await IMWebSocketBridge.instance.start(
        url: connectUrl,
        deviceName: deviceName.isEmpty ? null : deviceName,
      );
      // Register event handlers to forward events to WebSocket
      EventBridgeHandler.instance.registerAllHandlers();
      if (mounted) _showSnack('已连接并注册事件处理器');
    } catch (e) {
      if (mounted) _showSnack('连接失败: $e');
    } finally {
      if (mounted) setState(() => _connecting = false);
    }
  }

  Future<void> _disconnect() async {
    setState(() => _connecting = true);
    try {
      // Unregister event handlers
      EventBridgeHandler.instance.unregisterAllHandlers();
      await IMWebSocketBridge.instance.stop();
      if (mounted) _showSnack('已断开并取消注册事件处理器');
    } finally {
      if (mounted) setState(() => _connecting = false);
    }
  }

  void _clearLogs() {
    setState(() => _logs.clear());
    _showSnack('已清空');
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final connected = IMWebSocketBridge.instance.isConnected;
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebSocket 桥接配置'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            tooltip: 'SDK Demo（登录/发消息）',
            onPressed: () => Navigator.of(context).pushNamed('/sdk_demo'),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _urlController,
                  decoration: const InputDecoration(
                    labelText: 'URL (base 或完整)',
                    hintText: 'ws://host:port/path 或带 ?topic=',
                    border: OutlineInputBorder(),
                  ),
                  enabled: !connected,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _topicController,
                  decoration: const InputDecoration(
                    labelText: 'Topic (URL 无 ? 时使用)',
                    hintText: 'adc',
                    border: OutlineInputBorder(),
                  ),
                  enabled: !connected,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _deviceController,
                  decoration: const InputDecoration(
                    labelText: 'Device',
                    hintText: 'deviceA / deviceB',
                    border: OutlineInputBorder(),
                  ),
                  enabled: !connected,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: _connecting || connected ? null : _connect,
                        child: const Text('连接'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _connecting || !connected ? null : _disconnect,
                        child: const Text('断开'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      connected ? '已连接' : '未连接',
                      style: TextStyle(
                        color: connected ? Colors.green : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _logs.isEmpty ? null : _clearLogs,
                      icon: const Icon(Icons.delete_outline, size: 20),
                      label: const Text('清空列表'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 8),
            child: Text(
              '请求 / 响应 (${_logs.length})',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Expanded(
            child: _logs.isEmpty
                ? const Center(child: Text('暂无请求响应记录'))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: _logs.length,
                    itemBuilder: (_, i) {
                      final log = _logs[i];
                      return _LogTile(item: log);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class BridgeLogItem {
  final DateTime time;
  final String request;
  final String response;

  BridgeLogItem({
    required this.time,
    required this.request,
    required this.response,
  });
}

class _LogTile extends StatefulWidget {
  const _LogTile({required this.item});

  final BridgeLogItem item;

  @override
  State<_LogTile> createState() => _LogTileState();
}

class _LogTileState extends State<_LogTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final timeStr = '${item.time.hour.toString().padLeft(2, '0')}:'
        '${item.time.minute.toString().padLeft(2, '0')}:'
        '${item.time.second.toString().padLeft(2, '0')}';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    timeStr,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _shortPreview(item.request),
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: _expanded ? null : 1,
                      overflow: _expanded ? null : TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
              if (_expanded) ...[
                const SizedBox(height: 8),
                const Text('请求:', style: TextStyle(fontWeight: FontWeight.bold)),
                SelectableText(
                  item.request,
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
                const SizedBox(height: 4),
                const Text('响应:', style: TextStyle(fontWeight: FontWeight.bold)),
                SelectableText(
                  item.response,
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _shortPreview(String s) {
    if (s.length <= 80) return s;
    return '${s.substring(0, 80)}...';
  }
}
