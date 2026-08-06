# Native IM 自动化数据流
用于多平台多设备多版本的原生IM sdk自动化测试框架
使用 Python 编写统一测试用例，通过 WebSocket 将请求发送到设备上的 Flutter Runner。Runner 根据 Manager 选择对应的 MethodChannel，将请求交给平台 Wrapper；Wrapper 把通用数据转换为原生 SDK 对象，并调用原生 SDK。
调用结果通过 MethodChannel Future 返回，异步回调通过 Channel Handler 接收，再统一转换为 JSON 传回 Python，由测试用例完成断言。

                                         REQUEST

Python Case ─────→ Managed WS ─────→ Flutter Runner ─────→ MethodChannel ─────→ Java Wrapper ─────→ Android SDK
   call()            runnerId 路由        jsonDecode()          invokeMethod()         onMethodCall()         EMClient API
   _send_queue       转发目标 Runner      InterfaceRouter       JSONMethodCodec        MessageHelper      执行原生操作


数据类型：

Python dict ─────→ JSON text ─────→ Dart Map ─────→ 平台基础数据对象 ─────→ EMMessage
{manager,cmd,info}   json.dumps()       manager/cmd/info        Android: JSONObject      Android SDK 对象
requestId

消息队列：

1. _send_queue
   保存待发送的请求
   call() → _send_queue → WebSocket

2. resp_q
   每次 call() 单独创建
   Response 根据 requestId 进入对应 resp_q

3. _recv_queue
   保存 Runner 返回的异步 Event

4. _event_buffer
   暂存当前不匹配的 Event，供后续继续查找

关键职责：

Python Case
- 构造请求并放入 `_send_queue`
- 通过 `requestId` 等待对应响应

Managed WS
- 根据 `runnerId` 转发到目标 Runner
- 保存 `requestId` 与 Python Controller 的对应关系

Flutter Runner
- 将 JSON text 解析为 Dart Map
- 根据 `manager / cmd` 路由到对应 Channel

MethodChannel
- 使用 `JSONMethodCodec` 完成跨语言数据转换
- Dart Map → Android JSONObject

Java Wrapper
- 接收 `onMethodCall()`
- JSONObject → EMMessage
- 调用 Android 原生 SDK


返回机制：

Response：
Java `result.success()`
→ Dart `invokeMethod()` Future
→ Managed WS
→ `requestId`
→ `resp_q`
→ `call()` 返回

Event：
Android SDK Callback
→ Java `channel.invokeMethod()`
→ Dart Channel Handler
→ Managed WS
→ `_recv_queue`
→ `receive_message()`

未匹配 Event：
`_recv_queue` → `_event_buffer`
```


 REQUEST

Python Case ── call() ──→ Managed WS ── JSON text ──→ Flutter Runner ── MethodChannel ──→ Java Wrapper ──→ Android SDK
 Python dict               json.dumps()                jsonDecode()       invokeMethod()      onMethodCall()      EMClient API                                                - invokeMethod Future：接收 Response
                                                              - Channel Handler：接收 Event
 {manager,cmd,info}        runnerId 路由               Dart Map           JSONMethodCodec     JSONObject         EMMessage
 _send_queue               转发目标 Runner             InterfaceRouter                              ↓
 requestId                 保存请求来源                manager/cmd 路由                      MessageHelper.fromJson()


                                    RESPONSE

Python Case ←── Managed WS ←── JSON text ←── Flutter Runner ←── MethodChannel ←── Java Wrapper ←── Android SDK
 Python dict      requestId 路由      jsonEncode()       Dart Map           Future 返回         Java Map           API Result
 json.loads()     返回原调用方        type=response      await invokeMethod  result.success()    MessageHelper.toJson()
      │
      └── requestId 匹配 → resp_q → call() 返回


                                      EVENT

Python Case ←── Managed WS ←── JSON text ←── Flutter Runner ←── MethodChannel ←── Java Wrapper ←── Android SDK
 Python dict      按 runnerId 广播    jsonEncode()       EventRouter        Handler 回调        Java Map           SDK Callback
 json.loads()                         type=event          setMethodCallHandler channel.invokeMethod() EMMessage → Map
      │
      └── _recv_queue → receive_message()
                         └── 不匹配 → _event_buffer
数据类型变化

Request:
Python dict → JSON String → Dart Map → Java JSONObject → EMMessage

Response:
Result / EMMessage → Java Map → Dart Map → JSON String → Python dict

Event:
SDK Callback / EMMessage → Java Map → Dart Map → JSON String → Python dict
关键区别

Response：
Java result.success()
→ 返回原 Dart invokeMethod() 的 Future
→ requestId 匹配后进入 resp_q

Event：
Java channel.invokeMethod()
→ 进入 Dart setMethodCallHandler()
→ 进入 _recv_queue / _event_buffer



```text
                                      REQUEST

Python Case ──call()──→ Managed WS ──JSON text──→ Flutter Runner ──MethodChannel──→ Java Wrapper ──→ Android SDK
 Python dict              json.dumps()             jsonDecode()        Dart Map          JSONObject → EMMessage
 {manager,cmd,info}       runId/runnerId           targetRunnerId      manager/cmd       MessageHelper.fromJson()


                                  RESPONSE / EVENT

Python Case ←── Managed WS ←── Flutter Runner ←── MethodChannel ←── Java Wrapper ←── Android SDK
 Python dict      JSON text       Dart Map          result / event     Java Map/EMMessage

