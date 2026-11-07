# CI 联系人用例的数据同步与历史消息隔离

- 日期：2026-11-07
- 状态：同步前提已修正并验证；历史消息隔离方案待确认。
- 触发仓库：`im_flutter_sdk`，`testing` 分支。
- 适用环境：Flutter 3.47.0、SDK 5.0.0、Android 模拟器与 iOS Simulator。

## 结论

冷安装只清理本地数据，不保证登录后的数据库为空。联系人查询需明确同步配置和完成时机；复用同一个账号作为消息收件人及联系人删除对象，可能让旧测试消息进入后续轮次。

## 现象与根因

| 现象 | 已确认事实 | 处理 |
|---|---|---|
| REST 好友关系已修改，本地列表仍是旧值 | `getAllContactIds/getAllContacts` 读取本地；`dataSyncType` 明确保证登录后同步，不能凭 REST 成功推断当前本地缓存已更新 | REST 双向核验后重新登录，收到联系人同步成功事件，再验证本地查询 |
| 双端相同初始化代码，数据前提不同 | `dataSyncType=null` 保留 native 默认；iOS 默认为 conversations，Android 默认为 none | 测试显式设置 `contacts | joinedGroups`，登录前注册监听，等待两类同步完成及连接成功 |
| 冷安装后发现 peer 历史消息 | iOS 实际读到了此前 `FL-MSG-001` 的发送消息；显式关闭 conversations 同步仍不足以保证后续重新登录无旧消息 | 保留已有消息保护，不清除未知历史。临时 peer 或独立删除测试账号待确认；不能把本地为空当成冷安装的必然结果 |
| 退出后重新登录，业务回调没有继续交付 | 两端 logout 清空 listener 门闩 | 每次登录后执行 `startCallback()` |

初始化配置的依据：[5.0.0 同步契约](../../porting/5.0.0/02-contract.md)、[ChatOptions](../../../im_flutter_sdk/lib/src/models/chat_options.dart)。

## 验证边界

重新登录只用于 **REST 准备与恢复**。被测 `deleteContact` 返回后，关系、列表、会话断言必须在同一登录会话执行；不得用重新登录掩盖 SDK 操作失败。

iOS `keepConversation` 到 native `isDeleteConversation` 的映射仍有静态疑点。历史数据保护阻止了最新轮次的删除操作，不能将这两项准备失败写成该疑点已实测确认。

最新复验 `20261107-1950` 中，iOS 两例仍在准备阶段停止；Android 首轮另有恢复关系后联系人同步返回 300 的收尾失败，复验通过但根因未确认。用户确认相关删除行为为 SDK 5.0 已知问题、预计 5.1 修复，决定保留用例与失败记录，后续再处理；该信息不改变本轮实际失败阶段的分类。

## 排查命令

日志位于工作树 `artifacts/`，不纳入 Git：

```bash
rg -n 'data sync|contacts observe|existing peer conversation|after SDK delete|cleanup' \
  artifacts/ci-basic-ios-positive-20261107-1950.log
```

应先核对：同步配置、同步完成事件、REST 双向状态、SDK 本地状态、消息 ID／时间／用例标识、实际执行到的阶段。完整结果见 [正向用例验证记录](../ci-basic-api-tests/2026-11-07-positive-verification.md)。
