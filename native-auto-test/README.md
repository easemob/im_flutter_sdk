# Native API 自动化测试

本目录是 Python 用例端，通过 managed WebSocket 驱动 `im_flutter_test`，验证 Android/iOS 原生 IM SDK 的 API 和回调。

默认使用 Android 5.0 场景：`android_500_multi_device_default`。

## 1. 环境准备

需要：

- Python 3.12（推荐）
- Android SDK、`adb`、已启动的 Android 模拟器
- Flutter：只有构建或修改测试 App 时需要

以下命令默认从仓库根目录 `im_flutter_sdk/` 执行。

首次执行：

```bash
cd native-auto-test
python3.12 -m venv .venv
.venv/bin/pip install -r requirements.txt
cp config.yaml.template config.yaml
```

`config.yaml` 只放本机或测试环境配置，不要提交真实 token、密码或服务地址。

复制模板后必须填写：

- `rest_api.base_url`：当前 Scenario 使用 `provision: rest` 时必填；
- `rest_api.auth_token`：创建/删除测试账号所需的 REST token；
- `sdk_options.app_key`：必须与测试 App 构建时使用的 App Key 一致。

设备 `serial` 不在 `config.yaml` 中配置，而是在 `config/scenarios/*.yaml` 中按本机 `adb devices` 结果修改。

启动模拟器后确认设备在线：

```bash
adb devices
```

将本机 `adb devices` 显示的序列号，填写到自己实际使用的 Scenario YAML 中；不要假设仓库里的 serial 对所有机器都相同。默认 Scenario 是：

```text
config/scenarios/android_500_multi_device_default.yaml
```

如果本机设备数量或序列号不同，请复制/修改对应 Scenario 后，通过 `--scenario` 指定自己的 YAML；账号、SDK 版本和拓扑保持不变即可。

## 2. 构建 Android 5.0 测试 App

已有 APK 时可以直接跑测试。修改 Wrapper、原生 JAR/SO 或测试 App 后，先构建：

```bash
cd im_flutter_test
flutter build apk --flavor sdk500 --debug
```

然后回到本目录运行 pytest。也可以加 `--build`，让测试流程自动构建：

```bash
cd native-auto-test
.venv/bin/python -m pytest --build \
  --scenario android_500_multi_device_default \
  tests/client/test_client.py::test_client_login_success -q -s
```

使用规则：

- 只改 Python case：不需要构建 App。
- 改 `im_flutter_test`、Wrapper、JAR 或 SO：使用 `--build`，或先手动执行上面的 Flutter 构建命令。
- `--build` 会按 Scenario 的 SDK 版本构建并安装对应 APK；不加时复用 `config/artifacts.yaml` 中的产物。

## 3. 升级到下一个原生 SDK 版本

以新增 Android `5.1.0` 为例。不要覆盖 `base500`；它是 Android 5.0 的基线。

### 3.1 先确认原生 API

先拿到新版本 JAR、SO 和 iOS XCFramework，再生成原生 API 基线。API 基线不能从旧 Dart 或旧 Wrapper 反推：

```bash
python3 im_flutter_sdk/scripts/extract_native_api.py \
  --android-jar /path/to/hyphenatechat_5.1.0.jar \
  --android-doc /path/to/hyphenate-api-doc-5.1.0.zip \
  --ios-framework /path/to/HyphenateChat-5.1.0.xcframework \
  --output docs/native-api/5.1
```

然后对照 `docs/native-api/5.0/`，确认新增、删除、改名、参数和回调变化。

### 3.2 更新 API Matrix 和映射

保留 5.0 的 `base`，在对应版本的 `versions` 下记录相对上一版本的变化：

```yaml
versions:
  5.1.0:
    added:
      - ChatManager.newApi
    removed:
      - ChatManager.oldApi
    changed:
      - ChatManager.changedApi
```

需要同步检查：

- `config/api_matrix/android.yaml`、`ios.yaml`：API 能力和版本差异；
- `android-events.yaml`、`ios-events.yaml`：新版本真实存在且 Wrapper 实际转发的事件；
- `android_mapping.yaml`、`ios_mapping.yaml`：统一协议名到原生 API 的映射；
- `protocol-android-ios-5.0-pure-native-map.md`：跨端协议和原生名称对照，若是 5.1 可新增对应版本文档。

生成映射（输入必须是新版本原生基线）：