Response → result.success()
         → Dart Future<dynamic>
         → ResponseNormalizer
         → jsonEncode()
         → Managed WS
         → recv_loop
         → resp_q
         → call() 返回

Event    → SDK callback
         → Wrapper.invokeMethod()
         → Dart EventRouter
         → jsonEncode(type=event)
         → Managed WS
         → recv_loop
         → _recv_queue
         → _event_buffer
         → receive_message()
```

> iOS/Web 只需要把 `Java Wrapper` 换成对应平台 Wrapper，整体协议和 WebSocket 链路不变。

## 请求方向：Python 到原生 SDK

### 1. Python Case 生成请求

Case 调用：

```python
device_a.call(
    "ChatManager",
    "sendMessage",
    info={"message": {...}},
)
```

`DeviceConnection.call()` 会补充：

```json
{
  "type": "request",
  "manager": "ChatManager",
  "cmd": "sendMessage",
  "info": {},
  "id": "请求唯一 ID",
  "sequence": 1,
  "requestId": "请求唯一 ID",
  "runId": "本次 pytest session",
  "targetRunnerId": "目标设备 Runner",
  "device": "deviceA"
}
```

然后 Python 使用 `json.dumps()` 把 dict 编码成 WebSocket 文本。

### 2. Managed WebSocket 路由

Managed WebSocket 会解析 JSON，根据：

```text
runId + targetRunnerId
```

把请求转发给对应的 Flutter Runner。多设备共用一个 WebSocket 服务，但每个 Runner 有自己的 `runnerId`。

### 3. Flutter Runner 解码和分发

`IMWebSocketBridge` 收到 WebSocket 文本后执行：

```dart
final decoded = jsonDecode(text);
final request = Map<String, dynamic>.from(decoded);
```

此时：

```text
JSON 字符串 → Dart Map<String, dynamic>
```

Runner 校验目标 `runnerId` 后，将：

```text
manager → InterfaceRouter 选择 Manager
cmd     → 选择 Manager 内的方法
info    → 业务参数
```

### 4. MethodChannel 到 Wrapper

例如：

```text
ChatChannel.invokeMethod("sendMessage", info)
```

`JSONMethodCodec` 负责 Flutter 与原生之间的参数编码。Android Wrapper 收到 `JSONObject` 后：

```java
EMMessage msg = MessageHelper.fromJson(params);
```

即：

```text
原生 JSONObject / Map → EMMessage
```

最后调用 Android SDK：

```java
EMClient.getInstance().chatManager().sendMessage(msg);
```

## response 方向：API 调用返回

response 是某一次 API 调用的返回值，和发起请求的 MethodChannel 调用绑定。

```text
SDK Result / Map
  → Wrapper 的 result.success(...)
  → Dart invokeMethod() 返回 Future<dynamic>
  → ResponseNormalizer 包装 type=response、requestId、success、result
  → IMWebSocketBridge.jsonEncode()
  → Managed WebSocket
  → Python json.loads()
```

Python `DeviceConnection` 为每次 `call()` 创建一个专属 `resp_q`：

```python
resp_q = queue.Queue(maxsize=1)
pending[request_id] = resp_q
```

`recv_loop` 根据 `id` / `requestId` / `sequence` 找到对应的 `resp_q`，然后 `call()` 返回 response。

```text
response → 对应请求的 resp_q → call() 返回 → Case 断言
```

## event 方向：SDK 异步回调

event 不是某个 API 的直接返回值，而是 SDK 主动产生的异步回调。

例如：

```text
SDK onMessagesReceived
  → Wrapper 收到 EMMessage[]
  → Wrapper 转成 Map/List
  → MethodChannel.invokeMethod("onMessagesReceived", payload)
  → Dart EventRouter
```

`EventRouter` 将不同 Channel 的原生回调统一成：

```json
{
  "type": "event",
  "eventType": "onMessagesReceived",
  "data": {
    "messages": []
  }
}
```

然后：

```text
EventRouter
  → IMWebSocketBridge.jsonEncode()
  → Managed WebSocket
  → Python recv_loop
  → _recv_queue
```

## Python 端的三个队列概念

### `resp_q`

某一次 API 调用专属的 response 队列：

```text
一个 call() → 一个 resp_q
```

只存这一次请求对应的 response。

### `_recv_queue`

`DeviceConnection` 的通用接收队列。没有被某个 pending request 匹配的消息，通常先进入这里，主要包括 event。

### `_event_buffer`

`receive_message()` 读取 `_recv_queue` 后，如果发现事件不是当前要找的类型，就暂存到 `_event_buffer`，避免事件被直接丢弃。

```text
_recv_queue → receive_message() 匹配
                    ├─ 匹配成功：返回 Case
                    └─ 不匹配：放入 _event_buffer
```

因此：

```text
response → resp_q
event    → _recv_queue → _event_buffer → receive_message()
```

## response 和 event 的区别

| 类型 | 产生时机 | Dart 处理方式 | Python 去向 |
|---|---|---|---|
| response | API 调用完成 | `result.success()` → `Future` | 对应 `resp_q` |
| event | SDK 异步回调 | `channel.invokeMethod()` → `EventRouter` | `_recv_queue` / `_event_buffer` |

多个 MethodChannel 仍然只属于同一个 Flutter Runner，最终通过同一个 Runner WebSocket 回到 Python。

