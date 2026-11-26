# 目录改名会让存量格式漂移集中触发格式门禁

- 日期：2026-11-26
- 状态：已确认并规避
- 触发仓库：`im_flutter_sdk`，`5.2.0` 分支（`im_flutter_sdk/example` → `workbench` 迁移）
- 适用环境：Flutter 3.47.0 / Dart 3.13.0，`tool/ci/run_quality.sh` 格式门禁

## 结论

格式门禁（`dart format --set-exit-if-changed`）只检查**相对基线有改动的文件**。`git mv` 目录改名后，全部被移动文件在 diff 中都算"改动"，此前从未被门禁覆盖到的存量未格式化文件会一次性全部失败。修法：改名提交前，先对整个被移动目录执行一次 `dart format`，把纯格式改动并入改名提交。

## 现象与根因

`example` → `workbench` 改名后跑 `run_quality.sh`，14 个从未手工编辑过的 Dart 文件被判格式不合规（典型为超 80 列未换行）。根因：门禁按 `git diff --name-only <base>` 选文件，这些文件历史上从未进入任何 PR 的 diff，漂移从未暴露；改名使它们全部进入 diff。与 [2026-11-09 新 worktree 格式化记录](2026-11-09-new-worktree-dart-format.md) 的语言版本问题无关——本次依赖解析已完成，格式结果就是 CI 的真实判定。

## 修法

```bash
dart format <被移动目录>          # 或门禁输出的具体文件清单
bash tool/ci/run_quality.sh       # 复跑确认 Formatted N files (0 changed)
```

格式化产物是 CI 同款判定（本地 Flutter/Dart 版本须与 CI 的 `FLUTTER_VERSION` 一致），直接随改名提交即可，不会在 CI 上反弹。

## 排查命令备忘

```bash
# 看格式化器具体想改什么（不写入）
dart format --output=show <file> | diff - <file>
# 确认本地工具链与 CI 一致
dart --version   # 对照 .github/workflows/ci.yml 的 FLUTTER_VERSION
```
