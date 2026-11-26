## 1.16.0-ohos

随主包 `1.16.0-ohos` 一起发布，原生基线升级为 `@easemob/chatsdk` 1.16.0（平版 native 4.26.1 开发基线），以 ohpm 版本号依赖接入。

**新增**（chatsdk 1.16.0 新能力的 wrapper 平版，详见主包 CHANGELOG）

- `ClientWrapper` 新增 `getConnectionState` 路由（`isConnected` 保留）；`MethodKeys.ets` 由 `tool/check_method_keys.py --generate` 重新生成；
- `ConversationWrapper` 新增 `markMessagesAsReadWithTimestamp` 路由；
- `ChatOptionsHelper` 新增 `disconnectNotifyThreshold`、`usePushInBackground` 两个选项的下发；
- 连接监听注册回放与断开通知平滑为原生行为，wrapper 事件链路无需改动。

## 1.15.0-ohos

鸿蒙平台实现包首个版本，随主包 `1.15.0-ohos` 一起发布（本包先发布到 pub.dev，主包按 `^1.15.0-ohos` 版本范围引入）。

**新增**

- 新增 `im_flutter_sdk_ohos` 平台实现包，基于 HarmonyOS 原生 `@easemob/chatsdk` 1.15.0；
- 实现 `im_flutter_sdk_interface` 的全部 MethodChannel 路由，覆盖 `ChatClient` 与 8 个 Manager 的 wrapper（interface 为 pub.dev 已发布 4.25.0，复用，不随本线发版）；
- 新增鸿蒙本地测试入口：仓库根目录 `tool/ci/ohos_local.sh`、`tool/ci/smoke_local.harmony.sh`、`tool/ci/nightly_local.harmony.sh`（smoke 零凭证；nightly 只需长期凭证，token 由脚本现场换取）。

**修复**

- 修复 `ChatClient.init` 后事件监听器未及时注册，导致纯接收方收不到事件的问题；
- 修复 `loadMessagesWithIds`、`searchMsgFromDB` 参数键与 Dart 侧不一致的问题；
- 修复 `getGroupWithId` 对不存在的群返回空壳对象的问题（现返回 `null`）；
- 修复群组/聊天室成员列表缺少群主/房主的问题；
- 修复会话消息分页顺序、按时间删除会话消息参数的问题。

**已知限制**

- 暂不支持 Thread 相关 API（按鸿蒙能力缺口清单移除）；
- 鸿蒙端隐藏悬浮附件面板（`file_picker` 无可用实现）；
- 聊天室消息回执、翻译、语音转文字、服务端消息搜索等依赖服务端增值服务开通。

## 1.5.4

- 修复鸿蒙分页参数顺序（`pageNum` / `pageSize`）；
- 更新构建配置与示例调试依赖。

## 1.5.3

- 首个支持鸿蒙平台的联合插件版本，Dart API 对齐 Android/iOS 4.12；
- 暂不支持聊天室、Thread、多设备管理。
