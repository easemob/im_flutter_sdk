# Group 缺失 Case 补齐任务

- [x] 审计现有 SDK API、Group cases、事件桥接、真实设备和 deferred 项。
- [x] 确认 `PublicOpenJoin=style 3`，定位现有 `style=1` 成功链路设计错误。
- [x] 确认邀请确认矩阵可通过 `inviteNeedConfirm` 与 `updateAutoAcceptGroupInvitationSetting` 自动化。
- [x] 确认共享文件当前 `401 Invalid file` 来自宿主机路径不可被 Android 读取。
- [x] 为 bridge 设备本地群共享文件素材准备添加 RED 测试，并确认缺少 helper 时编译失败。
- [x] 实现最小 bridge 路径准备：Flutter `5 passed`、APK 构建成功；analyze 仅两条既有 deprecated info。新 APK 已装 5556，5554 覆盖安装因空间不足失败，按 design 由 5556 执行所有上传、5554 观察事件，双设备链路均已实测通过。
- [x] 补齐邀请自动接受、显式接受、显式拒绝三种组合；接受/自动接受 strict 通过，显式拒绝经重复 ADB 复现为缺少邀请方回调并保留严格失败。
- [x] 修正公开群 `style=3` 加入/退出成功 case，并保留私有群加入错误 case。
- [x] 补齐 Joined Groups 邀请加入、移除、再次加入、主动退出四阶段的本地/服务端一致性 case，并以双端 ADB 冻结完整群对象和事件。
- [x] 补齐 Public Groups `pageSize=1` 的真实 cursor 连续分页 case；ADB 确认第一页返回后创建群、第二页携带真实 cursor 返回先创建群。
- [x] 补齐群主/管理员更新公告组合及双端事件断言。
- [x] 补齐群主/管理员共享文件上传删除组合及双端事件断言；ADB 确认事件名 `{b62:...}`、列表名 `bigPic.jpg`、字符串 fileId 和操作者无同类事件。
- [x] 为每条新增或修改 case 写清前置、步骤、预期和严格断言。
- [x] 抓取每类场景的 A/B ADB 日志并按真实结果收紧断言；按用户最新要求不抓服务端 tracelog。
- [x] 更新 `CASES_RECORD.zh.md`、`CASES_FAILURES.zh.md` 和 `CASES_DEFERRED.zh.md`，仅保留群状态外部触发及 Jira traceId 门禁。
- [x] 逐 case、逐文件运行 strict 回归；受影响 30 条结果为 `29 passed, 1 failed`，唯一失败为已确认拒绝回调缺失。
- [x] 运行完整 `tests/group` 回归：`156 passed, 1 failed, 1 skipped, 1 warning in 242.65s`。
- [x] 对照 18 条 requirements 完成最终审计：可由现有 SDK 触发的七类缺口均有 case 和双端 ADB；群状态仅保留真实外部触发阻塞；台账函数名缺失 0、多余 0。

## 第二阶段：群类型、邀请申请与群主权限矩阵

- [x] 审计四种 `EMGroupStyle`、邀请确认设置、申请/邀请处理 API、群主转让和成员移除现有覆盖。
- [x] 将新增矩阵要求、角色编排、真实 ADB 约束和验证策略同步到 requirements/design。
- [x] 为跨 case 的 option 恢复、服务端群快照和负向事件等待补充必要的最小 helper。
- [x] 补齐 `style=0/1` 群主、普通成员、管理员邀请权限 cases。
- [x] 补齐 `style=2/3` 主动邀请、直接加入、申请加入的有效/无效 API 映射 cases。
- [x] 补齐 `inviteNeedConfirm=false + autoAccept=false` 及邀请 pending/重复/错误 inviter cases。
- [x] 补齐入群申请空原因、重复申请、无 pending、重复/交叉处理和角色权限 cases。
- [x] 补齐公开群重复加入、群满和黑名单边界 cases。
- [x] 补齐群主转让目标角色、非法目标、越权调用和转让后权限迁移 cases。
- [x] 补齐移除当前群主、转让后移除原群主、移除管理员、越权移除、混合批量及 owner leave cases。
- [x] 对每条新 case 运行 pytest collect 和本地静态检查，确认测试名、fixture 和命令映射有效：当前 `224 items`。
- [x] 对每类场景运行双设备 discovery，抓取 A/B ADB 日志并冻结真实响应、事件端和负向事件。
- [x] 运行新增 strict cases、受影响文件和完整 `tests/group` 回归；全量 223 条为 `215 passed, 7 failed, 1 skipped`，后补空原因 case 单独 `1 passed`。按用户指令不重复全量。
- [x] 更新 `CASES_RECORD.zh.md`、`CASES_FAILURES.zh.md`、`CASES_DEFERRED.zh.md`，完成测试函数与台账对账。
- [x] 按用户决定将 7 个已诊断参数场景精确标记为 skip，保留严格 case；定向验证为 `7 skipped`。

## 第三阶段：群消息归档与发送覆盖

- [x] 审计 `tests/chat` 中所有 `chatType=1` 使用点，区分独立群消息 case 与 ChatThread 前置消息。
- [x] 将群消息回执正常/边界 case 从 Chat 模块迁移到 Group 模块。
- [x] 补齐群聊九种公开消息类型的发送响应、发送成功与接收回调矩阵。
- [x] 对照 SDK 发送 API，更新 Chat/Group CASES_RECORD 覆盖矩阵和目录归属说明。
- [x] 运行受影响文件 collect-only、Python 静态检查及定向真实设备验证，不重复完整模块回归。
- [ ] 后续补齐单聊空/不存在 target、群聊空/不存在 groupId、非成员发送，以及九种消息类型各自非法 payload 的异常参数矩阵。

## 最终验证证据

- Flutter：`flutter test` 为 `5 passed`；`flutter build apk --debug` 成功。
- Analyze：仅 `event_bridge_handler.dart:599/605` 两条既有 deprecated info，无 error/warning。
- Speckit：Android/iOS 本地依赖检查全部 PASS。
- 受影响文件：`29 passed, 1 failed`；失败为显式拒绝邀请缺少邀请方回调。
- Group 全量：`156 passed, 1 failed, 1 skipped, 1 warning in 242.65s`。
- 收集/台账：`158 items`、`116` 个测试函数；文档缺失 `0`、多余 `0`。
- ADB：`native-auto-test/out/group_completion_20260723_105434/`。
- 第二阶段新增：29 个测试函数、66 个参数 items；严格结果 `60 passed, 6 failed`。
- 当前 Group 收集：`224 items`；skip 前历史合并结果 `216 passed, 7 failed, 1 skipped`；
  7 个问题参数定向验证为 `7 skipped`，未按用户要求重复全量。
- 第二阶段 ADB：`native-auto-test/out/group_matrix_20260723/`；仅采集真实 ADB，不采集 tracelog。
- 第三阶段收集：Group `235 items`；新增文件 `11 items` 均已分批 strict 通过，未重复完整模块回归。
