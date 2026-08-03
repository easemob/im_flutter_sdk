# Android 4.23 API 与 Wrapper 路由核对

## 结论

- Android 4.23 测试协议当前声明 **258** 个 `manager.cmd`；这**不是**官网原生 Java API 的总数。
- 从官网 4.23 各核心对象详情页抽取，10 个核心对象已有 **431 个方法重载 / 390 个不同方法名**。官网还包含 Listener、Options、Message、Model 等类，完整原生 API 只会更多。
- 这 258 个 `cmd` 中 **257** 个能在 Android Wrapper 的 `onMethodCall` 分发中找到；**1 个例外：`ConversationManager.insertMessage`**——Matrix/Manifest 声明了它，但 `im_flutter_sdk_android` 的 `MethodKey.java` 与全部 `*Wrapper.java` 都没有 `insertMessage`，该命令会落到 Wrapper 的 fallback（`notImplemented` 或空响应）。不是归属问题，是 Wrapper 未实现；要么 Wrapper 补，要么从 Matrix/Manifest 移除。
- 其中 **7** 条 `manager` 归属与实际 Wrapper 的 MethodChannel 不一致。它们不是原生 API 缺失，但若按照 Matrix 的 `manager` 调用，会被送到错误 channel，最终可能得到 `notImplemented` 或错误的响应。
- 因而当前“API 个数”的测试基准应是 `android.yaml` 的 **258 条测试协议 API**；不要把它与官网 Java API 的方法总数混为一个数字。

## 基线与来源

