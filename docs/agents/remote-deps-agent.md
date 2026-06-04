# Remote Deps Agent（远程依赖更新与构建）

- 职责
  - 将 Android 与 iOS 从“本地”切换为“远程依赖”，并更新到指定版本；完成自检与两端构建。
- 必用技能
  - using-superpowers（计划/清单）
  - speckit（检查与构建）
- 输入参数
  - ANDROID_VER（如 4.20.0）→ 用于 `io.hyphenate:hyphenate-chat:<ver>`；可与本地 jar 版本不同
  - IOS_HY_VER（如 4.20.0）：HyphenateChat 远程依赖版本下限 `>=`
  - IOS_SW_CHAT_VER（如 1.3.2）：ShengwangChat_iOS 远程依赖版本下限 `>=`
- 步骤
  1) 阅读 docs/specs/upgrade-flow.md 并确认目标版本
  2) 执行脚本（见下）进行“远程依赖切换”，默认 dry-run 显示差异；加 `--apply` 才会写入
  3) speckit.sh check → android → ios → ios-build
- 验收标准
  - spec_check PASS；Android assembleDebug 成功；iOS pod install + 模拟器构建成功

- 脚本
  - `im_flutter_sdk/scripts/agents/remote_deps_agent.sh --android-ver 4.20.1 --ios-hy-ver 4.20.1 --ios-sw-chat-ver 1.3.3 --apply`
