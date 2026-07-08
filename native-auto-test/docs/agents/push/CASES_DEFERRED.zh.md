# Push 模块 Cases 暂缓清单（按 API）

— 说明
- 本文件仅记录 Push 模块暂缓项。
- MissingPluginException 统一记录为桥接/平台通道缺口，不作为 SDK API 正常业务预期。

## 暂缓项
- `tests/push/test_push_remaining_api_coverage.py::test_push_apns_token_update_android_missing_plugin`
  - API：`updateAPNsPushToken`
  - 原因：Android 模拟器无 APNs 平台实现，当前实测返回 `MissingPluginException`；属于平台/桥接不适用缺口，不作为 SDK 业务语义。
  - 恢复条件：在 iOS 平台和 APNs 推送配置可用时按真实返回补齐 strict case。