```bash
python3 im_flutter_sdk/scripts/extract_api_mapping.py
python3 im_flutter_sdk/scripts/extract_ios_mapping.py
```

当前两个 mapping 脚本默认读取 5.0 基线并覆盖统一的 mapping 文件；升级到 5.1 前要先把脚本中的 API 输入目录、Wrapper 目录和输出文件改成 5.1，或给脚本补版本参数，确认无误后再执行。不要直接执行它们去覆盖 5.0 mapping，也不要手写生成文件中标记为自动生成的内容。

### 3.3 接入 Wrapper 和原生依赖

Android：

```text
im_flutter_sdk_android/android/src/sdk501/libs/hyphenatechat_5.1.0.jar
im_flutter_sdk_android/android/src/sdk501/jniLibs/<abi>/*.so
im_flutter_sdk_android/android/src/sdk501/java/...  # 只放相对 base500 的差异 Wrapper
```

在 `im_flutter_sdk_android/android/build.gradle` 中新增 `sdk501` flavor、`sourceSets.sdk501` 和对应的 `sdk501Api files(...)`。Wrapper 采用“`base500` 基线 + `sdk501` 差异合并”，不要把整套 5.0 Java 文件复制到新版本目录。

若新增的是公开 SDK 能力，还要同步 Android/iOS Wrapper、Dart method/event key、模型和接口导出；若只是测试桥接命令，只增加真实存在的 Wrapper 转发和序列化，不要为了测试伪造 SDK API。

iOS：将新版本 Wrapper 差异放到 `im_flutter_sdk_ios/ios/Classes/sdk501/`，再合并基线：

```bash
bash im_flutter_sdk/scripts/merge_ios_sdk.sh sdk501
```

依赖切换遵循 `docs/specs/dependency-spec.md`：本地 JAR/SO/XCFramework 与远程依赖只能启用一种。

### 3.4 增加测试 App flavor 和 Scenario

在 `im_flutter_test/android/app/build.gradle` 增加 `sdk501`，并让它依赖 `im_flutter_sdk_android` 的 `sdk501Implementation`。然后新增：

```text
config/scenarios/android_510_multi_device_default.yaml
```

其中角色的 `sdk_version` 写 `5.1.0`，`serial` 写团队实际使用的模拟器序列号；Scenario 只描述设备和拓扑，不在 case 中写死设备名。

构建：

```bash
cd im_flutter_test
flutter build apk --flavor sdk501 --debug
```

运行：

```bash
cd native-auto-test
.venv/bin/python -m pytest -q -ra -s \
  --scenario android_510_multi_device_default \
  tests/client/test_client.py::test_client_login_success
```

## 4. Artifact 配置、Manifest 和构建产物

`config/artifacts.yaml` 是“SDK 版本 → APK/App 产物”的目录，不是 API Matrix。新增版本时增加对应条目：

```yaml
android:
  5.1.0:
    path: ../../im_flutter_test/build/app/outputs/flutter-apk/app-sdk501-debug.apk
    manifest: artifact_manifests/android-5.1.0.json
    flavor: sdk501
    application_id: com.easemob.im_flutter_test
    activity: .MainActivity
```

iOS 同样增加 `ios.<版本>` 条目，`path` 指向 `Runner.app`，`flavor` 写对应的 Flutter flavor，`manifest` 指向 `artifact_manifests/ios-<版本>.json`。当前 iOS/Web manifest 使用 `artifactSha256: runtime`，不要求提交 `.app` 目录；Android manifest 才由脚本对 APK 计算实际 SHA-256。

构建 APK 后，在 `native-auto-test` 目录生成 Manifest：

```bash
.venv/bin/python scripts/generate_manifests.py --version 5.1.0
```

Manifest 会记录并校验：`sdkVersion`、`artifactSha256`、原生 JAR 的 `nativeSdkSha256`、`wrapperCommit` 和 API capabilities。不要手填 hash，也不要把本机 APK、`.venv`、构建目录和测试结果提交到 Git；`config/artifact_manifests/*.json`、`config/artifacts.yaml`、API Matrix 和 Scenario 是应提交的配置/元数据。

版本升级后至少执行：

```bash
cd /Users/andy_muyu/Documents/Project/im_flutter_sdk
bash im_flutter_sdk/scripts/speckit.sh check
python3 im_flutter_sdk/scripts/check_protocol_consistency.py
bash im_flutter_sdk/scripts/check_wrapper_diffs.sh
git diff --check
```

