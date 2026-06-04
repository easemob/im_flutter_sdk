# Superpowers 主规范（总 Agent）

本仓库采用“总 Agent + 执行 Agent”结构：
- 总 Agent（本文件）：统一流程、命名、质量门槛和调用技能（skills）。
- 执行 Agent（三类）：
  1) 远程依赖更新与构建（Remote Deps Agent）
  2) 本地依赖更新与构建（Local Deps Agent）
  3) API/回调适配与一致性检查（API Adapt Agent）

通用规则
- 统一命名：若 Android/iOS/Dart 命名不一致，以 Android 为准；Dart 与 iOS 对齐。
- 依赖切换：不使用 IM_USE_LOCAL_DEPS 等开关；通过编辑构建文件进行“手动切换”，脚本仅在获得确认后代改。
- 文档先行：任何操作前先阅读/更新规范：
  - 依赖切换规范：docs/specs/dependency-spec.md
  - API 适配规范：docs/specs/api-adaptation-spec.md
  - 升级流程规范：docs/specs/upgrade-flow.md
  - speckit 使用：docs/skills/speckit.md
- 构建校验：自检通过 → Android assembleDebug → iOS pod install → iOS 模拟器 build。
- 交付标准：变更点列表、构建日志摘要（成功/失败）、必要的代码与文档补丁。

必用技能（在开始任何动作前先调用/遵循）
- using-superpowers：建立计划、清单与检查点（用户可在私有技能库中查看）。
- speckit：统一执行检查与构建（im_flutter_sdk/scripts/speckit.sh）。

执行 Agent 入口与职责
- Remote Deps Agent：docs/agents/remote-deps-agent.md，脚本 im_flutter_sdk/scripts/agents/remote_deps_agent.sh
- Local Deps Agent：docs/agents/local-deps-agent.md，脚本 im_flutter_sdk/scripts/agents/local_deps_agent.sh
- API Adapt Agent：docs/agents/api-adapt-agent.md，脚本 im_flutter_sdk/scripts/agents/api_adapt_agent.sh

