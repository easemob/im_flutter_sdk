# 环信 IM Flutter SDK

环信即时通讯 Flutter 插件，采用 Federated Plugin 架构。本仓库包含 Dart 公开接口、Android/iOS 实现、示例应用和测试工具；HarmonyOS 实现在独立仓库维护。

调用链：`Dart API → MethodChannel → Native Wrapper → 原生 IM SDK`。

## 验证模式与入口

| 模式 | 职责 | 使用入口 |
|---|---|---|
| CI 测试 | 守住基础功能、稳定性和回归覆盖 | `.github/workflows/`；本地入口为 `tool/ci/` 下的 `run_quality.sh`、`smoke_local.sh`、`nightly_local.sh`，见[开发指南](CONTRIBUTING.md#running-and-verification) |
| AI 测试 | 验证每次平版的 API、行为变化及单设备、多设备场景 | 单设备：`make auto-report PLATFORM=<android\|ios> SCRIPT=<json>`，见[脚本模式](im_flutter_sdk/example/README.md#script-mode-ai-friendly)；多设备：进入 `testing_v2/`，使用 `dart run bin/cli.dart all --cases <选择文件>`，见[使用说明](testing_v2/README.md) |
| 人工模式 | 自由抽验 API，理解、使用和提取示例代码 | 进入 `im_flutter_sdk/example/`，运行 `flutter run -d <设备ID>`，见[示例说明](im_flutter_sdk/example/README.md) |

CI 使用 Flutter 单元、契约和设备集成测试；AI 使用 JSON 脚本及 YAML 控制流。两套测试架构独立维护，API 覆盖可以重叠，各自结果不相互替代。人工模式提供自由操作，不作为自动用例集。

每次平版先完成相关单设备、多设备场景验收，再将需要长期守护的基础行为、关键边界和已修复缺陷补充为 CI 回归用例。

## 目录

```text
.
├── im_flutter_sdk/             # SDK 主包
│   ├── lib/                    # 公开 API、模型与业务管理器
│   ├── test/                   # SDK 单元及契约测试
│   ├── example/                # 示例应用：人工操作、脚本执行、HTTP 控制服务
│   │   ├── lib/                # 页面、API 注册表、日志及自动执行端
│   │   ├── integration_test/   # CI 在设备上运行的 Flutter 集成测试
│   │   ├── scripts/            # 单设备 JSON 测试脚本
│   │   └── test/               # 示例应用及执行端自身的测试
│   ├── docs/                   # SDK 专项说明、CI 用例映射
│   ├── scripts/                # API 文档生成工具
│   └── tool/ci/                # 契约、版本与用例映射检查器
├── im_flutter_sdk_interface/   # MethodChannel 平台接口
├── im_flutter_sdk_android/     # Android 原生封装
├── im_flutter_sdk_ios/         # iOS 原生封装及依赖配置
├── testing/                    # 数据准备工具、已有协同用例及组合脚本
├── testing_v2/                 # Dart 多设备测试 CLI、用例、报告及排查文档
├── tool/                       # 仓库开发工具、单设备报告工具
│   ├── ci/                     # CI 检查与设备测试的执行入口
│   └── flow_runner/            # YAML 控制流解释器
├── .github/workflows/          # CI 触发条件和任务编排
├── docs/                       # 规格、计划、版本平版记录及排查资料
├── dailylog/                   # 协作工作日志
└── Makefile                    # 环境准备和常用开发命令
```

`testing_v2` 当前用于多设备执行；`testing/flows/` 中的用例使用[对应脚本入口](testing/scripts/README.md)。本地凭据、生成账号数据、构建缓存和运行报告由各工具管理，不纳入 Git。

## 文档

| 对象 | 入口 | 内容 |
|---|---|---|
| SDK 使用者 | [SDK 接入指南](im_flutter_sdk/README.md) | 集成、平台配置与快速开始 |
| 开发维护者 | [CONTRIBUTING.md](CONTRIBUTING.md) | 开发环境、验证、分支与发布流程 |
| CI 用例维护者 | [用例说明](im_flutter_sdk/docs/ci/flutter-only-ci.md)、[验证记录](docs/refs/ci-basic-api-tests/2026-11-07-positive-verification.md) | 覆盖范围、运行条件、报告与未完成项 |
| AI 执行者 | [AGENTS.md](AGENTS.md) | 架构边界、任务选择与协作规则 |
| 用例编写者 | [flow_runner](tool/flow_runner/README.md) | YAML 流程、JSON 命令及断言语法 |

开发使用 Flutter 3.47.0。环境准备见开发指南，仓库根目录运行 `make help` 查看可用命令。
