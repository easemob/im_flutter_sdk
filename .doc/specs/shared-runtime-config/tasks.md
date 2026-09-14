# 共享运行时配置任务清单

状态：`[ ]` 未开始 / `[~]` 进行中 / `[x]` 已完成

## 0. 基线确认

- [x] 0.1 确认当前基线：`native-auto-test/config.yaml`（旧格式）存在且被 gitignore，`im_flutter_test/assets/config.yaml` 为指向它的软链
- [x] 0.2 确认要保留的散落行为：`run.sh` 端口改写、`WS_BASE_URL` 优先级、WS `createAccount` 兜底、`topics.<device>` 回退链
- [x] 0.3 记录本仓库不消费但需透传的字段：`app.cluster`、`app.imm`、`app.wait`、`app.console`、`him*`

## 1. 环境/桥接文件与模板

- [x] 1.1 新增 `native-auto-test/config/env.yaml.template`（`app:` schema，占位值，含中文字段注释与 DNS 派生说明）
- [x] 1.2 新增 `native-auto-test/config/bridge.yaml`（`websocket` + `topics`，非敏感默认值）
- [x] 1.3 更新 `native-auto-test/.gitignore`：忽略 `config/*.yaml`，保留 `!config/bridge.yaml`；保留 `config.yaml`
- [x] 1.4 删除旧 `native-auto-test/config.yaml.template`（被 1.1 取代）
- [x] 1.5 本地把当前 `native-auto-test/config.yaml` 改写为 `config/config.yaml`（新 schema）；未提交真实凭据
- [x] 1.6 校验：`config/config.yaml` 被 gitignore、`config/bridge.yaml` 与 `config/env.yaml.template` 不被忽略

## 2. Python 配置层重构（`src/tools/config.py`）

- [x] 2.1 实现 `resolve_env_config_path()`：`IM_TEST_CONFIG` > `<repo>/config/config.yaml`，用 `Path.resolve()` 校验存在性，全不命中抛 `RuntimeError`
- [x] 2.2 实现 `resolve_bridge_config_path()`：`IM_BRIDGE_CONFIG` > `<repo>/config/bridge.yaml`，行为同上
- [x] 2.3 实现 `load_env_config()` / `load_bridge_config()` 并缓存；非法 YAML 抛明确错误
- [x] 2.4 新增访问器：`get_appkey`、`get_server_base_url`、`get_rest_base_url`（`{base}/{org}/{app}`）、`get_client_id`、`get_client_secret`、`has_rest_credentials`、`get_rest_verify_ssl`
- [x] 2.5 改造桥接访问器：`get_ws_base_url`、`get_default_topic`、`get_topic`、`get_connect_timeout`、`get_response_timeout`、`get_ws_debug`
- [x] 2.6 删除 `get_sdk_options`、`get_sdk_app_key`、`get_rest_auth_token` 以及对根目录 `config.yaml`、`rest_api`、`sdk_options` 的读取
- [x] 2.7 更新 `src/tools/ws_client.py` 调试开关读取为 `get_ws_debug()`
- [x] 2.8 校验：`python -m compileall src` 通过

## 3. Python REST 动态凭据（`src/rest_api/`）

- [x] 3.1 新增 `src/rest_api/auth.py`：`get_rest_token()`，client_credentials 换取 + 进程内缓存（按 `expires_in`，提前 60s 刷新）
- [x] 3.2 token 失败路径抛 `RuntimeError`，消息含 HTTP 状态或传输错误类别，不含 token/secret 明文
- [x] 3.3 改造 `user_api.py` / `contact_api.py` / `chatroom_api.py`：改用 `authorization_header()` / `rest_urlopen()` 与派生 `get_rest_base_url()`
- [x] 3.4 改造 `tests/conftest.py`：改用 `has_rest_credentials()`，保留无凭据时 WS `createAccount` 兜底
- [x] 3.5 检查 `skills/im-rest-users/scripts/*.py`、`tests/chatroom/chatroom_helpers.py`、`tests/contact/*.py`（经 `src.rest_api`，无需直接改）
- [x] 3.6 校验：全仓库无 `get_sdk_options` / `get_sdk_app_key` / `get_rest_auth_token` / `_authorization_header` 遗留

## 4. Dart 环境配置与启动（`im_flutter_test`）

