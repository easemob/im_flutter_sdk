/// Interpreter core: executes a FlowSpec against a set of agent clients.
///
/// Semantics implemented here (see spec 2026-11-05-flow-interpreter-spec.md):
/// - sequential steps by default; `parallel` runs branches as independent
///   async lines with join-all semantics;
/// - `barrier` synchronizes branches of the same parallel block; a branch
///   that exits early releases its barriers instead of hanging siblings;
/// - `cmd` honors the skip-on-failed-deps rule (global default + per-step
///   override), per-step timeout, and the onFail policy
///   (continue | abort_flow | abort_all);
/// - `wait_event` scans the agent event stream via a per-agent cursor:
///   cached events first, then new ones; `match` values are re-evaluated
///   on every event (lazy matching resolves cross-branch races);
/// - timeouts produce a timeout envelope; late results are never delivered
///   back into the flow (they remain visible in agent-side evidence).
library;

import 'dart:async';

import 'agent_client.dart';
import 'ast.dart';
import 'expr.dart';
import 'report.dart';

/// Thrown by abort_flow; caught at the enclosing branch/flow boundary.
class AbortFlow implements Exception {}

/// Thrown by abort_all; every execution line winds down.
class AbortAll implements Exception {}

/// Non-recoverable interpreter bug (not a test failure).
class InterpError implements Exception {
  InterpError(this.message);

  final String message;

  @override
  String toString() => 'interpreter error: $message';
}

class Interpreter {
  Interpreter({
    required this.spec,
    required this.agents,
    required this.report,
    Map<String, Map<String, Object?>> agentInfo = const {},
  }) {
    // Built-in `$agents` variable: role -> session info (userId etc.),
    // collected from the handshake before the flow starts.
    env.bindBuiltin(
      'agents',
      {
        for (final role in agents.keys)
          role: agentInfo[role] ?? <String, Object?>{},
      },
    );
  }

  final FlowSpec spec;
  final Map<String, AgentClient> agents;
  final ReportCollector report;
  final Env env = Env();

  /// Per-agent event cursors (exclusive: events with seq <= cursor consumed).
  final Map<String, int> _cursors = {};
  final Map<String, _BarrierState> _barriers = {};
  bool _abortedAll = false;

  Future<void> run() async {
    try {
      await _runSteps(spec.steps, 'flow');
    } on AbortFlow {
      // The main line requested abort_flow: nothing left to terminate.
    } on AbortAll {
      // Handled via the flag; nothing else to do.
    }
  }

  Future<void> _runSteps(List<Step> steps, String ctx) async {
    for (final step in steps) {
      if (_abortedAll) return;
      await _runStep(step, ctx);
    }
  }

  Future<void> _runStep(Step step, String ctx) async {
    switch (step) {
      case final CmdStep c:
        await _cmd(c, ctx);
      case final WaitEventStep w:
        await _waitEvent(w, ctx);
      case final ParallelStep p:
        await _parallel(p, ctx);
      case final BarrierStep b:
        await _barrier(b, ctx);
      case final IfStep i:
        await _runSteps(
          truthy(evalExpr(i.cond, env)) ? i.thenSteps : i.elseSteps,
          ctx,
        );
      case final ForStep f:
        await _for(f, ctx);
      case final WhileStep w:
        await _while(w, ctx);
      case final SetStep s:
        for (final e in s.assignments.entries) {
          env.bind(e.key, resolveValue(e.value, env), ok: true);
        }
      case final DelayStep d:
        await Future.delayed(Duration(milliseconds: d.ms));
    }
  }

  // -------------------------------------------------------------------------
  // cmd
  // -------------------------------------------------------------------------

