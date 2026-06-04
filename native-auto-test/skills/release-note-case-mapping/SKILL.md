---
name: release-note-case-mapping
description: Parse Easemob SDK release notes and map each change item to executable API test cases in this repo. Use when planning regression by version range, preparing test submissions from release records, generating covered/uncovered case matrices, or adding a dedicated pytest marker/label for release-driven case batches.
---

# Release Note Case Mapping

## Workflow

1. Confirm source and version range.
- Use official release-note URL as source of truth.
- Freeze the exact range, for example `4.14.0 ~ 4.16.2`.
- If a requested version does not exist in the source page, record that explicitly.

2. Extract change items by version.
- Split by version heading (`h2`) then subsection (`新增特性/优化/修复`).
- Flatten each bullet into one atomic “change item”.
- Keep wording close to source to avoid semantic drift.

3. Map each item to testability class.
- `已覆盖`: existing executable cases already verify the behavior.
- `可补充`: can be covered by new/extended API tests in this repo.
- `当前不可覆盖`: infra/perf/native-internal/demo-only change that cannot be stably asserted by API cases.

4. Produce artifact files.
- Write the matrix under `docs/` (never under `tests/`).
- Include: version, change item, status, mapped test file/case, gap reason, suggested case design.

5. Add release execution marker.
- Register marker in `pytest.ini`.
- Use a valid pytest marker id, for example `agorachat1_4_0`.
- Keep user-facing label in docs, for example `agorachat1.4.0`.
- Add marker to covered case files via module-level `pytestmark`.

6. Provide runnable command.
- Example:
```bash
pytest -q -m agorachat1_4_0 tests -s
```
- If needed, include domain slice:
```bash
pytest -q -m agorachat1_4_0 tests/group tests/chat tests/chatroom -s
```

## Mapping Rules

1. Prefer primary evidence.
- Prioritize existing strict cases that assert envelope plus key business fields.
- Do not mark covered if only weak/type-only assertions exist.

2. Keep boundaries explicit.
- Performance-only optimization without stable API signal goes to `当前不可覆盖`.
- SDK-internal crash fixes without deterministic trigger go to `当前不可覆盖`.
- API-surface additions map to `可补充` if command exists but case missing.

3. Preserve repo constraints.
- Executable tests only in `tests/`.
- Release mapping docs only in `docs/`.
- No debug switches added in test logic.
- Assertions follow `docs/agents/AGENTS.zh.md`.

## Output Template

Use this table in release coverage docs:

| 版本 | 变更类型 | 发版变更项 | 覆盖状态 | 现有用例 | 备注/补充设计 |
|---|---|---|---|---|---|
| vX.Y.Z | 新增/优化/修复 | ... | 已覆盖/可补充/当前不可覆盖 | `tests/...::test_...` | 说明 |
