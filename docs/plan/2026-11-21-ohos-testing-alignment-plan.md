# ohos 测试框架对齐（自 4.x 迁移）实现计划

关联规格：`docs/spec/2026-11-21-ohos-testing-alignment-spec.md`
目标分支：`ohos`（worktree：`.worktree/ohos`）；4.x 侧仅 T1 前半段；IMTO 侧 T4 子任务
总工作量估计：6–8 天（T4 含 IMTO ohos 平台支持，已上调）

## 任务与验收

- [x] **T0 可行性核对表**：12 个 multi 场景 × 31 个 API × ohos registry/gap 台账核对，产出 `docs/testing/ohos-multi-api-matrix.md`（可跑/skip 及依据）。验收：modifyMessage 等疑点 API 有明确结论
- [x] **T1 REST 同构**：4.x `rest_fixture.dart` 吸收 ohos 写侧方法（4.x 已提交 6a3ca669 并走到 main）；ohos 侧替换 support 层、删 rest.dart（env/session/login/ci_test 保留，见 spec 3.1 修正）、适配 8 个调用点文件。验收：两线 rest_fixture.dart/rest_resource_client.dart diff 为空（已验证）+ ohos 集成套件本地全量通过（待设备环境复验）
- [x] **T2 auto step 引擎**：移植 3 个新文件，合并 auto_mode.dart（保内联 JSON）。验收：官方 flutter 质量门（dart analyze 0 issue 已达成）+ ohos 侧单设备可跑 step 脚本（随 T5 复验）
- [x] **T3 agent 移植**：覆盖 `example/lib/agent/` + main.dart 三模式接线。验收：fvm 构建通过（待 T6 前复验），控制端可对设备下发脚本（待双设备实跑 T4 复验）；loopback HttpServer 仅编译验证，鸿蒙运行时待实跑确认
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

- 2026-11-21 16:30 spec/plan 立项提交 b9214b68（grill-me 三轮复验后决策：IMTO 加 ohos 平台、自助建号、1.16.0 冠名）
- 2026-11-21 17:00 T0 完成，提交见本次 commit。结论：31 API 中 30 runnable / 1 skip（ChatClient.fetchLoggedInDevices 已物理删除）；10 场景 runnable、2 个 device-sync 场景平台永久 skip；modifyMessage 可用（仅 Text/Custom 体）。产出 docs/testing/ohos-multi-api-matrix.md
- 2026-11-22 00:10 T1 进行中（跨 0 点续作）。4.x 侧纯加法已提交 6a3ca669 并走 4 线到 main（merge c1ab199a，含 flutter2_stable 镜像）。T1 实测修正写入 spec 3.1：session.dart 被 16+ 文件使用、ci_test.dart 承载 ohos 专属助手，env/session/login/ci_test 全部保留，仅删 rest.dart；调用点适配为 8 文件（非 9 处机械改名），构造沿用 env.dart 而非 dart-defines 工厂。4.x worktree 存量问题记录：example `make config`（env_tool ensure）因缺 templates/config.local.example.json 在 HEAD 即失败，与本次无关
- 2026-11-22 00:10 子代理执行机制首次启用：机械适配任务委派 deepseek/flash（模型别名 deepseek/flash，config.toml 已配，/reload 后生效），主代理复核 diff 与 analyze；若 flash 产出严重质量问题则推翻用 k3 重做
- 2026-11-22 00:18 T1 代码落地（子代理 deepseek/flash 执行、主代理全量复核）：8 调用点文件适配 + rest.dart 删除，两线 diff 为空验收通过，dart analyze 0 issue。适配要点：联系人关系走 setContacts（双侧幂等+轮询校验，替代 add/removeContact），模块导入用 `show CiRestFixture` 规避与 ci_test.dart 的 waitForCi 同名冲突；createGroup 补 isPublic:true、createChatRoom 补 description。子代理机制首次实战成功
- 2026-11-22 00:18 T2 完成：script_values/step_dependencies/step_expectation 三字节级拷贝，auto_mode.dart 合并（4.x 依赖跳过+expect 校验+blocked 计数+startCallback 接入；ohos 内联 JSON/兄弟 config/密码登录链全保留），diff 复核与 4.x 差异仅剩 ohos 保留项
- 2026-11-22 00:18 T3 完成：lib/agent/ 五文件字节级拷贝（仅 dart:io/flutter/im_flutter_sdk 依赖，鸿蒙可编译），main.dart 三模式接线（保留 file_picker ohos 守卫）；loopback 控制端运行时待设备实跑
- 2026-11-22 00:18 T1d 实测补充：4.x 规范层 fixture 自带 close() 与顶层 waitForCi（30s/200ms），ohos 保留 ci_test.dart 的 waitForCi（20s/500ms）为生效版本
- 2026-11-22 00:35 T4a 完成提交 ed57b060：12 场景 1.16.0-multi-* 落地（JSON 字节级不变），README Platform skip 节、scripts/multi.sh、testing/target-flutter.yaml（platform: ohos + flutterBin）
- 2026-11-22 00:55 T5 静态完成提交 894b99c2：script_1.16.0 正（16 步）/逆（6 步）脚本（API 名 16/16 经 ohos registry 核对）+ auto_report ohos 分支（自测与伪 hdc/flutter 端到端夹具全过）；实跑待设备（验收未闭环，不降级）。已知：ohos registry 仅 21 项，client/contact/thread 未注册
- 2026-11-22 00:55 T4b 进行中（k3 子代理）：IMTO ohos 平台支持（hdc 发现/装包/启动/hilog + FLUTTER_BIN 构建 + fport），dart test 全绿为目标
- 2026-11-22 01:40 T4b 完成：IMTO 提交 1e69503 并 push origin（230/230 测试通过，214 基线 + 16 新增；artifact 流 build hap + hdc install/aa start 与 apk 路同构；fport/bm dump/aa start 输出语义等按 fork flutter_tools 源码实现，标注待设备确认）；ohos 仓 testing/target-flutter.yaml 经 TargetConfig 解析验证。实跑待双鸿蒙设备（验收未闭环，不降级）
- 2026-11-22 01:40 T6 偏差记录：nightly_local.harmony.sh 不接 single/multi（遵循 4.x 惯例：single 走 `make auto-report` 独立入口，multi 走 scripts/multi.sh），AGENTS.md 与 testing/README.md 已如实描述；hap 编译验证通过（T1-T3 鸿蒙工具链编译确认）

## 验证记录

- T0：三层源码核查（Dart 公开 API → ArkTS Wrapper → gap 台账），辅以 ohos 自有集成用例实证；未做设备实跑，结论以源码与台账为准