  Future<void> _cmd(CmdStep s, String ctx) async {
    final sw = Stopwatch()..start();

    // Skip-on-failed-deps: global default, per-step override wins.
    final skip = s.skipOnFailedDeps ?? spec.defaults.skipOnFailedDeps;
    if (skip) {
      final refs = collectRefs(s.inputs);
      final failed = refs.where((n) => !env.isOk(n)).toList();
      if (failed.isNotEmpty) {
        report.add(StepRecord(
          kind: 'cmd',
          context: ctx,
          agent: s.agent,
          name: s.cmd,
          status: 'skipped',
          durationMs: 0,
          reason: 'failed or unbound deps: ${failed.join(', ')}',
        ));
        return; // no execution, no variable binding → cascades downstream
      }
    }

    final inputs = resolveValue(s.inputs, env) as Map<String, Object?>?;
    final timeoutMs = s.timeoutMs ?? spec.defaults.stepTimeoutMs;

    Envelope envelope;
    try {
      envelope = await agents[s.agent]!
          .runCommand(s.cmd, inputs ?? const {}, timeoutMs)
          .timeout(
            Duration(milliseconds: timeoutMs),
            onTimeout: () => Envelope.timeout(timeoutMs),
          );
    } catch (e) {
      envelope = Envelope.error(e);
    }

    if (s.as != null) {
      env.bind(s.as!, envelope.toMap(), ok: envelope.success);
    }

    final failed = !envelope.success;
    report.add(StepRecord(
      kind: 'cmd',
      context: ctx,
      agent: s.agent,
      name: s.cmd,
      status: envelope.status == 'timeout'
          ? 'timeout'
          : (failed ? 'failed' : 'passed'),
      durationMs: sw.elapsedMilliseconds,
      result: envelope.toMap(),
    ));

    if (failed) _applyOnFail(s.onFail);
  }

  void _applyOnFail(OnFail? override) {
    switch (override ?? spec.defaults.onFail) {
      case OnFail.continue_:
        break;
      case OnFail.abortFlow:
        throw AbortFlow();
      case OnFail.abortAll:
        _abortedAll = true;
        throw AbortAll();
    }
  }

  // -------------------------------------------------------------------------
  // wait_event
  // -------------------------------------------------------------------------

  Future<void> _waitEvent(WaitEventStep s, String ctx) async {
    final sw = Stopwatch()..start();
    final timeoutMs = s.timeoutMs ?? spec.defaults.stepTimeoutMs;
    final deadline = DateTime.now().add(Duration(milliseconds: timeoutMs));
    final client = agents[s.agent]!;

    while (true) {
      final cursor = _cursors[s.agent] ?? 0;
      final events = await client.pollEvents(cursor, waitMs: 200);

      for (final ev in events) {
        // Advance the cursor past every event we have inspected.
        _cursors[s.agent] = ev.seq;

        if (ev.source != s.event) continue;

        // Lazy match evaluation on every event: a match value referencing a
        // not-yet-produced variable evaluates to null → no match, keep
        // waiting. This is what makes cross-branch references safe.
        var matched = true;
        for (final e in s.match.entries) {
          final payloadVal = Env.dig(ev.payload, e.key.split('.'));
          final expected = resolveValue(e.value, env);
          if (expected == null || !deepEq(payloadVal, expected)) {
            matched = false;
            break;
          }
        }
        if (!matched) continue;

        if (s.as != null) {
          env.bind(s.as!, ev.payload, ok: true);
        }
        report.add(StepRecord(
          kind: 'wait_event',
          context: ctx,
          agent: s.agent,
          name: s.event,
          status: 'passed',
          durationMs: sw.elapsedMilliseconds,
          result: {'seq': ev.seq, 'payload': ev.payload},
        ));
        return;
      }

      if (DateTime.now().isAfter(deadline)) {
        report.add(StepRecord(
          kind: 'wait_event',
          context: ctx,
          agent: s.agent,
          name: s.event,
          status: 'timeout',
          durationMs: sw.elapsedMilliseconds,
          reason: 'no matching event within ${timeoutMs}ms',
        ));
        _applyOnFail(s.onFail);
        return;
      }
      // Events already drained but nothing matched: brief pause before the
      // next poll (mock agents return immediately; HTTP agents wait
      // server-side via waitMs).
      if (events.isEmpty) {
        await Future.delayed(const Duration(milliseconds: 25));
      }
    }
  }

  // -------------------------------------------------------------------------
  // parallel / barrier
  // -------------------------------------------------------------------------

