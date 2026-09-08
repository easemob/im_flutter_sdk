# release APK 测试自动化

## User Story

作为 Flutter SDK E2E 测试维护者，我希望 `im_flutter_test` 能以 release 模式构建并正常运行，从而用接近生产的形态（AOT + 混淆）跑 E2E 用例，同时让本地运行更快、更稳定。

作为仓库协作者，我希望测试 App 启动后自动连接 `native-auto-test/config.yaml` 中配置的 WebSocket 桥接，从而无需在模拟器上手动填写 URL/topic/device 并点击「连接」，支持无人值守和后续 CI/远程运行。

作为团队其他成员，我希望通过一个 repo-local skill 一条命令完成「构建 release APK → 启动模拟器 → 安装 App → 配置桥接 → 运行 pytest → 生成报告」，从而无需手动搭建 Flutter/Android 环境、无需启动 Android Studio。

## Acceptance Criteria（EARS）

1. 当在 `im_flutter_test` 中执行 `flutter build apk --release` 时，系统应成功产出 `build/app/outputs/flutter-apk/app-release.apk`，且环信 SDK 引用的可选厂商推送依赖（OPPO/魅族/vivo/小米）缺失不得导致 R8 构建失败。
2. 当 release APK 在模拟器上启动时，App 应无崩溃地完成 SDK 初始化，环信 SDK 版本日志应正常输出，`com.hyphenate.chat.adapter.**` 等 JNI 桥接类不得因 R8 混淆改名而触发 `ClassNotFoundException`。
3. 当 App 启动时，系统应从打包进 asset 的 `config.yaml` 读取 `websocket.base_url` 与 `websocket.default_topic`，并自动建立 WebSocket 桥接连接、注册事件处理器，无需任何手动 UI 操作。
4. 当 `config.yaml` 存在 `websocket.base_url` 与 `websocket.default_topic` 时，App 应优先使用该配置值；当缺失或为空时，系统应回退到现有默认值 `ws://127.0.0.1:4000/iov/websocket/dual` 与 `adc`，不得因缺失配置而崩溃。
5. 当 App 自动连接成功后，UI 应仍保留 URL/topic/device 输入与手动「连接/断开」能力，便于诊断时手动重连或切换环境，不得因自动连接移除现有手动入口。
6. 当自动连接失败（如 relay 未启动）时，App 应在 UI 上给出可定位的失败提示，且不阻塞后续手动重连；不得静默失败。
7. 当协作者执行一键 skill 时，系统应先检测 flutter、adb、emulator、python 与可用 AVD，任一缺失或不可执行时应立即给出明确修复提示并非零退出，不得进入后续步骤。
8. 当环境检测通过时，skill 应按顺序自动完成 release APK 构建、模拟器启动、APK 安装、WebSocket relay 启动、`adb reverse` 端口映射、pytest 运行与报告生成，全程无需启动 Android Studio 或手动操作 App。
9. 当 skill 复用现有 `make ws-bridge-up` / `make test-local` 能力时，relay 启动、reverse 映射与本地 pytest 环境加载行为应保持不变，不重复实现已有逻辑。
10. 当 pytest 运行结束时，skill 应生成报告并输出可访问的报告路径/URL；报告内容应包含请求、响应与比对结果（复用现有 allure/pytest-html 能力）。
11. 当协作者按 skill 文档操作时，文档应明确说明「改 `sdk_options`/`websocket` 后需重新构建 APK、`rest_api`/`topics` 无需重建」的配置生效规则，以及无需安装 Android Studio 的最小依赖。
12. 当本功能完成时，自动化测试应覆盖 config.yaml 的 websocket 配置读取、缺失回退与自动连接触发逻辑，且不依赖真实设备或外部服务器；release 构建与模拟器端到端流程作为需显式设备环境的手工验收步骤。
13. 当以 `--dart-define=DEVICE=deviceB` 构建 release APK 时，App 应使用 `topics.deviceB` 作为 topic、`deviceB` 作为设备标识；未指定 `DEVICE` 时默认 `deviceA`，不得破坏单端行为。
14. 当 `topics` 节缺失对应设备或为空时，App 应回退到 `websocket.default_topic`，保证单端/无 topics 配置下仍可连接。
15. 当业务 cases 执行时，session 登录应成功登录 deviceA 与 deviceB 两台设备，且至少一个真实业务 case（如 client 连接态查询）应通过，作为本功能完成的可运行验收标准。

## 范围说明

- 只改 `im_flutter_test`（测试端）与 `native-auto-test`（skill），不修改 `im_flutter_sdk` 发布层。
- 自动连接支持**双端**（deviceA/deviceB 两台设备分别连 `topics.deviceA`/`topics.deviceB`），以满足业务 cases 的 session 双端登录要求。
- GitHub Release 发布 APK 与远程机器/Docker 运行不在本 spec 内，作为后续独立功能。
