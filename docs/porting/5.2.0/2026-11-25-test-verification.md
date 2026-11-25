# 5.2.0 升级测试验证

- 日期：2026-11-25
- 覆盖表：[2026-11-25-test-coverage.md](2026-11-25-test-coverage.md)
- 目标：`im_flutter_sdk/.worktree/5.2.0`，分支 `5.2.0`，基线 `d503710a`（平版提交）；本轮未提交变更仅为测试用例与文档（见下「本轮范围」）。
- 工具链：Flutter/Dart `/Users/asterisk/fvm/versions/custom_official/bin`（3.47.0 线；PATH 默认的 ohos fork 不能用于本仓库）。
- SDK：四包 5.2.0；native 解析版本 5.2.0 平版阶段已实证（Android gradle hyphenate-chat 5.2.1、iOS SPM/CocoaPods HyphenateChat 5.2.0），本轮无 native 依赖变化。
- 环境：macOS；`emulator-5554` 在线；`im_flutter_sdk/example/config.local.json` 为 `make config` 占位（appKey `TODO(org…)`、账号 `TODO-user1/2`、token 空、clientId/Secret 占位）——所有需登录/对端的设备场景**阻塞于真实凭据**。
- 本轮范围（用户指定）：CI 补「多 body 文本」「多 body 附件（文件体，非图片）」2 用例；单设备补同 2 用例（正向脚本）；多设备补「发送多 body、接收多 body」1 场景（用户本轮已确认，无须二次确认）。连接状态用户明确本轮不补。未建 `script_520_apis_negative.json`（无明确逆向契约，不猜错误码）。
- 更新时间与阶段：2026-11-25 完成用例实施与全部可离线验证；设备场景阻塞待凭据。未完成，不得写全部完成。

## 正式运行报告索引

| 报告类别 | 实际执行时间 / run ID | 本轮操作 | 平台/设备、初始化批次及选择范围 | 正式报告与原始证据 | 代码与依赖证据 |
|---|---|---|---|---|---|
| CI 单元/契约/质量 | 2026-11-25 16:25（artifacts/ci/20261125162547） | 实际执行 | 仓库根 `FORMAT_BASE_SHA=HEAD bash tool/ci/run_quality.sh` | `artifacts/ci/20261125162547/unit/test-quality/summary.md`（Git 忽略） | 工作区 = `d503710a` + 本轮未提交用例改动 |
| 单设备自检 | 2026-11-25 | 实际执行 | `dart run testing/single/auto_report.dart --self-test` | 终端输出 `self-test passed`（自检不落盘业务报告） | 同上 |
| CI 设备 | — | 未执行 | 计划：FL-MSG-016 首测 Android、FL-MSG-017 首测 iOS（`logged_in_base_test` 批次），需 `E2E_*` 凭据或有效 `E2E_CONFIG_PATH` | 无 | — |
| 版本升级：单设备 | — | 未执行 | 计划：`make auto-report PLATFORM=android SCRIPT=testing/single/cases/script_520_apis_positive.json`，需真实 `config.local.json` | 无 | — |
| 版本升级：多设备 | — | 未执行 | 计划：`5.2.0-multi-message-multibody-positive`（Android alice → iOS bob），需真实凭据 + im-test-orchestrator 账号生成 | 无 | — |

## 选测清单与执行统计

| 类别 | 平台/组合与初始化批次 | 单位 | 本次选测总数 | 通过 | 失败 | 跳过 | 未完成 | 未执行 | 来源报告 |
|---|---|---|---|---|---|---|---|---|---|
| CI 单元/契约/质量 | 纯 Dart + 全仓静态检查 | 测试/检查项 | 76 单测 + mapping/契约/版本检查 | 76 | 0 | 0 | 0 | 0 | artifacts/ci/20261125162547/unit/test-quality/summary.md |
| 单设备工具自检 | 纯 Dart | 自检 | 1 | 1 | 0 | 0 | 0 | 0 | 终端 `self-test passed` |
| CI 设备 | Android（FL-MSG-016）、iOS（FL-MSG-017） | 用例 | 2 | 0 | 0 | 0 | 0 | 2 | 凭据阻塞 |
| 单设备 | Android（script_520 正向 2 步） | 场景 | 1（2 步） | 0 | 0 | 0 | 0 | 1 | 凭据阻塞 |
| 多设备 | Android+iOS（multibody 1 场景） | 场景 | 1 | 0 | 0 | 0 | 0 | 1 | 凭据阻塞 |

工具检查单列：`run_quality.sh`（format/analyze/单测/mapping/契约/版本）通过；`auto_report --self-test` 通过；本轮新增 JSON 均过 `jq` 解析；`native-case-mapping.json` 新增 FL-MSG-016/017 两条经 run_quality 的 mapping 校验；多设备新 YAML 经 flow_runner `parseFlow`（含 cmd-id 与配对 JSON 静态校验）通过，仅因无 agent endpoint 止步于连接阶段，符合预期。flow_runner 与多设备编排工具代码本轮未改动，不运行其单测。

计划与处理决定（不与执行结果相加）：

