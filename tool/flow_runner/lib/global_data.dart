import 'dart:convert';
import 'dart:async';

/// Generic run-scoped JSON storage. Domain names are supplied by the caller.
/// Initial data is immutable; output paths must be claimed before dispatch.
class GlobalData {
  GlobalData(Map<String, Object?> initial, {required List<String> outputRoots})
      : outputRoots = List.unmodifiable(outputRoots),
        _data = jsonDecode(jsonEncode(initial)) as Map<String, dynamic> {
    for (final root in outputRoots) {
      Object? value = _data;
      for (final part in _parts(root)) {
        if (value is! Map || !value.containsKey(part)) {
          throw FormatException('Output root must be an empty object: $root');
        }
        value = value[part];
      }
      if (value is! Map || value.isNotEmpty) {
        throw FormatException('Output root must be an empty object: $root');
      }
    }
  }

  final List<String> outputRoots;
  final Map<String, dynamic> _data;
  final Map<String, bool?> _outputs = {};
  final Set<String> _declared = {};
  final List<Map<String, Object?>> reads = [];

  Map<String, Object?> snapshot() =>
      jsonDecode(jsonEncode(_data)) as Map<String, Object?>;

  static bool isPath(String name) => name.startsWith('global.');

  static List<String> _parts(String name) {
    if (!RegExp(r'^global(?:\.[A-Za-z_][A-Za-z0-9_]*|\.\d+)+$')
        .hasMatch(name)) {
      throw FormatException('Invalid global path: $name');
    }
    return name.split('.').sublist(1);
  }

  void declare(String name) {
    _parts(name);
    _declared.add(name);
  }

  void claim(String name) {
    final parts = _parts(name);
    if (!outputRoots.any((root) => name.startsWith('$root.'))) {
      throw FormatException('Read-only global path: $name');
    }
    if (_outputs.keys.any(
        (p) => p == name || p.startsWith('$name.') || name.startsWith('$p.'))) {
      throw FormatException('Global binding already claimed: $name');
    }
    Object? cur = _data;
    for (var i = 0; i < parts.length; i++) {
      if (cur is! Map) {
        throw FormatException('Output parent is not an object: $name');
      }
      if (!cur.containsKey(parts[i])) break;
      if (i == parts.length - 1) {
        throw FormatException('Cannot overwrite global data: $name');
      }
      cur = cur[parts[i]];
    }
    _outputs[name] = null;
  }

  void complete(String name, Object? value, {required bool ok}) {
    if (!_outputs.containsKey(name) || _outputs[name] != null) {
      throw FormatException('Global binding is not pending: $name');
    }
    final parts = _parts(name);
    Map cur = _data;
    for (final part in parts.take(parts.length - 1)) {
      cur = cur.putIfAbsent(part, () => <String, Object?>{}) as Map;
    }
    cur[parts.last] = jsonDecode(jsonEncode(value));
    _outputs[name] = ok;
  }

  bool failed(String name) => _outputs.entries.any((e) =>
      e.value == false && (name == e.key || name.startsWith('${e.key}.')));

  Object? read(String name) {
    final parts = _parts(name);
    for (final binding in _declared) {
      if (!_outputs.containsKey(binding) &&
          (name == binding || name.startsWith('$binding.'))) {
        throw FormatException('Global result has not been produced: $name');
      }
    }
    for (final entry in _outputs.entries) {
      if (entry.value == null &&
          (name == entry.key || name.startsWith('${entry.key}.'))) {
        throw FormatException('Global result is not ready: $name');
      }
    }
    Object? cur = _data;
    for (final part in parts) {
      if (cur is Map && cur.containsKey(part)) {
        cur = cur[part];
      } else if (cur is List &&
          int.tryParse(part) != null &&
          int.parse(part) >= 0 &&
          int.parse(part) < cur.length) {
        cur = cur[int.parse(part)];
      } else {
        throw FormatException('Missing global path: $name');
      }
    }
    final copy = jsonDecode(jsonEncode(cur));
    reads.add({
      'path': name,
      'value': copy,
      'consumer': Zone.current[#dataReadContext]
    });
    return copy;
  }
}