| 项目 | 位置 / 来源 | 含义 |
| --- | --- | --- |
| 原生能力基线 | [官方 Android Java API 4.23.0](https://doc.easemob.com/apidoc/android/chat3.0/annotated.html) | 官网页面标题标注 `hyphenate_SDK4.0 4.23.0`。这里列出的是原生 Java 类和方法；需查看每个类的详情页，不能只用全站索引页计数。 |
| 测试协议清单 | `native-auto-test/config/api_matrix/android.yaml` | Python 用例可调用的 `manager.cmd`，共 258 条。 |
| Runner capability 镜像 | `native-auto-test/config/artifact_manifests/android-4.23.0.json` | 同样为 258 条；4.23 Runner 未上报 capability 时，框架回退读取这里和 Matrix。它不是 APK 自动扫描产物。 |
| 实际 Android 路由 | `im_flutter_sdk_android/android/src/main/java/com/easemob/im_flutter_sdk/*Wrapper.java` | `MethodKey.xxx.equals(call.method)` 决定某个 cmd 由哪个原生 MethodChannel 接收。 |
| 请求入口 | `im_flutter_test/lib/bridge/interface_router.dart` | 根据 `manager` 选择对应的 Interface channel。 |

官网 Java 文档用于判断“原生是否有能力”；Matrix/Wrapper 用于判断“自动化测试现在能否以某个 `manager.cmd` 调到该能力”。二者名字和粒度并不一一对应，例如一个协议命令可能封装原生对象方法，也可能只是改变了参数或异步回调形式。因此不能直接用官网方法名与 `cmd` 名做字符串差集。

## 官网 4.23 详情页规模（实际抽取）

以下统计来自官网各类详情页的 Member Function 表：左列为包含重载的方法条目数，右列为去重后的方法名数。它说明原生 API 基线远大于 Matrix 的 258 条协议命令。

| 官网原生类 | 方法重载 | 不同方法名 |
| --- | ---: | ---: |
| `EMClient` | 49 | 47 |
| `EMChatManager` | 84 | 68 |
| `EMGroupManager` | 110 | 101 |
| `EMChatRoomManager` | 65 | 62 |
| `EMContactManager` | 30 | 28 |
| `EMConversation` | 41 | 33 |
| `EMPushManager` | 19 | 19 |
| `EMChatThreadManager` | 14 | 13 |
| `EMUserInfoManager` | 11 | 11 |
| `EMPresenceManager` | 8 | 8 |
| **小计** | **431** | **390** |

这些数字不等于“应当补 390 条命令”。Wrapper 只需要暴露测试要覆盖且能够跨端稳定表达的能力；一个 `cmd` 可对应官网的异步变体、同步变体或对象方法，反之部分原生配置/Listener/模型方法不应成为独立测试命令。

## 从 jar 反编译实测的完整规模（2026-08-03）

官网详情页只抽了 10 个核心对象；本节用本地 jar 反编译给出**完整公开 API 规模**。

来源：gradle 缓存 `~/.gradle/caches/transforms-3/<hash>/transformed/jetified-hyphenatechat_4.23.0.jar`（615 个 class）。用 `javap -p` 反编译每个 class，统计**公开类**（`public class/interface` 声明）的 **public/protected 方法**，去掉构造器、bridge、synthetic 与 `internal` 包。

| 口径 | 类数 | 方法数(含重载) | 方法名去重 |
| --- | ---: | ---: | ---: |
| 正式 API（排除 `adapter`/`core` 混淆层） | **134** | **1496** | **1124** |
| 纯业务调用（再排除 Listener/Callback 接口） | 119 | 1393 | 1048 |
| 全量（含内部 `adapter.EMA*`/`core.a` 混淆层） | 224 | 2790 | 1670 |

方法最多的类：`EMGroupManager` 114、`EMMessage` 99、`EMOptions` 88、`EMChatManager` 84、`EMChatRoomManager` 65、`EMClient` 54、`EMConversation` 39、`EMContactManager` 30。

这个规模是**原生 Java API 面的总规模**，包含实体 getter/setter 与重载；Wrapper 只把其中可命令化的业务操作暴露为 **257 个 cmd**。所以“原生 1496 ≫ Wrapper 257”是设计使然（一个 `cmd` 可对应原生对象方法/异步变体），不是缺失。

可复算命令（macOS，用 Android Studio 自带 JBR）：
```bash
unzip -o -q ~/.gradle/caches/transforms-3/<hash>/transformed/jetified-hyphenatechat_4.23.0.jar -d /tmp/sdk23
JAVAP="/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/javap"
$JAVAP -p /tmp/sdk23/com/hyphenate/chat/EMClient.class   # 示例：单类反编译
```

本文件的 258 条逐项结论是 **Matrix → Wrapper 的路由核对**，不是声称已完成 `390` 个官网方法到 `258` 个 cmd 的逐项语义映射。官网逐项映射需要为每条 Wrapper 的实际原生调用记录：官网类、方法、重载签名、参数转换和回调转换；这是下一阶段应维护的映射表。

## 静态核对方法

1. 读取 `android.yaml` 中的 258 个 `manager.cmd`。
2. 读取 `MethodKey.java`：将 Java 常量名还原为真正发到 channel 的命令字符串。
3. 扫描全部 `*Wrapper.java` 的 `MethodKey.<key>.equals(call.method)` 分发。
4. 将命令所在 Wrapper 映射为实际 Manager：

| Wrapper | 实际 channel / Manager |
| --- | --- |
| `ClientWrapper` | `Client` |
| `ChatManagerWrapper` | `ChatManager` |
| `ContactManagerWrapper` | `ContactManager` |
| `GroupManagerWrapper` | `GroupManager` |
| `ChatRoomManagerWrapper` | `ChatRoomManager` |
| `PushManagerWrapper` | `PushManager` |
| `UserInfoManagerWrapper` | `UserInfoManager` |
| `PresenceManagerWrapper` | `PresenceManager` |
| `ChatThreadManagerWrapper` | `ChatThreadManager` |
| `ConversationWrapper` | `ConversationManager` |
| `MessageWrapper` | `MessageManager` |

结果：257/258 cmd 有 Wrapper 分发（`ConversationManager.insertMessage` 例外，见结论）；258 条 manager 已全部与实际 Wrapper 的 channel 一致（原 7 条归属差异已修正，见下表）。

## 已修正的 7 条 Matrix 归属

| 当前 Matrix 声明 | 实际 Wrapper | 应使用的 manager | 说明 |
| --- | --- | --- | --- |
| `Client.bindDeviceToken` | `PushManagerWrapper` | `PushManager` | 原生调用为 push manager 的设备 token 绑定。现有 push 用例也是按 `PushManager` 调用。 |
| `ChatManager.conversationRemindType` | `ConversationWrapper` | `ConversationManager` | 会话免打扰设置。 |
| `ChatManager.conversationSearchMsgsByOptions` | `ConversationWrapper` | `ConversationManager` | 会话内按条件搜索消息。 |
| `ChatManager.conversationGetLocalMessageCount` | `ConversationWrapper` | `ConversationManager` | 会话本地消息计数。 |
| `ChatManager.conversationDeleteServerMessageWithIds` | `ConversationWrapper` | `ConversationManager` | 按消息 ID 删除会话本地/服务端消息。 |
| `ChatManager.conversationDeleteServerMessageWithTime` | `ConversationWrapper` | `ConversationManager` | 按时间删除会话本地/服务端消息。 |
| `ConversationManager.getPinInfo` | `MessageWrapper` | `MessageManager` | 消息置顶信息查询。 |

这 7 条已同时改两处，保持同一协议事实：

1. `native-auto-test/config/api_matrix/android.yaml`：把旧的 `manager.cmd` 改为上表的正确归属。
2. `native-auto-test/config/artifact_manifests/android-4.23.0.json`：同步调整 `capabilities` 中的同一条字符串。

如果已有用例把这些命令发到旧 manager，也要改用例中的 `device.call(manager, cmd, ...)` 和 response 断言中的 `manager`。本仓库现有相关会话和 push 用例已经按正确 manager 调用，因此本次未改 case。

## 后续维护规则

新增或升级 API 时按下面顺序确认：

1. 在官网 4.23（或目标版本）Java API 中确认原生方法/回调存在。
2. 确认对应 Wrapper 有 `MethodKey` 和 `onMethodCall` 分发，并实际调用该原生方法。
3. 用 `interface_router.dart` 的 manager 选择正确 channel；**manager 以 Wrapper 所在 channel 为准，不以命令名称猜测。**
4. 再添加 `android.yaml` 和 manifest 的同一条 `manager.cmd`，二者集合必须一致。
5. 最后新增跨 Android/iOS 可运行的 case；Response 断言请求结果，Event 断言异步回调，不把二者混在同一断言里。

## 可复查的静态检查口径

以下检查只验证“协议声明是否存在 Wrapper 分发，以及 manager 是否选对 channel”；它不替代真机 API 回归，也不证明参数语义完全正确。

```bash
native-auto-test/.venv/bin/python -c '
import re, yaml
from pathlib import Path

root = Path("im_flutter_sdk_android/android/src/main/java/com/easemob/im_flutter_sdk")
apis = yaml.safe_load(Path("native-auto-test/config/api_matrix/android.yaml").read_text())["base"]["apis"]
keys = dict(re.findall(r"String\\s+(\\w+)\\s*=\\s*\\\"([^\\\"]+)\\\"", (root / "MethodKey.java").read_text()))
# 扫描 Wrapper 中 MethodKey.<key>.equals(call.method)，再与 apis 比对。
'
```

当前运行结果：`257` 条有分发（`ConversationManager.insertMessage` 例外），且 `258` 条 manager 都与实际 Wrapper 一致。
