# Test Assets Reorganization Plan (Interim Structure)

Date: 2026-11-26
Branch: 5.2.0 (do not merge to 5.x yet)
Status: in progress

## Background

The repository's test assets are currently scattered across three top-level directories (`testing/`, `scripts/`, `tool/`) that all exist only to serve the workbench-based test modes. After the example app was moved out of the published package to `workbench/` (commit 9b049ff2), the same ownership logic applies to test assets: each test mode should own its code, cases, and docs in one place.

This plan implements the **interim structure** agreed with the user: move assets under their owning area with pure `git mv` plus reference updates, without changing tool logic. The final structure (promoting integration/unit tests to a root-level `testing/`, demoting workbench back to a pure app) is documented as direction only and is explicitly out of scope.

## Target Layout (interim)

```
ci/                          # was tool/ci/ — orchestration plane, peer of workbench
  *.sh, *.py, patches/       # (unchanged content, paths updated)
  use_local_packages.sh      # was tool/use_local_packages.sh
workbench/
  single/                    # was testing/single/ (auto_report.dart + cases/ + README)
  multi/                     # was testing/multi/ + scripts/multi.sh + testing/multi-tool.json
  tool/                      # existing; gains report_upgrade.py, test_report_upgrade.py, target-flutter.yaml
```

Removed after the move: `testing/`, `scripts/`, `tool/` (root level).

## Tasks

- [x] 1. `git mv testing/single workbench/single`
- [x] 2. `git mv testing/multi workbench/multi`; move `scripts/multi.sh` and `testing/multi-tool.json` into `workbench/multi/`
- [x] 3. `git mv` `testing/report_upgrade.py`, `testing/test_report_upgrade.py`, `testing/target-flutter.yaml` into `workbench/tool/`
- [x] 4. `git mv tool/ci ci`; move `tool/use_local_packages.sh` into `ci/`; remove empty `tool/`, `testing/`, `scripts/`
- [x] 5. Update functional references (Edit tool only, no sed/perl):
  - `Makefile` (auto_report path, scan_deprecated, use_local_packages)
  - `workbench/single/auto_report.dart` default script paths + report_upgrade.py path
  - `workbench/multi/multi.sh` (PIN_FILE, CLONE_DIR, --cases-dir) and `workbench/tool/target-flutter.yaml` (casesDir)
  - `ci/*.sh` cross-references (`$REPO_ROOT/tool/ci/...` → `$REPO_ROOT/ci/...`; keep `im_flutter_sdk/tool/ci/` untouched)
  - `ci/test_report_runners.py` self-test temp-root paths
  - `.github/workflows/ci.yml`, `.github/workflows/ci-device.yml`
  - `.gitignore` orchestrator clone dir entry
  - workbench internal references (`templates/env.example.dart`, `test/script_500_coverage_test.dart`, `bugs/HIM-23835/run.dart`, `integration_test/modules/client_cases.dart`)
- [x] 6. Update active docs only (history untouched): root `README.md`, `AGENTS.md`, `CONTRIBUTING.md`, `ci/README.md`, `workbench/README.md`, `workbench/single/README.md`, `workbench/multi/README.md`, `docs/testing/README.md`, `docs/testing/2026-11-09-*.md`, `im_flutter_sdk/docs/ci/flutter-only-ci.md`; merge `testing/README.md` content into the workbench READMEs, then delete it
- [x] 7. Grep sweep: `testing/`, `scripts/multi`, `tool/ci`, `tool/use_local_packages` — zero hits outside gitignored/historical paths
- [x] 8. `bash ci/run_quality.sh` green (dart format first if drift surfaces)
- [x] 9. Single-device smoke on both emulators: `make auto-report PLATFORM=<android|ios> SCRIPT=workbench/single/cases/spot_520_multibody_text.json` (script initially created under `artifacts/single/`, relocated into tracked `workbench/single/cases/` per user review)
- [x] 10. One integration lane (Android logged_out smoke) + `workbench/multi/multi.sh generate` static check
- [x] 11. Append dailylog entry; commit on 5.2.0 (English message, local only, no push)

## Notes

- `im_flutter_sdk/tool/ci/check_deprecated_api.dart` lives inside the main package and is NOT moved; only root-level references change.
- After `git mv` of workbench-touched paths, run `flutter clean && flutter pub get` in workbench if build caches carry stale absolute paths (see docs/refs/troubleshooting/2026-11-26-git-mv-stale-build-cache.md).
- Multi-device full runs still require the external im-test-orchestrator checkout; verification here stops at `generate`.
