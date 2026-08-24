# Changelog

## Phase 1 - Android 4.10 / 4.14 / 4.23 多版本 Runner

### 新增

- 新增 Android `sdk410`、`sdk414`、`sdk423` 三个构建 flavor；前两个
  分别解析真实 `hyphenate-chat:4.10.0` 和 `hyphenate-chat:4.14.0`，
  `sdk423` 复用项目原有本地 `hyphenatechat_4.23.0.jar` 与配套 `.so`。
- 4.23 基线直接注册并复用正式 `im_flutter_sdk_android` Wrapper；测试专用
  `NativeSdkBridge` 只保留给 4.10/4.14 历史 Artifact。
- 新增独立 `TestControlChannel`，只负责 Runner 信息与升级快照，不重复实现
  登录、联系人、消息、群组等业务 API。
- 新增统一 `InterfaceRouter`。所有 JSON 请求按 `manager/cmd/info`
  经 `im_flutter_sdk_interface` 的 `Client.instance` 与 Manager 路由到原生，
  不经过正式 `im_flutter_sdk`。
- 新增 Runner Hello、能力上报、标准响应归一化和原生事件转发。
- 新增 Base API + 版本增量 Capability Matrix；支持
  `supported / unsupported / unknown / conflict` 四种判定。
- 新增 scenario、artifact、Runner Registry 和 Android Orchestrator；
  支持模拟器选择/启动、覆盖安装、显式启动参数和版本绑定校验。
- 新增由 `native-auto-test` 托管的 managed WS；按
  `runId + runnerId + requestId` 精确路由。external WS 保留为兼容模式。
- 新增 4.10 → 4.14 覆盖安装用例，使用真实 SDK 本地消息数据库生成并
  比较升级前后快照；升级后重新登录并执行真实服务端联系人同步。
- 新增 Phase 1 矩阵脚本、框架单测及 Allure 的 Runner、Capability、
  请求/响应、错误和升级快照附件。
- Runner Registry 增加 serial、runnerId、deviceName 唯一性校验，防止
  两个逻辑角色串绑到同一个真实 Runner。
- 测试 NativeSdkBridge 新增 `UserInfoManager` 的
  `updateOwnUserInfo`、`updateOwnUserInfoWithType`、
  `fetchUserInfoById`、`fetchUserInfoByIdWithType`、`fetchOwnInfo`，
  并统一完成 `EMUserInfo` 与 JSON Map 编解码。
- 新增六逻辑槽位、按 Case fixture 并集启动、Session 设备/登录复用、
  Case 事件游标、离线网络控制和场景资源清理登记表。

### 修改

- `im_flutter_test` 移除对正式 `im_flutter_sdk` 的依赖，只保留
  `im_flutter_sdk_interface`。
- WebSocket 请求从强类型 `EMMessage` 转换改为通用 JSON/Map
  encode/decode；版本差异留在平台 Adapter / Wrapper。
- Android 启动改为 `force-stop` 后显式 `am start`，避免覆盖安装或旧
  task 导致 runnerId、topic、版本串绑。
- `adb install -r` 后等待 PackageManager 更新稳定，再显式启动 Runner，
  避免系统恢复旧 Intent 覆盖本次 runnerId、topic 和 WebSocket URL。
- 登录幂等判断改为真实连接状态；矩阵使用独立测试账号，避免历史好友
  关系污染后续批次。
- 第一阶段验收标准改为可执行的 `AC-P0-* / AC-P1-*` 条目，明确证据、
  错误分类和最小验收用例集。
- 正式 Android API Matrix 改为以 4.23 为基线；4.10/4.14 的历史验证
  移入 `android_legacy.yaml`。

### 当前验证结果

- `sdk410`、`sdk414`、`sdk423` APK 均构建成功。
- Dart analyze 与单元测试通过。
- Python Capability / Orchestrator / UpgradeRunner 框架单测通过。
- 项目原有 Android SDK 4.23 双设备登录成功；
  `tests/user_info/test_user_info.py` 12 条现有用例真实执行并全部 Passed，
  无 Skip、Fail 或 Broken。
- 4.10 对 4.14 新 API 能在调用前自动 Skip。
- 4.10 → 4.14 覆盖安装、本地消息保留和升级后重新登录已在真实模拟器
  上通过；升级后的真实服务端联系人同步也通过。
- 4.23 单设备用户属性、A/B 消息和离线恢复在同一 managed WS Session
  连续 3 条全部通过。

### 待公司网络或 VPN 补验

- 同一联系人基准 case 在 4.10、4.14 两个方向的最终 Passed 结果。
- 4.14 `fetchGroupMembersInfo` 的真实在线 Passed 结果。
- 覆盖升级后恢复网络的同步/收发验证。
- 完整双向矩阵的 Allure 最终报告及连续三次稳定性记录。

当前非公司网络下，Flutter/Python 本地 relay 与设备路由可正常互通，但
原生 IM SDK 的登录、联系人 REST 和实时事件存在超时或不可达。因此以上
在线项不得标记为验收通过。
