/// Interpreter core: executes a FlowSpec against a set of agent clients.
///
/// Semantics implemented here (see spec 2026-11-05-flow-interpreter-spec.md):
/// - sequential steps by default; `parallel` runs branches as independent
///   async lines with join-all semantics;
/// - `barrier` synchronizes branches of the same parallel block; a branch
///   that exits early releases its barriers instead of hanging siblings;
/// - `cmd` looks the step up in the agent's device-script library (host-side
///   lookup, protocol v2), resolves parameter references
///   (`$inputs` / `$config` / `$step` / `$prev`), dispatches `{api, params}`
///   and judges the returned envelope against the step's `expect` itself;
///   step "ok" follows the expect judgment, so a reverse case that hit its
///   expected error code is a successful producer for downstream refs;
/// - skip-on-failed-deps covers both flow variables (inputs referencing
///   failed `as` bindings) and device-script references (`$step.<failedId>`);
/// - `wait_event` scans the agent event stream from a cursor established at
///   flow start (events of previous runs are never matched); each wait
///   scans from its own snapshot and the shared cursor only advances on
///   match, so concurrent waits on one agent observe independently and a
///   timed-out wait consumes nothing; `match` values are re-evaluated
///   on every event (lazy matching resolves cross-branch races);
/// - timeouts produce a timeout envelope; late results are never delivered
///   back into the flow (they remain visible in agent-side evidence).
library;

import 'dart:async';

import 'agent_client.dart';
import 'ast.dart';
import 'expect.dart';
import 'expr.dart';
import 'global_data.dart';
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

/// Outcome of one executed device-script step on one agent. `ok` follows
/// the expect judgment (a reverse case that hit its expected error code is
/// ok); the data is bound either way so downstream references still see it.
class _StepOutcome {
  const _StepOutcome(this.ok, this.data);

  final bool ok;
  final Object? data;
}

class Interpreter {
  Interpreter({
    required this.spec,
    required this.agents,
    required this.report,
    GlobalData? global,
    this.onTrace,
  }) {
    env.global = global;
    void declare(List<Step> steps) {
      for (final step in steps) {
        switch (step) {
          case final CmdStep s:
            if (s.as != null && GlobalData.isPath(s.as!)) {
              global?.declare(s.as!);
            }
          case final WaitEventStep s:
            if (s.as != null && GlobalData.isPath(s.as!)) {
              global?.declare(s.as!);
            }
          case final ParallelStep s:
            s.branches.values.forEach(declare);
          case final IfStep s:
            declare(s.thenSteps);
            declare(s.elseSteps);
          case final ForStep s:
            declare(s.doSteps);
          case final WhileStep s:
            declare(s.doSteps);
          default:
            break;
        }
      }
    }

    declare(spec.steps);
    // Built-in `$agents` variable: role -> that agent's runtime environment
    // (the `env:` file declared per agent). Host-side; no handshake needed.
    env.bindBuiltin(
      'agents',
      {
        for (final role in agents.keys)
          role: spec.envs[role] ?? <String, Object?>{},
      },
    );
  }

  final FlowSpec spec;
  final Map<String, AgentClient> agents;
  final ReportCollector report;
  final Env env = Env();
  final void Function(Map<String, Object?> record)? onTrace;
  int _traceSeq = 0;

  void _trace(String kind, Map<String, Object?> fields) {
    onTrace?.call({
      'seq': ++_traceSeq,
      'time': DateTime.now().toUtc().toIso8601String(),
      'kind': kind,
      ...fields,
    });
  }

  void _bind(String? name, Object? value, {required bool ok}) {
    if (name == null) return;
    if (GlobalData.isPath(name)) {
      env.global!.complete(name, value, ok: ok);
    } else {
      env.bind(name, value, ok: ok);
    }
    _trace('binding', {'path': name, 'ok': ok, 'value': value});
  }