## 5. 运行用例

推荐参数：

- `-q`：简洁输出
- `-s`：实时显示日志
- `-ra`：最后显示 skip/error 原因
- `--tb=short`：显示简短堆栈
- `--scenario`：指定平台、SDK、账号和设备拓扑

单个用例：

```bash
.venv/bin/python -m pytest -q -ra --tb=short -s \
  --scenario android_500_multi_device_default \
  tests/chat/test_chat_crud.py::test_chat_ack_message_read_success
```

单个文件：

```bash
.venv/bin/python -m pytest -q -ra --tb=short -s \
  --scenario android_500_multi_device_default \
  tests/group/test_group_moderation.py
```

模块目录：

```bash
.venv/bin/python -m pytest -q -ra --tb=short -s \
  --scenario android_500_multi_device_default \
  tests/chat
```

指定多个用例时，直接在命令末尾继续写测试路径；默认不要加 `--maxfail=1`，这样一次能看到全部失败项。

## 6. 用例和拓扑约定

- 普通单设备或双账号用例：直接使用 `device_a`、`device_b` 等 fixture。
- 需要多端、离线或明确验证事件方向的用例：使用
  `@pytest.mark.topology("account_a_to_account_b")`。
- 拓扑用例中使用 `sender`、`recipient`、`recipients` 表示角色，不要在断言里写死 `deviceA`、`deviceB`。
- 当前默认场景中，A/B 各有主端和副端；`user_c` 是服务端账号，默认没有设备端。
- 是否启动副端由场景拓扑决定，不要为了统一而给每个用例都加 topology。

写、改或审查用例前先阅读：

```text
skills/im-sdk-test-case-design/SKILL.md
```

这个 skill 是用例设计入口，规定普通 API、普通双端、多端拓扑和离线 Case 的选择边界，以及 topology 角色、Allure 步骤和严格断言要求。普通双端直接使用 `device_a`、`device_b` fixture；`action_device`、`observer_device` 只能是函数内部别名。默认 Scenario 即使启动四台设备，也不代表所有 Case 都要加 topology；只有验收目标是端点集合行为，或涉及多端离线恢复时才使用 topology。

API 适配时同时查看：

```text
config/api_matrix/android.yaml                         Android 版本 API 能力
config/api_matrix/ios.yaml                              iOS 版本 API 能力
config/api_matrix/android-events.yaml                   Android 回调能力
config/api_matrix/ios-events.yaml                      iOS 回调能力
config/api_matrix/protocol-android-ios-5.0-pure-native-map.md
```

其中 Matrix 决定用例是否支持/skip；协议映射文档记录统一协议与 Android/iOS 5.0 原生 API、Event 的对应关系。不要只根据旧版本 E2E 猜测 5.0 API。

## 7. 报告

生成 Allure：

```bash
.venv/bin/python -m pytest -q \
  --scenario android_500_multi_device_default \
  tests/chat --alluredir=out/allure-results
allure serve out/allure-results
```

生成 HTML：

```bash
.venv/bin/python -m pytest \
  --scenario android_500_multi_device_default \
  tests/chat --html=out/report.html --self-contained-html
```

## 8. 常见问题

### Runner is not registered / Runner hello timeout

通常是模拟器未在线、serial 不匹配、测试 App 未启动或 Runner 被上一轮进程占用。先检查：

```bash
adb devices
```

确认场景中的 `serial`、APK 和设备数量正确后，重新启动一轮 pytest。

### `code=2 Network is unavailable`

这是 SDK/服务连接失败，不是可以忽略的断言。确认模拟器和本机网络、服务地址及登录状态；全量运行时若前序用例留下异常连接，先结束 pytest 后重新跑失败用例。

### `code=300 Server is unreachable`

先确认这是 SDK 返回的真实错误还是测试 Relay 的占位响应。错误用例应严格断言真实错误码和描述，不能为了通过而忽略响应。

## 9. 目录速查

```text
config/scenarios/   场景：账号、设备、SDK 版本、拓扑
config/api_matrix/  各版本 API 能力
config/artifacts.yaml  SDK 版本与 APK/flavor 的对应关系
im_flutter_test/    测试 App、Runner 和事件桥接
src/                WebSocket、断言和测试流程工具
tests/              按模块组织的 pytest 用例
```

常用检查：

```bash
git diff --check
```
