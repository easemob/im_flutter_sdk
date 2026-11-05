/// Flow AST definitions.
///
/// The interpreter is generic by design: steps reference opaque command ids
/// and agent roles only. No business semantics are attached to any node.
library;

import 'expr.dart';

/// Failure policy for a step.
enum OnFail {
  /// Record the failure and continue with the next step (default).
  continue_,

  /// Terminate the current execution line (a parallel branch, or the flow).
  abortFlow,

  /// Terminate the whole run; sibling branches wind down as soon as possible.
  abortAll;

  static OnFail parse(String s) => switch (s) {
        'continue' => OnFail.continue_,
        'abort_flow' => OnFail.abortFlow,
        'abort_all' => OnFail.abortAll,
        _ => throw ArgumentError('unknown onFail value: $s'),
      };
}

/// Global defaults for a flow.
class Defaults {
  const Defaults({
    this.stepTimeoutMs = 30000,
    this.onFail = OnFail.continue_,
    this.skipOnFailedDeps = true,
  });

  final int stepTimeoutMs;
  final OnFail onFail;
  final bool skipOnFailedDeps;
}

/// One agent role declared in the flow. `endpoint` is where the agent's HTTP
/// control service listens; `scriptPath` points at the device-script JSON
/// command library (loaded by the parser); `envPath` optionally points at a
/// runtime environment JSON (the `$config` / `$agents.<role>` source).
/// `meta` is free-form info for humans and external tools.
class AgentDecl {
  AgentDecl({
    required this.name,
    required this.endpoint,
    required this.scriptPath,
    this.envPath,
    this.meta = const {},
  });

  final String name;
  final Uri endpoint;
  final String scriptPath;
  final String? envPath;
  final Map<String, Object?> meta;
}

/// A parsed device-script JSON: the command library for one agent.
///
/// `stepsById` maps step id -> raw step map (`{api, params, expect?, ...}`).
/// The interpreter looks commands up here, resolves parameter references,
/// and judges the returned envelope against the step's `expect` — the agent
/// itself never sees this library (protocol v2, 2026-11-05).
///
/// Top-level `init`/`login` blocks of the legacy script shape are kept for
/// the AutoMode direct-run path only; under HTTP they are ordinary steps
/// that the script author declares with ids.
class DeviceScript {
  DeviceScript({this.init, this.login, Map<String, Map<String, Object?>>? steps})
      : stepsById = steps ?? {};

  final Map<String, Object?>? init;
  final Map<String, Object?>? login;
  final Map<String, Map<String, Object?>> stepsById;
}

/// The parsed flow document.
///
/// `scripts`/`envs` are populated by the parser (or injected directly by
/// tests): role -> loaded device script / environment map.
class FlowSpec {
  FlowSpec({
    required this.name,
    this.runId,
    this.flowTimeoutMs,
    required this.agents,
    required this.defaults,
    required this.steps,
  })  : scripts = {},
        envs = {};

  final String name;
  final String? runId;
  final int? flowTimeoutMs;
  final Map<String, AgentDecl> agents;
  final Defaults defaults;
  final List<Step> steps;

  final Map<String, DeviceScript> scripts;
  final Map<String, Map<String, Object?>> envs;
}

/// Base type of all flow steps.
sealed class Step {
  const Step();
}

/// Execute one opaque command on the given agent.
class CmdStep extends Step {
  const CmdStep({
    required this.cmd,
    required this.agent,
    this.inputs,
    this.as,
    this.timeoutMs,
    this.onFail,
    this.skipOnFailedDeps,
  });

  final String cmd;
  final String agent;
  final Map<String, Object?>? inputs;
  final String? as;
  final int? timeoutMs;
  final OnFail? onFail;
  final bool? skipOnFailedDeps;
}

/// Run branches concurrently; join-all semantics: the block completes when
/// every branch has finished (successfully or not). Nesting `parallel`
/// inside a branch is rejected by the parser (first-version restriction).
class ParallelStep extends Step {
  const ParallelStep({required this.branches});

  final Map<String, List<Step>> branches;
}

/// Wait for one matching event on the given agent's event stream.
/// The main value is the SDK callback method name (decision 2026-11-05).
class WaitEventStep extends Step {
  const WaitEventStep({
    required this.event,
    required this.agent,
    this.match = const {},
    this.as,
    this.timeoutMs,
    this.onFail,
  });

  final String event;
  final String agent;
  final Map<String, Object?> match;
  final String? as;
  final int? timeoutMs;
  final OnFail? onFail;
}

/// Synchronization point shared by branches of the same parallel block.
/// Must appear on the unconditional path of every participating branch;
/// a branch that exits early releases the others instead of hanging them.
class BarrierStep extends Step {
  const BarrierStep(this.name);

  final String name;
}

/// Conditional branch on an expression.
class IfStep extends Step {
  const IfStep({
    required this.cond,
    required this.thenSteps,
    this.elseSteps = const [],
  });

  final Expr cond;
  final List<Step> thenSteps;
  final List<Step> elseSteps;
}

/// Iterate over a list variable or an inclusive integer range.
class ForStep extends Step {
  const ForStep({
    required this.varName,
    this.listRef,
    this.rangeStart,
    this.rangeEnd,
    required this.doSteps,
  });

  final String varName;
  final String? listRef;
  final int? rangeStart;
  final int? rangeEnd;
  final List<Step> doSteps;
}

/// Loop while an expression holds true. `flowTimeoutMs` is the backstop
/// against accidental infinite loops.
class WhileStep extends Step {
  const WhileStep({required this.cond, required this.doSteps});

  final Expr cond;
  final List<Step> doSteps;
}

/// Assign values (literals or references) to flow variables.
class SetStep extends Step {
  const SetStep(this.assignments);

  final Map<String, Object?> assignments;
}

/// Sleep for the given milliseconds.
class DelayStep extends Step {
  const DelayStep(this.ms);

  final int ms;
}