  List<String> _failedGlobalRefs(Object? value) {
    final failed = <String>[];
    void walk(Object? v) {
      if (v is String &&
          isRef(v) &&
          v.startsWith(r'$global.') &&
          env.global?.failed(v.substring(1)) == true) {
        failed.add(v);
      }
      if (v is Map) v.values.forEach(walk);
      if (v is List) v.forEach(walk);
    }

    walk(value);
    return failed;
  }

  /// Per-agent device-script step outcomes, keyed by step id.
  final Map<String, Map<String, _StepOutcome>> _stepData = {};

  /// Per-agent data of the most recent command (`$prev` source).
  final Map<String, Object?> _prev = {};

  /// Per-agent event cursors (exclusive: events with seq <= cursor consumed).
  final Map<String, int> _cursors = {};
  final Map<String, _BarrierState> _barriers = {};
  bool _abortedAll = false;
  bool _stopped = false;

  /// Stop scheduling and accepting results after a host-level deadline.
  /// Commands already sent to an agent may still have external side effects.
  void stop() {
    _stopped = true;
    _abortedAll = true;
  }

  Future<void> run() async {
    await _initEventCursors();
    try {
      await _runSteps(spec.steps, 'flow');
    } on AbortFlow {
      // The main line requested abort_flow: nothing left to terminate.
    } on AbortAll {
      // Handled via the flag; nothing else to do.
    }
  }

  /// Establish each agent's starting cursor at the CURRENT end of its
  /// event stream: a flow only ever matches events produced during its own
  /// run, never leftovers of a previous run on the same app instance
  /// (event isolation across flows).
  Future<void> _initEventCursors() async {
    for (final entry in agents.entries) {
      var cursor = 0;
      while (true) {
        final events = await entry.value.pollEvents(cursor, waitMs: 0);
        if (events.isEmpty) break;
        cursor = events.last.seq;
        if (events.length < 200) break;
      }
      _cursors[entry.key] = cursor;
    }
  }

