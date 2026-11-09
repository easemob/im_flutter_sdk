# 新 worktree 应先解析依赖再格式化 Dart

- 日期：2026-11-09
- 状态：已确认并规避
- 触发仓库：`im_flutter_sdk`，`5.1.0` 分支
- 适用环境：Flutter 3.47.0 / Dart 3.13.0，新建 worktree

## 结论

先生成本地依赖覆盖并执行 `flutter pub get`，再运行 `dart format`。新 worktree 缺少 `.dart_tool/package_config.json` 时，格式化可能采用与依赖解析后不同的语言版本，产生无关改动，并在质量检查中再次被判定需要格式化。

## 现象与根因

本次在解析依赖前格式化 `chat_manager.dart` 和 `chat_apis.dart`，出现大量缩进及换行变化。质量脚本完成依赖解析后，对同一文件执行格式检查却失败。解析依赖生成的包配置包含语言版本信息，格式化器据此选择格式规则；同一个 Dart 可执行文件不代表格式规则始终相同。

## 修法

依赖解析后重新格式化，并检查 diff。早先格式化删除的尾逗号未必自动恢复，应还原无关块，再检查格式。本次最终三个改动的 Dart 文件格式检查通过，保留功能改动范围。

## 排查命令备忘

在业务仓库 worktree 根目录执行：

```bash
make deps
dart format --output=none --set-exit-if-changed <changed-dart-files>
git diff --stat
```