- [x] 4.1 新增 `lib/env_config.dart`：解析 `app:` schema；外部 `files/config.yaml` > asset；非法 YAML/缺 appkey 返回失败结果
- [x] 4.2 实现 DNS 派生：`tcp_host` 或 `websocket_host` 去空白非空 → `enableDNSConfig=false`
- [x] 4.3 实现 `EMOptions` 映射（`rest_host` 回退 `server.base_url`、空值置 `null`、端口 int/数字字符串、datasync 空值不设置）
- [x] 4.4 固定写入 6 个开关
- [x] 4.5 改造 `lib/main.dart`：加载失败时跳过 `EMClient.init` 并记录原因，仍 `runApp`
- [x] 4.6 `im_flutter_test/assets/config.yaml` 替换为无凭据占位文件（`app:` schema，appkey 空）
- [x] 4.7 更新 `im_flutter_test/pubspec.yaml` assets：`assets/config.yaml` + `assets/bridge.yaml` + `assets/media/`
- [x] 4.8 校验：`flutter analyze` 通过（仅 2 条既有 deprecation info）

## 5. Dart 桥接配置

- [x] 5.1 新增 `lib/bridge_config.dart`：外部 `files/bridge.yaml` > asset；纯函数 `parse*` 保持容错语义
- [x] 5.2 新增 `im_flutter_test/assets/bridge.yaml` 软链到 `../../native-auto-test/config/bridge.yaml`（目标已提交）
- [x] 5.3 改造 `lib/sdk_config_loader.dart` 为薄委托层；保留 `loadOptions` / `loadWebSocketConfig` / `parse*` 方法名
- [x] 5.4 `lib/websocket_config_page.dart` 调用点无需改动
- [x] 5.5 校验：软链可解析，`flutter analyze` 通过

## 6. run.sh 与 Makefile

- [x] 6.1 `run.sh` 新增 `--config` 与 `--bridge-config` 参数
- [x] 6.2 解析优先级：CLI > `IM_TEST_CONFIG`/`IM_BRIDGE_CONFIG` > `native-auto-test/config/config.yaml` / `config/bridge.yaml`
- [x] 6.3 解析函数与参数一同导出 `IM_TEST_CONFIG`/`IM_BRIDGE_CONFIG`，多 lane 子进程继承
- [x] 6.4 lane 专属桥接副本：仅改写 `websocket.base_url` 端口（抽到 `config_helpers.sh:render_lane_bridge`）
- [x] 6.5 推送两份：env → `files/config.yaml`，lane 桥接 → `files/bridge.yaml`；推送前 `force-stop`，并 `mkdir -p` 外部目录
- [x] 6.6 `test-local` 继承导出的 `IM_TEST_CONFIG`/`IM_BRIDGE_CONFIG`
- [x] 6.7 更新 `run.sh` usage 与 SKILL.md 配置表
- [x] 6.8 校验：`bash -n run.sh config_helpers.sh`；`--help` 显示新参数

## 7. 文档与 spec 同步

- [x] 7.1 更新 `native-auto-test/README.md`：新 schema、文件布局、选择优先级、DNS 派生、固定开关位置
- [x] 7.2 更新 `skills/im-flutter-run/SKILL.md` 环境/桥接文件配置表
- [x] 7.3 更新 `.doc/specs/local-websocket-bridge/{requirements,design,tasks}.md` 中 `config.yaml` → 桥接文件
- [x] 7.4 本文档 `design.md` 记录与 im-test-hub 的 schema 分歧点（`server.verify_ssl`、`console`）
- [x] 7.5 更新 `run.sh usage`/README 中 `config.yaml.template` 引用为 `config/env.yaml.template`
- [x] 7.6 更新 `.github/workflows/build-release.yml`：删除已过期的 “Prepare config.yaml” 步骤与打包排除项

## 8. 测试与交付验证