  Future<void> _runSteps(List<Step> steps, String ctx) async {
    for (final step in steps) {
      if (_abortedAll) return;
      final binding = switch (step) {
        final CmdStep s => s.as,
        final WaitEventStep s => s.as,
        _ => null,
      };
      var claimed = false;
      try {
        if (binding != null && GlobalData.isPath(binding)) {
          if (env.global == null) {
            throw const FormatException('Global data was not supplied');
          }
          env.global!.claim(binding);
          claimed = true;
        }
        await runZoned(() => _runStep(step, ctx), zoneValues: {
          #dataReadContext: {
            'context': ctx,
            'binding': binding,
            'step': switch (step) {
              final CmdStep s => s.cmd,
              final WaitEventStep s => s.event,
              _ => step.runtimeType.toString()
            }
          },
        });
      } on FormatException catch (error) {
        if (claimed) {
          _bind(binding, {...Envelope.error(error).toMap(), 'data': null},
              ok: false);
        }
        final (kind, name, agent, policy) = switch (step) {
          CmdStep s => ('cmd', s.cmd, s.agent, s.onFail),
          WaitEventStep s => ('wait_event', s.event, s.agent, s.onFail),
          _ => ('flow', 'reference', null, OnFail.abortAll),
        };
        report.add(StepRecord(
            kind: kind,
            context: ctx,
            name: name,
            agent: agent,
            status: 'failed',
            durationMs: 0,
            reason: error.message.toString(),
            result: {'failureKind': 'tool'}));
        _trace('reference_error',
            {'context': ctx, 'name': name, 'error': error.message});
        _applyOnFail(policy);
      }
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
    final skip = s.skipOnFailedDeps ?? spec.defaults.skipOnFailedDeps;

    // Host-side library lookup (protocol v2): the agent never sees the
    // device script; we dispatch full step content.
    final script = spec.scripts[s.agent];
    final step = script?.stepsById[s.cmd];
    if (step == null) {
      throw InterpError(
          'command "${s.cmd}" not found in agent "${s.agent}" device script');
    }
    final api = step['api'] as String;

    // Skip-on-failed-deps, source 1: flow variables referenced by inputs.
    if (skip) {
      final refs = collectRefs(s.inputs);
      final failed = [
        ...refs.where((n) => !env.isOk(n)),
        ..._failedGlobalRefs([s.inputs, step['params'], step['expect']]),
      ];
      if (failed.isNotEmpty) {
        _recordStep(s.agent, s.cmd, ok: false);
        if (s.as != null && GlobalData.isPath(s.as!)) {
          _bind(s.as, null, ok: false);
        }
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

    // Parameter reference resolution (AutoMode semantics, exact full-string
    // match): `$inputs.*` from the flow, `$config.*` from the agent env,
    // `$step.<id>.*` from prior commands on the same agent, `$prev` from the
    // most recent command's data.
    final inputs = resolveValue(s.inputs, env) as Map<String, Object?>? ??
        const <String, Object?>{};
    final failedDeps = <String>{};
    final usedInputs = <String>{};
    final params =
        _resolveParams(step['params'], s.agent, inputs, failedDeps, usedInputs)
                as Map<String, Object?>? ??
            const <String, Object?>{};
    final expectation = _resolveExpect(step['expect'], s.agent, inputs);

    // Skip-on-failed-deps, source 2: device-script references to steps that
    // failed on this agent (AutoMode's blocked-step semantics).
    if (skip && failedDeps.isNotEmpty) {
      _recordStep(s.agent, s.cmd, ok: false);
      if (s.as != null && GlobalData.isPath(s.as!)) {
        _bind(s.as, null, ok: false);
      }
      report.add(StepRecord(
        kind: 'cmd',
        context: ctx,
        agent: s.agent,
        name: s.cmd,
        status: 'skipped',
        durationMs: 0,
        reason: 'failed step deps: ${failedDeps.join(', ')}',
      ));
      return;
    }

    final timeoutMs = s.timeoutMs ?? spec.defaults.stepTimeoutMs;
    _trace('command', {
      'context': ctx,
      'agent': s.agent,
      'command': s.cmd,
      'binding': s.as,
      'api': api,
      'params': params,
      'expect': expectation
    });

    Envelope envelope;
    try {
      envelope =
          await agents[s.agent]!.runCommand(api, params, timeoutMs).timeout(
                Duration(milliseconds: timeoutMs),
                onTimeout: () => Envelope.timeout(timeoutMs),
              );
    } catch (e) {
      envelope = Envelope.error(e);
    }

    if (_stopped) return;
    _trace('result', {
      'context': ctx,
      'agent': s.agent,
      'command': s.cmd,
      'binding': s.as,
      'result': envelope.toMap()
    });

    // Host-side judgment: evaluate the step's expect against the actual
    // envelope (absent expect => assert success, AutoMode semantics).
    // Expect operands resolve references first ($config/$agents/$inputs),
    // so assertions like "list contains the other role's userId" stay
    // account-agnostic.
    final expectOutcome = envelope.status == 'timeout'
        ? const ExpectOutcome(matched: false)
        : evaluateExpect(envelope.toMap(), expectation);

    // "Step ok" follows the EXPECTATION, not the envelope success flag: a
    // reverse case (expected errorCode hit) is a successful step whose
    // binding downstream steps may reference; only an expectation miss
    // (or timeout/tool failure) makes producers "not ok" for the
    // skip-on-failed-deps cascade.
    final stepOk = expectOutcome.matched;
    if (s.as != null) {
      _bind(
          s.as,
          GlobalData.isPath(s.as!)
              ? {...envelope.toMap(), 'data': envelope.data}
              : envelope.toMap(),
          ok: stepOk);
    }
    _recordStep(s.agent, s.cmd, ok: stepOk, data: envelope.data);
    _prev[s.agent] = envelope.data;

    final failed = !expectOutcome.matched;
    final unusedInputs =
        inputs.keys.where((k) => !usedInputs.contains(k)).toList();
    report.add(StepRecord(
      kind: 'cmd',
      context: ctx,
      agent: s.agent,
      name: s.cmd,
      status: envelope.status == 'timeout'
          ? 'timeout'
          : (failed ? 'failed' : 'passed'),
      durationMs: sw.elapsedMilliseconds,
      result: {
        ...envelope.toMap(),
        if (s.as != null) 'binding': s.as,
        'api': api,
        'expectMatched': expectOutcome.matched,
        if (expectOutcome.checks.isNotEmpty) 'checks': expectOutcome.checks,
        if (unusedInputs.isNotEmpty) 'unusedInputs': unusedInputs,
      },
    ));

    if (failed) _applyOnFail(s.onFail);
  }

  void _recordStep(String agent, String stepId,
      {required bool ok, Object? data}) {
    _stepData.putIfAbsent(agent, () => {})[stepId] = _StepOutcome(ok, data);
  }

  /// Resolve `$`-references inside an expect block (deep copy; strings go
  /// through the same substitution as params). Keeps assertions such as
  /// `contains: $agents.bob.userId` account-agnostic.
  Object? _resolveExpect(Object? v, String agent, Map<String, Object?> inputs) {
    if (v is Map) {
      return {
        for (final e in v.entries)
          e.key.toString(): _resolveExpect(e.value, agent, inputs),
      };
    }
    if (v is List) {
      return [
        for (final item in v) _resolveExpect(item, agent, inputs),
      ];
    }
    if (v is String &&
        (v.startsWith(r'$global.') ||
            v == r'$config' ||
            v.startsWith(r'$config.') ||
            v == r'$agents' ||
            v.startsWith(r'$agents.') ||
            v == r'$inputs' ||
            v.startsWith(r'$inputs.'))) {
      return _resolveParams(v, agent, inputs, <String>{}, <String>{});
    }
    return v;
  }

  /// Substitute parameter references. Records step ids whose data was
  /// requested but whose producer failed (skip signal) and which input
  /// slots were actually used (unused-inputs typo guard).
  Object? _resolveParams(
    Object? v,
    String agent,
    Map<String, Object?> inputs,
    Set<String> failedDeps,
    Set<String> usedInputs,
  ) {
    if (v is String) {
      if (v == r'$global' || v.startsWith(r'$global.')) {
        if (!isRef(v)) throw FormatException('Invalid global reference: $v');
        return env.lookup(refPath(v));
      }
      if (v == r'$inputs') return inputs;
      if (v.startsWith(r'$inputs.')) {
        final path = v.substring(8);
        usedInputs.add(path.split('.').first);
        return _dig(inputs, path);
      }
      if (v == r'$config') return spec.envs[agent] ?? const {};
      if (v.startsWith(r'$config.')) {
        return _dig(spec.envs[agent] ?? const {}, v.substring(8));
      }
      if (v == r'$agents' || v.startsWith(r'$agents.')) {
        // Host-side cross-role data: `$agents.<role>.<path>` resolves
        // against the target role's env (e.g. the other device's
        // `$agents.bob.userId`). Undeclared roles resolve to null.
        // '$agents.' is 8 chars — must strip the dot too, otherwise the
        // first path segment becomes '' and every lookup resolves to null.
        final path = v.substring(8);
        if (path.isEmpty) {
          return {
            for (final role in spec.agents.keys)
              role: spec.envs[role] ?? const <String, Object?>{},
          };
        }
        final role = path.split('.').first;
        final roleEnv = spec.envs[role] ?? const <String, Object?>{};
        final rest =
            path.length > role.length ? path.substring(role.length + 1) : '';
        return rest.isEmpty ? roleEnv : _dig(roleEnv, rest);
      }
      if (v == r'$prev') return _prev[agent];
      if (v.startsWith(r'$prev.')) return _dig(_prev[agent], v.substring(6));
      if (v.startsWith(r'$step.')) {
        final parts = v.substring(6).split('.');
        final stepId = parts.first;
        final outcome = _stepData[agent]?[stepId];
        if (outcome != null && !outcome.ok) failedDeps.add(stepId);
        return outcome == null
            ? null
            : _dig(outcome.data, parts.sublist(1).join('.'));
      }
      return v;
    }
    if (v is Map) {
      // Normalize to Map<String, Object?> regardless of the source map's
      // generics (literals, jsonDecode, YAML views all differ).
      return <String, Object?>{
        for (final e in v.entries)
          e.key as String:
              _resolveParams(e.value, agent, inputs, failedDeps, usedInputs),
      };
    }
    if (v is List) {
      return v
          .map((e) => _resolveParams(e, agent, inputs, failedDeps, usedInputs))
          .toList();
    }
    return v;
  }

  /// Dot-path dig over maps (key) and lists (numeric index); null on miss.
  static Object? _dig(Object? v, String path) {
    var cur = v;
    for (final key in path.split('.')) {
      if (cur is Map) {
        cur = cur[key];
      } else if (cur is List) {
        final i = int.tryParse(key);
        if (i == null || i < 0 || i >= cur.length) return null;
        cur = cur[i];
      } else {
        return null;
      }
    }
    return cur;
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
    final failed = _failedGlobalRefs([s.match, s.checks]);
    if (failed.isNotEmpty) {
      if (s.as != null && GlobalData.isPath(s.as!)) {
        _bind(s.as, null, ok: false);
      }
      report.add(StepRecord(
          kind: 'wait_event',
          context: ctx,
          name: s.event,
          agent: s.agent,
          status: 'skipped',
          durationMs: 0,
          reason: 'failed global deps: ${failed.join(', ')}'));
      return;
    }
    // Strict global operands must be ready before polling starts. Event
    // history remains available even when the producer completed earlier.
    final checks = resolveValue(s.checks, env) as List;
    for (final value in s.match.values) {
      if (value is String && value.startsWith(r'$global.')) {
        resolveValue(value, env);
      }
    }

    // Each wait scans from its OWN snapshot of the agent cursor; the shared
    // per-agent cursor only advances (monotonic max) when a wait matches.
    // Consequences (isolation & consumption rules):
    // - concurrent waits on one agent observe independently: one branch
    //   scanning ahead never consumes events another branch still needs;
    //   two waits MAY match the same event when they genuinely overlap;
    // - a sequential wait starts from the previous match: the same event
    //   cannot satisfy two sequential waits;
    // - a timed-out wait consumes nothing.
    var local = _cursors[s.agent] ?? 0;

    while (true) {
      if (_stopped) return;
      final events = await client.pollEvents(local, waitMs: 200);
      if (_stopped) return;

      for (final ev in events) {
        _trace('event', {
          'agent': s.agent,
          'eventSeq': ev.seq,
          'source': ev.source,
          'payload': ev.payload
        });
        // Advance the local scan position past every event inspected.
        local = ev.seq;

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
        if (checks.isNotEmpty &&
            !evaluateChecks(ev.payload, checks)
                .every((c) => c['passed'] == true)) {
          continue;
        }

        if (ev.seq > (_cursors[s.agent] ?? 0)) {
          _cursors[s.agent] = ev.seq;
        }
        if (s.as != null) {
          _bind(s.as, ev.payload, ok: true);
        }
        report.add(StepRecord(
          kind: 'wait_event',
          context: ctx,
          agent: s.agent,
          name: s.event,
          status: 'passed',
          durationMs: sw.elapsedMilliseconds,
          result: {
            'seq': ev.seq,
            'payload': ev.payload,
            if (s.as != null) 'binding': s.as
          },
        ));
        return;
      }

      if (DateTime.now().isAfter(deadline)) {
        if (s.as != null && GlobalData.isPath(s.as!)) {
          _bind(s.as, null, ok: false);
        }
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
