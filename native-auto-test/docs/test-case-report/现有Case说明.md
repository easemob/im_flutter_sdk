# 现有 pytest Cases 自然语言清单

> 统计范围：`native-auto-test/tests/` 当前工作树；参数化测试按 pytest 实际实例逐条列出。
> 描述口径：以当前测试代码中的真实操作、回调和断言为准；测试函数名只作为定位标识。

## 统计

- pytest 实例：**799**
- 测试函数：**544**
- 参数化展开实例：**255**

| 模块 | pytest 实例 | 测试函数 |
| --- | ---: | ---: |
| chat | 261 | 205 |
| chatroom | 144 | 70 |
| client | 27 | 11 |
| contact | 37 | 37 |
| group | 299 | 192 |
| presence | 10 | 10 |
| push | 9 | 7 |
| user_info | 12 | 12 |

- 普通：765
- 5.0 不可用：34

## chat

### 1. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_send_with_type.py::test_send_message_with_type_video`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_send_with_type.py::test_send_message_with_type_video`
- 业务说明：按类型发送消息(视频)：视频消息发送成功、发送账号副端同步、接收账号全端接收
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：按类型发送消息(视频)：视频消息发送成功、发送账号副端同步、接收账号全端接收。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 当前测试步骤的同步响应、异步事件和最终业务状态满足代码断言。
  2. 任一关键字段、回调、列表、数量或最终状态不符时，Case 判定失败。

### 2. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_send_with_type.py::test_send_message_with_type_image`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_send_with_type.py::test_send_message_with_type_image`
- 业务说明：按类型发送消息(图片)：图片消息发送成功、发送账号副端同步、接收账号全端接收
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：按类型发送消息(图片)：图片消息发送成功、发送账号副端同步、接收账号全端接收。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 当前测试步骤的同步响应、异步事件和最终业务状态满足代码断言。
  2. 任一关键字段、回调、列表、数量或最终状态不符时，Case 判定失败。

### 3. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_send_with_type.py::test_send_message_with_type_file`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_send_with_type.py::test_send_message_with_type_file`
- 业务说明：按类型发送消息(文件)：文件消息发送成功、发送账号副端同步、接收账号全端接收
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：按类型发送消息(文件)：文件消息发送成功、发送账号副端同步、接收账号全端接收。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 当前测试步骤的同步响应、异步事件和最终业务状态满足代码断言。
  2. 任一关键字段、回调、列表、数量或最终状态不符时，Case 判定失败。

### 4. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_send_with_type.py::test_send_message_with_type_cmd_received_by_cmd_callback`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_send_with_type.py::test_send_message_with_type_cmd_received_by_cmd_callback`
- 业务说明：按类型发送消息(cmd)：发送 CMD 消息，接收账号全部在线端收到 CMD 消息接收回调 且不混入普通消息回调
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：测试准备：清理收发账号全部端的历史事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  2. 操作：发送 CMD 消息
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：确认发送请求已提交
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：验证 CMD 发送成功（消息发送成功回调）并提取服务器消息 ID
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：接收账号端 收到 CMD 回调（CMD 消息接收回调）
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、from、to、convId、chatType、direction、status、hasRead、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 5. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_send_with_type.py::test_send_message_with_type_text_with_languages`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_send_with_type.py::test_send_message_with_type_text_with_languages`
- 业务说明：按类型发送消息(txt) 带目标语言：发送成功、全端同步并携带 翻译结果
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：按类型发送消息(txt) 带目标语言：发送成功、全端同步并携带 翻译结果。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验关键字段：content。

### 6. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_send_with_type.py::test_send_message_with_type_text_basic`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_send_with_type.py::test_send_message_with_type_text_basic`
- 业务说明：按类型发送消息(txt) 基本文本：发送账号副端同步、接收账号全端接收并落库
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：按类型发送消息(txt) 基本文本：发送账号副端同步、接收账号全端接收并落库。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验关键字段：content。

### 7. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_crud.py::test_chat_translate_message_recalled_message`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_crud.py::test_chat_translate_message_recalled_message`
- 业务说明：场景：发送账号向接收账号发送文本消息后撤回
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：动作发送端 发送待撤回的文本消息
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：发送端等待 消息发送成功回调 并提取消息 ID
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  3. 操作：发送账号副端 收到本账号消息同步（消息接收回调）
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  4. 操作：发送账号副端 可从本地消息库查询该消息
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  5. 操作：接收端 验证原始文本消息 消息 ID=
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  6. 操作：动作发送端撤回消息 消息 ID=
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  7. 操作：发送账号副端 验证撤回信息 消息撤回回调 消息 ID=
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  8. 操作：接收端 验证撤回信息 消息撤回回调 消息 ID=
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、from、to、convId、chatType、direction、status、hasRead、hasDeliverAck、content、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 8. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s4_message_content_changed.py::test_chat_modify_custom_message_content_changed_event`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s4_message_content_changed.py::test_chat_modify_custom_message_content_changed_event`
- 业务说明：场景：A 发送自定义消息并修改内容，B 的全部在线端验证内容变更事件；同时验证 A 副端同步原消息
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：向接收账号发送自定义消息
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：等待消息发送成功回调（消息发送成功回调）
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  3. 操作：取得服务端消息 ID
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  4. 操作：接收端 收到原始自定义消息（消息接收回调）
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：修改自定义消息内容
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  6. 操作：接收端 收到内容更新通知（消息内容变更回调）
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、from、to、convId、chatType、direction、status、hasRead、hasDeliverAck、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 9. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_manager_remaining_api_coverage.py::test_chat_manager_recall_message_receiver_recalled_info_event`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_manager_remaining_api_coverage.py::test_chat_manager_recall_message_receiver_recalled_info_event`
- 业务说明：撤回消息：发送方撤回已送达单聊消息，接收账号全部在线端收到 消息撤回回调 并携带撤回消息 ID
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：发送待撤回文本消息
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：撤回该消息（撤回消息）
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：接收账号端 收到撤回通知（消息撤回回调）
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、from、to、convId、chatType、direction、status、hasRead、content、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 10. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_crud.py::test_chat_search_chat_msg_from_db_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_crud.py::test_chat_search_chat_msg_from_db_success`
- 业务说明：从本地数据库搜索聊天消息 成功
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：从本地数据库搜索聊天消息 成功
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：from。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 11. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_reaction_fetch.py::test_chat_reaction_change_event_received_by_sender`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_reaction_fetch.py::test_chat_reaction_change_event_received_by_sender`
- 业务说明：单聊消息与 消息 Reaction 在收发账号多端同步，并校验各在线端的变更回调
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：测试准备：清理动作账号和接收账号的历史事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  2. 操作：向接收账号发送待 消息 Reaction 的文本消息
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：确认文本消息已提交
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  4. 操作：等待 的发送成功回调（消息发送成功回调）
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：确认文本消息发送成功
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  6. 操作：发送账号端 同步原消息（消息接收回调）
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  7. 操作：确认发送账号端 已同步原消息
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  8. 操作：发送账号端 从本地消息库查询原消息
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、from、to、convId、chatType、direction、status、hasRead、hasDeliverAck、content、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 12. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_crud.py::test_chat_send_and_received`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_crud.py::test_chat_send_and_received`
- 业务说明：单聊消息在发送账号多端同步、接收账号全端接收并完成本地落库校验
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：测试准备：清理发送账号和接收账号全部端的历史事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  2. 操作：发送账号动作端 向目标账号发送文本消息
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：确认发送请求已提交
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：发送端验证 消息发送成功回调 并提取服务端消息 ID
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：发送账号副端 收到本账号消息同步（消息接收回调）
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：发送账号副端 可从本地消息库查询该消息
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  7. 操作：接收端 验证 消息接收回调: 消息 ID=
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  8. 操作：接收端 可从本地消息库查询该消息
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、from、to、convId、chatType、direction、status、hasRead、hasDeliverAck、content、result、list。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 13. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_text_boundaries_and_location_delivery.py::test_chat_send_rejects_mismatched_from`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_text_boundaries_and_location_delivery.py::test_chat_send_rejects_mismatched_from`
- 业务说明：发送 拒绝 发送端不匹配
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：发送 拒绝 发送端不匹配
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、from、to、convId、chatType、direction、hasRead、content、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 14. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_callback_and_combine.py::test_attachment_messages_send_receive_and_public_download_methods`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_callback_and_combine.py::test_attachment_messages_send_receive_and_public_download_methods`
- 业务说明：发送 文件/图片/视频 附件：发送账号副端同步、接收账号全部在线端接收，主接收端执行公开下载 API
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：发送 文件/图片/视频 附件：发送账号副端同步、接收账号全部在线端接收，主接收端执行公开下载 API。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验关键字段：msgId。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 15. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_send_with_type.py::test_send_message_with_type_image_heic`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_send_with_type.py::test_send_message_with_type_image_heic`
- 业务说明：发送 HEIC 格式图片，验证 SDK 能正常上传并投递到接收账号全部在线端
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：发送 HEIC 格式图片，验证 SDK 能正常上传并投递到接收账号全部在线端。
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 当前测试步骤的同步响应、异步事件和最终业务状态满足代码断言。
  2. 任一关键字段、回调、列表、数量或最终状态不符时，Case 判定失败。

### 16. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_callback_and_combine.py::test_send_text_message_with_webhook_env[default-default]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_callback_and_combine.py::test_send_text_message_with_webhook_env[default-default]`
- 业务说明：发送带 webhookEnv 的文本消息：发送账号副端同步、接收账号全部在线端接收
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：发送带 webhookEnv 的文本消息：发送账号副端同步、接收账号全部在线端接收。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验关键字段：content。

### 17. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_attachment_download_and_history_boundaries.py::test_chat_sender_downloads_image_and_video_attachment`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_attachment_download_and_history_boundaries.py::test_chat_sender_downloads_image_and_video_attachment`
- 业务说明：发送方下载自己发送的 图片/视频 附件（发送账号副端同步 + 接收账号全端收由 _发送_with_type 内部完成）
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：发送方下载自己发送的 图片/视频 附件（发送账号副端同步 + 接收账号全端收由 _发送_with_type 内部完成）。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 当前测试步骤的同步响应、异步事件和最终业务状态满足代码断言。
  2. 任一关键字段、回调、列表、数量或最终状态不符时，Case 判定失败。

### 18. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_modification_matrix.py::test_chat_non_sender_cannot_modify_message`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_modification_matrix.py::test_chat_non_sender_cannot_modify_message`
- 业务说明：非发送者（接收账号端）尝试修改消息被拒绝（无权限）；发送投递到接收账号全部在线端
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：发送待修改文本消息
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：接收账号端 接收该消息
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：非发送者 尝试修改消息（应无权限）
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：msgId、content、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 19. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_callback_and_combine.py::test_combine_forward_send_receive_and_inner_attachment_download`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_callback_and_combine.py::test_combine_forward_send_receive_and_inner_attachment_download`
- 业务说明：合并 消息：发送账号副端同步、接收账号全部在线端接收，主接收端执行 inner 附件下载
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：合并 消息：发送账号副端同步、接收账号全部在线端接收，主接收端执行 inner 附件下载。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、from、to、convId、chatType、direction、status、hasRead、result、list。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 20. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_callback_and_combine.py::test_combine_forward_media_inner_attachment_download`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_callback_and_combine.py::test_combine_forward_media_inner_attachment_download`
- 业务说明：合并 转发媒体：发送账号副端同步、接收账号全部在线端接收，主接收端执行 inner 附件下载
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：合并 转发媒体：发送账号副端同步、接收账号全部在线端接收，主接收端执行 inner 附件下载。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验关键字段：msgId、result、list。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 21. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s3_non_message_ops.py::test_chat_ack_conversation_read_success_with_event`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s3_non_message_ops.py::test_chat_ack_conversation_read_success_with_event`
- 业务说明：会话已读回执：接收端回执会话已读（5.0 清未读数，两端均不发 会话已读回调 事件）
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：接收账号动作端 回执会话已读（会话已读回执）
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：convId、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 22. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_reaction_fetch.py::test_chat_fetch_reaction_detail_oversize_page_size`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_reaction_fetch.py::test_chat_fetch_reaction_detail_oversize_page_size`
- 业务说明：获取 消息 Reaction 详情 过大 pageSize（1000）；应返回稳定结果结构
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：获取 消息 Reaction 详情 过大 pageSize（1000）；应返回稳定结果结构。
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：msgId、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 23. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_types_and_delivery.py::test_chat_missing_voice_message_send_receive`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_types_and_delivery.py::test_chat_missing_voice_message_send_receive`
- 业务说明：缺失 语音 消息 发送 接收
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：缺失 语音 消息 发送 接收
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 当前测试步骤的同步响应、异步事件和最终业务状态满足代码断言。
  2. 任一关键字段、回调、列表、数量或最终状态不符时，Case 判定失败。

### 24. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_reaction_fetch.py::test_chat_remove_reaction_not_exists_reaction`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_reaction_fetch.py::test_chat_remove_reaction_not_exists_reaction`
- 业务说明：删除 消息 Reaction 删除不存在的 消息 Reaction；接收账号全部在线端收到消息投递
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：发送消息并等待接收端接收
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：删除不存在的 消息 Reaction
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：msgId、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 25. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_crud.py::test_chat_add_reaction_invalid_id_response`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_crud.py::test_chat_add_reaction_invalid_id_response`
- 业务说明：添加 消息 消息 Reaction 无效 id 响应
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：添加 消息 Reaction 无效 id 响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：msgId、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 26. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_reaction_fetch.py::test_chat_add_reaction_duplicate_reaction`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_reaction_fetch.py::test_chat_add_reaction_duplicate_reaction`
- 业务说明：添加 消息 Reaction 重复添加同一 消息 Reaction；接收账号全部在线端收到 消息 Reaction 变更事件
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：发送消息并等待接收端接收
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：添加 消息 Reaction（首次）
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 27. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_text_boundaries_and_location_delivery.py::test_chat_location_message_delivery_ack`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_text_boundaries_and_location_delivery.py::test_chat_location_message_delivery_ack`
- 业务说明：位置 消息 送达回执
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：位置 消息 送达回执
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、from、to、convId、chatType、direction、status、hasRead、hasDeliverAck、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 28. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_text_boundaries_and_location_delivery.py::test_chat_text_content_boundaries[empty]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_text_boundaries_and_location_delivery.py::test_chat_text_content_boundaries[empty]`
- 业务说明：文本 内容边界
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：文本 内容边界
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验关键字段：content。

### 29. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_text_boundaries_and_location_delivery.py::test_chat_text_content_boundaries[length-250]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_text_boundaries_and_location_delivery.py::test_chat_text_content_boundaries[length-250]`
- 业务说明：文本 内容边界
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：文本 内容边界
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验关键字段：content。

### 30. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_text_boundaries_and_location_delivery.py::test_chat_text_content_boundaries[special-characters]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_text_boundaries_and_location_delivery.py::test_chat_text_content_boundaries[special-characters]`
- 业务说明：文本 内容边界
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：文本 内容边界
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验关键字段：content。

### 31. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_crud.py::test_chat_translate_message_basic`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_crud.py::test_chat_translate_message_basic`
- 业务说明：文本消息在收发账号多端同步后，由发送动作端请求翻译并校验返回消息
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：查询待翻译消息
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  2. 操作：请求将消息翻译为简体中文
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：确认翻译接口返回当前文本消息
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验关键字段：msgId、from、to、convId、content、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 32. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_crud.py::test_chat_add_reaction_empty_reaction_response`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_crud.py::test_chat_add_reaction_empty_reaction_response`
- 业务说明：消息多端同步后，验证发送动作端提交空 消息 Reaction 返回明确业务错误
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：为消息提交空 消息 Reaction
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  2. 操作：确认空 消息 Reaction 被拒绝且错误码正确
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：msgId、content、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 33. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_ack_read_strict.py::test_chat_ack_message_read_invalid_msg_id`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_ack_read_strict.py::test_chat_ack_message_read_invalid_msg_id`
- 业务说明：消息已读回执 使用无效 消息 ID；按不存在语义冻结
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：消息已读回执 使用无效 消息 ID；按不存在语义冻结。
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：msgId、to、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 34. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_ack_read_strict.py::test_chat_ack_message_read_success_with_event`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_ack_read_strict.py::test_chat_ack_message_read_success_with_event`
- 业务说明：消息已读回执 正常链路：发送消息（需要已读回执）后接收账号全端接收，接收端回执并验证读回执事件
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：发送标记已读回执的文本消息
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：验证发送成功（消息发送成功回调）
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  3. 操作：接收账号动作端 回执已读（消息已读回执）
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、from、to、convId、chatType、direction、status、hasRead、content、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 35. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_modification_matrix.py::test_chat_modify_media_body_is_rejected[video]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_modification_matrix.py::test_chat_modify_media_body_is_rejected[video]`
- 业务说明：修改 媒体 内容 应被拒绝
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：修改 媒体 内容 应被拒绝
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：msgId、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 36. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_modification_matrix.py::test_chat_modify_media_body_is_rejected[image]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_modification_matrix.py::test_chat_modify_media_body_is_rejected[image]`
- 业务说明：修改 媒体 内容 应被拒绝
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：修改 媒体 内容 应被拒绝
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：msgId、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 37. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_modification_matrix.py::test_chat_modify_media_body_is_rejected[voice]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_modification_matrix.py::test_chat_modify_media_body_is_rejected[voice]`
- 业务说明：修改 媒体 内容 应被拒绝
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：修改 媒体 内容 应被拒绝
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：msgId、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 38. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_modification_matrix.py::test_chat_modify_media_attributes[video]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_modification_matrix.py::test_chat_modify_media_attributes[video]`
- 业务说明：修改 媒体 属性
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：修改 媒体 属性
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、from、to、convId、chatType、direction、status、hasRead、hasDeliverAck、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 39. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_modification_matrix.py::test_chat_modify_media_attributes[image]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_modification_matrix.py::test_chat_modify_media_attributes[image]`
- 业务说明：修改 媒体 属性
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：修改 媒体 属性
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、from、to、convId、chatType、direction、status、hasRead、hasDeliverAck、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 40. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_modification_matrix.py::test_chat_modify_media_attributes[voice]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_modification_matrix.py::test_chat_modify_media_attributes[voice]`
- 业务说明：修改 媒体 属性
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：修改 媒体 属性
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、from、to、convId、chatType、direction、status、hasRead、hasDeliverAck、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 41. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_crud.py::test_chat_modify_message_invalid_id_response`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_crud.py::test_chat_modify_message_invalid_id_response`
- 业务说明：修改 消息 无效 id 响应
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：修改 消息 无效 id 响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：msgId、content、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 42. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_pin_boundaries.py::test_chat_pin_recalled_message`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_pin_boundaries.py::test_chat_pin_recalled_message`
- 业务说明：A 发送并撤回消息：验证 B 全部在线端收到撤回通知（消息撤回回调），pin 撤回消息报错
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：清理发送与接收账号全部端历史事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  2. 操作：发送文本消息
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：撤回消息
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：B 全部在线端收到撤回通知（消息撤回回调）
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：pin 已撤回消息应报错
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、from、to、convId、chatType、direction、status、hasRead、content、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 43. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_types_and_delivery.py::test_chat_missing_location_message_send_receive`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_types_and_delivery.py::test_chat_missing_location_message_send_receive`
- 业务说明：A 发送位置消息，验证 A 副端同步以及 B 全部在线端接收相同消息
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：清理发送账号和接收账号全部端的历史事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  2. 操作：向接收账号发送位置消息
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：等待 的消息发送成功回调（消息发送成功回调）
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  4. 操作：确认位置消息已提交
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：确认位置消息发送成功
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  6. 操作：接收端 收到位置消息（消息接收回调）
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  7. 操作：确认接收端 收到当前位置消息
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、from、to、convId、chatType、direction、status、hasRead、hasDeliverAck、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 44. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_crud.py::test_chat_ack_message_read_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_crud.py::test_chat_ack_message_read_success`
- 业务说明：A 发送文本，B 的全部在线端接收并发送已读回执；验证 A 主副端已读回调和本地状态同步
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：清理发送账号和接收账号全部端的历史事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  2. 操作：向接收账号发送待已读文本消息
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：等待 的消息发送成功回调（消息发送成功回调）
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  4. 操作：确认待已读消息已提交
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：发送账号副端 收到待已读消息同步（消息接收回调）
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：发送账号副端 可从本地消息库查询待已读消息
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  7. 操作：接收端 收到待已读消息（消息接收回调）
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  8. 操作：确认接收端 收到当前消息
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、from、to、convId、chatType、direction、status、hasRead、content、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 45. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_types_and_delivery.py::test_chat_missing_custom_message_send_receive`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_types_and_delivery.py::test_chat_missing_custom_message_send_receive`
- 业务说明：A 发送自定义消息，验证 A 副端同步以及 B 全部在线端接收相同消息
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：清理发送账号和接收账号全部端的历史事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  2. 操作：向接收账号发送自定义消息
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：等待 的消息发送成功回调（消息发送成功回调）
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  4. 操作：确认自定义消息已提交
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：确认自定义消息发送成功
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  6. 操作：接收端 收到自定义消息（消息接收回调）
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  7. 操作：确认接收端 收到当前自定义消息
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、from、to、convId、chatType、direction、status、hasRead、hasDeliverAck、content、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 46. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_pin_boundaries.py::test_chat_pin_message_empty_id`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_pin_boundaries.py::test_chat_pin_message_empty_id`
- 业务说明：pin 消息 空 id
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：pin 消息 空 id
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：msgId。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 47. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_manager_remaining_api_coverage.py::test_chat_manager_pin_unpin_and_fetch_pinned_messages`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_manager_remaining_api_coverage.py::test_chat_manager_pin_unpin_and_fetch_pinned_messages`
- 业务说明：pin消息/unpin消息/获取置顶消息：发送消息后置顶、拉取置顶列表、取消置顶并确认列表清空
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：pin消息/unpin消息/获取置顶消息：发送消息后置顶、拉取置顶列表、取消置顶并确认列表清空。
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：msgId、from、to、convId、chatType、direction、status、hasRead、content、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 48. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_delivery.py::test_chat_offline_text_automatic_translation_after_recipient_login`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_delivery.py::test_chat_offline_text_automatic_translation_after_recipient_login`
- 业务说明：带 target语言 的文本在 B 离线期间发送，重登后保留真实翻译结果
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：带 target语言 的文本在 B 离线期间发送，重登后保留真实翻译结果。
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验关键字段：content。

### 49. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_delivery.py::test_chat_offline_cmd_message_received_after_login`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_delivery.py::test_chat_offline_cmd_message_received_after_login`
- 业务说明：好友 B 离线时 A 发普通 CMD；B 登录后通过 CMD 专用事件接收
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：好友 B 离线时 A 发普通 CMD；B 登录后通过 CMD 专用事件接收。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。

### 50. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_delivery.py::test_chat_offline_location_message_received_after_login`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_delivery.py::test_chat_offline_location_message_received_after_login`
- 业务说明：好友 B 离线时 A 发位置消息；B 重登收到完整位置业务字段
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：好友 B 离线时 A 发位置消息；B 重登收到完整位置业务字段。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 当前测试步骤的同步响应、异步事件和最终业务状态满足代码断言。
  2. 任一关键字段、回调、列表、数量或最终状态不符时，Case 判定失败。

### 51. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_delivery.py::test_chat_offline_text_message_received_after_login`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_delivery.py::test_chat_offline_text_message_received_after_login`
- 业务说明：好友 B 离线时 A 发文本；B 登录后收到同一真实消息
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：好友 B 离线时 A 发文本；B 登录后收到同一真实消息。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验关键字段：content。

### 52. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_delivery.py::test_chat_offline_custom_message_received_after_login`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_delivery.py::test_chat_offline_custom_message_received_after_login`
- 业务说明：好友 B 离线时 A 发自定义消息；B 重登收到事件名和参数
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：好友 B 离线时 A 发自定义消息；B 重登收到事件名和参数。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。

### 53. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_delivery.py::test_chat_offline_combine_message_received_after_login`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_delivery.py::test_chat_offline_combine_message_received_after_login`
- 业务说明：好友 B 离线时 A 转发两条真实源消息；B 重登收到合并消息
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：好友 B 离线时 A 转发两条真实源消息；B 重登收到合并消息。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验关键字段：content。

### 54. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_delivery.py::test_chat_offline_media_message_received_after_login[video]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_delivery.py::test_chat_offline_media_message_received_after_login[video]`
- 业务说明：好友 B 离线时接收 文件/图片/视频/语音，并保留媒体核心字段
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：好友 B 离线时接收 文件/图片/视频/语音，并保留媒体核心字段。
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 当前测试步骤的同步响应、异步事件和最终业务状态满足代码断言。
  2. 任一关键字段、回调、列表、数量或最终状态不符时，Case 判定失败。

### 55. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_delivery.py::test_chat_offline_media_message_received_after_login[image]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_delivery.py::test_chat_offline_media_message_received_after_login[image]`
- 业务说明：好友 B 离线时接收 文件/图片/视频/语音，并保留媒体核心字段
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：好友 B 离线时接收 文件/图片/视频/语音，并保留媒体核心字段。
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 当前测试步骤的同步响应、异步事件和最终业务状态满足代码断言。
  2. 任一关键字段、回调、列表、数量或最终状态不符时，Case 判定失败。

### 56. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_delivery.py::test_chat_offline_media_message_received_after_login[file]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_delivery.py::test_chat_offline_media_message_received_after_login[file]`
- 业务说明：好友 B 离线时接收 文件/图片/视频/语音，并保留媒体核心字段
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：好友 B 离线时接收 文件/图片/视频/语音，并保留媒体核心字段。
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 当前测试步骤的同步响应、异步事件和最终业务状态满足代码断言。
  2. 任一关键字段、回调、列表、数量或最终状态不符时，Case 判定失败。

### 57. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_delivery.py::test_chat_offline_media_message_received_after_login[voice]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_delivery.py::test_chat_offline_media_message_received_after_login[voice]`
- 业务说明：好友 B 离线时接收 文件/图片/视频/语音，并保留媒体核心字段
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：好友 B 离线时接收 文件/图片/视频/语音，并保留媒体核心字段。
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 当前测试步骤的同步响应、异步事件和最终业务状态满足代码断言。
  2. 任一关键字段、回调、列表、数量或最终状态不符时，Case 判定失败。

### 58. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_operations.py::test_chat_offline_sender_receives_reaction_remove_after_relogin`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_operations.py::test_chat_offline_sender_receives_reaction_remove_after_relogin`
- 业务说明：消息已有 消息 Reaction，A 离线期间 B 移除；A 重登收到移除事件
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：消息已有 消息 Reaction，A 离线期间 B 移除；A 重登收到移除事件。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、chatType、content、result。

### 59. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_operations.py::test_chat_offline_recipient_receives_message_unpin_after_relogin`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_operations.py::test_chat_offline_recipient_receives_message_unpin_after_relogin`
- 业务说明：消息已置顶，B 离线期间 A 取消置顶；B 重登收到取消事件
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：消息已置顶，B 离线期间 A 取消置顶；B 重登收到取消事件。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、content、result。

### 60. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_delivery.py::test_chat_offline_combine_delivery_ack_after_recipient_login`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_delivery.py::test_chat_offline_combine_delivery_ack_after_recipient_login`
- 业务说明：真实源消息组成 合并；B 离线重登接收后 A 才收到送达回执（源消息与 合并 均需标记 需要已读回执）
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：真实源消息组成 合并；B 离线重登接收后 A 才收到送达回执（源消息与 合并 均需标记 需要已读回执）。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验关键字段：content。

### 61. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_operations.py::test_chat_offline_sender_receives_message_read_after_relogin`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_operations.py::test_chat_offline_sender_receives_message_read_after_relogin`
- 业务说明：A 离线期间 B 回执单条已读；A 重登收到目标 已读回执回调
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：A 离线期间 B 回执单条已读；A 重登收到目标 已读回执回调。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、from、to、convId、chatType、direction、status、hasRead、hasDeliverAck、content、result。

### 62. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_operations.py::test_chat_offline_sender_receives_conversation_read_after_relogin`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_operations.py::test_chat_offline_sender_receives_conversation_read_after_relogin`
- 业务说明：A 离线期间 B 回执会话已读；A 重登只接受 会话已读回调
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：5.0 不可用
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：A 离线期间 B 回执会话已读；A 重登只接受 会话已读回调。
     - 预期：该原测试目标在 5.0 中不再成立。5.0 不再向对方发送会话已读回执，只清理本地未读数。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：该原测试目标在 5.0 中不再成立。5.0 不再向对方发送会话已读回执，只清理本地未读数。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：from、to、convId、content、result。

### 63. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_operations.py::test_chat_offline_sender_receives_reaction_add_after_relogin`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_operations.py::test_chat_offline_sender_receives_reaction_add_after_relogin`
- 业务说明：A 离线期间 B 添加 消息 Reaction；A 重登收到添加事件和最终聚合状态
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：A 离线期间 B 添加 消息 Reaction；A 重登收到添加事件和最终聚合状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、chatType、content、result。

### 64. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_combine_message_read_after_sender_relogin`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_combine_message_read_after_sender_relogin`
- 业务说明：A 离线期间 B 已读 合并；A 重登收到同一 消息 ID 的已读回执
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：A 离线期间 B 已读 合并；A 重登收到同一 消息 ID 的已读回执。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验关键字段：msgId、to、result。

### 65. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_typed_message_read_after_sender_relogin[video]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_typed_message_read_after_sender_relogin[video]`
- 业务说明：A 离线期间 B 已读类型消息；A 重登收到同一 消息 ID 的已读回执
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：A 离线期间 B 已读类型消息；A 重登收到同一 消息 ID 的已读回执。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验关键字段：msgId、to、result。

### 66. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_typed_message_read_after_sender_relogin[image]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_typed_message_read_after_sender_relogin[image]`
- 业务说明：A 离线期间 B 已读类型消息；A 重登收到同一 消息 ID 的已读回执
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：A 离线期间 B 已读类型消息；A 重登收到同一 消息 ID 的已读回执。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验关键字段：msgId、to、result。

### 67. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_typed_message_read_after_sender_relogin[location]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_typed_message_read_after_sender_relogin[location]`
- 业务说明：A 离线期间 B 已读类型消息；A 重登收到同一 消息 ID 的已读回执
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：A 离线期间 B 已读类型消息；A 重登收到同一 消息 ID 的已读回执。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验关键字段：msgId、to、result。

### 68. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_typed_message_read_after_sender_relogin[file]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_typed_message_read_after_sender_relogin[file]`
- 业务说明：A 离线期间 B 已读类型消息；A 重登收到同一 消息 ID 的已读回执
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：A 离线期间 B 已读类型消息；A 重登收到同一 消息 ID 的已读回执。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验关键字段：msgId、to、result。

### 69. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_typed_message_read_after_sender_relogin[voice]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_typed_message_read_after_sender_relogin[voice]`
- 业务说明：A 离线期间 B 已读类型消息；A 重登收到同一 消息 ID 的已读回执
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：A 离线期间 B 已读类型消息；A 重登收到同一 消息 ID 的已读回执。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验关键字段：msgId、to、result。

### 70. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_typed_message_read_after_sender_relogin[custom]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_typed_message_read_after_sender_relogin[custom]`
- 业务说明：A 离线期间 B 已读类型消息；A 重登收到同一 消息 ID 的已读回执
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：A 离线期间 B 已读类型消息；A 重登收到同一 消息 ID 的已读回执。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验关键字段：msgId、to、result。

### 71. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_delivery.py::test_chat_offline_mixed_backlog_local_state_after_recipient_login`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_delivery.py::test_chat_offline_mixed_backlog_local_state_after_recipient_login`
- 业务说明：B 离线积压四类消息；按 ID 集合核对回放、本地、历史、未读和最新消息
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：B 离线积压四类消息；按 ID 集合核对回放、本地、历史、未读和最新消息。
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、from、to、convId、chatType、direction、status、hasRead、content、result、list。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 72. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_operations.py::test_chat_offline_recipient_receives_message_pin_after_relogin`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_operations.py::test_chat_offline_recipient_receives_message_pin_after_relogin`
- 业务说明：B 离线期间 A 置顶消息；B 重登收到置顶事件和最终置顶消息
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：B 离线期间 A 置顶消息；B 重登收到置顶事件和最终置顶消息。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、content、result。

### 73. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_delivery.py::test_chat_offline_multiple_text_messages_and_unread_count`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_delivery.py::test_chat_offline_multiple_text_messages_and_unread_count`
- 业务说明：B 离线期间积压三条文本；上线后消息集合、未读数和最新消息一致
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：B 离线期间积压三条文本；上线后消息集合、未读数和最新消息一致。
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、from、to、convId、chatType、direction、status、hasRead、hasDeliverAck、content、result、list。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 74. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_delivery.py::test_chat_offline_typed_delivery_ack_after_recipient_login[video]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_delivery.py::test_chat_offline_typed_delivery_ack_after_recipient_login[video]`
- 业务说明：B 离线时的类型消息仅在重登接收后触发 A 的真实送达回执（需发送标记 需要已读回执）
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：B 离线时的类型消息仅在重登接收后触发 A 的真实送达回执（需发送标记 需要已读回执）。
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 当前测试步骤的同步响应、异步事件和最终业务状态满足代码断言。
  2. 任一关键字段、回调、列表、数量或最终状态不符时，Case 判定失败。

### 75. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_delivery.py::test_chat_offline_typed_delivery_ack_after_recipient_login[image]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_delivery.py::test_chat_offline_typed_delivery_ack_after_recipient_login[image]`
- 业务说明：B 离线时的类型消息仅在重登接收后触发 A 的真实送达回执（需发送标记 需要已读回执）
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：B 离线时的类型消息仅在重登接收后触发 A 的真实送达回执（需发送标记 需要已读回执）。
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 当前测试步骤的同步响应、异步事件和最终业务状态满足代码断言。
  2. 任一关键字段、回调、列表、数量或最终状态不符时，Case 判定失败。

### 76. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_delivery.py::test_chat_offline_typed_delivery_ack_after_recipient_login[location]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_delivery.py::test_chat_offline_typed_delivery_ack_after_recipient_login[location]`
- 业务说明：B 离线时的类型消息仅在重登接收后触发 A 的真实送达回执（需发送标记 需要已读回执）
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：B 离线时的类型消息仅在重登接收后触发 A 的真实送达回执（需发送标记 需要已读回执）。
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 当前测试步骤的同步响应、异步事件和最终业务状态满足代码断言。
  2. 任一关键字段、回调、列表、数量或最终状态不符时，Case 判定失败。

### 77. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_delivery.py::test_chat_offline_typed_delivery_ack_after_recipient_login[file]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_delivery.py::test_chat_offline_typed_delivery_ack_after_recipient_login[file]`
- 业务说明：B 离线时的类型消息仅在重登接收后触发 A 的真实送达回执（需发送标记 需要已读回执）
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：B 离线时的类型消息仅在重登接收后触发 A 的真实送达回执（需发送标记 需要已读回执）。
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 当前测试步骤的同步响应、异步事件和最终业务状态满足代码断言。
  2. 任一关键字段、回调、列表、数量或最终状态不符时，Case 判定失败。

### 78. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_delivery.py::test_chat_offline_typed_delivery_ack_after_recipient_login[voice]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_delivery.py::test_chat_offline_typed_delivery_ack_after_recipient_login[voice]`
- 业务说明：B 离线时的类型消息仅在重登接收后触发 A 的真实送达回执（需发送标记 需要已读回执）
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：B 离线时的类型消息仅在重登接收后触发 A 的真实送达回执（需发送标记 需要已读回执）。
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 当前测试步骤的同步响应、异步事件和最终业务状态满足代码断言。
  2. 任一关键字段、回调、列表、数量或最终状态不符时，Case 判定失败。

### 79. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_delivery.py::test_chat_offline_typed_delivery_ack_after_recipient_login[custom]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_delivery.py::test_chat_offline_typed_delivery_ack_after_recipient_login[custom]`
- 业务说明：B 离线时的类型消息仅在重登接收后触发 A 的真实送达回执（需发送标记 需要已读回执）
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：B 离线时的类型消息仅在重登接收后触发 A 的真实送达回执（需发送标记 需要已读回执）。
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 当前测试步骤的同步响应、异步事件和最终业务状态满足代码断言。
  2. 任一关键字段、回调、列表、数量或最终状态不符时，Case 判定失败。

### 80. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_delivery.py::test_chat_offline_delivery_ack_after_recipient_login`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_delivery.py::test_chat_offline_delivery_ack_after_recipient_login`
- 业务说明：B 离线时发送文本，B 登录投递后 A 收到同一消息的送达回执
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：B 离线时发送文本，B 登录投递后 A 收到同一消息的送达回执。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、from、to、convId、chatType、direction、status、hasRead、hasDeliverAck、content、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 81. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_delivery.py::test_chat_offline_received_media_downloads_after_recipient_login[video-attachment-thumbnail]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_delivery.py::test_chat_offline_received_media_downloads_after_recipient_login[video-attachment-thumbnail]`
- 业务说明：B 使用离线回放的原始媒体消息下载附件；图片/视频同时覆盖缩略图
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：B 使用离线回放的原始媒体消息下载附件；图片/视频同时覆盖缩略图。
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 当前测试步骤的同步响应、异步事件和最终业务状态满足代码断言。
  2. 任一关键字段、回调、列表、数量或最终状态不符时，Case 判定失败。

### 82. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_delivery.py::test_chat_offline_received_media_downloads_after_recipient_login[image-attachment-thumbnail]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_delivery.py::test_chat_offline_received_media_downloads_after_recipient_login[image-attachment-thumbnail]`
- 业务说明：B 使用离线回放的原始媒体消息下载附件；图片/视频同时覆盖缩略图
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：B 使用离线回放的原始媒体消息下载附件；图片/视频同时覆盖缩略图。
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 当前测试步骤的同步响应、异步事件和最终业务状态满足代码断言。
  2. 任一关键字段、回调、列表、数量或最终状态不符时，Case 判定失败。

### 83. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_delivery.py::test_chat_offline_received_media_downloads_after_recipient_login[file-attachment]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_delivery.py::test_chat_offline_received_media_downloads_after_recipient_login[file-attachment]`
- 业务说明：B 使用离线回放的原始媒体消息下载附件；图片/视频同时覆盖缩略图
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：B 使用离线回放的原始媒体消息下载附件；图片/视频同时覆盖缩略图。
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 当前测试步骤的同步响应、异步事件和最终业务状态满足代码断言。
  2. 任一关键字段、回调、列表、数量或最终状态不符时，Case 判定失败。

### 84. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_delivery.py::test_chat_offline_received_media_downloads_after_recipient_login[voice-attachment]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_delivery.py::test_chat_offline_received_media_downloads_after_recipient_login[voice-attachment]`
- 业务说明：B 使用离线回放的原始媒体消息下载附件；图片/视频同时覆盖缩略图
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：B 使用离线回放的原始媒体消息下载附件；图片/视频同时覆盖缩略图。
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 当前测试步骤的同步响应、异步事件和最终业务状态满足代码断言。
  2. 任一关键字段、回调、列表、数量或最终状态不符时，Case 判定失败。

### 85. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_text_recalled_before_first_recipient_login`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_text_recalled_before_first_recipient_login`
- 业务说明：B 首次接收前 A 已撤回文本；B 重登按真实离线合并语义收到撤回
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：B 首次接收前 A 已撤回文本；B 重登按真实离线合并语义收到撤回。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验关键字段：msgId、content、result。

### 86. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_text_modified_before_first_recipient_login`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_text_modified_before_first_recipient_login`
- 业务说明：B 首次接收前 A 已修改文本；B 重登直接收到最终正文
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：B 首次接收前 A 已修改文本；B 重登直接收到最终正文。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验关键字段：msgId、from、to、convId、chatType、direction、status、hasRead、hasDeliverAck、content、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 87. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_combine_message_recall_after_recipient_relogin`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_combine_message_recall_after_recipient_relogin`
- 业务说明：B 已收 合并 后离线；A 撤回后 B 重登收到原 合并 信息
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：B 已收 合并 后离线；A 撤回后 B 重登收到原 合并 信息。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验关键字段：msgId、result。

### 88. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_custom_body_modified_after_recipient_relogin`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_custom_body_modified_after_recipient_relogin`
- 业务说明：B 已收 自定义 后离线；A 修改 内容，B 重登收到最终自定义正文
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：B 已收 自定义 后离线；A 修改 内容，B 重登收到最终自定义正文。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、from、to、convId、chatType、direction、status、hasRead、hasDeliverAck、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 89. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_typed_message_recall_after_recipient_relogin[video]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_typed_message_recall_after_recipient_relogin[video]`
- 业务说明：B 已收类型消息后离线；A 撤回后 B 重登收到撤回事件且本地消息删除
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：B 已收类型消息后离线；A 撤回后 B 重登收到撤回事件且本地消息删除。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、result。

### 90. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_typed_message_recall_after_recipient_relogin[image]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_typed_message_recall_after_recipient_relogin[image]`
- 业务说明：B 已收类型消息后离线；A 撤回后 B 重登收到撤回事件且本地消息删除
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：B 已收类型消息后离线；A 撤回后 B 重登收到撤回事件且本地消息删除。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、result。

### 91. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_typed_message_recall_after_recipient_relogin[location]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_typed_message_recall_after_recipient_relogin[location]`
- 业务说明：B 已收类型消息后离线；A 撤回后 B 重登收到撤回事件且本地消息删除
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：B 已收类型消息后离线；A 撤回后 B 重登收到撤回事件且本地消息删除。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、result。

### 92. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_typed_message_recall_after_recipient_relogin[file]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_typed_message_recall_after_recipient_relogin[file]`
- 业务说明：B 已收类型消息后离线；A 撤回后 B 重登收到撤回事件且本地消息删除
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：B 已收类型消息后离线；A 撤回后 B 重登收到撤回事件且本地消息删除。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、result。

### 93. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_typed_message_recall_after_recipient_relogin[voice]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_typed_message_recall_after_recipient_relogin[voice]`
- 业务说明：B 已收类型消息后离线；A 撤回后 B 重登收到撤回事件且本地消息删除
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：B 已收类型消息后离线；A 撤回后 B 重登收到撤回事件且本地消息删除。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、result。

### 94. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_typed_message_recall_after_recipient_relogin[custom]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_typed_message_recall_after_recipient_relogin[custom]`
- 业务说明：B 已收类型消息后离线；A 撤回后 B 重登收到撤回事件且本地消息删除
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：B 已收类型消息后离线；A 撤回后 B 重登收到撤回事件且本地消息删除。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、result。

### 95. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_media_attributes_modified_after_recipient_relogin[video]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_media_attributes_modified_after_recipient_relogin[video]`
- 业务说明：B 已收媒体后离线；A 修改 属性，B 重登收到并保存扩展
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：B 已收媒体后离线；A 修改 属性，B 重登收到并保存扩展。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、from、to、convId、chatType、direction、status、hasRead、hasDeliverAck、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 96. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_media_attributes_modified_after_recipient_relogin[image]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_media_attributes_modified_after_recipient_relogin[image]`
- 业务说明：B 已收媒体后离线；A 修改 属性，B 重登收到并保存扩展
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：B 已收媒体后离线；A 修改 属性，B 重登收到并保存扩展。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、from、to、convId、chatType、direction、status、hasRead、hasDeliverAck、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 97. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_media_attributes_modified_after_recipient_relogin[file]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_media_attributes_modified_after_recipient_relogin[file]`
- 业务说明：B 已收媒体后离线；A 修改 属性，B 重登收到并保存扩展
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：B 已收媒体后离线；A 修改 属性，B 重登收到并保存扩展。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、from、to、convId、chatType、direction、status、hasRead、hasDeliverAck、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 98. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_media_attributes_modified_after_recipient_relogin[voice]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_media_attributes_modified_after_recipient_relogin[voice]`
- 业务说明：B 已收媒体后离线；A 修改 属性，B 重登收到并保存扩展
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：B 已收媒体后离线；A 修改 属性，B 重登收到并保存扩展。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、from、to、convId、chatType、direction、status、hasRead、hasDeliverAck、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 99. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_operations.py::test_chat_offline_recipient_receives_recall_after_relogin`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_operations.py::test_chat_offline_recipient_receives_recall_after_relogin`
- 业务说明：B 已收消息后离线，A 撤回；B 重登收到目标撤回信息
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：B 已收消息后离线，A 撤回；B 重登收到目标撤回信息。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、from、to、convId、chatType、direction、status、hasRead、hasDeliverAck、content、result。

### 100. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_operations.py::test_chat_offline_recipient_receives_content_change_after_relogin`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_operations.py::test_chat_offline_recipient_receives_content_change_after_relogin`
- 业务说明：B 已收消息后离线，A 修改正文；B 重登收到修改事件和最终正文
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：B 已收消息后离线，A 修改正文；B 重登收到修改事件和最终正文。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、from、to、convId、chatType、direction、status、hasRead、hasDeliverAck、content、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 101. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_delivery.py::test_chat_offline_deliver_online_only_not_received_after_login`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_offline_message_delivery.py::test_chat_offline_deliver_online_only_not_received_after_login`
- 业务说明：CMD 设置 deliver在线Only=true 时，不进入离线 B 的本地消息库
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：CMD 设置 deliver在线Only=true 时，不进入离线 B 的本地消息库。
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 102. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_send_boundaries.py::test_chat_message_type_rejects_missing_required_payload[location-missing-latitude]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_send_boundaries.py::test_chat_message_type_rejects_missing_required_payload[location-missing-latitude]`
- 业务说明：5.0 发送消息 路线：缺 payload 必填字段时 swt_to_发送 用默认值填充为消息默认值， 消息构造成功并发送；原生 SDK 实测接受空字段消息（消息发送成功回调），不拒绝
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：5.0 发送消息 路线：缺 payload 必填字段时 swt_to_发送 用默认值填充为消息默认值， 消息构造成功并发送；原生 SDK 实测接受空字段消息（消息发送成功回调），不拒绝。
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、chatType、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 103. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_send_boundaries.py::test_chat_message_type_rejects_missing_required_payload[location-missing-longitude]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_send_boundaries.py::test_chat_message_type_rejects_missing_required_payload[location-missing-longitude]`
- 业务说明：5.0 发送消息 路线：缺 payload 必填字段时 swt_to_发送 用默认值填充为消息默认值， 消息构造成功并发送；原生 SDK 实测接受空字段消息（消息发送成功回调），不拒绝
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：5.0 发送消息 路线：缺 payload 必填字段时 swt_to_发送 用默认值填充为消息默认值， 消息构造成功并发送；原生 SDK 实测接受空字段消息（消息发送成功回调），不拒绝。
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、chatType、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 104. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_send_boundaries.py::test_chat_message_type_rejects_missing_required_payload[custom-missing-event]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_send_boundaries.py::test_chat_message_type_rejects_missing_required_payload[custom-missing-event]`
- 业务说明：5.0 发送消息 路线：缺 payload 必填字段时 swt_to_发送 用默认值填充为消息默认值， 消息构造成功并发送；原生 SDK 实测接受空字段消息（消息发送成功回调），不拒绝
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：5.0 发送消息 路线：缺 payload 必填字段时 swt_to_发送 用默认值填充为消息默认值， 消息构造成功并发送；原生 SDK 实测接受空字段消息（消息发送成功回调），不拒绝。
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、chatType、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 105. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_send_boundaries.py::test_chat_message_type_rejects_missing_required_payload[cmd-missing-action]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_send_boundaries.py::test_chat_message_type_rejects_missing_required_payload[cmd-missing-action]`
- 业务说明：5.0 发送消息 路线：缺 payload 必填字段时 swt_to_发送 用默认值填充为消息默认值， 消息构造成功并发送；原生 SDK 实测接受空字段消息（消息发送成功回调），不拒绝
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：5.0 发送消息 路线：缺 payload 必填字段时 swt_to_发送 用默认值填充为消息默认值， 消息构造成功并发送；原生 SDK 实测接受空字段消息（消息发送成功回调），不拒绝。
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、chatType、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 106. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_send_boundaries.py::test_chat_message_type_rejects_missing_required_payload[txt-missing-content]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_send_boundaries.py::test_chat_message_type_rejects_missing_required_payload[txt-missing-content]`
- 业务说明：5.0 发送消息 路线：缺 payload 必填字段时 swt_to_发送 用默认值填充为消息默认值， 消息构造成功并发送；原生 SDK 实测接受空字段消息（消息发送成功回调），不拒绝
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：5.0 发送消息 路线：缺 payload 必填字段时 swt_to_发送 用默认值填充为消息默认值， 消息构造成功并发送；原生 SDK 实测接受空字段消息（消息发送成功回调），不拒绝。
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、chatType、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 107. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_load_all_conversations_contains_target_conversation`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_load_all_conversations_contains_target_conversation`
- 业务说明：5.0 会话改本地读取（loadAll会话列表）：发消息后本地会话列表含目标会话（原 获取会话列表FromServer 服务端拉取已移除）
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：5.0 会话改本地读取（loadAll会话列表）：发消息后本地会话列表含目标会话（原 获取会话列表FromServer 服务端拉取已移除）。
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：convId、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 108. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s3_non_message_ops.py::test_chat_fetch_history_messages_by_options_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s3_non_message_ops.py::test_chat_fetch_history_messages_by_options_success`
- 业务说明：按查询条件获取历史消息 成功
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：按查询条件获取历史消息 成功
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：msgId、convId、content、result、list、cursor。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 109. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s3_non_message_ops.py::test_chat_fetch_history_messages_by_options_empty_conv_id`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s3_non_message_ops.py::test_chat_fetch_history_messages_by_options_empty_conv_id`
- 业务说明：按查询条件获取历史消息 使用空会话
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：按查询条件获取历史消息 使用空会话
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 110，错误描述“Invalid parameter”。
  2. 校验关键字段：convId、cursor。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 110. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_crud.py::test_chat_fetch_history_by_options_invalid_conversation`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_crud.py::test_chat_fetch_history_by_options_invalid_conversation`
- 业务说明：使用无效会话按查询条件获取历史消息
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：使用无效会话按查询条件获取历史消息
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：convId、result、list、cursor。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 111. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s3_non_message_ops.py::test_chat_fetch_history_messages_by_options_invalid_conv_id`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s3_non_message_ops.py::test_chat_fetch_history_messages_by_options_invalid_conv_id`
- 业务说明：使用无效会话按查询条件获取历史消息
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：使用无效会话按查询条件获取历史消息
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：convId、cursor。

### 112. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_crud.py::test_chat_recall_message_invalid_id_response`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_crud.py::test_chat_recall_message_invalid_id_response`
- 业务说明：撤回 消息 无效 id 响应
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：撤回 消息 无效 id 响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：msgId、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 113. `im_flutter_sdk/native-auto-test/tests/chat/test_chat.py::test_chat_recall_message_invalid_id_response`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat.py::test_chat_recall_message_invalid_id_response`
- 业务说明：撤回不存在的消息，不应产生 消息撤回回调 事件
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：撤回 消息 无效 id 响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 114. `im_flutter_sdk/native-auto-test/tests/chat/test_chat.py::test_chat_send_to_self_should_not_succeed`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat.py::test_chat_send_to_self_should_not_succeed`
- 业务说明：发送 给自己 should not succeed
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：发送 给自己 should not succeed
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、from、to、convId、chatType、direction、status、hasRead、content、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 115. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_search_db.py::test_chat_search_chat_msg_from_db_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_search_db.py::test_chat_search_chat_msg_from_db_success`
- 业务说明：发送带唯一关键词的文本；按关键词本地搜索应命中
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：发送带唯一关键词的文本；按关键词本地搜索应命中。
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result、list。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 116. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_manager_remaining_api_coverage.py::test_chat_manager_send_to_non_friend_current_success_event`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_manager_remaining_api_coverage.py::test_chat_manager_send_to_non_friend_current_success_event`
- 业务说明：发送消息：向 user_c 发送单聊消息，按当前真实返回冻结为成功回调
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：发送消息：向 user_c 发送单聊消息，按当前真实返回冻结为成功回调。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、from、to、convId、chatType、direction、status、hasRead、content、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 117. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_crud.py::test_chat_send_to_self_event`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_crud.py::test_chat_send_to_self_event`
- 业务说明：发消息给自己：发送账号主端收到成功事件（5.0 self 消息无接收事件，不验证副端接收）
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：发消息给自己：主端收到成功事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、from、to、convId、chatType、direction、status、hasRead、content、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 118. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_reaction_fetch.py::test_chat_add_reaction_too_long_reaction`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_reaction_fetch.py::test_chat_add_reaction_too_long_reaction`
- 业务说明：分别验证正常长度与超长 消息 Reaction，避免同一消息的异步操作互相竞争
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：添加 消息 Reaction 超长 消息 Reaction；使用独立消息隔离异步操作状态。
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 119. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_crud.py::test_chat_get_message_invalid_id_returns_none`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_crud.py::test_chat_get_message_invalid_id_returns_none`
- 业务说明：官方结构：获取消息 无效 消息 ID → null（wrapper 基类 发送成功回调(null) → 真 null，对齐官方经 Dart 归一化）
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：官方结构：获取消息 无效 消息 ID → null（wrapper 基类 发送成功回调(null) → 真 null，对齐官方经 Dart 归一化）。
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：msgId、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 120. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_modification_matrix.py::test_chat_modify_message_empty_id`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_modification_matrix.py::test_chat_modify_message_empty_id`
- 业务说明：官方结构移植：修改消息 空 消息 ID → 错误
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：官方结构移植：修改消息 空 消息 ID → 错误。
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：msgId、content、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 121. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_modification_matrix.py::test_chat_modify_text_body_and_attributes[body-and-attributes]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_modification_matrix.py::test_chat_modify_text_body_and_attributes[body-and-attributes]`
- 业务说明：官方结构移植：修改消息 修改正文/属性/两者
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：官方结构移植：修改消息 修改正文/属性/两者。当前环境实测 305（edit not available，待研发）。
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、from、to、convId、chatType、direction、status、hasRead、hasDeliverAck、content、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 122. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_modification_matrix.py::test_chat_modify_text_body_and_attributes[body]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_modification_matrix.py::test_chat_modify_text_body_and_attributes[body]`
- 业务说明：官方结构移植：修改消息 修改正文/属性/两者
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：官方结构移植：修改消息 修改正文/属性/两者。当前环境实测 305（edit not available，待研发）。
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、from、to、convId、chatType、direction、status、hasRead、hasDeliverAck、content、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 123. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_modification_matrix.py::test_chat_modify_text_body_and_attributes[attributes]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_modification_matrix.py::test_chat_modify_text_body_and_attributes[attributes]`
- 业务说明：官方结构移植：修改消息 修改正文/属性/两者
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：官方结构移植：修改消息 修改正文/属性/两者。当前环境实测 305（edit not available，待研发）。
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、from、to、convId、chatType、direction、status、hasRead、hasDeliverAck、content、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 124. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_send_boundaries.py::test_chat_combine_message_rejects_empty_source_ids`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_send_boundaries.py::test_chat_combine_message_rejects_empty_source_ids`
- 业务说明：合并消息来源 ID 为空时应进入失败终态，B 不得收到该合并消息
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：合并消息来源 ID 为空时应进入失败终态，B 不得收到该合并消息。
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 110。
  2. 校验关键字段：msgId、to、chatType、direction、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 125. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_conversation_cursor_pagination.py::test_chat_conversation_pinned_and_marked_cursor_pagination`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_conversation_cursor_pagination.py::test_chat_conversation_pinned_and_marked_cursor_pagination`
- 业务说明：会话 置顶 and marked cursor pagination
- 类型：普通
- 状态/版本说明：5.0 不可用
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：会话 置顶 and marked cursor pagination
     - 预期：该原测试目标在 5.0 中不再成立。5.0 已移除服务端会话查询，改用本地会话列表。
- 关键断言：
  1. 校验关键字段：convId、result、cursor。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 126. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_conversation_marks_boundaries.py::test_chat_conversation_mark_idempotent_and_remove_unmarked`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_conversation_marks_boundaries.py::test_chat_conversation_mark_idempotent_and_remove_unmarked`
- 业务说明：会话 mark idempotent and 删除 unmarked
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：会话 mark idempotent and 删除 unmarked
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：convId、result、cursor。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 127. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_conversation_pin_additional.py::test_chat_conversation_pin_and_unpin_are_idempotent`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_conversation_pin_additional.py::test_chat_conversation_pin_and_unpin_are_idempotent`
- 业务说明：会话 pin and unpin are idempotent
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：会话 pin and unpin are idempotent
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验关键字段：convId、result、cursor。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 128. `im_flutter_sdk/native-auto-test/tests/chat/test_conversation_remaining_api_coverage.py::test_conversation_delete_local_and_server_messages_by_time`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_conversation_remaining_api_coverage.py::test_conversation_delete_local_and_server_messages_by_time`
- 业务说明：会话删除服务端消息按时间：按时间删除本地及服务端消息，冻结当前返回
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：会话删除服务端消息按时间：按时间删除本地及服务端消息，冻结当前返回。
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：content、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 129. `im_flutter_sdk/native-auto-test/tests/chat/test_conversation_remaining_api_coverage.py::test_conversation_delete_local_and_server_messages_current_behavior`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_conversation_remaining_api_coverage.py::test_conversation_delete_local_and_server_messages_current_behavior`
- 业务说明：会话删除服务端消息WithIds：按消息 ID 删除本地及服务端消息，冻结当前返回
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：会话删除服务端消息WithIds：按消息 ID 删除本地及服务端消息，冻结当前返回。
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：content、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 130. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s1_local_conversation.py::test_chat_get_conversation_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s1_local_conversation.py::test_chat_get_conversation_success`
- 业务说明：获取 会话 成功
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：获取 会话 成功
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：convId、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 131. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s1_local_conversation.py::test_chat_get_conversation_empty_conv_id`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s1_local_conversation.py::test_chat_get_conversation_empty_conv_id`
- 业务说明：获取 会话 使用空会话
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：获取 会话 使用空会话
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：convId。

### 132. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_conversation_marks_boundaries.py::test_chat_fetch_conversation_marks_boundaries[info0]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_conversation_marks_boundaries.py::test_chat_fetch_conversation_marks_boundaries[info0]`
- 业务说明：获取 会话 marks boundaries
- 类型：普通
- 状态/版本说明：5.0 不可用
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：获取 会话 marks boundaries
     - 预期：该原测试目标在 5.0 中不再成立。移除 获取会话列表By查询条件（残留，本地全量无分页/查询条件 校验）
- 关键断言：
  1. 校验关键字段：result、list。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 133. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_conversation_marks_boundaries.py::test_chat_fetch_conversation_marks_boundaries[info1]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_conversation_marks_boundaries.py::test_chat_fetch_conversation_marks_boundaries[info1]`
- 业务说明：获取 会话 marks boundaries
- 类型：普通
- 状态/版本说明：5.0 不可用
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：获取 会话 marks boundaries
     - 预期：该原测试目标在 5.0 中不再成立。移除 获取会话列表By查询条件（残留，本地全量无分页/查询条件 校验）
- 关键断言：
  1. 校验关键字段：result、list。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 134. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_conversation_marks_boundaries.py::test_chat_fetch_conversation_marks_boundaries[info2]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_conversation_marks_boundaries.py::test_chat_fetch_conversation_marks_boundaries[info2]`
- 业务说明：获取 会话 marks boundaries
- 类型：普通
- 状态/版本说明：5.0 不可用
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：获取 会话 marks boundaries
     - 预期：该原测试目标在 5.0 中不再成立。移除 获取会话列表By查询条件（残留，本地全量无分页/查询条件 校验）
- 关键断言：
  1. 校验关键字段：result、list。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 135. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_conversation_marks_boundaries.py::test_chat_fetch_conversation_marks_boundaries[info3]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_conversation_marks_boundaries.py::test_chat_fetch_conversation_marks_boundaries[info3]`
- 业务说明：获取 会话 marks boundaries
- 类型：普通
- 状态/版本说明：5.0 不可用
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：获取 会话 marks boundaries
     - 预期：该原测试目标在 5.0 中不再成立。移除 获取会话列表By查询条件（残留，本地全量无分页/查询条件 校验）
- 关键断言：
  1. 校验关键字段：result、list。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 136. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_conversation_marks_boundaries.py::test_chat_fetch_conversation_marks_boundaries[info4]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_conversation_marks_boundaries.py::test_chat_fetch_conversation_marks_boundaries[info4]`
- 业务说明：获取 会话 marks boundaries
- 类型：普通
- 状态/版本说明：5.0 不可用
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：获取 会话 marks boundaries
     - 预期：该原测试目标在 5.0 中不再成立。移除 获取会话列表By查询条件（残留，本地全量无分页/查询条件 校验）
- 关键断言：
  1. 校验关键字段：result、list。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 137. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s1_local_conversation.py::test_chat_get_conversation_not_exist_without_create`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s1_local_conversation.py::test_chat_get_conversation_not_exist_without_create`
- 业务说明：获取 会话 not exist without 创建
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：获取 会话 not exist without 创建
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：convId。

### 138. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_fetch_conversations_from_server_with_page_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_fetch_conversations_from_server_with_page_success`
- 业务说明：获取 会话列表 从服务端 带分页 成功
- 类型：普通
- 状态/版本说明：5.0 不可用
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：获取 会话列表 从服务端 带分页 成功
     - 预期：该原测试目标在 5.0 中不再成立。5.0 已移除服务端会话查询，改用本地会话列表。
- 关键断言：
  1. 校验关键字段：convId、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 139. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_fetch_conversations_from_server_with_page_invalid_page_size_zero`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_fetch_conversations_from_server_with_page_invalid_page_size_zero`
- 业务说明：获取 会话列表 从服务端 带分页 无效 分页大小 0
- 类型：普通
- 状态/版本说明：5.0 不可用
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：获取 会话列表 从服务端 带分页 无效 分页大小 0
     - 预期：该原测试目标在 5.0 中不再成立。5.0 已移除服务端会话查询，改用本地会话列表。
- 关键断言：
  1. 校验关键字段：convId、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 140. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_fetch_conversations_from_server_with_page_invalid_page_num_zero`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_fetch_conversations_from_server_with_page_invalid_page_num_zero`
- 业务说明：获取 会话列表 从服务端 带分页 无效 页码 0
- 类型：普通
- 状态/版本说明：5.0 不可用
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：获取 会话列表 从服务端 带分页 无效 页码 0
     - 预期：该原测试目标在 5.0 中不再成立。5.0 已移除服务端会话查询，改用本地会话列表。
- 关键断言：
  1. 校验关键字段：convId、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 141. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_get_conversations_from_server_with_cursor_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_get_conversations_from_server_with_cursor_success`
- 业务说明：获取 会话列表 从服务端 带游标 成功
- 类型：普通
- 状态/版本说明：5.0 不可用
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：获取 会话列表 从服务端 带游标 成功
     - 预期：该原测试目标在 5.0 中不再成立。5.0 已移除服务端会话查询，改用本地会话列表。
- 关键断言：
  1. 校验关键字段：convId、result、list、cursor。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 142. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_get_conversations_from_server_with_cursor_invalid_page_size_zero`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_get_conversations_from_server_with_cursor_invalid_page_size_zero`
- 业务说明：获取 会话列表 从服务端 带游标 无效 分页大小 0
- 类型：普通
- 状态/版本说明：5.0 不可用
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：获取 会话列表 从服务端 带游标 无效 分页大小 0
     - 预期：该原测试目标在 5.0 中不再成立。5.0 已移除游标分页语义，查询结果改为本地列表。
- 关键断言：
  1. 校验关键字段：result、list、cursor。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 143. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_get_conversations_from_server_with_cursor_invalid_page_size_negative`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_get_conversations_from_server_with_cursor_invalid_page_size_negative`
- 业务说明：获取 会话列表 从服务端 带游标 无效 分页大小 negative
- 类型：普通
- 状态/版本说明：5.0 不可用
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：获取 会话列表 从服务端 带游标 无效 分页大小 negative
     - 预期：该原测试目标在 5.0 中不再成立。5.0 已移除游标分页语义，查询结果改为本地列表。
- 关键断言：
  1. 校验关键字段：result、list、cursor。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 144. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_reaction_fetch.py::test_chat_fetch_reaction_detail_empty_reaction`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_reaction_fetch.py::test_chat_fetch_reaction_detail_empty_reaction`
- 业务说明：获取 消息 Reaction 详情 传入空 消息 Reaction；应返回参数错误
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：获取 消息 Reaction 详情 传入空 消息 Reaction；应返回参数错误。
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：msgId、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 145. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_reaction_fetch.py::test_chat_fetch_reaction_detail_invalid_page_size`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_reaction_fetch.py::test_chat_fetch_reaction_detail_invalid_page_size`
- 业务说明：获取 消息 Reaction 详情 非法 pageSize（-1）；应返回参数错误
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：获取 消息 Reaction 详情 非法 pageSize（-1）；应返回参数错误。
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：msgId、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 146. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_reaction_fetch.py::test_chat_fetch_reaction_detail_invalid`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_reaction_fetch.py::test_chat_fetch_reaction_detail_invalid`
- 业务说明：获取 消息 Reaction 详情 使用无效 消息 ID/消息 Reaction；先校验信封
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：获取 消息 Reaction 详情 使用无效 消息 ID/消息 Reaction；先校验信封。
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：msgId、result、list、cursor。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 147. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_get_pinned_conversations_from_server_with_cursor_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_get_pinned_conversations_from_server_with_cursor_success`
- 业务说明：获取 置顶 会话列表 从服务端 带游标 成功
- 类型：普通
- 状态/版本说明：5.0 不可用
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：获取 置顶 会话列表 从服务端 带游标 成功
     - 预期：该原测试目标在 5.0 中不再成立。5.0 已移除服务端会话查询，改用本地会话列表。
- 关键断言：
  1. 校验关键字段：result、list、cursor。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 148. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_get_pinned_conversations_from_server_with_cursor_invalid_page_size_zero`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_get_pinned_conversations_from_server_with_cursor_invalid_page_size_zero`
- 业务说明：获取 置顶 会话列表 从服务端 带游标 无效 分页大小 0
- 类型：普通
- 状态/版本说明：5.0 不可用
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：获取 置顶 会话列表 从服务端 带游标 无效 分页大小 0
     - 预期：该原测试目标在 5.0 中不再成立。5.0 已移除游标分页语义，查询结果改为本地列表。
- 关键断言：
  1. 校验关键字段：result、list、cursor。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 149. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_get_pinned_conversations_from_server_with_cursor_invalid_page_size_negative`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_get_pinned_conversations_from_server_with_cursor_invalid_page_size_negative`
- 业务说明：获取 置顶 会话列表 从服务端 带游标 无效 分页大小 negative
- 类型：普通
- 状态/版本说明：5.0 不可用
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：获取 置顶 会话列表 从服务端 带游标 无效 分页大小 negative
     - 预期：该原测试目标在 5.0 中不再成立。5.0 已移除游标分页语义，查询结果改为本地列表。
- 关键断言：
  1. 校验关键字段：result、list、cursor。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 150. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_conversation_pin_additional.py::test_chat_fetch_pinned_conversations_page_size_boundaries[-1-expected1]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_conversation_pin_additional.py::test_chat_fetch_pinned_conversations_page_size_boundaries[-1-expected1]`
- 业务说明：获取 置顶 会话列表 分页大小 boundaries
- 类型：普通
- 状态/版本说明：5.0 不可用
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：获取 置顶 会话列表 分页大小 boundaries
     - 预期：该原测试目标在 5.0 中不再成立。5.0 已移除游标分页语义，查询结果改为本地列表。
- 关键断言：
  1. 校验关键字段：result、cursor。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 151. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_conversation_pin_additional.py::test_chat_fetch_pinned_conversations_page_size_boundaries[0-expected0]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_conversation_pin_additional.py::test_chat_fetch_pinned_conversations_page_size_boundaries[0-expected0]`
- 业务说明：获取 置顶 会话列表 分页大小 boundaries
- 类型：普通
- 状态/版本说明：5.0 不可用
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：获取 置顶 会话列表 分页大小 boundaries
     - 预期：该原测试目标在 5.0 中不再成立。5.0 已移除游标分页语义，查询结果改为本地列表。
- 关键断言：
  1. 校验关键字段：result、cursor。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 152. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_conversation_pin_additional.py::test_chat_fetch_pinned_conversations_page_size_boundaries[1000-expected2]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_conversation_pin_additional.py::test_chat_fetch_pinned_conversations_page_size_boundaries[1000-expected2]`
- 业务说明：获取 置顶 会话列表 分页大小 boundaries
- 类型：普通
- 状态/版本说明：5.0 不可用
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：获取 置顶 会话列表 分页大小 boundaries
     - 预期：该原测试目标在 5.0 中不再成立。5.0 已移除游标分页语义，查询结果改为本地列表。
- 关键断言：
  1. 校验关键字段：result、cursor。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 153. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_pin_boundaries.py::test_chat_fetch_pinned_messages_invalid_conversation[]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_pin_boundaries.py::test_chat_fetch_pinned_messages_invalid_conversation[]`
- 业务说明：获取 置顶 消息 使用无效会话
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：获取 置顶 消息 使用无效会话
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：convId。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 154. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_pin_boundaries.py::test_chat_fetch_pinned_messages_invalid_conversation[__invalid_pin_conversation__]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_pin_boundaries.py::test_chat_fetch_pinned_messages_invalid_conversation[__invalid_pin_conversation__]`
- 业务说明：获取 置顶 消息 使用无效会话
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：获取 置顶 消息 使用无效会话
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：convId。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 155. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_crud.py::test_chat_fetch_support_languages_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_crud.py::test_chat_fetch_support_languages_success`
- 业务说明：获取 support 语言 成功
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：获取 support 语言 成功
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result、list。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 156. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s1_local_conversation.py::test_chat_get_unread_count_positive_then_zero`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s1_local_conversation.py::test_chat_get_unread_count_positive_then_zero`
- 业务说明：获取 unread count positive then 0
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：获取 unread count positive then 0
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 157. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s3_non_message_ops.py::test_chat_fetch_history_messages_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s3_non_message_ops.py::test_chat_fetch_history_messages_success`
- 业务说明：获取历史消息 成功
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：获取历史消息 成功
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：msgId、convId、direction、content、result、list。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 158. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_attachment_download_and_history_boundaries.py::test_chat_fetch_history_page_size_one_cursor`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_attachment_download_and_history_boundaries.py::test_chat_fetch_history_page_size_one_cursor`
- 业务说明：获取历史消息 分页大小 one cursor
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：获取历史消息 分页大小 one cursor
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：msgId、convId、hasDeliverAck、content、result、list、cursor。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 159. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s3_non_message_ops.py::test_chat_fetch_history_messages_empty_conv_id`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s3_non_message_ops.py::test_chat_fetch_history_messages_empty_conv_id`
- 业务说明：获取历史消息 使用空会话
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：获取历史消息 使用空会话
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：convId、direction、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 160. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_crud.py::test_chat_fetch_history_invalid_conversation`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_crud.py::test_chat_fetch_history_invalid_conversation`
- 业务说明：使用无效会话获取历史消息
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备B已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：使用无效会话获取历史消息
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：convId、direction、result、list、cursor。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 161. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s3_non_message_ops.py::test_chat_fetch_history_messages_invalid_conv_id`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s3_non_message_ops.py::test_chat_fetch_history_messages_invalid_conv_id`
- 业务说明：获取历史消息 使用无效会话
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：获取历史消息 使用无效会话
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：convId、direction。

### 162. `im_flutter_sdk/native-auto-test/tests/chat/test_chat.py::test_chat_get_message_invalid_id_returns_none_or_error`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat.py::test_chat_get_message_invalid_id_returns_none_or_error`
- 业务说明：获取消息 使用无效 消息 ID：WS_RELAX=1 观察到唯一返回为 result=None，锁定为单一预期
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：获取 消息 无效 id returns none or error
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：msgId、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 163. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_manager_remaining_api_coverage.py::test_chat_manager_message_count_and_search_options_boundaries`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_manager_remaining_api_coverage.py::test_chat_manager_message_count_and_search_options_boundaries`
- 业务说明：获取消息Count/searchMsgsBy查询条件：校验全量消息计数返回数值，以及 count=0 搜索边界返回空列表
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：获取消息Count/searchMsgsBy查询条件：校验全量消息计数返回数值，以及 count=0 搜索边界返回空列表。
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：from、direction、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 164. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s4_local_keyword_search.py::test_chat_load_conversation_messages_with_keyword_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s4_local_keyword_search.py::test_chat_load_conversation_messages_with_keyword_success`
- 业务说明：加载 会话 消息 带 关键词 成功
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：加载 会话 消息 带 关键词 成功
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：direction、content、result、list。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 165. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s4_local_keyword_search.py::test_chat_load_conversation_messages_with_keyword_no_hit`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s4_local_keyword_search.py::test_chat_load_conversation_messages_with_keyword_no_hit`
- 业务说明：加载 会话 消息 带 关键词 无匹配
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：加载 会话 消息 带 关键词 无匹配
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：direction、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 166. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s4_load_messages_by_ids.py::test_chat_load_messages_with_ids_single_and_multi_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s4_load_messages_by_ids.py::test_chat_load_messages_with_ids_single_and_multi_success`
- 业务说明：加载 消息 带 ids 单个和多个 成功
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：加载 消息 带 ids 单个和多个 成功
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 167. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s4_load_messages_by_ids.py::test_chat_load_messages_with_ids_empty_ids`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s4_load_messages_by_ids.py::test_chat_load_messages_with_ids_empty_ids`
- 业务说明：加载 消息 带 ids 空 ids
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：加载 消息 带 ids 空 ids
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 168. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s1_local_conversation.py::test_chat_load_all_conversations_contains_then_not_contains`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s1_local_conversation.py::test_chat_load_all_conversations_contains_then_not_contains`
- 业务说明：加载 all 会话列表 contains then not contains
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：加载 all 会话列表 contains then not contains
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：convId、result、list。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 169. `im_flutter_sdk/native-auto-test/tests/chat/test_conversation_remaining_api_coverage.py::test_conversation_load_message_and_message_lists`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_conversation_remaining_api_coverage.py::test_conversation_load_message_and_message_lists`
- 业务说明：加载消息/加载消息/加载消息FromTime：发送后按 ID、数量和时间窗口加载当前消息
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：加载消息/加载消息/加载消息FromTime：发送后按 ID、数量和时间窗口加载当前消息。
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：msgId、direction、status、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 170. `im_flutter_sdk/native-auto-test/tests/chat/test_conversation_remaining_api_coverage.py::test_conversation_invalid_message_id_boundaries`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_conversation_remaining_api_coverage.py::test_conversation_invalid_message_id_boundaries`
- 业务说明：加载消息/mark消息AsRead/删除消息ByIds：非法消息 ID 边界，冻结当前端真实返回语义
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：加载消息/mark消息AsRead/删除消息ByIds：非法消息 ID 边界，冻结当前端真实返回语义。
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：msgId、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 171. `im_flutter_sdk/native-auto-test/tests/chat/test_conversation_remaining_api_coverage.py::test_conversation_type_keyword_and_options_search_current_behavior`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_conversation_remaining_api_coverage.py::test_conversation_type_keyword_and_options_search_current_behavior`
- 业务说明：加载消息WithMsgType/加载消息WithKeyword/会话列表earchMsgsBy查询条件：使用空数量/唯一关键词边界冻结空列表返回
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：加载消息WithMsgType/加载消息WithKeyword/会话列表earchMsgsBy查询条件：使用空数量/唯一关键词边界冻结空列表返回。
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：from、direction、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 172. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_send_boundaries.py::test_chat_message_send_target_boundaries[empty-target]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_send_boundaries.py::test_chat_message_send_target_boundaries[empty-target]`
- 业务说明：空目标应失败；不存在用户按真实服务端语义发送成功；B 均不得误收目标消息
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：空目标应失败；不存在用户按真实服务端语义发送成功；B 均不得误收目标消息。
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、from、to、convId、chatType、direction、status、hasRead、hasDeliverAck、content、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 173. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_send_boundaries.py::test_chat_message_send_target_boundaries[nonexistent-target]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_send_boundaries.py::test_chat_message_send_target_boundaries[nonexistent-target]`
- 业务说明：空目标应失败；不存在用户按真实服务端语义发送成功；B 均不得误收目标消息
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：空目标应失败；不存在用户按真实服务端语义发送成功；B 均不得误收目标消息。
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、from、to、convId、chatType、direction、status、hasRead、hasDeliverAck、content、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 174. `im_flutter_sdk/native-auto-test/tests/chat/test_chat.py::test_chat_history_attach_lang_smoke_exists`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat.py::test_chat_history_attach_lang_smoke_exists`
- 业务说明：历史 attach lang smoke exists
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 测试账号已创建并登录，当前 Case 所需的基础数据已准备。
- 详细步骤与对应预期：
  1. 操作：历史 attach lang smoke exists
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 175. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_history_option_filters.py::test_chat_history_filters_direction_time_and_message_types`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_history_option_filters.py::test_chat_history_filters_direction_time_and_message_types`
- 业务说明：历史 filters direction time and 消息 types
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：历史 filters direction time and 消息 types
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、convId、direction、content、result、cursor。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 176. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_send_boundaries.py::test_chat_media_message_rejects_nonexistent_device_path[video]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_send_boundaries.py::test_chat_media_message_rejects_nonexistent_device_path[video]`
- 业务说明：媒体消息显式传入不存在 Android 路径时应失败，B 不得收到该媒体消息
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：媒体消息显式传入不存在 Android 路径时应失败，B 不得收到该媒体消息。
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 401。
  2. 校验关键字段：msgId、chatType、status、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 177. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_send_boundaries.py::test_chat_media_message_rejects_nonexistent_device_path[image]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_send_boundaries.py::test_chat_media_message_rejects_nonexistent_device_path[image]`
- 业务说明：媒体消息显式传入不存在 Android 路径时应失败，B 不得收到该媒体消息
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：媒体消息显式传入不存在 Android 路径时应失败，B 不得收到该媒体消息。
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 401。
  2. 校验关键字段：msgId、chatType、status、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 178. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_send_boundaries.py::test_chat_media_message_rejects_nonexistent_device_path[file]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_send_boundaries.py::test_chat_media_message_rejects_nonexistent_device_path[file]`
- 业务说明：媒体消息显式传入不存在 Android 路径时应失败，B 不得收到该媒体消息
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：媒体消息显式传入不存在 Android 路径时应失败，B 不得收到该媒体消息。
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 401。
  2. 校验关键字段：msgId、chatType、status、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 179. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_send_boundaries.py::test_chat_media_message_rejects_nonexistent_device_path[voice]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_send_boundaries.py::test_chat_media_message_rejects_nonexistent_device_path[voice]`
- 业务说明：媒体消息显式传入不存在 Android 路径时应失败，B 不得收到该媒体消息
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：媒体消息显式传入不存在 Android 路径时应失败，B 不得收到该媒体消息。
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 401。
  2. 校验关键字段：msgId、chatType、status、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 180. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s1_conversations_sort.py::test_chat_get_all_conversations_by_sort_orders_latest_first`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s1_conversations_sort.py::test_chat_get_all_conversations_by_sort_orders_latest_first`
- 业务说明：目标：验证 按时间获取全部会话并校验排序 返回的会话排序正确（最新消息会话优先）
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：目标：验证 按时间获取全部会话并校验排序 返回的会话排序正确（最新消息会话优先）。
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：convId、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 181. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_recall_and_message_read_ack.py::test_chat_missing_recall_empty_message_id`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_recall_and_message_read_ack.py::test_chat_missing_recall_empty_message_id`
- 业务说明：缺失 撤回 空 消息 ID
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：缺失 撤回 空 消息 ID
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：msgId、to、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 182. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_types_and_delivery.py::test_chat_missing_message_delivery_ack[custom-payload1]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_types_and_delivery.py::test_chat_missing_message_delivery_ack[custom-payload1]`
- 业务说明：缺失 消息 送达回执
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：缺失 消息 送达回执
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 183. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_types_and_delivery.py::test_chat_missing_message_delivery_ack[txt-payload0]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_types_and_delivery.py::test_chat_missing_message_delivery_ack[txt-payload0]`
- 业务说明：缺失 消息 送达回执
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：缺失 消息 送达回执
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 184. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_recall_and_message_read_ack.py::test_chat_missing_ack_message_read_boundaries[info0]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_recall_and_message_read_ack.py::test_chat_missing_ack_message_read_boundaries[info0]`
- 业务说明：缺失 ack 消息 read boundaries
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备B已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：缺失 ack 消息 read boundaries
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 185. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_recall_and_message_read_ack.py::test_chat_missing_ack_message_read_boundaries[info1]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_recall_and_message_read_ack.py::test_chat_missing_ack_message_read_boundaries[info1]`
- 业务说明：缺失 ack 消息 read boundaries
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备B已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：缺失 ack 消息 read boundaries
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 186. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_recall_and_message_read_ack.py::test_chat_missing_ack_message_read_boundaries[info2]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_recall_and_message_read_ack.py::test_chat_missing_ack_message_read_boundaries[info2]`
- 业务说明：缺失 ack 消息 read boundaries
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备B已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：缺失 ack 消息 read boundaries
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 187. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s1_local_conversation.py::test_chat_delete_conversation_existing_then_not_found`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s1_local_conversation.py::test_chat_delete_conversation_existing_then_not_found`
- 业务说明：删除 会话 existing then not found
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：删除 会话 existing then not found
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：convId。

### 188. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_conversation_marks_boundaries.py::test_chat_delete_conversation_mark_boundaries[info0]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_conversation_marks_boundaries.py::test_chat_delete_conversation_mark_boundaries[info0]`
- 业务说明：删除 会话 mark boundaries
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：删除 会话 mark boundaries
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result、cursor。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 189. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_conversation_marks_boundaries.py::test_chat_delete_conversation_mark_boundaries[info1]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_conversation_marks_boundaries.py::test_chat_delete_conversation_mark_boundaries[info1]`
- 业务说明：删除 会话 mark boundaries
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：删除 会话 mark boundaries
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result、cursor。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 190. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s1_local_conversation.py::test_chat_delete_conversation_nonexistent_returns_bool`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s1_local_conversation.py::test_chat_delete_conversation_nonexistent_returns_bool`
- 业务说明：删除 会话 nonexistent returns bool
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：删除 会话 nonexistent returns bool
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：convId、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 191. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_remove_messages_from_server_with_msg_ids_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_remove_messages_from_server_with_msg_ids_success`
- 业务说明：删除 消息 从服务端 带 消息 ids 成功
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：删除 消息 从服务端 带 消息 ids 成功
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：from、convId。

### 192. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_remove_messages_from_server_with_msg_ids_empty_msg_ids`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_remove_messages_from_server_with_msg_ids_empty_msg_ids`
- 业务说明：删除 消息 从服务端 带 消息 ids 空 消息 ids
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
- 详细步骤与对应预期：
  1. 操作：删除 消息 从服务端 带 消息 ids 空 消息 ids
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 110，错误描述“Invalid parameter”。
  2. 校验关键字段：from、convId。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 193. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_remove_messages_from_server_with_msg_ids_missing_msg_ids`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_remove_messages_from_server_with_msg_ids_missing_msg_ids`
- 业务说明：删除 消息 从服务端 带 消息 ids 缺失 消息 ids
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
- 详细步骤与对应预期：
  1. 操作：删除 消息 从服务端 带 消息 ids 缺失 消息 ids
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验异常返回：错误码 -1，错误描述“MissingPluginException”。
  2. 校验关键字段：convId。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 194. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_remove_messages_from_server_with_msg_ids_missing_conv_id`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_remove_messages_from_server_with_msg_ids_missing_conv_id`
- 业务说明：删除 消息 从服务端 带 消息 ids 缺失 conv id
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
- 详细步骤与对应预期：
  1. 操作：删除 消息 从服务端 带 消息 ids 缺失 conv id
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验异常返回：错误码 -1，错误描述“MissingPluginException”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 195. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_remove_messages_from_server_with_ts_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_remove_messages_from_server_with_ts_success`
- 业务说明：删除 消息 从服务端 带 ts 成功
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：删除 消息 从服务端 带 ts 成功
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：from、convId。

### 196. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_remove_messages_from_server_with_ts_missing_timestamp`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_remove_messages_from_server_with_ts_missing_timestamp`
- 业务说明：删除 消息 从服务端 带 ts 缺失 时间点
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
- 详细步骤与对应预期：
  1. 操作：删除 消息 从服务端 带 ts 缺失 时间点
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验异常返回：错误码 110，错误描述“Invalid parameter”。
  2. 校验关键字段：convId。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 197. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_remove_messages_from_server_with_ts_missing_conv_id`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_remove_messages_from_server_with_ts_missing_conv_id`
- 业务说明：删除 消息 从服务端 带 ts 缺失 conv id
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
- 详细步骤与对应预期：
  1. 操作：删除 消息 从服务端 带 ts 缺失 conv id
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验异常返回：错误码 -1，错误描述“MissingPluginException”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 198. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_remove_messages_from_server_with_ts_timestamp_zero`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_remove_messages_from_server_with_ts_timestamp_zero`
- 业务说明：删除 消息 从服务端 带 ts 时间点 0
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
- 详细步骤与对应预期：
  1. 操作：删除 消息 从服务端 带 ts 时间点 0
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验异常返回：错误码 110，错误描述“Invalid parameter”。
  2. 校验关键字段：from、convId。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 199. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_reaction_fetch.py::test_chat_remove_reaction_invalid_msg_id`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_reaction_fetch.py::test_chat_remove_reaction_invalid_msg_id`
- 业务说明：删除 消息 Reaction 使用无效 消息 ID；按不存在语义冻结
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：删除 消息 Reaction 使用无效 消息 ID；按不存在语义冻结。
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：msgId、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 200. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_crud.py::test_chat_remove_reaction_invalid_id_response`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_crud.py::test_chat_remove_reaction_invalid_id_response`
- 业务说明：删除 消息 消息 Reaction 无效 id 响应
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：删除 消息 Reaction 无效 id 响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：msgId、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 201. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_delete_remote_conversation_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_delete_remote_conversation_success`
- 业务说明：删除 remote 会话 成功
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：删除 remote 会话 成功
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：convId。

### 202. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_delete_remote_conversation_empty_conv_id`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_delete_remote_conversation_empty_conv_id`
- 业务说明：删除 remote 会话 使用空会话
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
- 详细步骤与对应预期：
  1. 操作：删除 remote 会话 使用空会话
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 303，错误描述“field channel cannot be null or empty”。
  2. 校验关键字段：convId。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 203. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_delete_remote_conversation_invalid_type`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_delete_remote_conversation_invalid_type`
- 业务说明：删除 remote 会话 无效 type
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：删除 remote 会话 无效 type
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：convId。

### 204. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s1_local_conversation.py::test_chat_delete_messages_before_timestamp_future_removes_msg`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s1_local_conversation.py::test_chat_delete_messages_before_timestamp_future_removes_msg`
- 业务说明：删除指定时间点之前的消息 未来时间点的删除结果
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：删除指定时间点之前的消息 未来时间点的删除结果
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：msgId。

### 205. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s1_local_conversation.py::test_chat_delete_messages_before_timestamp_zero_keeps_recent_msg`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s1_local_conversation.py::test_chat_delete_messages_before_timestamp_zero_keeps_recent_msg`
- 业务说明：删除指定时间点之前的消息，确认最近消息仍然保留
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：删除指定时间点之前的消息，确认最近消息仍然保留
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：msgId、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 206. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_manager_remaining_api_coverage.py::test_chat_manager_delete_all_message_and_conversation_local`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_manager_remaining_api_coverage.py::test_chat_manager_delete_all_message_and_conversation_local`
- 业务说明：删除All消息And会话：本地清空所有会话与消息，冻结 clearServerData=False 当前返回
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：删除All消息And会话：本地清空所有会话与消息，冻结 clearServerData=False 当前返回。
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 207. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_conversation_marks_boundaries.py::test_chat_add_conversation_mark_boundaries[info0]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_conversation_marks_boundaries.py::test_chat_add_conversation_mark_boundaries[info0]`
- 业务说明：添加 会话 mark boundaries
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：添加 会话 mark boundaries
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 208. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_conversation_marks_boundaries.py::test_chat_add_conversation_mark_boundaries[info1]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_conversation_marks_boundaries.py::test_chat_add_conversation_mark_boundaries[info1]`
- 业务说明：添加 会话 mark boundaries
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：添加 会话 mark boundaries
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 209. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_reaction_fetch.py::test_chat_add_reaction_special_char_reaction`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_reaction_fetch.py::test_chat_add_reaction_special_char_reaction`
- 业务说明：添加 消息 Reaction 特殊字符 消息 Reaction；按被测端实际语义冻结
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：添加 消息 Reaction 特殊字符 消息 Reaction；按被测端实际语义冻结。
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：msgId、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 210. `im_flutter_sdk/native-auto-test/tests/chat/test_chat.py::test_chat_add_reaction_empty_reaction_response`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat.py::test_chat_add_reaction_empty_reaction_response`
- 业务说明：添加空 消息 Reaction：先发送一条消息，再对该消息添加空 消息 Reaction，应视为无效（无事件）
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：添加 消息 Reaction 空 消息 Reaction 响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、from、to、convId、chatType、direction、status、hasRead、content、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 211. `im_flutter_sdk/native-auto-test/tests/chat/test_chat.py::test_chat_add_reaction_invalid_id_response`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat.py::test_chat_add_reaction_invalid_id_response`
- 业务说明：为不存在的消息添加 消息 Reaction，不应产生 消息ReactionDidChange
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：添加 消息 Reaction 无效 id 响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：msgId、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 212. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_crud.py::test_chat_download_attachment_invalid_id_response`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_crud.py::test_chat_download_attachment_invalid_id_response`
- 业务说明：下载 附件 无效 id 响应
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：下载 附件 无效 id 响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 500，错误描述“Message is invalid”。
  2. 校验关键字段：msgId、from、to、chatType、direction。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 213. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_attachment_download_and_history_boundaries.py::test_chat_download_attachment_for_text_message`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_attachment_download_and_history_boundaries.py::test_chat_download_attachment_for_text_message`
- 业务说明：下载 附件 用于 文本 消息
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：下载 附件 用于 文本 消息
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验关键字段：msgId、from、to、convId、chatType、direction、status、hasRead、hasDeliverAck、content、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 214. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_crud.py::test_chat_download_thumbnail_invalid_id_response`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_crud.py::test_chat_download_thumbnail_invalid_id_response`
- 业务说明：下载 缩略图 无效 id 响应
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：下载 缩略图 无效 id 响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 500，错误描述“Message is invalid”。
  2. 校验关键字段：msgId、from、to、chatType、direction。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 215. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_report_and_thumbnail_additional.py::test_chat_download_thumbnail_for_text_message`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_report_and_thumbnail_additional.py::test_chat_download_thumbnail_for_text_message`
- 业务说明：下载 缩略图 用于 文本 消息
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：下载 缩略图 用于 文本 消息
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、from、to、convId、chatType、direction、status、hasRead、content、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 216. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_modification_matrix.py::test_chat_modify_cmd_message_is_rejected`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_modification_matrix.py::test_chat_modify_cmd_message_is_rejected`
- 业务说明：修改 cmd 消息 应被拒绝
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：修改 cmd 消息 应被拒绝
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、to、chatType、direction、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 217. `im_flutter_sdk/native-auto-test/tests/chat/test_chat.py::test_chat_modify_message_invalid_id_response`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat.py::test_chat_modify_message_invalid_id_response`
- 业务说明：修改不存在的消息，不应产生 消息内容变更回调 事件
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：修改 消息 无效 id 响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、content、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 218. `im_flutter_sdk/native-auto-test/tests/chat/test_conversation_remaining_api_coverage.py::test_conversation_latest_and_last_received_messages`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_conversation_remaining_api_coverage.py::test_conversation_latest_and_last_received_messages`
- 业务说明：最新消息/last已接收消息：发送一条单聊消息后，分别校验发送方最新消息和接收方最近收到消息
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：最新消息/last已接收消息：发送一条单聊消息后，分别校验发送方最新消息和接收方最近收到消息。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验关键字段：msgId、from、to、convId、chatType、direction、status、hasRead、hasDeliverAck、content、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 219. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s3_non_message_ops.py::test_chat_ack_conversation_read_empty_conv_id`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s3_non_message_ops.py::test_chat_ack_conversation_read_empty_conv_id`
- 业务说明：ack 会话 read 使用空会话
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备B已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：ack 会话 read 使用空会话
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 110，错误描述“conversation not found”。
  2. 校验关键字段：convId。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 220. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s3_non_message_ops.py::test_chat_ack_conversation_read_invalid_conv_id`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s3_non_message_ops.py::test_chat_ack_conversation_read_invalid_conv_id`
- 业务说明：ack 会话 read 使用无效会话
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备B已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：ack 会话 read 使用无效会话
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 110，错误描述“conversation not found”。
  2. 校验关键字段：convId。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 221. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_crud.py::test_chat_ack_conversation_read_invalid_id_response`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_crud.py::test_chat_ack_conversation_read_invalid_id_response`
- 业务说明：ack 会话 read 无效 id 响应
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备B已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：ack 会话 read 无效 id 响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：convId、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 222. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_manager_remaining_api_coverage.py::test_chat_manager_conversation_marks_and_fetch_options`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_manager_remaining_api_coverage.py::test_chat_manager_conversation_marks_and_fetch_options`
- 业务说明：addRemoteAndLocal会话列表Mark/删除RemoteAndLocal会话列表Mark/获取会话列表By查询条件：添加会话标记后按 查询条件 查询，再移除标记
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：addRemoteAndLocal会话列表Mark/删除RemoteAndLocal会话列表Mark/获取会话列表By查询条件：添加会话标记后按 查询条件
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：convId、result、list、cursor。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 223. `im_flutter_sdk/native-auto-test/tests/chat/test_chat.py::test_chat_ack_conversation_read_invalid_id_response`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat.py::test_chat_ack_conversation_read_invalid_id_response`
- 业务说明：B 对一个不存在的会话调用 会话已读回执，A 不应在 5s 内收到 会话已读回调
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备B已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：ack 会话 read 无效 id 响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：convId、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 224. `im_flutter_sdk/native-auto-test/tests/chat/test_chat.py::test_chat_fetch_history_invalid_conversation`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat.py::test_chat_fetch_history_invalid_conversation`
- 业务说明：fetch历史消息 使用不存在的会话 id：严格断言响应形状；若成功体，结果应为空
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备B已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：使用无效会话获取历史消息
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：convId、direction、result、list、cursor。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 225. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_reaction_fetch.py::test_chat_fetch_reaction_list_invalid_msg_id`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_reaction_fetch.py::test_chat_fetch_reaction_list_invalid_msg_id`
- 业务说明：fetchReactionList 传入不存在的 消息 ID 列表；先断言信封
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：fetchReactionList 传入不存在的 消息 ID 列表；先断言信封。
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：msgId、chatType、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 226. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_reaction_fetch.py::test_chat_fetch_reaction_list_invalid_chat_type`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_reaction_fetch.py::test_chat_fetch_reaction_list_invalid_chat_type`
- 业务说明：fetchReactionList 传入非法 chatType；当前实现返回空 消息 Reaction 列表映射
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：fetchReactionList 传入非法 chatType；当前实现返回空 消息 Reaction 列表映射。
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：chatType、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 227. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_reaction_fetch.py::test_chat_fetch_reaction_list_empty_msg_ids`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_reaction_fetch.py::test_chat_fetch_reaction_list_empty_msg_ids`
- 业务说明：fetchReactionList 传入空 消息 IDs；应返回参数错误
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：fetchReactionList 传入空 消息 IDs；应返回参数错误。
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：chatType、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 228. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_conversation_pin_additional.py::test_chat_pin_conversation_non_boolean_coerces_to_unpin`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_conversation_pin_additional.py::test_chat_pin_conversation_non_boolean_coerces_to_unpin`
- 业务说明：Generic bridge 实测 Android 会将非布尔 isPinned 按 false 处理
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：Generic bridge 实测 Android 会将非布尔 isPinned 按 false 处理。
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验关键字段：convId、result、list、cursor。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 229. `im_flutter_sdk/native-auto-test/tests/chat/test_conversation_remaining_api_coverage.py::test_conversation_local_insert_append_update_and_delete`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_conversation_remaining_api_coverage.py::test_conversation_local_insert_append_update_and_delete`
- 业务说明：insert消息/append消息/update会话消息/删除消息/clearAll消息/删除消息WithTs：本地消息写入、更新和删除链路
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：insert消息/append消息/update会话消息/删除消息/clearAll消息/删除消息WithTs：本地消息写入、更新和删
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：msgId、from、to、convId、chatType、direction、status、hasRead、content、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 230. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s1_local_conversation.py::test_chat_mark_all_as_read_idempotent`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s1_local_conversation.py::test_chat_mark_all_as_read_idempotent`
- 业务说明：mark all as read idempotent
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备B已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：mark all as read idempotent
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 231. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_pin_boundaries.py::test_chat_pin_recalled_typed_message[location-payload0]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_pin_boundaries.py::test_chat_pin_recalled_typed_message[location-payload0]`
- 业务说明：pin 撤回 typed 消息
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：pin 撤回 typed 消息
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：msgId、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 232. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_pin_boundaries.py::test_chat_pin_recalled_typed_message[custom-payload1]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_pin_boundaries.py::test_chat_pin_recalled_typed_message[custom-payload1]`
- 业务说明：pin 撤回 typed 消息
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：pin 撤回 typed 消息
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：msgId、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 233. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s3_non_message_ops.py::test_chat_pin_conversation_success_toggle`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s3_non_message_ops.py::test_chat_pin_conversation_success_toggle`
- 业务说明：pin 会话 成功 toggle
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：pin 会话 成功 toggle
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验关键字段：convId、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 234. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s3_non_message_ops.py::test_chat_pin_conversation_empty_conv_id`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s3_non_message_ops.py::test_chat_pin_conversation_empty_conv_id`
- 业务说明：pin 会话 使用空会话
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：pin 会话 使用空会话
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 107，错误描述“Invalid conversation”。
  2. 校验关键字段：convId。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 235. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s3_non_message_ops.py::test_chat_pin_conversation_invalid_conv_id`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s3_non_message_ops.py::test_chat_pin_conversation_invalid_conv_id`
- 业务说明：pin 会话 使用无效会话
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：pin 会话 使用无效会话
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 107，错误描述“Invalid conversation”。
  2. 校验关键字段：convId。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 236. `im_flutter_sdk/native-auto-test/tests/chat/test_chat.py::test_chat_pin_conversation_nonexistent_conversation`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat.py::test_chat_pin_conversation_nonexistent_conversation`
- 业务说明：pin 会话 nonexistent 会话
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：pin 会话 nonexistent 会话
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 107，错误描述“Invalid conversation”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 237. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_crud.py::test_chat_pin_conversation_nonexistent_conversation`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_crud.py::test_chat_pin_conversation_nonexistent_conversation`
- 业务说明：pin 会话 nonexistent 会话
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：pin 会话 nonexistent 会话
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 107，错误描述“Invalid conversation”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 238. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_pin_boundaries.py::test_chat_pin_message_invalid_id`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_pin_boundaries.py::test_chat_pin_message_invalid_id`
- 业务说明：pin 消息 无效 id
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：pin 消息 无效 id
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：msgId。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 239. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_manager_remaining_api_coverage.py::test_chat_manager_message_object_boundary_methods`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_manager_remaining_api_coverage.py::test_chat_manager_message_object_boundary_methods`
- 业务说明：re发送消息/updateChat消息/import消息：使用本地构造消息对象覆盖重发、更新和导入的边界/当前返回
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：re发送消息/updateChat消息/import消息：使用本地构造消息对象覆盖重发、更新和导入的边界/当前返回。
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：msgId、from、to、convId、chatType、direction、status、hasRead、hasDeliverAck、content、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 240. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_report_message_boundaries.py::test_chat_report_recalled_message`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_report_message_boundaries.py::test_chat_report_recalled_message`
- 业务说明：report 撤回 消息
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：report 撤回 消息
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：msgId、content、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 241. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_report_message_boundaries.py::test_chat_report_text_message_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_report_message_boundaries.py::test_chat_report_text_message_success`
- 业务说明：report 文本 消息 成功
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：report 文本 消息 成功
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验关键字段：msgId、content、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 242. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_report_message_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_report_message_success`
- 业务说明：report 消息 成功
- 类型：普通
- 状态/版本说明：5.0 不可用
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：report 消息 成功
     - 预期：该原测试目标在 5.0 中不再成立。5.0 已移除消息举报能力。
- 关键断言：
  1. 校验关键字段：msgId。

### 243. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_report_message_boundaries.py::test_chat_report_message_empty_message_id`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_report_message_boundaries.py::test_chat_report_message_empty_message_id`
- 业务说明：report 消息 空 消息 ID
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：report 消息 空 消息 ID
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：msgId、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 244. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_report_message_boundaries.py::test_chat_report_message_empty_reason`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_report_message_boundaries.py::test_chat_report_message_empty_reason`
- 业务说明：report 消息 空 reason
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：report 消息 空 reason
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：msgId、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 245. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_report_message_boundaries.py::test_chat_report_message_empty_tag`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_report_message_boundaries.py::test_chat_report_message_empty_tag`
- 业务说明：report 消息 空 tag
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：report 消息 空 tag
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：msgId、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 246. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_report_message_missing_reason`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_report_message_missing_reason`
- 业务说明：report 消息 缺失 reason
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
- 详细步骤与对应预期：
  1. 操作：report 消息 缺失 reason
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 -1，错误描述“MissingPluginException”。
  2. 校验关键字段：msgId。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 247. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_report_message_missing_tag`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_report_message_missing_tag`
- 业务说明：report 消息 缺失 tag
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
- 详细步骤与对应预期：
  1. 操作：report 消息 缺失 tag
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 -1，错误描述“MissingPluginException”。
  2. 校验关键字段：msgId。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 248. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_report_message_invalid_msg_id`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_report_message_invalid_msg_id`
- 业务说明：report 消息 无效 消息 id
- 类型：普通
- 状态/版本说明：5.0 不可用
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
- 详细步骤与对应预期：
  1. 操作：report 消息 无效 消息 id
     - 预期：该原测试目标在 5.0 中不再成立。5.0 已移除消息举报能力。
- 关键断言：
  1. 校验异常返回：错误码 500，错误描述“message id is invalid”。
  2. 校验关键字段：msgId。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 249. `im_flutter_sdk/native-auto-test/tests/chat/test_conversation_remaining_api_coverage.py::test_conversation_ext_and_count_queries`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_conversation_remaining_api_coverage.py::test_conversation_ext_and_count_queries`
- 业务说明：sync会话Ext/消息Count/会话GetLocal消息Count/会话RemindType/置顶消息：校验会话扩展、计数、免打扰和置顶消息查询
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：sync会话Ext/消息Count/会话GetLocal消息Count/会话RemindType/置顶消息：校验会话扩展、计数、免打扰
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：msgId、content、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 250. `im_flutter_sdk/native-auto-test/tests/chat/test_chat.py::test_chat_translate_recall_smoke_exists`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat.py::test_chat_translate_recall_smoke_exists`
- 业务说明：translate 撤回 smoke exists
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 测试账号已创建并登录，当前 Case 所需的基础数据已准备。
- 详细步骤与对应预期：
  1. 操作：translate 撤回 smoke exists
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 251. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_translation_boundaries.py::test_chat_translate_message_empty_languages`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_translation_boundaries.py::test_chat_translate_message_empty_languages`
- 业务说明：translate 消息 空 语言
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：translate 消息 空 语言
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 当前测试步骤的同步响应、异步事件和最终业务状态满足代码断言。
  2. 任一关键字段、回调、列表、数量或最终状态不符时，Case 判定失败。

### 252. `im_flutter_sdk/native-auto-test/tests/chat/test_chat.py::test_chat_translate_message_nonexistent_message`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat.py::test_chat_translate_message_nonexistent_message`
- 业务说明：translate 消息 nonexistent 消息
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：translate 消息 nonexistent 消息
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验关键字段：msgId、from、to、chatType、direction、content、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 253. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_translation_boundaries.py::test_chat_translate_message_unsupported_language`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_translation_boundaries.py::test_chat_translate_message_unsupported_language`
- 业务说明：translate 消息 unsupported 语言
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：translate 消息 unsupported 语言
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 1110，错误描述“Translation parameter error”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 254. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_translation_boundaries.py::test_chat_translate_custom_message`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_translation_boundaries.py::test_chat_translate_custom_message`
- 业务说明：translate 自定义 消息
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：translate 自定义 消息
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 255. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_typed_message_pin_flows.py::test_chat_typed_message_pin_and_cross_user_unpin[sender-location-payload0]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_typed_message_pin_flows.py::test_chat_typed_message_pin_and_cross_user_unpin[sender-location-payload0]`
- 业务说明：typed 消息 pin and cross user unpin
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：typed 消息 pin and cross user unpin
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验关键字段：msgId、from、to、convId、chatType、direction、status、hasRead、hasDeliverAck、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 256. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_typed_message_pin_flows.py::test_chat_typed_message_pin_and_cross_user_unpin[sender-custom-payload1]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_typed_message_pin_flows.py::test_chat_typed_message_pin_and_cross_user_unpin[sender-custom-payload1]`
- 业务说明：typed 消息 pin and cross user unpin
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：typed 消息 pin and cross user unpin
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验关键字段：msgId、from、to、convId、chatType、direction、status、hasRead、hasDeliverAck、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 257. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_typed_message_pin_flows.py::test_chat_typed_message_pin_and_cross_user_unpin[receiver-location-payload0]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_typed_message_pin_flows.py::test_chat_typed_message_pin_and_cross_user_unpin[receiver-location-payload0]`
- 业务说明：typed 消息 pin and cross user unpin
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：typed 消息 pin and cross user unpin
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验关键字段：msgId、from、to、convId、chatType、direction、status、hasRead、hasDeliverAck、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 258. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_typed_message_pin_flows.py::test_chat_typed_message_pin_and_cross_user_unpin[receiver-custom-payload1]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_typed_message_pin_flows.py::test_chat_typed_message_pin_and_cross_user_unpin[receiver-custom-payload1]`
- 业务说明：typed 消息 pin and cross user unpin
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：typed 消息 pin and cross user unpin
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验关键字段：msgId、from、to、convId、chatType、direction、status、hasRead、hasDeliverAck、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 259. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_pin_boundaries.py::test_chat_unpin_message_empty_id`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_pin_boundaries.py::test_chat_unpin_message_empty_id`
- 业务说明：unpin 消息 空 id
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：unpin 消息 空 id
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：msgId。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 260. `im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_pin_boundaries.py::test_chat_unpin_message_invalid_id`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_chat_message_pin_boundaries.py::test_chat_unpin_message_invalid_id`
- 业务说明：unpin 消息 无效 id
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：unpin 消息 无效 id
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：msgId。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 261. `im_flutter_sdk/native-auto-test/tests/chat/test_conversation_remaining_api_coverage.py::test_conversation_read_count_and_mark_read`

- 代码：`im_flutter_sdk/native-auto-test/tests/chat/test_conversation_remaining_api_coverage.py::test_conversation_read_count_and_mark_read`
- 业务说明：unreadCount/mark消息AsRead/markAll消息AsRead：制造未读后按消息和按会话标记已读，校验计数清零
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：unreadCount/mark消息AsRead/markAll消息AsRead：制造未读后按消息和按会话标记已读，校验计数清零。
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：msgId、content、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

## chatroom

### 1. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_callbacks.py::test_chatroom_announcement_changed_callback`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_callbacks.py::test_chatroom_announcement_changed_callback`
- 业务说明：多端拓扑：A 更新聊天室公告；公告事件同步到 B 全部在线端
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：B 全部在线端加入聊天室
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：更新聊天室公告
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：确认更新公告请求已提交
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：B 全部在线端收到公告变更事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 2. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_callbacks.py::test_chatroom_admin_added_and_removed_callbacks`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_callbacks.py::test_chatroom_admin_added_and_removed_callbacks`
- 业务说明：多端拓扑：A 建聊天室并添加/移除 B 为管理员；事件同步到 B 全部在线端
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：B 全部在线端加入聊天室
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：添加 为聊天室管理员
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：确认添加管理员请求已提交
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：B 全部在线端收到管理员添加事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：移除 的聊天室管理员
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  6. 操作：确认移除管理员请求已提交
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  7. 操作：B 全部在线端收到管理员移除事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 3. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_callbacks.py::test_chatroom_owner_changed_callback`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_callbacks.py::test_chatroom_owner_changed_callback`
- 业务说明：多端拓扑：A 将聊天室 owner 转让给 B；owner 变更事件同步到 B 全部在线端
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：B 全部在线端加入聊天室
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：转让聊天室 owner 给
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：确认转让请求已提交
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  4. 操作：B 全部在线端收到 owner 变更事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 4. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_basics.py::test_chatroom_mute_fetch_unmute_member_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_basics.py::test_chatroom_mute_fetch_unmute_member_success`
- 业务说明：多端拓扑：A 禁言/解除 B；B 全部在线端加入，A 全部端查询禁言列表一致
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：B 全部在线端加入聊天室
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：禁言
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：确认禁言请求已提交
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  4. 操作：A 全部在线端查询禁言列表均含 B（账号级服务端状态一致）
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  5. 操作：解除 禁言
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  6. 操作：确认解除禁言请求已提交
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  7. 操作：A 全部在线端查询禁言列表均不含 B
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 5. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_callbacks.py::test_chatroom_mute_list_added_and_removed_callbacks`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_callbacks.py::test_chatroom_mute_list_added_and_removed_callbacks`
- 业务说明：多端拓扑：A 禁言/解除禁言 B；禁言事件同步到 B 全部在线端
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：B 全部在线端加入聊天室
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：禁言
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：确认禁言请求已提交
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  4. 操作：B 全部在线端收到禁言添加事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：解除 禁言
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  6. 操作：确认解除禁言请求已提交
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  7. 操作：B 全部在线端收到禁言移除事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：list。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 6. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_basics.py::test_chatroom_block_fetch_unblock_member_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_basics.py::test_chatroom_block_fetch_unblock_member_success`
- 业务说明：多端拓扑：A 拉黑/解除 B；B 全部在线端加入，A 全部端查询黑名单一致
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：B 全部在线端加入聊天室
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：拉黑
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：确认拉黑请求已提交
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  4. 操作：A 全部在线端查询黑名单均含 B（账号级服务端状态一致）
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  5. 操作：解除 拉黑
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  6. 操作：确认解除拉黑请求已提交
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  7. 操作：A 全部在线端查询黑名单均不含 B
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 7. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_callbacks.py::test_chatroom_all_member_mute_state_callbacks`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_callbacks.py::test_chatroom_all_member_mute_state_callbacks`
- 业务说明：多端拓扑：A 全员禁言/解除；状态事件同步到 B 全部在线端
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：B 全部在线端加入聊天室
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：全员禁言
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：确认全员禁言请求已提交
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  4. 操作：B 全部在线端收到全员禁言事件（状态 true）
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：解除全员禁言
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  6. 操作：确认解除全员禁言请求已提交
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  7. 操作：B 全部在线端收到解除全员禁言事件（状态 false）
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 8. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_callbacks.py::test_chatroom_attributes_updated_and_removed_callbacks`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_callbacks.py::test_chatroom_attributes_updated_and_removed_callbacks`
- 业务说明：多端拓扑：A 设置/删除聊天室属性；属性事件同步到 B 全部在线端
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：B 全部在线端加入聊天室
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：设置聊天室属性
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：确认设置属性请求已提交
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  4. 操作：B 全部在线端收到属性更新事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：删除聊天室属性
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  6. 操作：确认删除属性请求已提交
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  7. 操作：B 全部在线端收到属性删除事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：from、list。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 9. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_basics.py::test_chatroom_remove_member_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_basics.py::test_chatroom_remove_member_success`
- 业务说明：多端拓扑：A 踢出 B；B 全部在线端加入，A 全部端查询成员列表一致（不含 B）
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：B 全部在线端加入聊天室
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：踢出
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：确认踢出请求已提交
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  4. 操作：A 全部在线端查询成员列表均不含 B（账号级服务端状态一致）
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result、list、cursor。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 10. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_basics.py::test_chatroom_add_fetch_remove_white_list_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_basics.py::test_chatroom_add_fetch_remove_white_list_success`
- 业务说明：多端拓扑：A 添加/移除 B 白名单；B 全部在线端加入并可见事件，A 全部端查询白名单一致
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：B 全部在线端加入聊天室
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：添加 到白名单
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：确认添加白名单请求已提交
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：A 全部在线端查询白名单均含 B（账号级服务端状态一致）
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  5. 操作：从白名单移除
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  6. 操作：确认移除白名单请求已提交
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  7. 操作：A 全部在线端查询白名单均不含 B
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result、list。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 11. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_callbacks.py::test_chatroom_allow_list_added_and_removed_callbacks`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_callbacks.py::test_chatroom_allow_list_added_and_removed_callbacks`
- 业务说明：多端拓扑：A 添加/移除 B 到白名单；白名单事件同步到 B 全部在线端
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：B 全部在线端加入聊天室
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：添加 到白名单
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：确认添加白名单请求已提交
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：B 全部在线端收到白名单添加事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：从白名单移除
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  6. 操作：确认移除白名单请求已提交
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  7. 操作：B 全部在线端收到白名单移除事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 12. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_basics.py::test_chatroom_add_and_remove_admin_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_basics.py::test_chatroom_add_and_remove_admin_success`
- 业务说明：多端拓扑：A 添加/移除 B 为管理员；B 全部在线端加入，A 全部端查询 adminList 一致
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：B 全部在线端加入聊天室
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：添加 为管理员
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：确认添加管理员请求已提交
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：A 全部在线端查询 adminList 均含 B（账号级服务端状态一致）
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  5. 操作：移除 的管理员
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  6. 操作：确认移除管理员请求已提交
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  7. 操作：A 全部在线端查询 adminList 均不含 B
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result、list。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 13. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_callbacks.py::test_chatroom_specification_changed_callback`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_callbacks.py::test_chatroom_specification_changed_callback`
- 业务说明：多端拓扑：A 修改聊天室 subject；规格变更事件同步到 B 全部在线端
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：B 全部在线端加入聊天室
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：修改聊天室 subject
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：确认修改 subject 请求已提交
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：B 全部在线端收到规格变更事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 14. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_basics.py::test_chatroom_change_subject_and_description_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_basics.py::test_chatroom_change_subject_and_description_success`
- 业务说明：修改聊天室名称和描述并验证响应成功
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：修改聊天室名称和描述并验证响应成功
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：查询聊天室信息并验证名称和描述已更新
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 15. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_basics.py::test_chatroom_update_and_fetch_announcement_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_basics.py::test_chatroom_update_and_fetch_announcement_success`
- 业务说明：更新聊天室公告并验证响应成功
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：更新聊天室公告并验证响应成功
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：查询聊天室公告并验证等于本次设置值
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 16. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_self_checks_empty_room_id[isMemberInChatRoomMuteList]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_self_checks_empty_room_id[isMemberInChatRoomMuteList]`
- 业务说明：白名单/禁言自查接口：roomId 为空时返回 700；description 由平台 SDK 决定
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：使用空聊天室 ID 查询成员状态并验证参数错误
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 700。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 17. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_self_checks_empty_room_id[isMemberInChatRoomWhiteListFromServer]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_self_checks_empty_room_id[isMemberInChatRoomWhiteListFromServer]`
- 业务说明：白名单/禁言自查接口：roomId 为空时返回 700；description 由平台 SDK 决定
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：使用空聊天室 ID 查询成员状态并验证参数错误
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 700。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 18. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_membership_checks.py::test_chatroom_member_mute_list_check_reflects_server_state`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_membership_checks.py::test_chatroom_member_mute_list_check_reflects_server_state`
- 业务说明：B 加入聊天室并验证初始不在禁言列表
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：B 加入聊天室并验证初始不在禁言列表
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：A 禁言 B 并验证 B 查询到禁言状态
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  3. 操作：A 解除 B 禁言并验证状态恢复
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 19. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_membership_checks.py::test_chatroom_member_white_list_check_reflects_server_state`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_membership_checks.py::test_chatroom_member_white_list_check_reflects_server_state`
- 业务说明：B 加入聊天室并验证初始不在白名单
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：B 加入聊天室并验证初始不在白名单
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：A 添加 B 到白名单并验证 B 可查询到白名单状态
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：A 移除 B 出白名单并验证状态恢复
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 20. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_empty_members[addMembersToChatRoomWhiteList-members-110-usernames is null or empty!]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_empty_members[addMembersToChatRoomWhiteList-members-110-usernames is null or empty!]`
- 业务说明：成员管理接口：成员列表为空时，逐方法锁定真实错误码与错误描述
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：提交空成员列表管理请求并验证当前错误响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 21. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_empty_members[blockChatRoomMembers-members-110-usernames is null or empty!]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_empty_members[blockChatRoomMembers-members-110-usernames is null or empty!]`
- 业务说明：成员管理接口：成员列表为空时，逐方法锁定真实错误码与错误描述
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：提交空成员列表管理请求并验证当前错误响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 22. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_empty_members[muteChatRoomMembers-muteMembers-602-users [] are not members of this group!]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_empty_members[muteChatRoomMembers-muteMembers-602-users [] are not members of this group!]`
- 业务说明：成员管理接口：成员列表为空时，逐方法锁定真实错误码与错误描述
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：提交空成员列表管理请求并验证当前错误响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 23. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_empty_members[removeChatRoomMembers-members-300-Server is unreachable]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_empty_members[removeChatRoomMembers-members-300-Server is unreachable]`
- 业务说明：成员管理接口：成员列表为空时，逐方法锁定真实错误码与错误描述
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：提交空成员列表管理请求并验证当前错误响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 24. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_empty_members[removeMembersFromChatRoomWhiteList-members-300-Server is unreachable]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_empty_members[removeMembersFromChatRoomWhiteList-members-300-Server is unreachable]`
- 业务说明：成员管理接口：成员列表为空时，逐方法锁定真实错误码与错误描述
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：提交空成员列表管理请求并验证当前错误响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 25. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_empty_members[unBlockChatRoomMembers-members-300-Server is unreachable]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_empty_members[unBlockChatRoomMembers-members-300-Server is unreachable]`
- 业务说明：成员管理接口：成员列表为空时，逐方法锁定真实错误码与错误描述
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：提交空成员列表管理请求并验证当前错误响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 26. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_empty_members[unMuteChatRoomMembers-unMuteMembers-300-Server is unreachable]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_empty_members[unMuteChatRoomMembers-unMuteMembers-300-Server is unreachable]`
- 业务说明：成员管理接口：成员列表为空时，逐方法锁定真实错误码与错误描述
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：提交空成员列表管理请求并验证当前错误响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 27. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_nonexistent_user[addChatRoomAdmin-info0-expected0]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_nonexistent_user[addChatRoomAdmin-info0-expected0]`
- 业务说明：成员管理接口：传入不存在用户时，逐方法锁定真实错误或幂等成功响应
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：提交不存在用户的成员管理请求并验证真实响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 28. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_nonexistent_user[addMembersToChatRoomWhiteList-info3-expected3]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_nonexistent_user[addMembersToChatRoomWhiteList-info3-expected3]`
- 业务说明：成员管理接口：传入不存在用户时，逐方法锁定真实错误或幂等成功响应
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：提交不存在用户的成员管理请求并验证真实响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 29. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_nonexistent_user[blockChatRoomMembers-info7-expected7]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_nonexistent_user[blockChatRoomMembers-info7-expected7]`
- 业务说明：成员管理接口：传入不存在用户时，逐方法锁定真实错误或幂等成功响应
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：提交不存在用户的成员管理请求并验证真实响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 30. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_nonexistent_user[changeChatRoomOwner-info2-expected2]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_nonexistent_user[changeChatRoomOwner-info2-expected2]`
- 业务说明：成员管理接口：传入不存在用户时，逐方法锁定真实错误或幂等成功响应
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：提交不存在用户的成员管理请求并验证真实响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 31. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_nonexistent_user[muteChatRoomMembers-info5-expected5]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_nonexistent_user[muteChatRoomMembers-info5-expected5]`
- 业务说明：成员管理接口：传入不存在用户时，逐方法锁定真实错误或幂等成功响应
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：提交不存在用户的成员管理请求并验证真实响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 32. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_nonexistent_user[removeChatRoomAdmin-info1-expected1]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_nonexistent_user[removeChatRoomAdmin-info1-expected1]`
- 业务说明：成员管理接口：传入不存在用户时，逐方法锁定真实错误或幂等成功响应
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：提交不存在用户的成员管理请求并验证真实响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 33. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_nonexistent_user[removeChatRoomMembers-info9-expected9]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_nonexistent_user[removeChatRoomMembers-info9-expected9]`
- 业务说明：成员管理接口：传入不存在用户时，逐方法锁定真实错误或幂等成功响应
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：提交不存在用户的成员管理请求并验证真实响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 34. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_nonexistent_user[removeMembersFromChatRoomWhiteList-info4-None]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_nonexistent_user[removeMembersFromChatRoomWhiteList-info4-None]`
- 业务说明：成员管理接口：传入不存在用户时，逐方法锁定真实错误或幂等成功响应
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：提交不存在用户的成员管理请求并验证真实响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 35. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_nonexistent_user[unBlockChatRoomMembers-info8-room]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_nonexistent_user[unBlockChatRoomMembers-info8-room]`
- 业务说明：成员管理接口：传入不存在用户时，逐方法锁定真实错误或幂等成功响应
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：提交不存在用户的成员管理请求并验证真实响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 36. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_nonexistent_user[unMuteChatRoomMembers-info6-room]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_nonexistent_user[unMuteChatRoomMembers-info6-room]`
- 业务说明：成员管理接口：传入不存在用户时，逐方法锁定真实错误或幂等成功响应
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：提交不存在用户的成员管理请求并验证真实响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 37. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_non_member[addChatRoomAdmin-info0-room]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_non_member[addChatRoomAdmin-info0-room]`
- 业务说明：成员管理接口：真实用户未加入聊天室时，逐方法锁定当前成功/失败语义
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：对未加入成员执行聊天室管理操作并验证成功或错误语义
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 38. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_non_member[changeChatRoomOwner-info2-owner_changed]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_non_member[changeChatRoomOwner-info2-owner_changed]`
- 业务说明：成员管理接口：真实用户未加入聊天室时，逐方法锁定当前成功/失败语义
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：对未加入成员执行聊天室管理操作并验证成功或错误语义
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 39. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_non_member[removeChatRoomAdmin-info1-expected1]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_non_member[removeChatRoomAdmin-info1-expected1]`
- 业务说明：成员管理接口：真实用户未加入聊天室时，逐方法锁定当前成功/失败语义
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：对未加入成员执行聊天室管理操作并验证成功或错误语义
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 40. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_non_member[removeChatRoomMembers-info3-expected3]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_non_member[removeChatRoomMembers-info3-expected3]`
- 业务说明：成员管理接口：真实用户未加入聊天室时，逐方法锁定当前成功/失败语义
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：对未加入成员执行聊天室管理操作并验证成功或错误语义
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 41. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_lifecycle.py::test_chatroom_create_and_fetch_from_server`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_lifecycle.py::test_chatroom_create_and_fetch_from_server`
- 业务说明：创建聊天室后查询服务端信息并验证 owner 与默认字段
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：创建聊天室后查询服务端信息并验证 owner 与默认字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 42. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_lifecycle.py::test_chatroom_create_room_via_sdk_without_permission`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_lifecycle.py::test_chatroom_create_room_via_sdk_without_permission`
- 业务说明：创建 room via sdk without permission
- 类型：普通
- 状态/版本说明：5.0 不可用
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：创建 room via sdk without permission
     - 预期：该原测试目标在 5.0 中不再成立。移除客户端 createChatRoom（残留，聊天室由服务端创建）
- 关键断言：
  1. 校验异常返回：错误码 703，错误描述“you have no permission to do this.”。
  2. 校验关键字段：to。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 43. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_member_basics.py::test_chatroom_fetch_members_with_cursor_pagination`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_member_basics.py::test_chatroom_fetch_members_with_cursor_pagination`
- 业务说明：B 加入聊天室并验证首个成员分页结果
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：B 加入聊天室并验证首个成员分页结果
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：使用返回 cursor 查询下一页并合并成员结果
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result、list、cursor。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 44. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_exceptions.py::test_chatroom_fetch_members_empty_room_id`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_exceptions.py::test_chatroom_fetch_members_empty_room_id`
- 业务说明：使用空聊天室 ID 查询成员并验证参数错误码
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：使用空聊天室 ID 查询成员并验证参数错误码
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 700。
  2. 校验关键字段：cursor。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 45. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_member_basics.py::test_chatroom_fetch_members_after_join_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_member_basics.py::test_chatroom_fetch_members_after_join_success`
- 业务说明：B 加入聊天室并分页查询成员列表，验证包含 B
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：B 加入聊天室并分页查询成员列表，验证包含 B
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result、list、cursor。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 46. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_exceptions.py::test_chatroom_fetch_members_nonexistent_room`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_exceptions.py::test_chatroom_fetch_members_nonexistent_room`
- 业务说明：查询不存在聊天室的成员并验证不存在错误
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：查询不存在聊天室的成员并验证不存在错误
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 700，错误描述“do not find this group”。
  2. 校验关键字段：cursor。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 47. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_server_state.py::test_chatroom_fetch_public_chat_rooms_from_server_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_server_state.py::test_chatroom_fetch_public_chat_rooms_from_server_success`
- 业务说明：测试准备：创建公开聊天室
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建公开聊天室
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：分页查询公开聊天室并验证新建聊天室条目
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result、list。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 48. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_exceptions.py::test_chatroom_fetch_public_chat_rooms_invalid_paging[-1-1]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_exceptions.py::test_chatroom_fetch_public_chat_rooms_invalid_paging[-1-1]`
- 业务说明：使用 pageNum=, pageSize= 查询公开聊天室并验证分页响应
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：使用 pageNum=, pageSize= 查询公开聊天室并验证分页响应
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result、list。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 49. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_exceptions.py::test_chatroom_fetch_public_chat_rooms_invalid_paging[0-1]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_exceptions.py::test_chatroom_fetch_public_chat_rooms_invalid_paging[0-1]`
- 业务说明：使用 pageNum=, pageSize= 查询公开聊天室并验证分页响应
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：使用 pageNum=, pageSize= 查询公开聊天室并验证分页响应
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result、list。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 50. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_exceptions.py::test_chatroom_fetch_public_chat_rooms_invalid_paging[1--1]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_exceptions.py::test_chatroom_fetch_public_chat_rooms_invalid_paging[1--1]`
- 业务说明：使用 pageNum=, pageSize= 查询公开聊天室并验证分页响应
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：使用 pageNum=, pageSize= 查询公开聊天室并验证分页响应
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result、list。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 51. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_exceptions.py::test_chatroom_fetch_public_chat_rooms_invalid_paging[1-0]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_exceptions.py::test_chatroom_fetch_public_chat_rooms_invalid_paging[1-0]`
- 业务说明：使用 pageNum=, pageSize= 查询公开聊天室并验证分页响应
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：使用 pageNum=, pageSize= 查询公开聊天室并验证分页响应
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result、list。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 52. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_lifecycle.py::test_chatroom_fetch_room_info_from_server_after_destroy`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_lifecycle.py::test_chatroom_fetch_room_info_from_server_after_destroy`
- 业务说明：测试准备：销毁服务端聊天室
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：销毁服务端聊天室
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：查询已销毁聊天室并验证不存在错误
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 700，错误描述“do not find this group”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 53. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_lifecycle.py::test_chatroom_fetch_room_info_with_members_from_server`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_lifecycle.py::test_chatroom_fetch_room_info_with_members_from_server`
- 业务说明：B 加入聊天室并验证成员查询前置
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：B 加入聊天室并验证成员查询前置
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：查询聊天室概要并验证成员计数
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  3. 操作：分页查询聊天室成员并验证 B 在列表中
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result、list、cursor。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 54. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_exceptions.py::test_chatroom_fetch_room_info_empty_id`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_exceptions.py::test_chatroom_fetch_room_info_empty_id`
- 业务说明：使用空聊天室 ID 查询信息并验证参数错误码
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：使用空聊天室 ID 查询信息并验证参数错误码
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 700。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 55. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_exceptions.py::test_chatroom_fetch_room_info_nonexistent`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_exceptions.py::test_chatroom_fetch_room_info_nonexistent`
- 业务说明：查询不存在聊天室并验证不存在错误
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：查询不存在聊天室并验证不存在错误
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 700，错误描述“do not find this group”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 56. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_basics.py::test_chatroom_fetch_attributes_by_partial_keys_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_basics.py::test_chatroom_fetch_attributes_by_partial_keys_success`
- 业务说明：设置两项聊天室属性并验证写入成功
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：设置两项聊天室属性并验证写入成功
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  2. 操作：按指定 key 查询属性并验证未返回未请求的 key
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 57. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_basics.py::test_chatroom_fetch_all_attributes_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_basics.py::test_chatroom_fetch_all_attributes_success`
- 业务说明：设置多项聊天室属性并验证没有失败 key
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：设置多项聊天室属性并验证没有失败 key
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  2. 操作：读取全部聊天室属性并验证全部键值
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 58. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_member_basics.py::test_chatroom_get_all_local_rooms_returns_list`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_member_basics.py::test_chatroom_get_all_local_rooms_returns_list`
- 业务说明：读取本地全部聊天室并验证列表及房间 ID 结构
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备B已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：读取本地全部聊天室并验证列表及房间 ID 结构
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result、list。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 59. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_member_basics.py::test_chatroom_get_local_room_empty_id_returns_none`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_member_basics.py::test_chatroom_get_local_room_empty_id_returns_none`
- 业务说明：使用空聊天室 ID 查询本地房间并验证返回空值
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备B已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：使用空聊天室 ID 查询本地房间并验证返回空值
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 60. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_member_basics.py::test_chatroom_get_local_room_nonexistent_returns_placeholder`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_member_basics.py::test_chatroom_get_local_room_nonexistent_returns_placeholder`
- 业务说明：查询不存在的本地聊天室并验证返回空值
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备B已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：查询不存在的本地聊天室并验证返回空值
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 61. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_basics.py::test_chatroom_remove_attributes_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_basics.py::test_chatroom_remove_attributes_success`
- 业务说明：设置待删除聊天室属性并验证写入成功
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：设置待删除聊天室属性并验证写入成功
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：删除聊天室属性并验证查询结果为空
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 62. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_basics.py::test_chatroom_change_owner_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_basics.py::test_chatroom_change_owner_success`
- 业务说明：B 加入聊天室并验证转让前置
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：B 加入聊天室并验证转让前置
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：A 转让聊天室所有权给 B 并验证新 owner
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 63. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_change_description_empty_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_change_description_empty_success`
- 业务说明：changeChatRoomDescription：聊天室描述允许置为空，实测返回完整聊天室对象且 desc 为空字符串
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：将聊天室描述置空并验证返回状态
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 当前测试步骤的同步响应、异步事件和最终业务状态满足代码断言。
  2. 任一关键字段、回调、列表、数量或最终状态不符时，Case 判定失败。

### 64. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_change_description_too_long`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_change_description_too_long`
- 业务说明：changeChatRoomDescription：描述超过 4096 字符，实测返回 703/desc cannot exceed to 4096
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：提交超长聊天室描述并验证长度错误
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 703，错误描述“desc cannot exceed to 4096”。
  2. 校验关键字段：to。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 65. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_change_subject_empty_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_change_subject_empty_success`
- 业务说明：changeChatRoomSubject：聊天室名称允许置为空，实测返回完整聊天室对象且 name 为空字符串
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：将聊天室名称置空并验证返回的聊天室状态
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 当前测试步骤的同步响应、异步事件和最终业务状态满足代码断言。
  2. 任一关键字段、回调、列表、数量或最终状态不符时，Case 判定失败。

### 66. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_change_subject_too_long`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_change_subject_too_long`
- 业务说明：changeChatRoomSubject：名称超过 1024 字符，实测返回 703/title cannot exceed to 1024
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：提交超长聊天室名称并验证长度错误
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 703，错误描述“title cannot exceed to 1024”。
  2. 校验关键字段：to。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 67. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_lifecycle.py::test_chatroom_destroy_room_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_lifecycle.py::test_chatroom_destroy_room_success`
- 业务说明：destroy room 成功
- 类型：普通
- 状态/版本说明：5.0 不可用
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：destroy room 成功
     - 预期：该原测试目标在 5.0 中不再成立。移除客户端 destroyChatRoom（残留，聊天室由服务端销毁）
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 68. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_exceptions.py::test_chatroom_destroy_room_empty_id`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_exceptions.py::test_chatroom_destroy_room_empty_id`
- 业务说明：destroy room 空 id
- 类型：普通
- 状态/版本说明：5.0 不可用
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：destroy room 空 id
     - 预期：该原测试目标在 5.0 中不再成立。移除客户端 destroyChatRoom（残留）
- 关键断言：
  1. 校验异常返回：错误码 700。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 69. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_exceptions.py::test_chatroom_destroy_room_nonexistent`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_exceptions.py::test_chatroom_destroy_room_nonexistent`
- 业务说明：destroy room nonexistent
- 类型：普通
- 状态/版本说明：5.0 不可用
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：destroy room nonexistent
     - 预期：该原测试目标在 5.0 中不再成立。移除客户端 destroyChatRoom（残留）
- 关键断言：
  1. 校验异常返回：错误码 700，错误描述“do not find this group”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 70. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_fetch_members_invalid_paging[-1-20]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_fetch_members_invalid_paging[-1-20]`
- 业务说明：fetchChatRoomMembers：非法 pageNum/pageSize 当前仍返回 cursor 结构与成员列表
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：B 加入聊天室并验证非法成员分页参数仍返回成员列表
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result、list、cursor。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 71. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_fetch_members_invalid_paging[0-20]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_fetch_members_invalid_paging[0-20]`
- 业务说明：fetchChatRoomMembers：非法 pageNum/pageSize 当前仍返回 cursor 结构与成员列表
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：B 加入聊天室并验证非法成员分页参数仍返回成员列表
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result、list、cursor。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 72. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_fetch_members_invalid_paging[1--1]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_fetch_members_invalid_paging[1--1]`
- 业务说明：fetchChatRoomMembers：非法 pageNum/pageSize 当前仍返回 cursor 结构与成员列表
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：B 加入聊天室并验证非法成员分页参数仍返回成员列表
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result、list、cursor。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 73. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_fetch_members_invalid_paging[1-0]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_fetch_members_invalid_paging[1-0]`
- 业务说明：fetchChatRoomMembers：非法 pageNum/pageSize 当前仍返回 cursor 结构与成员列表
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：B 加入聊天室并验证非法成员分页参数仍返回成员列表
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result、list、cursor。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 74. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_server_member_list_invalid_paging[fetchChatRoomBlockList--1-20]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_server_member_list_invalid_paging[fetchChatRoomBlockList--1-20]`
- 业务说明：fetchChatRoomMuteList/fetchChatRoomBlockList：非法分页参数当前容错返回空列表
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：使用非法分页参数查询聊天室成员名单并验证空列表响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 75. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_server_member_list_invalid_paging[fetchChatRoomBlockList-0-20]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_server_member_list_invalid_paging[fetchChatRoomBlockList-0-20]`
- 业务说明：fetchChatRoomMuteList/fetchChatRoomBlockList：非法分页参数当前容错返回空列表
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：使用非法分页参数查询聊天室成员名单并验证空列表响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 76. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_server_member_list_invalid_paging[fetchChatRoomBlockList-1--1]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_server_member_list_invalid_paging[fetchChatRoomBlockList-1--1]`
- 业务说明：fetchChatRoomMuteList/fetchChatRoomBlockList：非法分页参数当前容错返回空列表
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：使用非法分页参数查询聊天室成员名单并验证空列表响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 77. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_server_member_list_invalid_paging[fetchChatRoomBlockList-1-0]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_server_member_list_invalid_paging[fetchChatRoomBlockList-1-0]`
- 业务说明：fetchChatRoomMuteList/fetchChatRoomBlockList：非法分页参数当前容错返回空列表
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：使用非法分页参数查询聊天室成员名单并验证空列表响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 78. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_server_member_list_invalid_paging[fetchChatRoomMuteList--1-20]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_server_member_list_invalid_paging[fetchChatRoomMuteList--1-20]`
- 业务说明：fetchChatRoomMuteList/fetchChatRoomBlockList：非法分页参数当前容错返回空列表
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：使用非法分页参数查询聊天室成员名单并验证空列表响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 79. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_server_member_list_invalid_paging[fetchChatRoomMuteList-0-20]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_server_member_list_invalid_paging[fetchChatRoomMuteList-0-20]`
- 业务说明：fetchChatRoomMuteList/fetchChatRoomBlockList：非法分页参数当前容错返回空列表
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：使用非法分页参数查询聊天室成员名单并验证空列表响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 80. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_server_member_list_invalid_paging[fetchChatRoomMuteList-1--1]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_server_member_list_invalid_paging[fetchChatRoomMuteList-1--1]`
- 业务说明：fetchChatRoomMuteList/fetchChatRoomBlockList：非法分页参数当前容错返回空列表
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：使用非法分页参数查询聊天室成员名单并验证空列表响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 81. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_server_member_list_invalid_paging[fetchChatRoomMuteList-1-0]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_server_member_list_invalid_paging[fetchChatRoomMuteList-1-0]`
- 业务说明：fetchChatRoomMuteList/fetchChatRoomBlockList：非法分页参数当前容错返回空列表
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：使用非法分页参数查询聊天室成员名单并验证空列表响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 82. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_membership_checks.py::test_chatroom_is_member_in_white_list_and_mute_list_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_membership_checks.py::test_chatroom_is_member_in_white_list_and_mute_list_success`
- 业务说明：查询聊天室白名单成员状态并验证返回布尔值
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：查询聊天室白名单成员状态并验证返回布尔值
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  2. 操作：查询聊天室禁言名单成员状态并验证返回布尔值
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 83. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_membership_checks.py::test_chatroom_is_member_in_white_list_and_mute_list_nonexistent_room`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_membership_checks.py::test_chatroom_is_member_in_white_list_and_mute_list_nonexistent_room`
- 业务说明：查询不存在聊天室的白名单和禁言名单状态并验证错误
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：查询不存在聊天室的白名单和禁言名单状态并验证错误
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 700，错误描述“do not find this group”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 84. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_members.py::test_chatroom_join_public_chatroom_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_members.py::test_chatroom_join_public_chatroom_success`
- 业务说明：B 加入聊天室并验证加入响应
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：B 加入聊天室并验证加入响应
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：A 分页查询聊天室成员并验证包含 B
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result、list、cursor。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 85. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_exceptions.py::test_chatroom_join_room_empty_id`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_exceptions.py::test_chatroom_join_room_empty_id`
- 业务说明：使用空聊天室 ID 加入并验证参数错误码
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备B已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：使用空聊天室 ID 加入并验证参数错误码
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 700。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 86. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_exceptions.py::test_chatroom_join_room_nonexistent`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_exceptions.py::test_chatroom_join_room_nonexistent`
- 业务说明：加入不存在聊天室并验证聊天室不存在错误
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备B已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：加入不存在聊天室并验证聊天室不存在错误
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 705，错误描述“Chat room does not exist”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 87. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_member_basics.py::test_chatroom_join_then_get_local_room_and_all_rooms`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_member_basics.py::test_chatroom_join_then_get_local_room_and_all_rooms`
- 业务说明：B 加入聊天室并验证本地单房间与全部房间查询
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：B 加入聊天室并验证本地单房间与全部房间查询
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result、list。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 88. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_members.py::test_chatroom_join_with_ext_member_joined_callback`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_members.py::test_chatroom_join_with_ext_member_joined_callback`
- 业务说明：joinChatRoom：加入方携带头像/昵称等 ext，观察端（其他在线成员）收到同一个成员加入回调 ext
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：观察端加入聊天室，再验证加入方携带 ext 的成员事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。

### 89. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_member_basics.py::test_chatroom_join_leave_other_rooms_option_controls_existing_rooms`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_member_basics.py::test_chatroom_join_leave_other_rooms_option_controls_existing_rooms`
- 业务说明：joinChatRoom：leaveOtherRooms=false 保留其他聊天室，leaveOtherRooms=true 退出其他聊天室
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：leaveOtherRooms=false：连续加入两个聊天室并验证旧房间保留
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：leaveOtherRooms=true：准备旧聊天室成员关系
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：leaveOtherRooms=true：加入新聊天室并验证旧房间退出
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 当前测试步骤的同步响应、异步事件和最终业务状态满足代码断言。
  2. 任一关键字段、回调、列表、数量或最终状态不符时，Case 判定失败。

### 90. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_exceptions.py::test_chatroom_leave_room_empty_id`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_exceptions.py::test_chatroom_leave_room_empty_id`
- 业务说明：使用空聊天室 ID 离开并验证参数错误码
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备B已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：使用空聊天室 ID 离开并验证参数错误码
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 700。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 91. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_exceptions.py::test_chatroom_leave_room_nonexistent`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_exceptions.py::test_chatroom_leave_room_nonexistent`
- 业务说明：离开不存在聊天室并验证幂等成功语义
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备B已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：离开不存在聊天室并验证幂等成功语义
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 92. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_member_basics.py::test_chatroom_leave_room_updates_local_cache`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_member_basics.py::test_chatroom_leave_room_updates_local_cache`
- 业务说明：B 加入后主动离开聊天室并验证离开响应
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：B 加入后主动离开聊天室并验证离开响应
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：A 查询成员列表并验证 B 已移除
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result、list、cursor。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 93. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_callbacks.py::test_chatroom_member_exited_callback`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_callbacks.py::test_chatroom_member_exited_callback`
- 业务说明：leaveChatRoom 触发成员主动退出回调，校验 roomId/participant
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A、B 加入聊天室并验证加入前置
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：B 主动离开并验证 A 收到成员退出事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 94. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[addChatRoomAdmin]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[addChatRoomAdmin]`
- 业务说明：调用 使用空聊天室 ID 并验证边界响应
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：调用 使用空聊天室 ID 并验证边界响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 95. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[addMembersToChatRoomWhiteList]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[addMembersToChatRoomWhiteList]`
- 业务说明：调用 使用空聊天室 ID 并验证边界响应
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：调用 使用空聊天室 ID 并验证边界响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 96. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[blockChatRoomMembers]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[blockChatRoomMembers]`
- 业务说明：调用 使用空聊天室 ID 并验证边界响应
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：调用 使用空聊天室 ID 并验证边界响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 97. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[changeChatRoomDescription]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[changeChatRoomDescription]`
- 业务说明：调用 使用空聊天室 ID 并验证边界响应
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：调用 使用空聊天室 ID 并验证边界响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 98. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[changeChatRoomOwner]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[changeChatRoomOwner]`
- 业务说明：调用 使用空聊天室 ID 并验证边界响应
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：调用 使用空聊天室 ID 并验证边界响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 99. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[changeChatRoomSubject]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[changeChatRoomSubject]`
- 业务说明：调用 使用空聊天室 ID 并验证边界响应
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：调用 使用空聊天室 ID 并验证边界响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 100. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[fetchChatRoomAnnouncement]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[fetchChatRoomAnnouncement]`
- 业务说明：调用 使用空聊天室 ID 并验证边界响应
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：调用 使用空聊天室 ID 并验证边界响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 101. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[fetchChatRoomAttributes]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[fetchChatRoomAttributes]`
- 业务说明：调用 使用空聊天室 ID 并验证边界响应
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：调用 使用空聊天室 ID 并验证边界响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 102. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[fetchChatRoomBlockList]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[fetchChatRoomBlockList]`
- 业务说明：调用 使用空聊天室 ID 并验证边界响应
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：调用 使用空聊天室 ID 并验证边界响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 103. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[fetchChatRoomMuteList]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[fetchChatRoomMuteList]`
- 业务说明：调用 使用空聊天室 ID 并验证边界响应
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：调用 使用空聊天室 ID 并验证边界响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 104. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[fetchChatRoomWhiteListFromServer]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[fetchChatRoomWhiteListFromServer]`
- 业务说明：调用 使用空聊天室 ID 并验证边界响应
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：调用 使用空聊天室 ID 并验证边界响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 105. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[muteAllChatRoomMembers]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[muteAllChatRoomMembers]`
- 业务说明：调用 使用空聊天室 ID 并验证边界响应
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：调用 使用空聊天室 ID 并验证边界响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 106. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[muteChatRoomMembers]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[muteChatRoomMembers]`
- 业务说明：调用 使用空聊天室 ID 并验证边界响应
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：调用 使用空聊天室 ID 并验证边界响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 107. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[removeChatRoomAdmin]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[removeChatRoomAdmin]`
- 业务说明：调用 使用空聊天室 ID 并验证边界响应
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：调用 使用空聊天室 ID 并验证边界响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 108. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[removeChatRoomAttributes]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[removeChatRoomAttributes]`
- 业务说明：调用 使用空聊天室 ID 并验证边界响应
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：调用 使用空聊天室 ID 并验证边界响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 109. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[removeChatRoomMembers]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[removeChatRoomMembers]`
- 业务说明：调用 使用空聊天室 ID 并验证边界响应
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：调用 使用空聊天室 ID 并验证边界响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 110. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[removeMembersFromChatRoomWhiteList]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[removeMembersFromChatRoomWhiteList]`
- 业务说明：调用 使用空聊天室 ID 并验证边界响应
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：调用 使用空聊天室 ID 并验证边界响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 111. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[setChatRoomAttributes]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[setChatRoomAttributes]`
- 业务说明：调用 使用空聊天室 ID 并验证边界响应
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：调用 使用空聊天室 ID 并验证边界响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 112. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[unBlockChatRoomMembers]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[unBlockChatRoomMembers]`
- 业务说明：调用 使用空聊天室 ID 并验证边界响应
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：调用 使用空聊天室 ID 并验证边界响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 113. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[unMuteAllChatRoomMembers]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[unMuteAllChatRoomMembers]`
- 业务说明：调用 使用空聊天室 ID 并验证边界响应
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：调用 使用空聊天室 ID 并验证边界响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 114. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[unMuteChatRoomMembers]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[unMuteChatRoomMembers]`
- 业务说明：调用 使用空聊天室 ID 并验证边界响应
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：调用 使用空聊天室 ID 并验证边界响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 115. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[updateChatRoomAnnouncement]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[updateChatRoomAnnouncement]`
- 业务说明：调用 使用空聊天室 ID 并验证边界响应
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：调用 使用空聊天室 ID 并验证边界响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 116. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[addChatRoomAdmin]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[addChatRoomAdmin]`
- 业务说明：调用 访问不存在聊天室并验证错误码
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：调用 访问不存在聊天室并验证错误码
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 117. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[addMembersToChatRoomWhiteList]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[addMembersToChatRoomWhiteList]`
- 业务说明：调用 访问不存在聊天室并验证错误码
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：调用 访问不存在聊天室并验证错误码
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 118. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[blockChatRoomMembers]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[blockChatRoomMembers]`
- 业务说明：调用 访问不存在聊天室并验证错误码
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：调用 访问不存在聊天室并验证错误码
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 119. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[changeChatRoomDescription]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[changeChatRoomDescription]`
- 业务说明：调用 访问不存在聊天室并验证错误码
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：调用 访问不存在聊天室并验证错误码
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 120. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[changeChatRoomOwner]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[changeChatRoomOwner]`
- 业务说明：调用 访问不存在聊天室并验证错误码
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：调用 访问不存在聊天室并验证错误码
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 121. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[changeChatRoomSubject]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[changeChatRoomSubject]`
- 业务说明：调用 访问不存在聊天室并验证错误码
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：调用 访问不存在聊天室并验证错误码
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 122. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[fetchChatRoomAnnouncement]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[fetchChatRoomAnnouncement]`
- 业务说明：调用 访问不存在聊天室并验证错误码
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：调用 访问不存在聊天室并验证错误码
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 123. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[fetchChatRoomAttributes]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[fetchChatRoomAttributes]`
- 业务说明：调用 访问不存在聊天室并验证错误码
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：调用 访问不存在聊天室并验证错误码
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 124. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[fetchChatRoomBlockList]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[fetchChatRoomBlockList]`
- 业务说明：调用 访问不存在聊天室并验证错误码
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：调用 访问不存在聊天室并验证错误码
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 125. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[fetchChatRoomMuteList]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[fetchChatRoomMuteList]`
- 业务说明：调用 访问不存在聊天室并验证错误码
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：调用 访问不存在聊天室并验证错误码
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 126. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[fetchChatRoomWhiteListFromServer]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[fetchChatRoomWhiteListFromServer]`
- 业务说明：调用 访问不存在聊天室并验证错误码
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：调用 访问不存在聊天室并验证错误码
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 127. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[muteAllChatRoomMembers]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[muteAllChatRoomMembers]`
- 业务说明：调用 访问不存在聊天室并验证错误码
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：调用 访问不存在聊天室并验证错误码
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 128. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[muteChatRoomMembers]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[muteChatRoomMembers]`
- 业务说明：调用 访问不存在聊天室并验证错误码
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：调用 访问不存在聊天室并验证错误码
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 129. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[removeChatRoomAdmin]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[removeChatRoomAdmin]`
- 业务说明：调用 访问不存在聊天室并验证错误码
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：调用 访问不存在聊天室并验证错误码
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 130. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[removeChatRoomAttributes]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[removeChatRoomAttributes]`
- 业务说明：调用 访问不存在聊天室并验证错误码
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：调用 访问不存在聊天室并验证错误码
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 131. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[removeChatRoomMembers]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[removeChatRoomMembers]`
- 业务说明：调用 访问不存在聊天室并验证错误码
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：调用 访问不存在聊天室并验证错误码
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 132. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[removeMembersFromChatRoomWhiteList]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[removeMembersFromChatRoomWhiteList]`
- 业务说明：调用 访问不存在聊天室并验证错误码
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：调用 访问不存在聊天室并验证错误码
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 133. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[setChatRoomAttributes]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[setChatRoomAttributes]`
- 业务说明：调用 访问不存在聊天室并验证错误码
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：调用 访问不存在聊天室并验证错误码
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 134. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[unBlockChatRoomMembers]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[unBlockChatRoomMembers]`
- 业务说明：调用 访问不存在聊天室并验证错误码
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：调用 访问不存在聊天室并验证错误码
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 135. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[unMuteAllChatRoomMembers]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[unMuteAllChatRoomMembers]`
- 业务说明：调用 访问不存在聊天室并验证错误码
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：调用 访问不存在聊天室并验证错误码
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 136. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[unMuteChatRoomMembers]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[unMuteChatRoomMembers]`
- 业务说明：调用 访问不存在聊天室并验证错误码
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：调用 访问不存在聊天室并验证错误码
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 137. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[updateChatRoomAnnouncement]`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[updateChatRoomAnnouncement]`
- 业务说明：调用 访问不存在聊天室并验证错误码
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：调用 访问不存在聊天室并验证错误码
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 138. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_basics.py::test_chatroom_mute_and_unmute_all_members_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_basics.py::test_chatroom_mute_and_unmute_all_members_success`
- 业务说明：开启全员禁言并验证聊天室状态
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：开启全员禁言并验证聊天室状态
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  2. 操作：解除全员禁言并验证聊天室状态恢复
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 139. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_remove_attributes_empty_keys`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_remove_attributes_empty_keys`
- 业务说明：removeChatRoomAttributes：keys 为空列表时，实测返回 110 且 description 为空字符串
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：提交空聊天室属性 key 列表并验证参数错误
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 110。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 140. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_callbacks.py::test_chatroom_removed_and_destroyed_callbacks`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_callbacks.py::test_chatroom_removed_and_destroyed_callbacks`
- 业务说明：B 加入聊天室，A 移除 B 并验证移除事件
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：B 加入聊天室，A 移除 B 并验证移除事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  2. 操作：B 重新加入后销毁聊天室并验证销毁事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 141. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_basics.py::test_chatroom_set_and_fetch_attributes_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_basics.py::test_chatroom_set_and_fetch_attributes_success`
- 业务说明：设置聊天室属性并验证没有失败 key
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：设置聊天室属性并验证没有失败 key
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  2. 操作：读取指定聊天室属性并验证值一致
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 142. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_add_attributes_empty_map`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_add_attributes_empty_map`
- 业务说明：setChatRoomAttributes：属性 为空 map 时，实测返回 110 且 description 为空字符串
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：提交空聊天室属性 map 并验证参数错误
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 110。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 143. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_basics.py::test_chatroom_update_attribute_overwrites_previous_value`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_basics.py::test_chatroom_update_attribute_overwrites_previous_value`
- 业务说明：先写入旧属性值，再写入新值验证覆盖请求成功
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：先写入旧属性值，再写入新值验证覆盖请求成功
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  2. 操作：读取覆盖后的属性并验证已是新值
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 144. `im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_update_announcement_empty`

- 代码：`im_flutter_sdk/native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_update_announcement_empty`
- 业务说明：updateChatRoomAnnouncement：公告允许置为空，实测返回 True
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：将聊天室公告置空并验证返回成功
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

## client

### 1. `im_flutter_sdk/native-auto-test/tests/client/test_client.py::test_login_then_receive_offline_sync_event`

- 代码：`im_flutter_sdk/native-auto-test/tests/client/test_client.py::test_login_then_receive_offline_sync_event`
- 业务说明：验证登录后能收到 离线消息同步 回调
- 类型：离线
- 多设备校验：否。本 Case 只验证指定设备的离线同步或重新登录结果。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 本 Case 仅验证指定设备的离线/重登结果，不代表多设备校验。
- 详细步骤与对应预期：
  1. 操作：测试准备：退出当前会话并清理历史事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  2. 操作：测试准备：清理登录前残留事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  3. 操作：重新登录并验证登录成功
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：启动回调并等待离线同步事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：from。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 2. `im_flutter_sdk/native-auto-test/tests/client/test_client.py::test_client_login_invalid_password`

- 代码：`im_flutter_sdk/native-auto-test/tests/client/test_client.py::test_client_login_invalid_password`
- 业务说明：错误密码：预期返回错误响应；若服务端仅返回 result=None 也视为合法响应
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：使用错误密码登录并验证失败响应语义
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 3. `im_flutter_sdk/native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_compress_logs_returns_path`

- 代码：`im_flutter_sdk/native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_compress_logs_returns_path`
- 业务说明：compressLogs：压缩本地日志，校验返回压缩文件路径字符串
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：压缩客户端日志并验证返回文件路径
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 4. `im_flutter_sdk/native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_create_account_empty_user_boundary`

- 代码：`im_flutter_sdk/native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_create_account_empty_user_boundary`
- 业务说明：createAccount：空 userId/password 边界，冻结真实模拟器参数校验错误，不创建新账号
- 类型：普通
- 状态/版本说明：5.0 不可用
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：使用空账号参数创建账号并验证参数错误
     - 预期：该原测试目标在 5.0 中不再成立。移除客户端 createAccount（残留，注册走 REST）
- 关键断言：
  1. 校验异常返回：错误码 205，错误描述“illegal user name”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 5. `im_flutter_sdk/native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_current_token_and_device_id`

- 代码：`im_flutter_sdk/native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_current_token_and_device_id`
- 业务说明：getToken / getCurrentDeviceId：已登录 session 下获取 token 和当前设备信息，校验关键字段非空
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：读取当前登录令牌并验证非空
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  2. 操作：读取当前设备信息并验证返回结构非空
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 6. `im_flutter_sdk/native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_init_repeated_call_idempotent`

- 代码：`im_flutter_sdk/native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_init_repeated_call_idempotent`
- 业务说明：init：SDK 已初始化后重复调用，验证原生幂等返回 result=null，不改变当前登录态
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：重复初始化客户端并验证幂等返回
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  2. 操作：验证重复初始化未清空当前登录用户
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 7. `im_flutter_sdk/native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_connection_state_queries`

- 代码：`im_flutter_sdk/native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_connection_state_queries`
- 业务说明：isConnected / isLoggedIn之前：已登录 session 下查询连接态和历史登录态，均应返回 true
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：查询连接状态并验证当前连接正常
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  2. 操作：查询历史登录状态并验证登录记录存在
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 8. `im_flutter_sdk/native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_session_sensitive_api_boundaries[changeAppKey-info1-expected_result1]`

- 代码：`im_flutter_sdk/native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_session_sensitive_api_boundaries[changeAppKey-info1-expected_result1]`
- 业务说明：renew/changeAppKey/device-kick 类方法：使用不会破坏当前 session 的边界入参冻结真实错误返回
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：执行会话敏感接口边界参数并验证错误语义
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 9. `im_flutter_sdk/native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_session_sensitive_api_boundaries[getLoggedInDevicesFromServer-info2-expected_result2]`

- 代码：`im_flutter_sdk/native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_session_sensitive_api_boundaries[getLoggedInDevicesFromServer-info2-expected_result2]`
- 业务说明：renew/changeAppKey/device-kick 类方法：使用不会破坏当前 session 的边界入参冻结真实错误返回
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：执行会话敏感接口边界参数并验证错误语义
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 10. `im_flutter_sdk/native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_session_sensitive_api_boundaries[kickAllDevices-info4-expected_result4]`

- 代码：`im_flutter_sdk/native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_session_sensitive_api_boundaries[kickAllDevices-info4-expected_result4]`
- 业务说明：renew/changeAppKey/device-kick 类方法：使用不会破坏当前 session 的边界入参冻结真实错误返回
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：执行会话敏感接口边界参数并验证错误语义
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 11. `im_flutter_sdk/native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_session_sensitive_api_boundaries[kickDevice-info3-expected_result3]`

- 代码：`im_flutter_sdk/native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_session_sensitive_api_boundaries[kickDevice-info3-expected_result3]`
- 业务说明：renew/changeAppKey/device-kick 类方法：使用不会破坏当前 session 的边界入参冻结真实错误返回
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：执行会话敏感接口边界参数并验证错误语义
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 12. `im_flutter_sdk/native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_session_sensitive_api_boundaries[loginWithAgoraToken-info5-expected_result5]`

- 代码：`im_flutter_sdk/native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_session_sensitive_api_boundaries[loginWithAgoraToken-info5-expected_result5]`
- 业务说明：renew/changeAppKey/device-kick 类方法：使用不会破坏当前 session 的边界入参冻结真实错误返回
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：执行会话敏感接口边界参数并验证错误语义
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 13. `im_flutter_sdk/native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_session_sensitive_api_boundaries[renewToken-info0-expected_result0]`

- 代码：`im_flutter_sdk/native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_session_sensitive_api_boundaries[renewToken-info0-expected_result0]`
- 业务说明：renew/changeAppKey/device-kick 类方法：使用不会破坏当前 session 的边界入参冻结真实错误返回
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：执行会话敏感接口边界参数并验证错误语义
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 14. `im_flutter_sdk/native-auto-test/tests/client/test_client.py::test_client_change_app_id`

- 代码：`im_flutter_sdk/native-auto-test/tests/client/test_client.py::test_client_change_app_id`
- 业务说明：session 已登录 deviceA，校验 changeAppId 调用成功
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：切换应用标识并验证调用成功
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 15. `im_flutter_sdk/native-auto-test/tests/client/test_client.py::test_client_get_current_user`

- 代码：`im_flutter_sdk/native-auto-test/tests/client/test_client.py::test_client_get_current_user`
- 业务说明：session 已登录 deviceA，校验 getCurrentUser 返回当前用户
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：查询当前登录用户并验证返回用户信息
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 16. `im_flutter_sdk/native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_update_runtime_setting_success[acceptInvitationAlways-info6]`

- 代码：`im_flutter_sdk/native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_update_runtime_setting_success[acceptInvitationAlways-info6]`
- 业务说明：update*Setting：逐项更新运行时配置，冻结真实模拟器返回 result=null 的成功语义
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：更新客户端运行时配置并验证设置成功
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 17. `im_flutter_sdk/native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_update_runtime_setting_success[updateDeleteMessagesWhenLeaveGroupSetting-info2]`

- 代码：`im_flutter_sdk/native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_update_runtime_setting_success[updateDeleteMessagesWhenLeaveGroupSetting-info2]`
- 业务说明：update*Setting：逐项更新运行时配置，冻结真实模拟器返回 result=null 的成功语义
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：更新客户端运行时配置并验证设置成功
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 18. `im_flutter_sdk/native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_update_runtime_setting_success[updateDeleteMessageWhenLeaveRoomSetting-info3]`

- 代码：`im_flutter_sdk/native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_update_runtime_setting_success[updateDeleteMessageWhenLeaveRoomSetting-info3]`
- 业务说明：update*Setting：逐项更新运行时配置，冻结真实模拟器返回 result=null 的成功语义
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：更新客户端运行时配置并验证设置成功
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 19. `im_flutter_sdk/native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_update_runtime_setting_success[updateDeliveryAckSetting-info8]`

- 代码：`im_flutter_sdk/native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_update_runtime_setting_success[updateDeliveryAckSetting-info8]`
- 业务说明：update*Setting：逐项更新运行时配置，冻结真实模拟器返回 result=null 的成功语义
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：更新客户端运行时配置并验证设置成功
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 20. `im_flutter_sdk/native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_update_runtime_setting_success[updateMessagesReceiveCallbackIncludeSendSetting-info10]`

- 代码：`im_flutter_sdk/native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_update_runtime_setting_success[updateMessagesReceiveCallbackIncludeSendSetting-info10]`
- 业务说明：update*Setting：逐项更新运行时配置，冻结真实模拟器返回 result=null 的成功语义
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：更新客户端运行时配置并验证设置成功
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 21. `im_flutter_sdk/native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_update_runtime_setting_success[updateAutoDownloadAttachmentThumbnailSetting-info7]`

- 代码：`im_flutter_sdk/native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_update_runtime_setting_success[updateAutoDownloadAttachmentThumbnailSetting-info7]`
- 业务说明：update*Setting：逐项更新运行时配置，冻结真实模拟器返回 result=null 的成功语义
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：更新客户端运行时配置并验证设置成功
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 22. `im_flutter_sdk/native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_update_runtime_setting_success[updateAutoAcceptGroupInvitationSetting-info5]`

- 代码：`im_flutter_sdk/native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_update_runtime_setting_success[updateAutoAcceptGroupInvitationSetting-info5]`
- 业务说明：update*Setting：逐项更新运行时配置，冻结真实模拟器返回 result=null 的成功语义
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：更新客户端运行时配置并验证设置成功
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 23. `im_flutter_sdk/native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_update_runtime_setting_success[updateLoginExtensionInfo-info1]`

- 代码：`im_flutter_sdk/native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_update_runtime_setting_success[updateLoginExtensionInfo-info1]`
- 业务说明：update*Setting：逐项更新运行时配置，冻结真实模拟器返回 result=null 的成功语义
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：更新客户端运行时配置并验证设置成功
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 24. `im_flutter_sdk/native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_update_runtime_setting_success[updateRegradeMessagesSetting-info11]`

- 代码：`im_flutter_sdk/native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_update_runtime_setting_success[updateRegradeMessagesSetting-info11]`
- 业务说明：update*Setting：逐项更新运行时配置，冻结真实模拟器返回 result=null 的成功语义
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：更新客户端运行时配置并验证设置成功
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 25. `im_flutter_sdk/native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_update_runtime_setting_success[updateRoomOwnerCanLeaveSetting-info4]`

- 代码：`im_flutter_sdk/native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_update_runtime_setting_success[updateRoomOwnerCanLeaveSetting-info4]`
- 业务说明：update*Setting：逐项更新运行时配置，冻结真实模拟器返回 result=null 的成功语义
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：更新客户端运行时配置并验证设置成功
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 26. `im_flutter_sdk/native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_update_runtime_setting_success[updateSortMessageByServerTimeSetting-info9]`

- 代码：`im_flutter_sdk/native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_update_runtime_setting_success[updateSortMessageByServerTimeSetting-info9]`
- 业务说明：update*Setting：逐项更新运行时配置，冻结真实模拟器返回 result=null 的成功语义
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：更新客户端运行时配置并验证设置成功
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 27. `im_flutter_sdk/native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_update_runtime_setting_success[updateUsingHttpsOnlySetting-info0]`

- 代码：`im_flutter_sdk/native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_update_runtime_setting_success[updateUsingHttpsOnlySetting-info0]`
- 业务说明：update*Setting：逐项更新运行时配置，冻结真实模拟器返回 result=null 的成功语义
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：更新客户端运行时配置并验证设置成功
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

## contact

### 1. `im_flutter_sdk/native-auto-test/tests/contact/test_contact.py::test_contact_block_list_flow_then_unblock_restores_friend`

- 代码：`im_flutter_sdk/native-auto-test/tests/contact/test_contact.py::test_contact_block_list_flow_then_unblock_restores_friend`
- 业务说明：多端拓扑：A 拉黑 B → A 全部端黑名单含 B、好友列表不含 B，B 全部端好友列表仍含 A；A 取消拉黑后好友恢复
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：与 B 建立好友
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：拉黑
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：A 全部在线端黑名单均含 B（账号级服务端状态一致）
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  4. 操作：A 全部在线端好友列表均不含 B
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：B 全部在线端好友列表仍含 A
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  6. 操作：取消拉黑
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  7. 操作：A 全部在线端好友列表恢复含 B
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 2. `im_flutter_sdk/native-auto-test/tests/contact/test_friend_info_sync.py::test_friend_info_sync_on_peer_metadata_change`

- 代码：`im_flutter_sdk/native-auto-test/tests/contact/test_friend_info_sync.py::test_friend_info_sync_on_peer_metadata_change`
- 业务说明：多端拓扑：REST 修改 B 用户属性后，A 全部在线端拉取 B 的用户信息一致（userId/remark/updatedAt）
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：与 B 建立好友
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：测试准备：清理历史事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  3. 操作：通过 REST 修改 B 的用户元数据
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：A 全部在线端拉取 B 的用户信息一致
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 3. `im_flutter_sdk/native-auto-test/tests/contact/test_contact.py::test_friend_add_decline_and_verify_not_friends`

- 代码：`im_flutter_sdk/native-auto-test/tests/contact/test_contact.py::test_friend_add_decline_and_verify_not_friends`
- 业务说明：发送账号添加接收账号为好友（申请回调接收账号全部在线端收到），接收端拒绝后 发送端收到拒绝回调；双方好友列表均不应包含对方
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：向 发送好友申请
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：接收账号端 收到好友申请回调（INVITED）
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  3. 操作：拒绝好友申请（declineInvitation）
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  4. 操作：收到拒绝回调（INVITATION_DECLINED）
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 4. `im_flutter_sdk/native-auto-test/tests/contact/test_contact.py::test_friend_add_accept_and_list`

- 代码：`im_flutter_sdk/native-auto-test/tests/contact/test_contact.py::test_friend_add_accept_and_list`
- 业务说明：发送账号添加接收账号为好友（申请回调接收账号全部在线端收到），接收端同意后 发送端收到同意回调，分别获取双方好友列表，最后发送端删除好友
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：向 发送好友申请
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：接收账号端 收到好友申请回调（INVITED）
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  3. 操作：同意好友申请（acceptInvitation）
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  4. 操作：收到同意回调（INVITATION_ACCEPTED）
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：删除好友
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 5. `im_flutter_sdk/native-auto-test/tests/contact/test_contact.py::test_contact_delete_contact_nonexistent_user`

- 代码：`im_flutter_sdk/native-auto-test/tests/contact/test_contact.py::test_contact_delete_contact_nonexistent_user`
- 业务说明：删除Contact：目标用户不存在，预期失败
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：删除不存在用户并验证用户不存在错误
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 204，错误描述“User does not exist”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 6. `im_flutter_sdk/native-auto-test/tests/contact/test_contact.py::test_contact_add_user_to_block_list_nonexistent`

- 代码：`im_flutter_sdk/native-auto-test/tests/contact/test_contact.py::test_contact_add_user_to_block_list_nonexistent`
- 业务说明：addUserToBlockList：拉黑不存在用户，预期失败
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：将不存在用户加入黑名单并验证用户不存在错误
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 204，错误描述“User does not exist”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 7. `im_flutter_sdk/native-auto-test/tests/contact/test_contact_offline_friendship.py::test_contact_offline_requester_receives_peer_delete_after_relogin`

- 代码：`im_flutter_sdk/native-auto-test/tests/contact/test_contact_offline_friendship.py::test_contact_offline_requester_receives_peer_delete_after_relogin`
- 业务说明：A 离线期间 B 删除好友；A 重登收到删除事件且双方关系清空
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：测试准备：建立好友关系并让申请账号全部端点离线
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：接收账号删除好友并验证动作响应
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：申请账号全部端点重新登录并验证主端离线删除事件与最终状态
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。

### 8. `im_flutter_sdk/native-auto-test/tests/contact/test_contact_offline_friendship.py::test_contact_offline_invitation_decline_after_login`

- 代码：`im_flutter_sdk/native-auto-test/tests/contact/test_contact_offline_friendship.py::test_contact_offline_invitation_decline_after_login`
- 业务说明：B 登录收到离线申请后拒绝，A 收到拒绝事件且双方保持非好友
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：测试准备：发送好友申请并让接收账号恢复全部端点
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：接收账号动作端拒绝好友申请并验证响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  3. 操作：验证拒绝事件及双方全部端点的非好友状态
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。

### 9. `im_flutter_sdk/native-auto-test/tests/contact/test_contact_offline_friendship.py::test_contact_offline_invitation_accept_after_login`

- 代码：`im_flutter_sdk/native-auto-test/tests/contact/test_contact_offline_friendship.py::test_contact_offline_invitation_accept_after_login`
- 业务说明：B 登录收到离线申请后同意，A 收到接受与联系人新增事件
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：测试准备：发送好友申请并让接收账号恢复全部端点
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：接收账号动作端同意好友申请并验证响应
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  3. 操作：验证关键接受事件及双方全部端点的最终好友状态
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。

### 10. `im_flutter_sdk/native-auto-test/tests/contact/test_contact_offline_friendship.py::test_contact_offline_recipient_receives_delete_after_relogin`

- 代码：`im_flutter_sdk/native-auto-test/tests/contact/test_contact_offline_friendship.py::test_contact_offline_recipient_receives_delete_after_relogin`
- 业务说明：B 离线期间 A 删除好友；B 重登收到删除事件且双方关系清空
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：测试准备：建立好友关系并让接收账号全部端点离线
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：申请账号删除好友并验证动作响应
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：接收账号全部端点重新登录并验证主端离线删除事件与最终状态
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。

### 11. `im_flutter_sdk/native-auto-test/tests/contact/test_contact_offline_friendship.py::test_contact_offline_requester_receives_decline_after_relogin`

- 代码：`im_flutter_sdk/native-auto-test/tests/contact/test_contact_offline_friendship.py::test_contact_offline_requester_receives_decline_after_relogin`
- 业务说明：B 收到申请后让 A 离线；B 拒绝，A 重登收到离线拒绝结果
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：测试准备：发送好友申请后让申请账号全部端点离线
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：接收账号拒绝好友申请并验证动作端响应
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  3. 操作：申请账号全部端点重新登录并验证离线拒绝事件与最终状态
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。

### 12. `im_flutter_sdk/native-auto-test/tests/contact/test_contact_offline_friendship.py::test_contact_offline_requester_receives_accept_after_relogin`

- 代码：`im_flutter_sdk/native-auto-test/tests/contact/test_contact_offline_friendship.py::test_contact_offline_requester_receives_accept_after_relogin`
- 业务说明：B 收到申请后让 A 离线；B 同意，A 重登收到离线接受结果
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：测试准备：发送好友申请后让申请账号全部端点离线
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：接收账号同意好友申请并验证动作端响应
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  3. 操作：申请账号全部端点重新登录并验证离线接受事件与最终好友状态
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。

### 13. `im_flutter_sdk/native-auto-test/tests/contact/test_contact_offline_friendship.py::test_contact_offline_invitation_received_after_login`

- 代码：`im_flutter_sdk/native-auto-test/tests/contact/test_contact_offline_friendship.py::test_contact_offline_invitation_received_after_login`
- 业务说明：B 先离线，A 发起申请；B 登录收到邀请，但双方仍不是好友
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：测试准备：让接收账号全部端点离线并发送好友申请
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：接收账号逐端登录并验证离线好友申请已消费
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 当前测试步骤的同步响应、异步事件和最终业务状态满足代码断言。
  2. 任一关键字段、回调、列表、数量或最终状态不符时，Case 判定失败。

### 14. `im_flutter_sdk/native-auto-test/tests/contact/test_friend_info_sync.py::test_contact_data_sync_events_after_relogin`

- 代码：`im_flutter_sdk/native-auto-test/tests/contact/test_friend_info_sync.py::test_contact_data_sync_events_after_relogin`
- 业务说明：5.0 Contact 数据同步：配置 CONTACTS 数据同步后重新登录，验证 Client 层原生数据同步开始/完成事件能够通过测试桥接到达
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：测试准备：建立好友关系并清理历史事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  2. 操作：配置 Contact 数据同步类型（CONTACTS=2）
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  3. 操作：退出当前登录会话
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  4. 操作：重新登录并触发 Contact 数据同步
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：验证 Contact 数据同步开始与完成事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 15. `im_flutter_sdk/native-auto-test/tests/contact/test_contact.py::test_contact_remark_special_chars_length_101`

- 代码：`im_flutter_sdk/native-auto-test/tests/contact/test_contact.py::test_contact_remark_special_chars_length_101`
- 业务说明：备注为 101 长度且含特殊字符
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：测试准备：建立好友关系
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：设置超长特殊字符备注并验证长度错误
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  3. 操作：测试后置：删除好友关系
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验异常返回：错误码 4，错误描述“remark length must less than 100”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 16. `im_flutter_sdk/native-auto-test/tests/contact/test_contact.py::test_contact_remark_empty_string`

- 代码：`im_flutter_sdk/native-auto-test/tests/contact/test_contact.py::test_contact_remark_empty_string`
- 业务说明：成为好友后将备注设为空字符串
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：测试准备：建立好友关系
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 设置空好友备注并验证请求成功
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  3. 操作：查询好友资料并验证备注为空
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  4. 操作：测试后置：删除好友关系
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 17. `im_flutter_sdk/native-auto-test/tests/contact/test_contact.py::test_contact_fetch_all_contact_ids`

- 代码：`im_flutter_sdk/native-auto-test/tests/contact/test_contact.py::test_contact_fetch_all_contact_ids`
- 业务说明：获取 all contact ids
- 类型：普通
- 状态/版本说明：5.0 不可用
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：获取 all contact ids
     - 预期：该原测试目标在 5.0 中不再成立。移除 fetchContacts/fetchAllContactIds/getAllContactIds（残留，无分页拉联系人）
- 关键断言：
  1. 校验关键字段：result、list。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 18. `im_flutter_sdk/native-auto-test/tests/contact/test_contact.py::test_contact_get_all_contact_ids`

- 代码：`im_flutter_sdk/native-auto-test/tests/contact/test_contact.py::test_contact_get_all_contact_ids`
- 业务说明：读取全部联系人 ID 并验证返回列表
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：读取全部联系人 ID 并验证返回列表
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result、list。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 19. `im_flutter_sdk/native-auto-test/tests/contact/test_contact.py::test_contact_fetch_all_fetch_page_fetch_ids_get_local_lists`

- 代码：`im_flutter_sdk/native-auto-test/tests/contact/test_contact.py::test_contact_fetch_all_fetch_page_fetch_ids_get_local_lists`
- 业务说明：加好友并设置备注后：getAllContactsFromDB 本地读取； 再验证 fetchAllContacts（本地好友）、getContact、getAllContacts（本地）
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：测试准备：建立好友关系并设置备注
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 设置好友备注并验证成功
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  3. 操作：读取本地联系人 ID 列表并验证包含 B
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：读取本地全部联系人并验证 B 存在
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  5. 操作：读取单个联系人并验证备注
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  6. 操作：读取全部本地联系人对象并验证 B 存在
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  7. 操作：测试后置：删除好友关系
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 20. `im_flutter_sdk/native-auto-test/tests/contact/test_contact.py::test_contact_delete_contact_not_friend`

- 代码：`im_flutter_sdk/native-auto-test/tests/contact/test_contact.py::test_contact_delete_contact_not_friend`
- 业务说明：删除Contact：对方非好友（未建立好友关系），预期失败
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：删除非好友并验证当前返回语义
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 21. `im_flutter_sdk/native-auto-test/tests/contact/test_contact.py::test_contact_remove_from_block_list_when_not_blocked`

- 代码：`im_flutter_sdk/native-auto-test/tests/contact/test_contact.py::test_contact_remove_from_block_list_when_not_blocked`
- 业务说明：已是好友但未加入黑名单时调用 removeUserFromBlockList
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：测试准备：清理关系并建立好友关系
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：查询黑名单并验证好友不在黑名单
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  3. 操作：移除未加入的黑名单成员并验证幂等成功
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：测试后置：删除好友关系
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 22. `im_flutter_sdk/native-auto-test/tests/contact/test_contact.py::test_contact_remark_not_preserved_after_delete_and_readd`

- 代码：`im_flutter_sdk/native-auto-test/tests/contact/test_contact.py::test_contact_remark_not_preserved_after_delete_and_readd`
- 业务说明：A 删除 B 后再次添加并同意，先前备注一般不应保留（以服务端为准；此处断言与旧备注不同或为空）
- 类型：普通
- 状态/版本说明：5.0 不可用
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：A 删除 B 后再次添加并同意，先前备注一般不应保留（以服务端为准；此处断言与旧备注不同或为空）。
     - 预期：该原测试目标在 5.0 中不再成立。getContact 为本地拉取（fetchContactFromLocal），本地 EMContact 不携带 remark（恒空）—— 备注保留/失效语义无法通过 getContact 验证；需服务端拉取 API（如有）
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 23. `im_flutter_sdk/native-auto-test/tests/contact/test_contact.py::test_contact_remark_set_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/contact/test_contact.py::test_contact_remark_set_success`
- 业务说明：A 添加 B、B 同意后，A 调用 setContactRemark 并严格验证 5.0 原生成功响应
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：测试准备：建立好友关系
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 设置好友备注并验证请求成功
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  3. 操作：测试后置：删除好友关系
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 24. `im_flutter_sdk/native-auto-test/tests/contact/test_contact.py::test_contact_accept_invitation_without_pending`

- 代码：`im_flutter_sdk/native-auto-test/tests/contact/test_contact.py::test_contact_accept_invitation_without_pending`
- 业务说明：acceptInvitation：无待处理邀请时同意某用户
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：无待处理邀请时同意好友申请并验证返回语义
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  2. 操作：查询目标用户好友关系并验证列表为空
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result、list。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 25. `im_flutter_sdk/native-auto-test/tests/contact/test_contact.py::test_contact_add_self`

- 代码：`im_flutter_sdk/native-auto-test/tests/contact/test_contact.py::test_contact_add_self`
- 业务说明：addContact：不能添加自己为好友，预期失败
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：添加自己为好友并验证参数错误
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 101，错误描述“User ID is invalid”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 26. `im_flutter_sdk/native-auto-test/tests/contact/test_contact.py::test_contact_add_nonexistent_user`

- 代码：`im_flutter_sdk/native-auto-test/tests/contact/test_contact.py::test_contact_add_nonexistent_user`
- 业务说明：addContact：目标用户不存在，预期失败（顶层 error）
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：添加不存在用户并验证用户不存在错误
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 204，错误描述“User does not exist”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 27. `im_flutter_sdk/native-auto-test/tests/contact/test_contact.py::test_contact_add_empty_user_id`

- 代码：`im_flutter_sdk/native-auto-test/tests/contact/test_contact.py::test_contact_add_empty_user_id`
- 业务说明：addContact：userId 为空字符串，预期参数非法类错误
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：使用空用户 ID 添加好友并验证参数错误
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 101，错误描述“User ID is invalid”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 28. `im_flutter_sdk/native-auto-test/tests/contact/test_contact.py::test_contact_decline_invitation_without_pending`

- 代码：`im_flutter_sdk/native-auto-test/tests/contact/test_contact.py::test_contact_decline_invitation_without_pending`
- 业务说明：declineInvitation：对方从未发起邀请（不存在用户 / 无待处理邀请）时拒绝，按服务端实际响应断言
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备B已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：无待处理邀请时拒绝好友申请并验证返回语义
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 29. `im_flutter_sdk/native-auto-test/tests/contact/test_contact.py::test_contact_fetch_contacts_page_size_exceeds_50`

- 代码：`im_flutter_sdk/native-auto-test/tests/contact/test_contact.py::test_contact_fetch_contacts_page_size_exceeds_50`
- 业务说明：fetchContacts：pageSize 大于 50（5.0 已移除分页，忽略 pageSize）
- 类型：普通
- 状态/版本说明：5.0 不可用
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：fetchContacts：pageSize 大于 50（5.0 已移除分页，忽略 pageSize）。
     - 预期：该原测试目标在 5.0 中不再成立。移除分页拉联系人（fetchContacts 本地全量，忽略 pageSize）—— 超出 50 的边界校验不存在
- 关键断言：
  1. 校验异常返回：错误码 112，错误描述“getContacts | page size more than max limit : 50”。
  2. 校验关键字段：cursor。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 30. `im_flutter_sdk/native-auto-test/tests/contact/test_contact.py::test_contact_fetch_contacts_page_size_zero`

- 代码：`im_flutter_sdk/native-auto-test/tests/contact/test_contact.py::test_contact_fetch_contacts_page_size_zero`
- 业务说明：fetchContacts：pageSize 为 0（5.0 已移除分页，忽略 pageSize）
- 类型：普通
- 状态/版本说明：5.0 不可用
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：fetchContacts：pageSize 为 0（5.0 已移除分页，忽略 pageSize）。
     - 预期：该原测试目标在 5.0 中不再成立。移除分页拉联系人（fetchContacts 改为本地全量 asyncFetchAllContactsFromLocal，忽略 pageSize）—— pageSize 边界校验不存在，case 语义失效
- 关键断言：
  1. 校验关键字段：result、list、cursor。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 31. `im_flutter_sdk/native-auto-test/tests/contact/test_contact.py::test_contact_fetch_contacts_page_size_negative`

- 代码：`im_flutter_sdk/native-auto-test/tests/contact/test_contact.py::test_contact_fetch_contacts_page_size_negative`
- 业务说明：fetchContacts：pageSize 为负数（5.0 已移除分页，忽略 pageSize）
- 类型：普通
- 状态/版本说明：5.0 不可用
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：fetchContacts：pageSize 为负数（5.0 已移除分页，忽略 pageSize）。
     - 预期：该原测试目标在 5.0 中不再成立。移除分页拉联系人（fetchContacts 本地全量，忽略 pageSize）—— 负数边界校验不存在
- 关键断言：
  1. 校验关键字段：result、list、cursor。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 32. `im_flutter_sdk/native-auto-test/tests/contact/test_contact_remaining_api_coverage.py::test_contact_get_all_contacts_from_db_after_server_sync`

- 代码：`im_flutter_sdk/native-auto-test/tests/contact/test_contact_remaining_api_coverage.py::test_contact_get_all_contacts_from_db_after_server_sync`
- 业务说明：getAllContactsFromDB：建立好友后，从本地 DB 获取好友 ID 列表（5.0 本地读取；原 getAllContactsFromServer 服务端拉取已移除）
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：测试准备：建立好友关系并完成本地同步
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  2. 操作：读取本地联系人 ID 并验证包含 B
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  3. 操作：测试后置：删除好友关系
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 33. `im_flutter_sdk/native-auto-test/tests/contact/test_contact_remaining_api_coverage.py::test_contact_get_block_list_from_db_after_server_sync`

- 代码：`im_flutter_sdk/native-auto-test/tests/contact/test_contact_remaining_api_coverage.py::test_contact_get_block_list_from_db_after_server_sync`
- 业务说明：getBlockListFromDB：拉黑并同步服务端黑名单后，从本地 DB 获取黑名单 ID 列表
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：测试准备：建立好友关系并加入黑名单
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：查询服务端黑名单并验证包含 B
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  3. 操作：读取本地黑名单并验证包含 B
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：测试后置：移出黑名单并删除好友关系
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 34. `im_flutter_sdk/native-auto-test/tests/contact/test_contact.py::test_contact_get_block_list_from_server_returns_list`

- 代码：`im_flutter_sdk/native-auto-test/tests/contact/test_contact.py::test_contact_get_block_list_from_server_returns_list`
- 业务说明：getBlockListFromServer：从服务器拉黑名单，result 为列表（可为空）
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：查询服务端黑名单并验证返回列表
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result、list。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 35. `im_flutter_sdk/native-auto-test/tests/contact/test_contact_remaining_api_coverage.py::test_contact_get_self_ids_on_other_platform_returns_list`

- 代码：`im_flutter_sdk/native-auto-test/tests/contact/test_contact_remaining_api_coverage.py::test_contact_get_self_ids_on_other_platform_returns_list`
- 业务说明：getSelfIdsOnOtherPlatform：先确保当前账号只有 deviceA 在线，再严格验证空列表
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：测试准备：确保其他平台设备退出登录
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：查询当前账号其他平台设备并验证列表为空
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  3. 操作：测试后置：恢复其他平台设备登录
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 36. `im_flutter_sdk/native-auto-test/tests/contact/test_contact.py::test_contact_remove_from_block_list_nonexistent_user`

- 代码：`im_flutter_sdk/native-auto-test/tests/contact/test_contact.py::test_contact_remove_from_block_list_nonexistent_user`
- 业务说明：removeUserFromBlockList：目标用户不存在，服务端幂等返回成功（HTTP 200），result 为用户名
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：移除不存在用户的黑名单关系并验证幂等返回
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 37. `im_flutter_sdk/native-auto-test/tests/contact/test_contact.py::test_contact_set_contact_remark_non_friend`

- 代码：`im_flutter_sdk/native-auto-test/tests/contact/test_contact.py::test_contact_set_contact_remark_non_friend`
- 业务说明：setContactRemark：对非好友设置备注，预期失败
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：为非好友设置备注并验证好友关系错误
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 221，错误描述“updateRemark | they are not friends, please add as a friend first.”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

## group

### 1. `im_flutter_sdk/native-auto-test/tests/group/test_group_join_requests_and_invitations.py::test_group_request_to_join_and_decline_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_join_requests_and_invitations.py::test_group_request_to_join_and_decline_success`
- 业务说明：成员申请入群并由群主拒绝：申请/拒绝事件同步到收发账号全部在线端
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：B 申请加入公开群
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证申请加入公开群返回的响应 result 与关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：发送账号全部在线端同步验证入群申请事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：A 拒绝入群申请
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  7. 操作：验证拒绝入群申请返回的响应 result 与关键字段
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  8. 操作：接收账号全部在线端同步验证申请拒绝事件
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 2. `im_flutter_sdk/native-auto-test/tests/group/test_group_join_requests_and_invitations.py::test_group_request_to_join_and_accept_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_join_requests_and_invitations.py::test_group_request_to_join_and_accept_success`
- 业务说明：成员申请入群并由群主同意：申请/同意事件同步到收发账号全部在线端
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：B 申请加入公开群
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证申请加入公开群返回的响应 result 与关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：发送账号全部在线端同步验证入群申请事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：A 同意入群申请
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  7. 操作：验证同意入群申请返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  8. 操作：接收账号全部在线端同步验证申请通过事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 3. `im_flutter_sdk/native-auto-test/tests/group/test_group_owner_removal_matrix.py::test_group_owner_must_transfer_before_leaving`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_owner_removal_matrix.py::test_group_owner_must_transfer_before_leaving`
- 业务说明：当前群主不能退群；转让后新群主 B 收到 owner 变更事件，A 退出后 B 收到成员退出事件
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 退出群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证退出群返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  4. 操作：A 转让群主
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：验证转让群主返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  6. 操作：B 账号全部在线端消费 owner 变更事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  7. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  8. 操作：B 账号全部在线端收到成员退出事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验异常返回：错误码 603。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 校验关键字段：result。
  4. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 4. `im_flutter_sdk/native-auto-test/tests/group/test_group_members.py::test_group_join_and_leave_public_group`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_members.py::test_group_join_and_leave_public_group`
- 业务说明：多端拓扑：A 建 PublicOpenJoin 公开群，B 加入/退出；成员事件同步到 A 全部在线端，A 全部端查询成员快照一致
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：建 PublicOpenJoin 公开群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：加入公开群
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：确认加入请求已提交
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：A 全部在线端收到成员加入事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：A 全部在线端查询成员快照均含 B（账号级服务端状态一致）
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  6. 操作：退出公开群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  7. 操作：确认退出请求已提交
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  8. 操作：A 全部在线端收到成员退出事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result、list、cursor。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 5. `im_flutter_sdk/native-auto-test/tests/group/test_group_lifecycle.py::test_group_create_group`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_lifecycle.py::test_group_create_group`
- 业务说明：多端拓扑：A 建群并邀请 B；邀请/自动接受事件同步到 B 全部在线端，成员加入事件同步到 A 全部在线端
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：建群并邀请
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：B 全部在线端收到邀请/自动接受事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  3. 操作：A 全部在线端收到成员加入事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  4. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。

### 6. `im_flutter_sdk/native-auto-test/tests/group/test_group_lifecycle.py::test_group_get_group`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_lifecycle.py::test_group_get_group`
- 业务说明：多端拓扑：A 建群并邀请 B；A 的主端和副端先消费成员同步事件， 再分别查询本地群缓存，验证多设备本地状态一致
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：建群并邀请
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 全部在线端消费成员加入同步事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  3. 操作：A 全部在线端查询本地群快照一致
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。

### 7. `im_flutter_sdk/native-auto-test/tests/group/test_group_roles.py::test_group_add_admin_and_remove_admin_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_roles.py::test_group_add_admin_and_remove_admin_success`
- 业务说明：多端拓扑：A 添加/移除 B 为管理员；admin 事件同步到 B 全部在线端，A 全部端不收 admin 事件（原生语义）
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：建群并邀请
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：添加 为管理员
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：确认添加管理员请求已提交（result 含 adminList）
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：B 全部在线端收到管理员添加事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：A 全部在线端不收管理员添加事件（原生语义：admin 事件仅 B 收）
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：A 全部在线端查询群规格 adminList 含 B（账号级服务端状态一致）
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  7. 操作：移除 的管理员
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  8. 操作：确认移除管理员请求已提交（result 含 adminList）
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result、list。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 8. `im_flutter_sdk/native-auto-test/tests/group/test_group_roles.py::test_group_update_owner_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_roles.py::test_group_update_owner_success`
- 业务说明：多端拓扑：A 转让群 owner 给 B；B 全部在线端收到 owner 变更事件并查询群 owner 一致
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：建群并邀请
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：转让群 owner 给
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：确认转让请求已提交（result 含 owner）
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  4. 操作：B 全部在线端收到 owner 变更事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：B 全部在线端查询群规格 owner 均为 B（账号级服务端状态一致）
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  6. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 9. `im_flutter_sdk/native-auto-test/tests/group/test_group_owner_removal_matrix.py::test_group_non_member_cannot_transfer_ownership`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_owner_removal_matrix.py::test_group_non_member_cannot_transfer_ownership`
- 业务说明：非成员 C 不能把 A 的群转让给成员 B
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：B 转让群主
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证转让群主返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  4. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 603，错误描述“group member permission is required”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 10. `im_flutter_sdk/native-auto-test/tests/group/test_group_message_send.py::test_group_message_ack_boundary_methods`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_message_send.py::test_group_message_ack_boundary_methods`
- 业务说明：非法群消息 ID 与群 ID 调用群回执 API，冻结当前真实同步返回
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 发送群已读回执
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：验证发送群已读回执返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 110，错误描述“messages is empty”。
  2. 校验关键字段：msgId。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 11. `im_flutter_sdk/native-auto-test/tests/group/test_group_message_send.py::test_group_message_read_ack_updates_count`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_message_send.py::test_group_message_read_ack_updates_count`
- 业务说明：B 对真实群消息发送已读回执后，A 的群已读数量变为 1
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 发送一条需要群已读回执的文本消息。
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：B 接收该群消息并发送已读回执。
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：A 查询该消息的群已读数量，确认数量变为 1。
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、content、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 12. `im_flutter_sdk/native-auto-test/tests/group/test_group_shared_files.py::test_group_admin_upload_remove_shared_file_notifies_owner`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_shared_files.py::test_group_admin_upload_remove_shared_file_notifies_owner`
- 业务说明：管理员 B 上传/删除共享文件：新增/删除事件同步到 owner 账号（A）全部在线端；B 全端收管理员提升事件
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 添加群管理员
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证 添加群管理员返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：B 账号全部在线端收到管理员提升事件（onGroupAdminAdded）
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：A 账号全部在线端不收到管理员提升事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 13. `im_flutter_sdk/native-auto-test/tests/group/test_group_owner_removal_matrix.py::test_group_owner_removes_admin_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_owner_removal_matrix.py::test_group_owner_removes_admin_success`
- 业务说明：管理员仍可由群主移除：移除事件同步到接收账号全部在线端
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 添加群管理员
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证 添加群管理员返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：A 移除群成员
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  7. 操作：验证 移除群成员返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  8. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 14. `im_flutter_sdk/native-auto-test/tests/group/test_group_owner_removal_matrix.py::test_group_batch_remove_ignores_owner_and_non_member_but_removes_valid_member`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_owner_removal_matrix.py::test_group_batch_remove_ignores_owner_and_non_member_but_removes_valid_member`
- 业务说明：批量移除忽略 owner/非成员、移除有效成员：移除事件同步到接收账号全部在线端
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 移除群成员
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  4. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：验证 移除群成员返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  6. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 15. `im_flutter_sdk/native-auto-test/tests/group/test_group_owner_removal_matrix.py::test_group_non_owner_cannot_transfer_ownership[member]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_owner_removal_matrix.py::test_group_non_owner_cannot_transfer_ownership[member]`
- 业务说明：普通成员和管理员都不能调用 owner-only 的 updateGroupOwner
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 添加群管理员
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证 添加群管理员返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：B 转让群主
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：验证转让群主返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  6. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 603，错误描述“permission”。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 16. `im_flutter_sdk/native-auto-test/tests/group/test_group_owner_removal_matrix.py::test_group_non_owner_cannot_transfer_ownership[admin]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_owner_removal_matrix.py::test_group_non_owner_cannot_transfer_ownership[admin]`
- 业务说明：普通成员和管理员都不能调用 owner-only 的 updateGroupOwner
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 添加群管理员
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证 添加群管理员返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：B 转让群主
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：验证转让群主返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  6. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 603，错误描述“permission”。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 17. `im_flutter_sdk/native-auto-test/tests/group/test_group_owner_removal_matrix.py::test_group_remove_other_member_permission_by_role[member]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_owner_removal_matrix.py::test_group_remove_other_member_permission_by_role[member]`
- 业务说明：普通成员无权移除其他成员；管理员移除普通成员：退出事件同步到 owner 与操作管理员账号全部在线端
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 添加群管理员
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证 添加群管理员返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：B 移除群成员
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：owner 账号全部在线端收到成员退出事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  7. 操作：操作管理员账号全部在线端收到成员退出事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  8. 操作：验证 移除群成员返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 603，错误描述“permission”。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 校验关键字段：result。
  4. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 18. `im_flutter_sdk/native-auto-test/tests/group/test_group_owner_removal_matrix.py::test_group_remove_other_member_permission_by_role[admin]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_owner_removal_matrix.py::test_group_remove_other_member_permission_by_role[admin]`
- 业务说明：普通成员无权移除其他成员；管理员移除普通成员：退出事件同步到 owner 与操作管理员账号全部在线端
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 添加群管理员
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证 添加群管理员返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：B 移除群成员
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：owner 账号全部在线端收到成员退出事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  7. 操作：操作管理员账号全部在线端收到成员退出事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  8. 操作：验证 移除群成员返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 603，错误描述“permission”。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 校验关键字段：result。
  4. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 19. `im_flutter_sdk/native-auto-test/tests/group/test_group_announcement.py::test_group_owner_update_announcement_notifies_member`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_announcement.py::test_group_owner_update_announcement_notifies_member`
- 业务说明：前置：A 为群主，B 已入群且双方建群事件已消费
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：所有拓扑端点消费建群和入群事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  3. 操作：更新群公告
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：验证更新群公告返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  5. 操作：收到并校验群公告变更事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：不收到自己更新的群公告事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  7. 操作：查询服务端群公告
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  8. 操作：验证查询群公告返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 20. `im_flutter_sdk/native-auto-test/tests/group/test_group_announcement.py::test_group_admin_update_announcement_notifies_owner`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_announcement.py::test_group_admin_update_announcement_notifies_owner`
- 业务说明：前置：A 为群主、B 已入群；A 将 B 设置为管理员并消费管理员变更事件
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：所有拓扑端点消费建群和入群事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  3. 操作：添加群管理员
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：验证 添加群管理员返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  5. 操作：收到并校验管理员变更事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：不收到管理员变更事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  7. 操作：更新群公告
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  8. 操作：验证更新群公告返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 21. `im_flutter_sdk/native-auto-test/tests/group/test_group_join_requests_and_invitations.py::test_group_invitation_auto_accept_when_confirmation_required`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_join_requests_and_invitations.py::test_group_invitation_auto_accept_when_confirmation_required`
- 业务说明：前置：A/B 已登录；B 的 autoAcceptGroupInvitation 显式设置为 true
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：B 开启自动接受群邀请
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证自动接受群邀请设置已更新
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  4. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：接收账号全部在线端同步验证成员加入事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  7. 操作：发送账号全部在线端同步验证邀请接受和成员加入事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  8. 操作：接收账号全部在线端不收到邀请接受通知
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 22. `im_flutter_sdk/native-auto-test/tests/group/test_group_join_requests_and_invitations.py::test_group_invitation_explicit_accept_when_auto_accept_disabled`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_join_requests_and_invitations.py::test_group_invitation_explicit_accept_when_auto_accept_disabled`
- 业务说明：前置：A/B 已登录；B 的自动接受邀请基线为 true
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：B 关闭自动接受群邀请
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证自动接受群邀请设置已更新
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  4. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：接收账号全部在线端同步验证收到邀请事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  7. 操作：B 接受入群邀请
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  8. 操作：验证接受入群邀请返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 23. `im_flutter_sdk/native-auto-test/tests/group/test_group_join_requests_and_invitations.py::test_group_invitation_explicit_decline_when_auto_accept_disabled`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_join_requests_and_invitations.py::test_group_invitation_explicit_decline_when_auto_accept_disabled`
- 业务说明：前置：A/B 已登录；B 的自动接受邀请基线为 true
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：B 关闭自动接受群邀请
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证自动接受群邀请设置已更新
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  4. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：接收账号全部在线端同步验证收到邀请事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  7. 操作：B 拒绝入群邀请
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  8. 操作：验证拒绝入群邀请返回的响应 result 与关键字段
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：from、result、list。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 24. `im_flutter_sdk/native-auto-test/tests/group/test_group_shared_files.py::test_group_owner_upload_remove_shared_file_notifies_member`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_shared_files.py::test_group_owner_upload_remove_shared_file_notifies_member`
- 业务说明：前置：B 为群主、A 已入群；B 所在测试 App 已将默认素材准备为 Android 本地文件
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。

### 25. `im_flutter_sdk/native-auto-test/tests/group/test_group_moderation.py::test_group_block_unblock_members_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_moderation.py::test_group_block_unblock_members_success`
- 业务说明：群主封禁/解封成员：移除事件同步到接收账号全部在线端
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 加入群黑名单
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证加入群黑名单返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：A 移出群黑名单
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  6. 操作：验证移出群黑名单返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  7. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 26. `im_flutter_sdk/native-auto-test/tests/group/test_group_metadata.py::test_group_update_description`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_metadata.py::test_group_update_description`
- 业务说明：群主更新群描述：变更事件同步到群成员全部在线端
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证执行群组业务操作返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：A 查询本地群详情
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  6. 操作：验证查询本地群详情返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  7. 操作：A 查询服务端群详情
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  8. 操作：验证查询服务端群详情返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 27. `im_flutter_sdk/native-auto-test/tests/group/test_group_metadata.py::test_group_update_subject`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_metadata.py::test_group_update_subject`
- 业务说明：群主更新群名称：变更事件同步到群成员全部在线端
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 更新群名称
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证更新群名称返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：A 查询本地群详情
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  6. 操作：验证查询本地群详情返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  7. 操作：A 查询服务端群详情
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  8. 操作：验证查询服务端群详情返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 28. `im_flutter_sdk/native-auto-test/tests/group/test_group_moderation.py::test_group_mute_unmute_members_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_moderation.py::test_group_mute_unmute_members_success`
- 业务说明：群主禁言/解禁成员：禁言列表变更事件同步到接收账号全部在线端
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 禁言成员
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证 禁言成员返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：A 解除成员禁言
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  6. 操作：验证解除成员禁言返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  7. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。

### 29. `im_flutter_sdk/native-auto-test/tests/group/test_group_moderation.py::test_group_mute_all_unmute_all_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_moderation.py::test_group_mute_all_unmute_all_success`
- 业务说明：群主全员禁言/解禁：状态变更事件同步到接收账号全部在线端
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 全员禁言
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证 全员禁言返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：A 解除全员禁言
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  6. 操作：验证解除全员禁言返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  7. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。

### 30. `im_flutter_sdk/native-auto-test/tests/group/test_group_moderation.py::test_group_add_remove_white_list_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_moderation.py::test_group_add_remove_white_list_success`
- 业务说明：群主添加/移除白名单：白名单变更事件同步到接收账号全部在线端
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 加入群白名单
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证加入群白名单返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：A 移出群白名单
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  6. 操作：验证移出群白名单返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  7. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 31. `im_flutter_sdk/native-auto-test/tests/group/test_group_members.py::test_group_add_remove_members`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_members.py::test_group_add_remove_members`
- 业务说明：群主添加/移除成员：加入与移除事件同步到收发账号全部在线端
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 添加群成员
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证 添加群成员返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：接收账号副端 同步验证收到事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：发送账号副端 同步验证收到事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  7. 操作：A 查询服务端群详情
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  8. 操作：验证查询服务端群详情返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 32. `im_flutter_sdk/native-auto-test/tests/group/test_group_owner_removal_matrix.py::test_group_transfer_owner_target_boundaries[empty]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_owner_removal_matrix.py::test_group_transfer_owner_target_boundaries[empty]`
- 业务说明：转让给当前 owner 幂等成功；其他无效目标返回稳定错误且 owner 不变；接收账号全部在线端不触发 owner 变更事件
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 转让群主
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证转让群主返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：验证转让群主返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  5. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 33. `im_flutter_sdk/native-auto-test/tests/group/test_group_owner_removal_matrix.py::test_group_transfer_owner_target_boundaries[current-owner-idempotent]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_owner_removal_matrix.py::test_group_transfer_owner_target_boundaries[current-owner-idempotent]`
- 业务说明：转让给当前 owner 幂等成功；其他无效目标返回稳定错误且 owner 不变；接收账号全部在线端不触发 owner 变更事件
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 转让群主
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证转让群主返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：验证转让群主返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  5. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 34. `im_flutter_sdk/native-auto-test/tests/group/test_group_owner_removal_matrix.py::test_group_transfer_owner_target_boundaries[non-member]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_owner_removal_matrix.py::test_group_transfer_owner_target_boundaries[non-member]`
- 业务说明：转让给当前 owner 幂等成功；其他无效目标返回稳定错误且 owner 不变；接收账号全部在线端不触发 owner 变更事件
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 转让群主
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证转让群主返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：验证转让群主返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  5. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 35. `im_flutter_sdk/native-auto-test/tests/group/test_group_owner_removal_matrix.py::test_group_transfer_owner_target_boundaries[nonexistent]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_owner_removal_matrix.py::test_group_transfer_owner_target_boundaries[nonexistent]`
- 业务说明：转让给当前 owner 幂等成功；其他无效目标返回稳定错误且 owner 不变；接收账号全部在线端不触发 owner 变更事件
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 转让群主
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证转让群主返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：验证转让群主返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  5. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 36. `im_flutter_sdk/native-auto-test/tests/group/test_group_message_send.py::test_group_message_send_receive_combine`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_message_send.py::test_group_message_send_receive_combine`
- 业务说明：A 合并同群两条真实文本消息并发送，B 全部在线端收到关联同一群会话的合并消息
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 发送第 条源文本消息并记录 消息 ID
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：A 发送合并消息，并验证 B 全部在线端收到关联消息
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验关键字段：msgId、content。

### 37. `im_flutter_sdk/native-auto-test/tests/group/test_group_owner_removal_matrix.py::test_group_transfer_owner_to_admin_normalizes_roles`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_owner_removal_matrix.py::test_group_transfer_owner_to_admin_normalizes_roles`
- 业务说明：A 将群主转让给管理员 B：B 账号在线端收到 owner 变更事件；B 成 owner，A 成普通成员
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 添加群管理员
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证 添加群管理员返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：A 转让群主
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：验证转让群主返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  6. 操作：B 账号全部在线端收到 owner 变更事件（onGroupOwnerChanged）
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  7. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 38. `im_flutter_sdk/native-auto-test/tests/group/test_group_message_send.py::test_group_message_send_receive_by_type[video]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_message_send.py::test_group_message_send_receive_by_type[video]`
- 业务说明：A 向包含 B 的群发送指定类型消息：A 全部在线端同步、B 全部在线端接收
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 发送 类型群消息，并验证发送端与接收端链路
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 当前测试步骤的同步响应、异步事件和最终业务状态满足代码断言。
  2. 任一关键字段、回调、列表、数量或最终状态不符时，Case 判定失败。

### 39. `im_flutter_sdk/native-auto-test/tests/group/test_group_message_send.py::test_group_message_send_receive_by_type[image]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_message_send.py::test_group_message_send_receive_by_type[image]`
- 业务说明：A 向包含 B 的群发送指定类型消息：A 全部在线端同步、B 全部在线端接收
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 发送 类型群消息，并验证发送端与接收端链路
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 当前测试步骤的同步响应、异步事件和最终业务状态满足代码断言。
  2. 任一关键字段、回调、列表、数量或最终状态不符时，Case 判定失败。

### 40. `im_flutter_sdk/native-auto-test/tests/group/test_group_message_send.py::test_group_message_send_receive_by_type[location]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_message_send.py::test_group_message_send_receive_by_type[location]`
- 业务说明：A 向包含 B 的群发送指定类型消息：A 全部在线端同步、B 全部在线端接收
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 发送 类型群消息，并验证发送端与接收端链路
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 当前测试步骤的同步响应、异步事件和最终业务状态满足代码断言。
  2. 任一关键字段、回调、列表、数量或最终状态不符时，Case 判定失败。

### 41. `im_flutter_sdk/native-auto-test/tests/group/test_group_message_send.py::test_group_message_send_receive_by_type[file]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_message_send.py::test_group_message_send_receive_by_type[file]`
- 业务说明：A 向包含 B 的群发送指定类型消息：A 全部在线端同步、B 全部在线端接收
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 发送 类型群消息，并验证发送端与接收端链路
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 当前测试步骤的同步响应、异步事件和最终业务状态满足代码断言。
  2. 任一关键字段、回调、列表、数量或最终状态不符时，Case 判定失败。

### 42. `im_flutter_sdk/native-auto-test/tests/group/test_group_message_send.py::test_group_message_send_receive_by_type[voice]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_message_send.py::test_group_message_send_receive_by_type[voice]`
- 业务说明：A 向包含 B 的群发送指定类型消息：A 全部在线端同步、B 全部在线端接收
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 发送 类型群消息，并验证发送端与接收端链路
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 当前测试步骤的同步响应、异步事件和最终业务状态满足代码断言。
  2. 任一关键字段、回调、列表、数量或最终状态不符时，Case 判定失败。

### 43. `im_flutter_sdk/native-auto-test/tests/group/test_group_message_send.py::test_group_message_send_receive_by_type[custom]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_message_send.py::test_group_message_send_receive_by_type[custom]`
- 业务说明：A 向包含 B 的群发送指定类型消息：A 全部在线端同步、B 全部在线端接收
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 发送 类型群消息，并验证发送端与接收端链路
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 当前测试步骤的同步响应、异步事件和最终业务状态满足代码断言。
  2. 任一关键字段、回调、列表、数量或最终状态不符时，Case 判定失败。

### 44. `im_flutter_sdk/native-auto-test/tests/group/test_group_message_send.py::test_group_message_send_receive_by_type[cmd]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_message_send.py::test_group_message_send_receive_by_type[cmd]`
- 业务说明：A 向包含 B 的群发送指定类型消息：A 全部在线端同步、B 全部在线端接收
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 发送 类型群消息，并验证发送端与接收端链路
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 当前测试步骤的同步响应、异步事件和最终业务状态满足代码断言。
  2. 任一关键字段、回调、列表、数量或最终状态不符时，Case 判定失败。

### 45. `im_flutter_sdk/native-auto-test/tests/group/test_group_message_send.py::test_group_message_send_receive_by_type[txt]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_message_send.py::test_group_message_send_receive_by_type[txt]`
- 业务说明：A 向包含 B 的群发送指定类型消息：A 全部在线端同步、B 全部在线端接收
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 发送 类型群消息，并验证发送端与接收端链路
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 当前测试步骤的同步响应、异步事件和最终业务状态满足代码断言。
  2. 任一关键字段、回调、列表、数量或最终状态不符时，Case 判定失败。

### 46. `im_flutter_sdk/native-auto-test/tests/group/test_group_owner_removal_matrix.py::test_group_transfer_then_new_owner_removes_former_owner`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_owner_removal_matrix.py::test_group_transfer_then_new_owner_removes_former_owner`
- 业务说明：A 转让给 B 后 A 失去 owner 权限：B 收到 owner 变更事件，A 收到被移除事件
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 转让群主
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证转让群主返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：B 账号全部在线端消费 owner 变更事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：A 移除群成员
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  6. 操作：验证 移除群成员返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  7. 操作：B 移除群成员
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  8. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验异常返回：错误码 603，错误描述“permission”。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 校验关键字段：result。
  4. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 47. `im_flutter_sdk/native-auto-test/tests/group/test_group_message_send.py::test_group_message_fetch_acks_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_message_send.py::test_group_message_fetch_acks_success`
- 业务说明：B 创建群并邀请 A，A 发送群消息；验证 A 副端同步、B 全部在线端接收及群回执查询
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：清理参与设备的历史事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  2. 操作：创建群并邀请发送账号
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：清理建群及入群产生的历史事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  4. 操作：向群发送需要群回执的文本消息
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  5. 操作：验证发送群消息返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  6. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  7. 操作：等待 的消息发送成功回调（消息发送成功回调）
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  8. 操作：发送账号副端 收到群消息同步（消息接收回调）
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、from、to、convId、chatType、direction、status、hasRead、content、result、list、cursor。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 48. `im_flutter_sdk/native-auto-test/tests/group/test_group_moderation.py::test_group_block_members_non_member`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_moderation.py::test_group_block_members_non_member`
- 业务说明：测试准备：创建测试群并建立业务前置
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 加入群黑名单
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证加入群黑名单返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  4. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 603，错误描述“are not members of this group”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 49. `im_flutter_sdk/native-auto-test/tests/group/test_group_chat_thread_remaining_api_coverage.py::test_chat_thread_destroy_event_received_by_group_member`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_chat_thread_remaining_api_coverage.py::test_chat_thread_destroy_event_received_by_group_member`
- 业务说明：destroyChatThread：子区创建后由 owner 解散，收发账号全部在线端收到 onChatThreadDestroy 事件
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 解散子区
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证 解散子区返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：全部在线端验证收到子区事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 50. `im_flutter_sdk/native-auto-test/tests/group/test_group_chat_thread_remaining_api_coverage.py::test_chat_thread_fetch_members_and_latest_message`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_chat_thread_remaining_api_coverage.py::test_chat_thread_fetch_members_and_latest_message`
- 业务说明：fetchChatThreadMember / fetchLast消息WithChatThreads：成员列表包含 A/B，新建子区未发线程消息时最新消息映射为空
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 查询子区成员
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  3. 操作：验证查询子区成员返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：A 执行子区业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：验证执行子区业务操作返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result、list、cursor。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 51. `im_flutter_sdk/native-auto-test/tests/group/test_group_owner_removal_matrix.py::test_group_remove_current_owner_is_ignored`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_owner_removal_matrix.py::test_group_remove_current_owner_is_ignored`
- 业务说明：removeMembers 单独传当前群主返回成功但状态不变；接收账号全部在线端不触发移除事件
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 移除群成员
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  4. 操作：验证 移除群成员返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  5. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。

### 52. `im_flutter_sdk/native-auto-test/tests/group/test_group_chat_thread_remaining_api_coverage.py::test_chat_thread_update_name_and_leave`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_chat_thread_remaining_api_coverage.py::test_chat_thread_update_name_and_leave`
- 业务说明：updateChatThreadSubject / leaveChatThread：更新子区名称后，收发账号全部在线端收到事件，B 退出子区
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 执行子区业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证执行子区业务操作返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：全部在线端验证收到子区事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：A 查询子区详情
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  6. 操作：验证查询子区详情返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  7. 操作：B 退出子区
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  8. 操作：验证退出子区返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、result、list、cursor。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 53. `im_flutter_sdk/native-auto-test/tests/group/test_group_offline_invitation_application.py::test_group_offline_owner_receives_join_application_and_processes_after_login[accept]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_offline_invitation_application.py::test_group_offline_owner_receives_join_application_and_processes_after_login[accept]`
- 业务说明：审批群群主 A 先离线，B 申请后 A 重登接收申请并同意或拒绝
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：测试准备：切换账号设备在线状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  4. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：A 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  6. 操作：验证执行群组业务操作返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  7. 操作：测试后置：测试准备：切换账号设备在线状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  8. 操作：测试后置：销毁测试群并恢复环境
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  9. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。

### 54. `im_flutter_sdk/native-auto-test/tests/group/test_group_offline_invitation_application.py::test_group_offline_owner_receives_join_application_and_processes_after_login[decline]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_offline_invitation_application.py::test_group_offline_owner_receives_join_application_and_processes_after_login[decline]`
- 业务说明：审批群群主 A 先离线，B 申请后 A 重登接收申请并同意或拒绝
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：测试准备：切换账号设备在线状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  4. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：A 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  6. 操作：验证执行群组业务操作返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  7. 操作：测试后置：测试准备：切换账号设备在线状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  8. 操作：测试后置：销毁测试群并恢复环境
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  9. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。

### 55. `im_flutter_sdk/native-auto-test/tests/group/test_group_offline_roles_and_configuration.py::test_group_offline_member_attributes_final_state`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_offline_roles_and_configuration.py::test_group_offline_member_attributes_final_state`
- 业务说明：A 离线期间 B 修改自己的群成员属性；A 重登后按成员 ID 查询到同一属性
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：测试准备：切换账号设备在线状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：B 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  4. 操作：验证执行群组业务操作返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  5. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：动作端 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  7. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。

### 56. `im_flutter_sdk/native-auto-test/tests/group/test_group_offline_invitation_application.py::test_group_offline_owner_receives_invitation_result_after_relogin[accept]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_offline_invitation_application.py::test_group_offline_owner_receives_invitation_result_after_relogin[accept]`
- 业务说明：A 在 B 处理邀请时离线，A 重登收到接受或拒绝结果并核验成员状态
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  3. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  4. 操作：测试准备：切换账号设备在线状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：B 接受入群邀请
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  6. 操作：验证接受入群邀请返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  7. 操作：B 拒绝入群邀请
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  8. 操作：验证拒绝入群邀请返回的响应 result 与关键字段
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  9. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。

### 57. `im_flutter_sdk/native-auto-test/tests/group/test_group_offline_invitation_application.py::test_group_offline_owner_receives_invitation_result_after_relogin[decline]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_offline_invitation_application.py::test_group_offline_owner_receives_invitation_result_after_relogin[decline]`
- 业务说明：A 在 B 处理邀请时离线，A 重登收到接受或拒绝结果并核验成员状态
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  3. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  4. 操作：测试准备：切换账号设备在线状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：B 接受入群邀请
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  6. 操作：验证接受入群邀请返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  7. 操作：B 拒绝入群邀请
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  8. 操作：验证拒绝入群邀请返回的响应 result 与关键字段
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  9. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。

### 58. `im_flutter_sdk/native-auto-test/tests/group/test_group_offline_message_delivery.py::test_group_offline_multiple_text_messages_and_conversation_state`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_offline_message_delivery.py::test_group_offline_multiple_text_messages_and_conversation_state`
- 业务说明：B 离线积压三条群文本；重登验证完整集合、未读数 3 和最新消息
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：测试准备：切换账号设备在线状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：执行群消息动作并验证发送/接收链路
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：验证本用例的关键业务结果
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  5. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：动作端 执行本用例业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  7. 操作：验证执行本用例业务操作返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  8. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、convId、direction、status、content、result、list。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 59. `im_flutter_sdk/native-auto-test/tests/group/test_group_offline_roles_and_configuration.py::test_group_offline_announcement_final_state`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_offline_roles_and_configuration.py::test_group_offline_announcement_final_state`
- 业务说明：B 离线期间 A 更新公告；B 重登从公告查询 API 得到同一动态值
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：测试准备：切换账号设备在线状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：A 更新群公告
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：验证更新群公告返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  5. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：动作端 查询群公告
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  7. 操作：验证查询群公告返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  8. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。

### 60. `im_flutter_sdk/native-auto-test/tests/group/test_group_offline_member_state.py::test_group_offline_member_blocked_state_after_login`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_offline_member_state.py::test_group_offline_member_blocked_state_after_login`
- 业务说明：B 离线期间被加入群黑名单；重登后成员移除且服务端黑名单包含 B
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：测试准备：切换账号设备在线状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：A 加入群黑名单
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：验证加入群黑名单返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  5. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：B 加入公开群
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  7. 操作：验证加入公开群返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  8. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验异常返回：错误码 613，错误描述“blacklist”。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 校验关键字段：result。
  4. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 61. `im_flutter_sdk/native-auto-test/tests/group/test_group_offline_roles_and_configuration.py::test_group_offline_member_mute_unmute_final_state`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_offline_roles_and_configuration.py::test_group_offline_member_mute_unmute_final_state`
- 业务说明：B 离线期间被禁言/解除禁言；每次重登均从服务端名单验证最终状态
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：测试准备：切换账号设备在线状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：A 禁言成员
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  4. 操作：验证 禁言成员返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  5. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：A 解除成员禁言
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  7. 操作：验证解除成员禁言返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  8. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 62. `im_flutter_sdk/native-auto-test/tests/group/test_group_offline_roles_and_configuration.py::test_group_offline_admin_add_remove_final_state`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_offline_roles_and_configuration.py::test_group_offline_admin_add_remove_final_state`
- 业务说明：B 离线期间被设为/移出管理员；每次重登均验证本地角色和服务端 adminList
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：测试准备：切换账号设备在线状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：A 添加群管理员
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：验证 添加群管理员返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  6. 操作：A 移除群管理员
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  7. 操作：验证 移除群管理员返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  8. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。

### 63. `im_flutter_sdk/native-auto-test/tests/group/test_group_offline_member_state.py::test_group_offline_member_removed_state_after_login`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_offline_member_state.py::test_group_offline_member_removed_state_after_login`
- 业务说明：B 离线期间被移出；重登收到真实终态事件且本地/服务端均不再入群
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：测试准备：切换账号设备在线状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：A 移除群成员
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  4. 操作：验证 移除群成员返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  5. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。

### 64. `im_flutter_sdk/native-auto-test/tests/group/test_group_offline_roles_and_configuration.py::test_group_offline_metadata_final_state[avatarUrl]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_offline_roles_and_configuration.py::test_group_offline_metadata_final_state[avatarUrl]`
- 业务说明：B 离线期间更新名称/描述/头像/扩展；重登后按真实服务端字段验收
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：测试准备：切换账号设备在线状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：A 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  4. 操作：验证执行群组业务操作返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  5. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 65. `im_flutter_sdk/native-auto-test/tests/group/test_group_offline_roles_and_configuration.py::test_group_offline_metadata_final_state[desc]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_offline_roles_and_configuration.py::test_group_offline_metadata_final_state[desc]`
- 业务说明：B 离线期间更新名称/描述/头像/扩展；重登后按真实服务端字段验收
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：测试准备：切换账号设备在线状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：A 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  4. 操作：验证执行群组业务操作返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  5. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 66. `im_flutter_sdk/native-auto-test/tests/group/test_group_offline_roles_and_configuration.py::test_group_offline_metadata_final_state[ext]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_offline_roles_and_configuration.py::test_group_offline_metadata_final_state[ext]`
- 业务说明：B 离线期间更新名称/描述/头像/扩展；重登后按真实服务端字段验收
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：测试准备：切换账号设备在线状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：A 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  4. 操作：验证执行群组业务操作返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  5. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 67. `im_flutter_sdk/native-auto-test/tests/group/test_group_offline_roles_and_configuration.py::test_group_offline_metadata_final_state[name]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_offline_roles_and_configuration.py::test_group_offline_metadata_final_state[name]`
- 业务说明：B 离线期间更新名称/描述/头像/扩展；重登后按真实服务端字段验收
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：测试准备：切换账号设备在线状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：A 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  4. 操作：验证执行群组业务操作返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  5. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 68. `im_flutter_sdk/native-auto-test/tests/group/test_group_offline_roles_and_configuration.py::test_group_offline_allow_list_add_remove_final_state`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_offline_roles_and_configuration.py::test_group_offline_allow_list_add_remove_final_state`
- 业务说明：B 离线期间加入/移出白名单；每次重登均从服务端白名单验证
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：测试准备：切换账号设备在线状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：A 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  4. 操作：验证执行群组业务操作返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  5. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：动作端 查询白名单成员状态
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  7. 操作：验证查询白名单成员状态返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  8. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。

### 69. `im_flutter_sdk/native-auto-test/tests/group/test_group_offline_roles_and_configuration.py::test_group_offline_owner_transfer_final_state`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_offline_roles_and_configuration.py::test_group_offline_owner_transfer_final_state`
- 业务说明：B 离线期间接任群主；重登后本地和服务端 owner/permissionType 均为新群主
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：测试准备：切换账号设备在线状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：A 转让群主
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  4. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：验证转让群主返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  6. 操作：B 转让群主
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  7. 操作：测试后置：测试准备：切换账号设备在线状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  8. 操作：测试后置：销毁测试群并恢复环境
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  9. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。

### 70. `im_flutter_sdk/native-auto-test/tests/group/test_group_offline_roles_and_configuration.py::test_group_offline_mute_all_unmute_all_final_state`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_offline_roles_and_configuration.py::test_group_offline_mute_all_unmute_all_final_state`
- 业务说明：B 离线期间全员禁言/解除；每次重登均查询 isAllMemberMuted
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：测试准备：切换账号设备在线状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：A 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  4. 操作：验证执行群组业务操作返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  5. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。

### 71. `im_flutter_sdk/native-auto-test/tests/group/test_group_offline_member_state.py::test_group_offline_group_destroyed_state_after_login`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_offline_member_state.py::test_group_offline_group_destroyed_state_after_login`
- 业务说明：B 离线期间群被解散；重登收到解散事件且本地/服务端 joined 投影为空
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：测试准备：切换账号设备在线状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：A 销毁测试群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  4. 操作：验证销毁测试群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  5. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。

### 72. `im_flutter_sdk/native-auto-test/tests/group/test_group_offline_roles_and_configuration.py::test_group_offline_shared_file_upload_delete_final_state`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_offline_roles_and_configuration.py::test_group_offline_shared_file_upload_delete_final_state`
- 业务说明：B 离线期间上传/删除共享文件；每次重登均从服务端文件列表验证终态
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：测试准备：切换账号设备在线状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：A 上传群共享文件
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  4. 操作：验证 上传群共享文件返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  5. 操作：A 查询群共享文件列表
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  6. 操作：验证查询群共享文件列表返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  7. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  8. 操作：动作端 查询群共享文件列表
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  9. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result、list。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 73. `im_flutter_sdk/native-auto-test/tests/group/test_group_offline_message_delivery.py::test_group_offline_text_message_received_after_login`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_offline_message_delivery.py::test_group_offline_text_message_received_after_login`
- 业务说明：B 离线时 A 发群文本；B 重登收到同一真实 消息 ID 和群会话正文
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：测试准备：切换账号设备在线状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：执行群消息动作并验证发送/接收链路
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：等待并关联目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、content。

### 74. `im_flutter_sdk/native-auto-test/tests/group/test_group_offline_message_delivery.py::test_group_offline_cmd_deliver_online_only_not_received_after_login`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_offline_message_delivery.py::test_group_offline_cmd_deliver_online_only_not_received_after_login`
- 业务说明：B 离线时群 CMD 设置 deliver在线Only=true；重登无旧事件且本地无消息
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：测试准备：切换账号设备在线状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：A 发送群消息
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：验证发送群消息返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  5. 操作：等待并关联目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：等待本地撤回消息删除完成
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  7. 操作：验证执行群消息操作返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  8. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、from、to、convId、chatType、direction、status、hasRead、hasDeliverAck、result、list。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 75. `im_flutter_sdk/native-auto-test/tests/group/test_group_offline_invitation_application.py::test_group_offline_applicant_receives_application_result_after_relogin[accept]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_offline_invitation_application.py::test_group_offline_applicant_receives_application_result_after_relogin[accept]`
- 业务说明：B 申请审批群后离线，A 处理；B 重登收到审批结果并验证最终状态
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  3. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  4. 操作：测试准备：切换账号设备在线状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：A 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  6. 操作：验证执行群组业务操作返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  7. 操作：测试后置：测试准备：切换账号设备在线状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  8. 操作：测试后置：销毁测试群并恢复环境
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  9. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。

### 76. `im_flutter_sdk/native-auto-test/tests/group/test_group_offline_invitation_application.py::test_group_offline_applicant_receives_application_result_after_relogin[decline]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_offline_invitation_application.py::test_group_offline_applicant_receives_application_result_after_relogin[decline]`
- 业务说明：B 申请审批群后离线，A 处理；B 重登收到审批结果并验证最终状态
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  3. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  4. 操作：测试准备：切换账号设备在线状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：A 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  6. 操作：验证执行群组业务操作返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  7. 操作：测试后置：测试准备：切换账号设备在线状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  8. 操作：测试后置：销毁测试群并恢复环境
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  9. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。

### 77. `im_flutter_sdk/native-auto-test/tests/group/test_group_offline_message_delivery.py::test_group_offline_sender_reads_ack_count_after_relogin`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_offline_message_delivery.py::test_group_offline_sender_reads_ack_count_after_relogin`
- 业务说明：B 收到群消息后在 A 离线期间发送 已读回执；A 重登最终查询 count=1
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 发送群消息
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证发送群消息返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：等待并关联目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：测试准备：切换账号设备在线状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  7. 操作：B 发送群已读回执
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  8. 操作：验证发送群已读回执返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  9. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、from、to、chatType、direction、status、content、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 78. `im_flutter_sdk/native-auto-test/tests/group/test_group_offline_message_delivery.py::test_group_offline_message_recalled_before_first_recipient_login`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_offline_message_delivery.py::test_group_offline_message_recalled_before_first_recipient_login`
- 业务说明：B 首次接收前 A 撤回群文本；B 重登验证撤回回放和本地最终删除
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：测试准备：切换账号设备在线状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：执行群消息动作并验证发送/接收链路
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：A 执行群消息操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：验证执行群消息操作返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  6. 操作：等待并关联目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  7. 操作：等待本地撤回消息删除完成
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  8. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、convId、content、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 79. `im_flutter_sdk/native-auto-test/tests/group/test_group_offline_invitation_application.py::test_group_offline_invitation_received_and_processed_after_login[accept]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_offline_invitation_application.py::test_group_offline_invitation_received_and_processed_after_login[accept]`
- 业务说明：B 先离线，重登收到群邀请并接受或拒绝，验证权限和最终成员状态
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：切换账号设备在线状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  4. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：B 接受入群邀请
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  6. 操作：验证接受入群邀请返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  7. 操作：B 拒绝入群邀请
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  8. 操作：验证拒绝入群邀请返回的响应 result 与关键字段
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  9. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。

### 80. `im_flutter_sdk/native-auto-test/tests/group/test_group_offline_invitation_application.py::test_group_offline_invitation_received_and_processed_after_login[decline]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_offline_invitation_application.py::test_group_offline_invitation_received_and_processed_after_login[decline]`
- 业务说明：B 先离线，重登收到群邀请并接受或拒绝，验证权限和最终成员状态
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：切换账号设备在线状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  4. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：B 接受入群邀请
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  6. 操作：验证接受入群邀请返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  7. 操作：B 拒绝入群邀请
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  8. 操作：验证拒绝入群邀请返回的响应 result 与关键字段
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  9. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。

### 81. `im_flutter_sdk/native-auto-test/tests/group/test_group_offline_message_delivery.py::test_group_offline_recipient_receives_recall_after_relogin`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_offline_message_delivery.py::test_group_offline_recipient_receives_recall_after_relogin`
- 业务说明：B 已收群文本后离线，A 撤回；B 重登验证撤回事件和本地最终删除
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：执行群消息动作并验证发送/接收链路
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：等待并关联目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  4. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：测试准备：切换账号设备在线状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  6. 操作：A 执行群消息操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  7. 操作：验证执行群消息操作返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  8. 操作：动作端 执行群消息操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  9. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、convId、direction、status、content、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 82. `im_flutter_sdk/native-auto-test/tests/group/test_group_offline_message_delivery.py::test_group_offline_recipient_receives_content_change_after_relogin`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_offline_message_delivery.py::test_group_offline_recipient_receives_content_change_after_relogin`
- 业务说明：B 已收群文本后离线，A 修改正文；B 重登验证修改事件和本地最终正文
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：执行群消息动作并验证发送/接收链路
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：等待并关联目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  4. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：测试准备：切换账号设备在线状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  6. 操作：A 执行群消息操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  7. 操作：验证执行群消息操作返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  8. 操作：动作端 执行群消息操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  9. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、direction、status、content、result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 83. `im_flutter_sdk/native-auto-test/tests/group/test_group_offline_member_state.py::test_group_offline_member_leave_state_persists_after_relogin`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_offline_member_state.py::test_group_offline_member_leave_state_persists_after_relogin`
- 业务说明：B 主动退群后 logout/login；成员数、joined groups 和本地群对象保持退出终态
- 类型：离线
- 多设备校验：是。当前 5.0 默认拓扑按账号全部设备执行，重新登录后逐台校验相关消息、事件或本地状态。
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 当前 5.0 默认拓扑中 A、B 两个账号各有两台设备；离线阶段按账号全部设备下线，重新登录后逐台校验。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：B 退出群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证退出群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：测试准备：切换账号设备在线状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：目标账号的全部设备重新登录后，分别校验每台设备的消息、事件或本地状态。
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。

### 84. `im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_request_to_join_permission_by_style[private-member]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_request_to_join_permission_by_style[private-member]`
- 业务说明：5.0 入群申请/自动入群：私有群拒绝，PublicOpenJoin(style=3) 自动入群
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：B 申请加入公开群
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  4. 操作：验证申请加入公开群返回的响应 result 与关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  5. 操作：验证申请加入公开群返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  6. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 603，错误描述“permission”。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 校验关键字段：result。
  4. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 85. `im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_request_to_join_permission_by_style[private-owner]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_request_to_join_permission_by_style[private-owner]`
- 业务说明：5.0 入群申请/自动入群：私有群拒绝，PublicOpenJoin(style=3) 自动入群
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：B 申请加入公开群
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  4. 操作：验证申请加入公开群返回的响应 result 与关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  5. 操作：验证申请加入公开群返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  6. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 603，错误描述“permission”。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 校验关键字段：result。
  4. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 86. `im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_request_to_join_permission_by_style[public-open]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_request_to_join_permission_by_style[public-open]`
- 业务说明：5.0 入群申请/自动入群：私有群拒绝，PublicOpenJoin(style=3) 自动入群
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：B 申请加入公开群
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  4. 操作：验证申请加入公开群返回的响应 result 与关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  5. 操作：验证申请加入公开群返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  6. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 603，错误描述“permission”。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 校验关键字段：result。
  4. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 87. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_empty_name`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_empty_name`
- 业务说明：A 创建群
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 创建群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证创建群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  3. 操作：A 销毁测试群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  4. 操作：验证销毁测试群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 88. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_text_fields_additional_inputs[desc_multiline-desc-line1\nline2\nline3-None]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_text_fields_additional_inputs[desc_multiline-desc-line1\nline2\nline3-None]`
- 业务说明：A 创建群
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 创建群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证创建群返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  3. 操作：验证创建群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：A 销毁测试群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：验证销毁测试群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 89. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_text_fields_additional_inputs[desc_space_only-desc- -None]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_text_fields_additional_inputs[desc_space_only-desc- -None]`
- 业务说明：A 创建群
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 创建群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证创建群返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  3. 操作：验证创建群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：A 销毁测试群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：验证销毁测试群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 90. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_text_fields_additional_inputs[desc_symbols-desc-desc_!@#$%^&*()[]{}<>?/\\|-None]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_text_fields_additional_inputs[desc_symbols-desc-desc_!@#$%^&*()[]{}<>?/\\|-None]`
- 业务说明：A 创建群
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 创建群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证创建群返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  3. 操作：验证创建群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：A 销毁测试群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：验证销毁测试群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 91. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_text_fields_additional_inputs[group_name_mixed_symbols-groupName-group-name_!@#$%^&*()[]{}-None]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_text_fields_additional_inputs[group_name_mixed_symbols-groupName-group-name_!@#$%^&*()[]{}-None]`
- 业务说明：A 创建群
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 创建群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证创建群返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  3. 操作：验证创建群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：A 销毁测试群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：验证销毁测试群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 92. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_text_fields_additional_inputs[group_name_tabs-groupName-\tgroup\tname\t-None]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_text_fields_additional_inputs[group_name_tabs-groupName-\tgroup\tname\t-None]`
- 业务说明：A 创建群
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 创建群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证创建群返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  3. 操作：验证创建群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：A 销毁测试群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：验证销毁测试群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 93. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_text_fields_additional_inputs[invite_reason_multiline-inviteReason-reason line1\nreason line2-None]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_text_fields_additional_inputs[invite_reason_multiline-inviteReason-reason line1\nreason line2-None]`
- 业务说明：A 创建群
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 创建群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证创建群返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  3. 操作：验证创建群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：A 销毁测试群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：验证销毁测试群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 94. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_text_fields_additional_inputs[invite_reason_space_only-inviteReason- -None]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_text_fields_additional_inputs[invite_reason_space_only-inviteReason- -None]`
- 业务说明：A 创建群
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 创建群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证创建群返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  3. 操作：验证创建群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：A 销毁测试群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：验证销毁测试群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 95. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_text_fields_additional_inputs[invite_reason_symbols-inviteReason-reason_!@#$%^&*()[]{}<>?/\\|-None]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_text_fields_additional_inputs[invite_reason_symbols-inviteReason-reason_!@#$%^&*()[]{}<>?/\\|-None]`
- 业务说明：A 创建群
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 创建群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证创建群返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  3. 操作：验证创建群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：A 销毁测试群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：验证销毁测试群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 96. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_desc_reason_options_abnormal_inputs[options_ext_too_long_1025-overrides2-None]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_desc_reason_options_abnormal_inputs[options_ext_too_long_1025-overrides2-None]`
- 业务说明：A 创建群
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 创建群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证创建群返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  3. 操作：验证创建群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：A 销毁测试群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：验证销毁测试群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 97. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_desc_reason_options_abnormal_inputs[options_max_count_zero-overrides3-expect_error3]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_desc_reason_options_abnormal_inputs[options_max_count_zero-overrides3-expect_error3]`
- 业务说明：A 创建群
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 创建群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证创建群返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  3. 操作：验证创建群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：A 销毁测试群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：验证销毁测试群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 98. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_desc_reason_options_abnormal_inputs[options_max_count_negative-overrides4-expect_error4]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_desc_reason_options_abnormal_inputs[options_max_count_negative-overrides4-expect_error4]`
- 业务说明：A 创建群
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 创建群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证创建群返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  3. 操作：验证创建群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：A 销毁测试群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：验证销毁测试群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 99. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_desc_reason_options_abnormal_inputs[options_style_out_of_range-overrides5-None]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_desc_reason_options_abnormal_inputs[options_style_out_of_range-overrides5-None]`
- 业务说明：A 创建群
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 创建群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证创建群返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  3. 操作：验证创建群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：A 销毁测试群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：验证销毁测试群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 100. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_desc_reason_options_abnormal_inputs[desc_too_long_513-overrides0-None]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_desc_reason_options_abnormal_inputs[desc_too_long_513-overrides0-None]`
- 业务说明：A 创建群
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 创建群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证创建群返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  3. 操作：验证创建群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：A 销毁测试群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：验证销毁测试群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 101. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_desc_reason_options_abnormal_inputs[invite_reason_too_long_1025-overrides1-None]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_desc_reason_options_abnormal_inputs[invite_reason_too_long_1025-overrides1-None]`
- 业务说明：A 创建群
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 创建群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证创建群返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  3. 操作：验证创建群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：A 销毁测试群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：验证销毁测试群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 102. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_invite_members_abnormal_inputs[invite_members_duplicate_user-invite_members0-None]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_invite_members_abnormal_inputs[invite_members_duplicate_user-invite_members0-None]`
- 业务说明：A 创建群
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 创建群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证创建群返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  3. 操作：验证创建群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：A 销毁测试群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：验证销毁测试群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 103. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_invite_members_abnormal_inputs[invite_members_contains_nonexistent_user-invite_members1-expect_error1]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_invite_members_abnormal_inputs[invite_members_contains_nonexistent_user-invite_members1-expect_error1]`
- 业务说明：A 创建群
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 创建群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证创建群返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  3. 操作：验证创建群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：A 销毁测试群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：验证销毁测试群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 104. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_max_count_less_than_invite_members`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_max_count_less_than_invite_members`
- 业务说明：A 创建群
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 创建群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证创建群返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 604，错误描述“The group member capacity is reached”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 105. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_name_and_avatar_abnormal_inputs[avatar_url_ftp_protocol-overrides5-None]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_name_and_avatar_abnormal_inputs[avatar_url_ftp_protocol-overrides5-None]`
- 业务说明：A 创建群
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 创建群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证创建群返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  3. 操作：验证创建群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：A 销毁测试群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：验证销毁测试群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 106. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_name_and_avatar_abnormal_inputs[avatar_url_not_url-overrides4-None]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_name_and_avatar_abnormal_inputs[avatar_url_not_url-overrides4-None]`
- 业务说明：A 创建群
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 创建群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证创建群返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  3. 操作：验证创建群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：A 销毁测试群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：验证销毁测试群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 107. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_name_and_avatar_abnormal_inputs[avatar_url_too_long-overrides6-expect_error6]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_name_and_avatar_abnormal_inputs[avatar_url_too_long-overrides6-expect_error6]`
- 业务说明：A 创建群
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 创建群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证创建群返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  3. 操作：验证创建群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：A 销毁测试群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：验证销毁测试群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 108. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_name_and_avatar_abnormal_inputs[group_name_control_chars-overrides3-None]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_name_and_avatar_abnormal_inputs[group_name_control_chars-overrides3-None]`
- 业务说明：A 创建群
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 创建群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证创建群返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  3. 操作：验证创建群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：A 销毁测试群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：验证销毁测试群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 109. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_name_and_avatar_abnormal_inputs[group_name_space_only-overrides0-None]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_name_and_avatar_abnormal_inputs[group_name_space_only-overrides0-None]`
- 业务说明：A 创建群
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 创建群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证创建群返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  3. 操作：验证创建群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：A 销毁测试群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：验证销毁测试群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 110. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_name_and_avatar_abnormal_inputs[group_name_too_long_256-overrides1-None]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_name_and_avatar_abnormal_inputs[group_name_too_long_256-overrides1-None]`
- 业务说明：A 创建群
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 创建群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证创建群返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  3. 操作：验证创建群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：A 销毁测试群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：验证销毁测试群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 111. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_name_and_avatar_abnormal_inputs[group_name_too_long_512-overrides2-None]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_name_and_avatar_abnormal_inputs[group_name_too_long_512-overrides2-None]`
- 业务说明：A 创建群
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 创建群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证创建群返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  3. 操作：验证创建群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：A 销毁测试群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：验证销毁测试群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 112. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_optional_fields_empty[options_ext_empty-overrides4]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_optional_fields_empty[options_ext_empty-overrides4]`
- 业务说明：A 创建群
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 创建群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证创建群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  3. 操作：A 销毁测试群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  4. 操作：验证销毁测试群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 113. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_optional_fields_empty[avatar_url_empty-overrides0]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_optional_fields_empty[avatar_url_empty-overrides0]`
- 业务说明：A 创建群
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 创建群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证创建群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  3. 操作：A 销毁测试群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  4. 操作：验证销毁测试群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 114. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_optional_fields_empty[desc_empty-overrides1]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_optional_fields_empty[desc_empty-overrides1]`
- 业务说明：A 创建群
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 创建群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证创建群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  3. 操作：A 销毁测试群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  4. 操作：验证销毁测试群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 115. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_optional_fields_empty[invite_members_empty-overrides2]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_optional_fields_empty[invite_members_empty-overrides2]`
- 业务说明：A 创建群
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 创建群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证创建群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  3. 操作：A 销毁测试群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  4. 操作：验证销毁测试群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 116. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_optional_fields_empty[invite_reason_empty-overrides3]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_optional_fields_empty[invite_reason_empty-overrides3]`
- 业务说明：A 创建群
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 创建群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证创建群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  3. 操作：A 销毁测试群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  4. 操作：验证销毁测试群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 117. `im_flutter_sdk/native-auto-test/tests/group/test_group_invitation_state_matrix.py::test_group_invitation_wrong_inviter_does_not_consume_pending[accept]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_invitation_state_matrix.py::test_group_invitation_wrong_inviter_does_not_consume_pending[accept]`
- 业务说明：错误 inviter 处理邀请应失败，随后正确 inviter 仍可接受同一 pending
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：B 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：B 接受入群邀请
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  4. 操作：验证接受入群邀请返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  5. 操作：验证接受入群邀请返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  6. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  7. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 601、603，错误描述“already joined；is not in the invitee list”。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 校验关键字段：result、list。
  4. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 118. `im_flutter_sdk/native-auto-test/tests/group/test_group_invitation_state_matrix.py::test_group_invitation_wrong_inviter_does_not_consume_pending[decline]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_invitation_state_matrix.py::test_group_invitation_wrong_inviter_does_not_consume_pending[decline]`
- 业务说明：错误 inviter 处理邀请应失败，随后正确 inviter 仍可接受同一 pending
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：B 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：B 接受入群邀请
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  4. 操作：验证接受入群邀请返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  5. 操作：验证接受入群邀请返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  6. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  7. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 601、603，错误描述“already joined；is not in the invitee list”。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 校验关键字段：result、list。
  4. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 119. `im_flutter_sdk/native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_message_block_role_matrix[member]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_message_block_role_matrix[member]`
- 业务说明：冻结三种群角色屏蔽/取消屏蔽群消息的真实 SDK 行为
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：动作端 屏蔽群消息
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  4. 操作：动作端 取消屏蔽群消息
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。

### 120. `im_flutter_sdk/native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_message_block_role_matrix[admin]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_message_block_role_matrix[admin]`
- 业务说明：冻结三种群角色屏蔽/取消屏蔽群消息的真实 SDK 行为
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：动作端 屏蔽群消息
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  4. 操作：动作端 取消屏蔽群消息
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。

### 121. `im_flutter_sdk/native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_message_block_role_matrix[owner]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_message_block_role_matrix[owner]`
- 业务说明：冻结三种群角色屏蔽/取消屏蔽群消息的真实 SDK 行为
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：动作端 屏蔽群消息
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  4. 操作：动作端 取消屏蔽群消息
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。

### 122. `im_flutter_sdk/native-auto-test/tests/group/test_group_capacity.py::test_group_options_use_active_capacity_unless_boundary_value_is_explicit`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_capacity.py::test_group_options_use_active_capacity_unless_boundary_value_is_explicit`
- 业务说明：防止 3000 场景漏传给建群请求，或覆盖 maxCount=2 的容量边界用例
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 测试账号已创建并登录，当前 Case 所需的基础数据已准备。
  3. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：验证本用例的关键业务结果
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：from。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 123. `im_flutter_sdk/native-auto-test/tests/group/test_group_capacity.py::test_group_capacity_rejects_non_positive_values[-1]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_capacity.py::test_group_capacity_rejects_non_positive_values[-1]`
- 业务说明：防止错误的运行参数创建无效容量群并污染真实测试环境
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 测试账号已创建并登录，当前 Case 所需的基础数据已准备。
  3. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：验证非法容量 被拒绝并返回 ValueError
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 当前测试步骤的同步响应、异步事件和最终业务状态满足代码断言。
  2. 任一关键字段、回调、列表、数量或最终状态不符时，Case 判定失败。

### 124. `im_flutter_sdk/native-auto-test/tests/group/test_group_capacity.py::test_group_capacity_rejects_non_positive_values[0]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_capacity.py::test_group_capacity_rejects_non_positive_values[0]`
- 业务说明：防止错误的运行参数创建无效容量群并污染真实测试环境
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 测试账号已创建并登录，当前 Case 所需的基础数据已准备。
  3. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：验证非法容量 被拒绝并返回 ValueError
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 当前测试步骤的同步响应、异步事件和最终业务状态满足代码断言。
  2. 任一关键字段、回调、列表、数量或最终状态不符时，Case 判定失败。

### 125. `im_flutter_sdk/native-auto-test/tests/group/test_group_capacity.py::test_group_capacity_defaults_to_200_and_accepts_3000_override`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_capacity.py::test_group_capacity_defaults_to_200_and_accepts_3000_override`
- 业务说明：防止默认群容量漂移，或扩容场景没有将常规建群容量切换为 3000
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 测试账号已创建并登录，当前 Case 所需的基础数据已准备。
  3. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：验证本用例的关键业务结果
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 126. `im_flutter_sdk/native-auto-test/tests/group/test_group_capacity.py::test_group_snapshot_default_uses_active_capacity`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_capacity.py::test_group_snapshot_default_uses_active_capacity`
- 业务说明：防止未传 max_user_count_value 的群快照断言在 3000 场景退回 200
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 测试账号已创建并登录，当前 Case 所需的基础数据已准备。
  3. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：验证本用例的关键业务结果
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：from、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 127. `im_flutter_sdk/native-auto-test/tests/group/test_group_join_application_state_matrix.py::test_group_non_member_cannot_process_join_application[accept]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_join_application_state_matrix.py::test_group_non_member_cannot_process_join_application[accept]`
- 业务说明：非成员不能处理其他用户的有效 pending 申请
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证执行群组业务操作返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  4. 操作：验证执行群组业务操作返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  5. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 602，错误描述“has not joined the group”。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 128. `im_flutter_sdk/native-auto-test/tests/group/test_group_join_application_state_matrix.py::test_group_non_member_cannot_process_join_application[decline]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_join_application_state_matrix.py::test_group_non_member_cannot_process_join_application[decline]`
- 业务说明：非成员不能处理其他用户的有效 pending 申请
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证执行群组业务操作返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  4. 操作：验证执行群组业务操作返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  5. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 602，错误描述“has not joined the group”。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 129. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_server_state_lists.py::test_group_server_state_list_nonexistent_group[getGroupBlockListFromServer]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_server_state_lists.py::test_group_server_state_list_nonexistent_group[getGroupBlockListFromServer]`
- 业务说明：A 执行群组业务操作
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证执行群组业务操作返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 600，错误描述“do not find this group”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 130. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_server_state_lists.py::test_group_server_state_list_nonexistent_group[getGroupMuteListFromServer]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_server_state_lists.py::test_group_server_state_list_nonexistent_group[getGroupMuteListFromServer]`
- 业务说明：A 执行群组业务操作
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证执行群组业务操作返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 600，错误描述“do not find this group”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 131. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_server_state_lists.py::test_group_server_state_list_nonexistent_group[getGroupWhiteListFromServer]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_server_state_lists.py::test_group_server_state_list_nonexistent_group[getGroupWhiteListFromServer]`
- 业务说明：A 执行群组业务操作
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证执行群组业务操作返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 600，错误描述“do not find this group”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 132. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_server_state_lists.py::test_group_server_state_list_nonexistent_group[isMemberInWhiteListFromServer]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_server_state_lists.py::test_group_server_state_list_nonexistent_group[isMemberInWhiteListFromServer]`
- 业务说明：A 执行群组业务操作
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证执行群组业务操作返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 600，错误描述“do not find this group”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 133. `im_flutter_sdk/native-auto-test/tests/group/test_group.py::test_group_member_count_local_then_server_sync`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group.py::test_group_member_count_local_then_server_sync`
- 业务说明：复现流程： 1) 邀请别人入群（addMembers） 2) getGroupWithId（本地）读取人数 3) getGroupSpecificationFromServer（服务端）读取人数 4) 再次 getGroupWithId（本地）读取人数，验证与服务端一致 说明： - 若本地人数与服务端人数不一致，则判定“复现到问题”； - 若未出现不一致，则该环境下未复现，使用 skip 标记
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 添加群成员
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证 添加群成员返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：A 查询本地群详情
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  5. 操作：验证查询本地群详情返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  6. 操作：A 查询服务端群详情
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  7. 操作：验证查询服务端群详情返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  8. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 134. `im_flutter_sdk/native-auto-test/tests/group/test_group_member_info.py::test_group_fetch_members_info_contains_updated_own_profile`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_member_info.py::test_group_fetch_members_info_contains_updated_own_profile`
- 业务说明：更新本人昵称/头像后，fetchGroupMembersInfo 返回的本人 EMGroupMemberInfo 字段保持一致
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 查询用户资料
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  2. 操作：验证查询用户资料返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  3. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  4. 操作：A 查询群成员信息
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  5. 操作：验证查询群成员信息返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  6. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  7. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result、cursor。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 135. `im_flutter_sdk/native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_destroy_owner_only_role_denied[member]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_destroy_owner_only_role_denied[member]`
- 业务说明：管理员和普通成员不能解散群，失败后群仍可由群主查询和清理
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：B 销毁测试群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证销毁测试群返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  4. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 603。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 136. `im_flutter_sdk/native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_destroy_owner_only_role_denied[admin]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_destroy_owner_only_role_denied[admin]`
- 业务说明：管理员和普通成员不能解散群，失败后群仍可由群主查询和清理
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：B 销毁测试群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证销毁测试群返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  4. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 603。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 137. `im_flutter_sdk/native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_metadata_admin_member_role_matrix[member]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_metadata_admin_member_role_matrix[member]`
- 业务说明：管理员可修改群名称、描述、扩展；普通成员返回群字段权限错误
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：B 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证执行群组业务操作返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  4. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：验证执行群组业务操作返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  6. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  7. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 603。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 校验关键字段：result。
  4. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 138. `im_flutter_sdk/native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_metadata_admin_member_role_matrix[admin]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_metadata_admin_member_role_matrix[admin]`
- 业务说明：管理员可修改群名称、描述、扩展；普通成员返回群字段权限错误
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：B 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证执行群组业务操作返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  4. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：验证执行群组业务操作返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  6. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  7. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 603。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 校验关键字段：result。
  4. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 139. `im_flutter_sdk/native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_blocklist_admin_member_role_matrix[member]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_blocklist_admin_member_role_matrix[member]`
- 业务说明：管理员可增删群黑名单；普通成员返回管理员权限错误且状态不变
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：将目标成员加入群黑名单
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证移出群黑名单返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  4. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：将目标成员移出群黑名单
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  7. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 603。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 校验关键字段：result。
  4. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 140. `im_flutter_sdk/native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_blocklist_admin_member_role_matrix[admin]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_blocklist_admin_member_role_matrix[admin]`
- 业务说明：管理员可增删群黑名单；普通成员返回管理员权限错误且状态不变
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：将目标成员加入群黑名单
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证移出群黑名单返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  4. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：将目标成员移出群黑名单
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  7. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 603。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 校验关键字段：result。
  4. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 141. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_member_attributes.py::test_group_fetch_member_attributes_nonexistent_group`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_member_attributes.py::test_group_fetch_member_attributes_nonexistent_group`
- 业务说明：A 执行群组业务操作
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证执行群组业务操作返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 142. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_member_attributes.py::test_group_fetch_members_attributes_nonexistent_group`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_member_attributes.py::test_group_fetch_members_attributes_nonexistent_group`
- 业务说明：A 执行群组业务操作
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证执行群组业务操作返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 143. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_announcement.py::test_group_get_announcement_nonexistent_group`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_announcement.py::test_group_get_announcement_nonexistent_group`
- 业务说明：A 查询群公告
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 查询群公告
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  2. 操作：验证查询群公告返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 600，错误描述“do not find this group”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 144. `im_flutter_sdk/native-auto-test/tests/group/test_group_member_list.py::test_group_get_group_member_list_from_server_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_member_list.py::test_group_get_group_member_list_from_server_success`
- 业务说明：测试准备：创建测试群并建立业务前置
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 查询服务端成员列表
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  3. 操作：验证查询服务端成员列表返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 145. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_member_list.py::test_group_get_group_member_list_from_server_invalid_paging[-1-20]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_member_list.py::test_group_get_group_member_list_from_server_invalid_paging[-1-20]`
- 业务说明：A 查询服务端成员列表
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 查询服务端成员列表
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  2. 操作：验证查询服务端成员列表返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  3. 操作：验证查询服务端成员列表返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 146. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_member_list.py::test_group_get_group_member_list_from_server_invalid_paging[0-20]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_member_list.py::test_group_get_group_member_list_from_server_invalid_paging[0-20]`
- 业务说明：A 查询服务端成员列表
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 查询服务端成员列表
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  2. 操作：验证查询服务端成员列表返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  3. 操作：验证查询服务端成员列表返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 147. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_member_list.py::test_group_get_group_member_list_from_server_invalid_paging[1--1]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_member_list.py::test_group_get_group_member_list_from_server_invalid_paging[1--1]`
- 业务说明：A 查询服务端成员列表
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 查询服务端成员列表
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  2. 操作：验证查询服务端成员列表返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  3. 操作：验证查询服务端成员列表返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 148. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_member_list.py::test_group_get_group_member_list_from_server_invalid_paging[1-0]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_member_list.py::test_group_get_group_member_list_from_server_invalid_paging[1-0]`
- 业务说明：A 查询服务端成员列表
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 查询服务端成员列表
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  2. 操作：验证查询服务端成员列表返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  3. 操作：验证查询服务端成员列表返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 149. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_member_list.py::test_group_get_group_member_list_from_server_nonexistent_group`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_member_list.py::test_group_get_group_member_list_from_server_nonexistent_group`
- 业务说明：A 查询服务端成员列表
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 查询服务端成员列表
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  2. 操作：验证查询服务端成员列表返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 600，错误描述“do not find this group”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 150. `im_flutter_sdk/native-auto-test/tests/group/test_group_lifecycle.py::test_group_get_group_from_server`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_lifecycle.py::test_group_get_group_from_server`
- 业务说明：测试准备：创建测试群并建立业务前置
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 查询服务端群详情
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  3. 操作：验证查询服务端群详情返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 当前测试步骤的同步响应、异步事件和最终业务状态满足代码断言。
  2. 任一关键字段、回调、列表、数量或最终状态不符时，Case 判定失败。

### 151. `im_flutter_sdk/native-auto-test/tests/group/test_group_lifecycle.py::test_group_get_group_from_server_after_destroy`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_lifecycle.py::test_group_get_group_from_server_after_destroy`
- 业务说明：测试准备：创建测试群并建立业务前置
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：A 查询服务端群详情
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：验证查询服务端群详情返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 600，错误描述“do not find this group”。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 152. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_get_group_from_server_nonexistent`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_get_group_from_server_nonexistent`
- 业务说明：A 查询服务端群详情
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 查询服务端群详情
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  2. 操作：验证查询服务端群详情返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 600，错误描述“do not find this group”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 153. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_get_group_with_id_nonexistent`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_get_group_with_id_nonexistent`
- 业务说明：A 查询本地群详情
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 查询本地群详情
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  2. 操作：验证查询本地群详情返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 154. `im_flutter_sdk/native-auto-test/tests/group/test_group_file_list.py::test_group_get_group_file_list_from_server_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_file_list.py::test_group_get_group_file_list_from_server_success`
- 业务说明：测试准备：创建测试群并建立业务前置
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 查询群共享文件列表
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  3. 操作：验证查询群共享文件列表返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验关键字段：result、list。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 155. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_file_list.py::test_group_get_group_file_list_from_server_nonexistent_group[0-20]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_file_list.py::test_group_get_group_file_list_from_server_nonexistent_group[0-20]`
- 业务说明：A 查询群共享文件列表
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 查询群共享文件列表
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  2. 操作：验证查询群共享文件列表返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 600，错误描述“do not find this group”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 156. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_file_list.py::test_group_get_group_file_list_from_server_nonexistent_group[1-0]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_file_list.py::test_group_get_group_file_list_from_server_nonexistent_group[1-0]`
- 业务说明：A 查询群共享文件列表
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 查询群共享文件列表
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  2. 操作：验证查询群共享文件列表返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 600，错误描述“do not find this group”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 157. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_file_list.py::test_group_get_group_file_list_from_server_nonexistent_group[1-20]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_file_list.py::test_group_get_group_file_list_from_server_nonexistent_group[1-20]`
- 业务说明：A 查询群共享文件列表
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 查询群共享文件列表
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  2. 操作：验证查询群共享文件列表返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 600，错误描述“do not find this group”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 158. `im_flutter_sdk/native-auto-test/tests/group/test_group_server_state_lists.py::test_group_get_group_block_list_from_server_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_server_state_lists.py::test_group_get_group_block_list_from_server_success`
- 业务说明：测试准备：创建测试群并建立业务前置
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 查询群黑名单
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  3. 操作：验证查询群黑名单返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 159. `im_flutter_sdk/native-auto-test/tests/group/test_group_server_state_lists.py::test_group_get_group_mute_list_from_server_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_server_state_lists.py::test_group_get_group_mute_list_from_server_success`
- 业务说明：测试准备：创建测试群并建立业务前置
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 查询群禁言列表
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  3. 操作：验证查询群禁言列表返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 160. `im_flutter_sdk/native-auto-test/tests/group/test_group_server_state_lists.py::test_group_get_group_white_list_and_member_check_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_server_state_lists.py::test_group_get_group_white_list_and_member_check_success`
- 业务说明：测试准备：创建测试群并建立业务前置
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 查询群白名单
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  3. 操作：验证查询群白名单返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：A 查询白名单成员状态
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  5. 操作：验证查询白名单成员状态返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  6. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 161. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_public_groups_count.py::test_group_fetch_joined_group_count_with_extra_info`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_public_groups_count.py::test_group_fetch_joined_group_count_with_extra_info`
- 业务说明：A 查询已加入群数量
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 查询已加入群数量
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：验证查询已加入群数量返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 162. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_joined_groups.py::test_group_get_joined_groups_from_server_with_extra_info_fields`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_joined_groups.py::test_group_get_joined_groups_from_server_with_extra_info_fields`
- 业务说明：A 查询服务端已加入群列表
- 类型：普通
- 状态/版本说明：5.0 不可用
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 查询服务端已加入群列表
     - 预期：该原测试目标在 5.0 中不再成立。移除 getJoinedGroupsFromServer（残留，改本地 getJoinedGroups）
  2. 操作：验证查询服务端已加入群列表返回的关键字段
     - 预期：该原测试目标在 5.0 中不再成立。移除 getJoinedGroupsFromServer（残留，改本地 getJoinedGroups）
- 关键断言：
  1. 校验关键字段：cursor。

### 163. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_joined_groups.py::test_group_get_joined_groups_with_extra_info_fields`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_joined_groups.py::test_group_get_joined_groups_with_extra_info_fields`
- 业务说明：A 查询本地已加入群列表
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 查询本地已加入群列表
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：验证查询本地已加入群列表返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 当前测试步骤的同步响应、异步事件和最终业务状态满足代码断言。
  2. 任一关键字段、回调、列表、数量或最终状态不符时，Case 判定失败。

### 164. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_public_groups_count.py::test_group_get_public_groups_from_server_invalid_paging[-1-20]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_public_groups_count.py::test_group_get_public_groups_from_server_invalid_paging[-1-20]`
- 业务说明：A 查询公开群列表
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 查询公开群列表
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  2. 操作：验证查询公开群列表返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  3. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 165. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_public_groups_count.py::test_group_get_public_groups_from_server_invalid_paging[0-20]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_public_groups_count.py::test_group_get_public_groups_from_server_invalid_paging[0-20]`
- 业务说明：A 查询公开群列表
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 查询公开群列表
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  2. 操作：验证查询公开群列表返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  3. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 166. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_public_groups_count.py::test_group_get_public_groups_from_server_invalid_paging[1--1]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_public_groups_count.py::test_group_get_public_groups_from_server_invalid_paging[1--1]`
- 业务说明：A 查询公开群列表
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 查询公开群列表
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  2. 操作：验证查询公开群列表返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  3. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 167. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_public_groups_count.py::test_group_get_public_groups_from_server_invalid_paging[1-0]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_public_groups_count.py::test_group_get_public_groups_from_server_invalid_paging[1-0]`
- 业务说明：A 查询公开群列表
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 查询公开群列表
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  2. 操作：验证查询公开群列表返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  3. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 168. `im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_non_member_cannot_invite_user[add-members]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_non_member_cannot_invite_user[add-members]`
- 业务说明：即使 style=1 允许成员邀请，非成员仍不能调用任一邀请 API
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：B 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证执行群组业务操作返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  4. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 603，错误描述“group member permission is required”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 169. `im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_non_member_cannot_invite_user[inviter-user]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_non_member_cannot_invite_user[inviter-user]`
- 业务说明：即使 style=1 允许成员邀请，非成员仍不能调用任一邀请 API
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：B 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证执行群组业务操作返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  4. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 603，错误描述“group member permission is required”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 170. `im_flutter_sdk/native-auto-test/tests/group/test_group_join_requests_and_invitations.py::test_group_accept_invitation_from_group_without_pending_invite`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_join_requests_and_invitations.py::test_group_accept_invitation_from_group_without_pending_invite`
- 业务说明：B 接受入群邀请
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备B已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：B 接受入群邀请
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证接受入群邀请返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 600，错误描述“does not exist”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 171. `im_flutter_sdk/native-auto-test/tests/group/test_group_join_requests_and_invitations.py::test_group_accept_join_application_nonexistent_group`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_join_requests_and_invitations.py::test_group_accept_join_application_nonexistent_group`
- 业务说明：A 同意入群申请
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 同意入群申请
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证同意入群申请返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 600，错误描述“do not find this group”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 172. `im_flutter_sdk/native-auto-test/tests/group/test_group_join_requests_and_invitations.py::test_group_accept_join_application_nonexistent_user`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_join_requests_and_invitations.py::test_group_accept_join_application_nonexistent_user`
- 业务说明：测试准备：创建测试群并建立业务前置
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 同意入群申请
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证同意入群申请返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  4. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 600，错误描述“doesn”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 173. `im_flutter_sdk/native-auto-test/tests/group/test_group_join_requests_and_invitations.py::test_group_decline_invitation_from_group_without_pending_invite`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_join_requests_and_invitations.py::test_group_decline_invitation_from_group_without_pending_invite`
- 业务说明：B 拒绝入群邀请
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备B已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：B 拒绝入群邀请
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  2. 操作：验证拒绝入群邀请返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 600，错误描述“does not exist”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 174. `im_flutter_sdk/native-auto-test/tests/group/test_group_join_requests_and_invitations.py::test_group_decline_join_application_nonexistent_group`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_join_requests_and_invitations.py::test_group_decline_join_application_nonexistent_group`
- 业务说明：A 拒绝入群申请
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 拒绝入群申请
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  2. 操作：验证拒绝入群申请返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 600，错误描述“do not find this group”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 175. `im_flutter_sdk/native-auto-test/tests/group/test_group_join_application_state_matrix.py::test_group_join_application_empty_reason_uses_server_default`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_join_application_state_matrix.py::test_group_join_application_empty_reason_uses_server_default`
- 业务说明：空申请原因应被服务端规范化，并且 pending 仍可被正常拒绝
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：B 申请加入公开群
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  4. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：A 拒绝入群申请
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  6. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：to、result。

### 176. `im_flutter_sdk/native-auto-test/tests/group/test_group_chat_thread_user_removed.py::test_chat_thread_remove_member_updates_member_list`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_chat_thread_user_removed.py::test_chat_thread_remove_member_updates_member_list`
- 业务说明：链路： 1) A 建群并邀请 B 2) B 在群里发父消息 3) A 用父消息创建子区并让 B 加入 4) A 把 B 从子区移除 5) 查询子区成员，断言 A 仍在且 B 已被移除 当前 Android 实测 removeMemberFromChatThread 成功后不派发 onUserKickOutOfChatThread，因此按 SDK 可查询的真实成员状态验收移除结果
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：B 发送群消息
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证发送群消息返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：A 创建子区
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：验证创建子区返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  6. 操作：B 加入子区
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  7. 操作：验证加入子区返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  8. 操作：A 查询子区成员
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、from、to、convId、chatType、direction、status、hasRead、content、result、list、cursor。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 177. `im_flutter_sdk/native-auto-test/tests/group/test_group_join_application_state_matrix.py::test_group_join_application_processing_permission_by_role[member-accept]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_join_application_state_matrix.py::test_group_join_application_processing_permission_by_role[member-accept]`
- 业务说明：普通成员不能处理申请；管理员按原生权限接收并处理申请
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 添加群管理员
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证 添加群管理员返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：A 申请加入公开群
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  5. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  7. 操作：B 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  8. 操作：验证执行群组业务操作返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 603，错误描述“permission”。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 校验关键字段：result。
  4. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 178. `im_flutter_sdk/native-auto-test/tests/group/test_group_join_application_state_matrix.py::test_group_join_application_processing_permission_by_role[member-decline]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_join_application_state_matrix.py::test_group_join_application_processing_permission_by_role[member-decline]`
- 业务说明：普通成员不能处理申请；管理员按原生权限接收并处理申请
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 添加群管理员
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证 添加群管理员返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：A 申请加入公开群
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  5. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  7. 操作：B 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  8. 操作：验证执行群组业务操作返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 603，错误描述“permission”。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 校验关键字段：result。
  4. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 179. `im_flutter_sdk/native-auto-test/tests/group/test_group_join_application_state_matrix.py::test_group_join_application_processing_permission_by_role[admin-accept]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_join_application_state_matrix.py::test_group_join_application_processing_permission_by_role[admin-accept]`
- 业务说明：普通成员不能处理申请；管理员按原生权限接收并处理申请
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 添加群管理员
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证 添加群管理员返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：A 申请加入公开群
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  5. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  7. 操作：B 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  8. 操作：验证执行群组业务操作返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 603，错误描述“permission”。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 校验关键字段：result。
  4. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 180. `im_flutter_sdk/native-auto-test/tests/group/test_group_join_application_state_matrix.py::test_group_join_application_processing_permission_by_role[admin-decline]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_join_application_state_matrix.py::test_group_join_application_processing_permission_by_role[admin-decline]`
- 业务说明：普通成员不能处理申请；管理员按原生权限接收并处理申请
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 添加群管理员
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证 添加群管理员返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：A 申请加入公开群
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  5. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  7. 操作：B 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  8. 操作：验证执行群组业务操作返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 603，错误描述“permission”。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 校验关键字段：result。
  4. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 181. `im_flutter_sdk/native-auto-test/tests/group/test_group_shared_files.py::test_group_remove_shared_file_nonexistent_group`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_shared_files.py::test_group_remove_shared_file_nonexistent_group`
- 业务说明：前置：使用固定不存在的 groupId 和 fileId
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证执行群组业务操作返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 600，错误描述“do not find this group”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 182. `im_flutter_sdk/native-auto-test/tests/group/test_group_shared_files.py::test_group_upload_shared_file_nonexistent_group`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_shared_files.py::test_group_upload_shared_file_nonexistent_group`
- 业务说明：前置：使用固定不存在的 groupId 和显式 Android 不可读路径
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 上传群共享文件
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证 上传群共享文件返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 600，错误描述“do not find this group”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 183. `im_flutter_sdk/native-auto-test/tests/group/test_group_shared_files.py::test_group_download_shared_file_nonexistent_group_current_behavior`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_shared_files.py::test_group_download_shared_file_nonexistent_group_current_behavior`
- 业务说明：前置：使用固定不存在的 groupId/fileId 和宿主机保存路径
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 下载群共享文件
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证 下载群共享文件返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验异常返回：错误码 600，错误描述“do not find this group”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 184. `im_flutter_sdk/native-auto-test/tests/group/test_group_shared_files.py::test_group_upload_shared_file_invalid_path`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_shared_files.py::test_group_upload_shared_file_invalid_path`
- 业务说明：前置：A 为群主，显式设备路径在 Android 中不存在
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 上传群共享文件
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证 上传群共享文件返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  4. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 401，错误描述“Invalid file”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 185. `im_flutter_sdk/native-auto-test/tests/group/test_group_joined_groups.py::test_group_joined_lists_follow_invite_remove_readd_and_member_leave`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_joined_groups.py::test_group_joined_lists_follow_invite_remove_readd_and_member_leave`
- 业务说明：前置：A 为群主，B 初始不是目标群成员，B 的自动接受邀请开关为 true
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  3. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  4. 操作：验证本用例的关键业务结果
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  5. 操作：A 移除群成员
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  6. 操作：验证 移除群成员返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  7. 操作：A 添加群成员
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  8. 操作：验证 添加群成员返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result、list。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 186. `im_flutter_sdk/native-auto-test/tests/group/test_group_shared_files.py::test_group_upload_shared_file_explicit_host_path_is_invalid`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_shared_files.py::test_group_upload_shared_file_explicit_host_path_is_invalid`
- 业务说明：前置：A 为群主；传入的 `/private/tmp/...` 是 macOS 宿主机路径，不存在于 Android
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 上传群共享文件
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证 上传群共享文件返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  4. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 401，错误描述“Invalid file”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 187. `im_flutter_sdk/native-auto-test/tests/group/test_group_public_groups_count.py::test_group_fetch_joined_group_count_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_public_groups_count.py::test_group_fetch_joined_group_count_success`
- 业务说明：前置：A 已登录，当前账号可能已加入零个或多个共享环境群组
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 查询已加入群数量
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：验证查询已加入群数量返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 188. `im_flutter_sdk/native-auto-test/tests/group/test_group_public_groups_count.py::test_group_get_public_groups_from_server_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_public_groups_count.py::test_group_get_public_groups_from_server_success`
- 业务说明：前置：A 已登录，公开群列表允许包含共享环境已有数据
- 类型：普通
- 状态/版本说明：5.0 不可用
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 查询公开群列表
     - 预期：该原测试目标在 5.0 中不再成立。移除服务端拉公开群（getPublicGroupsFromServer 残留，无公开群列表）
  2. 操作：验证查询公开群列表返回的关键字段
     - 预期：该原测试目标在 5.0 中不再成立。移除服务端拉公开群（getPublicGroupsFromServer 残留，无公开群列表）
  3. 操作：验证群业务状态、事件与关键字段
     - 预期：该原测试目标在 5.0 中不再成立。移除服务端拉公开群（getPublicGroupsFromServer 残留，无公开群列表）
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result、list、cursor。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 189. `im_flutter_sdk/native-auto-test/tests/group/test_group_public_groups_count.py::test_group_public_groups_cursor_paginates_two_created_groups`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_public_groups_count.py::test_group_public_groups_cursor_paginates_two_created_groups`
- 业务说明：前置：A 已登录；测试依次创建两个名称唯一的 PublicOpenJoin（style=3）公开群
- 类型：普通
- 状态/版本说明：5.0 不可用
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：该原测试目标在 5.0 中不再成立。移除服务端拉公开群（getPublicGroupsFromServer 残留，无公开群列表）
  2. 操作：A 查询公开群列表
     - 预期：该原测试目标在 5.0 中不再成立。移除服务端拉公开群（getPublicGroupsFromServer 残留，无公开群列表）
  3. 操作：验证查询公开群列表返回的关键字段
     - 预期：该原测试目标在 5.0 中不再成立。移除服务端拉公开群（getPublicGroupsFromServer 残留，无公开群列表）
  4. 操作：验证群业务状态、事件与关键字段
     - 预期：该原测试目标在 5.0 中不再成立。移除服务端拉公开群（getPublicGroupsFromServer 残留，无公开群列表）
  5. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：该原测试目标在 5.0 中不再成立。移除服务端拉公开群（getPublicGroupsFromServer 残留，无公开群列表）
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result、list、cursor。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 190. `im_flutter_sdk/native-auto-test/tests/group/test_group_joined_groups.py::test_group_get_joined_groups_local_contains_created_group`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_joined_groups.py::test_group_get_joined_groups_local_contains_created_group`
- 业务说明：前置：A 已登录且尚未创建本 case 的目标群
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 查询本地已加入群列表
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证查询本地已加入群列表返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 191. `im_flutter_sdk/native-auto-test/tests/group/test_group_joined_groups.py::test_group_get_joined_groups_contains_created_group`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_joined_groups.py::test_group_get_joined_groups_contains_created_group`
- 业务说明：前置：A 已登录且尚未创建本 case 的目标群
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 查询本地已加入群列表
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证查询本地已加入群列表返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 192. `im_flutter_sdk/native-auto-test/tests/group/test_group_members.py::test_group_join_public_group_rejects_private_member_invite_group`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_members.py::test_group_join_public_group_rejects_private_member_invite_group`
- 业务说明：前置：A/B 已登录，A 创建 PrivateMemberCanInvite（style=1）私有群，B 不是成员
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：B 加入公开群
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证加入公开群返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  4. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 603，错误描述“group member permission is required”。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 193. `im_flutter_sdk/native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_mute_members_role_permission_matrix[member]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_mute_members_role_permission_matrix[member]`
- 业务说明：群主/管理员可禁言与解除禁言；普通成员被拒绝且状态不变
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：动作端 禁言成员
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证解除成员禁言返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  4. 操作：验证 禁言成员返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  5. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  7. 操作：动作端 解除成员禁言
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  8. 操作：验证解除成员禁言返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验异常返回：错误码 603。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 194. `im_flutter_sdk/native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_mute_members_role_permission_matrix[admin]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_mute_members_role_permission_matrix[admin]`
- 业务说明：群主/管理员可禁言与解除禁言；普通成员被拒绝且状态不变
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：动作端 禁言成员
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证解除成员禁言返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  4. 操作：验证 禁言成员返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  5. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  7. 操作：动作端 解除成员禁言
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  8. 操作：验证解除成员禁言返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验异常返回：错误码 603。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 195. `im_flutter_sdk/native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_mute_members_role_permission_matrix[owner]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_mute_members_role_permission_matrix[owner]`
- 业务说明：群主/管理员可禁言与解除禁言；普通成员被拒绝且状态不变
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：动作端 禁言成员
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证解除成员禁言返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  4. 操作：验证 禁言成员返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  5. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  7. 操作：动作端 解除成员禁言
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  8. 操作：验证解除成员禁言返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验异常返回：错误码 603。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 196. `im_flutter_sdk/native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_mute_all_role_permission_matrix[member]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_mute_all_role_permission_matrix[member]`
- 业务说明：群主/管理员可切换全员禁言；普通成员被拒绝且状态不变
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：动作端 全员禁言
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证解除全员禁言返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  4. 操作：验证 全员禁言返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  5. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  7. 操作：动作端 解除全员禁言
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  8. 操作：验证解除全员禁言返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验异常返回：错误码 603。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 197. `im_flutter_sdk/native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_mute_all_role_permission_matrix[admin]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_mute_all_role_permission_matrix[admin]`
- 业务说明：群主/管理员可切换全员禁言；普通成员被拒绝且状态不变
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：动作端 全员禁言
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证解除全员禁言返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  4. 操作：验证 全员禁言返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  5. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  7. 操作：动作端 解除全员禁言
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  8. 操作：验证解除全员禁言返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验异常返回：错误码 603。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 198. `im_flutter_sdk/native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_mute_all_role_permission_matrix[owner]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_mute_all_role_permission_matrix[owner]`
- 业务说明：群主/管理员可切换全员禁言；普通成员被拒绝且状态不变
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：动作端 全员禁言
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证解除全员禁言返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  4. 操作：验证 全员禁言返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  5. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  7. 操作：动作端 解除全员禁言
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  8. 操作：验证解除全员禁言返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验异常返回：错误码 603。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 199. `im_flutter_sdk/native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_allow_list_role_permission_matrix[member]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_allow_list_role_permission_matrix[member]`
- 业务说明：群主/管理员可增删白名单；普通成员被拒绝且白名单保持为空
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：动作端 加入群白名单
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证移出群白名单返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  4. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：动作端 查询白名单成员状态
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  7. 操作：动作端 移出群白名单
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  8. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 603。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 校验关键字段：result。
  4. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 200. `im_flutter_sdk/native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_allow_list_role_permission_matrix[admin]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_allow_list_role_permission_matrix[admin]`
- 业务说明：群主/管理员可增删白名单；普通成员被拒绝且白名单保持为空
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：动作端 加入群白名单
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证移出群白名单返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  4. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：动作端 查询白名单成员状态
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  7. 操作：动作端 移出群白名单
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  8. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 603。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 校验关键字段：result。
  4. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 201. `im_flutter_sdk/native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_allow_list_role_permission_matrix[owner]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_allow_list_role_permission_matrix[owner]`
- 业务说明：群主/管理员可增删白名单；普通成员被拒绝且白名单保持为空
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：动作端 加入群白名单
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证移出群白名单返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  4. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：动作端 查询白名单成员状态
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  7. 操作：动作端 移出群白名单
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  8. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 603。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 校验关键字段：result。
  4. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 202. `im_flutter_sdk/native-auto-test/tests/group/test_group_member_attributes_remove.py::test_group_remove_member_attributes_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_member_attributes_remove.py::test_group_remove_member_attributes_success`
- 业务说明：测试准备：创建测试群并建立业务前置
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：B 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证执行群组业务操作返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：B 删除成员属性
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  6. 操作：验证删除成员属性返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  7. 操作：A 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  8. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 203. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_member_attributes_remove.py::test_group_remove_member_attributes_empty_keys`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_member_attributes_remove.py::test_group_remove_member_attributes_empty_keys`
- 业务说明：测试准备：创建测试群并建立业务前置
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 删除成员属性
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证删除成员属性返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  4. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 205，错误描述“Invalid parameter”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 204. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_member_attributes_remove.py::test_group_remove_member_attributes_nonexistent_group`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_member_attributes_remove.py::test_group_remove_member_attributes_nonexistent_group`
- 业务说明：A 删除成员属性
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 删除成员属性
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：验证删除成员属性返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 205. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_member_attributes_remove.py::test_group_remove_member_attributes_nonexistent_key`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_member_attributes_remove.py::test_group_remove_member_attributes_nonexistent_key`
- 业务说明：测试准备：创建测试群并建立业务前置
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 删除成员属性
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证删除成员属性返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 206. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_members.py::test_group_remove_members_non_member`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_members.py::test_group_remove_members_non_member`
- 业务说明：测试准备：创建测试群并建立业务前置
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 移除群成员
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证 移除群成员返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  4. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 603，错误描述“are not members of this group”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 207. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_roles.py::test_group_remove_admin_nonexistent_group`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_roles.py::test_group_remove_admin_nonexistent_group`
- 业务说明：A 移除群管理员
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 移除群管理员
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证 移除群管理员返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 600，错误描述“do not find this group”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 208. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_members.py::test_group_add_members_empty_members`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_members.py::test_group_add_members_empty_members`
- 业务说明：测试准备：创建测试群并建立业务前置
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 添加群成员
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证 添加群成员返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 209. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_members.py::test_group_add_members_nonexistent_group`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_members.py::test_group_add_members_nonexistent_group`
- 业务说明：A 添加群成员
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 添加群成员
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：验证 添加群成员返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 600，错误描述“do not find this group”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 210. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_members.py::test_group_add_members_nonexistent_user`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_members.py::test_group_add_members_nonexistent_user`
- 业务说明：测试准备：创建测试群并建立业务前置
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 添加群成员
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证 添加群成员返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  4. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 603，错误描述“doesn”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 211. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_roles.py::test_group_add_admin_non_member`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_roles.py::test_group_add_admin_non_member`
- 业务说明：测试准备：创建测试群并建立业务前置
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 添加群管理员
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证 添加群管理员返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  4. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 600，错误描述“doesn”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 212. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_roles.py::test_group_add_admin_nonexistent_group`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_roles.py::test_group_add_admin_nonexistent_group`
- 业务说明：A 添加群管理员
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 添加群管理员
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：验证 添加群管理员返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 600，错误描述“do not find this group”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 213. `im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_owner_can_invite_for_each_remaining_style[private-member-add-members]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_owner_can_invite_for_each_remaining_style[private-member-add-members]`
- 业务说明：通用 inviterUser API 应覆盖 style=1/2/3 的群主邀请链路
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  4. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：验证执行群组业务操作返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  6. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 214. `im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_owner_can_invite_for_each_remaining_style[private-member-inviter-user]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_owner_can_invite_for_each_remaining_style[private-member-inviter-user]`
- 业务说明：通用 inviterUser API 应覆盖 style=1/2/3 的群主邀请链路
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  4. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：验证执行群组业务操作返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  6. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 215. `im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_owner_can_invite_for_each_remaining_style[public-approval-add-members]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_owner_can_invite_for_each_remaining_style[public-approval-add-members]`
- 业务说明：通用 inviterUser API 应覆盖 style=1/2/3 的群主邀请链路
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  4. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：验证执行群组业务操作返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  6. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 216. `im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_owner_can_invite_for_each_remaining_style[public-approval-inviter-user]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_owner_can_invite_for_each_remaining_style[public-approval-inviter-user]`
- 业务说明：通用 inviterUser API 应覆盖 style=1/2/3 的群主邀请链路
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  4. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：验证执行群组业务操作返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  6. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 217. `im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_owner_can_invite_for_each_remaining_style[public-open-add-members]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_owner_can_invite_for_each_remaining_style[public-open-add-members]`
- 业务说明：通用 inviterUser API 应覆盖 style=1/2/3 的群主邀请链路
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  4. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：验证执行群组业务操作返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  6. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 218. `im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_owner_can_invite_for_each_remaining_style[public-open-inviter-user]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_owner_can_invite_for_each_remaining_style[public-open-inviter-user]`
- 业务说明：通用 inviterUser API 应覆盖 style=1/2/3 的群主邀请链路
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  4. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：验证执行群组业务操作返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  6. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 219. `im_flutter_sdk/native-auto-test/tests/group/test_group_join_application_state_matrix.py::test_group_duplicate_join_application_keeps_single_pending_request`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_join_application_state_matrix.py::test_group_duplicate_join_application_keeps_single_pending_request`
- 业务说明：同一用户重复申请时，两次通知可见，但只保留一个可处理的 pending
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 拒绝入群申请
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  3. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  4. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。

### 220. `im_flutter_sdk/native-auto-test/tests/group/test_group_members.py::test_group_members_batch_join_exit_new_events`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_members.py::test_group_members_batch_join_exit_new_events`
- 业务说明：校验新事件名： - onMembersJoinedFromGroup - onMembersExitedFromGroup
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 添加群成员
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证 添加群成员返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：A 移除群成员
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  6. 操作：验证 移除群成员返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  7. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result、list。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 221. `im_flutter_sdk/native-auto-test/tests/group/test_group_invitation_state_matrix.py::test_group_invitation_cannot_be_processed_twice[accept-then-decline]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_invitation_state_matrix.py::test_group_invitation_cannot_be_processed_twice[accept-then-decline]`
- 业务说明：邀请首次处理后 pending 消失，重复或反向处理应失败且不改变首次结果
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：B 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证执行群组业务操作返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：验证执行群组业务操作返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  7. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 601、603，错误描述“already joined；is not in the invitee list”。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 校验关键字段：result、list。
  4. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 222. `im_flutter_sdk/native-auto-test/tests/group/test_group_invitation_state_matrix.py::test_group_invitation_cannot_be_processed_twice[accept-twice]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_invitation_state_matrix.py::test_group_invitation_cannot_be_processed_twice[accept-twice]`
- 业务说明：邀请首次处理后 pending 消失，重复或反向处理应失败且不改变首次结果
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：B 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证执行群组业务操作返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：验证执行群组业务操作返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  7. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 601、603，错误描述“already joined；is not in the invitee list”。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 校验关键字段：result、list。
  4. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 223. `im_flutter_sdk/native-auto-test/tests/group/test_group_invitation_state_matrix.py::test_group_invitation_cannot_be_processed_twice[decline-then-accept]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_invitation_state_matrix.py::test_group_invitation_cannot_be_processed_twice[decline-then-accept]`
- 业务说明：邀请首次处理后 pending 消失，重复或反向处理应失败且不改变首次结果
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：B 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证执行群组业务操作返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：验证执行群组业务操作返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  7. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 601、603，错误描述“already joined；is not in the invitee list”。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 校验关键字段：result、list。
  4. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 224. `im_flutter_sdk/native-auto-test/tests/group/test_group_invitation_state_matrix.py::test_group_invitation_cannot_be_processed_twice[decline-twice]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_invitation_state_matrix.py::test_group_invitation_cannot_be_processed_twice[decline-twice]`
- 业务说明：邀请首次处理后 pending 消失，重复或反向处理应失败且不改变首次结果
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：B 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证执行群组业务操作返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：验证执行群组业务操作返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  7. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 601、603，错误描述“already joined；is not in the invitee list”。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 校验关键字段：result、list。
  4. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 225. `im_flutter_sdk/native-auto-test/tests/group/test_group_join_application_state_matrix.py::test_group_join_application_cannot_be_processed_twice[accept-then-decline]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_join_application_state_matrix.py::test_group_join_application_cannot_be_processed_twice[accept-then-decline]`
- 业务说明：一个 pending 申请只能处理一次，重复或反向处理不得改变首次结果
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  4. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：验证执行群组业务操作返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  6. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 110，错误描述“is not in the apply list”。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 校验关键字段：result、list。
  4. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 226. `im_flutter_sdk/native-auto-test/tests/group/test_group_join_application_state_matrix.py::test_group_join_application_cannot_be_processed_twice[accept-twice]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_join_application_state_matrix.py::test_group_join_application_cannot_be_processed_twice[accept-twice]`
- 业务说明：一个 pending 申请只能处理一次，重复或反向处理不得改变首次结果
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  4. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：验证执行群组业务操作返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  6. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 110，错误描述“is not in the apply list”。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 校验关键字段：result、list。
  4. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 227. `im_flutter_sdk/native-auto-test/tests/group/test_group_join_application_state_matrix.py::test_group_join_application_cannot_be_processed_twice[decline-then-accept]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_join_application_state_matrix.py::test_group_join_application_cannot_be_processed_twice[decline-then-accept]`
- 业务说明：一个 pending 申请只能处理一次，重复或反向处理不得改变首次结果
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  4. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：验证执行群组业务操作返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  6. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 110，错误描述“is not in the apply list”。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 校验关键字段：result、list。
  4. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 228. `im_flutter_sdk/native-auto-test/tests/group/test_group_join_application_state_matrix.py::test_group_join_application_cannot_be_processed_twice[decline-twice]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_join_application_state_matrix.py::test_group_join_application_cannot_be_processed_twice[decline-twice]`
- 业务说明：一个 pending 申请只能处理一次，重复或反向处理不得改变首次结果
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  4. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：验证执行群组业务操作返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  6. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 110，错误描述“is not in the apply list”。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 校验关键字段：result、list。
  4. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 229. `im_flutter_sdk/native-auto-test/tests/group/test_group_invitation_state_matrix.py::test_group_invitation_valid_group_without_pending_is_rejected[accept]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_invitation_state_matrix.py::test_group_invitation_valid_group_without_pending_is_rejected[accept]`
- 业务说明：有效群中没有待处理邀请时，接受和拒绝都返回稳定错误
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：B 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证执行群组业务操作返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  4. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 603，错误描述“is not in the invitee list”。
  2. 校验关键字段：list。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 230. `im_flutter_sdk/native-auto-test/tests/group/test_group_invitation_state_matrix.py::test_group_invitation_valid_group_without_pending_is_rejected[decline]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_invitation_state_matrix.py::test_group_invitation_valid_group_without_pending_is_rejected[decline]`
- 业务说明：有效群中没有待处理邀请时，接受和拒绝都返回稳定错误
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：B 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证执行群组业务操作返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  4. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 603，错误描述“is not in the invitee list”。
  2. 校验关键字段：list。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 231. `im_flutter_sdk/native-auto-test/tests/group/test_group_join_application_state_matrix.py::test_group_join_application_valid_group_without_pending_is_rejected[accept]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_join_application_state_matrix.py::test_group_join_application_valid_group_without_pending_is_rejected[accept]`
- 业务说明：有效审批群中不存在 pending 申请时，同意和拒绝都应返回稳定错误
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证执行群组业务操作返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  4. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 110，错误描述“is not in the apply list”。
  2. 校验关键字段：list。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 232. `im_flutter_sdk/native-auto-test/tests/group/test_group_join_application_state_matrix.py::test_group_join_application_valid_group_without_pending_is_rejected[decline]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_join_application_state_matrix.py::test_group_join_application_valid_group_without_pending_is_rejected[decline]`
- 业务说明：有效审批群中不存在 pending 申请时，同意和拒绝都应返回稳定错误
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证执行群组业务操作返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  4. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 110，错误描述“is not in the apply list”。
  2. 校验关键字段：list。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 233. `im_flutter_sdk/native-auto-test/tests/group/test_group_message_send.py::test_group_message_send_rejects_invalid_group_target[empty]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_message_send.py::test_group_message_send_rejects_invalid_group_target[empty]`
- 业务说明：A 向空或不存在 groupId 发送群文本时应失败，B 不得收到目标消息
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 向 群目标发送文本并验证失败终态
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 500。
  2. 校验关键字段：content。

### 234. `im_flutter_sdk/native-auto-test/tests/group/test_group_message_send.py::test_group_message_send_rejects_invalid_group_target[nonexistent]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_message_send.py::test_group_message_send_rejects_invalid_group_target[nonexistent]`
- 业务说明：A 向空或不存在 groupId 发送群文本时应失败，B 不得收到目标消息
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 向 群目标发送文本并验证失败终态
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 500。
  2. 校验关键字段：content。

### 235. `im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_public_open_join_rejects_blocked_user`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_public_open_join_rejects_blocked_user`
- 业务说明：B 被移入群黑名单并移出后，不得通过 PublicOpenJoin 重新加入
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 加入群黑名单
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证加入群黑名单返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：B 加入公开群
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  6. 操作：验证加入公开群返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  7. 操作：验证加入公开群返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  8. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 613，错误描述“blacklist”。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 校验关键字段：result。
  4. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 236. `im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_public_open_join_rejects_duplicate_membership`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_public_open_join_rejects_duplicate_membership`
- 业务说明：B 成功加入 PublicOpenJoin 后再次 join，不得重复增加成员或重复发送加入事件
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：B 加入公开群
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  4. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：验证加入公开群返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  6. 操作：验证加入公开群返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  7. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 601，错误描述“already joined”。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 237. `im_flutter_sdk/native-auto-test/tests/group/test_group_message_send.py::test_group_message_send_rejects_non_member_states[left]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_message_send.py::test_group_message_send_rejects_non_member_states[left]`
- 业务说明：B 从未入群、主动退出或被移除后发送群文本均应失败，群主 A 不得收到消息
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：B 退出群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证退出群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：A 移除群成员
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  6. 操作：验证 移除群成员返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  7. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  8. 操作：A 查询服务端群详情
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验异常返回：错误码 602。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 校验关键字段：content、result。
  4. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 238. `im_flutter_sdk/native-auto-test/tests/group/test_group_message_send.py::test_group_message_send_rejects_non_member_states[never-member]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_message_send.py::test_group_message_send_rejects_non_member_states[never-member]`
- 业务说明：B 从未入群、主动退出或被移除后发送群文本均应失败，群主 A 不得收到消息
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：B 退出群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证退出群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：A 移除群成员
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  6. 操作：验证 移除群成员返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  7. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  8. 操作：A 查询服务端群详情
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验异常返回：错误码 602。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 校验关键字段：content、result。
  4. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 239. `im_flutter_sdk/native-auto-test/tests/group/test_group_message_send.py::test_group_message_send_rejects_non_member_states[removed]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_message_send.py::test_group_message_send_rejects_non_member_states[removed]`
- 业务说明：B 从未入群、主动退出或被移除后发送群文本均应失败，群主 A 不得收到消息
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：B 退出群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证退出群返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：A 移除群成员
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  6. 操作：验证 移除群成员返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  7. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  8. 操作：A 查询服务端群详情
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验异常返回：错误码 602。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 校验关键字段：content、result。
  4. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 240. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_blocking.py::test_group_block_idempotent`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_blocking.py::test_group_block_idempotent`
- 业务说明：测试准备：创建测试群并建立业务前置
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 屏蔽群消息
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证屏蔽群消息返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：测试后置：A 取消屏蔽群消息
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 241. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_blocking.py::test_group_block_nonexistent_group`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_blocking.py::test_group_block_nonexistent_group`
- 业务说明：A 屏蔽群消息
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 屏蔽群消息
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证屏蔽群消息返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 600，错误描述“do not find this group”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 242. `im_flutter_sdk/native-auto-test/tests/group/test_group_blocking.py::test_group_block_then_unblock_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_blocking.py::test_group_block_then_unblock_success`
- 业务说明：测试准备：创建测试群并建立业务前置
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 屏蔽群消息
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证屏蔽群消息返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：A 取消屏蔽群消息
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  6. 操作：验证取消屏蔽群消息返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  7. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 243. `im_flutter_sdk/native-auto-test/tests/group/test_group_moderation.py::test_group_block_unblock_members_nonexistent_group[blockMembers]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_moderation.py::test_group_block_unblock_members_nonexistent_group[blockMembers]`
- 业务说明：A 执行群组业务操作
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证执行群组业务操作返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 600，错误描述“do not find this group”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 244. `im_flutter_sdk/native-auto-test/tests/group/test_group_moderation.py::test_group_block_unblock_members_nonexistent_group[unblockMembers]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_moderation.py::test_group_block_unblock_members_nonexistent_group[unblockMembers]`
- 业务说明：A 执行群组业务操作
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证执行群组业务操作返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 600，错误描述“do not find this group”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 245. `im_flutter_sdk/native-auto-test/tests/group/test_group_remaining_api_coverage.py::test_group_clear_all_groups_from_local_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_remaining_api_coverage.py::test_group_clear_all_groups_from_local_success`
- 业务说明：clearAllGroupsFromLocal：清理本地群缓存，实测成功返回 None
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 清理本地群数据
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证清理本地群数据返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 246. `im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_create_group_invites_member_for_each_remaining_style[private-member]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_create_group_invites_member_for_each_remaining_style[private-member]`
- 业务说明：createGroup.inviteMembers 应覆盖 style=1/2/3 的直接邀请入群链路
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  3. 操作：验证本用例的关键业务结果
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 247. `im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_create_group_invites_member_for_each_remaining_style[public-approval]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_create_group_invites_member_for_each_remaining_style[public-approval]`
- 业务说明：createGroup.inviteMembers 应覆盖 style=1/2/3 的直接邀请入群链路
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  3. 操作：验证本用例的关键业务结果
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 248. `im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_create_group_invites_member_for_each_remaining_style[public-open]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_create_group_invites_member_for_each_remaining_style[public-open]`
- 业务说明：createGroup.inviteMembers 应覆盖 style=1/2/3 的直接邀请入群链路
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  3. 操作：验证本用例的关键业务结果
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 249. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_destroy_group_empty_group_id`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_destroy_group_empty_group_id`
- 业务说明：A 销毁测试群
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 销毁测试群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证销毁测试群返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 600。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 250. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_destroy_group_nonexistent`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_destroy_group_nonexistent`
- 业务说明：A 销毁测试群
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 销毁测试群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证销毁测试群返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 600，错误描述“do not find this group”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 251. `im_flutter_sdk/native-auto-test/tests/group/test_group_chat_thread_remaining_api_coverage.py::test_chat_thread_fetch_detail_and_lists`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_chat_thread_remaining_api_coverage.py::test_chat_thread_fetch_detail_and_lists`
- 业务说明：fetchChatThreadDetail/getThread会话/joined/parent 列表：创建并加入子区后校验详情、线程会话和列表
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立成员前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 查询子区详情
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  3. 操作：验证查询子区详情返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：A 执行群消息操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：验证执行群消息操作返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  6. 操作：B 执行子区业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  7. 操作：验证执行子区业务操作返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  8. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：msgId、convId、result、cursor。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 252. `im_flutter_sdk/native-auto-test/tests/group/test_group_remaining_api_coverage.py::test_group_fetch_members_info_empty_group_id`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_remaining_api_coverage.py::test_group_fetch_members_info_empty_group_id`
- 业务说明：fetchGroupMembersInfo：groupId 为空字符串时，冻结真实错误返回
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 查询群成员信息
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  2. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验异常返回：错误码 600，错误描述“Group ID is invalid”。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 校验关键字段：cursor。
  4. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 253. `im_flutter_sdk/native-auto-test/tests/group/test_group_remaining_api_coverage.py::test_group_fetch_members_info_invalid_limit`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_remaining_api_coverage.py::test_group_fetch_members_info_invalid_limit`
- 业务说明：fetchGroupMembersInfo：limit=0 的分页边界，并比对成员资料与当前用户资料一致
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 查询用户资料
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  2. 操作：验证查询用户资料返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  3. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  4. 操作：A 查询群成员信息
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  5. 操作：验证查询群成员信息返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  6. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验关键字段：result、list、cursor。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 254. `im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_direct_invite_ignores_auto_accept_disabled_when_confirmation_not_required`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_direct_invite_ignores_auto_accept_disabled_when_confirmation_not_required`
- 业务说明：inviteNeedConfirm=false 时，即使 B 关闭自动接受，也应由服务端直接加入
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：B 关闭自动接受群邀请
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证自动接受群邀请设置已更新
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  4. 操作：A 添加群成员
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  5. 操作：验证 添加群成员返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  6. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  7. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  8. 操作：测试后置：恢复 B 的自动接受群邀请设置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 255. `im_flutter_sdk/native-auto-test/tests/group/test_group_inviter.py::test_group_inviter_user_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_inviter.py::test_group_inviter_user_success`
- 业务说明：测试准备：创建测试群并建立业务前置
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 邀请成员
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证邀请成员返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：A 查询服务端群详情
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  6. 操作：验证查询服务端群详情返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  7. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 256. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_inviter.py::test_group_inviter_user_empty_members`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_inviter.py::test_group_inviter_user_empty_members`
- 业务说明：测试准备：创建测试群并建立业务前置
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 邀请成员
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证邀请成员返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 257. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_inviter.py::test_group_inviter_user_nonexistent_group`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_inviter.py::test_group_inviter_user_nonexistent_group`
- 业务说明：A 邀请成员
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 邀请成员
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证邀请成员返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 600，错误描述“do not find this group”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 258. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_inviter.py::test_group_inviter_user_nonexistent_user`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_inviter.py::test_group_inviter_user_nonexistent_user`
- 业务说明：测试准备：创建测试群并建立业务前置
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 邀请成员
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证邀请成员返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  4. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 603，错误描述“doesn”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 259. `im_flutter_sdk/native-auto-test/tests/group/test_group_membership_checks.py::test_group_is_member_in_white_list_and_mute_list_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_membership_checks.py::test_group_is_member_in_white_list_and_mute_list_success`
- 业务说明：测试准备：创建测试群并建立业务前置
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 查询白名单成员状态
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  3. 操作：验证查询白名单成员状态返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：A 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：验证执行群组业务操作返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  6. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 260. `im_flutter_sdk/native-auto-test/tests/group/test_group_membership_checks.py::test_group_is_member_in_white_list_and_mute_list_nonexistent_group`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_membership_checks.py::test_group_is_member_in_white_list_and_mute_list_nonexistent_group`
- 业务说明：A 执行群组业务操作
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证执行群组业务操作返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 600，错误描述“do not find this group”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 261. `im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_join_public_group_rejects_every_non_open_style[private-member]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_join_public_group_rejects_every_non_open_style[private-member]`
- 业务说明：joinPublicGroup 拒绝私有群（style 0/1，603）；public-approval(style=2)/public-open(style=3) 5.0 允许加入（公开群）
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：B 加入公开群
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证加入公开群返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  4. 操作：验证加入公开群返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  5. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 603，错误描述“permission”。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 262. `im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_join_public_group_rejects_every_non_open_style[private-owner]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_join_public_group_rejects_every_non_open_style[private-owner]`
- 业务说明：joinPublicGroup 拒绝私有群（style 0/1，603）；public-approval(style=2)/public-open(style=3) 5.0 允许加入（公开群）
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：B 加入公开群
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证加入公开群返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  4. 操作：验证加入公开群返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  5. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 603，错误描述“permission”。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 263. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_members.py::test_group_leave_group_non_member`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_members.py::test_group_leave_group_non_member`
- 业务说明：B 退出群
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备B已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：B 退出群
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证退出群返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 600，错误描述“do not find this group”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 264. `im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_public_open_join_rejects_when_group_is_full`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_public_open_join_rejects_when_group_is_full`
- 业务说明：maxCount=2 的公开自由群已包含 A+B 时，C 不得加入
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：B 加入公开群
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证加入公开群返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  4. 操作：验证加入公开群返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  5. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 604，错误描述“capacity is reached”。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 265. `im_flutter_sdk/native-auto-test/tests/group/test_group_moderation.py::test_group_moderation_nonexistent_group_errors[addWhiteList-info4-600-do not find this group]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_moderation.py::test_group_moderation_nonexistent_group_errors[addWhiteList-info4-600-do not find this group]`
- 业务说明：A 执行群组业务操作
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证执行群组业务操作返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 266. `im_flutter_sdk/native-auto-test/tests/group/test_group_moderation.py::test_group_moderation_nonexistent_group_errors[muteAllMembers-info2-600-do not find this group]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_moderation.py::test_group_moderation_nonexistent_group_errors[muteAllMembers-info2-600-do not find this group]`
- 业务说明：A 执行群组业务操作
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证执行群组业务操作返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 267. `im_flutter_sdk/native-auto-test/tests/group/test_group_moderation.py::test_group_moderation_nonexistent_group_errors[muteMembers-info0-600-do not find this group]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_moderation.py::test_group_moderation_nonexistent_group_errors[muteMembers-info0-600-do not find this group]`
- 业务说明：A 执行群组业务操作
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证执行群组业务操作返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 268. `im_flutter_sdk/native-auto-test/tests/group/test_group_moderation.py::test_group_moderation_nonexistent_group_errors[removeWhiteList-info5-600-do not find this group]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_moderation.py::test_group_moderation_nonexistent_group_errors[removeWhiteList-info5-600-do not find this group]`
- 业务说明：A 执行群组业务操作
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证执行群组业务操作返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 269. `im_flutter_sdk/native-auto-test/tests/group/test_group_moderation.py::test_group_moderation_nonexistent_group_errors[unMuteAllMembers-info3-600-do not find this group]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_moderation.py::test_group_moderation_nonexistent_group_errors[unMuteAllMembers-info3-600-do not find this group]`
- 业务说明：A 执行群组业务操作
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证执行群组业务操作返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 270. `im_flutter_sdk/native-auto-test/tests/group/test_group_moderation.py::test_group_moderation_nonexistent_group_errors[unMuteMembers-info1-600-do not find this group]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_moderation.py::test_group_moderation_nonexistent_group_errors[unMuteMembers-info1-600-do not find this group]`
- 业务说明：A 执行群组业务操作
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证执行群组业务操作返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 271. `im_flutter_sdk/native-auto-test/tests/group/test_group_moderation.py::test_group_moderation_nonexistent_group_errors[updateGroupExt-info6-600-do not find this group]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_moderation.py::test_group_moderation_nonexistent_group_errors[updateGroupExt-info6-600-do not find this group]`
- 业务说明：A 执行群组业务操作
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证执行群组业务操作返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 272. `im_flutter_sdk/native-auto-test/tests/group/test_group_join_requests_and_invitations.py::test_group_request_to_join_public_group_nonexistent_group`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_join_requests_and_invitations.py::test_group_request_to_join_public_group_nonexistent_group`
- 业务说明：B 申请加入公开群
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备B已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：B 申请加入公开群
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：验证申请加入公开群返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 600，错误描述“do not find this group”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 273. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_member_attributes.py::test_group_set_member_attributes_empty_attributes`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_member_attributes.py::test_group_set_member_attributes_empty_attributes`
- 业务说明：测试准备：创建测试群并建立业务前置
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证执行群组业务操作返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  4. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 205，错误描述“Invalid parameter”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 274. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_member_attributes.py::test_group_set_member_attributes_nonexistent_group`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_member_attributes.py::test_group_set_member_attributes_nonexistent_group`
- 业务说明：A 执行群组业务操作
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证执行群组业务操作返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 275. `im_flutter_sdk/native-auto-test/tests/group/test_group_member_attributes.py::test_group_set_and_fetch_member_attributes_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_member_attributes.py::test_group_set_and_fetch_member_attributes_success`
- 业务说明：测试准备：创建测试群并建立业务前置
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：B 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证执行群组业务操作返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：A 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  6. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 276. `im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_member_invitation_permission_depends_on_style[add-members-private-member-admin-allowed]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_member_invitation_permission_depends_on_style[add-members-private-member-admin-allowed]`
- 业务说明：style=0 仅群主可邀请；style=1 的普通成员和管理员均可邀请
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 添加群管理员
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证 添加群管理员返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：B 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  7. 操作：验证执行群组业务操作返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  8. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 603，错误描述“invite is not allowed”。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 校验关键字段：result。
  4. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 277. `im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_member_invitation_permission_depends_on_style[add-members-private-member-normal-member-allowed]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_member_invitation_permission_depends_on_style[add-members-private-member-normal-member-allowed]`
- 业务说明：style=0 仅群主可邀请；style=1 的普通成员和管理员均可邀请
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 添加群管理员
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证 添加群管理员返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：B 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  7. 操作：验证执行群组业务操作返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  8. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 603，错误描述“invite is not allowed”。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 校验关键字段：result。
  4. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 278. `im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_member_invitation_permission_depends_on_style[add-members-private-owner-admin-denied]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_member_invitation_permission_depends_on_style[add-members-private-owner-admin-denied]`
- 业务说明：style=0 仅群主可邀请；style=1 的普通成员和管理员均可邀请
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 添加群管理员
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证 添加群管理员返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：B 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  7. 操作：验证执行群组业务操作返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  8. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 603，错误描述“invite is not allowed”。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 校验关键字段：result。
  4. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 279. `im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_member_invitation_permission_depends_on_style[add-members-private-owner-normal-member-denied]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_member_invitation_permission_depends_on_style[add-members-private-owner-normal-member-denied]`
- 业务说明：style=0 仅群主可邀请；style=1 的普通成员和管理员均可邀请
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 添加群管理员
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证 添加群管理员返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：B 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  7. 操作：验证执行群组业务操作返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  8. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 603，错误描述“invite is not allowed”。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 校验关键字段：result。
  4. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 280. `im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_member_invitation_permission_depends_on_style[inviter-user-private-member-admin-allowed]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_member_invitation_permission_depends_on_style[inviter-user-private-member-admin-allowed]`
- 业务说明：style=0 仅群主可邀请；style=1 的普通成员和管理员均可邀请
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 添加群管理员
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证 添加群管理员返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：B 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  7. 操作：验证执行群组业务操作返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  8. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 603，错误描述“invite is not allowed”。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 校验关键字段：result。
  4. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 281. `im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_member_invitation_permission_depends_on_style[inviter-user-private-member-normal-member-allowed]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_member_invitation_permission_depends_on_style[inviter-user-private-member-normal-member-allowed]`
- 业务说明：style=0 仅群主可邀请；style=1 的普通成员和管理员均可邀请
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 添加群管理员
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证 添加群管理员返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：B 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  7. 操作：验证执行群组业务操作返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  8. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 603，错误描述“invite is not allowed”。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 校验关键字段：result。
  4. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 282. `im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_member_invitation_permission_depends_on_style[inviter-user-private-owner-admin-denied]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_member_invitation_permission_depends_on_style[inviter-user-private-owner-admin-denied]`
- 业务说明：style=0 仅群主可邀请；style=1 的普通成员和管理员均可邀请
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 添加群管理员
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证 添加群管理员返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：B 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  7. 操作：验证执行群组业务操作返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  8. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 603，错误描述“invite is not allowed”。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 校验关键字段：result。
  4. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 283. `im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_member_invitation_permission_depends_on_style[inviter-user-private-owner-normal-member-denied]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_member_invitation_permission_depends_on_style[inviter-user-private-owner-normal-member-denied]`
- 业务说明：style=0 仅群主可邀请；style=1 的普通成员和管理员均可邀请
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 添加群管理员
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证 添加群管理员返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：B 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  5. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  6. 操作：等待并校验目标业务事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  7. 操作：验证执行群组业务操作返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  8. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验异常返回：错误码 603，错误描述“invite is not allowed”。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 校验关键字段：result。
  4. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 284. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_blocking.py::test_group_unblock_idempotent`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_blocking.py::test_group_unblock_idempotent`
- 业务说明：测试准备：创建测试群并建立业务前置
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 取消屏蔽群消息
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证取消屏蔽群消息返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 285. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_blocking.py::test_group_unblock_nonexistent_group`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_blocking.py::test_group_unblock_nonexistent_group`
- 业务说明：A 取消屏蔽群消息
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 取消屏蔽群消息
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证取消屏蔽群消息返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 600，错误描述“do not find this group”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 286. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_announcement.py::test_group_update_announcement_empty`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_announcement.py::test_group_update_announcement_empty`
- 业务说明：测试准备：创建测试群并建立业务前置
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 更新群公告
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证更新群公告返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：A 查询群公告
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  5. 操作：验证查询群公告返回的关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  6. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 287. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_announcement.py::test_group_update_announcement_nonexistent_group`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_announcement.py::test_group_update_announcement_nonexistent_group`
- 业务说明：A 更新群公告
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 更新群公告
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：验证更新群公告返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 600，错误描述“do not find this group”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 288. `im_flutter_sdk/native-auto-test/tests/group/test_group_remaining_api_coverage.py::test_group_update_avatar_abnormal_values[]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_remaining_api_coverage.py::test_group_update_avatar_abnormal_values[]`
- 业务说明：测试准备：创建测试群并建立业务前置
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 更新群头像
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证更新群头像返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 289. `im_flutter_sdk/native-auto-test/tests/group/test_group_remaining_api_coverage.py::test_group_update_avatar_abnormal_values[https://example.com/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa]`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_remaining_api_coverage.py::test_group_update_avatar_abnormal_values[https://example.com/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa]`
- 业务说明：测试准备：创建测试群并建立业务前置
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 更新群头像
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证更新群头像返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 290. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_metadata.py::test_group_update_description_empty`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_metadata.py::test_group_update_description_empty`
- 业务说明：测试准备：创建测试群并建立业务前置
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证执行群组业务操作返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 291. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_metadata.py::test_group_update_description_nonexistent_group`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_metadata.py::test_group_update_description_nonexistent_group`
- 业务说明：A 执行群组业务操作
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证执行群组业务操作返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 600，错误描述“do not find this group”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 292. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_metadata.py::test_group_update_description_too_long`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_metadata.py::test_group_update_description_too_long`
- 业务说明：测试准备：创建测试群并建立业务前置
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 执行群组业务操作
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：验证执行群组业务操作返回的响应 result 与关键字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 293. `im_flutter_sdk/native-auto-test/tests/group/test_group_moderation.py::test_group_update_group_ext_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_moderation.py::test_group_update_group_ext_success`
- 业务说明：测试准备：创建测试群并建立业务前置
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 更新群扩展信息
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证更新群扩展信息返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 当前测试步骤的同步响应、异步事件和最终业务状态满足代码断言。
  2. 任一关键字段、回调、列表、数量或最终状态不符时，Case 判定失败。

### 294. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_roles.py::test_group_update_owner_nonexistent_group`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_roles.py::test_group_update_owner_nonexistent_group`
- 业务说明：A 转让群主
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 转让群主
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：验证转让群主返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 600，错误描述“do not find this group”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 295. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_metadata.py::test_group_update_subject_empty`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_metadata.py::test_group_update_subject_empty`
- 业务说明：测试准备：创建测试群并建立业务前置
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 更新群名称
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证更新群名称返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 296. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_metadata.py::test_group_update_subject_nonexistent_group`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_metadata.py::test_group_update_subject_nonexistent_group`
- 业务说明：A 更新群名称
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 更新群名称
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：验证更新群名称返回的错误码与错误文案
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 600，错误描述“do not find this group”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 297. `im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_metadata.py::test_group_update_subject_too_long`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_exceptions_metadata.py::test_group_update_subject_too_long`
- 业务说明：测试准备：创建测试群并建立业务前置
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 更新群名称
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证更新群名称返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 298. `im_flutter_sdk/native-auto-test/tests/group/test_group_remaining_api_coverage.py::test_group_update_avatar_success`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_remaining_api_coverage.py::test_group_update_avatar_success`
- 业务说明：updateGroupAvatar：群主更新群头像 URL，返回群对象中 avatarUrl 为新值
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
  5. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：测试准备：创建测试群并建立业务前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：A 更新群头像
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：验证更新群头像返回的关键字段
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  4. 操作：测试后置：销毁测试群并恢复群状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 299. `im_flutter_sdk/native-auto-test/tests/group/test_group_remaining_api_coverage.py::test_group_update_avatar_empty_group_id`

- 代码：`im_flutter_sdk/native-auto-test/tests/group/test_group_remaining_api_coverage.py::test_group_update_avatar_empty_group_id`
- 业务说明：updateGroupAvatar：groupId 为空字符串时，冻结真实错误返回
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
  4. 服务端所需权限及目标对象已准备。
- 详细步骤与对应预期：
  1. 操作：A 更新群头像
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  2. 操作：验证群业务状态、事件与关键字段
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验异常返回：错误码 600，错误描述“Group ID is invalid”。
  2. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

## presence

### 1. `im_flutter_sdk/native-auto-test/tests/presence/test_presence.py::test_presence_publish_subscribe_query_unsubscribe`

- 代码：`im_flutter_sdk/native-auto-test/tests/presence/test_presence.py::test_presence_publish_subscribe_query_unsubscribe`
- 业务说明：多端拓扑：A 发布 presence（动作端）；B 订阅 A，订阅关系为账号级 → B 全部在线端查询订阅列表一致； B 取消订阅后全部端查询为空
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：测试准备：清理收发账号全部端的历史事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  2. 操作：发布在线状态 在线
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  3. 操作：确认发布请求已提交
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  4. 操作：A 全部在线端查询自己的状态均为 在线（账号级服务端状态同步）
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  5. 操作：订阅 A 的在线状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  6. 操作：确认订阅请求已提交且返回 A 当前状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  7. 操作：B 全部在线端查询订阅列表均含 A（订阅关系账号级共享）
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  8. 操作：取消订阅 A
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 2. `im_flutter_sdk/native-auto-test/tests/presence/test_presence.py::test_presence_publish_empty_desc_then_fetch`

- 代码：`im_flutter_sdk/native-auto-test/tests/presence/test_presence.py::test_presence_publish_empty_desc_then_fetch`
- 业务说明：多端拓扑：A 发布空 desc 在线状态；A 全部端查询状态 desc 为空；B 订阅后，B 全部端查询 A 状态 desc 也为空
- 类型：多设备
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 用例所需的设备拓扑、账号和在线设备集合已准备。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：测试准备：清理收发账号全部端的历史事件
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
  2. 操作：发布空 desc 的在线状态
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  3. 操作：确认发布请求已提交
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  4. 操作：A 全部在线端查询自己的状态 desc 均为空（账号级服务端状态同步）
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
  5. 操作：订阅 A 的在线状态
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  6. 操作：确认订阅请求已提交
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  7. 操作：B 全部在线端查询 A 状态 desc 均为空
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验相关事件在规定时间内到达或按用例要求不产生事件，并核对事件类型及关键数据。
  2. 校验关键字段：result。
  3. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 3. `im_flutter_sdk/native-auto-test/tests/presence/test_presence.py::test_presence_subscribe_nonexistent_user`

- 代码：`im_flutter_sdk/native-auto-test/tests/presence/test_presence.py::test_presence_subscribe_nonexistent_user`
- 业务说明：订阅不存在用户：B 对不存在用户发起 presenceSubscribe
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：订阅不存在用户并验证当前服务端返回语义
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 4. `im_flutter_sdk/native-auto-test/tests/presence/test_presence.py::test_presence_subscribe_over_100_members`

- 代码：`im_flutter_sdk/native-auto-test/tests/presence/test_presence.py::test_presence_subscribe_over_100_members`
- 业务说明：订阅超过 100 个用户：presenceSubscribe 传入超过 100 个 成员，预期返回错误
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：订阅超过数量上限的用户并验证数量错误
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 5. `im_flutter_sdk/native-auto-test/tests/presence/test_presence.py::test_presence_subscribe_expiry_over_30_days`

- 代码：`im_flutter_sdk/native-auto-test/tests/presence/test_presence.py::test_presence_subscribe_expiry_over_30_days`
- 业务说明：订阅存在用户但过期时间大于 30 天：B 订阅 A，expiry 设为超过 30 天，预期返回错误
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：A 发布在线状态作为订阅前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：B 使用超过 30 天的有效期订阅并验证边界错误
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 6. `im_flutter_sdk/native-auto-test/tests/presence/test_presence.py::test_fetch_subscribed_members_invalid_pagination`

- 代码：`im_flutter_sdk/native-auto-test/tests/presence/test_presence.py::test_fetch_subscribed_members_invalid_pagination`
- 业务说明：非法分页参数：pageNum=0 或 pageSize=0，预期返回错误
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：使用 pageNum=0 查询订阅列表并验证边界语义
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  2. 操作：使用 pageSize=0 查询订阅列表并验证边界错误
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 7. `im_flutter_sdk/native-auto-test/tests/presence/test_presence.py::test_fetch_subscribed_members_pagination_page_size_one`

- 代码：`im_flutter_sdk/native-auto-test/tests/presence/test_presence.py::test_fetch_subscribed_members_pagination_page_size_one`
- 业务说明：分页 pageSize=1：第 1 页 1 条，第 2 页 0 条
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：创建在线状态并建立订阅前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：按 pageSize=1 查询第一页并验证包含 A
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  3. 操作：按 pageSize=1 查询第二页并验证为空
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 8. `im_flutter_sdk/native-auto-test/tests/presence/test_presence.py::test_fetch_subscribed_members_pagination`

- 代码：`im_flutter_sdk/native-auto-test/tests/presence/test_presence.py::test_fetch_subscribed_members_pagination`
- 业务说明：分页查询订阅列表：B 订阅 A 后，第 1 页有数据，第 2 页为空
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：创建在线状态并建立订阅前置
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
  2. 操作：查询第一页订阅列表并验证包含 A
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  3. 操作：查询第二页订阅列表并验证为空
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 9. `im_flutter_sdk/native-auto-test/tests/presence/test_presence.py::test_presence_unsubscribe_over_100_members`

- 代码：`im_flutter_sdk/native-auto-test/tests/presence/test_presence.py::test_presence_unsubscribe_over_100_members`
- 业务说明：取消订阅超过 100 个用户：presenceUnsubscribe 传入超过 100 个 成员，预期返回错误
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备B已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：取消超过数量上限的订阅并验证数量错误
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 10. `im_flutter_sdk/native-auto-test/tests/presence/test_presence.py::test_presence_publish_128k_desc`

- 代码：`im_flutter_sdk/native-auto-test/tests/presence/test_presence.py::test_presence_publish_128k_desc`
- 业务说明：A 发布 128KB 大小 desc 的在线状态
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A、设备B已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：A 发布超长在线状态描述并验证长度错误
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

## push

### 1. `im_flutter_sdk/native-auto-test/tests/push/test_push_remaining_api_coverage.py::test_push_fetch_configs_update_nickname_and_style`

- 代码：`im_flutter_sdk/native-auto-test/tests/push/test_push_remaining_api_coverage.py::test_push_fetch_configs_update_nickname_and_style`
- 业务说明：fetchPushConfigsFromServer / updatePushNickname / updatePushDisplayStyle：拉取推送配置并更新昵称和展示样式
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：查询服务端推送配置并验证返回结构
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  2. 操作：更新推送昵称并验证配置更新结果
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
  3. 操作：更新推送展示样式并验证配置更新结果
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：to、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 2. `im_flutter_sdk/native-auto-test/tests/push/test_push_remaining_api_coverage.py::test_push_conversation_silent_mode_flow`

- 代码：`im_flutter_sdk/native-auto-test/tests/push/test_push_remaining_api_coverage.py::test_push_conversation_silent_mode_flow`
- 业务说明：set/获取/删除会话列表ilentMode：对单聊会话设置、查询、移除离线推送设置
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：设置单聊会话免打扰并验证成功
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  2. 操作：查询单聊会话免打扰设置并验证配置
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  3. 操作：批量查询会话免打扰设置并验证目标会话
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：移除单聊会话免打扰设置并验证成功
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：convId、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 3. `im_flutter_sdk/native-auto-test/tests/push/test_push_remaining_api_coverage.py::test_push_preferred_language_and_template`

- 代码：`im_flutter_sdk/native-auto-test/tests/push/test_push_remaining_api_coverage.py::test_push_preferred_language_and_template`
- 业务说明：set/fetchPreferredNotification语言 与 set/getPushTemplate：设置并查询推送语言和模板名称
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：设置首选通知语言并验证保存成功
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  2. 操作：查询首选通知语言并验证为英语
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  3. 操作：设置推送模板并验证保存成功
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  4. 操作：查询推送模板并验证模板名称
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 4. `im_flutter_sdk/native-auto-test/tests/push/test_push_remaining_api_coverage.py::test_push_global_silent_mode_flow`

- 代码：`im_flutter_sdk/native-auto-test/tests/push/test_push_remaining_api_coverage.py::test_push_global_silent_mode_flow`
- 业务说明：setSilentModeForAll / fetchSilentModeForAll：设置全局离线推送提醒类型，并拉取全局设置
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：设置全局离线推送提醒类型并验证成功
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  2. 操作：查询全局离线推送设置并验证配置字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：convId、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 5. `im_flutter_sdk/native-auto-test/tests/push/test_push_remaining_api_coverage.py::test_push_sync_conversations_silent_mode_current_environment`

- 代码：`im_flutter_sdk/native-auto-test/tests/push/test_push_remaining_api_coverage.py::test_push_sync_conversations_silent_mode_current_environment`
- 业务说明：syncSilentModels：同步所有会话免打扰信息，冻结当前模拟器返回语义
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：同步所有会话免打扰设置并验证返回结构
     - 预期：在规定超时时间内收到对应结果或事件，并核对关键 ID、内容、状态和来源信息。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 6. `im_flutter_sdk/native-auto-test/tests/push/test_push_remaining_api_coverage.py::test_push_vendor_token_update_current_environment[bindDeviceToken-info2-None]`

- 代码：`im_flutter_sdk/native-auto-test/tests/push/test_push_remaining_api_coverage.py::test_push_vendor_token_update_current_environment[bindDeviceToken-info2-None]`
- 业务说明：update*PushToken / bindDeviceToken：使用测试 token 调用，冻结当前模拟器环境下的真实返回语义
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：更新厂商推送令牌并验证当前环境返回语义
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 7. `im_flutter_sdk/native-auto-test/tests/push/test_push_remaining_api_coverage.py::test_push_vendor_token_update_current_environment[updateFCMPushToken-info1-expected_result1]`

- 代码：`im_flutter_sdk/native-auto-test/tests/push/test_push_remaining_api_coverage.py::test_push_vendor_token_update_current_environment[updateFCMPushToken-info1-expected_result1]`
- 业务说明：update*PushToken / bindDeviceToken：使用测试 token 调用，冻结当前模拟器环境下的真实返回语义
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：更新厂商推送令牌并验证当前环境返回语义
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 8. `im_flutter_sdk/native-auto-test/tests/push/test_push_remaining_api_coverage.py::test_push_vendor_token_update_current_environment[updateHMSPushToken-info0-hms-token-api-coverage]`

- 代码：`im_flutter_sdk/native-auto-test/tests/push/test_push_remaining_api_coverage.py::test_push_vendor_token_update_current_environment[updateHMSPushToken-info0-hms-token-api-coverage]`
- 业务说明：update*PushToken / bindDeviceToken：使用测试 token 调用，冻结当前模拟器环境下的真实返回语义
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：更新厂商推送令牌并验证当前环境返回语义
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 9. `im_flutter_sdk/native-auto-test/tests/push/test_push_remaining_api_coverage.py::test_push_apns_token_update_android_missing_plugin`

- 代码：`im_flutter_sdk/native-auto-test/tests/push/test_push_remaining_api_coverage.py::test_push_apns_token_update_android_missing_plugin`
- 业务说明：updateAPNsPushToken：仅在 Android 验证 缺失Plugin，iOS 不执行该平台缺口用例
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：调用 Android 不适用的 APNs 令牌接口并记录平台缺口
     - 预期：步骤结果符合当前代码断言，并保持业务状态正确。
- 关键断言：
  1. 当前测试步骤的同步响应、异步事件和最终业务状态满足代码断言。
  2. 任一关键字段、回调、列表、数量或最终状态不符时，Case 判定失败。

## user_info

### 1. `im_flutter_sdk/native-auto-test/tests/user_info/test_user_info.py::test_user_info_update_then_fetch_user_info_by_id`

- 代码：`im_flutter_sdk/native-auto-test/tests/user_info/test_user_info.py::test_user_info_update_then_fetch_user_info_by_id`
- 业务说明：先 updateOwnUserInfo，再用 fetchUserInfoById 拉当前用户（全量字段，与 fetchOwnInfo 语义等价）
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：设置用于查询验证的用户资料
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  2. 操作：按用户 ID 查询资料并验证全部字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 2. `im_flutter_sdk/native-auto-test/tests/user_info/test_user_info.py::test_user_info_update_then_fetch_user_info_by_id_with_type`

- 代码：`im_flutter_sdk/native-auto-test/tests/user_info/test_user_info.py::test_user_info_update_then_fetch_user_info_by_id_with_type`
- 业务说明：先 updateOwnUserInfo，再用 fetchUserInfoByIdWithType 按类型拉取（仅 nick + sign；按类型返回时未必含 mail）
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：设置按类型查询所需的用户资料
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  2. 操作：按资料类型查询用户并验证昵称和签名
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 3. `im_flutter_sdk/native-auto-test/tests/user_info/test_user_info.py::test_user_info_update_then_all_fetch_paths_in_one_flow`

- 代码：`im_flutter_sdk/native-auto-test/tests/user_info/test_user_info.py::test_user_info_update_then_all_fetch_paths_in_one_flow`
- 业务说明：一次更新后：先 fetchUserInfoById（全量），再 fetchUserInfoByIdWithType（nick+sign），字段一致
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：设置统一的用户资料用于多接口查询
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  2. 操作：按用户 ID 查询全量资料并验证字段
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  3. 操作：按资料类型查询并验证部分字段一致
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 4. `im_flutter_sdk/native-auto-test/tests/user_info/test_user_info.py::test_user_info_update_then_fetch_own_info`

- 代码：`im_flutter_sdk/native-auto-test/tests/user_info/test_user_info.py::test_user_info_update_then_fetch_own_info`
- 业务说明：fetchOwnInfo：更新当前用户属性后拉取自己的用户属性
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：设置用于查询的当前用户资料
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  2. 操作：查询当前用户资料并验证属性
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 5. `im_flutter_sdk/native-auto-test/tests/user_info/test_user_info.py::test_user_info_fetch_by_id_normal`

- 代码：`im_flutter_sdk/native-auto-test/tests/user_info/test_user_info.py::test_user_info_fetch_by_id_normal`
- 业务说明：fetchUserInfoById：获取指定用户（当前用户与另一用户）的属性
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：查询两个用户的资料并验证用户标识
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 6. `im_flutter_sdk/native-auto-test/tests/user_info/test_user_info.py::test_user_info_fetch_by_id_user_ids_over_100`

- 代码：`im_flutter_sdk/native-auto-test/tests/user_info/test_user_info.py::test_user_info_fetch_by_id_user_ids_over_100`
- 业务说明：fetchUserInfoById：userIds 超过 100 个，预期失败
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：使用超过上限的用户列表查询资料并验证数量错误
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 900，错误描述“The maximum number of user IDs is exceeded.”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 7. `im_flutter_sdk/native-auto-test/tests/user_info/test_user_info.py::test_user_info_fetch_by_id_empty_user_ids`

- 代码：`im_flutter_sdk/native-auto-test/tests/user_info/test_user_info.py::test_user_info_fetch_by_id_empty_user_ids`
- 业务说明：fetchUserInfoById：userIds 为空列表
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：使用空用户列表查询资料并验证参数错误
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 8. `im_flutter_sdk/native-auto-test/tests/user_info/test_user_info.py::test_user_info_fetch_by_id_with_type_normal`

- 代码：`im_flutter_sdk/native-auto-test/tests/user_info/test_user_info.py::test_user_info_fetch_by_id_with_type_normal`
- 业务说明：fetchUserInfoByIdWithType：按属性类型拉取指定用户（nick + sign）
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：按昵称和签名类型查询用户资料
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 9. `im_flutter_sdk/native-auto-test/tests/user_info/test_user_info.py::test_user_info_update_own_nickname_length_over_64`

- 代码：`im_flutter_sdk/native-auto-test/tests/user_info/test_user_info.py::test_user_info_update_own_nickname_length_over_64`
- 业务说明：updateOwnUserInfo：昵称超过 2k长度，预期失败
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：提交超长昵称并验证长度错误
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验异常返回：错误码 901，错误描述“User info exceeds the data length”。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 10. `im_flutter_sdk/native-auto-test/tests/user_info/test_user_info.py::test_user_info_update_own_nickname_empty`

- 代码：`im_flutter_sdk/native-auto-test/tests/user_info/test_user_info.py::test_user_info_update_own_nickname_empty`
- 业务说明：updateOwnUserInfo：昵称为空
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：提交空昵称并验证空值处理结果
     - 预期：返回当前代码断言的错误或空结果，业务状态不被错误修改，且不产生意外事件。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 11. `im_flutter_sdk/native-auto-test/tests/user_info/test_user_info.py::test_user_info_update_own_set_and_modify`

- 代码：`im_flutter_sdk/native-auto-test/tests/user_info/test_user_info.py::test_user_info_update_own_set_and_modify`
- 业务说明：updateOwnUserInfo：先设置再修改当前用户属性
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：设置当前用户昵称、签名和性别并验证结果
     - 预期：返回结构、关键字段、列表内容或数量符合当前代码断言。
  2. 操作：修改当前用户昵称和签名并验证更新结果
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。

### 12. `im_flutter_sdk/native-auto-test/tests/user_info/test_user_info.py::test_user_info_update_own_with_type_nickname`

- 代码：`im_flutter_sdk/native-auto-test/tests/user_info/test_user_info.py::test_user_info_update_own_with_type_nickname`
- 业务说明：updateOwnUserInfoWithType：按类型更新昵称（0 = NICKNAME）
- 类型：普通
- 状态/版本说明：普通
- 前置条件：
  1. WebSocket 测试桥接和被测 Flutter App 已连接，pytest fixtures 可正常工作。
  2. 设备A已启动并登录，账号状态可用。
  3. 用例涉及的用户关系、会话或群组基础数据已准备。
  4. 接口响应与事件断言工具已初始化。
- 详细步骤与对应预期：
  1. 操作：按昵称类型更新当前用户昵称并验证结果
     - 预期：操作成功，返回结果和后续业务状态符合当前代码断言。
- 关键断言：
  1. 校验关键字段：from、result。
  2. 任一固定错误码、关键 ID、回调类型、列表内容、数量或最终状态不符时，Case 判定失败。
