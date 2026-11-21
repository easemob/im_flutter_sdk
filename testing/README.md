# 测试入口

ohos（鸿蒙）线的三类测试：单设备集成套件（`integration_test/`，经 `tool/ci/ohos_local.sh`）、单设备脚本（`testing/single/`，auto 模式 step 脚本 + `auto_report.dart` 报告器）、多设备场景（`testing/multi/`，im-test-orchestrator 编排）。鸿蒙构建/测试一律使用 fvm `custom_ohos`（`.fvm/flutter_sdk/bin/flutter` 或 `FLUTTER_BIN`），设备为 hdc target（默认 `127.0.0.1:5555`）。

| 目录 | 内容 | 入口 |
|---|---|---|
| `../im_flutter_sdk/example/integration_test/` | 单设备集成测试（6 套件） | 仓库根 `bash tool/ci/ohos_local.sh [suite...]`（凭证：6 个 `E2E_*` 变量） |
| `single/cases/` | 单设备 auto 脚本（1.16.0 正/逆向） | [单设备说明](single/README.md)；`dart testing/single/auto_report.dart --platform ohos` |
| `multi/cases/` | 多设备 YAML/JSON 场景（`1.16.0-multi-*`） | [多设备说明](multi/README.md)；`scripts/multi.sh`（编排工具为独立仓 im-test-orchestrator，需其 ohos 平台支持） |
| `../im_flutter_sdk/test/` | SDK 单元与契约测试 | 官方 Flutter 3.47.0：仓库根 `bash tool/ci/run_quality.sh` |

example 的 `lib/` 是共用执行端（普通 / auto / agent 三模式互斥，见 `main.dart`）；REST 规范层为 `integration_test/support/rest_fixture.dart`（与 4.x 线同构，两线 diff 为空）。

## 质量门

```bash
bash tool/ci/run_quality.sh   # 官方 Flutter 3.47.0（analyze/format）；门禁后鸿蒙构建前先 fvm flutter pub get
```

## 已知平台限制

- 2 个多设备 device-sync 场景在鸿蒙线永久跳过：`ChatClient.fetchLoggedInDevices` 已从 ohos Dart 层移除（native chatsdk 无多端设备管理）。依据见 `docs/testing/ohos-multi-api-matrix.md`。
- 单设备脚本依赖的 example registry 仅 21 个 API（chat/group/presence/push/user_info），client/contact/thread 未注册；脚本只覆盖已注册 API。
