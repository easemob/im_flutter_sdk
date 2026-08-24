# Native API 自动化测试

Python pytest 用例通过 managed WebSocket 驱动 Android、iOS 测试 App 或浏览器 Runner，验证统一协议下的 API 响应和事件回调。

当前只维护 SDK 5.0：Android 5.0、iOS 5.0、Web 5.0。其他版本不在本分支构建或运行。

## 快速开始

```bash
cd native-auto-test
python3.12 -m venv .venv
.venv/bin/pip install -r requirements.txt
cp config.yaml.template config.yaml
```

完成初始化后，pytest 命令默认都在 `native-auto-test/` 目录执行。

`config.yaml` 至少填写：

- `rest_api.base_url`
- `rest_api.auth_token`
- `sdk_options.app_key`

不要提交真实 token、密码或服务地址。

### Android / iOS

先确认本机设备：

```bash
adb devices                 # Android
xcrun simctl list devices   # iOS
```

然后修改对应 Scenario 中的 `serial`，使用本机实际设备序列号。不要直接假设仓库里的 serial 在其他机器上可用。

常用 Scenario：

```text
config/scenarios/android_500_multi_device_default.yaml
config/scenarios/ios_500_multi_device_default.yaml
```

### Web

Web 使用本地浏览器 Runner，不需要 `serial`：

```text
config/scenarios/web_500_multi_device_default.yaml
```

需要 Chrome，可用 `NATIVE_TEST_CHROME` 或 Scenario 中的 `browser` 指定浏览器路径。

## 构建和运行

只改 Python 用例时，不需要构建；修改测试 App、Wrapper、JAR、SO、XCFramework 或 Web IIFE 时使用 `--build`。

Android：

```bash
cd native-auto-test
.venv/bin/python -m pytest --build -q -ra -s \
  --scenario android_500_multi_device_default \
  tests/chat/test_chat_crud.py::test_chat_send_and_received
```

iOS：

```bash
.venv/bin/python -m pytest --build -q -ra -s \
  --scenario ios_500_multi_device_default \
  tests/chat/test_chat_crud.py::test_chat_send_and_received
```

Web：

```bash
.venv/bin/python -m pytest --build -q -ra -s \
  --scenario web_500_multi_device_default \
  tests/chat/test_chat_crud.py::test_chat_send_and_received
```

运行文件或模块：

```bash
.venv/bin/python -m pytest -q -ra -s \
  --scenario android_500_multi_device_default \
  tests/chat/test_chat_crud.py

.venv/bin/python -m pytest -q -ra -s \
  --scenario android_500_multi_device_default \
  tests/chat
```

默认不要加 `--maxfail=1`，一次查看全部失败项。单个失败用例确认后再单独重跑。

## 三端适配原则

同一业务语义使用同一个协议名；各平台 Wrapper 负责把协议映射到自己的原生 API。

| 平台 | 测试入口 | 适配位置 |
|---|---|---|
| Android | Flutter 测试 App | `im_flutter_sdk_android/android/src/main`，当前 checkout 只包含 Android 5.0 |
| iOS | Flutter 测试 App | `im_flutter_sdk_ios/ios/Classes`，当前 checkout 只包含 iOS 5.0 |
| Web | 浏览器 Runner | `im_flutter_sdk_web/src/index.js`；5.0 原生 IIFE 放 `im_flutter_sdk_web/vendor/` |

测试桥接在 `im_flutter_test/`，pytest 工具和用例在 `native-auto-test/`。发布层 SDK 不因普通测试用例增加而修改；只有 SDK 本身新增公开能力时才改发布层。

## 后续版本

当前分支不支持多版本混编或混跑。将来升级 SDK 时，从 5.0 的 Git tag 创建新分支，在同样的单版本目录中替换原生依赖和 Wrapper，再同步更新 Scenario、Artifact Manifest、API Matrix 和事件清单。

目录约定保持不变：Android 使用 `android/src/main`，iOS 使用 `ios/Classes`，Web 使用 `vendor/im-sdk-web.iife.js`。不要重新引入 `base500`、`sdkXXX` 或 Wrapper 合并目录。

## 普通、拓扑和离线用例

- 普通单设备或普通双端：使用 `device_a`、`device_b`。
- 多端、离线、或明确验证事件投递端集合：使用 `@pytest.mark.topology(...)`。
- 拓扑用例使用 `sender`、`recipient`、`recipients` 等角色变量，避免在断言中写死 `deviceA`、`deviceB`。
- 默认多设备 Scenario 会启动多台设备，但不代表所有 case 都要使用拓扑。
- 离线用例需要明确谁下线、谁执行动作、谁恢复登录，以及恢复后验证哪些端点；不能只因为启动了副端就要求所有端收到事件。
- 修改或新增用例前阅读：

  ```text
  skills/im-sdk-test-case-design/SKILL.md
  ```

## Allure

```bash
.venv/bin/python -m pytest -q \
  --scenario android_500_multi_device_default \
  tests/chat --alluredir=out/allure-results
allure serve out/allure-results
```

详细测试设计和 SDK 差异记录放在 `docs/`，README 只保留运行方式。

## 提交前检查

以下检查从仓库根目录执行：

```bash
cd ..
bash im_flutter_sdk/scripts/speckit.sh check
git diff --check
```

修改依赖或原生 Wrapper 后，再执行对应平台构建；修改版本产物后重新生成 Manifest。不要提交 `.venv`、构建目录、APK/APP、浏览器 profile、测试结果或本机配置。

## 目录速查

```text
config/scenarios/       设备、账号、SDK 版本和拓扑
config/api_matrix/      API/事件能力和跨端协议映射
config/artifacts.yaml   SDK 版本与测试产物
im_flutter_test/        测试 App、WebSocket 桥接和事件转发
im_flutter_sdk_android/ Android 原生依赖与 Wrapper
im_flutter_sdk_ios/    iOS 原生依赖与 Wrapper
im_flutter_sdk_web/    Web IIFE 与 Web Wrapper
src/                    pytest 驱动、断言和测试流程工具
tests/                  按模块组织的用例
docs/                   版本差异、测试设计和问题记录
```