| 计划项/关联问题 | 平台/配置 | 计划状态或后续决定 | 原因与决定来源 | 已有执行结果/报告 |
|---|---|---|---|---|
| FL-MSG-016 | Android / logged_in_base 批次 | 未执行（阻塞） | `config.local.json` 为占位、无 E2E 凭据 | 尚未执行 |
| FL-MSG-017 | iOS / logged_in_base 批次 | 未执行（阻塞） | 同上 | 尚未执行 |
| script_520_apis_positive | Android / dataSyncType=6 显式配置 | 未执行（阻塞） | 同上 | 尚未执行 |
| 5.2.0-multi-message-multibody-positive | Android alice → iOS bob | 未执行（阻塞） | 同上 + 编排工具账号生成需真实 appKey/secret | 尚未执行 |
| script_520 逆向脚本 | — | 不建 | 无明确逆向契约，不猜测错误码（覆盖表记录） | — |

- 单/多设备脚本步骤统计：0 实际执行（阻塞），不估计通过。
- 运行次数及复验：无设备运行；离线检查各 1 次通过。
- 未选平台/组合：FL-MSG-016 iOS、FL-MSG-017 Android、script_520 iOS、multibody 同端组合——按交叉选端原则未选，不计通过；触发补测条件为已选端失败需跨端对照或用户要求。
- 多设备未确认候选：无（唯一候选已由用户本轮明确指定）。

## 执行结果

| 行为/用例 | 平台/设备与初始化配置 | cwd 与实际命令/入口 | 状态 | 核心断言预期与实际 | run ID/报告及日志路径 | 清理结果 |
|---|---|---|---|---|---|---|
| 离线质量检查 | 纯 Dart | worktree 根；`FORMAT_BASE_SHA=HEAD bash tool/ci/run_quality.sh` | 通过 | analyze（含新 integration_test 代码）/format/76 单测/mapping/契约/版本全绿；mapping 校验含新增 FL-MSG-016/017 | artifacts/ci/20261125162547/unit/test-quality/summary.md | 不适用 |
| FL-MSG-016 | Android（计划） | — | 未执行 | 预期：双文本体发送最终回调 SUCCESS，bodies 有序、contentType==MULTIBODY、本地回读一致 | — | — |
| FL-MSG-017 | iOS（计划） | — | 未执行 | 预期：文本+文件体发送 SUCCESS，文件体 remotePath/secret/fileSize 保持 | — | — |
| send_multi_body_text / send_multi_body_attachment | Android（计划） | — | 未执行 | 预期：脚本 checks 见 script_520 JSON（bodies 长度/顺序/remotePath） | — | — |
| multibody 收发 | Android alice → iOS bob（计划） | — | 未执行 | 预期：bob onMessagesReceived 匹配 msgId 且 bodies.0/1 内容与顺序正确 | — | — |

## 失败、三次上限与最终确认

本轮无设备执行，无失败计数；同一问题三次上限未触发。阻塞项（凭据缺失）为前置环境阻塞，不计入任何用例的失败或跳过计数。

| 问题 ID / 关联用例及平台 | 失败阶段与预期/实际 | 未通过次数 | 原因与确定程度 | 影响与处理决定 | 待用户确认 |
|---|---|---|---|---|---|
| ENV-520-01：凭据缺失 | 准备阶段：config.local.json 占位、无 E2E 凭据 | 0（未尝试） | 环境，已确认（jq 核验 appKey/账号/clientId 均为 TODO 占位） | CI 设备 2 例、单设备 1 场景、多设备 1 场景全部未执行；恢复需提供真实凭据后按选测清单执行 | 需用户提供凭据并授权执行 |

## 复验与结论

- 操作说明核对：tool/ci/README.md、testing/single/README.md、testing/multi/README.md 入口与本轮用例落点一致；新增 `script_520_apis_positive.json` 沿用既有 `make auto-report SCRIPT=` 入口，无需文档变更。多设备新场景的 RN 仓同名副本同步（byte-identical 对账）不在本仓范围，按多设备 README 由维护者执行 `scripts/multi.sh cases diff`。
- 复验：无设备运行可复验；离线检查如重跑，命令同上。
- 多设备稳定性：未执行，无证据，不宣称稳定。
- 未验证的平台/行为及原因：FL-MSG-016/017、script_520 两步、multibody 场景——凭据阻塞；连接状态、disconnectNotifyThreshold、body setter 语义——用户本轮范围外/决定不补（见覆盖表暂缓行）。
- 暂停/已知失败：无新增；5.1.0 遗留的 FL-CONV-006、FL-MSG-006/007 跳过决定本轮不涉及。
- 达到三次上限的问题：无。
- 本轮结论与下一步：用户指定的 5 项用例（CI 2、单设备 2、多设备 1）已全部实现并完成离线验证；剩余全部为设备执行，阻塞于真实凭据。下一步：用户提供凭据后，按上表选测清单依次执行 CI 设备（Android FL-MSG-016、iOS FL-MSG-017）→ 单设备 Android script_520 → 多设备 multibody（单设备验证后再跑多设备）。
- 提交状态：未提交。变更范围：`im_flutter_sdk/example/integration_test/modules/message_cases.dart`（+prepareUnblockedFriendship、FL-MSG-016/017）、`im_flutter_sdk/docs/ci/native-case-mapping.json`（+2 条）、`testing/single/cases/script_520_apis_positive.json`（新增）、`testing/multi/cases/5.2.0-multi-message-multibody-positive.{yaml,json}`（新增）、`docs/porting/5.2.0/2026-11-25-test-coverage.md` 及本文件。默认不提交，待用户授权。
