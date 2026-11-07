# 发送错误回调中的消息仍为 PROGRESS

- 日期：2026-11-07
- 状态：Android、iOS 均已复现；保留失败断言，SDK 修复及断言范围待人工确认
- 触发仓库：`im_flutter_sdk`，`testing` 分支，SDK 5.0.0
- 适用环境：Android 模拟器、iOS 18.2 模拟器；Flutter 设备集成测试

## 结论

`sendMessage` 的方法返回、最终错误回调和回调消息的 `status` 是不同的观察点。本次在“未登录”和“已登录但收件人为空”两种场景收到准确错误回调，回调消息却仍为 `PROGRESS`。不能据此认为消息仍在发送，也不能把收到错误回调视为状态字段已正确更新。

## 现象与证据

| 用例 | 前置条件 | 错误码 | 回调消息状态 |
|---|---|---|---|
| FL-MSG-006 | 冷安装、初始化、未登录 | 双端 201 | 双端 PROGRESS，预期 FAIL |
| FL-MSG-007 | 正常登录、空收件人 | 双端 500 | 双端 PROGRESS，预期 FAIL |

监听在发送前注册，并用本次发送前消息 ID 关联回调。最终回调错误码断言已通过，随后状态断言失败。重复执行结果见[逆向验证记录](../ci-basic-api-tests/2026-11-07-negative-verification.md)。

## 根因定位与边界

1. Dart `ChatManager.sendMessage` 在调用 native 前将发送对象设为 `PROGRESS`。
2. 两端 Flutter `ChatManagerWrapper` 将原生错误回调的消息序列化后发送到消息通道，没有将状态改成 `FAIL`。
3. Dart `MessageCallBackManager` 对回调数据重新构造 `ChatMessage`。本次断言读取的是这个独立回调对象，不是可能被方法返回覆盖的原发送对象，因此不是测试引用同一可变对象导致的竞态。
4. `emclient-linux` 的 `SDK_5.0.0` 源码 `src/emchatmanager.cpp:2031` 中，未登录和空收件人校验直接调用 `callbackError`；`callbackError`（同文件 5868 行）负责分发错误，没有设置消息状态。该路径能解释观测结果，但不能据此声称两端实际二进制的 core 提交完全相同。

错误码稳定且分别对应主动构造的前置条件，不是网络波动或 Token 意外失效。状态行为属于 SDK 调用链问题候选；最终契约及修复归属由人工确认。

## 处理

本次只新增用例和取证日志，保留 `status == FAIL` 断言，未改 SDK，也未将 `PROGRESS` 加入可接受结果。若确认发送前拒绝也应进入失败终态，应修正对应 SDK 路径；若业务决定基础 CI 只验错误回调，需明确调整验证范围，不能将范围变化记为状态问题已修复。

## 排查命令备忘

在工作树根目录执行：

```bash
rg 'negative send callback|Expected: MessageStatus|Actual: MessageStatus' artifacts/ci-negative-*-20261107.log
rg -n 'message.status = MessageStatus.PROGRESS|onMessageError' im_flutter_sdk/lib/src/managers/chat_manager.dart
```

先查看错误码与本次消息 ID 是否匹配，再比较回调消息和原发送对象。不要通过增加睡眠或放宽错误码来处理状态不一致。
