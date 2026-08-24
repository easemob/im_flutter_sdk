# WebSocket Bridge（与 Cases 通讯）

cases 与 im_flutter_sdk **均连接同一 WebSocket 服务**，通过该服务收发请求/响应。

默认连接：`ws://140.143.132.6:4000/iov/websocket/dual?topic=adc`。可通过 `start(topic: ...)` 自定义 topic，或通过 `start(url: ...)` 指定完整 URL。

## 使用方式（Flutter 侧）

1. 初始化 SDK 后连接桥接（例如在 `EMClient.getInstance.init(options)` 之后）：

```dart
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

// 使用默认地址连接（topic 默认为 adc）
await IMWebSocketBridge.instance.start();

// 自定义 topic（与 cases 端使用同一 topic 即可互通）
await IMWebSocketBridge.instance.start(topic: 'my_topic');

// 指定完整 URL
await IMWebSocketBridge.instance.start(
  url: 'ws://140.143.132.6:4000/iov/websocket/dual?topic=adc',
);
```

2. 断开连接：

```dart
await IMWebSocketBridge.instance.stop();
```

3. 常量（如需引用）：`kDefaultBridgeWebSocketBaseUrl`、`kDefaultBridgeWebSocketTopic`

## 请求格式（Cases → 服务 → im_flutter_sdk）

Cases 向同一 WebSocket 服务发送的 JSON 消息，会由服务转发到 im_flutter_sdk。格式例如：

```json
{
  "id": "req-1",
  "manager": "Client",
  "method": "login",
  "args": {
    "userId": "user1",
    "pwdOrToken": "password_or_token",
    "isPassword": true
  }
}
```

| 字段     | 类型   | 必填 | 说明 |
|----------|--------|------|------|
| id       | string | 否   | 请求 ID，原样带回响应，便于对账 |
| manager  | string | 是   | 管理器名称，见下表 |
| method   | string | 是   | 方法名，与 ChatMethodKeys 等一致 |
| args     | object | 否   | 方法参数，无参可省略或 `{}` |

### manager 取值

- `Client`：客户端（init、login、logout、createAccount 等）
- `ChatManager`：会话/消息
- `ContactManager`：联系人
- `GroupManager`：群组
- `ChatRoomManager`：聊天室
- `PushManager`：推送
- `UserInfoManager`：用户信息
- `PresenceManager`：在线状态
- `ChatThreadManager`：子区
- `ConversationManager`：会话对象上的操作
- `MessageManager`：消息相关

## 响应格式（im_flutter_sdk → 服务 → Cases）

成功：

```json
{
  "id": "req-1",
  "success": true,
  "result": { ... }
}
```

失败：

```json
{
  "id": "req-1",
  "success": false,
  "error": {
    "code": -1,
    "description": "错误描述"
  }
}
```

具体由服务如何按 topic/会话转发给 cases，以服务端实现为准。

## 示例（Python 端）

Cases 连接**同一地址、同一 topic**，发送请求并接收响应（需与后端约定的路由/订阅方式一致）：

```python
import asyncio
import json
import urllib.parse
import websockets

# 与 im_flutter_sdk 使用同一 WebSocket 服务；topic 需与 Flutter 端 start(topic='...') 一致
BASE = "ws://140.143.132.6:4000/iov/websocket/dual"
TOPIC = "adc"  # 可自定义，与 Flutter 端一致即可
BRIDGE_WS_URL = f"{BASE}?topic={urllib.parse.quote(TOPIC)}"

async def call_sdk():
    async with websockets.connect(BRIDGE_WS_URL) as ws:
        req = {
            "id": "1",
            "manager": "Client",
            "method": "login",
            "args": {"userId": "user1", "pwdOrToken": "pwd", "isPassword": True},
        }
        await ws.send(json.dumps(req))
        resp = json.loads(await ws.recv())
        print(resp)  # {"id": "1", "success": true, "result": {...}} 或 success: false + error
```

方法名与参数与 Flutter/Native 侧一致，可参考项目根目录下的 `PROJECT_STRUCTURE_AND_API.md` 中的 API 请求参数。
