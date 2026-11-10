# CI 入口归类与验证记录

日期：2026-11-10。状态：五类常规入口已整理；已有会话专项配置的最终归属待用户确认。

## 范围与保留情况

仅重划已有用例归属、显式初始化、必要注册/调度引用，并同步操作文档和工作区测试 skill。SDK 业务代码、单/多设备平版场景未修改。按 HEAD 与工作区源码核对，55 个用例 ID 完整保留、没有新增；全部配置执行项仍为 56。

| 稳定入口 | 显式 dataSyncType | 用例数 |
|---|---|---:|
| logged_out_test.dart | conversations | 17 |
| logged_in_base_test.dart | conversations | 25 |
| logged_in_group_test.dart | conversations + joinedGroups | 5 |
| logged_in_contact_test.dart | conversations + contacts | 5 |
| logged_in_user_info_test.dart | conversations；enableUserInfo=true | 1 |

五个常规入口均显式 autoLoadConversations=true、enableChatroomConversation=false；只有用户资料入口 enableUserInfo=true。业务主体放 modules，入口负责初始化及注册。FL-AUTH-007 保留冷启动登录同步和退出断言；其他基础用例在独立 group 前置中登录，不依赖它先执行。共享登录辅助函数按入口的显式同步 mask 等待完成，保留超时、错误传播与连接状态核验。

## 待确认：原有特殊配置三项

FL-CONV-011/012 明确要求 autoLoadConversations=false；FL-CONV-013 另有 enableChatroomConversation=true 的执行项。不能删除前置断言，也不能运行中重新初始化。

已向用户提出：在基础入口下保留常规/会话专项两种固定配置，nightly 分两次冷启动；备选是明确保留第六个专项入口。尚未收到决定，不实施任一最终方案。原有 conversation_config_test.dart 暂时完整保留，nightly 在四个稳定登录入口后继续保留该旧批次，以免丢失已有用例；这不是已批准第六个稳定入口。该专项本轮未执行。

## 实际验证

执行对象：5.1.0 worktree，提交 3e8333ed 加本次未提交改动；Flutter 3.47.0，iOS 模拟器。Native 实际解析版本本轮未独立核验，不由分支名推断。

[正式 CI 汇总报告](../../artifacts/ci/20261110-112501-entry-reclassification/summary.md)显式合并下列五个本轮运行，50/50 通过。合并不是重新执行；每批原始执行时间、初始化快照、事件与日志见报告链接。本轮未运行 Android，未宣称双端通过。

| 入口 | 实际执行 | 原始运行 |
|---|---|---|
| 未登录 | 16/16 通过 | 20261110-112318-ios-swj71__9 |
| 基础登录 | 23/23 通过 | 20261110-112042-ios-wtad7o1x |
| 群组 | 5/5 通过 | 20261110-111659-ios-0f17dhqi |
| 联系人 | 5/5 通过 | 20261110-111845-ios-qt4kqo4g |
| 用户资料 | 1/1 通过 | 20261110-112147-ios-vis6kelz |

单项补验不增加覆盖用例数：[FL-AUTH-007 独立执行](../../artifacts/ci/20261110-112430-ios-__ygcqn8/summary.md) 1/1 通过，验证只选冷登录用例时收尾不会重复登出。该检查发生在基础入口收尾增加“仍登录时才调用 logout”的保护之后；保留退出身份和断连断言。

[FL-MSG-008 独立执行](../../artifacts/ci/20261110-112525-ios-t2f27cq1/summary.md) 1/1 通过，确认不执行 FL-AUTH-007 时，基础用例也能独立登录和清理。这两次补验不并入汇总，以免同入口单项运行替代完整选测批次的统计。

静态检查：integration_test 全目录 Dart analyze、迁移文件格式、case mapping、shell 语法、文档本地链接和 diff 空白检查通过。已有 CI runner/report Python 测试 14/14；首次在沙盒内因 Bash /dev/fd 进程替换受限失败，允许正常执行环境后通过，未修改脚本规避环境问题。这不是 SDK 用例失败。本次未运行完整 quality 或 SDK 全部单元测试。

## 未执行项与边界

- FL-MSG-006、FL-MSG-007、FL-CONV-006：沿用用户已有跳过决定，本轮通过选测列表排除，源码及正确断言保留；未将历史失败改为通过。
- FL-CONV-011/012/013(true)：特殊配置归属待确认，本轮未执行。
- 上述 6 个执行项属于计划/决策记录，未混入正式报告的实际执行统计。
- 未启动完整 nightly 设备运行，分别调用现有 runner 验证；nightly 新目标列表、失败后继续和报告汇总由现有 runner 工具测试验证。

操作说明见 [CI README](../../tool/ci/README.md)，长期分类规则见 [CI 设计规则](2026-11-09-ci.md)。后续普通补用例只改现有模块注册函数，任何稳定入口修改（包括 import/注册接线）都须先确认。
