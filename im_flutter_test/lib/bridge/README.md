# Test Runner Bridge

`im_flutter_test` 是测试专用 Runner，不依赖正式 `im_flutter_sdk`。
请求通过统一 JSON 协议进入 Dart，再经 `im_flutter_sdk_interface`
路由到当前构建版本的原生 Adapter / Wrapper。

```text
native-auto-test
→ WebSocket JSON
→ InterfaceRouter
→ im_flutter_sdk_interface
→ Android NativeSdkBridge
→ sdk410 / sdk414 SdkVersionAdapter
→ 对应版本真实原生 SDK
```

## 请求

```json
{
  "id": "req-1",
  "manager": "ContactManager",
  "cmd": "addContact",
  "info": {
    "userId": "user2",
    "reason": "hello"
  },
  "device": "deviceA"
}
```

- `manager` 决定 interface Manager。
- `cmd` 是该 Manager 的原生方法名。
- `info` 只包含 JSON/Map 可编码参数。
- `id`、`sequence` 和 `device` 原样带回响应。

普通新增 API 不在 Dart 写版本分支。Python Capability Matrix 先判断是否
支持，Android 版本差异由 flavor 下的 `SdkVersionAdapterImpl` 处理。

## 响应和事件

成功响应沿用现有 case 协议：

```json
{
  "id": "req-1",
  "manager": "ContactManager",
  "cmd": "addContact",
  "device": "deviceA",
  "result": "user2"
}
```

原生事件由 `EventRouter` 转成：

```json
{
  "type": "event",
  "eventType": "onContactInvited",
  "data": {
    "userId": "user1",
    "reason": "hello"
  }
}
```

## Runner Hello

Runner 周期上报 `runnerHello`，至少包含：

- `runnerId`
- `deviceName`
- `platform`
- `sdkVersion`
- `appVersion`
- `capabilities`

Python 在执行业务调用前校验这些字段，版本或角色不匹配时按环境错误
终止，不能继续执行或转为 Skip。

## WebSocket

单独运行时可继续使用 `config.yaml` 中的远端 relay。第一阶段矩阵脚本
默认启动本地 relay，并为每台 Android 自动配置 `adb reverse`：

```bash
cd native-auto-test
python scripts/run_phase1_matrix.py
```

如需使用已有远端服务：

```bash
python scripts/run_phase1_matrix.py --external-relay
```
