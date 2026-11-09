# 5.0.0 送达回执受已读回执开关限制

- 日期：2026-11-07
- 状态：已定位共享源码条件；补充消息开关后 Android 连续三轮、iOS 一轮通过
- 触发仓库：`im_flutter_sdk`，`testing` 分支
- 适用环境：Flutter 3.47.0、Native SDK 5.0.0；双 Android API 35、双 iOS 18.2 模拟器

## 结论

接收端设置 `requireDeliveryAck: true`，消息使用默认 `isNeedReadReceipt: false` 时，本次 Android、iOS 均发送成功且对端收到消息，但发送方没有收到 `onMessagesDelivered`，等待 30 秒超时。

共享 Native 5.0.0 的 `sendMessageAck` 对送达回执也检查 `isNeedReadReceipt`。此版本的送达用例需同时设置接收端 `requireDeliveryAck: true` 和消息 `isNeedReadReceipt: true`。发送成功、对端接收及发送方收到同一消息送达回执仍须全部验证；开启该字段本身不等于测试通过。

## 现象与证据

用例：[5.0.0-multi-message-delivery-positive](../data/5.0.0-multi-message-delivery-positive.yaml)。两次执行使用相同用例及断言，各 11 步中 10 步通过、1 个送达事件等待超时；发送成功和接收事件关联到同一服务器消息 ID，双方退出及 HTTP finish 成功。

| 平台 | runId | 服务器消息 ID | 接收事件 seq |
|---|---|---|---|
| 双 Android | `20261107-230842-message-delivery-7dffd6db` | `1617052789261730204` | B：279 |
| 双 iOS | `20261107-231310-message-delivery-ccfecfcc` | `1617053952820380064` | B：23 |

每轮证据位置：

- `reports/<runId>/summary.md`、`statistics.csv`：用例结论及故障入口。
- `reports/<runId>/5.0.0-multi-message-delivery-positive/1/flow-report.json`：11 步结果、目标消息和等待超时。
- `tmp/<runId>/5.0.0-multi-message-delivery-positive/1/trace.jsonl`：B 的初始化覆盖值 `requireDeliveryAck: true`；该文件包含私有运行输入，分享时只提取所需字段。
- 同目录 `alice-events.jsonl`、`bob-events.jsonl`：原始事件及序号；目标消息 `isNeedReadReceipt` 为 false。

Android 登录后还收到历史消息，目标接收事件仍通过服务器 ID 和本轮正文准确匹配。没有将历史消息、查询结果或发送成功回调当作送达回执。

设置 `isNeedReadReceipt: true` 后，以下轮次均 11/11 步通过、任务故障为 0，接收与送达按同一服务器消息 ID 关联：

| 平台 | runId |
|---|---|
| Android 第 1 轮 | `20261107-232326-message-delivery-b91c7112` |
| Android 第 2 轮 | `20261107-232523-message-delivery-22c820b6` |
| Android 第 3 轮 | `20261107-232710-message-delivery-c1d2f5dc` |
| iOS 第 1 轮 | `20261107-232900-message-delivery-fad6f8ac` |

用户要求停止继续验证；iOS 未追加轮次。原失败证据保留，以上结果不证明长期稳定率。

## 源码阻断条件

依据 `emclient-linux` 的 `SDK_5.0.0`，提交 `2f4d2094c78047e07c41d7fb0e4232e05010d331`：

1. `src/emchatmanager.cpp:1244`：收到非漫游单聊消息且 `getRequireDeliveryAck()` 为 true，调用 `sendMessageAck(emMsg, DELIVERY, false)`。
2. 同文件 `:5490`：`sendMessageAck` 的以下判断没有区分 `READ` 和 `DELIVERY`：

```cpp
if (id.empty() || !msg->isNeedReadReceipt()) {
    EMLog::getInstance().getErrorLogStream() << "message read ack not enabled";
    return false;
}
```

3. 提交 `0bc797856`（`update readReceipts && unread message count`）将原来的非单聊群回执检查改为上述通用检查，单聊送达也因此受限。

公开定义分别见：

- Flutter：`im_flutter_sdk/lib/src/models/chat_message.dart` 的 `isNeedReadReceipt`，仅描述已读回执；`ChatOptions.requireDeliveryAck` 描述收到单聊后自动发送送达回执。
- Android：`SDK_5.0.0`（`8025ecb767e72a5c4623fab457ed269011e773d6`）中 `EMMessage.java` 的 `setIsNeedReadReceipt`，仅描述已读回执。
- iOS：`sdk-5.0`（`7dffc7e8cdc70ea661236159a5972671e588bdcc`）中 `EMChatMessage.h` 的 `isNeedReadReceipt` 及 `EMOptions.h` 的 `enableDeliveryAck`，分别描述已读开关和自动送达回执。

公开注释未完整表达送达路径的字段依赖；本例依据 5.0.0 源码补齐配置，不修改 Native SDK，也不据此认定 SDK 缺陷已修复。

## 处理边界

- 保留用例失败和原始证据，不删除送达断言，不增加延时掩盖条件阻断。
- 消息显式设置 `isNeedReadReceipt: true`，不调用已读回执 API，仍只验证当前送达场景。
- 保持测试目标及核心断言正确的参数、前置调整属于用例探索，可依据证据修正规格，不必逐项请求确认。

## 排查命令备忘

```bash
# 在 testing_v2 内，使用已准备的账号源码及角色选择文件。
dart run bin/cli.dart all --cases tmp/20261107-delivery-input/cases-android.json
dart run bin/cli.dart all --cases tmp/20261107-delivery-input/cases-ios.json

# 在 emclient-linux 内，按实际测试版本读取，避免使用当前工作分支源码。
git show SDK_5.0.0:src/emchatmanager.cpp | sed -n '1244,1251p;5478,5500p'
git show 0bc797856 -- src/emchatmanager.cpp
```