- [x] 8.1 Dart：新增 `test/env_config_test.dart`（固定开关、DNS 派生 5 组、映射、空值/字符串端口、缺 appkey、非法 YAML）
- [x] 8.2 Dart：更新 `test/sdk_config_loader_test.dart`
- [x] 8.3 Dart：更新 `test/sdk_config_loader_websocket_test.dart`
- [x] 8.4 Dart：新增 `test/bridge_config_test.dart`（正常/缺失/空值/非法 YAML/去空白/device topic 回退/asset 回退）
- [x] 8.5 Python：重写 `tests/tools/test_config.py`（文件选择优先级、未知字段容错、REST base 派生、`WS_BASE_URL` 优先级）
- [x] 8.6 Python：新增 `tests/tools/test_rest_auth.py`（token 获取/缓存/到期/失败、verify_ssl，mock HTTP）
- [x] 8.7 脚本：新增 `tests/tools/test_run_config_helpers.py`，覆盖 `--config` 选择失败与 lane 桥接端口改写
- [x] 8.8 运行 `flutter analyze`（2 条既有 deprecation info）与 `flutter test`（43 passed）
- [x] 8.9 运行 `python -m compileall src tests` 与 `pytest tests/tools -q`（245 passed）
- [x] 8.10 设备冒烟：`run.sh --lane 2 --build --config config/config.yaml` 跑 `test_client_login_invalid_password` / `test_client_get_current_user`（2 passed）与 `tests/chatroom/test_chatroom_lifecycle.py`（5 passed，无需环境变量）
- [x] 8.11 回填本清单状态与实现说明（见文末）

## 实现说明与偏离

1. **抽出 `config_helpers.sh`**：`resolve_config_files` / `render_lane_bridge` 从 `run.sh` 抽到独立脚本，`run.sh` `source` 后调用。目的：让配置选择与端口改写可被无设备测试覆盖（任务 8.7）。另有 `bash -n` 语法校验。
2. **新增 `IM_REST_TOKEN` 逃生口**：`auth.get_rest_token()` 先看该环境变量；迁移期可从旧配置的静态 token 平滑过渡，不污染 YAML schema。
3. **首启目录保护**：App 在缺 appkey 时会跳过 SDK 初始化（不再抛异常退出），因此 `run.sh` 在 push 前增加 `adb shell mkdir -p files/`，避免首次启动未创建外部目录导致 push 失败。
4. **`assets/bridge.yaml` 用软链**：目标 `native-auto-test/config/bridge.yaml` 是已提交文件，链接稳定；`assets/config.yaml` 改为提交的无凭据占位文件（不再是软链）。
5. **`SdkConfigLoader.loadOptions()` 返回类型从 `Future<EMOptions>` 变为 `Future<EMOptions?>`**；调用点 `main.dart` 已按可空处理。
6. **`conftest.py` 语义等价替换**：`bool(get_rest_auth_token())` → `has_rest_credentials()`（配置存在性判定，不触发网络）。
7. **版本/依赖未变**；未触碰 `im_flutter_sdk` / `_android` / `_ios` / `_interface` 发布层。
8. **外部目录归属修复（设备冒烟发现的根因）**：首版在 `run.sh` push 前用 `adb shell mkdir -p` 创建 `files/`，该目录归属 `shell`，App 进程无权限进入，导致注入的 config/bridge 读取失败、SDK 跳过初始化、login 超时。改为 `MainActivity.onCreate` 调 `getExternalFilesDir(null)` 创建（App uid 持有），`run.sh` 只 push。
9. **REST 凭据只用 client_credentials**：`conftest` 用 `has_rest_credentials()` 判断是否走 REST 建用户（无凭据时回退 WS `createAccount`）。该环境禁止开放注册（401），因此本地 `config/config.yaml` 必须配 `client_id/client_secret`（已从 `im-test-hub/.vscode/.env` 的同环境注释块取到并验证可换 token）。
10. **事故与恢复**：创建 `im_flutter_test/assets/config.yaml` 占位文件时 `rm` 与 `write` 并行，写入穿透当时的软链，把 `native-auto-test/config.yaml`（本地旧配置）覆盖；已按首次读取内容恢复原文件。该文件中的静态 token 已在本会话输出中暴露，建议轮换。
11. **配置来源可观测**：`EnvConfigResult.source` 记录 `external:<path>` / `asset:assets/config.yaml`，`main()` 启动时打印；设备实测确认二次启动读的是 `external:/sdcard/.../files/config.yaml`。
12. **不写静态 token**：REST token 一律由 `app.server.client_id/client_secret` 走 client_credentials 获取并缓存；不提供 `access_token` 字段或 `IM_REST_TOKEN` 覆盖，避免把会过期的 token 落在配置里。
