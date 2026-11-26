## 1.16.0-ohos

原生基线升级为 HarmonyOS `@easemob/chatsdk` 1.16.0（平版 native 4.26.1 开发基线），以 ohpm 版本号依赖接入。

**新增**（chatsdk 1.16.0 原生新增能力的 Dart 平版）

- `ChatClient.getConnectionState`：获取 SDK 与服务器的连接状态，新增枚举 `ChatConnectionState`（`disconnected` / `connecting` / `connected`，数值与原生 ordinal 对齐），可区分"连接中"状态；`isConnected` 自本版本起在文档中标记废弃；
- `ChatOptions.disconnectNotifyThreshold`：断开连接通知的时间阈值（秒），原生默认 `10`；小于等于 `0` 关闭断开通知平滑；为 `null` 时不下发，使用原生默认值；
- 断开通知平滑（原生行为）：可恢复错误（如网络波动）导致的断开按阈值延迟回调 `onDisconnected`，阈值内恢复连接则不通知；致命错误（如被踢下线）立即回调；
- `ChatConversation.markMessagesAsReadWithTimestamp`：将会话中时间戳不晚于指定时间的未读接收消息置为已读；本地操作，不发送已读回执，未读数相应扣减；
- `ChatOptions.usePushInBackground`：退后台且已绑定推送 token 时，SDK 延迟 10 秒主动断连，期间消息通过离线推送送达，回前台自动重连，默认关闭；
- 连接监听注册回放（原生行为）：`addConnectionListener` 注册时异步回放一次当前连接状态（已连接回调 `onConnected`；已登录未连接回调 `onDisconnected(NETWORK_ERROR)`）。

**修复**（随原生 1.16.0 获得）

- 修复流式消息后续分片未整表覆盖本地 ext 的问题；
- 修复聊天室跨登录会话 join/leave 竞态问题；
- 修复自动登录/重连时 host 列表耗尽直接登出的问题，改为刷新 DNS 退避重连（HIM-24079）。

## 1.15.0-ohos

鸿蒙线首个版本，以 `1.15.0-ohos` 标识鸿蒙线（版本号跟随 HarmonyOS 原生 SDK `@easemob/chatsdk` 1.15.0）。

**新增**

- 新增 HarmonyOS 平台实现包 `im_flutter_sdk_ohos`，基于 HarmonyOS 原生 `@easemob/chatsdk` 1.15.0；
- Dart API 与 Flutter 4.25.0 线对齐，覆盖 `ChatClient` 与 8 个 Manager：会话、消息、群组、聊天室、联系人、用户属性、推送、在线状态；
- 新增本地数据准备工具：`make config` / `make env-gettoken` 生成不随仓库提交的 `example/lib/env.dart`；
- 新增鸿蒙本地测试入口 `tool/ci/ohos_local.sh` 与 `tool/ci/smoke_local.harmony.sh`、`tool/ci/nightly_local.harmony.sh`（smoke 零凭证；nightly 只需长期凭证，token 由脚本现场换取）。

**修复**

- 修复 `ChatClient.init` 后事件监听器未及时注册，导致纯接收方收不到事件的问题；
- 修复 `loadMessagesWithIds`、`searchMsgFromDB` 参数键与 native 不一致的问题；
- 修复 `getGroupWithId` 对不存在的群返回空壳对象的问题（现返回 `null`）；
- 修复群组/聊天室成员列表缺少群主/房主的问题；
- 修复会话消息分页顺序、按时间删除会话消息参数的问题。

**说明**

- 主包只声明 HarmonyOS 平台；Android/iOS 请使用 pub.dev 官方发布线（4.25.0 / 5.0.0）。
- `im_flutter_sdk_ohos` 与主包同步发布 `1.15.0-ohos`（先发布实现包到 pub.dev，再打主包 Git tag）；`im_flutter_sdk_interface` / `_android` / `_ios` 使用 pub.dev 已发布 **4.25.0**，**不发布新版本**。

**已知限制**

- 暂不支持 Thread 相关 API（按鸿蒙能力缺口清单移除）；
- 鸿蒙端隐藏悬浮附件面板（`file_picker` 无可用实现）；
- 聊天室消息回执、翻译、语音转文字、服务端消息搜索等依赖服务端增值服务开通；
- 多设备部分用例需双端联调。

## 1.5.4

- 修复鸿蒙分页参数顺序（`pageNum` / `pageSize`）；
- 更新构建配置与示例调试依赖。

## 1.5.3

- 首个支持鸿蒙平台的联合插件版本，Dart API 对齐 Android/iOS 4.12；
- 暂不支持聊天室、Thread、多设备管理。
