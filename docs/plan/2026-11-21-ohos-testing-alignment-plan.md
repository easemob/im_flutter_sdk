# ohos 测试框架对齐（自 4.x 迁移）实现计划

关联规格：`docs/spec/2026-11-21-ohos-testing-alignment-spec.md`
目标分支：`ohos`（worktree：`.worktree/ohos`）；4.x 侧仅 T1 前半段；IMTO 侧 T4 子任务
总工作量估计：6–8 天（T4 含 IMTO ohos 平台支持，已上调）

## 任务与验收

- [ ] **T0 可行性核对表**：12 个 multi 场景 × 29 个 API × ohos registry/gap 台账核对，产出 `docs/testing/ohos-multi-api-matrix.md`（可跑/skip 及依据）。验收：modifyMessage 等疑点 API 有明确结论
- [ ] **T1 REST 同构**：4.x `rest_fixture.dart` 吸收 ohos 写侧方法（4.x 提交，走 4 线到 main）；ohos 侧替换 support 层、删 rest/env/session、改 9 处调用点。验收：两线 diff 为空 + ohos 集成套件本地全量通过
- [ ] **T2 auto step 引擎**：移植 3 个新文件，合并 auto_mode.dart（保内联 JSON）。验收：官方 flutter 质量门 + ohos 侧单设备可跑 step 脚本
- [ ] **T3 agent 移植**：覆盖 `example/lib/agent/` + main.dart 三模式接线。验收：fvm 构建通过，控制端可对设备下发脚本
- [ ] **T4 multi 场景**：覆盖 12 场景（重命名 1.16.0-multi-*），skip 场景有台账依据；**IMTO 增加 ohos 平台支持**（hdc 发现/装包/启动 + FLUTTER_BIN 构建 + hilog），ohos 仓新增 `scripts/multi.sh` 封装与 target yaml；账号走自助建号（REST createUser + client credentials 换双 token）；双鸿蒙设备实跑。验收：可跑场景全过；设备不可用则不跑并记录，不降级
- [ ] **T5 single 脚本**：auto_report.dart + 1.16.0 正反两脚本，单设备实跑。验收：脚本实跑通过
- [ ] **T6 runner/文档**：nightly_local.harmony.sh 接 multi/single，AGENTS.md 更新。验收：脚本能起入口、文档与实现一致

## 必需实现约定

- ohos 专有资产冻结清单（spec 2.3）全程不触碰
- 同构验收以两线 diff 为空为准，不凭印象
- 每任务完成：更新本文件复选框 + 追加"进度记录" + dailylog，随该任务代码一起提交并推送双远端
- 4.x 侧改动只走 4 线工作流（4.x → main → flutter2_stable 镜像），ohos 永不合并 main
- IMTO 改动提交其 `main` 并 push `origin`
- **Flutter 工具链纪律**：`.zshrc` 全局 `flutter` 是 custom_official（3.47.0）；鸿蒙构建/测试一律项目 `.fvm/flutter_sdk/bin/flutter` 或显式 `FLUTTER_BIN`，禁止裸 `flutter`；验证顺序：质量门（官方 3.47.0）→ 鸿蒙构建/实跑（fvm custom_ohos）；门禁后先 `fvm flutter pub get`
- multi 设备不可用则不跑、记录现象与环境，不降级冒烟（用户决策 2026-11-21）

## 任务依赖

- T1（4.x 加法）与 T2 无依赖，可并行
- T3 依赖 T2（agent 依赖 step 引擎执行脚本）
- T4 依赖 T1、T2、T3
- T5 依赖 T2（与 T3/T4 无强依赖，可与 T4 并行）
- T6 依赖 T4、T5

执行顺序建议：T0 → T1 → T2 → T3 → T4 ∥ T5 → T6

## 进度记录

（每完成一项追加一行：`- YYYY-MM-DD HH:MM <任务> <提交号> <验证结果>`；此节与复选框同步更新，随任务提交持久化）

## 验证记录

（任务级验证证据：命令、设备、结果摘要）
