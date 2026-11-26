import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../registry/api_entry.dart';
import '../registry/registry.dart';
import 'api_call_page.dart';

/// Search page: shows hint text by default; real-time keyword filtering (case-insensitive substring,
/// matching method name + group name). Read-only full list is not included in search.
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _query = '';

  List<ApiEntry> get _results {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return apiRegistry
        .where((e) =>
            e.name.toLowerCase().contains(q) ||
            e.group.toLowerCase().contains(q))
        .toList();
  }

  void _showAllApis() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        builder: (context, scroll) => ListView.builder(
          controller: scroll,
          itemCount: apiRegistry.length + 1,
          itemBuilder: (context, i) {
            if (i == 0) {
              return const ListTile(
                title: Text('全部 API（只读，长按可复制名称）'),
              );
            }
            final e = apiRegistry[i - 1];
            return ListTile(
              dense: true,
              title: Text(e.name),
              subtitle: Text(e.group),
              onLongPress: () => Clipboard.setData(ClipboardData(text: e.name)),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    return Scaffold(
      appBar: AppBar(
        title: const Text('API 搜索'),
        actions: [
          TextButton(
            onPressed: _showAllApis,
            child: const Text('全部清单', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              autofocus: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
                hintText: '输入方法名或分组名，如 send / chat',
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: _query.trim().isEmpty
                ? const Center(child: Text('输入关键字开始搜索（匹配方法名与分组名）'))
                : results.isEmpty
                    ? const Center(child: Text('无匹配结果'))
                    : ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (context, i) {
                          final e = results[i];
                          return ListTile(
                            title: Text(e.name),
                            subtitle: Text(e.group),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ApiCallPage(entry: e),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
