# 发送 ACK 超时只读取证

## 范围

用户允许跳过 spec。仅修改用例诊断；未重跑设备测试、修改 SDK/远端配置、启用 trace、发布或部署。工作区原有改动保留。

## 已有记录

`/tmp/logcat-5562.txt`：1743 首次发送，1751 在 10.001 秒后 ACK 等待超时，1754 进入第二次重试，1786 未连接导致发送失败，1830 重试耗尽，1836 通用 JNI onError，1838 更新该消息数据库，1916 收到成功 SYNC ACK，1919 更换消息 ID。

关联 ID：
- meta_id: 178901934746830751
- first trace: 7503691006945001484
- retry trace: 7503691048896430093
- server_id: 1595387809210827269

不能因 onError 夹在 TCP 日志中就认定它是连接回调，也不能根据仅过滤 success 的 seen=[] 认定没有 error。原生错误回调是否到达 Python 尚缺事件原始记录。BEACON-LOSS 成功失败窗口均每分钟 7–8 次，不构成异常定位证据。

## 原生版本与时序

保存的 `/tmp/im-flutter-run-lane2.apk` 与当前本地 `im_flutter_sdk_android/android/libs/easemob-sdk/libs/` 原生库不同：

| ABI | 缓存 APK Build ID | 当前本地 Build ID |
|---|---|---|
| arm64-v8a | e66c3fa03f402bf25288f9e3b6a9bce125c81d88 | cc4aec27091e72a7009681f884c4bd99e78e10eb |
| x86_64 | c0197ebcb6f77ea0e200354d70a43acf58caebbb | 23415f7408fa4b636ac79887f359a459cae4049b |

继续核对 `/tmp/diag-run2.log:16`：失败运行使用 release `v1.2.0-e2e-automation`、asset `552367681` 的缓存 `app-release.apk`。该缓存包 arm64 库 SHA256 为 `5bb094dd913eff9959e71c0a3ba15b34496ec4d8948bcdc32ff5a42eeaeb4e01`，与 `/tmp/im-flutter-run-lane2.apk` 中库一致。因此已建立失败运行日志→缓存 release asset→上述库的关联；仍缺 release 对应的原生源码提交。模拟器启动记录为 arm64-v8a。

本机 `/Users/kk/Desktop/emclient-linux` 当前版本 4.24.2：
- `src/emchatmanager.cpp:79`：ACK 等待 10000ms。
- `src/emchatmanager.cpp:2038–2140`：ACK 超时重连，连接变化取消等待会消耗重试；耗尽后仍 DELIVERING 则设 FAIL 并调用 callbackError。
- `src/android/emacallback.cpp:40`：通用 C++→Java onError，不是 TCP 专属。
- `src/emsessionmanager.cpp:163,2093–2126`：复用 mConnectionSem；notifyConnectResult 设置取消结果，waitConnectToServer 根据返回 flag 判断连接结果。
- `src/emsemaphoretracker.cpp:50–73`：mResult 不是 INVALID 时立即返回已有结果，wait 不重置；`cancel` 保留 flag/result。

具体嫌疑：复用信号量返回旧连接结果，让发送线程误以为重连已完成，立即重试，随后真实断连取消消息等待并耗尽预算。这与日志时序兼容，但不是对失败二进制的最终定性。

离线验证：临时 C++ 程序直接编译当前生产 `src/emsemaphoretracker.cpp`（非复制实现），执行首次 wait → cancel(42) → 再次 wait(1000ms)。实际输出 `result=2 flag=42 elapsed_ms=0 requested_ms=1000`，确认该原语会立即返回保留结果。探针在临时目录运行后自动清理，未启动 SDK/设备或服务连接。这个测试仅证明原语行为，不是整个重连问题的复现。

失败包动态符号表未暴露所需 wait/connect 函数，暂无法通过这些符号直接反汇编定位。

版本 4.23 升级提交 `e065b6a52` 也存在发送失败收尾和通用 JNI 日志。`0eb570a82` 仅将 CONNECT_TIMEOUT 从 10 秒改为 20 秒，并未修改 SEND_MSG_TIMEOUT，也不解决立即返回旧结果的问题。未修改原生源码。

## 服务端搜索

显式 context `tke-sdb`，没有切换全局 context。仅执行 get/logs/文件目录只读查询。

对以下当前容器 stdout，自 `2026-09-10T05:55:00Z` 起（单容器 30MB 上限）同时搜索两个 trace 和 server_id：
- easemob-sandbox/msync-gateway-0..3
- im-core-rt-flow/im-core-rt-flow-taskmanager-1-1、1-2
- im-core-rt-flow-green/im-core-rt-flow-green-taskmanager-1-1、1-2
- im-flink/im-msg-up-flow-taskmanager-1-1

命令全部成功，但没有匹配。返回输出约 0.7KB–156KB，未触及 30MB 限制。gateway-0 `/data/apps/log/gateway` 目录未列出文件。该结果不覆盖日志平台归档、已轮转历史日志、之前容器和所有可能路由，不能据此认定请求未到达。

注意：模拟器时钟与 ACK 中服务端 timestamp 存在偏移，不应直接拿模拟器 13:49 当服务端时间。gateway 当前启动时间集中在 05:55–05:59 UTC；部署时间邻近服务端处理窗口值得关联，但不能直接推断部署导致超时。

### 归档日志补查

从现有 Fluent Bit ConfigMap 确認输出到 Elasticsearch 的 msync-logs/flink-logs/go-logs 索引。主机直连不可达，通过已有 rest2 容器中的 curl 执行只读 `_search`，未创建文件、代理或修改配置。

- 三个关联 ID 在上述保留索引内跨全部时间查询：0 命中。
- 05:45–06:15 UTC 窗口覆盖检查：5115 条记录，全部属于 `go-logs-2026.09.10`；无 msync/flink 窗口记录。
- 因此归档中没有本次所需 msync/flink 证据，不是证明服务端未收到消息。未查询/修改 Secret，未启用额外日志。

## 后续所需证据

1. 失败进程 APK/原生库 Build ID 对应的源码提交或符号文件，以验证连接信号量旧结果假设。
2. 日志平台归档按上列关联 ID 查 gateway 接入、Flink JOIN、ACK 写出及连接迁移记录；不能仅查询某个当前 Pod 后宣告服务端无问题。
3. 若历史证据不可得，经用户另行确认后单次联合取证：目标消息 success/error、原生等待结果及连接代次、客户端抓包与服务端 trace；不自动重发或放宽成功条件。
