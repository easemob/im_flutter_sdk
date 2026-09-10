# release APK 测试自动化

> 下方原始需求保留为历史阶段记录。当前 APK 获取流程以「Release APK 缓存增量需求」为准；ADB 防护以「ADB mDNS 崩溃防护增量」为准。历史的双 APK、编译期设备标识、配置修改需重建等描述不作为当前增量验收依据。

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
- GitHub Release 发布 APK 与远程机器/Docker 运行不在原始阶段范围内。本次仅纳入已发布 APK 的查询、下载与缓存，不改变发布流程。

## Release APK 缓存增量需求

### 当前基线与范围

- 当前 `run.sh` 默认下载 latest Release 的单个 `app-release.apk`，`--build` 使用本地构建；同一个 APK 用于所有设备，设备标识通过启动 intent 传入。
- 当前本地 `config.yaml` 在运行时推送，修改已支持配置项的值不需要重新构建 APK。
- 当前脚本每次无条件下载覆盖临时 APK，结束时不删除该文件；设备端每次安装前执行卸载。
- 本次只修改测试运行工具、对应工具测试及使用文档，不修改 SDK、测试 App、Release 发布工作流或业务用例。
- 本次仅编写 spec；实现、测试与交付状态在 `tasks.md` 中单独标注。

### User Stories

- 作为日常运行 E2E 用例的维护者，我希望每次确认远端 Release 附件是否变化，仅在变化或本地缓存不可用时下载，从而缩短启动时间而不无意中测试旧 SDK。
- 作为排障人员，我希望通过 `--refresh-apk` 强制重新下载当前远端附件，同时保留本地构建和显式指定 APK 的能力。
- 作为测试维护者，我希望 APK 文件缓存与设备用户数据隔离，复用安装包时仍执行原有卸载重装和运行时配置注入流程。

### Acceptance Criteria（EARS）

- C1：当默认远端下载模式启动时，系统应查询指定仓库的 latest Release 元数据，唯一选取已上传完成的 `app-release.apk`；不得仅凭本地文件存在就继续测试。
- C2：当远端仓库、Release ID、附件 ID、附件更新时间、附件大小及可用的 digest 与缓存记录一致，且本地文件大小和 SHA-256 校验通过时，系统应复用缓存而不下载 APK 正文。
- C3：当缓存缺失、元数据损坏、文件校验失败或远端标识变化时，系统应下载所查询附件的确定版本，不得再次使用可变的 latest 下载地址导致查询与下载指向不同版本。
- C4：当用户指定 `--refresh-apk` 时，系统应查询当前远端附件并重新下载，即使缓存有效也不得跳过下载。
- C5：当查询失败、限流、latest Release 不存在、目标附件缺失/不唯一或元数据非法时，系统应明确报错并非零退出，不得回退旧缓存继续测试。
- C6：当下载超时、中断或文件校验失败时，系统应非零退出，不得安装部分文件；原有有效缓存应保留，但本次不得使用它继续测试。
- C7：当下载成功且大小及可用的远端 SHA-256 digest 校验通过时，系统应记录本地 SHA-256，并以原子发布方式保存 APK 与元数据；只有完整缓存可供后续复用。
- C8：当指定不同 `--repo` 时，系统应隔离不同仓库缓存；同一仓库同一附件的并发读写不得暴露未完成的缓存。
- C9：当使用多 lane 模式时，外层应只查询一次并最多下载一次，再向各子 lane 传递确定的 APK；子 lane 不得重复查询远端或下载。
- C10：当使用 `--build` 或显式有效 `APK_PATH` 时，系统应绕过远端查询与缓存，并在单/多 lane 中保持一致；当它们与 `--refresh-apk` 同时出现时，系统应在环境准备前报参数冲突。显式无效 `APK_PATH` 应报错，不得偷偷改用远端包；`APK_PATH` 与 `--build` 同时出现时也应报冲突。
- C11：当缓存命中或下载更新时，系统应输出仓库、Release tag、附件 ID、缓存命中/刷新原因和使用路径；不得输出认证信息。
- C12：当复用缓存 APK 时，系统应继续执行原有设备端卸载、安装、配置推送及测试流程，不得改成保留用户数据的覆盖安装。
- C13：当验证本功能时，自动化测试应在无真实 GitHub、模拟器及 IM 服务的条件下覆盖 C1–C12 的关键正常和失败路径。

