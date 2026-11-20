import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../log/log_store.dart';

/// One event on the evidence stream (agent-service §7).
class EvidenceEvent {
  const EvidenceEvent({
    required this.seq,
    required this.source,
    required this.payload,
    required this.bytes,
  });

  final int seq;

  /// Listener callbacks carry the bare SDK callback method name
  /// (`ChatEventHandler.onMessageReceived` -> `onMessageReceived`, decision
  /// 2026-11-05; the current listener set has no bare-name collisions).
  /// Everything else (api.*, log.path, ...) passes through unchanged.
  final String source;
  final Object? payload;

  /// UTF-8 size of the originating log line, for the byte budget.
  final int bytes;

  Map<String, Object?> toJson() => {'seq': seq, 'source': source, 'payload': payload};
}

/// Evidence ring buffer: subscribes to [LogStore] as a plain listener and
/// keeps its own copy of every structured event, independent of the UI log
/// list (LogStore.clear() only clears the UI view — the evidence survives).
///
/// Bounded: 10,000 entries or 32 MiB, whichever is hit first. Overflow drops
/// the oldest events, advances [firstAvailableSeq] and marks the store
/// degraded (the control server then rejects further business commands with
/// 503 so a run never passes on incomplete evidence).
class EvidenceStore extends ChangeNotifier {
  EvidenceStore({LogStore? logStore, this.maxEntries = 10000, this.maxBytes = 32 * 1024 * 1024})
      : _logStore = logStore ?? LogStore.instance {
    _logStore.addListener(_onLog);
  }

  static final RegExp _handlerPrefix = RegExp(r'^[A-Za-z]+EventHandler\.(.+)$');

  final LogStore _logStore;
  final int maxEntries;
  final int maxBytes;

  final List<EvidenceEvent> _events = [];
  final List<Completer<void>> _waiters = [];
  int _totalBytes = 0;
  bool _degraded = false;

  /// Seq of the oldest retained event (lastSeq + 1 when empty).
  int get firstAvailableSeq => _events.isEmpty ? _lastSeq + 1 : _events.first.seq;

  /// Seq of the newest event seen (0 when nothing logged yet).
  int get lastSeq => _lastSeq;
  int _lastSeq = 0;

  bool get degraded => _degraded;
  int get count => _events.length;

  void _onLog() {
    final lines = _logStore.lines;
    if (lines.isEmpty) return;
    final raw = lines.last;
    Map<String, dynamic> decoded;
    try {
      decoded = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return; // not a structured line; ignore
    }
    final seq = decoded['seq'];
    if (seq is! int || seq <= _lastSeq) return; // clear() or replay: ignore

    final source = decoded['source'];
    final match = source is String ? _handlerPrefix.firstMatch(source) : null;
    final event = EvidenceEvent(
      seq: seq,
      source: match != null ? match.group(1)! : (source is String ? source : ''),
      payload: decoded['payload'],
      bytes: utf8.encode(raw).length,
    );
    _events.add(event);
    _lastSeq = seq;
    _totalBytes += event.bytes;

    while (_events.length > maxEntries || _totalBytes > maxBytes) {
      final dropped = _events.removeAt(0);
      _totalBytes -= dropped.bytes;
      _degraded = true;
    }
    notifyListeners();
    for (final w in _waiters) {
      if (!w.isCompleted) w.complete();
    }
    _waiters.clear();
  }

  /// Events with seq strictly after [afterSeq], at most [limit].
  List<EvidenceEvent> query(int afterSeq, {int limit = 200}) {
    return _events.where((e) => e.seq > afterSeq).take(limit).toList();
  }

  /// Completes as soon as an event with seq > [afterSeq] exists, or after
  /// [timeout] at the latest. Returns the same query result either way.
  Future<List<EvidenceEvent>> queryWithWait(int afterSeq,
      {int limit = 200, required Duration timeout}) {
    final immediate = query(afterSeq, limit: limit);
    if (immediate.isNotEmpty || timeout == Duration.zero) {
      return Future.value(immediate);
    }
    final completer = Completer<void>();
    _waiters.add(completer);
    return completer.future
        .timeout(timeout, onTimeout: () {})
        .then((_) => query(afterSeq, limit: limit));
  }

  /// Detach from the LogStore (app shutdown / tests).
  @override
  void dispose() {
    _logStore.removeListener(_onLog);
    for (final w in _waiters) {
      if (!w.isCompleted) w.complete();
    }
    _waiters.clear();
    super.dispose();
  }
}
