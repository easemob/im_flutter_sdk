# Repository Conventions (Agent-facing)

- Skills
  - Keep all Codex skills under `skills/`.
  - Each skill includes `SKILL.md`, optional `openai.yaml`, and optional `scripts/`, `references/`, `assets/`.
- Documentation
  - Place docs under `docs/`.
  - `docs/agents/AGENTS.zh.md` 是唯一权威 Agent 文档（中文）。
  - `docs/spec/` 存放可执行测试规范与速查；新增规范统一写入 `docs/agents/AGENTS.zh.md`。
- Tests
  - Keep executable tests only under `tests/` (no documentation inside tests/).
- Tooling
  - Makefile exposes common tasks (`make help`). Prefer these targets for WS calls, REST user ops, and contact flows.
- Editor/Local artifacts
  - `.cursor/`, `.DS_Store`, and `allure-results/` are not part of the source of truth and are ignored via `.gitignore`.
- Do not create `.agents/` in this repo; use `skills/` for repo-local skills. Use `$CODEX_HOME/skills` for user-global skills when needed.

- Assertions: 禁止自证式 result 断言；优先断言信封字段 + 关键业务字段，或使用类型/条件与 ignore_keys。

See: `docs/agents/AGENTS.zh.md`（中文总规范）。

## Case Authoring Agent (Global)

This section defines the end-to-end workflow for writing and maintaining test cases across modules. It complements `docs/spec/CASES_SPEC.md`.

- Source of truth
  - Specs: `docs/spec/CASES_SPEC.md` (global + domain quick refs).
  - SDK keys: `src/sdk_api/cmd_keys.py`, `src/sdk_api/event_keys.py`.
  - Assertions helpers: `src/tools/assertions.py`, `src/tools/response_match.py`.

- Workflow (Strict-first with Discovery loop)
  - Skill gate: before changes, invoke the “using-superpowers” skill to check applicable skills and confirm process.
  - Scope: map Manager/Cmd and Event names to Dart; align `info` shapes with models.
  - Draft: outline one normal and one error/boundary case per API using `docs/spec/CASES_SPEC.md` domain quick refs.
  - Implement: place executable tests only under `tests/`; no docs under `tests/`.
  - Assertions: use `assert_api.assert_response_matches` for success, `assert_api.assert_error` for errors; minimal ignore set.
  - Discovery run: `CASES_DISCOVER=1 WS_DEBUG=1 pytest -q <path>::<case> -s` to capture actual vs expected diffs.
  - Tighten: incorporate stable fields into `expected`, reduce `ignore_keys`, then run strict (no env vars).

- Events & semantics
  - Always assert `type="event"` + `eventType` and key `data` fields. For Chat, respect convId semantics in send/receive.
  - Sync responses: only ignore `sequence`. Events: may ignore time-like keys (`timestamp/serverTime/localTime`) and `sequence`.

- Error canonicalization
  - Freeze known codes/phrases from `docs/spec/CASES_SPEC.md` where stable; otherwise discover then freeze.

- Debug policy
  - Do not add debug toggles in tests; WS-layer only (`WS_DEBUG`, `WS_RELAX`).

- Useful commands
  - Single (discovery): `CASES_DISCOVER=1 WS_DEBUG=1 pytest -q tests/<domain>/test_<topic>.py::test_<name> -s`
  - Module (strict): `pytest -q tests/<domain>/test_<topic>.py -s`
  - All: `pytest -q tests -s`

## Child Agents (Per-domain)

Child agent docs live under `docs/agents/` and reference domain agent rules plus `docs/spec/CASES_SPEC.md`. They define local checklists and invariants. Start here:

- Chat Case Agent: `docs/agents/chat/AGENTS.md`
- Contact Case Agent: `docs/agents/contact/AGENTS.md`

When working in a domain, consult the corresponding child agent doc and follow its checklist in addition to this global section.
