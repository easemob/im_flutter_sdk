# CI 联系人：删除成功与本地同步的验证边界

- 日期：2026-11-07
- 状态：基础 CI 用例范围已确认并调整；本地更新延迟的最终根因未闭环。
- 触发仓库：`im_flutter_sdk`，`testing` 分支。
- 适用环境：Flutter 3.47.0、SDK 5.0.0、Android 模拟器与 iOS Simulator。

## 结论

`deleteContact` 的成功返回与本地联系人同步是不同的完成时机。基础 CI 的 `FL-CONTACT-002/003` 只判断删除 API 成功返回；分别传入 `keepConversation: true/false`，不追加 REST 删除结果、本地列表、监听通知或会话断言，不准备会话和消息。好友关系准备和原状态恢复仍使用 REST。

旧断言同时验证了多个链路，导致删除已成功的用例因本地同步超时而失败。范围调整由用户确认，不代表本地同步缺陷已修复；旧失败记录保留。Android 诊断也出现过本地联系人残留，不能以某轮通过概括为 Android 没问题。

## 现象与根因

| 现象 | 已确认事实 |
|---|---|
| 删除成功，本地联系人 30 秒仍存在 | core 的删除调用不直接移除本地联系人；数据库和缓存通过 REMOVE 通知路径更新。Android、iOS 均观察到异常，通知延迟的最终责任未确定 |
| iOS 保留／删除会话行为相反 | Flutter `keepConversation` 与 iOS native `isDeleteConversation` 语义相反；wrapper 漏了取反，用户已修正。此问题与联系人同步独立 |
| 冷安装后仍有 peer 历史消息 | 卸载只清理本地数据；登录后可能获取历史消息。旧删除用例准备会话时被已有消息保护阻止，这不代表删除 API 失败 |
| REST 准备成功，本地查询仍是旧值 | `getAllContactIds/getAllContacts` 读取本地；REST 成功不能证明本地缓存已同步 |
| 双端相同初始化代码，同步前提不同 | `dataSyncType=null` 使用 native 默认；iOS 为 conversations，Android 为 none |
| 退出再登录后业务回调不交付 | 两端 logout 清空 listener 门闩，登录后需重新 `startCallback()` |

源码与设备证据见 [deleteContact 专项排查](../ci-basic-api-tests/2026-11-07-delete-contact-investigation.md)。iOS 原生日志还观察到删除成功后当前会话未处理 REMOVE，重新登录才拉取并处理；不能据此直接认定服务端未发通知或 SDK 收到后丢弃。

## 处理与排查顺序

1. 先区分失败阶段：准备未完成、删除 API 报错、额外断言超时、恢复失败；未执行删除 API 的失败不能归为删除失败。
2. 对删除用例，以 API 成功返回为通过依据；异常和超时仍失败。恢复好友关系和黑名单后核验远端原状态，不在这两例重新登录等待本地同步。
3. 对联系人查询用例，显式配置 `contacts | joinedGroups`；REST 准备与恢复后重新登录，等待同步完成再查本地。这些检查仍属于查询用例。
4. 排查本地同步时，分别记录 API 返回、REMOVE 接收／处理、本地读取时间；参数映射、会话状态和通知链路分开归因。不通过固定等待或重试覆盖原失败。
5. 比较平台时注明轮次、前置数据和实际执行范围，不把一次成功当成稳定性结论。

## 排查命令备忘

从工作树根目录读取已有日志，无需重新执行用例：

```bash
rg -n 'FL-CONTACT-00[23]|contacts observe|after SDK delete|cleanup|TimeoutException' \
  artifacts/ci-basic-ios-positive-20261107-delete-fixed.log
rg -n 'deleteContact|doHandleRosterEvent|REMOVE|SYNC' \
  reports/ci-basic-api/20261107-delete-native-source/native-filtered.log
```

调整后 Android、iOS 各执行一轮完整正向套件，均 22/22 通过。各轮结果见 [验证记录](../ci-basic-api-tests/2026-11-07-positive-verification.md)；原始日志位于被 Git 忽略的 `artifacts/` 和 `reports/`。
