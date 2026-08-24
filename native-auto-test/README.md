# Native API 自动化测试

Python pytest 用例通过 managed WebSocket 驱动 Android、iOS 测试 App 或浏览器 Runner，验证统一协议下的 API 响应和事件回调。

当前基线：Android 5.0、iOS 5.0、Web 5.0。

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
| Android | Flutter 测试 App | `im_flutter_sdk_android/android/src/base500`；后续版本放 `sdk510`、`sdk520` 等差异目录 |
| iOS | Flutter 测试 App | `im_flutter_sdk_ios/ios/Classes/base500`；后续版本放对应版本差异目录 |
| Web | 浏览器 Runner | `im_flutter_sdk_web/src/index.js`；5.0 原生 IIFE 放 `im_flutter_sdk_web/vendor/base500/` |

测试桥接在 `im_flutter_test/`，pytest 工具和用例在 `native-auto-test/`。发布层 SDK 不因普通测试用例增加而修改；只有 SDK 本身新增公开能力时才改发布层。

## 新增下一个 SDK 版本

以 5.1.0 为例，顺序如下：

1. 准备 Android JAR/SO、iOS XCFramework 或 Web IIFE，并确认真实原生 API、参数和事件。
2. 新增版本差异目录：

   ```text
   android/src/sdk510/
   ios/Classes/sdk510/
   web/vendor/sdk510/
   ```

   Android/iOS 只放相对 5.0 的差异，不复制整套基线文件。
3. 在 `im_flutter_test` 增加对应 flavor，并新增 Scenario，例如：

   ```text
   config/scenarios/android_510_multi_device_default.yaml
   config/scenarios/ios_510_multi_device_default.yaml
   config/scenarios/web_510_multi_device_default.yaml
   ```

4. 更新 `config/artifacts.yaml` 和 `config/artifact_manifests/`，记录版本、产物路径、SHA256、Wrapper 版本和 capabilities。
5. 更新对应 API Matrix：

   ```yaml
   base:
     version: 5.0.0
     apis: [...]

   versions:
     5.1.0:
       added:
         - ChatManager.newApi
       removed:
         - ChatManager.oldApi
   ```

   API 改名按“旧 API `removed` + 新 API `added`”记录。不要在版本节点下写完整 `apis` 快照，也不要用版本级 `changed`。
6. 公共语义继续使用 Android 对齐的协议名；只有平台独有能力才放到：

   ```yaml
   android_only_native: []
   ios_only_native: []
   web_only_native: []
   ```

   独有能力必须有真实 Wrapper 和真实原生实现，不能为了让 case 通过而构造假结果。
7. 按实际变更更新对应文件，不需要每次全部修改：

   - API 能力变化：更新对应平台的 `config/api_matrix/*.yaml`；
   - 回调新增、删除或字段变化：更新对应的 `*-events.yaml` 和 Wrapper；当前基线清单为 `android-events.yaml`、`ios-events.yaml`、`web-events.yaml`；
   - 公共协议名或跨端原生映射变化：更新对应 Wrapper 和 API Matrix；映射 YAML 只用于升级核对，不是运行测试的必需文件。

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

## Allure 和结果

```bash
.venv/bin/python -m pytest -q \
  --scenario android_500_multi_device_default \
  tests/chat --alluredir=out/allure-results
allure serve out/allure-results
```

用例应在 Allure 中记录前置、关键动作、设备/平台/SDK 参数和最终断言；详细测试设计放在 `docs/`，不要把长篇 case 说明塞进 README。

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