### 认证查询增量（用户已确认）

作为测试维护者，我希望使用已导出的 GitHub token 查询公开 Release，避免匿名限流，并安全定位认证和网络错误。

- C14：当非空 `GH_TOKEN` 存在时，API 查询应使用它，否则使用非空 `GITHUB_TOKEN`；均未设置时应匿名查询。
- C15：当使用 token 时，系统应只通过标准输入向 API 查询传递认证头，不在进程参数、子进程环境、文件、缓存或日志中暴露 token；APK 下载不得携带该认证头。
- C16：当 API 返回 401、403/429 或其他 HTTP 错误时，系统应显示 HTTP 状态与可用的安全限流字段；401 提示认证无效，限流提示恢复时间；网络与非法 JSON 应分别提示。任何失败均不得回退旧缓存。
- C17：当 token 包含换行或控制字符时，系统应在发出请求前拒绝，且不得回显 token；自动化测试应覆盖 token 优先级、匿名模式、诊断和不泄露边界。

### 非目标与数据边界

- 不新增离线自动回退、固定 tag 选择器、缓存自动淘汰或跳过安装开关。
- 不承诺在查询完成后阻止远端发布新版本；本次运行使用该次查询确认的附件快照，下次运行重新查询。
- APK 缓存只保存电脑上的安装包和元数据，不保存设备登录态、SDK 数据库或测试账号数据。
- 保持现有卸载行为，不在本次添加「卸载后确认包不存在」检查。现有卸载失败被忽略的风险仍存在，不宣称保证所有卸载成功。
- 服务端历史数据以及 Android 公共共享目录清理不在本次范围内。

## ADB mDNS 崩溃防护增量

### User Story

作为在不同机器安装 `im-flutter-run` 的维护者，我希望 skill 自身关闭并验证 ADB mDNS，而不依赖单机 shell 配置，避免 OpenScreen `dns_data_graph.cc` 致命断言中断全部 lane 的 reverse 控制通道。

### Acceptance Criteria（EARS）

- M1：当执行 `run.sh` 时，系统应为完整子进程树强制导出 `ADB_MDNS=0`，覆盖调用者传入的 `1`；不得修改其他机器的全局配置。
- M2：当单/多 lane 完成 Android 工具准备时，系统应在获取 APK、启动模拟器前以禁用环境启动/复用 ADB；仅当 `server-status` 成功且唯一的 `mdns_enabled` 字段为 `false` 时继续。
- M3：当已有共享 ADB 启用了 mDNS 时，系统应非零退出并给出所选 adb 的人工重启命令，不自动执行 `kill-server`，不启动设备测试。
- M4：当启动或状态查询失败、超时、字段缺失/重复或状态无法确认时，系统应非零退出；每次探测最多等待 10 秒，不打印原始状态/错误中的潜在敏感内容。
- M5：当多 lane 运行时，外层应在派发前完成预检，每个 lane 应再次验证真实 server 状态，不信任继承的“已检查”标记，不重启共享 server。
- M6：当每个 lane 即将执行 pytest 时，应再次验证 mDNS 状态；失败时不得调用 `make test-local`，并沿用该 lane 的资源清理。
- M7：当验证该增量时，应以 fake adb 覆盖安全启动/复用、已启用、未知状态、失败/超时、环境覆盖、单/多 lane、pytest 前状态变化；不得访问业务账号。
- M8：当安装或使用 skill 时，文档应说明完整 scripts 目录、防护与一次性重启方法；该增量只阻断已定位的 mDNS 路径，不承诺恢复外部强杀 ADB、其他崩溃或网络故障。
