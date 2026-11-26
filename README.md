# EaseMob IM Flutter SDK

The Flutter plugin for EaseMob instant messaging, built on the Federated Plugin architecture. This repository contains the Dart public APIs, the Android/iOS implementations, the internal workbench app, and the test tooling; HarmonyOS is maintained in a separate repository.

Call chain: `Dart API → MethodChannel → Native Wrapper → native IM SDK`.

## Verification Modes and Entry Points

| Mode | Responsibility | Entry point |
|---|---|---|
| CI tests | Guard basic behavior, stability, and regression coverage | `.github/workflows/`; local entry points `run_quality.sh`, `smoke_local.sh`, `nightly_local.sh` under `ci/`, see [CONTRIBUTING](CONTRIBUTING.md#running-and-verification) |
| AI tests | Verify the APIs, behavior changes, and single-/multi-device scenarios of each SDK version port | Single-device: `make auto-report PLATFORM=<android\|ios> SCRIPT=<json>`, see [script mode](workbench/README.md#script-mode-ai-friendly); multi-device: `workbench/multi/cases/` via `workbench/multi/multi.sh`, see [usage](workbench/multi/README.md) |
| Manual mode | Freely spot-check APIs and extract usable example code | Go to `workbench/` and run `flutter run -d <device id>`, see [workbench README](workbench/README.md) |

CI uses Flutter unit, contract, and on-device integration tests; AI tests use JSON scripts and YAML control flows. The two test architectures are maintained independently, their API coverage may overlap, and neither result replaces the other. Manual mode is free-form operation, not an automated case suite.

For each version port, complete the relevant single-device and multi-device scenario acceptance first, then promote basic behaviors, key boundaries, and fixed defects that need lasting protection into CI regression cases.

## Directory Layout

```text
.
├── im_flutter_sdk/             # Main SDK package
│   ├── lib/                    # Public APIs, models, and business managers
│   ├── test/                   # SDK unit and contract tests
│   ├── example/                # Minimal user-facing example published to pub.dev
│   ├── docs/                   # SDK-specific notes, CI case mapping
│   ├── scripts/                # API documentation generation tools
│   └── tool/ci/                # Contract, version, and case-mapping checkers
├── workbench/                  # Internal workbench app: manual operation, script execution, HTTP control server
│   ├── lib/                    # Pages, API registry, logging, and the automated runner
│   ├── integration_test/       # On-device Flutter integration tests run by CI
│   ├── test/                   # Tests for the workbench app and runner itself
│   ├── single/                 # Single-device JSON scenarios and the auto_report.dart runner
│   ├── multi/                  # Multi-device cases and the multi.sh orchestrator wrapper
│   └── tool/                   # Workbench-side tools (env tool, upgrade report, target yaml)
├── ci/                         # CI quality gate and device-test entry points
├── im_flutter_sdk_interface/   # MethodChannel platform interface
├── im_flutter_sdk_android/     # Android native wrapper
├── im_flutter_sdk_ios/         # iOS native wrapper and dependency config
├── .github/workflows/          # CI triggers and job orchestration
├── docs/                       # Specs, plans, version-port records, troubleshooting
├── dailylog/                   # Collaboration work logs
└── Makefile                    # Environment setup and common development commands
```

`workbench/multi` is for multi-device execution; single-device scripts use `make auto-report`. Local credentials, generated account data, build caches, and run reports are managed by the tools and not committed to Git.

## Documentation

| Audience | Entry | Content |
|---|---|---|
| SDK users | [SDK integration guide](im_flutter_sdk/README.md) | Integration, platform configuration, quick start |
| Developers and maintainers | [CONTRIBUTING.md](CONTRIBUTING.md) | Dev environment, verification, branching and release process |
| CI case maintainers | [Case notes](im_flutter_sdk/docs/ci/flutter-only-ci.md), [verification records](docs/refs/ci-basic-api-tests/2026-11-07-positive-verification.md) | Coverage, run conditions, reports, and open items |
| AI agents | [AGENTS.md](AGENTS.md) | Architecture boundaries, task selection, collaboration rules |
| Case authors | [Testing guide](docs/testing/README.md), [single-device](workbench/single/README.md), [multi-device](workbench/multi/README.md) | Scenario selection, design principles, and execution for the three test modes |

Development uses Flutter 3.47.0. See the contributing guide for environment setup; run `make help` at the repo root for available commands.
