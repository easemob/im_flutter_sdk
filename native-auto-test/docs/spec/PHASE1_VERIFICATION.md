# Spec 7.30 整体 MVP 验收记录

记录日期：2026-07-30

## MVP 结论

整体 MVP 已跑通：

```
pytest Case
→ native-auto-test managed WS
→ im_flutter_test
→ InterfaceRouter
→ im_flutter_sdk_interface
→ Android Wrapper
→ Android 原生 SDK
```

4.23 使用正式 `im_flutter_sdk_android` Wrapper；4.10/4.14 仅作为历史
覆盖安装机制验证，使用测试端 legacy Wrapper。测试业务调用不经过
`im_flutter_sdk` Dart 业务层。

正式 API Matrix 以 Android 4.23 为基线：
`config/api_matrix/android.yaml`。历史 4.10/4.14 验证使用
`config/api_matrix/android_legacy.yaml`，不作为后续版本基线。

## Artifact

| SDK | Artifact SHA-256 | Native SDK SHA-256 |
|---|---|---|
| 4.10.0 | `5f1fbe1246e557ad8cace211440b091520034340c323f54cf5432e9397d57a5f` | `639c552cae14298423e11b7e9c377f858a60a6a0caa5c3ffd40916128f6a7e3b` |
| 4.14.0 | `1d432c04b3fc72f2616e8edb01d7c4532a696d4ce4839e8b736ccdee437f1a3b` | `ece81133b2291e3117b3ae910554a14b8b5fd7375a0245450c255c5142cd42fb` |
| 4.23.0 | `781569e611dbb0d780188d737a16d307234d109ca3caf4a87d8220405f9c0877` | `4630a0e04cb9cce0caf0e50afa087b5e57856b1fcc0a43a7bbfdf01c2c6d6c88` |

三个 Artifact 使用同一 applicationId
`com.easemob.im_flutter_test`。Manifest、APK Hash、Wrapper 状态、
Native SDK Hash、Runner Hello 和 API Matrix 均在 Case 开始前校验。

## 已通过

- `im_flutter_test flutter analyze`：通过。
- `im_flutter_test flutter test`：5 Passed。
- Python Framework：17 Passed。
- `speckit check`：Android/iOS 依赖结构全部通过。
- `sdk410`、`sdk414`、`sdk423` 三个 APK：构建通过。
- managed WS：自动端口、runId、Runner Hello、requestId 精确路由通过。
- 同一 Session 两个 4.23 Runner 连续执行：
  - 现有单设备 `test_user_info_update_then_fetch_own_info`：Passed。
  - 现有 A/B `test_chat_send_and_received`：Passed。
  - 离线消息恢复及事件游标：Passed。
- 4.10 → 4.14 `adb install -r`：
  - 旧版创建本地消息；
  - 新版 Hello 校验通过；
  - 本地消息 ID 保留；
  - 升级后登录和服务端联系人同步通过。
- Case 资源登记表按逆序执行清理，清理失败不阻断后续资源清理；结果写入
  Allure。
- Allure 已包含 Case 类型、Scenario、Logical Device、Runner、账号槽位、
  实际账号、Artifact、版本、Capability、请求、响应、事件和升级快照。

证据目录：

- `native-auto-test/allure-results/mvp-final/`
- `native-auto-test/allure-results/spec730-upgrade-fixed/`
- `native-auto-test/allure-results/spec730-offline/`

## MVP 后续项

以下属于完整 Spec 验收，不伪装成 MVP 已通过：

- 接入一个真实的 4.23 后续 Android SDK Artifact，验证新增、删除和参数变化。
- 当前 AppKey/服务端未开启 Android 同账号并发多设备登录；框架已在 Case
  前识别并报告 Environment Error，服务能力开启后再验
  `device_a + device_a_sec` 和第三方复杂拓扑。
- external WS 双 Runner 兼容模式尚需在真实外部 WS 环境补验。
- Web、iOS、macOS、OHOS Runner 尚未接入。

## 运行命令

4.23 MVP：

```bash
cd native-auto-test
.venv/bin/python -m pytest -q \
  --scenario android_423_423 \
  tests/user_info/test_user_info.py::test_user_info_update_then_fetch_own_info \
  tests/chat/test_chat_crud.py::test_chat_send_and_received \
  tests/phase1/test_offline_sync.py::test_offline_message_sync_keeps_case_event_cursor \
  --alluredir=allure-results/mvp-final
```

历史覆盖安装机制：

```bash
cd native-auto-test
.venv/bin/python -m pytest -q \
  --scenario android_410_414 \
  --api-matrix config/api_matrix/android_legacy.yaml \
  tests/phase1/test_upgrade.py \
  --alluredir=allure-results/spec730-upgrade-fixed
```