  Future<void> _parallel(ParallelStep s, String ctx) async {
    // Register barriers from a static scan of each branch (including those
    // nested in if/for/while bodies). One branch counts once per name.
    final branchBarriers = <String, Set<String>>{};
    for (final entry in s.branches.entries) {
      final names = _collectBarrierNames(entry.value);
      branchBarriers[entry.key] = names;
      for (final n in names) {
        _barriers.putIfAbsent(n, _BarrierState.new).parties++;
      }
    }

    final futures = [
      for (final entry in s.branches.entries)
        _runBranch(entry.value, '$ctx.${entry.key}',
                branchBarriers[entry.key] ?? const {})
            .catchError((Object e) {
          // AbortFlow/AbortAll are handled inside _runBranch; anything else
          // is a bug — surface it on the main line.
          if (e is! AbortFlow && e is! AbortAll) {
            throw InterpError('branch "${entry.key}" crashed: $e');
          }
        }),
    ];
    // join-all: wait for every branch to finish regardless of outcome.
    await Future.wait(futures);
  }

  Future<void> _runBranch(
      List<Step> steps, String ctx, Set<String> myBarriers) async {
    try {
      await _runSteps(steps, ctx);
    } on AbortFlow {
      // Only this branch ends.
    } on AbortAll {
      // Flag already set by _applyOnFail; siblings check it between steps.
    } finally {
      // Release barriers this branch registered but never reached, so
      // waiting siblings are not hung forever.
      for (final name in myBarriers) {
        _barriers[name]?.branchExited();
      }
    }
  }

  Set<String> _collectBarrierNames(List<Step> steps) {
    final names = <String>{};
    void walk(List<Step> list) {
      for (final s in list) {
        switch (s) {
          case final BarrierStep b:
            names.add(b.name);
          case final IfStep i:
            walk(i.thenSteps);
            walk(i.elseSteps);
          case final ForStep f:
            walk(f.doSteps);
          case final WhileStep w:
            walk(w.doSteps);
          case ParallelStep():
            throw InterpError(
                'nested parallel should have been rejected by the parser');
          case CmdStep():
          case WaitEventStep():
          case SetStep():
          case DelayStep():
            break;
        }
      }
    }

    walk(steps);
    return names;
  }

  Future<void> _barrier(BarrierStep s, String ctx) async {
    final state = _barriers[s.name];
    if (state == null) {
      throw InterpError(
          'barrier "${s.name}" is only usable inside a parallel branch');
    }
    await state.arrive();
  }

  // -------------------------------------------------------------------------
  // for / while
  // -------------------------------------------------------------------------

  Future<void> _for(ForStep s, String ctx) async {
    Iterable<Object?> items;
    if (s.listRef != null) {
      final list = resolveValue(s.listRef, env);
      if (list is! List) {
        throw InterpError(
            'for source "${s.listRef}" is not a list (got ${list.runtimeType}); '
            'failed or wrong-shaped producer');
      }
      items = list;
    } else {
      items = [
        for (var i = s.rangeStart!; i <= s.rangeEnd!; i++) i,
      ];
    }
    for (final item in items) {
      if (_abortedAll) return;
      final shadow = env.pushShadow(s.varName, item);
      try {
        await _runSteps(s.doSteps, ctx);
      } finally {
        env.popShadow(shadow);
      }
    }
  }

  Future<void> _while(WhileStep s, String ctx) async {
    while (truthy(evalExpr(s.cond, env))) {
      if (_abortedAll) return;
      await _runSteps(s.doSteps, ctx);
    }
  }
}

class _BarrierState {
  int parties = 0;
  int _arrived = 0;
  Completer<void>? _done;

  /// Called by each participating branch when it reaches the barrier.
  Future<void> arrive() async {
    _arrived++;
    if (_arrived >= parties) {
      _release();
    } else {
      final done = _done ??= Completer<void>();
      await done.future;
    }
  }

  /// Called when a participating branch exits without reaching the barrier:
  /// drop the expectation so waiting branches are released immediately.
  void branchExited() {
    parties = _arrived;
    _release();
  }

  void _release() {
    final done = _done;
    _done = null;
    if (done != null && !done.isCompleted) {
      done.complete();
    }
  }
}
