# HTTP 控制方案 grill-me 审查记录

- 日期：2026-11-04；状态：历史审查记录。用户已回答 Q1：人工／AI 二选一，不增加操作锁，干预按日志识别；Q2：接受独立脚本冷启动。随后设计改为工具自动编排并取消 AI 子代理，用户要求暂不使用 grill-me，待思路完成后再审查。下方决策树保留为旧草案的审查背景，不作为当前待答问题。
- 对象：[HTTP 控制协议草案](2026-11-04-phase-control.md)。本轮只更新文档，之前开发修改继续保留且不提交。
- 方法：用户显式调用 grill-me，入口转到 grilling；按规则使用独立只读子代理核实平台连接和执行生命周期，未启动设备、构建或读取凭据。

## 决策树

```text
已确定：HTTP 统一设备控制协议，人工 example 保持可用
├── 已确定：单设备整脚本、多脚本串行、多设备阶段协调共用执行能力
├── Q1：活动 AI 会话是否独占 SDK 操作权？
│   └── 推荐：人工只读观察，结束控制并核实状态后交还
├── Q2：独立脚本间是否默认完整冷启动？
│   └── 推荐：同脚本阶段保活，独立脚本重启 App、复用安装包
├── 已有规则：主代理核验日志、按依赖暂停、复验归因、保留正确预期
└── 草案：接口、命令结果、监听流程、日志与连接适配
```

若 Q1 允许人工并发，需要继续确定人工调用如何进入统一调度及证据链。若 Q2 允许同进程复用，需要继续确定初始化兼容、启动代次及状态清理。采用推荐答案时，按草案核对一致性并确认共同理解，不重新询问此前已确定的失败处理原则。

## 核实的事实与影响

| 事实 | 影响 |
|---|---|
| 双端 native 已初始化时直接返回成功并忽略新 options；Dart 先更新自身 options | 新 HTTP 会话和 logout 不代表 SDK 重置，需明确 Q2 |
| 人工页面仅有局部 running，registry logout／被踢事件未统一维护 SdkState | 需明确 Q1，状态接口不能仅返回 UI 快照 |
| LogStore 内存最多 2000 条，界面 clear 清同一列表；文件错误被吞掉，seq 每次 Dart 启动归零 | 独立证据缓冲、session 隔离、游标缺口与写入错误必须显式报告 |
| 旧 AutoMode init/login 失败后仍继续，无分类重试登录；Future timeout 不取消 native | 复用底层模块，不能把旧 run() 直接包装成 HTTP 路由 |
| SDK 监听在 init 后注册，并输出 listeners.registered | 区分 HTTP ready 与 watch.ready，login 同步必须先观察后触发 |
| sendMessage 先 await 发送再注册回调，固定 handler ID | 存在早到回调丢失／并发覆盖的源码风险，尚未设备复现；登记工具风险，不能直接归因 SDK |
| Android 调试 manifest 已有 INTERNET；Flutter 会向 iOS Debug 构建注入调试 Bonjour 和本地网络说明 | 根据实际路由及构建产物验证，不能只看源 plist 就机械增权限 |
| Flutter iOS simulator 转发直接使用设备端口，本机缓存有可运行的 iproxy | 模拟器可本机连接，iOS 真机 USB 仍需实际验证，不能声称无平台适配 |

源码入口：

- [Android ClientWrapper](../../im_flutter_sdk_android/android/src/main/java/com/easemob/im_flutter_sdk/ClientWrapper.java)、[iOS ClientWrapper](../../im_flutter_sdk_ios/ios/im_flutter_sdk_ios/Sources/im_flutter_sdk_ios/ClientWrapper.m)：init 已有 options 分支。
- [Dart ChatClient](../../im_flutter_sdk/lib/src/managers/chat_client.dart)、[人工初始化页](../../im_flutter_sdk/example/lib/pages/init_page.dart)、[SdkState](../../im_flutter_sdk/example/lib/sdk_state.dart)。
- [LogStore](../../im_flutter_sdk/example/lib/log/log_store.dart)、[旧自动执行器](../../im_flutter_sdk/example/lib/auto/auto_mode.dart)、[SDK 监听](../../im_flutter_sdk/example/lib/listeners.dart)、[消息 registry](../../im_flutter_sdk/example/lib/registry/apis/chat_apis.dart)。
- [Android Debug manifest](../../im_flutter_sdk/example/android/app/src/debug/AndroidManifest.xml)、[iOS 源 Info.plist](../../im_flutter_sdk/example/ios/Runner/Info.plist)。

平台资料：[Apple TN3179](https://developer.apple.com/documentation/technotes/tn3179-understanding-local-network-privacy) 明确入站 TCP 监听／接受连接不要求 Local Network privilege，出站 TCP、Bonjour 属于其他情况，Simulator 不支持本地网络隐私验证。[ATS](https://developer.apple.com/documentation/bundleresources/information-property-list/nsapptransportsecurity) 针对 URL Loading System 出站连接，不能为 Dart 入站服务机械添加全局 ATS 放行。当前本地 Flutter 的 xcode_backend.dart、simulators.dart、iproxy.dart 已核对，本轮未检查新构建产物或实际设备连通性。

## 审查出的失败路径

1. SDK 已发送消息但 HTTP 响应丢失：只查询原 ID，不换 ID 自动重发。
2. 新脚本更换同步 mask，native 未冷启动却返回 init 成功：不能据此认定新配置生效。
3. 回调被内存上限挤掉、界面清日志或宿主写盘失败：明确证据缺失，不能归为 SDK 未回调。
4. 阶段超时后 native 继续：禁止马上退出／切账号，保留迟到结果和首次失败。
5. App 崩溃：内存去重不跨进程保留，宿主已有证据保留，未知操作不自动重放。

以上为源码事实、风险与设计检查项，不是本轮复现的 SDK 缺陷。协议第 8 节列出后续实际验收要求。
