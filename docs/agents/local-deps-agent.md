# Local Deps Agent（本地依赖更新与构建）

- 职责
  - 以“本地资产”为主进行版本更新与构建（Android jar/so；iOS xcframework），并确保目录不带版本号
- 必用技能
  - using-superpowers、speckit
- 输入参数
  - ANDROID_JAR（例 hyphenatechat_4.20.0.jar）
  - ANDROID_LIBS_DIR（默认 android/libs/easemob-sdk/libs）
  - RENAME_DIR（是否将 `easemob-sdk-<ver>` 重命名为 `easemob-sdk`）
- 步骤
  1) 按 docs/specs/dependency-spec.md 放置本地资产；必要时用脚本做规范化（dry-run/--apply）
  2) speckit.sh check → android → ios → ios-build
- 验收标准
  - 目录名不带版本、jar 存在、仅启用一种依赖；两端构建成功

- 脚本
  - `im_flutter_sdk/scripts/agents/local_deps_agent.sh --jar hyphenatechat_4.20.0.jar --rename-dir --apply`
