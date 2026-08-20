# 现有自动化 Case 说明

本说明根据 `native-auto-test/tests/` 下的 pytest Case 汇总生成，共 803 条，覆盖模块：Chat、ChatRoom、Client、Contact、Group、Phase1、Presence、Push、UserInfo。

## 分类

- 普通：单端或普通业务链路。
- 多设备：验证在线设备集合之间的消息或状态同步。
- 离线：验证设备离线、重新上线后的补同步或本地数据。

## 状态说明

- 正常执行：当前 Case 按现有环境执行。
- 5.0 不适用：5.0 已删除或改变了原 API 语义，不计为失败。
- 平台不适用：例如 Android 模拟器不具备 APNs 能力。
- 待补齐：API 能力存在，但当前桥接或集成端未实现。

## 汇总

- Case 总数：803
- 正常执行：702
- 5.0 不适用：57
- 平台不适用：2
- 待补齐：13

## Chat

### 1. 按类型发送消息(视频)：视频消息发送成功、发送账号副端同步、接收账号全端接收

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 按类型发送消息(视频)：视频消息发送成功、发送账号副端同步、接收账号全端接收。
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_send_with_type.py::test_send_message_with_type_video

### 2. 按类型发送消息(图片)：图片消息发送成功、发送账号副端同步、接收账号全端接收

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 按类型发送消息(图片)：图片消息发送成功、发送账号副端同步、接收账号全端接收。
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_send_with_type.py::test_send_message_with_type_image

### 3. 按类型发送消息(文件)：文件消息发送成功、发送账号副端同步、接收账号全端接收

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 按类型发送消息(文件)：文件消息发送成功、发送账号副端同步、接收账号全端接收。
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_send_with_type.py::test_send_message_with_type_file

### 4. 按类型发送消息(cmd)：发送 CMD 消息，接收账号全部在线端收到 CMD 消息接收回调 且不混入普通消息回调

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 测试准备：清理收发账号全部端的历史事件
  2. 发送 CMD 消息
  3. 确认发送请求已提交
  4. 验证 CMD 发送成功（消息发送成功回调）并提取服务器消息 ID
  5. 接收账号端 收到 CMD 回调（CMD 消息接收回调）
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatManager.sendMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_send_with_type.py::test_send_message_with_type_cmd_received_by_cmd_callback

### 5. 按类型发送消息(txt) 带目标语言：发送成功、全端同步并携带 翻译结果

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 按类型发送消息(txt) 带目标语言：发送成功、全端同步并携带 翻译结果。
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_send_with_type.py::test_send_message_with_type_text_with_languages

### 6. 按类型发送消息(txt) 基本文本：发送账号副端同步、接收账号全端接收并落库

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 按类型发送消息(txt) 基本文本：发送账号副端同步、接收账号全端接收并落库。
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_send_with_type.py::test_send_message_with_type_text_basic

### 7. 场景：发送账号向接收账号发送文本消息后撤回

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 动作发送端 发送待撤回的文本消息
  2. 发送端等待 消息发送成功回调 并提取消息 ID
  3. 发送账号副端 收到本账号消息同步（消息接收回调）
  4. 发送账号副端 可从本地消息库查询该消息
  5. 接收端 验证原始文本消息 消息 ID=
  6. 动作发送端撤回消息 消息 ID=
  7. 发送账号副端 验证撤回信息 消息撤回回调 消息 ID=
  8. 接收端 验证撤回信息 消息撤回回调 消息 ID=
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatManager.sendMessage、ChatManager.getMessage、ChatManager.recallMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_crud.py::test_chat_translate_message_recalled_message

### 8. 场景：A 发送自定义消息并修改内容，B 的全部在线端验证内容变更事件；同时验证 A 副端同步原消息

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 向接收账号发送自定义消息
  2. 等待消息发送成功回调（消息发送成功回调）
  3. 取得服务端消息 ID
  4. 接收端 收到原始自定义消息（消息接收回调）
  5. 修改自定义消息内容
  6. 接收端 收到内容更新通知（消息内容变更回调）
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatManager.sendMessage、ChatManager.modifyMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_s4_message_content_changed.py::test_chat_modify_custom_message_content_changed_event

### 9. 撤回消息：发送方撤回已送达单聊消息，接收账号全部在线端收到 消息撤回回调 并携带撤回消息 ID

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 发送待撤回文本消息
  2. 撤回该消息（撤回消息）
  3. 接收账号端 收到撤回通知（消息撤回回调）
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatManager.recallMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_manager_remaining_api_coverage.py::test_chat_manager_recall_message_receiver_recalled_info_event

### 10. 从本地数据库搜索聊天消息 成功

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 从本地数据库搜索聊天消息 成功
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatManager.sendMessage、ChatManager.searchChatMsgFromDB。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_crud.py::test_chat_search_chat_msg_from_db_success

### 11. 单聊消息与 消息 Reaction 在收发账号多端同步，并校验各在线端的变更回调

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 测试准备：清理动作账号和接收账号的历史事件
  2. 向接收账号发送待 消息 Reaction 的文本消息
  3. 确认文本消息已提交
  4. 等待 的发送成功回调（消息发送成功回调）
  5. 确认文本消息发送成功
  6. 发送账号端 同步原消息（消息接收回调）
  7. 确认发送账号端 已同步原消息
  8. 发送账号端 从本地消息库查询原消息
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatManager.sendMessage、ChatManager.getMessage、ChatManager.addReaction。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_reaction_fetch.py::test_chat_reaction_change_event_received_by_sender

### 12. 单聊消息在发送账号多端同步、接收账号全端接收并完成本地落库校验

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 测试准备：清理发送账号和接收账号全部端的历史事件
  2. 发送账号动作端 向目标账号发送文本消息
  3. 确认发送请求已提交
  4. 发送端验证 消息发送成功回调 并提取服务端消息 ID
  5. 发送账号副端 收到本账号消息同步（消息接收回调）
  6. 发送账号副端 可从本地消息库查询该消息
  7. 接收端 验证 消息接收回调: 消息 ID=
  8. 接收端 可从本地消息库查询该消息
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatManager.sendMessage、ChatManager.getMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_crud.py::test_chat_send_and_received

### 13. 发送 拒绝 发送端不匹配

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 发送 拒绝 发送端不匹配
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatManager.sendMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_text_boundaries_and_location_delivery.py::test_chat_send_rejects_mismatched_from

### 14. 发送 文件/图片/视频 附件：发送账号副端同步、接收账号全部在线端接收，主接收端执行公开下载 API

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 发送 文件/图片/视频 附件：发送账号副端同步、接收账号全部在线端接收，主接收端执行公开下载 API。
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_message_callback_and_combine.py::test_attachment_messages_send_receive_and_public_download_methods

### 15. 发送 HEIC 格式图片，验证 SDK 能正常上传并投递到接收账号全部在线端

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 发送 HEIC 格式图片，验证 SDK 能正常上传并投递到接收账号全部在线端。
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_send_with_type.py::test_send_message_with_type_image_heic

### 16. 发送带 webhookEnv 的文本消息：发送账号副端同步、接收账号全部在线端接收（参数：默认-默认）

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 发送带 webhookEnv 的文本消息：发送账号副端同步、接收账号全部在线端接收。
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_message_callback_and_combine.py::test_send_text_message_with_webhook_env[default-default]

### 17. 发送方下载自己发送的 图片/视频 附件（发送账号副端同步 + 接收账号全端收由 _发送_with_type 内部完成）

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 发送方下载自己发送的 图片/视频 附件（发送账号副端同步 + 接收账号全端收由 _发送_with_type 内部完成）。
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatManager.downloadAttachment。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_attachment_download_and_history_boundaries.py::test_chat_sender_downloads_image_and_video_attachment

### 18. 非发送者（接收账号端）尝试修改消息被拒绝（无权限）；发送投递到接收账号全部在线端

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 发送待修改文本消息
  2. 接收账号端 接收该消息
  3. 非发送者 尝试修改消息（应无权限）
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatManager.modifyMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_message_modification_matrix.py::test_chat_non_sender_cannot_modify_message

### 19. 合并 消息：发送账号副端同步、接收账号全部在线端接收，主接收端执行 inner 附件下载

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 合并 消息：发送账号副端同步、接收账号全部在线端接收，主接收端执行 inner 附件下载。
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatManager.downloadAndParseCombineMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_message_callback_and_combine.py::test_combine_forward_send_receive_and_inner_attachment_download

### 20. 合并 转发媒体：发送账号副端同步、接收账号全部在线端接收，主接收端执行 inner 附件下载

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 合并 转发媒体：发送账号副端同步、接收账号全部在线端接收，主接收端执行 inner 附件下载。
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatManager.downloadAndParseCombineMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_message_callback_and_combine.py::test_combine_forward_media_inner_attachment_download

### 21. 会话已读回执：接收端回执会话已读（5.0 清未读数，两端均不发 会话已读回调 事件）

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 接收账号动作端 回执会话已读（会话已读回执）
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatManager.ackConversationRead。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_s3_non_message_ops.py::test_chat_ack_conversation_read_success_with_event

### 22. 获取 消息 Reaction 详情 过大 pageSize（1000）；应返回稳定结果结构

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 获取 消息 Reaction 详情 过大 pageSize（1000）；应返回稳定结果结构。
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatManager.fetchReactionDetail。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_reaction_fetch.py::test_chat_fetch_reaction_detail_oversize_page_size

### 23. 缺失 语音 消息 发送 接收

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 缺失 语音 消息 发送 接收
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_message_types_and_delivery.py::test_chat_missing_voice_message_send_receive

### 24. 删除 消息 Reaction 删除不存在的 消息 Reaction；接收账号全部在线端收到消息投递

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 发送消息并等待接收端接收
  2. 删除不存在的 消息 Reaction
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatManager.removeReaction。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_reaction_fetch.py::test_chat_remove_reaction_not_exists_reaction

### 25. 删除 消息 Reaction 使用无效 消息 ID；按不存在语义冻结

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 删除 消息 Reaction 使用无效 消息 ID；按不存在语义冻结。
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatManager.removeReaction。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_reaction_fetch.py::test_chat_remove_reaction_invalid_msg_id

### 26. 添加 消息 Reaction 无效 id 响应

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 添加 消息 Reaction 无效 id 响应
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatManager.addReaction。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_crud.py::test_chat_add_reaction_invalid_id_response

### 27. 添加 消息 Reaction 重复添加同一 消息 Reaction；接收账号全部在线端收到 消息 Reaction 变更事件

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 发送消息并等待接收端接收
  2. 添加 消息 Reaction（首次）
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatManager.addReaction。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_reaction_fetch.py::test_chat_add_reaction_duplicate_reaction

### 28. 位置 消息 送达回执

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 位置 消息 送达回执
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：Client.updateDeliveryAckSetting。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_text_boundaries_and_location_delivery.py::test_chat_location_message_delivery_ack

### 29. 文本 内容边界（参数：空）

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 文本 内容边界
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_text_boundaries_and_location_delivery.py::test_chat_text_content_boundaries[empty]

### 30. 文本 内容边界（参数：长度-250）

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 文本 内容边界
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_text_boundaries_and_location_delivery.py::test_chat_text_content_boundaries[length-250]

### 31. 文本 内容边界（参数：special-characters）

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 文本 内容边界
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_text_boundaries_and_location_delivery.py::test_chat_text_content_boundaries[special-characters]

### 32. 文本消息在收发账号多端同步后，由发送动作端请求翻译并校验返回消息

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 查询待翻译消息
  2. 请求将消息翻译为简体中文
  3. 确认翻译接口返回当前文本消息
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatManager.getMessage、ChatManager.translateMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_crud.py::test_chat_translate_message_basic

### 33. 下载 附件 无效 id 响应

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：跳过：原生缺陷：无效 msgId 下载原生 NPE（getMessage=null → 原生无校验 NPE；官方应 400/500）。传参已修正为完整 message 对象，等原生补校验后启用
- 源码：native-auto-test/tests/chat/test_chat_crud.py::test_chat_download_attachment_invalid_id_response

### 34. 下载 附件 用于 文本 消息

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 下载 附件 用于 文本 消息
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatManager.downloadAttachment。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_attachment_download_and_history_boundaries.py::test_chat_download_attachment_for_text_message

### 35. 消息多端同步后，验证发送动作端提交空 消息 Reaction 返回明确业务错误

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 为消息提交空 消息 Reaction
  2. 确认空 消息 Reaction 被拒绝且错误码正确
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatManager.addReaction。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_crud.py::test_chat_add_reaction_empty_reaction_response

### 36. 消息已读回执 使用无效 消息 ID；按不存在语义冻结

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 消息已读回执 使用无效 消息 ID；按不存在语义冻结。
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatManager.ackMessageRead。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_ack_read_strict.py::test_chat_ack_message_read_invalid_msg_id

### 37. 消息已读回执 正常链路：发送消息（需要已读回执）后接收账号全端接收，接收端回执并验证读回执事件

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 发送标记已读回执的文本消息
  2. 验证发送成功（消息发送成功回调）
  3. 接收账号动作端 回执已读（消息已读回执）
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatManager.sendMessage、ChatManager.ackMessageRead。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_ack_read_strict.py::test_chat_ack_message_read_success_with_event

### 38. 修改 媒体 内容 应被拒绝（参数：视频）

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 修改 媒体 内容 应被拒绝
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatManager.modifyMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_message_modification_matrix.py::test_chat_modify_media_body_is_rejected[video]

### 39. 修改 媒体 内容 应被拒绝（参数：图片）

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 修改 媒体 内容 应被拒绝
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatManager.modifyMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_message_modification_matrix.py::test_chat_modify_media_body_is_rejected[image]

### 40. 修改 媒体 内容 应被拒绝（参数：语音）

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 修改 媒体 内容 应被拒绝
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatManager.modifyMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_message_modification_matrix.py::test_chat_modify_media_body_is_rejected[voice]

### 41. 修改 媒体 属性（参数：视频）

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 修改 媒体 属性
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatManager.modifyMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_message_modification_matrix.py::test_chat_modify_media_attributes[video]

### 42. 修改 媒体 属性（参数：图片）

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 修改 媒体 属性
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatManager.modifyMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_message_modification_matrix.py::test_chat_modify_media_attributes[image]

### 43. 修改 媒体 属性（参数：语音）

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 修改 媒体 属性
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatManager.modifyMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_message_modification_matrix.py::test_chat_modify_media_attributes[voice]

### 44. 修改 消息 无效 id 响应

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 修改 消息 无效 id 响应
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatManager.modifyMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_crud.py::test_chat_modify_message_invalid_id_response

### 45. A 发送并撤回消息：验证 B 全部在线端收到撤回通知（消息撤回回调），pin 撤回消息报错

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 清理发送与接收账号全部端历史事件
  2. 发送文本消息
  3. 撤回消息
  4. B 全部在线端收到撤回通知（消息撤回回调）
  5. pin 已撤回消息应报错
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatManager.recallMessage、ChatManager.pinMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_message_pin_boundaries.py::test_chat_pin_recalled_message

### 46. A 发送位置消息，验证 A 副端同步以及 B 全部在线端接收相同消息

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 清理发送账号和接收账号全部端的历史事件
  2. 向接收账号发送位置消息
  3. 等待 的消息发送成功回调（消息发送成功回调）
  4. 确认位置消息已提交
  5. 确认位置消息发送成功
  6. 接收端 收到位置消息（消息接收回调）
  7. 确认接收端 收到当前位置消息
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatManager.sendMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_message_types_and_delivery.py::test_chat_missing_location_message_send_receive

### 47. A 发送文本，B 的全部在线端接收并发送已读回执；验证 A 主副端已读回调和本地状态同步

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 清理发送账号和接收账号全部端的历史事件
  2. 向接收账号发送待已读文本消息
  3. 等待 的消息发送成功回调（消息发送成功回调）
  4. 确认待已读消息已提交
  5. 发送账号副端 收到待已读消息同步（消息接收回调）
  6. 发送账号副端 可从本地消息库查询待已读消息
  7. 接收端 收到待已读消息（消息接收回调）
  8. 确认接收端 收到当前消息
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatManager.sendMessage、ChatManager.getMessage、ChatManager.ackMessageRead。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_crud.py::test_chat_ack_message_read_success

### 48. A 发送自定义消息，验证 A 副端同步以及 B 全部在线端接收相同消息

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 清理发送账号和接收账号全部端的历史事件
  2. 向接收账号发送自定义消息
  3. 等待 的消息发送成功回调（消息发送成功回调）
  4. 确认自定义消息已提交
  5. 确认自定义消息发送成功
  6. 接收端 收到自定义消息（消息接收回调）
  7. 确认接收端 收到当前自定义消息
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatManager.sendMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_message_types_and_delivery.py::test_chat_missing_custom_message_send_receive

### 49. pin 消息 空 id

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. pin 消息 空 id
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatManager.pinMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_message_pin_boundaries.py::test_chat_pin_message_empty_id

### 50. pin消息/unpin消息/获取置顶消息：发送消息后置顶、拉取置顶列表、取消置顶并确认列表清空

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. pin消息/unpin消息/获取置顶消息：发送消息后置顶、拉取置顶列表、取消置顶并确认列表清空。
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatManager.pinMessage、ChatManager.fetchPinnedMessages、ChatManager.unpinMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_manager_remaining_api_coverage.py::test_chat_manager_pin_unpin_and_fetch_pinned_messages

### 51. 带 target语言 的文本在 B 离线期间发送，重登后保留真实翻译结果

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 带 target语言 的文本在 B 离线期间发送，重登后保留真实翻译结果。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_extended_delivery.py::test_chat_offline_text_automatic_translation_after_recipient_login

### 52. 好友 B 离线时 A 发普通 CMD；B 登录后通过 CMD 专用事件接收

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 好友 B 离线时 A 发普通 CMD；B 登录后通过 CMD 专用事件接收。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_delivery.py::test_chat_offline_cmd_message_received_after_login

### 53. 好友 B 离线时 A 发位置消息；B 重登收到完整位置业务字段

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 好友 B 离线时 A 发位置消息；B 重登收到完整位置业务字段。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_delivery.py::test_chat_offline_location_message_received_after_login

### 54. 好友 B 离线时 A 发文本；B 登录后收到同一真实消息

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 好友 B 离线时 A 发文本；B 登录后收到同一真实消息。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_delivery.py::test_chat_offline_text_message_received_after_login

### 55. 好友 B 离线时 A 发自定义消息；B 重登收到事件名和参数

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 好友 B 离线时 A 发自定义消息；B 重登收到事件名和参数。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_delivery.py::test_chat_offline_custom_message_received_after_login

### 56. 好友 B 离线时 A 转发两条真实源消息；B 重登收到合并消息

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 好友 B 离线时 A 转发两条真实源消息；B 重登收到合并消息。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_delivery.py::test_chat_offline_combine_message_received_after_login

### 57. 好友 B 离线时接收 文件/图片/视频/语音，并保留媒体核心字段（参数：视频）

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 好友 B 离线时接收 文件/图片/视频/语音，并保留媒体核心字段。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_delivery.py::test_chat_offline_media_message_received_after_login[video]

### 58. 好友 B 离线时接收 文件/图片/视频/语音，并保留媒体核心字段（参数：图片）

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 好友 B 离线时接收 文件/图片/视频/语音，并保留媒体核心字段。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_delivery.py::test_chat_offline_media_message_received_after_login[image]

### 59. 好友 B 离线时接收 文件/图片/视频/语音，并保留媒体核心字段（参数：文件）

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 好友 B 离线时接收 文件/图片/视频/语音，并保留媒体核心字段。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_delivery.py::test_chat_offline_media_message_received_after_login[file]

### 60. 好友 B 离线时接收 文件/图片/视频/语音，并保留媒体核心字段（参数：语音）

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 好友 B 离线时接收 文件/图片/视频/语音，并保留媒体核心字段。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_delivery.py::test_chat_offline_media_message_received_after_login[voice]

### 61. 消息已有 消息 Reaction，A 离线期间 B 移除；A 重登收到移除事件

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 消息已有 消息 Reaction，A 离线期间 B 移除；A 重登收到移除事件。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：ChatManager.addReaction、ChatManager.removeReaction、ChatManager.fetchReactionList。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_operations.py::test_chat_offline_sender_receives_reaction_remove_after_relogin

### 62. 消息已置顶，B 离线期间 A 取消置顶；B 重登收到取消事件

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 消息已置顶，B 离线期间 A 取消置顶；B 重登收到取消事件。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：ChatManager.pinMessage、ChatManager.unpinMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_operations.py::test_chat_offline_recipient_receives_message_unpin_after_relogin

### 63. 真实源消息组成 合并；B 离线重登接收后 A 才收到送达回执（源消息与 合并 均需标记 需要已读回执）

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 真实源消息组成 合并；B 离线重登接收后 A 才收到送达回执（源消息与 合并 均需标记 需要已读回执）。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_extended_delivery.py::test_chat_offline_combine_delivery_ack_after_recipient_login

### 64. A 离线期间 B 回执单条已读；A 重登收到目标 已读回执回调

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. A 离线期间 B 回执单条已读；A 重登收到目标 已读回执回调。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：ChatManager.ackMessageRead。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_operations.py::test_chat_offline_sender_receives_message_read_after_relogin

### 65. A 离线期间 B 回执会话已读；A 重登只接受 会话已读回调

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。原测试目标：A 离线期间 B 回执会话已读；A 重登只接受 onConversationRead。
- 状态/版本说明：5.0 不适用：5.0 会话已读语义废除：ackConversationRead → asyncClearConversationUnreadMessageCount 仅本地清未读、不再向对方发已读回执（onConversationRead 不触发，两端一致）
- 源码：native-auto-test/tests/chat/test_chat_offline_message_operations.py::test_chat_offline_sender_receives_conversation_read_after_relogin

### 66. A 离线期间 B 添加 消息 Reaction；A 重登收到添加事件和最终聚合状态

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. A 离线期间 B 添加 消息 Reaction；A 重登收到添加事件和最终聚合状态。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：ChatManager.addReaction、ChatManager.fetchReactionList。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_operations.py::test_chat_offline_sender_receives_reaction_add_after_relogin

### 67. A 离线期间 B 已读 合并；A 重登收到同一 消息 ID 的已读回执

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. A 离线期间 B 已读 合并；A 重登收到同一 消息 ID 的已读回执。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：ChatManager.ackMessageRead。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_combine_message_read_after_sender_relogin

### 68. A 离线期间 B 已读类型消息；A 重登收到同一 消息 ID 的已读回执（参数：视频）

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. A 离线期间 B 已读类型消息；A 重登收到同一 消息 ID 的已读回执。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：ChatManager.ackMessageRead。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_typed_message_read_after_sender_relogin[video]

### 69. A 离线期间 B 已读类型消息；A 重登收到同一 消息 ID 的已读回执（参数：图片）

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. A 离线期间 B 已读类型消息；A 重登收到同一 消息 ID 的已读回执。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：ChatManager.ackMessageRead。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_typed_message_read_after_sender_relogin[image]

### 70. A 离线期间 B 已读类型消息；A 重登收到同一 消息 ID 的已读回执（参数：位置）

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. A 离线期间 B 已读类型消息；A 重登收到同一 消息 ID 的已读回执。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：ChatManager.ackMessageRead。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_typed_message_read_after_sender_relogin[location]

### 71. A 离线期间 B 已读类型消息；A 重登收到同一 消息 ID 的已读回执（参数：文件）

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. A 离线期间 B 已读类型消息；A 重登收到同一 消息 ID 的已读回执。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：ChatManager.ackMessageRead。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_typed_message_read_after_sender_relogin[file]

### 72. A 离线期间 B 已读类型消息；A 重登收到同一 消息 ID 的已读回执（参数：语音）

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. A 离线期间 B 已读类型消息；A 重登收到同一 消息 ID 的已读回执。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：ChatManager.ackMessageRead。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_typed_message_read_after_sender_relogin[voice]

### 73. A 离线期间 B 已读类型消息；A 重登收到同一 消息 ID 的已读回执（参数：自定义）

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. A 离线期间 B 已读类型消息；A 重登收到同一 消息 ID 的已读回执。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：ChatManager.ackMessageRead。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_typed_message_read_after_sender_relogin[custom]

### 74. B 离线积压四类消息；按 ID 集合核对回放、本地、历史、未读和最新消息

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. B 离线积压四类消息；按 ID 集合核对回放、本地、历史、未读和最新消息。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：ConversationManager.clearAllMessages、ConversationManager.markAllMessagesAsRead、ChatManager.getMessage、ConversationManager.getUnreadMsgCount、ConversationManager.getLatestMessage、ChatManager.fetchHistoryMessages。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_extended_delivery.py::test_chat_offline_mixed_backlog_local_state_after_recipient_login

### 75. B 离线期间 A 置顶消息；B 重登收到置顶事件和最终置顶消息

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. B 离线期间 A 置顶消息；B 重登收到置顶事件和最终置顶消息。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：ChatManager.pinMessage、ChatManager.unpinMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_operations.py::test_chat_offline_recipient_receives_message_pin_after_relogin

### 76. B 离线期间积压三条文本；上线后消息集合、未读数和最新消息一致

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. B 离线期间积压三条文本；上线后消息集合、未读数和最新消息一致。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：ConversationManager.getUnreadMsgCount、ConversationManager.getLatestMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_delivery.py::test_chat_offline_multiple_text_messages_and_unread_count

### 77. B 离线时的类型消息仅在重登接收后触发 A 的真实送达回执（需发送标记 需要已读回执）（参数：视频）

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. B 离线时的类型消息仅在重登接收后触发 A 的真实送达回执（需发送标记 需要已读回执）。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_extended_delivery.py::test_chat_offline_typed_delivery_ack_after_recipient_login[video]

### 78. B 离线时的类型消息仅在重登接收后触发 A 的真实送达回执（需发送标记 需要已读回执）（参数：图片）

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. B 离线时的类型消息仅在重登接收后触发 A 的真实送达回执（需发送标记 需要已读回执）。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_extended_delivery.py::test_chat_offline_typed_delivery_ack_after_recipient_login[image]

### 79. B 离线时的类型消息仅在重登接收后触发 A 的真实送达回执（需发送标记 需要已读回执）（参数：位置）

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. B 离线时的类型消息仅在重登接收后触发 A 的真实送达回执（需发送标记 需要已读回执）。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_extended_delivery.py::test_chat_offline_typed_delivery_ack_after_recipient_login[location]

### 80. B 离线时的类型消息仅在重登接收后触发 A 的真实送达回执（需发送标记 需要已读回执）（参数：文件）

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. B 离线时的类型消息仅在重登接收后触发 A 的真实送达回执（需发送标记 需要已读回执）。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_extended_delivery.py::test_chat_offline_typed_delivery_ack_after_recipient_login[file]

### 81. B 离线时的类型消息仅在重登接收后触发 A 的真实送达回执（需发送标记 需要已读回执）（参数：语音）

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. B 离线时的类型消息仅在重登接收后触发 A 的真实送达回执（需发送标记 需要已读回执）。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_extended_delivery.py::test_chat_offline_typed_delivery_ack_after_recipient_login[voice]

### 82. B 离线时的类型消息仅在重登接收后触发 A 的真实送达回执（需发送标记 需要已读回执）（参数：自定义）

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. B 离线时的类型消息仅在重登接收后触发 A 的真实送达回执（需发送标记 需要已读回执）。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_extended_delivery.py::test_chat_offline_typed_delivery_ack_after_recipient_login[custom]

### 83. B 离线时发送文本，B 登录投递后 A 收到同一消息的送达回执

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。原测试目标：B 离线时发送文本，B 登录投递后 A 收到同一消息的送达回执。
- 状态/版本说明：5.0 不适用：5.0 送达回执机制实际不可用：原生 onMessageDelivered 回调存在但服务端不发送 DELIVER_ACK（离线/在线均实测不触发）
- 源码：native-auto-test/tests/chat/test_chat_offline_message_delivery.py::test_chat_offline_delivery_ack_after_recipient_login

### 84. B 使用离线回放的原始媒体消息下载附件；图片/视频同时覆盖缩略图（参数：视频-附件-缩略图）

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. B 使用离线回放的原始媒体消息下载附件；图片/视频同时覆盖缩略图。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_extended_delivery.py::test_chat_offline_received_media_downloads_after_recipient_login[video-attachment-thumbnail]

### 85. B 使用离线回放的原始媒体消息下载附件；图片/视频同时覆盖缩略图（参数：图片-附件-缩略图）

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. B 使用离线回放的原始媒体消息下载附件；图片/视频同时覆盖缩略图。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_extended_delivery.py::test_chat_offline_received_media_downloads_after_recipient_login[image-attachment-thumbnail]

### 86. B 使用离线回放的原始媒体消息下载附件；图片/视频同时覆盖缩略图（参数：文件-附件）

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. B 使用离线回放的原始媒体消息下载附件；图片/视频同时覆盖缩略图。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_extended_delivery.py::test_chat_offline_received_media_downloads_after_recipient_login[file-attachment]

### 87. B 使用离线回放的原始媒体消息下载附件；图片/视频同时覆盖缩略图（参数：语音-附件）

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. B 使用离线回放的原始媒体消息下载附件；图片/视频同时覆盖缩略图。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_extended_delivery.py::test_chat_offline_received_media_downloads_after_recipient_login[voice-attachment]

### 88. B 首次接收前 A 已撤回文本；B 重登按真实离线合并语义收到撤回

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. B 首次接收前 A 已撤回文本；B 重登按真实离线合并语义收到撤回。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：ChatManager.recallMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_text_recalled_before_first_recipient_login

### 89. B 首次接收前 A 已修改文本；B 重登直接收到最终正文

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. B 首次接收前 A 已修改文本；B 重登直接收到最终正文。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：ChatManager.modifyMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_text_modified_before_first_recipient_login

### 90. B 已收 合并 后离线；A 撤回后 B 重登收到原 合并 信息

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. B 已收 合并 后离线；A 撤回后 B 重登收到原 合并 信息。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：ChatManager.recallMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_combine_message_recall_after_recipient_relogin

### 91. B 已收 自定义 后离线；A 修改 内容，B 重登收到最终自定义正文

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. B 已收 自定义 后离线；A 修改 内容，B 重登收到最终自定义正文。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：ChatManager.modifyMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_custom_body_modified_after_recipient_relogin

### 92. B 已收类型消息后离线；A 撤回后 B 重登收到撤回事件且本地消息删除（参数：视频）

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. B 已收类型消息后离线；A 撤回后 B 重登收到撤回事件且本地消息删除。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：ChatManager.recallMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_typed_message_recall_after_recipient_relogin[video]

### 93. B 已收类型消息后离线；A 撤回后 B 重登收到撤回事件且本地消息删除（参数：图片）

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. B 已收类型消息后离线；A 撤回后 B 重登收到撤回事件且本地消息删除。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：ChatManager.recallMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_typed_message_recall_after_recipient_relogin[image]

### 94. B 已收类型消息后离线；A 撤回后 B 重登收到撤回事件且本地消息删除（参数：位置）

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. B 已收类型消息后离线；A 撤回后 B 重登收到撤回事件且本地消息删除。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：ChatManager.recallMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_typed_message_recall_after_recipient_relogin[location]

### 95. B 已收类型消息后离线；A 撤回后 B 重登收到撤回事件且本地消息删除（参数：文件）

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. B 已收类型消息后离线；A 撤回后 B 重登收到撤回事件且本地消息删除。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：ChatManager.recallMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_typed_message_recall_after_recipient_relogin[file]

### 96. B 已收类型消息后离线；A 撤回后 B 重登收到撤回事件且本地消息删除（参数：语音）

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. B 已收类型消息后离线；A 撤回后 B 重登收到撤回事件且本地消息删除。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：ChatManager.recallMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_typed_message_recall_after_recipient_relogin[voice]

### 97. B 已收类型消息后离线；A 撤回后 B 重登收到撤回事件且本地消息删除（参数：自定义）

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. B 已收类型消息后离线；A 撤回后 B 重登收到撤回事件且本地消息删除。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：ChatManager.recallMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_typed_message_recall_after_recipient_relogin[custom]

### 98. B 已收媒体后离线；A 修改 属性，B 重登收到并保存扩展（参数：视频）

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. B 已收媒体后离线；A 修改 属性，B 重登收到并保存扩展。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：ChatManager.modifyMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_media_attributes_modified_after_recipient_relogin[video]

### 99. B 已收媒体后离线；A 修改 属性，B 重登收到并保存扩展（参数：图片）

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. B 已收媒体后离线；A 修改 属性，B 重登收到并保存扩展。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：ChatManager.modifyMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_media_attributes_modified_after_recipient_relogin[image]

### 100. B 已收媒体后离线；A 修改 属性，B 重登收到并保存扩展（参数：文件）

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. B 已收媒体后离线；A 修改 属性，B 重登收到并保存扩展。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：ChatManager.modifyMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_media_attributes_modified_after_recipient_relogin[file]

### 101. B 已收媒体后离线；A 修改 属性，B 重登收到并保存扩展（参数：语音）

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. B 已收媒体后离线；A 修改 属性，B 重登收到并保存扩展。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：ChatManager.modifyMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_extended_operations.py::test_chat_offline_media_attributes_modified_after_recipient_relogin[voice]

### 102. B 已收消息后离线，A 撤回；B 重登收到目标撤回信息

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. B 已收消息后离线，A 撤回；B 重登收到目标撤回信息。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：ChatManager.recallMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_operations.py::test_chat_offline_recipient_receives_recall_after_relogin

### 103. B 已收消息后离线，A 修改正文；B 重登收到修改事件和最终正文

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. B 已收消息后离线，A 修改正文；B 重登收到修改事件和最终正文。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：ChatManager.modifyMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_operations.py::test_chat_offline_recipient_receives_content_change_after_relogin

### 104. CMD 设置 deliver在线Only=true 时，不进入离线 B 的本地消息库

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. CMD 设置 deliver在线Only=true 时，不进入离线 B 的本地消息库。
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：ChatManager.getMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_offline_message_delivery.py::test_chat_offline_deliver_online_only_not_received_after_login

### 105. 5.0 发送消息 路线：缺 payload 必填字段时 swt_to_发送 用默认值填充为消息默认值， 消息构造成功并发送；原生 SDK 实测接受空字段消息（消息发送成功回调），不拒绝（参数：位置-缺失-latitude）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。原测试目标：5.0 sendMessage 路线：缺 payload 必填字段时 swt_to_send 用默认值填充为消息默认值， 消息构造成功并发送；原生 SDK 实测接受空字段消息（onMessageSuccess），不拒绝。
- 状态/版本说明：跳过：缺字段被 swt_to_send 默认值填充（content=
- 源码：native-auto-test/tests/chat/test_chat_message_send_boundaries.py::test_chat_message_type_rejects_missing_required_payload[location-missing-latitude]

### 106. 5.0 发送消息 路线：缺 payload 必填字段时 swt_to_发送 用默认值填充为消息默认值， 消息构造成功并发送；原生 SDK 实测接受空字段消息（消息发送成功回调），不拒绝（参数：位置-缺失-longitude）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。原测试目标：5.0 sendMessage 路线：缺 payload 必填字段时 swt_to_send 用默认值填充为消息默认值， 消息构造成功并发送；原生 SDK 实测接受空字段消息（onMessageSuccess），不拒绝。
- 状态/版本说明：跳过：缺字段被 swt_to_send 默认值填充（content=
- 源码：native-auto-test/tests/chat/test_chat_message_send_boundaries.py::test_chat_message_type_rejects_missing_required_payload[location-missing-longitude]

### 107. 5.0 发送消息 路线：缺 payload 必填字段时 swt_to_发送 用默认值填充为消息默认值， 消息构造成功并发送；原生 SDK 实测接受空字段消息（消息发送成功回调），不拒绝（参数：自定义-缺失-event）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。原测试目标：5.0 sendMessage 路线：缺 payload 必填字段时 swt_to_send 用默认值填充为消息默认值， 消息构造成功并发送；原生 SDK 实测接受空字段消息（onMessageSuccess），不拒绝。
- 状态/版本说明：跳过：缺字段被 swt_to_send 默认值填充（content=
- 源码：native-auto-test/tests/chat/test_chat_message_send_boundaries.py::test_chat_message_type_rejects_missing_required_payload[custom-missing-event]

### 108. 5.0 发送消息 路线：缺 payload 必填字段时 swt_to_发送 用默认值填充为消息默认值， 消息构造成功并发送；原生 SDK 实测接受空字段消息（消息发送成功回调），不拒绝（参数：cmd-缺失-操作）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。原测试目标：5.0 sendMessage 路线：缺 payload 必填字段时 swt_to_send 用默认值填充为消息默认值， 消息构造成功并发送；原生 SDK 实测接受空字段消息（onMessageSuccess），不拒绝。
- 状态/版本说明：跳过：缺字段被 swt_to_send 默认值填充（content=
- 源码：native-auto-test/tests/chat/test_chat_message_send_boundaries.py::test_chat_message_type_rejects_missing_required_payload[cmd-missing-action]

### 109. 5.0 发送消息 路线：缺 payload 必填字段时 swt_to_发送 用默认值填充为消息默认值， 消息构造成功并发送；原生 SDK 实测接受空字段消息（消息发送成功回调），不拒绝（参数：txt-缺失-内容）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。原测试目标：5.0 sendMessage 路线：缺 payload 必填字段时 swt_to_send 用默认值填充为消息默认值， 消息构造成功并发送；原生 SDK 实测接受空字段消息（onMessageSuccess），不拒绝。
- 状态/版本说明：跳过：缺字段被 swt_to_send 默认值填充（content=
- 源码：native-auto-test/tests/chat/test_chat_message_send_boundaries.py::test_chat_message_type_rejects_missing_required_payload[txt-missing-content]

### 110. 5.0 会话改本地读取（loadAll会话列表）：发消息后本地会话列表含目标会话（原 获取会话列表FromServer 服务端拉取已移除）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 5.0 会话改本地读取（loadAll会话列表）：发消息后本地会话列表含目标会话（原 获取会话列表FromServer 服务端拉取已移除）。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_load_all_conversations_contains_target_conversation

### 111. 按查询条件获取历史消息 成功

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 按查询条件获取历史消息 成功
  重点验证接口：ChatManager.fetchHistoryMessagesByOptions。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_s3_non_message_ops.py::test_chat_fetch_history_messages_by_options_success

### 112. 按查询条件获取历史消息 使用空会话

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 按查询条件获取历史消息 使用空会话
  重点验证接口：ChatManager.fetchHistoryMessagesByOptions。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_s3_non_message_ops.py::test_chat_fetch_history_messages_by_options_empty_conv_id

### 113. 按查询条件获取历史消息 使用无效会话

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 使用无效会话按查询条件获取历史消息
  重点验证接口：ChatManager.fetchHistoryMessagesByOptions。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_crud.py::test_chat_fetch_history_by_options_invalid_conversation

### 114. 按查询条件获取历史消息 使用无效会话

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 使用无效会话按查询条件获取历史消息
  重点验证接口：ChatManager.fetchHistoryMessagesByOptions。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_s3_non_message_ops.py::test_chat_fetch_history_messages_by_options_invalid_conv_id

### 115. 撤回 消息 无效 id 响应

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 撤回 消息 无效 id 响应
  重点验证接口：ChatManager.recallMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_crud.py::test_chat_recall_message_invalid_id_response

### 116. 撤回不存在的消息，不应产生 消息撤回回调 事件

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 撤回 消息 无效 id 响应
  重点验证接口：ChatManager.recallMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat.py::test_chat_recall_message_invalid_id_response

### 117. 发送 给自己 should not succeed

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 发送 给自己 should not succeed
  重点验证接口：ChatManager.sendMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat.py::test_chat_send_to_self_should_not_succeed

### 118. 发送带唯一关键词的文本；按关键词本地搜索应命中

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 发送带唯一关键词的文本；按关键词本地搜索应命中。
  重点验证接口：ChatManager.sendMessage、ChatManager.searchChatMsgFromDB。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_search_db.py::test_chat_search_chat_msg_from_db_success

### 119. 发送消息：向 user_c 发送单聊消息，按当前真实返回冻结为成功回调

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 发送消息：向 user_c 发送单聊消息，按当前真实返回冻结为成功回调。
  重点验证接口：ChatManager.sendMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_manager_remaining_api_coverage.py::test_chat_manager_send_to_non_friend_current_success_event

### 120. 发消息给自己：发送账号主端收到成功事件（5.0 self 消息无接收事件，不验证副端接收）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 发消息给自己：主端收到成功事件
  重点验证接口：ChatManager.sendMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_crud.py::test_chat_send_to_self_event

### 121. 分别验证正常长度与超长 消息 Reaction，避免同一消息的异步操作互相竞争

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 添加 消息 Reaction 超长 消息 Reaction；使用独立消息隔离异步操作状态。
  重点验证接口：ChatManager.addReaction。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_reaction_fetch.py::test_chat_add_reaction_too_long_reaction

### 122. 官方结构：获取消息 无效 消息 ID → null（wrapper 基类 发送成功回调(null) → 真 null，对齐官方经 Dart 归一化）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 官方结构：获取消息 无效 消息 ID → null（wrapper 基类 发送成功回调(null) → 真 null，对齐官方经 Dart 归一化）。
  重点验证接口：ChatManager.getMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_crud.py::test_chat_get_message_invalid_id_returns_none

### 123. 官方结构移植：修改消息 空 消息 ID → 错误

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 官方结构移植：修改消息 空 消息 ID → 错误。
  重点验证接口：ChatManager.modifyMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_message_modification_matrix.py::test_chat_modify_message_empty_id

### 124. 官方结构移植：修改消息 修改正文/属性/两者（参数：内容-and-属性）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 官方结构移植：修改消息 修改正文/属性/两者。当前环境实测 305（edit not available，待研发）。
  重点验证接口：ChatManager.modifyMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_message_modification_matrix.py::test_chat_modify_text_body_and_attributes[body-and-attributes]

### 125. 官方结构移植：修改消息 修改正文/属性/两者（参数：内容）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 官方结构移植：修改消息 修改正文/属性/两者。当前环境实测 305（edit not available，待研发）。
  重点验证接口：ChatManager.modifyMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_message_modification_matrix.py::test_chat_modify_text_body_and_attributes[body]

### 126. 官方结构移植：修改消息 修改正文/属性/两者（参数：属性）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 官方结构移植：修改消息 修改正文/属性/两者。当前环境实测 305（edit not available，待研发）。
  重点验证接口：ChatManager.modifyMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_message_modification_matrix.py::test_chat_modify_text_body_and_attributes[attributes]

### 127. 合并消息来源 ID 为空时应进入失败终态，B 不得收到该合并消息

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 合并消息来源 ID 为空时应进入失败终态，B 不得收到该合并消息。
  重点验证接口：ChatManager.sendMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_message_send_boundaries.py::test_chat_combine_message_rejects_empty_source_ids

### 128. 会话 置顶 and marked cursor pagination

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：5.0 不适用：5.0 移除服务端拉会话/options cursor 分页（fetchConversationsByOptions 残留）
- 源码：native-auto-test/tests/chat/test_chat_conversation_cursor_pagination.py::test_chat_conversation_pinned_and_marked_cursor_pagination

### 129. 会话 mark idempotent and 删除 unmarked

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 会话 mark idempotent and 删除 unmarked
  重点验证接口：ChatManager.addRemoteAndLocalConversationsMark、ChatManager.loadAllConversations、ChatManager.deleteRemoteAndLocalConversationsMark。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_conversation_marks_boundaries.py::test_chat_conversation_mark_idempotent_and_remove_unmarked

### 130. 会话 pin and unpin are idempotent

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 会话 pin and unpin are idempotent
  重点验证接口：ChatManager.pinConversation、ChatManager.loadAllConversations。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_conversation_pin_additional.py::test_chat_conversation_pin_and_unpin_are_idempotent

### 131. 会话DeleteServer消息WithIds：按消息 ID 删除本地及服务端消息，冻结当前返回

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 会话DeleteServer消息WithIds：按消息 ID 删除本地及服务端消息，冻结当前返回。
  重点验证接口：ConversationManager.conversationDeleteServerMessageWithIds。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_conversation_remaining_api_coverage.py::test_conversation_delete_local_and_server_messages_current_behavior

### 132. 会话DeleteServer消息WithTime：按时间删除本地及服务端消息，冻结当前返回

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 会话DeleteServer消息WithTime：按时间删除本地及服务端消息，冻结当前返回。
  重点验证接口：ConversationManager.conversationDeleteServerMessageWithTime。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_conversation_remaining_api_coverage.py::test_conversation_delete_local_and_server_messages_by_time

### 133. 获取 会话 成功

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 获取 会话 成功
  重点验证接口：ChatManager.getConversation。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_s1_local_conversation.py::test_chat_get_conversation_success

### 134. 获取 会话 使用空会话

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 获取 会话 使用空会话
  重点验证接口：ChatManager.getConversation。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_s1_local_conversation.py::test_chat_get_conversation_empty_conv_id

### 135. 获取 会话 marks boundaries（参数：info0）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：跳过：mark=999 非法标记值边界暂缓（此前 Android bridge 抛异常，行为待确认）
- 源码：native-auto-test/tests/chat/test_chat_conversation_marks_boundaries.py::test_chat_fetch_conversation_marks_boundaries[info0]

### 136. 获取 会话 marks boundaries（参数：info1）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：跳过：mark=999 非法标记值边界暂缓（此前 Android bridge 抛异常，行为待确认）
- 源码：native-auto-test/tests/chat/test_chat_conversation_marks_boundaries.py::test_chat_fetch_conversation_marks_boundaries[info1]

### 137. 获取 会话 marks boundaries（参数：info2）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：跳过：mark=999 非法标记值边界暂缓（此前 Android bridge 抛异常，行为待确认）
- 源码：native-auto-test/tests/chat/test_chat_conversation_marks_boundaries.py::test_chat_fetch_conversation_marks_boundaries[info2]

### 138. 获取 会话 marks boundaries（参数：info3）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：跳过：mark=999 非法标记值边界暂缓（此前 Android bridge 抛异常，行为待确认）
- 源码：native-auto-test/tests/chat/test_chat_conversation_marks_boundaries.py::test_chat_fetch_conversation_marks_boundaries[info3]

### 139. 获取 会话 marks boundaries（参数：info4）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：跳过：mark=999 非法标记值边界暂缓（此前 Android bridge 抛异常，行为待确认）
- 源码：native-auto-test/tests/chat/test_chat_conversation_marks_boundaries.py::test_chat_fetch_conversation_marks_boundaries[info4]

### 140. 获取 会话 not exist without 创建

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 获取 会话 not exist without 创建
  重点验证接口：ChatManager.getConversation。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_s1_local_conversation.py::test_chat_get_conversation_not_exist_without_create

### 141. 获取 会话列表 从服务端 带分页 成功

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：5.0 不适用：5.0 移除 cursor 分页（会话查询返回纯 list，无 pageSize 校验）
- 源码：native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_fetch_conversations_from_server_with_page_success

### 142. 获取 会话列表 从服务端 带分页 无效 分页大小 zero

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：5.0 不适用：5.0 移除服务端拉会话（改用本地列表，无服务端/分页语义）
- 源码：native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_fetch_conversations_from_server_with_page_invalid_page_size_zero

### 143. 获取 会话列表 从服务端 带分页 无效 页码 zero

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：5.0 不适用：5.0 移除服务端拉会话（改用本地列表，无服务端/分页语义）
- 源码：native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_fetch_conversations_from_server_with_page_invalid_page_num_zero

### 144. 获取 会话列表 从服务端 带游标 成功

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：5.0 不适用：5.0 移除服务端拉会话（改用本地列表，无服务端/分页语义）
- 源码：native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_get_conversations_from_server_with_cursor_success

### 145. 获取 会话列表 从服务端 带游标 无效 分页大小 negative

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：5.0 不适用：5.0 移除 cursor 分页（会话查询返回纯 list，无 pageSize 校验）
- 源码：native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_get_conversations_from_server_with_cursor_invalid_page_size_negative

### 146. 获取 会话列表 从服务端 带游标 无效 分页大小 zero

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：5.0 不适用：5.0 移除 cursor 分页（会话查询返回纯 list，无 pageSize 校验）
- 源码：native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_get_conversations_from_server_with_cursor_invalid_page_size_zero

### 147. 获取 消息 Reaction 详情 传入空 消息 Reaction；应返回参数错误

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 获取 消息 Reaction 详情 传入空 消息 Reaction；应返回参数错误。
  重点验证接口：ChatManager.fetchReactionDetail。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_reaction_fetch.py::test_chat_fetch_reaction_detail_empty_reaction

### 148. 获取 消息 Reaction 详情 非法 pageSize（-1）；应返回参数错误

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 获取 消息 Reaction 详情 非法 pageSize（-1）；应返回参数错误。
  重点验证接口：ChatManager.fetchReactionDetail。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_reaction_fetch.py::test_chat_fetch_reaction_detail_invalid_page_size

### 149. 获取 消息 Reaction 详情 使用无效 消息 ID/消息 Reaction；先校验信封

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 获取 消息 Reaction 详情 使用无效 消息 ID/消息 Reaction；先校验信封。
  重点验证接口：ChatManager.fetchReactionDetail。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_reaction_fetch.py::test_chat_fetch_reaction_detail_invalid

### 150. 获取 置顶 会话列表 从服务端 带游标 成功

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：5.0 不适用：5.0 移除服务端拉会话（改用本地列表，无服务端/分页语义）
- 源码：native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_get_pinned_conversations_from_server_with_cursor_success

### 151. 获取 置顶 会话列表 从服务端 带游标 无效 分页大小 negative

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：5.0 不适用：5.0 移除 cursor 分页（会话查询返回纯 list，无 pageSize 校验）
- 源码：native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_get_pinned_conversations_from_server_with_cursor_invalid_page_size_negative

### 152. 获取 置顶 会话列表 从服务端 带游标 无效 分页大小 zero

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：5.0 不适用：5.0 移除服务端拉会话（改用本地列表，无服务端/分页语义）
- 源码：native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_get_pinned_conversations_from_server_with_cursor_invalid_page_size_zero

### 153. 获取 置顶 会话列表 分页大小 boundaries（参数：-1-expected1）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：5.0 不适用：5.0 移除 cursor 分页（fetchPinnedConversations 返回纯 list，无 pageSize 校验）
- 源码：native-auto-test/tests/chat/test_chat_conversation_pin_additional.py::test_chat_fetch_pinned_conversations_page_size_boundaries[-1-expected1]

### 154. 获取 置顶 会话列表 分页大小 boundaries（参数：0-expected0）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：5.0 不适用：5.0 移除 cursor 分页（fetchPinnedConversations 返回纯 list，无 pageSize 校验）
- 源码：native-auto-test/tests/chat/test_chat_conversation_pin_additional.py::test_chat_fetch_pinned_conversations_page_size_boundaries[0-expected0]

### 155. 获取 置顶 会话列表 分页大小 boundaries（参数：1000-expected2）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：5.0 不适用：5.0 移除 cursor 分页（fetchPinnedConversations 返回纯 list，无 pageSize 校验）
- 源码：native-auto-test/tests/chat/test_chat_conversation_pin_additional.py::test_chat_fetch_pinned_conversations_page_size_boundaries[1000-expected2]

### 156. 获取 置顶 消息 使用无效会话

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 获取 置顶 消息 使用无效会话
  重点验证接口：ChatManager.fetchPinnedMessages。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_message_pin_boundaries.py::test_chat_fetch_pinned_messages_invalid_conversation[]

### 157. 获取 置顶 消息 使用无效会话（参数：__无效_pin_会话__）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 获取 置顶 消息 使用无效会话
  重点验证接口：ChatManager.fetchPinnedMessages。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_message_pin_boundaries.py::test_chat_fetch_pinned_messages_invalid_conversation[__invalid_pin_conversation__]

### 158. 获取 support 语言 成功

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 获取 support 语言 成功
  重点验证接口：ChatManager.fetchSupportLanguages。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_crud.py::test_chat_fetch_support_languages_success

### 159. 获取 unread count positive then zero

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 获取 unread count positive then zero
  重点验证接口：ChatManager.markAllChatMsgAsRead、ChatManager.getUnreadMessageCount。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_s1_local_conversation.py::test_chat_get_unread_count_positive_then_zero

### 160. 获取历史消息 成功

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 获取历史消息 成功
  重点验证接口：ChatManager.fetchHistoryMessages。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_s3_non_message_ops.py::test_chat_fetch_history_messages_success

### 161. 获取历史消息 分页大小 one cursor

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 获取历史消息 分页大小 one cursor
  重点验证接口：ChatManager.fetchHistoryMessagesByOptions。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_attachment_download_and_history_boundaries.py::test_chat_fetch_history_page_size_one_cursor

### 162. 获取历史消息 使用空会话

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 获取历史消息 使用空会话
  重点验证接口：ChatManager.fetchHistoryMessages。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_s3_non_message_ops.py::test_chat_fetch_history_messages_empty_conv_id

### 163. 获取历史消息 使用无效会话

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 使用无效会话获取历史消息
  重点验证接口：ChatManager.fetchHistoryMessages。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_crud.py::test_chat_fetch_history_invalid_conversation

### 164. 获取历史消息 使用无效会话

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 获取历史消息 使用无效会话
  重点验证接口：ChatManager.fetchHistoryMessages。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_s3_non_message_ops.py::test_chat_fetch_history_messages_invalid_conv_id

### 165. 获取消息 使用无效 消息 ID：WS_RELAX=1 观察到唯一返回为 result=None，锁定为单一预期

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 获取 消息 无效 id returns none or error
  重点验证接口：ChatManager.getMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat.py::test_chat_get_message_invalid_id_returns_none_or_error

### 166. 获取消息Count/searchMsgsBy查询条件：校验全量消息计数返回数值，以及 count=0 搜索边界返回空列表

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 获取消息Count/searchMsgsBy查询条件：校验全量消息计数返回数值，以及 count=0 搜索边界返回空列表。
  重点验证接口：ChatManager.deleteAllMessageAndConversation、ChatManager.getMessageCount、ChatManager.searchMsgsByOptions。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_manager_remaining_api_coverage.py::test_chat_manager_message_count_and_search_options_boundaries

### 167. 加载 会话 消息 带 关键词 成功

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 加载 会话 消息 带 关键词 成功
  重点验证接口：ChatManager.loadConversationMessagesWithKeyword。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_s4_local_keyword_search.py::test_chat_load_conversation_messages_with_keyword_success

### 168. 加载 会话 消息 带 关键词 无匹配

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 加载 会话 消息 带 关键词 无匹配
  重点验证接口：ChatManager.loadConversationMessagesWithKeyword。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_s4_local_keyword_search.py::test_chat_load_conversation_messages_with_keyword_no_hit

### 169. 加载 消息 带 ids 单个和多个 成功

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 加载 消息 带 ids 单个和多个 成功
  重点验证接口：ChatManager.loadMessagesWithIds。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_s4_load_messages_by_ids.py::test_chat_load_messages_with_ids_single_and_multi_success

### 170. 加载 消息 带 ids 空 ids

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 加载 消息 带 ids 空 ids
  重点验证接口：ChatManager.loadMessagesWithIds。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_s4_load_messages_by_ids.py::test_chat_load_messages_with_ids_empty_ids

### 171. 加载 all 会话列表 contains then not contains

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 加载 all 会话列表 contains then not contains
  重点验证接口：ChatManager.deleteConversation、ChatManager.loadAllConversations。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_s1_local_conversation.py::test_chat_load_all_conversations_contains_then_not_contains

### 172. 加载消息/加载消息/加载消息FromTime：发送后按 ID、数量和时间窗口加载当前消息

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 加载消息/加载消息/加载消息FromTime：发送后按 ID、数量和时间窗口加载当前消息。
  重点验证接口：ConversationManager.loadMsgWithId。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_conversation_remaining_api_coverage.py::test_conversation_load_message_and_message_lists

### 173. 加载消息/mark消息AsRead/delete消息ByIds：非法消息 ID 边界，冻结当前端真实返回语义

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 加载消息/mark消息AsRead/delete消息ByIds：非法消息 ID 边界，冻结当前端真实返回语义。
  重点验证接口：ConversationManager.loadMsgWithId、ConversationManager.markMessageAsRead、ConversationManager.deleteMessageByIds。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_conversation_remaining_api_coverage.py::test_conversation_invalid_message_id_boundaries

### 174. 加载消息WithMsgType/加载消息WithKeyword/会话列表earchMsgsBy查询条件：使用空数量/唯一关键词边界冻结空列表返回

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 加载消息WithMsgType/加载消息WithKeyword/会话列表earchMsgsBy查询条件：使用空数量/唯一关键词边界冻结空列表返回。
  重点验证接口：ConversationManager.loadMsgWithMsgType、ConversationManager.loadMsgWithKeywords、ConversationManager.conversationSearchMsgsByOptions。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_conversation_remaining_api_coverage.py::test_conversation_type_keyword_and_options_search_current_behavior

### 175. 空目标应失败；不存在用户按真实服务端语义发送成功；B 均不得误收目标消息（参数：空-target）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。原测试目标：空目标应失败；不存在用户按真实服务端语义发送成功；B 均不得误收目标消息。
- 状态/版本说明：待补齐：桥接或集成端缺口
- 源码：native-auto-test/tests/chat/test_chat_message_send_boundaries.py::test_chat_message_send_target_boundaries[empty-target]

### 176. 空目标应失败；不存在用户按真实服务端语义发送成功；B 均不得误收目标消息（参数：nonexistent-target）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。原测试目标：空目标应失败；不存在用户按真实服务端语义发送成功；B 均不得误收目标消息。
- 状态/版本说明：待补齐：桥接或集成端缺口
- 源码：native-auto-test/tests/chat/test_chat_message_send_boundaries.py::test_chat_message_send_target_boundaries[nonexistent-target]

### 177. 历史 attach lang smoke exists

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 历史 attach lang smoke exists
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat.py::test_chat_history_attach_lang_smoke_exists

### 178. 历史 filters direction time and 消息 types

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 历史 filters direction time and 消息 types
  重点验证接口：ChatManager.deleteRemoteConversation。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_history_option_filters.py::test_chat_history_filters_direction_time_and_message_types

### 179. 媒体消息显式传入不存在 Android 路径时应失败，B 不得收到该媒体消息（参数：视频）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 媒体消息显式传入不存在 Android 路径时应失败，B 不得收到该媒体消息。
  重点验证接口：ChatManager.sendMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_message_send_boundaries.py::test_chat_media_message_rejects_nonexistent_device_path[video]

### 180. 媒体消息显式传入不存在 Android 路径时应失败，B 不得收到该媒体消息（参数：图片）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 媒体消息显式传入不存在 Android 路径时应失败，B 不得收到该媒体消息。
  重点验证接口：ChatManager.sendMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_message_send_boundaries.py::test_chat_media_message_rejects_nonexistent_device_path[image]

### 181. 媒体消息显式传入不存在 Android 路径时应失败，B 不得收到该媒体消息（参数：文件）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 媒体消息显式传入不存在 Android 路径时应失败，B 不得收到该媒体消息。
  重点验证接口：ChatManager.sendMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_message_send_boundaries.py::test_chat_media_message_rejects_nonexistent_device_path[file]

### 182. 媒体消息显式传入不存在 Android 路径时应失败，B 不得收到该媒体消息（参数：语音）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 媒体消息显式传入不存在 Android 路径时应失败，B 不得收到该媒体消息。
  重点验证接口：ChatManager.sendMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_message_send_boundaries.py::test_chat_media_message_rejects_nonexistent_device_path[voice]

### 183. 目标：验证 ChatManager#getAll会话列表BySort 返回的会话排序正确（最新消息会话优先）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 目标：验证 ChatManager#getAll会话列表BySort 返回的会话排序正确（最新消息会话优先）。
  重点验证接口：ChatManager.deleteConversation、ChatManager.loadAllConversations。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_s1_conversations_sort.py::test_chat_get_all_conversations_by_sort_orders_latest_first

### 184. 缺失 撤回 空 消息 ID

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 缺失 撤回 空 消息 ID
  重点验证接口：ChatManager.recallMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_recall_and_message_read_ack.py::test_chat_missing_recall_empty_message_id

### 185. 缺失 消息 送达回执（参数：自定义-payload1）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 缺失 消息 送达回执
  重点验证接口：Client.updateDeliveryAckSetting。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_message_types_and_delivery.py::test_chat_missing_message_delivery_ack[custom-payload1]

### 186. 缺失 消息 送达回执（参数：txt-payload0）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 缺失 消息 送达回执
  重点验证接口：Client.updateDeliveryAckSetting。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_message_types_and_delivery.py::test_chat_missing_message_delivery_ack[txt-payload0]

### 187. 缺失 ack 消息 read boundaries（参数：info0）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 缺失 ack 消息 read boundaries
  重点验证接口：ChatManager.ackMessageRead。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_recall_and_message_read_ack.py::test_chat_missing_ack_message_read_boundaries[info0]

### 188. 缺失 ack 消息 read boundaries（参数：info1）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 缺失 ack 消息 read boundaries
  重点验证接口：ChatManager.ackMessageRead。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_recall_and_message_read_ack.py::test_chat_missing_ack_message_read_boundaries[info1]

### 189. 缺失 ack 消息 read boundaries（参数：info2）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 缺失 ack 消息 read boundaries
  重点验证接口：ChatManager.ackMessageRead。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_recall_and_message_read_ack.py::test_chat_missing_ack_message_read_boundaries[info2]

### 190. 删除 消息 从服务端 带 msg ids 成功

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：待补齐：桥接或集成端缺口
- 源码：native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_remove_messages_from_server_with_msg_ids_success

### 191. 删除 消息 从服务端 带 msg ids 空 msg ids

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：待补齐：桥接或集成端缺口
- 源码：native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_remove_messages_from_server_with_msg_ids_empty_msg_ids

### 192. 删除 消息 从服务端 带 msg ids 缺失 conv id

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：待补齐：桥接或集成端缺口
- 源码：native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_remove_messages_from_server_with_msg_ids_missing_conv_id

### 193. 删除 消息 从服务端 带 msg ids 缺失 msg ids

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：待补齐：桥接或集成端缺口
- 源码：native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_remove_messages_from_server_with_msg_ids_missing_msg_ids

### 194. 删除 消息 从服务端 带 ts 成功

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：待补齐：桥接或集成端缺口
- 源码：native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_remove_messages_from_server_with_ts_success

### 195. 删除 消息 从服务端 带 ts 缺失 conv id

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：待补齐：桥接或集成端缺口
- 源码：native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_remove_messages_from_server_with_ts_missing_conv_id

### 196. 删除 消息 从服务端 带 ts 缺失 timestamp

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：待补齐：桥接或集成端缺口
- 源码：native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_remove_messages_from_server_with_ts_missing_timestamp

### 197. 删除 消息 从服务端 带 ts timestamp zero

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：待补齐：桥接或集成端缺口
- 源码：native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_remove_messages_from_server_with_ts_timestamp_zero

### 198. 删除 消息 Reaction 无效 id 响应

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 删除 消息 Reaction 无效 id 响应
  重点验证接口：ChatManager.removeReaction。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_crud.py::test_chat_remove_reaction_invalid_id_response

### 199. 添加 会话 mark boundaries（参数：info0）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 添加 会话 mark boundaries
  重点验证接口：ChatManager.addRemoteAndLocalConversationsMark。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_conversation_marks_boundaries.py::test_chat_add_conversation_mark_boundaries[info0]

### 200. 添加 会话 mark boundaries（参数：info1）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 添加 会话 mark boundaries
  重点验证接口：ChatManager.addRemoteAndLocalConversationsMark。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_conversation_marks_boundaries.py::test_chat_add_conversation_mark_boundaries[info1]

### 201. 添加 消息 Reaction 特殊字符 消息 Reaction；按被测端实际语义冻结

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 添加 消息 Reaction 特殊字符 消息 Reaction；按被测端实际语义冻结。
  重点验证接口：ChatManager.addReaction。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_reaction_fetch.py::test_chat_add_reaction_special_char_reaction

### 202. 添加空 消息 Reaction：先发送一条消息，再对该消息添加空 消息 Reaction，应视为无效（无事件）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 添加 消息 Reaction 空 消息 Reaction 响应
  重点验证接口：ChatManager.sendMessage、ChatManager.addReaction。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat.py::test_chat_add_reaction_empty_reaction_response

### 203. 为不存在的消息添加 消息 Reaction，不应产生 消息ReactionDidChange

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 添加 消息 Reaction 无效 id 响应
  重点验证接口：ChatManager.addReaction。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat.py::test_chat_add_reaction_invalid_id_response

### 204. 下载 缩略图 无效 id 响应

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：跳过：原生缺陷：无效 msgId 下载原生 NPE（getMessage=null → 原生无校验 NPE；官方应 400/500）。传参已修正为完整 message 对象，等原生补校验后启用
- 源码：native-auto-test/tests/chat/test_chat_crud.py::test_chat_download_thumbnail_invalid_id_response

### 205. 下载 缩略图 用于 文本 消息

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 下载 缩略图 用于 文本 消息
  重点验证接口：ChatManager.downloadThumbnail。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_report_and_thumbnail_additional.py::test_chat_download_thumbnail_for_text_message

### 206. 修改 cmd 消息 应被拒绝

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 修改 cmd 消息 应被拒绝
  重点验证接口：ChatManager.sendMessage、ChatManager.modifyMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_message_modification_matrix.py::test_chat_modify_cmd_message_is_rejected

### 207. 修改不存在的消息，不应产生 消息内容变更回调 事件

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 修改 消息 无效 id 响应
  重点验证接口：ChatManager.modifyMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat.py::test_chat_modify_message_invalid_id_response

### 208. ack 会话 read 使用空会话

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. ack 会话 read 使用空会话
  重点验证接口：ChatManager.ackConversationRead。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_s3_non_message_ops.py::test_chat_ack_conversation_read_empty_conv_id

### 209. ack 会话 read 使用无效会话

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. ack 会话 read 使用无效会话
  重点验证接口：ChatManager.ackConversationRead。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_s3_non_message_ops.py::test_chat_ack_conversation_read_invalid_conv_id

### 210. ack 会话 read 无效 id 响应

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. ack 会话 read 无效 id 响应
  重点验证接口：ChatManager.ackConversationRead。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_crud.py::test_chat_ack_conversation_read_invalid_id_response

### 211. addRemoteAndLocal会话列表Mark/deleteRemoteAndLocal会话列表Mark/获取会话列表By查询条件：添加会话标记后按 查询条件 查询，再移除标记

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. addRemoteAndLocal会话列表Mark/deleteRemoteAndLocal会话列表Mark/获取会话列表By查询条件：添加会话标记后按 查询条件
  重点验证接口：ChatManager.addRemoteAndLocalConversationsMark、ChatManager.loadAllConversations、ChatManager.deleteRemoteAndLocalConversationsMark。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_manager_remaining_api_coverage.py::test_chat_manager_conversation_marks_and_fetch_options

### 212. B 对一个不存在的会话调用 会话已读回执，A 不应在 5s 内收到 会话已读回调

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。原测试目标：B 对一个不存在的会话调用 ackConversationRead，A 不应在 5s 内收到 onConversationHasRead。
- 状态/版本说明：跳过：temporary skip: backend bug under investigation
- 源码：native-auto-test/tests/chat/test_chat.py::test_chat_ack_conversation_read_invalid_id_response

### 213. delete 会话 existing then not found

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. delete 会话 existing then not found
  重点验证接口：ChatManager.deleteConversation、ChatManager.getConversation。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_s1_local_conversation.py::test_chat_delete_conversation_existing_then_not_found

### 214. delete 会话 mark boundaries（参数：info0）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. delete 会话 mark boundaries
  重点验证接口：ChatManager.deleteRemoteAndLocalConversationsMark。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_conversation_marks_boundaries.py::test_chat_delete_conversation_mark_boundaries[info0]

### 215. delete 会话 mark boundaries（参数：info1）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. delete 会话 mark boundaries
  重点验证接口：ChatManager.deleteRemoteAndLocalConversationsMark。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_conversation_marks_boundaries.py::test_chat_delete_conversation_mark_boundaries[info1]

### 216. delete 会话 nonexistent returns bool

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. delete 会话 nonexistent returns bool
  重点验证接口：ChatManager.deleteConversation。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_s1_local_conversation.py::test_chat_delete_conversation_nonexistent_returns_bool

### 217. delete 消息 before timestamp future removes msg

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. delete 消息 before timestamp future removes msg
  重点验证接口：ChatManager.deleteMessagesBeforeTimestamp、ChatManager.getMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_s1_local_conversation.py::test_chat_delete_messages_before_timestamp_future_removes_msg

### 218. delete 消息 before timestamp zero keeps recent msg

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. delete 消息 before timestamp zero keeps recent msg
  重点验证接口：ChatManager.deleteMessagesBeforeTimestamp、ChatManager.getMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_s1_local_conversation.py::test_chat_delete_messages_before_timestamp_zero_keeps_recent_msg

### 219. delete remote 会话 成功

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：5.0 不适用：5.0 移除 cursor 分页（会话查询返回纯 list，无 pageSize 校验）
- 源码：native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_delete_remote_conversation_success

### 220. delete remote 会话 使用空会话

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. delete remote 会话 使用空会话
  重点验证接口：ChatManager.deleteRemoteConversation。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_delete_remote_conversation_empty_conv_id

### 221. delete remote 会话 无效 type

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. delete remote 会话 无效 type
  重点验证接口：ChatManager.deleteRemoteConversation。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_delete_remote_conversation_invalid_type

### 222. deleteAll消息And会话：本地清空所有会话与消息，冻结 clearServerData=False 当前返回

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. deleteAll消息And会话：本地清空所有会话与消息，冻结 clearServerData=False 当前返回。
  重点验证接口：ChatManager.deleteAllMessageAndConversation。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_manager_remaining_api_coverage.py::test_chat_manager_delete_all_message_and_conversation_local

### 223. fetch历史消息 使用不存在的会话 id：严格断言响应形状；若成功体，结果应为空

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 使用无效会话获取历史消息
  重点验证接口：ChatManager.fetchHistoryMessages。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat.py::test_chat_fetch_history_invalid_conversation

### 224. fetchReactionList 传入不存在的 消息 ID 列表；先断言信封

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. fetchReactionList 传入不存在的 消息 ID 列表；先断言信封。
  重点验证接口：ChatManager.fetchReactionList。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_reaction_fetch.py::test_chat_fetch_reaction_list_invalid_msg_id

### 225. fetchReactionList 传入非法 chatType；当前实现返回空 消息 Reaction 列表映射

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. fetchReactionList 传入非法 chatType；当前实现返回空 消息 Reaction 列表映射。
  重点验证接口：ChatManager.fetchReactionList。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_reaction_fetch.py::test_chat_fetch_reaction_list_invalid_chat_type

### 226. fetchReactionList 传入空 消息 IDs；应返回参数错误

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. fetchReactionList 传入空 消息 IDs；应返回参数错误。
  重点验证接口：ChatManager.fetchReactionList。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_reaction_fetch.py::test_chat_fetch_reaction_list_empty_msg_ids

### 227. Generic bridge 实测 Android 会将非布尔 isPinned 按 false 处理

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. Generic bridge 实测 Android 会将非布尔 isPinned 按 false 处理。
  重点验证接口：ChatManager.pinConversation、ChatManager.getConversation。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_conversation_pin_additional.py::test_chat_pin_conversation_non_boolean_coerces_to_unpin

### 228. insert消息/append消息/update会话消息/删除消息/clearAll消息/delete消息WithTs：本地消息写入、更新和删除链路

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. insert消息/append消息/update会话消息/删除消息/clearAll消息/delete消息WithTs：本地消息写入、更新和删
  重点验证接口：ConversationManager.updateConversationMessage、ConversationManager.loadMsgWithId、ConversationManager.removeMessage、ConversationManager.deleteMessagesWithTs、ConversationManager.clearAllMessages。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_conversation_remaining_api_coverage.py::test_conversation_local_insert_append_update_and_delete

### 229. latest消息/last已接收消息：发送一条单聊消息后，分别校验发送方最新消息和接收方最近收到消息

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. latest消息/last已接收消息：发送一条单聊消息后，分别校验发送方最新消息和接收方最近收到消息。
  重点验证接口：ConversationManager.clearAllMessages、ConversationManager.getLatestMessage、ConversationManager.getLatestMessageFromOthers。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_conversation_remaining_api_coverage.py::test_conversation_latest_and_last_received_messages

### 230. mark all as read idempotent

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. mark all as read idempotent
  重点验证接口：ChatManager.markAllChatMsgAsRead、ChatManager.getUnreadMessageCount。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_s1_local_conversation.py::test_chat_mark_all_as_read_idempotent

### 231. pin 撤回 typed 消息（参数：位置-payload0）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. pin 撤回 typed 消息
  重点验证接口：ChatManager.recallMessage、ChatManager.pinMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_message_pin_boundaries.py::test_chat_pin_recalled_typed_message[location-payload0]

### 232. pin 撤回 typed 消息（参数：自定义-payload1）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. pin 撤回 typed 消息
  重点验证接口：ChatManager.recallMessage、ChatManager.pinMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_message_pin_boundaries.py::test_chat_pin_recalled_typed_message[custom-payload1]

### 233. pin 会话 成功 toggle

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. pin 会话 成功 toggle
  重点验证接口：ChatManager.getConversation。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_s3_non_message_ops.py::test_chat_pin_conversation_success_toggle

### 234. pin 会话 使用空会话

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. pin 会话 使用空会话
  重点验证接口：ChatManager.pinConversation。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_s3_non_message_ops.py::test_chat_pin_conversation_empty_conv_id

### 235. pin 会话 使用无效会话

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. pin 会话 使用无效会话
  重点验证接口：ChatManager.pinConversation。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_s3_non_message_ops.py::test_chat_pin_conversation_invalid_conv_id

### 236. pin 会话 nonexistent 会话

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. pin 会话 nonexistent 会话
  重点验证接口：ChatManager.pinConversation。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_crud.py::test_chat_pin_conversation_nonexistent_conversation

### 237. pin 会话 nonexistent 会话

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. pin 会话 nonexistent 会话
  重点验证接口：ChatManager.pinConversation。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat.py::test_chat_pin_conversation_nonexistent_conversation

### 238. pin 消息 无效 id

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. pin 消息 无效 id
  重点验证接口：ChatManager.pinMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_message_pin_boundaries.py::test_chat_pin_message_invalid_id

### 239. re发送消息/updateChat消息/import消息：使用本地构造消息对象覆盖重发、更新和导入的边界/当前返回

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. re发送消息/updateChat消息/import消息：使用本地构造消息对象覆盖重发、更新和导入的边界/当前返回。
  重点验证接口：ChatManager.importMessages、ChatManager.updateChatMessage、ChatManager.resendMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_manager_remaining_api_coverage.py::test_chat_manager_message_object_boundary_methods

### 240. report 撤回 消息

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. report 撤回 消息
  重点验证接口：ChatManager.recallMessage、ChatManager.reportMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_report_message_boundaries.py::test_chat_report_recalled_message

### 241. report 文本 消息 成功

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：5.0 不适用：5.0 移除 reportMessage（残留）
- 源码：native-auto-test/tests/chat/test_chat_report_message_boundaries.py::test_chat_report_text_message_success

### 242. report 消息 成功

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：待补齐：桥接或集成端缺口
- 源码：native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_report_message_success

### 243. report 消息 空 消息 ID

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：5.0 不适用：5.0 移除 reportMessage（残留）
- 源码：native-auto-test/tests/chat/test_chat_report_message_boundaries.py::test_chat_report_message_empty_message_id

### 244. report 消息 空 reason

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. report 消息 空 reason
  重点验证接口：ChatManager.reportMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_report_message_boundaries.py::test_chat_report_message_empty_reason

### 245. report 消息 空 tag

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：5.0 不适用：5.0 移除 reportMessage（残留）
- 源码：native-auto-test/tests/chat/test_chat_report_message_boundaries.py::test_chat_report_message_empty_tag

### 246. report 消息 缺失 reason

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：5.0 不适用：5.0 移除 reportMessage（残留）
- 源码：native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_report_message_missing_reason

### 247. report 消息 缺失 tag

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：5.0 不适用：5.0 移除 reportMessage（残留）
- 源码：native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_report_message_missing_tag

### 248. report 消息 无效 msg id

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：待补齐：桥接或集成端缺口
- 源码：native-auto-test/tests/chat/test_chat_s2_server_ops.py::test_chat_report_message_invalid_msg_id

### 249. sync会话Ext/消息Count/会话GetLocal消息Count/会话RemindType/置顶消息：校验会话扩展、计数、免打扰和置顶消息查询

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. sync会话Ext/消息Count/会话GetLocal消息Count/会话RemindType/置顶消息：校验会话扩展、计数、免打扰
  重点验证接口：ConversationManager.syncConversationExt、ConversationManager.messageCount、ConversationManager.conversationGetLocalMessageCount、ConversationManager.conversationRemindType、ChatManager.pinMessage、ConversationManager.pinnedMessages。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_conversation_remaining_api_coverage.py::test_conversation_ext_and_count_queries

### 250. translate 撤回 smoke exists

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. translate 撤回 smoke exists
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat.py::test_chat_translate_recall_smoke_exists

### 251. translate 消息 空 语言

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. translate 消息 空 语言
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_message_translation_boundaries.py::test_chat_translate_message_empty_languages

### 252. translate 消息 nonexistent 消息

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：跳过：temporary skip: backend bug under investigation
- 源码：native-auto-test/tests/chat/test_chat.py::test_chat_translate_message_nonexistent_message

### 253. translate 消息 unsupported 语言

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. translate 消息 unsupported 语言
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_message_translation_boundaries.py::test_chat_translate_message_unsupported_language

### 254. translate 自定义 消息

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. translate 自定义 消息
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_message_translation_boundaries.py::test_chat_translate_custom_message

### 255. typed 消息 pin and cross user unpin（参数：发送端-位置-payload0）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. typed 消息 pin and cross user unpin
  重点验证接口：ChatManager.pinMessage、ChatManager.fetchPinnedMessages、ChatManager.unpinMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_typed_message_pin_flows.py::test_chat_typed_message_pin_and_cross_user_unpin[sender-location-payload0]

### 256. typed 消息 pin and cross user unpin（参数：发送端-自定义-payload1）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. typed 消息 pin and cross user unpin
  重点验证接口：ChatManager.pinMessage、ChatManager.fetchPinnedMessages、ChatManager.unpinMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_typed_message_pin_flows.py::test_chat_typed_message_pin_and_cross_user_unpin[sender-custom-payload1]

### 257. typed 消息 pin and cross user unpin（参数：接收端-位置-payload0）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. typed 消息 pin and cross user unpin
  重点验证接口：ChatManager.pinMessage、ChatManager.fetchPinnedMessages、ChatManager.unpinMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_typed_message_pin_flows.py::test_chat_typed_message_pin_and_cross_user_unpin[receiver-location-payload0]

### 258. typed 消息 pin and cross user unpin（参数：接收端-自定义-payload1）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. typed 消息 pin and cross user unpin
  重点验证接口：ChatManager.pinMessage、ChatManager.fetchPinnedMessages、ChatManager.unpinMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_typed_message_pin_flows.py::test_chat_typed_message_pin_and_cross_user_unpin[receiver-custom-payload1]

### 259. unpin 消息 空 id

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. unpin 消息 空 id
  重点验证接口：ChatManager.unpinMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_message_pin_boundaries.py::test_chat_unpin_message_empty_id

### 260. unpin 消息 无效 id

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. unpin 消息 无效 id
  重点验证接口：ChatManager.unpinMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_chat_message_pin_boundaries.py::test_chat_unpin_message_invalid_id

### 261. unreadCount/mark消息AsRead/markAll消息AsRead：制造未读后按消息和按会话标记已读，校验计数清零

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. unreadCount/mark消息AsRead/markAll消息AsRead：制造未读后按消息和按会话标记已读，校验计数清零。
  重点验证接口：ConversationManager.markAllMessagesAsRead、ConversationManager.getUnreadMsgCount、ConversationManager.markMessageAsRead。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chat/test_conversation_remaining_api_coverage.py::test_conversation_read_count_and_mark_read

## ChatRoom

### 1. 多端拓扑：A 更新聊天室公告；公告事件同步到 B 全部在线端

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. B 全部在线端加入聊天室
  2. 更新聊天室公告
  3. 确认更新公告请求已提交
  4. B 全部在线端收到公告变更事件
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatRoomManager.updateChatRoomAnnouncement。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_callbacks.py::test_chatroom_announcement_changed_callback

### 2. 多端拓扑：A 建聊天室并添加/移除 B 为管理员；事件同步到 B 全部在线端

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. B 全部在线端加入聊天室
  2. 添加 为聊天室管理员
  3. 确认添加管理员请求已提交
  4. B 全部在线端收到管理员添加事件
  5. 移除 的聊天室管理员
  6. 确认移除管理员请求已提交
  7. B 全部在线端收到管理员移除事件
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatRoomManager.addChatRoomAdmin、ChatRoomManager.removeChatRoomAdmin。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_callbacks.py::test_chatroom_admin_added_and_removed_callbacks

### 3. 多端拓扑：A 将聊天室 owner 转让给 B；owner 变更事件同步到 B 全部在线端

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. B 全部在线端加入聊天室
  2. 转让聊天室 owner 给
  3. 确认转让请求已提交
  4. B 全部在线端收到 owner 变更事件
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatRoomManager.changeChatRoomOwner。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_callbacks.py::test_chatroom_owner_changed_callback

### 4. 多端拓扑：A 禁言/解除 B；B 全部在线端加入，A 全部端查询禁言列表一致

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. B 全部在线端加入聊天室
  2. 禁言
  3. 确认禁言请求已提交
  4. A 全部在线端查询禁言列表均含 B（账号级服务端状态一致）
  5. 解除 禁言
  6. 确认解除禁言请求已提交
  7. A 全部在线端查询禁言列表均不含 B
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatRoomManager.muteChatRoomMembers、ChatRoomManager.fetchChatRoomMuteList、ChatRoomManager.unMuteChatRoomMembers。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_basics.py::test_chatroom_mute_fetch_unmute_member_success

### 5. 多端拓扑：A 禁言/解除禁言 B；禁言事件同步到 B 全部在线端

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. B 全部在线端加入聊天室
  2. 禁言
  3. 确认禁言请求已提交
  4. B 全部在线端收到禁言添加事件
  5. 解除 禁言
  6. 确认解除禁言请求已提交
  7. B 全部在线端收到禁言移除事件
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatRoomManager.muteChatRoomMembers、ChatRoomManager.unMuteChatRoomMembers。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_callbacks.py::test_chatroom_mute_list_added_and_removed_callbacks

### 6. 多端拓扑：A 拉黑/解除 B；B 全部在线端加入，A 全部端查询黑名单一致

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. B 全部在线端加入聊天室
  2. 拉黑
  3. 确认拉黑请求已提交
  4. A 全部在线端查询黑名单均含 B（账号级服务端状态一致）
  5. 解除 拉黑
  6. 确认解除拉黑请求已提交
  7. A 全部在线端查询黑名单均不含 B
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatRoomManager.blockChatRoomMembers、ChatRoomManager.fetchChatRoomBlockList、ChatRoomManager.unBlockChatRoomMembers。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_basics.py::test_chatroom_block_fetch_unblock_member_success

### 7. 多端拓扑：A 全员禁言/解除；状态事件同步到 B 全部在线端

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. B 全部在线端加入聊天室
  2. 全员禁言
  3. 确认全员禁言请求已提交
  4. B 全部在线端收到全员禁言事件（状态 true）
  5. 解除全员禁言
  6. 确认解除全员禁言请求已提交
  7. B 全部在线端收到解除全员禁言事件（状态 false）
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatRoomManager.muteAllChatRoomMembers、ChatRoomManager.unMuteAllChatRoomMembers。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_callbacks.py::test_chatroom_all_member_mute_state_callbacks

### 8. 多端拓扑：A 设置/删除聊天室属性；属性事件同步到 B 全部在线端

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. B 全部在线端加入聊天室
  2. 设置聊天室属性
  3. 确认设置属性请求已提交
  4. B 全部在线端收到属性更新事件
  5. 删除聊天室属性
  6. 确认删除属性请求已提交
  7. B 全部在线端收到属性删除事件
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatRoomManager.setChatRoomAttributes、ChatRoomManager.removeChatRoomAttributes。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_callbacks.py::test_chatroom_attributes_updated_and_removed_callbacks

### 9. 多端拓扑：A 踢出 B；B 全部在线端加入，A 全部端查询成员列表一致（不含 B）

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. B 全部在线端加入聊天室
  2. 踢出
  3. 确认踢出请求已提交
  4. A 全部在线端查询成员列表均不含 B（账号级服务端状态一致）
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatRoomManager.removeChatRoomMembers、ChatRoomManager.fetchChatRoomMembers。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_basics.py::test_chatroom_remove_member_success

### 10. 多端拓扑：A 添加/移除 B 白名单；B 全部在线端加入并可见事件，A 全部端查询白名单一致

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. B 全部在线端加入聊天室
  2. 添加 到白名单
  3. 确认添加白名单请求已提交
  4. A 全部在线端查询白名单均含 B（账号级服务端状态一致）
  5. 从白名单移除
  6. 确认移除白名单请求已提交
  7. A 全部在线端查询白名单均不含 B
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatRoomManager.joinChatRoom、ChatRoomManager.addMembersToChatRoomWhiteList、ChatRoomManager.fetchChatRoomWhiteListFromServer、ChatRoomManager.removeMembersFromChatRoomWhiteList。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_basics.py::test_chatroom_add_fetch_remove_white_list_success

### 11. 多端拓扑：A 添加/移除 B 到白名单；白名单事件同步到 B 全部在线端

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. B 全部在线端加入聊天室
  2. 添加 到白名单
  3. 确认添加白名单请求已提交
  4. B 全部在线端收到白名单添加事件
  5. 从白名单移除
  6. 确认移除白名单请求已提交
  7. B 全部在线端收到白名单移除事件
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatRoomManager.addMembersToChatRoomWhiteList、ChatRoomManager.removeMembersFromChatRoomWhiteList。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_callbacks.py::test_chatroom_allow_list_added_and_removed_callbacks

### 12. 多端拓扑：A 添加/移除 B 为管理员；B 全部在线端加入，A 全部端查询 adminList 一致

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. B 全部在线端加入聊天室
  2. 添加 为管理员
  3. 确认添加管理员请求已提交
  4. A 全部在线端查询 adminList 均含 B（账号级服务端状态一致）
  5. 移除 的管理员
  6. 确认移除管理员请求已提交
  7. A 全部在线端查询 adminList 均不含 B
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatRoomManager.addChatRoomAdmin、ChatRoomManager.fetchChatRoomInfoFromServer、ChatRoomManager.removeChatRoomAdmin。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_basics.py::test_chatroom_add_and_remove_admin_success

### 13. 多端拓扑：A 修改聊天室 subject；规格变更事件同步到 B 全部在线端

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. B 全部在线端加入聊天室
  2. 修改聊天室 subject
  3. 确认修改 subject 请求已提交
  4. B 全部在线端收到规格变更事件
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatRoomManager.changeChatRoomSubject。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_callbacks.py::test_chatroom_specification_changed_callback

### 14. change subject and description 成功

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 修改聊天室名称和描述并验证响应成功
  2. 查询聊天室信息并验证名称和描述已更新
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatRoomManager.changeChatRoomSubject、ChatRoomManager.changeChatRoomDescription、ChatRoomManager.fetchChatRoomInfoFromServer。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_basics.py::test_chatroom_change_subject_and_description_success

### 15. update and 获取 announcement 成功

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 更新聊天室公告并验证响应成功
  2. 查询聊天室公告并验证等于本次设置值
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatRoomManager.updateChatRoomAnnouncement、ChatRoomManager.fetchChatRoomAnnouncement。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_basics.py::test_chatroom_update_and_fetch_announcement_success

### 16. 白名单/禁言自查接口：roomId 为空时，按方法分别冻结 700/Chat room ID is 无效（参数：isMemberInChatRoomMuteList）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 使用空聊天室 ID 查询成员状态并验证参数错误
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_self_checks_empty_room_id[isMemberInChatRoomMuteList]

### 17. 白名单/禁言自查接口：roomId 为空时，按方法分别冻结 700/Chat room ID is 无效（参数：isMemberInChatRoomWhiteListFromServer）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 使用空聊天室 ID 查询成员状态并验证参数错误
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_self_checks_empty_room_id[isMemberInChatRoomWhiteListFromServer]

### 18. 成员 mute list check reflects 服务端 state

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. B 加入聊天室并验证初始不在禁言列表
  2. A 禁言 B 并验证 B 查询到禁言状态
  3. A 解除 B 禁言并验证状态恢复
  重点验证接口：ChatRoomManager.joinChatRoom、ChatRoomManager.isMemberInChatRoomMuteList、ChatRoomManager.muteChatRoomMembers、ChatRoomManager.unMuteChatRoomMembers。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_membership_checks.py::test_chatroom_member_mute_list_check_reflects_server_state

### 19. 成员 white list check reflects 服务端 state

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. B 加入聊天室并验证初始不在白名单
  2. A 添加 B 到白名单并验证 B 可查询到白名单状态
  3. A 移除 B 出白名单并验证状态恢复
  重点验证接口：ChatRoomManager.joinChatRoom、ChatRoomManager.isMemberInChatRoomWhiteListFromServer、ChatRoomManager.addMembersToChatRoomWhiteList、ChatRoomManager.removeMembersFromChatRoomWhiteList。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_membership_checks.py::test_chatroom_member_white_list_check_reflects_server_state

### 20. 成员管理接口：成员列表为空时，逐方法锁定真实错误码与错误描述（参数：addMembersToChatRoomWhiteList-成员-110-usernames is null or 空!）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 提交空成员列表管理请求并验证当前错误响应
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_empty_members[addMembersToChatRoomWhiteList-members-110-usernames is null or empty!]

### 21. 成员管理接口：成员列表为空时，逐方法锁定真实错误码与错误描述（参数：blockChatRoomMembers-成员-110-usernames is null or 空!）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 提交空成员列表管理请求并验证当前错误响应
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_empty_members[blockChatRoomMembers-members-110-usernames is null or empty!]

### 22. 成员管理接口：成员列表为空时，逐方法锁定真实错误码与错误描述（参数：muteChatRoomMembers-muteMembers-602-users [] are not 成员 of this group!）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 提交空成员列表管理请求并验证当前错误响应
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_empty_members[muteChatRoomMembers-muteMembers-602-users [] are not members of this group!]

### 23. 成员管理接口：成员列表为空时，逐方法锁定真实错误码与错误描述（参数：removeChatRoomMembers-成员-300-服务端 is unreachable）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 提交空成员列表管理请求并验证当前错误响应
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_empty_members[removeChatRoomMembers-members-300-Server is unreachable]

### 24. 成员管理接口：成员列表为空时，逐方法锁定真实错误码与错误描述（参数：removeMembersFromChatRoomWhiteList-成员-300-服务端 is unreachable）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 提交空成员列表管理请求并验证当前错误响应
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_empty_members[removeMembersFromChatRoomWhiteList-members-300-Server is unreachable]

### 25. 成员管理接口：成员列表为空时，逐方法锁定真实错误码与错误描述（参数：unBlockChatRoomMembers-成员-300-服务端 is unreachable）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 提交空成员列表管理请求并验证当前错误响应
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_empty_members[unBlockChatRoomMembers-members-300-Server is unreachable]

### 26. 成员管理接口：成员列表为空时，逐方法锁定真实错误码与错误描述（参数：unMuteChatRoomMembers-unMuteMembers-300-服务端 is unreachable）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 提交空成员列表管理请求并验证当前错误响应
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_empty_members[unMuteChatRoomMembers-unMuteMembers-300-Server is unreachable]

### 27. 成员管理接口：传入不存在用户时，逐方法锁定真实错误或幂等成功响应（参数：addChatRoomAdmin-info0-expected0）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 提交不存在用户的成员管理请求并验证真实响应
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_nonexistent_user[addChatRoomAdmin-info0-expected0]

### 28. 成员管理接口：传入不存在用户时，逐方法锁定真实错误或幂等成功响应（参数：addMembersToChatRoomWhiteList-info3-expected3）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 提交不存在用户的成员管理请求并验证真实响应
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_nonexistent_user[addMembersToChatRoomWhiteList-info3-expected3]

### 29. 成员管理接口：传入不存在用户时，逐方法锁定真实错误或幂等成功响应（参数：blockChatRoomMembers-info7-expected7）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 提交不存在用户的成员管理请求并验证真实响应
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_nonexistent_user[blockChatRoomMembers-info7-expected7]

### 30. 成员管理接口：传入不存在用户时，逐方法锁定真实错误或幂等成功响应（参数：changeChatRoomOwner-info2-expected2）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 提交不存在用户的成员管理请求并验证真实响应
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_nonexistent_user[changeChatRoomOwner-info2-expected2]

### 31. 成员管理接口：传入不存在用户时，逐方法锁定真实错误或幂等成功响应（参数：muteChatRoomMembers-info5-expected5）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 提交不存在用户的成员管理请求并验证真实响应
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_nonexistent_user[muteChatRoomMembers-info5-expected5]

### 32. 成员管理接口：传入不存在用户时，逐方法锁定真实错误或幂等成功响应（参数：removeChatRoomAdmin-info1-expected1）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 提交不存在用户的成员管理请求并验证真实响应
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_nonexistent_user[removeChatRoomAdmin-info1-expected1]

### 33. 成员管理接口：传入不存在用户时，逐方法锁定真实错误或幂等成功响应（参数：removeChatRoomMembers-info9-expected9）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 提交不存在用户的成员管理请求并验证真实响应
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_nonexistent_user[removeChatRoomMembers-info9-expected9]

### 34. 成员管理接口：传入不存在用户时，逐方法锁定真实错误或幂等成功响应（参数：removeMembersFromChatRoomWhiteList-info4-None）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 提交不存在用户的成员管理请求并验证真实响应
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_nonexistent_user[removeMembersFromChatRoomWhiteList-info4-None]

### 35. 成员管理接口：传入不存在用户时，逐方法锁定真实错误或幂等成功响应（参数：unBlockChatRoomMembers-info8-room）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 提交不存在用户的成员管理请求并验证真实响应
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_nonexistent_user[unBlockChatRoomMembers-info8-room]

### 36. 成员管理接口：传入不存在用户时，逐方法锁定真实错误或幂等成功响应（参数：unMuteChatRoomMembers-info6-room）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 提交不存在用户的成员管理请求并验证真实响应
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_nonexistent_user[unMuteChatRoomMembers-info6-room]

### 37. 成员管理接口：真实用户未加入聊天室时，逐方法锁定当前成功/失败语义（参数：addChatRoomAdmin-info0-room）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 对未加入成员执行聊天室管理操作并验证成功或错误语义
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_non_member[addChatRoomAdmin-info0-room]

### 38. 成员管理接口：真实用户未加入聊天室时，逐方法锁定当前成功/失败语义（参数：changeChatRoomOwner-info2-owner_changed）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 对未加入成员执行聊天室管理操作并验证成功或错误语义
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_non_member[changeChatRoomOwner-info2-owner_changed]

### 39. 成员管理接口：真实用户未加入聊天室时，逐方法锁定当前成功/失败语义（参数：removeChatRoomAdmin-info1-expected1）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 对未加入成员执行聊天室管理操作并验证成功或错误语义
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_non_member[removeChatRoomAdmin-info1-expected1]

### 40. 成员管理接口：真实用户未加入聊天室时，逐方法锁定当前成功/失败语义（参数：removeChatRoomMembers-info3-expected3）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 对未加入成员执行聊天室管理操作并验证成功或错误语义
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_member_management_non_member[removeChatRoomMembers-info3-expected3]

### 41. 创建 and 获取 从服务端

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：5.0 不适用：5.0 移除客户端 createChatRoom（残留，聊天室由服务端创建）
- 源码：native-auto-test/tests/chatroom/test_chatroom_lifecycle.py::test_chatroom_create_and_fetch_from_server

### 42. 创建 room via sdk without permission

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：5.0 不适用：5.0 移除客户端 createChatRoom（残留，聊天室由服务端创建）
- 源码：native-auto-test/tests/chatroom/test_chatroom_lifecycle.py::test_chatroom_create_room_via_sdk_without_permission

### 43. 获取 成员 带游标 pagination

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. B 加入聊天室并验证首个成员分页结果
  2. 使用返回 cursor 查询下一页并合并成员结果
  重点验证接口：ChatRoomManager.fetchChatRoomMembers。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_member_basics.py::test_chatroom_fetch_members_with_cursor_pagination

### 44. 获取 成员 空 room id

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 使用空聊天室 ID 查询成员并验证参数错误码
  重点验证接口：ChatRoomManager.fetchChatRoomMembers。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_exceptions.py::test_chatroom_fetch_members_empty_room_id

### 45. 获取 成员 after join 成功

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. B 加入聊天室并分页查询成员列表，验证包含 B
  重点验证接口：ChatRoomManager.fetchChatRoomMembers。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_member_basics.py::test_chatroom_fetch_members_after_join_success

### 46. 获取 成员 nonexistent room

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 查询不存在聊天室的成员并验证不存在错误
  重点验证接口：ChatRoomManager.fetchChatRoomMembers。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_exceptions.py::test_chatroom_fetch_members_nonexistent_room

### 47. 获取 公共聊天室 从服务端 成功

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 测试准备：创建公开聊天室
  2. 分页查询公开聊天室并验证新建聊天室条目
  重点验证接口：ChatRoomManager.fetchPublicChatRoomsFromServer。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_server_state.py::test_chatroom_fetch_public_chat_rooms_from_server_success

### 48. 获取 公共聊天室 无效 paging（参数：-1-1）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：5.0 不适用：5.0 移除客户端 destroyChatRoom（残留）
- 源码：native-auto-test/tests/chatroom/test_chatroom_exceptions.py::test_chatroom_fetch_public_chat_rooms_invalid_paging[-1-1]

### 49. 获取 公共聊天室 无效 paging（参数：0-1）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：5.0 不适用：5.0 移除客户端 destroyChatRoom（残留）
- 源码：native-auto-test/tests/chatroom/test_chatroom_exceptions.py::test_chatroom_fetch_public_chat_rooms_invalid_paging[0-1]

### 50. 获取 公共聊天室 无效 paging（参数：1--1）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：5.0 不适用：5.0 移除客户端 destroyChatRoom（残留）
- 源码：native-auto-test/tests/chatroom/test_chatroom_exceptions.py::test_chatroom_fetch_public_chat_rooms_invalid_paging[1--1]

### 51. 获取 公共聊天室 无效 paging（参数：1-0）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：5.0 不适用：5.0 移除客户端 destroyChatRoom（残留）
- 源码：native-auto-test/tests/chatroom/test_chatroom_exceptions.py::test_chatroom_fetch_public_chat_rooms_invalid_paging[1-0]

### 52. 获取 聊天室信息 从服务端 after destroy

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：5.0 不适用：5.0 移除客户端 destroyChatRoom（残留，聊天室由服务端销毁）
- 源码：native-auto-test/tests/chatroom/test_chatroom_lifecycle.py::test_chatroom_fetch_room_info_from_server_after_destroy

### 53. 获取 聊天室信息 带成员信息 从服务端

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. B 加入聊天室并验证成员查询前置
  2. 查询聊天室概要并验证成员计数
  3. 分页查询聊天室成员并验证 B 在列表中
  重点验证接口：ChatRoomManager.joinChatRoom、ChatRoomManager.fetchChatRoomInfoFromServer、ChatRoomManager.fetchChatRoomMembers。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_lifecycle.py::test_chatroom_fetch_room_info_with_members_from_server

### 54. 获取 聊天室信息 空 id

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 使用空聊天室 ID 查询信息并验证参数错误码
  重点验证接口：ChatRoomManager.fetchChatRoomInfoFromServer。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_exceptions.py::test_chatroom_fetch_room_info_empty_id

### 55. 获取 聊天室信息 nonexistent

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 查询不存在聊天室并验证不存在错误
  重点验证接口：ChatRoomManager.fetchChatRoomInfoFromServer。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_exceptions.py::test_chatroom_fetch_room_info_nonexistent

### 56. 获取 属性 按 partial keys 成功

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 设置两项聊天室属性并验证写入成功
  2. 按指定 key 查询属性并验证未返回未请求的 key
  重点验证接口：ChatRoomManager.setChatRoomAttributes、ChatRoomManager.fetchChatRoomAttributes。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_basics.py::test_chatroom_fetch_attributes_by_partial_keys_success

### 57. 获取 all 属性 成功

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 设置多项聊天室属性并验证没有失败 key
  2. 读取全部聊天室属性并验证全部键值
  重点验证接口：ChatRoomManager.setChatRoomAttributes、ChatRoomManager.fetchChatRoomAttributes。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_basics.py::test_chatroom_fetch_all_attributes_success

### 58. 获取 all local rooms returns list

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 读取本地全部聊天室并验证列表及房间 ID 结构
  重点验证接口：ChatRoomManager.getAllChatRooms。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_member_basics.py::test_chatroom_get_all_local_rooms_returns_list

### 59. 获取 local room 空 id returns none

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 使用空聊天室 ID 查询本地房间并验证返回空值
  重点验证接口：ChatRoomManager.getChatRoom。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_member_basics.py::test_chatroom_get_local_room_empty_id_returns_none

### 60. 获取 local room nonexistent returns placeholder

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 查询不存在的本地聊天室并验证返回空值
  重点验证接口：ChatRoomManager.getChatRoom。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_member_basics.py::test_chatroom_get_local_room_nonexistent_returns_placeholder

### 61. 删除 属性 成功

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 设置待删除聊天室属性并验证写入成功
  2. 删除聊天室属性并验证查询结果为空
  重点验证接口：ChatRoomManager.setChatRoomAttributes、ChatRoomManager.removeChatRoomAttributes、ChatRoomManager.fetchChatRoomAttributes。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_basics.py::test_chatroom_remove_attributes_success

### 62. change owner 成功

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. B 加入聊天室并验证转让前置
  2. A 转让聊天室所有权给 B 并验证新 owner
  重点验证接口：ChatRoomManager.changeChatRoomOwner。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_basics.py::test_chatroom_change_owner_success

### 63. changeChatRoomDescription：聊天室描述允许置为空，实测返回完整聊天室对象且 desc 为空字符串

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 将聊天室描述置空并验证返回状态
  重点验证接口：ChatRoomManager.changeChatRoomDescription。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_change_description_empty_success

### 64. changeChatRoomDescription：描述超过 4096 字符，实测返回 703/desc cannot exceed to 4096

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 提交超长聊天室描述并验证长度错误
  重点验证接口：ChatRoomManager.changeChatRoomDescription。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_change_description_too_long

### 65. changeChatRoomSubject：聊天室名称允许置为空，实测返回完整聊天室对象且 name 为空字符串

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 将聊天室名称置空并验证返回的聊天室状态
  重点验证接口：ChatRoomManager.changeChatRoomSubject。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_change_subject_empty_success

### 66. changeChatRoomSubject：名称超过 1024 字符，实测返回 703/title cannot exceed to 1024

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 提交超长聊天室名称并验证长度错误
  重点验证接口：ChatRoomManager.changeChatRoomSubject。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_change_subject_too_long

### 67. destroy room 成功

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：5.0 不适用：5.0 移除客户端 destroyChatRoom（残留，聊天室由服务端销毁）
- 源码：native-auto-test/tests/chatroom/test_chatroom_lifecycle.py::test_chatroom_destroy_room_success

### 68. destroy room 空 id

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：5.0 不适用：5.0 移除客户端 destroyChatRoom（残留）
- 源码：native-auto-test/tests/chatroom/test_chatroom_exceptions.py::test_chatroom_destroy_room_empty_id

### 69. destroy room nonexistent

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：5.0 不适用：5.0 移除客户端 destroyChatRoom（残留）
- 源码：native-auto-test/tests/chatroom/test_chatroom_exceptions.py::test_chatroom_destroy_room_nonexistent

### 70. fetchChatRoomMembers：非法 pageNum/pageSize 当前仍返回 cursor 结构与成员列表（参数：-1-20）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. B 加入聊天室并验证非法成员分页参数仍返回成员列表
  重点验证接口：ChatRoomManager.fetchChatRoomMembers。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_fetch_members_invalid_paging[-1-20]

### 71. fetchChatRoomMembers：非法 pageNum/pageSize 当前仍返回 cursor 结构与成员列表（参数：0-20）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. B 加入聊天室并验证非法成员分页参数仍返回成员列表
  重点验证接口：ChatRoomManager.fetchChatRoomMembers。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_fetch_members_invalid_paging[0-20]

### 72. fetchChatRoomMembers：非法 pageNum/pageSize 当前仍返回 cursor 结构与成员列表（参数：1--1）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. B 加入聊天室并验证非法成员分页参数仍返回成员列表
  重点验证接口：ChatRoomManager.fetchChatRoomMembers。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_fetch_members_invalid_paging[1--1]

### 73. fetchChatRoomMembers：非法 pageNum/pageSize 当前仍返回 cursor 结构与成员列表（参数：1-0）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. B 加入聊天室并验证非法成员分页参数仍返回成员列表
  重点验证接口：ChatRoomManager.fetchChatRoomMembers。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_fetch_members_invalid_paging[1-0]

### 74. fetchChatRoomMuteList/fetchChatRoomBlockList：非法分页参数当前容错返回空列表（参数：fetchChatRoomBlockList--1-20）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 使用非法分页参数查询聊天室成员名单并验证空列表响应
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_server_member_list_invalid_paging[fetchChatRoomBlockList--1-20]

### 75. fetchChatRoomMuteList/fetchChatRoomBlockList：非法分页参数当前容错返回空列表（参数：fetchChatRoomBlockList-0-20）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 使用非法分页参数查询聊天室成员名单并验证空列表响应
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_server_member_list_invalid_paging[fetchChatRoomBlockList-0-20]

### 76. fetchChatRoomMuteList/fetchChatRoomBlockList：非法分页参数当前容错返回空列表（参数：fetchChatRoomBlockList-1--1）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 使用非法分页参数查询聊天室成员名单并验证空列表响应
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_server_member_list_invalid_paging[fetchChatRoomBlockList-1--1]

### 77. fetchChatRoomMuteList/fetchChatRoomBlockList：非法分页参数当前容错返回空列表（参数：fetchChatRoomBlockList-1-0）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 使用非法分页参数查询聊天室成员名单并验证空列表响应
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_server_member_list_invalid_paging[fetchChatRoomBlockList-1-0]

### 78. fetchChatRoomMuteList/fetchChatRoomBlockList：非法分页参数当前容错返回空列表（参数：fetchChatRoomMuteList--1-20）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 使用非法分页参数查询聊天室成员名单并验证空列表响应
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_server_member_list_invalid_paging[fetchChatRoomMuteList--1-20]

### 79. fetchChatRoomMuteList/fetchChatRoomBlockList：非法分页参数当前容错返回空列表（参数：fetchChatRoomMuteList-0-20）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 使用非法分页参数查询聊天室成员名单并验证空列表响应
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_server_member_list_invalid_paging[fetchChatRoomMuteList-0-20]

### 80. fetchChatRoomMuteList/fetchChatRoomBlockList：非法分页参数当前容错返回空列表（参数：fetchChatRoomMuteList-1--1）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 使用非法分页参数查询聊天室成员名单并验证空列表响应
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_server_member_list_invalid_paging[fetchChatRoomMuteList-1--1]

### 81. fetchChatRoomMuteList/fetchChatRoomBlockList：非法分页参数当前容错返回空列表（参数：fetchChatRoomMuteList-1-0）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 使用非法分页参数查询聊天室成员名单并验证空列表响应
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_server_member_list_invalid_paging[fetchChatRoomMuteList-1-0]

### 82. is 成员 in white list and mute list 成功

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 查询聊天室白名单成员状态并验证返回布尔值
  2. 查询聊天室禁言名单成员状态并验证返回布尔值
  重点验证接口：ChatRoomManager.isMemberInChatRoomWhiteListFromServer、ChatRoomManager.isMemberInChatRoomMuteList。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_membership_checks.py::test_chatroom_is_member_in_white_list_and_mute_list_success

### 83. is 成员 in white list and mute list nonexistent room

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 查询不存在聊天室的白名单和禁言名单状态并验证错误
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_membership_checks.py::test_chatroom_is_member_in_white_list_and_mute_list_nonexistent_room

### 84. join public chatroom 成功

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. B 加入聊天室并验证加入响应
  2. A 分页查询聊天室成员并验证包含 B
  重点验证接口：ChatRoomManager.joinChatRoom、ChatRoomManager.fetchChatRoomMembers。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_members.py::test_chatroom_join_public_chatroom_success

### 85. join room 空 id

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：5.0 不适用：5.0 移除客户端 destroyChatRoom（残留）
- 源码：native-auto-test/tests/chatroom/test_chatroom_exceptions.py::test_chatroom_join_room_empty_id

### 86. join room nonexistent

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：5.0 不适用：5.0 移除客户端 destroyChatRoom（残留）
- 源码：native-auto-test/tests/chatroom/test_chatroom_exceptions.py::test_chatroom_join_room_nonexistent

### 87. join then 获取 local room and all rooms

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. B 加入聊天室并验证本地单房间与全部房间查询
  重点验证接口：ChatRoomManager.getChatRoom、ChatRoomManager.getAllChatRooms。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_member_basics.py::test_chatroom_join_then_get_local_room_and_all_rooms

### 88. joinChatRoom：加入方携带头像/昵称等 ext，观察端（其他在线成员）收到同一个成员加入回调 ext

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 观察端加入聊天室，再验证加入方携带 ext 的成员事件
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_members.py::test_chatroom_join_with_ext_member_joined_callback

### 89. joinChatRoom：leaveOtherRooms=false 保留其他聊天室，leaveOtherRooms=true 退出其他聊天室

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. leaveOtherRooms=false：连续加入两个聊天室并验证旧房间保留
  2. leaveOtherRooms=true：准备旧聊天室成员关系
  3. leaveOtherRooms=true：加入新聊天室并验证旧房间退出
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_member_basics.py::test_chatroom_join_leave_other_rooms_option_controls_existing_rooms

### 90. leave room 空 id

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 使用空聊天室 ID 离开并验证幂等成功语义
  重点验证接口：ChatRoomManager.leaveChatRoom。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_exceptions.py::test_chatroom_leave_room_empty_id

### 91. leave room nonexistent

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：5.0 不适用：5.0 移除客户端 destroyChatRoom（残留）
- 源码：native-auto-test/tests/chatroom/test_chatroom_exceptions.py::test_chatroom_leave_room_nonexistent

### 92. leave room updates local cache

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. B 加入后主动离开聊天室并验证离开响应
  2. A 查询成员列表并验证 B 已移除
  重点验证接口：ChatRoomManager.leaveChatRoom、ChatRoomManager.fetchChatRoomMembers。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_member_basics.py::test_chatroom_leave_room_updates_local_cache

### 93. leaveChatRoom 触发成员主动退出回调，校验 roomId/participant

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. A、B 加入聊天室并验证加入前置
  2. B 主动离开并验证 A 收到成员退出事件
  重点验证接口：ChatRoomManager.joinChatRoom、ChatRoomManager.leaveChatRoom。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_callbacks.py::test_chatroom_member_exited_callback

### 94. management api 空 room id（参数：addChatRoomAdmin）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 调用 使用空聊天室 ID 并验证边界响应
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[addChatRoomAdmin]

### 95. management api 空 room id（参数：addMembersToChatRoomWhiteList）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 调用 使用空聊天室 ID 并验证边界响应
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[addMembersToChatRoomWhiteList]

### 96. management api 空 room id（参数：blockChatRoomMembers）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 调用 使用空聊天室 ID 并验证边界响应
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[blockChatRoomMembers]

### 97. management api 空 room id（参数：changeChatRoomDescription）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 调用 使用空聊天室 ID 并验证边界响应
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[changeChatRoomDescription]

### 98. management api 空 room id（参数：changeChatRoomOwner）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 调用 使用空聊天室 ID 并验证边界响应
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[changeChatRoomOwner]

### 99. management api 空 room id（参数：changeChatRoomSubject）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 调用 使用空聊天室 ID 并验证边界响应
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[changeChatRoomSubject]

### 100. management api 空 room id（参数：fetchChatRoomAnnouncement）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 调用 使用空聊天室 ID 并验证边界响应
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[fetchChatRoomAnnouncement]

### 101. management api 空 room id（参数：fetchChatRoomAttributes）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 调用 使用空聊天室 ID 并验证边界响应
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[fetchChatRoomAttributes]

### 102. management api 空 room id（参数：fetchChatRoomBlockList）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 调用 使用空聊天室 ID 并验证边界响应
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[fetchChatRoomBlockList]

### 103. management api 空 room id（参数：fetchChatRoomMuteList）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 调用 使用空聊天室 ID 并验证边界响应
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[fetchChatRoomMuteList]

### 104. management api 空 room id（参数：fetchChatRoomWhiteListFromServer）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 调用 使用空聊天室 ID 并验证边界响应
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[fetchChatRoomWhiteListFromServer]

### 105. management api 空 room id（参数：muteAllChatRoomMembers）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 调用 使用空聊天室 ID 并验证边界响应
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[muteAllChatRoomMembers]

### 106. management api 空 room id（参数：muteChatRoomMembers）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 调用 使用空聊天室 ID 并验证边界响应
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[muteChatRoomMembers]

### 107. management api 空 room id（参数：removeChatRoomAdmin）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 调用 使用空聊天室 ID 并验证边界响应
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[removeChatRoomAdmin]

### 108. management api 空 room id（参数：removeChatRoomAttributes）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 调用 使用空聊天室 ID 并验证边界响应
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[removeChatRoomAttributes]

### 109. management api 空 room id（参数：removeChatRoomMembers）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 调用 使用空聊天室 ID 并验证边界响应
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[removeChatRoomMembers]

### 110. management api 空 room id（参数：removeMembersFromChatRoomWhiteList）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 调用 使用空聊天室 ID 并验证边界响应
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[removeMembersFromChatRoomWhiteList]

### 111. management api 空 room id（参数：setChatRoomAttributes）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 调用 使用空聊天室 ID 并验证边界响应
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[setChatRoomAttributes]

### 112. management api 空 room id（参数：unBlockChatRoomMembers）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 调用 使用空聊天室 ID 并验证边界响应
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[unBlockChatRoomMembers]

### 113. management api 空 room id（参数：unMuteAllChatRoomMembers）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 调用 使用空聊天室 ID 并验证边界响应
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[unMuteAllChatRoomMembers]

### 114. management api 空 room id（参数：unMuteChatRoomMembers）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 调用 使用空聊天室 ID 并验证边界响应
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[unMuteChatRoomMembers]

### 115. management api 空 room id（参数：updateChatRoomAnnouncement）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 调用 使用空聊天室 ID 并验证边界响应
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_empty_room_id[updateChatRoomAnnouncement]

### 116. management api nonexistent room（参数：addChatRoomAdmin）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 调用 访问不存在聊天室并验证错误码
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[addChatRoomAdmin]

### 117. management api nonexistent room（参数：addMembersToChatRoomWhiteList）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 调用 访问不存在聊天室并验证错误码
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[addMembersToChatRoomWhiteList]

### 118. management api nonexistent room（参数：blockChatRoomMembers）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 调用 访问不存在聊天室并验证错误码
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[blockChatRoomMembers]

### 119. management api nonexistent room（参数：changeChatRoomDescription）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 调用 访问不存在聊天室并验证错误码
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[changeChatRoomDescription]

### 120. management api nonexistent room（参数：changeChatRoomOwner）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 调用 访问不存在聊天室并验证错误码
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[changeChatRoomOwner]

### 121. management api nonexistent room（参数：changeChatRoomSubject）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 调用 访问不存在聊天室并验证错误码
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[changeChatRoomSubject]

### 122. management api nonexistent room（参数：fetchChatRoomAnnouncement）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 调用 访问不存在聊天室并验证错误码
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[fetchChatRoomAnnouncement]

### 123. management api nonexistent room（参数：fetchChatRoomAttributes）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 调用 访问不存在聊天室并验证错误码
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[fetchChatRoomAttributes]

### 124. management api nonexistent room（参数：fetchChatRoomBlockList）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 调用 访问不存在聊天室并验证错误码
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[fetchChatRoomBlockList]

### 125. management api nonexistent room（参数：fetchChatRoomMuteList）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 调用 访问不存在聊天室并验证错误码
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[fetchChatRoomMuteList]

### 126. management api nonexistent room（参数：fetchChatRoomWhiteListFromServer）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 调用 访问不存在聊天室并验证错误码
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[fetchChatRoomWhiteListFromServer]

### 127. management api nonexistent room（参数：muteAllChatRoomMembers）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 调用 访问不存在聊天室并验证错误码
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[muteAllChatRoomMembers]

### 128. management api nonexistent room（参数：muteChatRoomMembers）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 调用 访问不存在聊天室并验证错误码
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[muteChatRoomMembers]

### 129. management api nonexistent room（参数：removeChatRoomAdmin）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 调用 访问不存在聊天室并验证错误码
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[removeChatRoomAdmin]

### 130. management api nonexistent room（参数：removeChatRoomAttributes）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 调用 访问不存在聊天室并验证错误码
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[removeChatRoomAttributes]

### 131. management api nonexistent room（参数：removeChatRoomMembers）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 调用 访问不存在聊天室并验证错误码
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[removeChatRoomMembers]

### 132. management api nonexistent room（参数：removeMembersFromChatRoomWhiteList）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 调用 访问不存在聊天室并验证错误码
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[removeMembersFromChatRoomWhiteList]

### 133. management api nonexistent room（参数：setChatRoomAttributes）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 调用 访问不存在聊天室并验证错误码
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[setChatRoomAttributes]

### 134. management api nonexistent room（参数：unBlockChatRoomMembers）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 调用 访问不存在聊天室并验证错误码
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[unBlockChatRoomMembers]

### 135. management api nonexistent room（参数：unMuteAllChatRoomMembers）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 调用 访问不存在聊天室并验证错误码
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[unMuteAllChatRoomMembers]

### 136. management api nonexistent room（参数：unMuteChatRoomMembers）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 调用 访问不存在聊天室并验证错误码
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[unMuteChatRoomMembers]

### 137. management api nonexistent room（参数：updateChatRoomAnnouncement）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 调用 访问不存在聊天室并验证错误码
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_exceptions.py::test_chatroom_management_api_nonexistent_room[updateChatRoomAnnouncement]

### 138. mute and unmute all 成员 成功

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 开启全员禁言并验证聊天室状态
  2. 解除全员禁言并验证聊天室状态恢复
  重点验证接口：ChatRoomManager.muteAllChatRoomMembers、ChatRoomManager.fetchChatRoomInfoFromServer、ChatRoomManager.unMuteAllChatRoomMembers。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_basics.py::test_chatroom_mute_and_unmute_all_members_success

### 139. removeChatRoomAttributes：keys 为空列表时，实测返回 110 且 description 为空字符串

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 提交空聊天室属性 key 列表并验证参数错误
  重点验证接口：ChatRoomManager.removeChatRoomAttributes。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_remove_attributes_empty_keys

### 140. removed and destroyed callbacks

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. B 加入聊天室，A 移除 B 并验证移除事件
  2. B 重新加入后销毁聊天室并验证销毁事件
  重点验证接口：ChatRoomManager.removeChatRoomMembers。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_callbacks.py::test_chatroom_removed_and_destroyed_callbacks

### 141. set and 获取 属性 成功

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 设置聊天室属性并验证没有失败 key
  2. 读取指定聊天室属性并验证值一致
  重点验证接口：ChatRoomManager.setChatRoomAttributes、ChatRoomManager.fetchChatRoomAttributes。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_basics.py::test_chatroom_set_and_fetch_attributes_success

### 142. setChatRoomAttributes：属性 为空 map 时，实测返回 110 且 description 为空字符串

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 提交空聊天室属性 map 并验证参数错误
  重点验证接口：ChatRoomManager.setChatRoomAttributes。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_add_attributes_empty_map

### 143. update 属性 overwrites previous value

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 先写入旧属性值，再写入新值验证覆盖请求成功
  2. 读取覆盖后的属性并验证已是新值
  重点验证接口：ChatRoomManager.setChatRoomAttributes、ChatRoomManager.fetchChatRoomAttributes。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_basics.py::test_chatroom_update_attribute_overwrites_previous_value

### 144. updateChatRoomAnnouncement：公告允许置为空，实测返回 True

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 将聊天室公告置空并验证返回成功
  重点验证接口：ChatRoomManager.updateChatRoomAnnouncement。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/chatroom/test_chatroom_management_boundaries.py::test_chatroom_update_announcement_empty

## Client

### 1. 验证登录后能收到 on离线消息yncStart 回调

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 测试准备：退出当前会话并清理历史事件
  2. 测试准备：清理登录前残留事件
  3. 重新登录并验证登录成功
  4. 启动回调并等待离线同步事件
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：Client.logout、Client.login、Client.startCallback。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/client/test_client.py::test_login_then_receive_offline_sync_event

### 2. 错误密码：预期返回错误响应；若服务端仅返回 result=None 也视为合法响应

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 使用错误密码登录并验证失败响应语义
  重点验证接口：Client.login。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/client/test_client.py::test_client_login_invalid_password

### 3. compressLogs：压缩本地日志，校验返回压缩文件路径字符串

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 压缩客户端日志并验证返回文件路径
  重点验证接口：Client.compressLogs。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_compress_logs_returns_path

### 4. createAccount：空 userId/password 边界，冻结真实模拟器参数校验错误，不创建新账号

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。原测试目标：createAccount：空 userId/password 边界，冻结真实模拟器参数校验错误，不创建新账号。
- 状态/版本说明：5.0 不适用：5.0 移除客户端 createAccount（残留，注册走 REST）
- 源码：native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_create_account_empty_user_boundary

### 5. getToken / getCurrentDeviceId：已登录 session 下获取 token 和当前设备信息，校验关键字段非空

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 读取当前登录令牌并验证非空
  2. 读取当前设备信息并验证返回结构非空
  重点验证接口：Client.getToken、Client.getCurrentDeviceId。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_current_token_and_device_id

### 6. init：SDK 已初始化后重复调用，验证原生幂等返回 result=null，不改变当前登录态

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 重复初始化客户端并验证幂等返回
  2. 验证重复初始化未清空当前登录用户
  重点验证接口：Client.init、Client.getCurrentUser。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_init_repeated_call_idempotent

### 7. isConnected / isLoggedInBefore：已登录 session 下查询连接态和历史登录态，均应返回 true

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 查询连接状态并验证当前连接正常
  2. 查询历史登录状态并验证登录记录存在
  重点验证接口：Client.isConnected、Client.isLoggedInBefore。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_connection_state_queries

### 8. renew/changeAppKey/device-kick 类方法：使用不会破坏当前 session 的边界入参冻结真实错误返回（参数：changeAppKey-info1-expected_result1）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 执行会话敏感接口边界参数并验证错误语义
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_session_sensitive_api_boundaries[changeAppKey-info1-expected_result1]

### 9. renew/changeAppKey/device-kick 类方法：使用不会破坏当前 session 的边界入参冻结真实错误返回（参数：getLoggedInDevicesFromServer-info2-expected_result2）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 执行会话敏感接口边界参数并验证错误语义
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_session_sensitive_api_boundaries[getLoggedInDevicesFromServer-info2-expected_result2]

### 10. renew/changeAppKey/device-kick 类方法：使用不会破坏当前 session 的边界入参冻结真实错误返回（参数：kickAllDevices-info4-expected_result4）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 执行会话敏感接口边界参数并验证错误语义
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_session_sensitive_api_boundaries[kickAllDevices-info4-expected_result4]

### 11. renew/changeAppKey/device-kick 类方法：使用不会破坏当前 session 的边界入参冻结真实错误返回（参数：kickDevice-info3-expected_result3）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 执行会话敏感接口边界参数并验证错误语义
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_session_sensitive_api_boundaries[kickDevice-info3-expected_result3]

### 12. renew/changeAppKey/device-kick 类方法：使用不会破坏当前 session 的边界入参冻结真实错误返回（参数：loginWithAgoraToken-info5-expected_result5）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 执行会话敏感接口边界参数并验证错误语义
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_session_sensitive_api_boundaries[loginWithAgoraToken-info5-expected_result5]

### 13. renew/changeAppKey/device-kick 类方法：使用不会破坏当前 session 的边界入参冻结真实错误返回（参数：renewToken-info0-expected_result0）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 执行会话敏感接口边界参数并验证错误语义
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_session_sensitive_api_boundaries[renewToken-info0-expected_result0]

### 14. session 已登录 deviceA，校验 changeAppId 调用成功

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 切换应用标识并验证调用成功
  重点验证接口：Client.changeAppId。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/client/test_client.py::test_client_change_app_id

### 15. session 已登录 deviceA，校验 getCurrentUser 返回当前用户

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 查询当前登录用户并验证返回用户信息
  重点验证接口：Client.getCurrentUser。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/client/test_client.py::test_client_get_current_user

### 16. update*Setting：逐项更新运行时配置，冻结真实模拟器返回 result=null 的成功语义（参数：acceptInvitationAlways-info6）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 更新客户端运行时配置并验证设置成功
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_update_runtime_setting_success[acceptInvitationAlways-info6]

### 17. update*Setting：逐项更新运行时配置，冻结真实模拟器返回 result=null 的成功语义（参数：update送达AckSetting-info8）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 更新客户端运行时配置并验证设置成功
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_update_runtime_setting_success[updateDeliveryAckSetting-info8]

### 18. update*Setting：逐项更新运行时配置，冻结真实模拟器返回 result=null 的成功语义（参数：update消息接收CallbackInclude发送Setting-info10）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 更新客户端运行时配置并验证设置成功
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_update_runtime_setting_success[updateMessagesReceiveCallbackIncludeSendSetting-info10]

### 19. update*Setting：逐项更新运行时配置，冻结真实模拟器返回 result=null 的成功语义（参数：updateAuto下载附件ThumbnailSetting-info7）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 更新客户端运行时配置并验证设置成功
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_update_runtime_setting_success[updateAutoDownloadAttachmentThumbnailSetting-info7]

### 20. update*Setting：逐项更新运行时配置，冻结真实模拟器返回 result=null 的成功语义（参数：updateAutoAcceptGroupInvitationSetting-info5）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 更新客户端运行时配置并验证设置成功
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_update_runtime_setting_success[updateAutoAcceptGroupInvitationSetting-info5]

### 21. update*Setting：逐项更新运行时配置，冻结真实模拟器返回 result=null 的成功语义（参数：updateDelete消息WhenLeaveGroupSetting-info2）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 更新客户端运行时配置并验证设置成功
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_update_runtime_setting_success[updateDeleteMessagesWhenLeaveGroupSetting-info2]

### 22. update*Setting：逐项更新运行时配置，冻结真实模拟器返回 result=null 的成功语义（参数：updateDelete消息WhenLeaveRoomSetting-info3）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 更新客户端运行时配置并验证设置成功
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_update_runtime_setting_success[updateDeleteMessageWhenLeaveRoomSetting-info3]

### 23. update*Setting：逐项更新运行时配置，冻结真实模拟器返回 result=null 的成功语义（参数：updateLoginExtensionInfo-info1）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 更新客户端运行时配置并验证设置成功
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_update_runtime_setting_success[updateLoginExtensionInfo-info1]

### 24. update*Setting：逐项更新运行时配置，冻结真实模拟器返回 result=null 的成功语义（参数：updateRegrade消息Setting-info11）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 更新客户端运行时配置并验证设置成功
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_update_runtime_setting_success[updateRegradeMessagesSetting-info11]

### 25. update*Setting：逐项更新运行时配置，冻结真实模拟器返回 result=null 的成功语义（参数：updateRoomOwnerCanLeaveSetting-info4）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 更新客户端运行时配置并验证设置成功
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_update_runtime_setting_success[updateRoomOwnerCanLeaveSetting-info4]

### 26. update*Setting：逐项更新运行时配置，冻结真实模拟器返回 result=null 的成功语义（参数：updateSort消息ByServerTimeSetting-info9）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 更新客户端运行时配置并验证设置成功
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_update_runtime_setting_success[updateSortMessageByServerTimeSetting-info9]

### 27. update*Setting：逐项更新运行时配置，冻结真实模拟器返回 result=null 的成功语义（参数：updateUsingHttpsOnlySetting-info0）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 更新客户端运行时配置并验证设置成功
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/client/test_client_remaining_api_coverage.py::test_client_update_runtime_setting_success[updateUsingHttpsOnlySetting-info0]

## Contact

### 1. 多端拓扑：A 拉黑 B → A 全部端黑名单含 B、好友列表不含 B，B 全部端好友列表仍含 A；A 取消拉黑后好友恢复

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。原测试目标：多端拓扑：A 拉黑 B → A 全部端黑名单含 B、好友列表不含 B，B 全部端好友列表仍含 A；A 取消拉黑后好友恢复。
- 状态/版本说明：5.0 不适用：5.0 移除 fetchContacts/fetchAllContactIds/getAllContactIds（残留，无分页拉联系人）
- 源码：native-auto-test/tests/contact/test_contact.py::test_contact_block_list_flow_then_unblock_restores_friend

### 2. 多端拓扑：REST 修改 B 用户属性后，A 全部在线端拉取 B 的用户信息一致（userId/remark/updatedAt）

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 与 B 建立好友
  2. 测试准备：清理历史事件
  3. 通过 REST 修改 B 的用户元数据
  4. A 全部在线端拉取 B 的用户信息一致
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ContactManager.getContact。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/contact/test_friend_info_sync.py::test_friend_info_sync_on_peer_metadata_change

### 3. 发送账号添加接收账号为好友（申请回调接收账号全部在线端收到），接收端拒绝后 发送端收到拒绝回调；双方好友列表均不应包含对方

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 向 发送好友申请
  2. 接收账号端 收到好友申请回调（INVITED）
  3. 拒绝好友申请（declineInvitation）
  4. 收到拒绝回调（INVITATION_DECLINED）
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ContactManager.addContact、ContactManager.declineInvitation、ContactManager.getAllContactsFromDB。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/contact/test_contact.py::test_friend_add_decline_and_verify_not_friends

### 4. 发送账号添加接收账号为好友（申请回调接收账号全部在线端收到），接收端同意后 发送端收到同意回调，分别获取双方好友列表，最后发送端删除好友

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 向 发送好友申请
  2. 接收账号端 收到好友申请回调（INVITED）
  3. 同意好友申请（acceptInvitation）
  4. 收到同意回调（INVITATION_ACCEPTED）
  5. 删除好友
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ContactManager.addContact、ContactManager.acceptInvitation、ContactManager.getAllContactsFromDB、ContactManager.deleteContact。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/contact/test_contact.py::test_friend_add_accept_and_list

### 5. addUserToBlockList：拉黑不存在用户，预期失败

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。原测试目标：addUserToBlockList：拉黑不存在用户，预期失败。
- 状态/版本说明：5.0 不适用：5.0 移除分页拉联系人（fetchContacts 本地全量，忽略 pageSize）—— 负数边界校验不存在
- 源码：native-auto-test/tests/contact/test_contact.py::test_contact_add_user_to_block_list_nonexistent

### 6. deleteContact：目标用户不存在，预期失败

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 删除不存在用户并验证用户不存在错误
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ContactManager.deleteContact。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/contact/test_contact.py::test_contact_delete_contact_nonexistent_user

### 7. 5.0 Contact 数据同步：配置 CONTACTS 数据同步后重新登录，验证 Client 层原生数据同步开始/完成事件能够通过测试桥接到达

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。原测试目标：5.0 Contact 数据同步：配置 CONTACTS 数据同步后重新登录，验证 Client 层原生数据同步开始/完成事件能够通过测试桥接到达。 该用例不依赖 4.x 的 onFriendStartSync/onFriendSyncFinished 回调。
- 状态/版本说明：待补齐：桥接或集成端缺口
- 源码：native-auto-test/tests/contact/test_friend_info_sync.py::test_contact_data_sync_events_after_relogin

### 8. A 离线期间 B 删除好友；A 重登收到删除事件且双方关系清空

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 测试准备：建立好友关系并让申请账号全部端点离线
  2. 接收账号删除好友并验证动作响应
  3. 申请账号全部端点重新登录并验证主端离线删除事件与最终状态
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：ContactManager.deleteContact。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/contact/test_contact_offline_friendship.py::test_contact_offline_requester_receives_peer_delete_after_relogin

### 9. B 登录收到离线申请后拒绝，A 收到拒绝事件且双方保持非好友

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 测试准备：发送好友申请并让接收账号恢复全部端点
  2. 接收账号动作端拒绝好友申请并验证响应
  3. 验证拒绝事件及双方全部端点的非好友状态
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：ContactManager.declineInvitation。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/contact/test_contact_offline_friendship.py::test_contact_offline_invitation_decline_after_login

### 10. B 登录收到离线申请后同意，A 收到接受与联系人新增事件

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 测试准备：发送好友申请并让接收账号恢复全部端点
  2. 接收账号动作端同意好友申请并验证响应
  3. 验证关键接受事件及双方全部端点的最终好友状态
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：ContactManager.acceptInvitation。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/contact/test_contact_offline_friendship.py::test_contact_offline_invitation_accept_after_login

### 11. B 离线期间 A 删除好友；B 重登收到删除事件且双方关系清空

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 测试准备：建立好友关系并让接收账号全部端点离线
  2. 申请账号删除好友并验证动作响应
  3. 接收账号全部端点重新登录并验证主端离线删除事件与最终状态
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：ContactManager.deleteContact。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/contact/test_contact_offline_friendship.py::test_contact_offline_recipient_receives_delete_after_relogin

### 12. B 收到申请后让 A 离线；B 拒绝，A 重登收到离线拒绝结果

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 测试准备：发送好友申请后让申请账号全部端点离线
  2. 接收账号拒绝好友申请并验证动作端响应
  3. 申请账号全部端点重新登录并验证离线拒绝事件与最终状态
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：ContactManager.declineInvitation。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/contact/test_contact_offline_friendship.py::test_contact_offline_requester_receives_decline_after_relogin

### 13. B 收到申请后让 A 离线；B 同意，A 重登收到离线接受结果

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 测试准备：发送好友申请后让申请账号全部端点离线
  2. 接收账号同意好友申请并验证动作端响应
  3. 申请账号全部端点重新登录并验证离线接受事件与最终好友状态
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：ContactManager.acceptInvitation。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/contact/test_contact_offline_friendship.py::test_contact_offline_requester_receives_accept_after_relogin

### 14. B 先离线，A 发起申请；B 登录收到邀请，但双方仍不是好友

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 测试准备：让接收账号全部端点离线并发送好友申请
  2. 接收账号逐端登录并验证离线好友申请已消费
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/contact/test_contact_offline_friendship.py::test_contact_offline_invitation_received_after_login

### 15. getSelfIdsOnOtherPlatform：先确保当前账号只有 deviceA 在线，再严格验证空列表

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 测试准备：确保其他平台设备退出登录
  2. 查询当前账号其他平台设备并验证列表为空
  3. 测试后置：恢复其他平台设备登录
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：ContactManager.getSelfIdsOnOtherPlatform。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/contact/test_contact_remaining_api_coverage.py::test_contact_get_self_ids_on_other_platform_returns_list

### 16. 备注为 101 长度且含特殊字符

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：建立好友关系
  2. 设置超长特殊字符备注并验证长度错误
  3. 测试后置：删除好友关系
  重点验证接口：ContactManager.setContactRemark。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/contact/test_contact.py::test_contact_remark_special_chars_length_101

### 17. 成为好友后将备注设为空字符串

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：建立好友关系
  2. A 设置空好友备注并验证请求成功
  3. 查询好友资料并验证备注为空
  4. 测试后置：删除好友关系
  重点验证接口：ContactManager.setContactRemark、ContactManager.getContact。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/contact/test_contact.py::test_contact_remark_empty_string

### 18. 获取 all contact ids

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：5.0 不适用：5.0 移除 fetchContacts/fetchAllContactIds/getAllContactIds（残留，无分页拉联系人）
- 源码：native-auto-test/tests/contact/test_contact.py::test_contact_fetch_all_contact_ids

### 19. 获取 all contact ids

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：5.0 不适用：5.0 移除 fetchContacts/fetchAllContactIds/getAllContactIds（残留，无分页拉联系人）
- 源码：native-auto-test/tests/contact/test_contact.py::test_contact_get_all_contact_ids

### 20. 加好友并设置备注后：getAllContactsFromDB 本地读取； 再验证 fetchAllContacts（本地好友）、getContact、getAllContacts（本地）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：建立好友关系并设置备注
  2. A 设置好友备注并验证成功
  3. 读取本地联系人 ID 列表并验证包含 B
  4. 读取本地全部联系人并验证 B 存在
  5. 读取单个联系人并验证备注
  6. 读取全部本地联系人对象并验证 B 存在
  7. 测试后置：删除好友关系
  重点验证接口：ContactManager.setContactRemark、ContactManager.getAllContactsFromDB、ContactManager.fetchAllContacts、ContactManager.getContact、ContactManager.getAllContacts。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/contact/test_contact.py::test_contact_fetch_all_fetch_page_fetch_ids_get_local_lists

### 21. 已是好友但未加入黑名单时调用 removeUserFromBlockList

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 测试准备：清理关系并建立好友关系
  2. 查询黑名单并验证好友不在黑名单
  3. 移除未加入的黑名单成员并验证幂等成功
  4. 测试后置：删除好友关系
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/contact/test_contact.py::test_contact_remove_from_block_list_when_not_blocked

### 22. A 删除 B 后再次添加并同意，先前备注一般不应保留（以服务端为准；此处断言与旧备注不同或为空）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。原测试目标：A 删除 B 后再次添加并同意，先前备注一般不应保留（以服务端为准；此处断言与旧备注不同或为空）。
- 状态/版本说明：5.0 不适用：5.0 getContact 为本地拉取（fetchContactFromLocal），本地 EMContact 不携带 remark（恒空）—— 备注保留/失效语义无法通过 getContact 验证；需服务端拉取 API（如有）
- 源码：native-auto-test/tests/contact/test_contact.py::test_contact_remark_not_preserved_after_delete_and_readd

### 23. A 添加 B、B 同意后，A 调用 setContactRemark 并严格验证 5.0 原生成功响应

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：建立好友关系
  2. A 设置好友备注并验证请求成功
  3. 测试后置：删除好友关系
  重点验证接口：ContactManager.setContactRemark。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/contact/test_contact.py::test_contact_remark_set_success

### 24. acceptInvitation：无待处理邀请时同意某用户

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 无待处理邀请时同意好友申请并验证返回语义
  2. 查询目标用户好友关系并验证列表为空
  重点验证接口：ContactManager.acceptInvitation。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/contact/test_contact.py::test_contact_accept_invitation_without_pending

### 25. addContact：不能添加自己为好友，预期失败

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 添加自己为好友并验证参数错误
  重点验证接口：ContactManager.addContact。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/contact/test_contact.py::test_contact_add_self

### 26. addContact：目标用户不存在，预期失败（顶层 error）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 添加不存在用户并验证用户不存在错误
  重点验证接口：ContactManager.addContact。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/contact/test_contact.py::test_contact_add_nonexistent_user

### 27. addContact：userId 为空字符串，预期参数非法类错误

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 使用空用户 ID 添加好友并验证参数错误
  重点验证接口：ContactManager.addContact。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/contact/test_contact.py::test_contact_add_empty_user_id

### 28. declineInvitation：对方从未发起邀请（不存在用户 / 无待处理邀请）时拒绝，按服务端实际响应断言

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 无待处理邀请时拒绝好友申请并验证返回语义
  重点验证接口：ContactManager.declineInvitation。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/contact/test_contact.py::test_contact_decline_invitation_without_pending

### 29. deleteContact：对方非好友（未建立好友关系），预期失败

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 删除非好友并验证当前返回语义
  重点验证接口：ContactManager.deleteContact。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/contact/test_contact.py::test_contact_delete_contact_not_friend

### 30. fetchContacts：pageSize 大于 50（5.0 已移除分页，忽略 pageSize）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。原测试目标：fetchContacts：pageSize 大于 50（5.0 已移除分页，忽略 pageSize）。
- 状态/版本说明：5.0 不适用：5.0 移除分页拉联系人（fetchContacts 改为本地全量 asyncFetchAllContactsFromLocal，忽略 pageSize）—— pageSize 边界校验不存在，case 语义失效
- 源码：native-auto-test/tests/contact/test_contact.py::test_contact_fetch_contacts_page_size_exceeds_50

### 31. fetchContacts：pageSize 为 0（5.0 已移除分页，忽略 pageSize）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。原测试目标：fetchContacts：pageSize 为 0（5.0 已移除分页，忽略 pageSize）。
- 状态/版本说明：5.0 不适用：5.0 移除分页拉联系人（fetchContacts 改为本地全量 asyncFetchAllContactsFromLocal，忽略 pageSize）—— pageSize 边界校验不存在，case 语义失效
- 源码：native-auto-test/tests/contact/test_contact.py::test_contact_fetch_contacts_page_size_zero

### 32. fetchContacts：pageSize 为负数（5.0 已移除分页，忽略 pageSize）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。原测试目标：fetchContacts：pageSize 为负数（5.0 已移除分页，忽略 pageSize）。
- 状态/版本说明：5.0 不适用：5.0 移除分页拉联系人（fetchContacts 本地全量，忽略 pageSize）—— 超出 50 的边界校验不存在
- 源码：native-auto-test/tests/contact/test_contact.py::test_contact_fetch_contacts_page_size_negative

### 33. getAllContactsFromDB：建立好友后，从本地 DB 获取好友 ID 列表（5.0 本地读取；原 getAllContactsFromServer 服务端拉取已移除）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 测试准备：建立好友关系并完成本地同步
  2. 读取本地联系人 ID 并验证包含 B
  3. 测试后置：删除好友关系
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/contact/test_contact_remaining_api_coverage.py::test_contact_get_all_contacts_from_db_after_server_sync

### 34. getBlockListFromDB：拉黑并同步服务端黑名单后，从本地 DB 获取黑名单 ID 列表

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 测试准备：建立好友关系并加入黑名单
  2. 查询服务端黑名单并验证包含 B
  3. 读取本地黑名单并验证包含 B
  4. 测试后置：移出黑名单并删除好友关系
  重点验证接口：ContactManager.getBlockListFromServer、ContactManager.getBlockListFromDB。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/contact/test_contact_remaining_api_coverage.py::test_contact_get_block_list_from_db_after_server_sync

### 35. getBlockListFromServer：从服务器拉黑名单，result 为列表（可为空）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 查询服务端黑名单并验证返回列表
  重点验证接口：ContactManager.getBlockListFromServer。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/contact/test_contact.py::test_contact_get_block_list_from_server_returns_list

### 36. removeUserFromBlockList：目标用户不存在，服务端幂等返回成功（HTTP 200），result 为用户名

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 移除不存在用户的黑名单关系并验证幂等返回
  重点验证接口：ContactManager.removeUserFromBlockList。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/contact/test_contact.py::test_contact_remove_from_block_list_nonexistent_user

### 37. setContactRemark：对非好友设置备注，预期失败

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 为非好友设置备注并验证好友关系错误
  重点验证接口：ContactManager.setContactRemark。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/contact/test_contact.py::test_contact_set_contact_remark_non_friend

## Group

### 1. 成员申请入群并由群主拒绝：申请/拒绝事件同步到收发账号全部在线端

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. B 申请加入公开群
  3. 验证申请加入公开群返回的响应 result 与关键字段
  4. 等待并校验目标业务事件
  5. 发送账号全部在线端同步验证入群申请事件
  6. A 拒绝入群申请
  7. 验证拒绝入群申请返回的响应 result 与关键字段
  8. 接收账号全部在线端同步验证申请拒绝事件
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：GroupManager.requestToJoinPublicGroup、GroupManager.declineJoinApplication、GroupManager.getGroupSpecificationFromServer。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_join_requests_and_invitations.py::test_group_request_to_join_and_decline_success

### 2. 成员申请入群并由群主同意：申请/同意事件同步到收发账号全部在线端

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. B 申请加入公开群
  3. 验证申请加入公开群返回的响应 result 与关键字段
  4. 等待并校验目标业务事件
  5. 发送账号全部在线端同步验证入群申请事件
  6. A 同意入群申请
  7. 验证同意入群申请返回的响应 result 与关键字段
  8. 接收账号全部在线端同步验证申请通过事件
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：GroupManager.requestToJoinPublicGroup、GroupManager.acceptJoinApplication、GroupManager.getGroupSpecificationFromServer。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_join_requests_and_invitations.py::test_group_request_to_join_and_accept_success

### 3. 当前群主不能退群；转让后新群主 B 收到 owner 变更事件，A 退出后 B 收到成员退出事件

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 退出群
  3. 验证退出群返回的错误码与错误文案
  4. A 转让群主
  5. 验证转让群主返回的关键字段
  6. B 账号全部在线端消费 owner 变更事件
  7. 验证群业务状态、事件与关键字段
  8. B 账号全部在线端收到成员退出事件
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：GroupManager.leaveGroup、GroupManager.updateGroupOwner。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_owner_removal_matrix.py::test_group_owner_must_transfer_before_leaving

### 4. 多端拓扑：A 建 PublicOpenJoin 公开群，B 加入/退出；成员事件同步到 A 全部在线端，A 全部端查询成员快照一致

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 建 PublicOpenJoin 公开群
  2. 加入公开群
  3. 确认加入请求已提交
  4. A 全部在线端收到成员加入事件
  5. A 全部在线端查询成员快照均含 B（账号级服务端状态一致）
  6. 退出公开群
  7. 确认退出请求已提交
  8. A 全部在线端收到成员退出事件
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：GroupManager.joinPublicGroup、GroupManager.getGroupMemberListFromServer、GroupManager.leaveGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_members.py::test_group_join_and_leave_public_group

### 5. 多端拓扑：A 建群并邀请 B；邀请/自动接受事件同步到 B 全部在线端，成员加入事件同步到 A 全部在线端

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 建群并邀请
  2. B 全部在线端收到邀请/自动接受事件
  3. A 全部在线端收到成员加入事件
  4. 测试后置：销毁测试群并恢复群状态
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_lifecycle.py::test_group_create_group

### 6. 多端拓扑：A 建群并邀请 B；A 的主端和副端先消费成员同步事件， 再分别查询本地群缓存，验证多设备本地状态一致

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 建群并邀请
  2. A 全部在线端消费成员加入同步事件
  3. A 全部在线端查询本地群快照一致
  4. 测试后置：销毁测试群并恢复群状态
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：GroupManager.getGroupWithId。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_lifecycle.py::test_group_get_group

### 7. 多端拓扑：A 添加/移除 B 为管理员；admin 事件同步到 B 全部在线端，A 全部端不收 admin 事件（原生语义）

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 建群并邀请
  2. 添加 为管理员
  3. 确认添加管理员请求已提交（result 含 adminList）
  4. B 全部在线端收到管理员添加事件
  5. A 全部在线端不收管理员添加事件（原生语义：admin 事件仅 B 收）
  6. A 全部在线端查询群规格 adminList 含 B（账号级服务端状态一致）
  7. 移除 的管理员
  8. 确认移除管理员请求已提交（result 含 adminList）
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：GroupManager.addAdmin、GroupManager.getGroupSpecificationFromServer、GroupManager.removeAdmin。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_roles.py::test_group_add_admin_and_remove_admin_success

### 8. 多端拓扑：A 转让群 owner 给 B；B 全部在线端收到 owner 变更事件并查询群 owner 一致

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 建群并邀请
  2. 转让群 owner 给
  3. 确认转让请求已提交（result 含 owner）
  4. B 全部在线端收到 owner 变更事件
  5. B 全部在线端查询群规格 owner 均为 B（账号级服务端状态一致）
  6. 测试后置：销毁测试群并恢复群状态
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：GroupManager.updateGroupOwner、GroupManager.getGroupSpecificationFromServer。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_roles.py::test_group_update_owner_success

### 9. 非成员 C 不能把 A 的群转让给成员 B

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. B 转让群主
  3. 验证转让群主返回的错误码与错误文案
  4. 测试后置：销毁测试群并恢复群状态
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：GroupManager.updateGroupOwner。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_owner_removal_matrix.py::test_group_non_member_cannot_transfer_ownership

### 10. 非法群消息 ID 与群 ID 调用群回执 API，冻结当前真实同步返回

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. A 发送群已读回执
  2. 验证发送群已读回执返回的错误码与错误文案
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatManager.ackGroupMessageRead。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_message_send.py::test_group_message_ack_boundary_methods

### 11. 管理员 B 上传/删除共享文件：新增/删除事件同步到 owner 账号（A）全部在线端；B 全端收管理员提升事件

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 添加群管理员
  3. 验证 添加群管理员返回的关键字段
  4. B 账号全部在线端收到管理员提升事件（onGroupAdminAdded）
  5. A 账号全部在线端不收到管理员提升事件
  6. 测试后置：销毁测试群并恢复群状态
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：GroupManager.addAdmin。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_shared_files.py::test_group_admin_upload_remove_shared_file_notifies_owner

### 12. 管理员仍可由群主移除：移除事件同步到接收账号全部在线端

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 添加群管理员
  3. 验证 添加群管理员返回的关键字段
  4. A 移除群成员
  5. 验证群业务状态、事件与关键字段
  6. 等待并校验目标业务事件
  7. 验证 移除群成员返回的关键字段
  8. 测试后置：销毁测试群并恢复群状态
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：GroupManager.addAdmin、GroupManager.removeMembers。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_owner_removal_matrix.py::test_group_owner_removes_admin_success

### 13. 批量移除忽略 owner/非成员、移除有效成员：移除事件同步到接收账号全部在线端

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 移除群成员
  3. 验证群业务状态、事件与关键字段
  4. 等待并校验目标业务事件
  5. 验证 移除群成员返回的关键字段
  6. 测试后置：销毁测试群并恢复群状态
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：GroupManager.removeMembers。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_owner_removal_matrix.py::test_group_batch_remove_ignores_owner_and_non_member_but_removes_valid_member

### 14. 普通成员和管理员都不能调用 owner-only 的 updateGroupOwner（参数：成员）

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 添加群管理员
  3. 验证 添加群管理员返回的关键字段
  4. B 转让群主
  5. 验证转让群主返回的错误码与错误文案
  6. 测试后置：销毁测试群并恢复群状态
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：GroupManager.addAdmin、GroupManager.updateGroupOwner。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_owner_removal_matrix.py::test_group_non_owner_cannot_transfer_ownership[member]

### 15. 普通成员和管理员都不能调用 owner-only 的 updateGroupOwner（参数：admin）

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 添加群管理员
  3. 验证 添加群管理员返回的关键字段
  4. B 转让群主
  5. 验证转让群主返回的错误码与错误文案
  6. 测试后置：销毁测试群并恢复群状态
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：GroupManager.addAdmin、GroupManager.updateGroupOwner。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_owner_removal_matrix.py::test_group_non_owner_cannot_transfer_ownership[admin]

### 16. 普通成员无权移除其他成员；管理员移除普通成员：退出事件同步到 owner 与操作管理员账号全部在线端（参数：成员）

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 添加群管理员
  3. 验证 添加群管理员返回的关键字段
  4. B 移除群成员
  5. 验证群业务状态、事件与关键字段
  6. owner 账号全部在线端收到成员退出事件
  7. 操作管理员账号全部在线端收到成员退出事件
  8. 验证 移除群成员返回的错误码与错误文案
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：GroupManager.addAdmin、GroupManager.removeMembers。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_owner_removal_matrix.py::test_group_remove_other_member_permission_by_role[member]

### 17. 普通成员无权移除其他成员；管理员移除普通成员：退出事件同步到 owner 与操作管理员账号全部在线端（参数：admin）

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 添加群管理员
  3. 验证 添加群管理员返回的关键字段
  4. B 移除群成员
  5. 验证群业务状态、事件与关键字段
  6. owner 账号全部在线端收到成员退出事件
  7. 操作管理员账号全部在线端收到成员退出事件
  8. 验证 移除群成员返回的错误码与错误文案
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：GroupManager.addAdmin、GroupManager.removeMembers。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_owner_removal_matrix.py::test_group_remove_other_member_permission_by_role[admin]

### 18. 前置：A 为群主，B 已入群且双方建群事件已消费

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. 所有拓扑端点消费建群和入群事件
  3. 更新群公告
  4. 验证更新群公告返回的关键字段
  5. 收到并校验群公告变更事件
  6. 不收到自己更新的群公告事件
  7. 查询服务端群公告
  8. 验证查询群公告返回的关键字段
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：GroupManager.updateGroupAnnouncement、GroupManager.getGroupAnnouncementFromServer。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_announcement.py::test_group_owner_update_announcement_notifies_member

### 19. 前置：A 为群主、B 已入群；A 将 B 设置为管理员并消费管理员变更事件

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. 所有拓扑端点消费建群和入群事件
  3. 添加群管理员
  4. 验证 添加群管理员返回的关键字段
  5. 收到并校验管理员变更事件
  6. 不收到管理员变更事件
  7. 更新群公告
  8. 验证更新群公告返回的关键字段
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：GroupManager.addAdmin、GroupManager.updateGroupAnnouncement、GroupManager.getGroupAnnouncementFromServer。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_announcement.py::test_group_admin_update_announcement_notifies_owner

### 20. 前置：A/B 已登录；B 的 autoAcceptGroupInvitation 显式设置为 true

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. B 开启自动接受群邀请
  2. 验证自动接受群邀请设置已更新
  3. 测试准备：创建测试群并建立业务前置
  4. 等待并校验目标业务事件
  5. 接收账号全部在线端同步验证成员加入事件
  6. 验证群业务状态、事件与关键字段
  7. 发送账号全部在线端同步验证邀请接受和成员加入事件
  8. 接收账号全部在线端不收到邀请接受通知
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：Client.updateAutoAcceptGroupInvitationSetting、GroupManager.getGroupSpecificationFromServer。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_join_requests_and_invitations.py::test_group_invitation_auto_accept_when_confirmation_required

### 21. 前置：A/B 已登录；B 的自动接受邀请基线为 true

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. B 关闭自动接受群邀请
  2. 验证自动接受群邀请设置已更新
  3. 测试准备：创建测试群并建立业务前置
  4. 等待并校验目标业务事件
  5. 接收账号全部在线端同步验证收到邀请事件
  6. 验证群业务状态、事件与关键字段
  7. B 接受入群邀请
  8. 验证接受入群邀请返回的响应 result 与关键字段
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：Client.updateAutoAcceptGroupInvitationSetting、GroupManager.acceptInvitationFromGroup、GroupManager.getGroupSpecificationFromServer。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_join_requests_and_invitations.py::test_group_invitation_explicit_accept_when_auto_accept_disabled

### 22. 前置：A/B 已登录；B 的自动接受邀请基线为 true

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。原测试目标：前置：A/B 已登录；B 的自动接受邀请基线为 true。 步骤： 1. B 将 autoAcceptGroupInvitation 切为 false。 2. A 创建 inviteNeedConfirm=true 的私有群并邀请 B。 3. B 收到待处理邀请后显式调用 declineInvitationFromGroup 并传拒绝原因。 4. A 接收邀请被拒绝事件，随后从服务端核验 B 未入群。 预期与断言：创建和拒绝后 memberCount 均为 1；A 收到包含 B 与拒绝原因的真实回调； A/B 均不收到成员加入事件；无论结果如何都恢复 B 的自动接受开关。
- 状态/版本说明：跳过：known Android adapter bug: declineInvitationFromGroup drops inviter
- 源码：native-auto-test/tests/group/test_group_join_requests_and_invitations.py::test_group_invitation_explicit_decline_when_auto_accept_disabled

### 23. 前置：B 为群主、A 已入群；B 所在测试 App 已将默认素材准备为 Android 本地文件

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. 测试后置：销毁测试群并恢复群状态
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_shared_files.py::test_group_owner_upload_remove_shared_file_notifies_member

### 24. 群主封禁/解封成员：移除事件同步到接收账号全部在线端

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 加入群黑名单
  3. 验证加入群黑名单返回的关键字段
  4. 等待并校验目标业务事件
  5. A 移出群黑名单
  6. 验证移出群黑名单返回的关键字段
  7. 测试后置：销毁测试群并恢复群状态
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：GroupManager.blockMembers、GroupManager.unblockMembers。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_moderation.py::test_group_block_unblock_members_success

### 25. 群主更新群描述：变更事件同步到群成员全部在线端

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 执行群组业务操作
  3. 验证执行群组业务操作返回的响应 result 与关键字段
  4. 验证群业务状态、事件与关键字段
  5. A 查询本地群详情
  6. 验证查询本地群详情返回的关键字段
  7. A 查询服务端群详情
  8. 验证查询服务端群详情返回的关键字段
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：GroupManager.updateDescription、GroupManager.getGroupWithId、GroupManager.getGroupSpecificationFromServer。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_metadata.py::test_group_update_description

### 26. 群主更新群名称：变更事件同步到群成员全部在线端

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 更新群名称
  3. 验证更新群名称返回的关键字段
  4. 验证群业务状态、事件与关键字段
  5. A 查询本地群详情
  6. 验证查询本地群详情返回的关键字段
  7. A 查询服务端群详情
  8. 验证查询服务端群详情返回的关键字段
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：GroupManager.updateGroupSubject、GroupManager.getGroupWithId、GroupManager.getGroupSpecificationFromServer。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_metadata.py::test_group_update_subject

### 27. 群主禁言/解禁成员：禁言列表变更事件同步到接收账号全部在线端

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 禁言成员
  3. 验证 禁言成员返回的关键字段
  4. 等待并校验目标业务事件
  5. A 解除成员禁言
  6. 验证解除成员禁言返回的关键字段
  7. 测试后置：销毁测试群并恢复群状态
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：GroupManager.muteMembers、GroupManager.unMuteMembers。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_moderation.py::test_group_mute_unmute_members_success

### 28. 群主全员禁言/解禁：状态变更事件同步到接收账号全部在线端

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 全员禁言
  3. 验证 全员禁言返回的关键字段
  4. 等待并校验目标业务事件
  5. A 解除全员禁言
  6. 验证解除全员禁言返回的关键字段
  7. 测试后置：销毁测试群并恢复群状态
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：GroupManager.muteAllMembers、GroupManager.unMuteAllMembers。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_moderation.py::test_group_mute_all_unmute_all_success

### 29. 群主添加/移除白名单：白名单变更事件同步到接收账号全部在线端

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 加入群白名单
  3. 验证加入群白名单返回的关键字段
  4. 等待并校验目标业务事件
  5. A 移出群白名单
  6. 验证移出群白名单返回的关键字段
  7. 测试后置：销毁测试群并恢复群状态
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：GroupManager.addWhiteList、GroupManager.removeWhiteList。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_moderation.py::test_group_add_remove_white_list_success

### 30. 群主添加/移除成员：加入与移除事件同步到收发账号全部在线端

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 添加群成员
  3. 验证 添加群成员返回的关键字段
  4. 等待并校验目标业务事件
  5. 接收账号副端 同步验证收到事件
  6. 发送账号副端 同步验证收到事件
  7. A 查询服务端群详情
  8. 验证查询服务端群详情返回的关键字段
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：GroupManager.addMembers、GroupManager.getGroupSpecificationFromServer、GroupManager.removeMembers。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_members.py::test_group_add_remove_members

### 31. 转让给当前 owner 幂等成功；其他无效目标返回稳定错误且 owner 不变；接收账号全部在线端不触发 owner 变更事件（参数：空）

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 转让群主
  3. 验证转让群主返回的关键字段
  4. 验证转让群主返回的错误码与错误文案
  5. 测试后置：销毁测试群并恢复群状态
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：GroupManager.updateGroupOwner。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_owner_removal_matrix.py::test_group_transfer_owner_target_boundaries[empty]

### 32. 转让给当前 owner 幂等成功；其他无效目标返回稳定错误且 owner 不变；接收账号全部在线端不触发 owner 变更事件（参数：current-owner-idempotent）

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 转让群主
  3. 验证转让群主返回的关键字段
  4. 验证转让群主返回的错误码与错误文案
  5. 测试后置：销毁测试群并恢复群状态
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：GroupManager.updateGroupOwner。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_owner_removal_matrix.py::test_group_transfer_owner_target_boundaries[current-owner-idempotent]

### 33. 转让给当前 owner 幂等成功；其他无效目标返回稳定错误且 owner 不变；接收账号全部在线端不触发 owner 变更事件（参数：non-成员）

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 转让群主
  3. 验证转让群主返回的关键字段
  4. 验证转让群主返回的错误码与错误文案
  5. 测试后置：销毁测试群并恢复群状态
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：GroupManager.updateGroupOwner。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_owner_removal_matrix.py::test_group_transfer_owner_target_boundaries[non-member]

### 34. 转让给当前 owner 幂等成功；其他无效目标返回稳定错误且 owner 不变；接收账号全部在线端不触发 owner 变更事件（参数：nonexistent）

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 转让群主
  3. 验证转让群主返回的关键字段
  4. 验证转让群主返回的错误码与错误文案
  5. 测试后置：销毁测试群并恢复群状态
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：GroupManager.updateGroupOwner。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_owner_removal_matrix.py::test_group_transfer_owner_target_boundaries[nonexistent]

### 35. A 合并同群两条真实文本消息并发送，B 全部在线端收到关联同一群会话的合并消息

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. A 发送第 条源文本消息并记录 消息 ID
  2. A 发送合并消息，并验证 B 全部在线端收到关联消息
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_message_send.py::test_group_message_send_receive_combine

### 36. A 将群主转让给管理员 B：B 账号在线端收到 owner 变更事件；B 成 owner，A 成普通成员

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 添加群管理员
  3. 验证 添加群管理员返回的关键字段
  4. A 转让群主
  5. 验证转让群主返回的关键字段
  6. B 账号全部在线端收到 owner 变更事件（onGroupOwnerChanged）
  7. 测试后置：销毁测试群并恢复群状态
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：GroupManager.addAdmin、GroupManager.updateGroupOwner。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_owner_removal_matrix.py::test_group_transfer_owner_to_admin_normalizes_roles

### 37. A 向包含 B 的群发送指定类型消息：A 全部在线端同步、B 全部在线端接收（参数：视频）

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. A 发送 类型群消息，并验证发送端与接收端链路
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_message_send.py::test_group_message_send_receive_by_type[video]

### 38. A 向包含 B 的群发送指定类型消息：A 全部在线端同步、B 全部在线端接收（参数：图片）

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. A 发送 类型群消息，并验证发送端与接收端链路
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_message_send.py::test_group_message_send_receive_by_type[image]

### 39. A 向包含 B 的群发送指定类型消息：A 全部在线端同步、B 全部在线端接收（参数：位置）

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. A 发送 类型群消息，并验证发送端与接收端链路
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_message_send.py::test_group_message_send_receive_by_type[location]

### 40. A 向包含 B 的群发送指定类型消息：A 全部在线端同步、B 全部在线端接收（参数：文件）

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. A 发送 类型群消息，并验证发送端与接收端链路
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_message_send.py::test_group_message_send_receive_by_type[file]

### 41. A 向包含 B 的群发送指定类型消息：A 全部在线端同步、B 全部在线端接收（参数：语音）

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. A 发送 类型群消息，并验证发送端与接收端链路
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_message_send.py::test_group_message_send_receive_by_type[voice]

### 42. A 向包含 B 的群发送指定类型消息：A 全部在线端同步、B 全部在线端接收（参数：自定义）

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. A 发送 类型群消息，并验证发送端与接收端链路
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_message_send.py::test_group_message_send_receive_by_type[custom]

### 43. A 向包含 B 的群发送指定类型消息：A 全部在线端同步、B 全部在线端接收（参数：cmd）

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. A 发送 类型群消息，并验证发送端与接收端链路
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_message_send.py::test_group_message_send_receive_by_type[cmd]

### 44. A 向包含 B 的群发送指定类型消息：A 全部在线端同步、B 全部在线端接收（参数：txt）

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. A 发送 类型群消息，并验证发送端与接收端链路
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_message_send.py::test_group_message_send_receive_by_type[txt]

### 45. A 转让给 B 后 A 失去 owner 权限：B 收到 owner 变更事件，A 收到被移除事件

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 转让群主
  3. 验证转让群主返回的关键字段
  4. B 账号全部在线端消费 owner 变更事件
  5. A 移除群成员
  6. 验证 移除群成员返回的错误码与错误文案
  7. B 移除群成员
  8. 验证群业务状态、事件与关键字段
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：GroupManager.updateGroupOwner、GroupManager.removeMembers。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_owner_removal_matrix.py::test_group_transfer_then_new_owner_removes_former_owner

### 46. B 创建群并邀请 A，A 发送群消息；验证 A 副端同步、B 全部在线端接收及群回执查询

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 清理参与设备的历史事件
  2. 创建群并邀请发送账号
  3. 清理建群及入群产生的历史事件
  4. 向群发送需要群回执的文本消息
  5. 验证发送群消息返回的关键字段
  6. 验证群业务状态、事件与关键字段
  7. 等待 的消息发送成功回调（消息发送成功回调）
  8. 发送账号副端 收到群消息同步（消息接收回调）
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatManager.sendMessage、ChatManager.getMessage、ChatManager.ackGroupMessageRead、ChatManager.asyncFetchGroupAcks。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_message_send.py::test_group_message_fetch_acks_success

### 47. block 成员 non 成员

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 加入群黑名单
  3. 验证加入群黑名单返回的错误码与错误文案
  4. 测试后置：销毁测试群并恢复群状态
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：GroupManager.blockMembers。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_moderation.py::test_group_block_members_non_member

### 48. destroyChatThread：子区创建后由 owner 解散，收发账号全部在线端收到 onChatThreadDestroy 事件

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立成员前置
  2. A 解散子区
  3. 验证 解散子区返回的关键字段
  4. 全部在线端验证收到子区事件
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatThreadManager.destroyChatThread。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_chat_thread_remaining_api_coverage.py::test_chat_thread_destroy_event_received_by_group_member

### 49. fetchChatThreadMember / fetchLast消息WithChatThreads：成员列表包含 A/B，新建子区未发线程消息时最新消息映射为空

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立成员前置
  2. A 查询子区成员
  3. 验证查询子区成员返回的关键字段
  4. A 执行子区业务操作
  5. 验证执行子区业务操作返回的响应 result 与关键字段
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatThreadManager.fetchChatThreadMember、ChatThreadManager.fetchLastMessageWithChatThreads。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_chat_thread_remaining_api_coverage.py::test_chat_thread_fetch_members_and_latest_message

### 50. removeMembers 单独传当前群主返回成功但状态不变；接收账号全部在线端不触发移除事件

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 移除群成员
  3. 验证群业务状态、事件与关键字段
  4. 验证 移除群成员返回的关键字段
  5. 测试后置：销毁测试群并恢复群状态
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：GroupManager.removeMembers。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_owner_removal_matrix.py::test_group_remove_current_owner_is_ignored

### 51. updateChatThreadSubject / leaveChatThread：更新子区名称后，收发账号全部在线端收到事件，B 退出子区

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立成员前置
  2. A 执行子区业务操作
  3. 验证执行子区业务操作返回的响应 result 与关键字段
  4. 全部在线端验证收到子区事件
  5. A 查询子区详情
  6. 验证查询子区详情返回的关键字段
  7. B 退出子区
  8. 验证退出子区返回的关键字段
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatThreadManager.updateChatThreadSubject、ChatThreadManager.fetchChatThreadDetail、ChatThreadManager.leaveChatThread、ChatThreadManager.fetchJoinedChatThreadsWithParentId。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_chat_thread_remaining_api_coverage.py::test_chat_thread_update_name_and_leave

### 52. 审批群群主 A 先离线，B 申请后 A 重登接收申请并同意或拒绝（参数：接受）

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. 测试准备：切换账号设备在线状态
  3. 等待并校验目标业务事件
  4. 验证群业务状态、事件与关键字段
  5. A 执行群组业务操作
  6. 验证执行群组业务操作返回的响应 result 与关键字段
  7. 测试后置：测试准备：切换账号设备在线状态
  8. 测试后置：销毁测试群并恢复环境
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_offline_invitation_application.py::test_group_offline_owner_receives_join_application_and_processes_after_login[accept]

### 53. 审批群群主 A 先离线，B 申请后 A 重登接收申请并同意或拒绝（参数：拒绝）

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. 测试准备：切换账号设备在线状态
  3. 等待并校验目标业务事件
  4. 验证群业务状态、事件与关键字段
  5. A 执行群组业务操作
  6. 验证执行群组业务操作返回的响应 result 与关键字段
  7. 测试后置：测试准备：切换账号设备在线状态
  8. 测试后置：销毁测试群并恢复环境
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_offline_invitation_application.py::test_group_offline_owner_receives_join_application_and_processes_after_login[decline]

### 54. A 离线期间 B 修改自己的群成员属性；A 重登后按成员 ID 查询到同一属性

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立成员前置
  2. 测试准备：切换账号设备在线状态
  3. B 执行群组业务操作
  4. 验证执行群组业务操作返回的响应 result 与关键字段
  5. 验证群业务状态、事件与关键字段
  6. 动作端 执行群组业务操作
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：GroupManager.setMemberAttributesFromGroup、GroupManager.fetchMembersAttributesFromGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_offline_roles_and_configuration.py::test_group_offline_member_attributes_final_state

### 55. A 在 B 处理邀请时离线，A 重登收到接受或拒绝结果并核验成员状态（参数：接受）

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立成员前置
  2. 等待并校验目标业务事件
  3. 验证群业务状态、事件与关键字段
  4. 测试准备：切换账号设备在线状态
  5. B 接受入群邀请
  6. 验证接受入群邀请返回的响应 result 与关键字段
  7. B 拒绝入群邀请
  8. 验证拒绝入群邀请返回的响应 result 与关键字段
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：GroupManager.acceptInvitationFromGroup、GroupManager.declineInvitationFromGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_offline_invitation_application.py::test_group_offline_owner_receives_invitation_result_after_relogin[accept]

### 56. A 在 B 处理邀请时离线，A 重登收到接受或拒绝结果并核验成员状态（参数：拒绝）

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立成员前置
  2. 等待并校验目标业务事件
  3. 验证群业务状态、事件与关键字段
  4. 测试准备：切换账号设备在线状态
  5. B 接受入群邀请
  6. 验证接受入群邀请返回的响应 result 与关键字段
  7. B 拒绝入群邀请
  8. 验证拒绝入群邀请返回的响应 result 与关键字段
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：GroupManager.acceptInvitationFromGroup、GroupManager.declineInvitationFromGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_offline_invitation_application.py::test_group_offline_owner_receives_invitation_result_after_relogin[decline]

### 57. B 离线积压三条群文本；重登验证完整集合、未读数 3 和最新消息

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立成员前置
  2. 测试准备：切换账号设备在线状态
  3. 执行群消息动作并验证发送/接收链路
  4. 验证本用例的关键业务结果
  5. 验证群业务状态、事件与关键字段
  6. 动作端 执行本用例业务操作
  7. 验证执行本用例业务操作返回的响应 result 与关键字段
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：ConversationManager.getUnreadMsgCount、ConversationManager.getLatestMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_offline_message_delivery.py::test_group_offline_multiple_text_messages_and_conversation_state

### 58. B 离线期间 A 更新公告；B 重登从公告查询 API 得到同一动态值

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立成员前置
  2. 测试准备：切换账号设备在线状态
  3. A 更新群公告
  4. 验证更新群公告返回的关键字段
  5. 验证群业务状态、事件与关键字段
  6. 动作端 查询群公告
  7. 验证查询群公告返回的关键字段
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：GroupManager.updateGroupAnnouncement、GroupManager.getGroupAnnouncementFromServer。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_offline_roles_and_configuration.py::test_group_offline_announcement_final_state

### 59. B 离线期间被加入群黑名单；重登后成员移除且服务端黑名单包含 B

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立成员前置
  2. 测试准备：切换账号设备在线状态
  3. A 加入群黑名单
  4. 验证加入群黑名单返回的关键字段
  5. 验证群业务状态、事件与关键字段
  6. B 加入公开群
  7. 验证加入公开群返回的错误码与错误文案
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：GroupManager.blockMembers、GroupManager.joinPublicGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_offline_member_state.py::test_group_offline_member_blocked_state_after_login

### 60. B 离线期间被禁言/解除禁言；每次重登均从服务端名单验证最终状态

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立成员前置
  2. 测试准备：切换账号设备在线状态
  3. A 禁言成员
  4. 验证 禁言成员返回的关键字段
  5. 验证群业务状态、事件与关键字段
  6. A 解除成员禁言
  7. 验证解除成员禁言返回的关键字段
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：GroupManager.muteMembers、GroupManager.unMuteMembers。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_offline_roles_and_configuration.py::test_group_offline_member_mute_unmute_final_state

### 61. B 离线期间被设为/移出管理员；每次重登均验证本地角色和服务端 adminList

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立成员前置
  2. 测试准备：切换账号设备在线状态
  3. A 添加群管理员
  4. 验证群业务状态、事件与关键字段
  5. 验证 添加群管理员返回的关键字段
  6. A 移除群管理员
  7. 验证 移除群管理员返回的关键字段
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：GroupManager.addAdmin、GroupManager.removeAdmin。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_offline_roles_and_configuration.py::test_group_offline_admin_add_remove_final_state

### 62. B 离线期间被移出；重登收到真实终态事件且本地/服务端均不再入群

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立成员前置
  2. 测试准备：切换账号设备在线状态
  3. A 移除群成员
  4. 验证 移除群成员返回的关键字段
  5. 验证群业务状态、事件与关键字段
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：GroupManager.removeMembers。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_offline_member_state.py::test_group_offline_member_removed_state_after_login

### 63. B 离线期间更新名称/描述/头像/扩展；重登后按真实服务端字段验收（参数：avatarUrl）

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立成员前置
  2. 测试准备：切换账号设备在线状态
  3. A 执行群组业务操作
  4. 验证执行群组业务操作返回的响应 result 与关键字段
  5. 验证群业务状态、事件与关键字段
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_offline_roles_and_configuration.py::test_group_offline_metadata_final_state[avatarUrl]

### 64. B 离线期间更新名称/描述/头像/扩展；重登后按真实服务端字段验收（参数：desc）

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立成员前置
  2. 测试准备：切换账号设备在线状态
  3. A 执行群组业务操作
  4. 验证执行群组业务操作返回的响应 result 与关键字段
  5. 验证群业务状态、事件与关键字段
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_offline_roles_and_configuration.py::test_group_offline_metadata_final_state[desc]

### 65. B 离线期间更新名称/描述/头像/扩展；重登后按真实服务端字段验收（参数：ext）

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立成员前置
  2. 测试准备：切换账号设备在线状态
  3. A 执行群组业务操作
  4. 验证执行群组业务操作返回的响应 result 与关键字段
  5. 验证群业务状态、事件与关键字段
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_offline_roles_and_configuration.py::test_group_offline_metadata_final_state[ext]

### 66. B 离线期间更新名称/描述/头像/扩展；重登后按真实服务端字段验收（参数：name）

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立成员前置
  2. 测试准备：切换账号设备在线状态
  3. A 执行群组业务操作
  4. 验证执行群组业务操作返回的响应 result 与关键字段
  5. 验证群业务状态、事件与关键字段
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_offline_roles_and_configuration.py::test_group_offline_metadata_final_state[name]

### 67. B 离线期间加入/移出白名单；每次重登均从服务端白名单验证

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立成员前置
  2. 测试准备：切换账号设备在线状态
  3. A 执行群组业务操作
  4. 验证执行群组业务操作返回的响应 result 与关键字段
  5. 验证群业务状态、事件与关键字段
  6. 动作端 查询白名单成员状态
  7. 验证查询白名单成员状态返回的关键字段
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：GroupManager.isMemberInWhiteListFromServer。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_offline_roles_and_configuration.py::test_group_offline_allow_list_add_remove_final_state

### 68. B 离线期间接任群主；重登后本地和服务端 owner/permissionType 均为新群主

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立成员前置
  2. 测试准备：切换账号设备在线状态
  3. A 转让群主
  4. 验证群业务状态、事件与关键字段
  5. 验证转让群主返回的关键字段
  6. B 转让群主
  7. 测试后置：测试准备：切换账号设备在线状态
  8. 测试后置：销毁测试群并恢复环境
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：GroupManager.updateGroupOwner。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_offline_roles_and_configuration.py::test_group_offline_owner_transfer_final_state

### 69. B 离线期间全员禁言/解除；每次重登均查询 isAllMemberMuted

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立成员前置
  2. 测试准备：切换账号设备在线状态
  3. A 执行群组业务操作
  4. 验证执行群组业务操作返回的响应 result 与关键字段
  5. 验证群业务状态、事件与关键字段
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_offline_roles_and_configuration.py::test_group_offline_mute_all_unmute_all_final_state

### 70. B 离线期间群被解散；重登收到解散事件且本地/服务端 joined 投影为空

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立成员前置
  2. 测试准备：切换账号设备在线状态
  3. A 销毁测试群
  4. 验证销毁测试群返回的关键字段
  5. 验证群业务状态、事件与关键字段
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：GroupManager.destroyGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_offline_member_state.py::test_group_offline_group_destroyed_state_after_login

### 71. B 离线期间上传/删除共享文件；每次重登均从服务端文件列表验证终态

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立成员前置
  2. 测试准备：切换账号设备在线状态
  3. A 上传群共享文件
  4. 验证 上传群共享文件返回的关键字段
  5. A 查询群共享文件列表
  6. 验证查询群共享文件列表返回的关键字段
  7. 验证群业务状态、事件与关键字段
  8. 动作端 查询群共享文件列表
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：GroupManager.uploadGroupSharedFile、GroupManager.getGroupFileListFromServer、GroupManager.removeGroupSharedFile。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_offline_roles_and_configuration.py::test_group_offline_shared_file_upload_delete_final_state

### 72. B 离线时 A 发群文本；B 重登收到同一真实 消息 ID 和群会话正文

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立成员前置
  2. 测试准备：切换账号设备在线状态
  3. 执行群消息动作并验证发送/接收链路
  4. 等待并关联目标业务事件
  5. 验证群业务状态、事件与关键字段
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_offline_message_delivery.py::test_group_offline_text_message_received_after_login

### 73. B 离线时群 CMD 设置 deliver在线Only=true；重登无旧事件且本地无消息

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立成员前置
  2. 测试准备：切换账号设备在线状态
  3. A 发送群消息
  4. 验证发送群消息返回的关键字段
  5. 等待并关联目标业务事件
  6. 等待本地撤回消息删除完成
  7. 验证执行群消息操作返回的响应 result 与关键字段
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：ChatManager.sendMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_offline_message_delivery.py::test_group_offline_cmd_deliver_online_only_not_received_after_login

### 74. B 申请审批群后离线，A 处理；B 重登收到审批结果并验证最终状态（参数：接受）

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. 等待并校验目标业务事件
  3. 验证群业务状态、事件与关键字段
  4. 测试准备：切换账号设备在线状态
  5. A 执行群组业务操作
  6. 验证执行群组业务操作返回的响应 result 与关键字段
  7. 测试后置：测试准备：切换账号设备在线状态
  8. 测试后置：销毁测试群并恢复环境
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_offline_invitation_application.py::test_group_offline_applicant_receives_application_result_after_relogin[accept]

### 75. B 申请审批群后离线，A 处理；B 重登收到审批结果并验证最终状态（参数：拒绝）

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. 等待并校验目标业务事件
  3. 验证群业务状态、事件与关键字段
  4. 测试准备：切换账号设备在线状态
  5. A 执行群组业务操作
  6. 验证执行群组业务操作返回的响应 result 与关键字段
  7. 测试后置：测试准备：切换账号设备在线状态
  8. 测试后置：销毁测试群并恢复环境
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_offline_invitation_application.py::test_group_offline_applicant_receives_application_result_after_relogin[decline]

### 76. B 收到群消息后在 A 离线期间发送 已读回执；A 重登最终查询 count=1

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立成员前置
  2. A 发送群消息
  3. 验证发送群消息返回的关键字段
  4. 等待并关联目标业务事件
  5. 验证群业务状态、事件与关键字段
  6. 测试准备：切换账号设备在线状态
  7. B 发送群已读回执
  8. 验证发送群已读回执返回的关键字段
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：ChatManager.sendMessage、ChatManager.ackGroupMessageRead、ChatManager.asyncFetchGroupAcks、MessageManager.groupAckCount。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_offline_message_delivery.py::test_group_offline_sender_reads_ack_count_after_relogin

### 77. B 首次接收前 A 撤回群文本；B 重登验证撤回回放和本地最终删除

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立成员前置
  2. 测试准备：切换账号设备在线状态
  3. 执行群消息动作并验证发送/接收链路
  4. A 执行群消息操作
  5. 验证执行群消息操作返回的响应 result 与关键字段
  6. 等待并关联目标业务事件
  7. 等待本地撤回消息删除完成
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：ChatManager.recallMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_offline_message_delivery.py::test_group_offline_message_recalled_before_first_recipient_login

### 78. B 先离线，重登收到群邀请并接受或拒绝，验证权限和最终成员状态（参数：接受）

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 测试准备：切换账号设备在线状态
  2. 测试准备：创建测试群并建立成员前置
  3. 验证群业务状态、事件与关键字段
  4. 等待并校验目标业务事件
  5. B 接受入群邀请
  6. 验证接受入群邀请返回的响应 result 与关键字段
  7. B 拒绝入群邀请
  8. 验证拒绝入群邀请返回的响应 result 与关键字段
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：GroupManager.acceptInvitationFromGroup、GroupManager.declineInvitationFromGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_offline_invitation_application.py::test_group_offline_invitation_received_and_processed_after_login[accept]

### 79. B 先离线，重登收到群邀请并接受或拒绝，验证权限和最终成员状态（参数：拒绝）

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 测试准备：切换账号设备在线状态
  2. 测试准备：创建测试群并建立成员前置
  3. 验证群业务状态、事件与关键字段
  4. 等待并校验目标业务事件
  5. B 接受入群邀请
  6. 验证接受入群邀请返回的响应 result 与关键字段
  7. B 拒绝入群邀请
  8. 验证拒绝入群邀请返回的响应 result 与关键字段
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：GroupManager.acceptInvitationFromGroup、GroupManager.declineInvitationFromGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_offline_invitation_application.py::test_group_offline_invitation_received_and_processed_after_login[decline]

### 80. B 已收群文本后离线，A 撤回；B 重登验证撤回事件和本地最终删除

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立成员前置
  2. 执行群消息动作并验证发送/接收链路
  3. 等待并关联目标业务事件
  4. 验证群业务状态、事件与关键字段
  5. 测试准备：切换账号设备在线状态
  6. A 执行群消息操作
  7. 验证执行群消息操作返回的响应 result 与关键字段
  8. 动作端 执行群消息操作
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：ChatManager.recallMessage、ChatManager.getMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_offline_message_delivery.py::test_group_offline_recipient_receives_recall_after_relogin

### 81. B 已收群文本后离线，A 修改正文；B 重登验证修改事件和本地最终正文

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立成员前置
  2. 执行群消息动作并验证发送/接收链路
  3. 等待并关联目标业务事件
  4. 验证群业务状态、事件与关键字段
  5. 测试准备：切换账号设备在线状态
  6. A 执行群消息操作
  7. 验证执行群消息操作返回的响应 result 与关键字段
  8. 动作端 执行群消息操作
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：ChatManager.modifyMessage、ChatManager.getMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_offline_message_delivery.py::test_group_offline_recipient_receives_content_change_after_relogin

### 82. B 主动退群后 logout/login；成员数、joined groups 和本地群对象保持退出终态

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立成员前置
  2. B 退出群
  3. 验证退出群返回的关键字段
  4. 测试准备：切换账号设备在线状态
  5. 验证群业务状态、事件与关键字段
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：GroupManager.leaveGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_offline_member_state.py::test_group_offline_member_leave_state_persists_after_relogin

### 83. `requestToJoinPublicGroup` 只允许 PublicJoinNeedApproval(style=2)（参数：private-成员）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. B 申请加入公开群
  3. 等待并校验目标业务事件
  4. 验证申请加入公开群返回的响应 result 与关键字段
  5. 验证申请加入公开群返回的错误码与错误文案
  6. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.requestToJoinPublicGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_request_to_join_rejects_every_non_approval_style[private-member]

### 84. `requestToJoinPublicGroup` 只允许 PublicJoinNeedApproval(style=2)（参数：private-owner）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. B 申请加入公开群
  3. 等待并校验目标业务事件
  4. 验证申请加入公开群返回的响应 result 与关键字段
  5. 验证申请加入公开群返回的错误码与错误文案
  6. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.requestToJoinPublicGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_request_to_join_rejects_every_non_approval_style[private-owner]

### 85. `requestToJoinPublicGroup` 只允许 PublicJoinNeedApproval(style=2)（参数：public-open）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. B 申请加入公开群
  3. 等待并校验目标业务事件
  4. 验证申请加入公开群返回的响应 result 与关键字段
  5. 验证申请加入公开群返回的错误码与错误文案
  6. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.requestToJoinPublicGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_request_to_join_rejects_every_non_approval_style[public-open]

### 86. 创建 group 空 name

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 创建群
  2. 验证创建群返回的关键字段
  3. A 销毁测试群
  4. 验证销毁测试群返回的关键字段
  重点验证接口：GroupManager.createGroup、GroupManager.destroyGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_empty_name

### 87. 创建 group 文本 fields additional inputs（参数：desc_multiline-desc-line1\nline2\nline3-None）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 创建群
  2. 验证创建群返回的错误码与错误文案
  3. 验证创建群返回的关键字段
  4. A 销毁测试群
  5. 验证销毁测试群返回的关键字段
  重点验证接口：GroupManager.createGroup、GroupManager.destroyGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_text_fields_additional_inputs[desc_multiline-desc-line1\nline2\nline3-None]

### 88. 创建 group 文本 fields additional inputs（参数：desc_space_only-desc- -None）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 创建群
  2. 验证创建群返回的错误码与错误文案
  3. 验证创建群返回的关键字段
  4. A 销毁测试群
  5. 验证销毁测试群返回的关键字段
  重点验证接口：GroupManager.createGroup、GroupManager.destroyGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_text_fields_additional_inputs[desc_space_only-desc- -None]

### 89. 创建 group 文本 fields additional inputs（参数：desc_symbols-desc-desc_!@#$%^&*()[]{}<>?/\\|-None）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 创建群
  2. 验证创建群返回的错误码与错误文案
  3. 验证创建群返回的关键字段
  4. A 销毁测试群
  5. 验证销毁测试群返回的关键字段
  重点验证接口：GroupManager.createGroup、GroupManager.destroyGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_text_fields_additional_inputs[desc_symbols-desc-desc_!@#$%^&*()[]{}<>?/\\|-None]

### 90. 创建 group 文本 fields additional inputs（参数：group_name_mixed_symbols-groupName-group-name_!@#$%^&*()[]{}-None）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 创建群
  2. 验证创建群返回的错误码与错误文案
  3. 验证创建群返回的关键字段
  4. A 销毁测试群
  5. 验证销毁测试群返回的关键字段
  重点验证接口：GroupManager.createGroup、GroupManager.destroyGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_text_fields_additional_inputs[group_name_mixed_symbols-groupName-group-name_!@#$%^&*()[]{}-None]

### 91. 创建 group 文本 fields additional inputs（参数：group_name_tabs-groupName-\tgroup\tname\t-None）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 创建群
  2. 验证创建群返回的错误码与错误文案
  3. 验证创建群返回的关键字段
  4. A 销毁测试群
  5. 验证销毁测试群返回的关键字段
  重点验证接口：GroupManager.createGroup、GroupManager.destroyGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_text_fields_additional_inputs[group_name_tabs-groupName-\tgroup\tname\t-None]

### 92. 创建 group 文本 fields additional inputs（参数：invite_reason_multiline-inviteReason-reason line1\nreason line2-None）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 创建群
  2. 验证创建群返回的错误码与错误文案
  3. 验证创建群返回的关键字段
  4. A 销毁测试群
  5. 验证销毁测试群返回的关键字段
  重点验证接口：GroupManager.createGroup、GroupManager.destroyGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_text_fields_additional_inputs[invite_reason_multiline-inviteReason-reason line1\nreason line2-None]

### 93. 创建 group 文本 fields additional inputs（参数：invite_reason_space_only-inviteReason- -None）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 创建群
  2. 验证创建群返回的错误码与错误文案
  3. 验证创建群返回的关键字段
  4. A 销毁测试群
  5. 验证销毁测试群返回的关键字段
  重点验证接口：GroupManager.createGroup、GroupManager.destroyGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_text_fields_additional_inputs[invite_reason_space_only-inviteReason- -None]

### 94. 创建 group 文本 fields additional inputs（参数：invite_reason_symbols-inviteReason-reason_!@#$%^&*()[]{}<>?/\\|-None）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 创建群
  2. 验证创建群返回的错误码与错误文案
  3. 验证创建群返回的关键字段
  4. A 销毁测试群
  5. 验证销毁测试群返回的关键字段
  重点验证接口：GroupManager.createGroup、GroupManager.destroyGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_text_fields_additional_inputs[invite_reason_symbols-inviteReason-reason_!@#$%^&*()[]{}<>?/\\|-None]

### 95. 创建 group desc reason 查询条件 abnormal inputs（参数：查询条件_ext_too_long_1025-overrides2-None）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：5.0 不适用：5.0 EMGroupConfigs 已移除 style，无对应边界
- 源码：native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_desc_reason_options_abnormal_inputs[options_ext_too_long_1025-overrides2-None]

### 96. 创建 group desc reason 查询条件 abnormal inputs（参数：查询条件_max_count_negative-overrides4-expect_error4）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：5.0 不适用：5.0 EMGroupConfigs 已移除 style，无对应边界
- 源码：native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_desc_reason_options_abnormal_inputs[options_max_count_negative-overrides4-expect_error4]

### 97. 创建 group desc reason 查询条件 abnormal inputs（参数：查询条件_max_count_zero-overrides3-expect_error3）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：5.0 不适用：5.0 EMGroupConfigs 已移除 style，无对应边界
- 源码：native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_desc_reason_options_abnormal_inputs[options_max_count_zero-overrides3-expect_error3]

### 98. 创建 group desc reason 查询条件 abnormal inputs（参数：查询条件_style_out_of_range-overrides5-None）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：5.0 不适用：5.0 EMGroupConfigs 已移除 style，无对应边界
- 源码：native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_desc_reason_options_abnormal_inputs[options_style_out_of_range-overrides5-None]

### 99. 创建 group desc reason 查询条件 abnormal inputs（参数：desc_too_long_513-overrides0-None）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：5.0 不适用：5.0 EMGroupConfigs 已移除 style，无对应边界
- 源码：native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_desc_reason_options_abnormal_inputs[desc_too_long_513-overrides0-None]

### 100. 创建 group desc reason 查询条件 abnormal inputs（参数：invite_reason_too_long_1025-overrides1-None）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：5.0 不适用：5.0 EMGroupConfigs 已移除 style，无对应边界
- 源码：native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_desc_reason_options_abnormal_inputs[invite_reason_too_long_1025-overrides1-None]

### 101. 创建 group invite 成员 abnormal inputs（参数：invite_members_重复_user-invite_members0-None）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 创建群
  2. 验证创建群返回的错误码与错误文案
  3. 验证创建群返回的关键字段
  4. A 销毁测试群
  5. 验证销毁测试群返回的关键字段
  重点验证接口：GroupManager.createGroup、GroupManager.destroyGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_invite_members_abnormal_inputs[invite_members_duplicate_user-invite_members0-None]

### 102. 创建 group invite 成员 abnormal inputs（参数：invite_members_contains_nonexistent_user-invite_members1-expect_error1）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 创建群
  2. 验证创建群返回的错误码与错误文案
  3. 验证创建群返回的关键字段
  4. A 销毁测试群
  5. 验证销毁测试群返回的关键字段
  重点验证接口：GroupManager.createGroup、GroupManager.destroyGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_invite_members_abnormal_inputs[invite_members_contains_nonexistent_user-invite_members1-expect_error1]

### 103. 创建 group max count less than invite 成员

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 创建群
  2. 验证创建群返回的错误码与错误文案
  重点验证接口：GroupManager.createGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_max_count_less_than_invite_members

### 104. 创建 group name and avatar abnormal inputs（参数：avatar_url_ftp_protocol-overrides5-None）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 创建群
  2. 验证创建群返回的错误码与错误文案
  3. 验证创建群返回的关键字段
  4. A 销毁测试群
  5. 验证销毁测试群返回的关键字段
  重点验证接口：GroupManager.createGroup、GroupManager.destroyGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_name_and_avatar_abnormal_inputs[avatar_url_ftp_protocol-overrides5-None]

### 105. 创建 group name and avatar abnormal inputs（参数：avatar_url_not_url-overrides4-None）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 创建群
  2. 验证创建群返回的错误码与错误文案
  3. 验证创建群返回的关键字段
  4. A 销毁测试群
  5. 验证销毁测试群返回的关键字段
  重点验证接口：GroupManager.createGroup、GroupManager.destroyGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_name_and_avatar_abnormal_inputs[avatar_url_not_url-overrides4-None]

### 106. 创建 group name and avatar abnormal inputs（参数：avatar_url_too_long-overrides6-expect_error6）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 创建群
  2. 验证创建群返回的错误码与错误文案
  3. 验证创建群返回的关键字段
  4. A 销毁测试群
  5. 验证销毁测试群返回的关键字段
  重点验证接口：GroupManager.createGroup、GroupManager.destroyGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_name_and_avatar_abnormal_inputs[avatar_url_too_long-overrides6-expect_error6]

### 107. 创建 group name and avatar abnormal inputs（参数：group_name_control_chars-overrides3-None）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 创建群
  2. 验证创建群返回的错误码与错误文案
  3. 验证创建群返回的关键字段
  4. A 销毁测试群
  5. 验证销毁测试群返回的关键字段
  重点验证接口：GroupManager.createGroup、GroupManager.destroyGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_name_and_avatar_abnormal_inputs[group_name_control_chars-overrides3-None]

### 108. 创建 group name and avatar abnormal inputs（参数：group_name_space_only-overrides0-None）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 创建群
  2. 验证创建群返回的错误码与错误文案
  3. 验证创建群返回的关键字段
  4. A 销毁测试群
  5. 验证销毁测试群返回的关键字段
  重点验证接口：GroupManager.createGroup、GroupManager.destroyGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_name_and_avatar_abnormal_inputs[group_name_space_only-overrides0-None]

### 109. 创建 group name and avatar abnormal inputs（参数：group_name_too_long_256-overrides1-None）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 创建群
  2. 验证创建群返回的错误码与错误文案
  3. 验证创建群返回的关键字段
  4. A 销毁测试群
  5. 验证销毁测试群返回的关键字段
  重点验证接口：GroupManager.createGroup、GroupManager.destroyGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_name_and_avatar_abnormal_inputs[group_name_too_long_256-overrides1-None]

### 110. 创建 group name and avatar abnormal inputs（参数：group_name_too_long_512-overrides2-None）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 创建群
  2. 验证创建群返回的错误码与错误文案
  3. 验证创建群返回的关键字段
  4. A 销毁测试群
  5. 验证销毁测试群返回的关键字段
  重点验证接口：GroupManager.createGroup、GroupManager.destroyGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_name_and_avatar_abnormal_inputs[group_name_too_long_512-overrides2-None]

### 111. 创建 group optional fields 空（参数：查询条件_ext_空-overrides4）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 创建群
  2. 验证创建群返回的关键字段
  3. A 销毁测试群
  4. 验证销毁测试群返回的关键字段
  重点验证接口：GroupManager.createGroup、GroupManager.destroyGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_optional_fields_empty[options_ext_empty-overrides4]

### 112. 创建 group optional fields 空（参数：avatar_url_空-overrides0）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 创建群
  2. 验证创建群返回的关键字段
  3. A 销毁测试群
  4. 验证销毁测试群返回的关键字段
  重点验证接口：GroupManager.createGroup、GroupManager.destroyGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_optional_fields_empty[avatar_url_empty-overrides0]

### 113. 创建 group optional fields 空（参数：desc_空-overrides1）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 创建群
  2. 验证创建群返回的关键字段
  3. A 销毁测试群
  4. 验证销毁测试群返回的关键字段
  重点验证接口：GroupManager.createGroup、GroupManager.destroyGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_optional_fields_empty[desc_empty-overrides1]

### 114. 创建 group optional fields 空（参数：invite_members_空-overrides2）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 创建群
  2. 验证创建群返回的关键字段
  3. A 销毁测试群
  4. 验证销毁测试群返回的关键字段
  重点验证接口：GroupManager.createGroup、GroupManager.destroyGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_optional_fields_empty[invite_members_empty-overrides2]

### 115. 创建 group optional fields 空（参数：invite_reason_空-overrides3）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 创建群
  2. 验证创建群返回的关键字段
  3. A 销毁测试群
  4. 验证销毁测试群返回的关键字段
  重点验证接口：GroupManager.createGroup、GroupManager.destroyGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_create_group_optional_fields_empty[invite_reason_empty-overrides3]

### 116. 错误 inviter 处理邀请应失败，随后正确 inviter 仍可接受同一 pending（参数：接受）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。原测试目标：错误 inviter 处理邀请应失败，随后正确 inviter 仍可接受同一 pending。
- 状态/版本说明：跳过：known inviter handling gap; decline path also has Android adapter key mismatch
- 源码：native-auto-test/tests/group/test_group_invitation_state_matrix.py::test_group_invitation_wrong_inviter_does_not_consume_pending[accept]

### 117. 错误 inviter 处理邀请应失败，随后正确 inviter 仍可接受同一 pending（参数：拒绝）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。原测试目标：错误 inviter 处理邀请应失败，随后正确 inviter 仍可接受同一 pending。
- 状态/版本说明：跳过：known inviter handling gap; decline path also has Android adapter key mismatch
- 源码：native-auto-test/tests/group/test_group_invitation_state_matrix.py::test_group_invitation_wrong_inviter_does_not_consume_pending[decline]

### 118. 冻结三种群角色屏蔽/取消屏蔽群消息的真实 SDK 行为（参数：成员）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立成员前置
  2. 动作端 屏蔽群消息
  3. 验证群业务状态、事件与关键字段
  4. 动作端 取消屏蔽群消息
  5. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.blockGroup、GroupManager.unblockGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_message_block_role_matrix[member]

### 119. 冻结三种群角色屏蔽/取消屏蔽群消息的真实 SDK 行为（参数：admin）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立成员前置
  2. 动作端 屏蔽群消息
  3. 验证群业务状态、事件与关键字段
  4. 动作端 取消屏蔽群消息
  5. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.blockGroup、GroupManager.unblockGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_message_block_role_matrix[admin]

### 120. 冻结三种群角色屏蔽/取消屏蔽群消息的真实 SDK 行为（参数：owner）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立成员前置
  2. 动作端 屏蔽群消息
  3. 验证群业务状态、事件与关键字段
  4. 动作端 取消屏蔽群消息
  5. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.blockGroup、GroupManager.unblockGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_message_block_role_matrix[owner]

### 121. 防止 3000 场景漏传给建群请求，或覆盖 maxCount=2 的容量边界用例

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 验证本用例的关键业务结果
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_capacity.py::test_group_options_use_active_capacity_unless_boundary_value_is_explicit

### 122. 防止错误的运行参数创建无效容量群并污染真实测试环境（参数：-1）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 验证非法容量 被拒绝并返回 ValueError
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_capacity.py::test_group_capacity_rejects_non_positive_values[-1]

### 123. 防止错误的运行参数创建无效容量群并污染真实测试环境（参数：0）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 验证非法容量 被拒绝并返回 ValueError
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_capacity.py::test_group_capacity_rejects_non_positive_values[0]

### 124. 防止默认群容量漂移，或扩容场景没有将常规建群容量切换为 3000

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 验证本用例的关键业务结果
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_capacity.py::test_group_capacity_defaults_to_200_and_accepts_3000_override

### 125. 防止未传 max_user_count_value 的群快照断言在 3000 场景退回 200

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 验证本用例的关键业务结果
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_capacity.py::test_group_snapshot_default_uses_active_capacity

### 126. 非成员不能处理其他用户的有效 pending 申请（参数：接受）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 执行群组业务操作
  3. 验证执行群组业务操作返回的错误码与错误文案
  4. 验证执行群组业务操作返回的响应 result 与关键字段
  5. 测试后置：销毁测试群并恢复群状态
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_join_application_state_matrix.py::test_group_non_member_cannot_process_join_application[accept]

### 127. 非成员不能处理其他用户的有效 pending 申请（参数：拒绝）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 执行群组业务操作
  3. 验证执行群组业务操作返回的错误码与错误文案
  4. 验证执行群组业务操作返回的响应 result 与关键字段
  5. 测试后置：销毁测试群并恢复群状态
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_join_application_state_matrix.py::test_group_non_member_cannot_process_join_application[decline]

### 128. 服务端 state list nonexistent group（参数：getGroupBlockListFromServer）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. A 执行群组业务操作
  2. 验证执行群组业务操作返回的错误码与错误文案
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_server_state_lists.py::test_group_server_state_list_nonexistent_group[getGroupBlockListFromServer]

### 129. 服务端 state list nonexistent group（参数：getGroupMuteListFromServer）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. A 执行群组业务操作
  2. 验证执行群组业务操作返回的错误码与错误文案
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_server_state_lists.py::test_group_server_state_list_nonexistent_group[getGroupMuteListFromServer]

### 130. 服务端 state list nonexistent group（参数：getGroupWhiteListFromServer）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. A 执行群组业务操作
  2. 验证执行群组业务操作返回的错误码与错误文案
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_server_state_lists.py::test_group_server_state_list_nonexistent_group[getGroupWhiteListFromServer]

### 131. 服务端 state list nonexistent group（参数：isMemberInWhiteListFromServer）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. A 执行群组业务操作
  2. 验证执行群组业务操作返回的错误码与错误文案
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_server_state_lists.py::test_group_server_state_list_nonexistent_group[isMemberInWhiteListFromServer]

### 132. 复现流程： 1) 邀请别人入群（addMembers） 2) getGroupWithId（本地）读取人数 3) getGroupSpecificationFromServer（服务端）读取人数 4) 再次 getGroupWithId（本地）读取人数，验证与服务端一致 说明： - 若本地人数与服务端人数不一致，则判定“复现到问题”； - 若未出现不一致，则该环境下未复现，使用 skip 标记

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 添加群成员
  3. 验证 添加群成员返回的关键字段
  4. A 查询本地群详情
  5. 验证查询本地群详情返回的关键字段
  6. A 查询服务端群详情
  7. 验证查询服务端群详情返回的关键字段
  8. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.addMembers、GroupManager.getGroupWithId、GroupManager.getGroupSpecificationFromServer。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group.py::test_group_member_count_local_then_server_sync

### 133. 更新本人昵称/头像后，fetchGroupMembersInfo 返回的本人 EMGroupMemberInfo 字段保持一致

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 查询用户资料
  2. 验证查询用户资料返回的响应 result 与关键字段
  3. 测试准备：创建测试群并建立业务前置
  4. A 查询群成员信息
  5. 验证查询群成员信息返回的响应 result 与关键字段
  6. 验证群业务状态、事件与关键字段
  7. 测试后置：销毁测试群并恢复群状态
  重点验证接口：UserInfoManager.updateOwnUserInfo、UserInfoManager.fetchUserInfoById、GroupManager.fetchGroupMembersInfo。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_member_info.py::test_group_fetch_members_info_contains_updated_own_profile

### 134. 管理员和普通成员不能解散群，失败后群仍可由群主查询和清理（参数：成员）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立成员前置
  2. B 销毁测试群
  3. 验证销毁测试群返回的错误码与错误文案
  4. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.destroyGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_destroy_owner_only_role_denied[member]

### 135. 管理员和普通成员不能解散群，失败后群仍可由群主查询和清理（参数：admin）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立成员前置
  2. B 销毁测试群
  3. 验证销毁测试群返回的错误码与错误文案
  4. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.destroyGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_destroy_owner_only_role_denied[admin]

### 136. 管理员可修改群名称、描述、扩展；普通成员返回群字段权限错误（参数：成员）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立成员前置
  2. B 执行群组业务操作
  3. 验证执行群组业务操作返回的错误码与错误文案
  4. 验证群业务状态、事件与关键字段
  5. 验证执行群组业务操作返回的响应 result 与关键字段
  6. 等待并校验目标业务事件
  7. 测试后置：销毁测试群并恢复群状态
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_metadata_admin_member_role_matrix[member]

### 137. 管理员可修改群名称、描述、扩展；普通成员返回群字段权限错误（参数：admin）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立成员前置
  2. B 执行群组业务操作
  3. 验证执行群组业务操作返回的错误码与错误文案
  4. 验证群业务状态、事件与关键字段
  5. 验证执行群组业务操作返回的响应 result 与关键字段
  6. 等待并校验目标业务事件
  7. 测试后置：销毁测试群并恢复群状态
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_metadata_admin_member_role_matrix[admin]

### 138. 管理员可增删群黑名单；普通成员返回管理员权限错误且状态不变（参数：成员）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立成员前置
  2. 将目标成员加入群黑名单
  3. 验证移出群黑名单返回的错误码与错误文案
  4. 验证群业务状态、事件与关键字段
  5. 等待并校验目标业务事件
  6. 将目标成员移出群黑名单
  7. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.blockMembers、GroupManager.unblockMembers。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_blocklist_admin_member_role_matrix[member]

### 139. 管理员可增删群黑名单；普通成员返回管理员权限错误且状态不变（参数：admin）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立成员前置
  2. 将目标成员加入群黑名单
  3. 验证移出群黑名单返回的错误码与错误文案
  4. 验证群业务状态、事件与关键字段
  5. 等待并校验目标业务事件
  6. 将目标成员移出群黑名单
  7. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.blockMembers、GroupManager.unblockMembers。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_blocklist_admin_member_role_matrix[admin]

### 140. 获取 成员 属性 nonexistent group

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 执行群组业务操作
  2. 验证执行群组业务操作返回的响应 result 与关键字段
  重点验证接口：GroupManager.fetchMemberAttributesFromGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_member_attributes.py::test_group_fetch_member_attributes_nonexistent_group

### 141. 获取 成员 属性 nonexistent group

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 执行群组业务操作
  2. 验证执行群组业务操作返回的响应 result 与关键字段
  重点验证接口：GroupManager.fetchMembersAttributesFromGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_member_attributes.py::test_group_fetch_members_attributes_nonexistent_group

### 142. 获取 announcement nonexistent group

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. A 查询群公告
  2. 验证查询群公告返回的错误码与错误文案
  重点验证接口：GroupManager.getGroupAnnouncementFromServer。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_announcement.py::test_group_get_announcement_nonexistent_group

### 143. 获取 group 成员 list 从服务端 成功

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 查询服务端成员列表
  3. 验证查询服务端成员列表返回的关键字段
  4. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.getGroupMemberListFromServer。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_member_list.py::test_group_get_group_member_list_from_server_success

### 144. 获取 group 成员 list 从服务端 无效 paging（参数：-1-20）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. A 查询服务端成员列表
  2. 验证查询服务端成员列表返回的关键字段
  3. 验证查询服务端成员列表返回的错误码与错误文案
  重点验证接口：GroupManager.getGroupMemberListFromServer。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_member_list.py::test_group_get_group_member_list_from_server_invalid_paging[-1-20]

### 145. 获取 group 成员 list 从服务端 无效 paging（参数：0-20）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. A 查询服务端成员列表
  2. 验证查询服务端成员列表返回的关键字段
  3. 验证查询服务端成员列表返回的错误码与错误文案
  重点验证接口：GroupManager.getGroupMemberListFromServer。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_member_list.py::test_group_get_group_member_list_from_server_invalid_paging[0-20]

### 146. 获取 group 成员 list 从服务端 无效 paging（参数：1--1）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. A 查询服务端成员列表
  2. 验证查询服务端成员列表返回的关键字段
  3. 验证查询服务端成员列表返回的错误码与错误文案
  重点验证接口：GroupManager.getGroupMemberListFromServer。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_member_list.py::test_group_get_group_member_list_from_server_invalid_paging[1--1]

### 147. 获取 group 成员 list 从服务端 无效 paging（参数：1-0）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. A 查询服务端成员列表
  2. 验证查询服务端成员列表返回的关键字段
  3. 验证查询服务端成员列表返回的错误码与错误文案
  重点验证接口：GroupManager.getGroupMemberListFromServer。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_member_list.py::test_group_get_group_member_list_from_server_invalid_paging[1-0]

### 148. 获取 group 成员 list 从服务端 nonexistent group

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. A 查询服务端成员列表
  2. 验证查询服务端成员列表返回的错误码与错误文案
  重点验证接口：GroupManager.getGroupMemberListFromServer。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_member_list.py::test_group_get_group_member_list_from_server_nonexistent_group

### 149. 获取 group 从服务端

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 查询服务端群详情
  3. 验证查询服务端群详情返回的关键字段
  4. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.getGroupSpecificationFromServer。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_lifecycle.py::test_group_get_group_from_server

### 150. 获取 group 从服务端 after destroy

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. 测试后置：销毁测试群并恢复群状态
  3. A 查询服务端群详情
  4. 验证查询服务端群详情返回的错误码与错误文案
  重点验证接口：GroupManager.getGroupSpecificationFromServer。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_lifecycle.py::test_group_get_group_from_server_after_destroy

### 151. 获取 group 从服务端 nonexistent

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. A 查询服务端群详情
  2. 验证查询服务端群详情返回的错误码与错误文案
  重点验证接口：GroupManager.getGroupSpecificationFromServer。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_get_group_from_server_nonexistent

### 152. 获取 group 带 id nonexistent

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 查询本地群详情
  2. 验证查询本地群详情返回的关键字段
  重点验证接口：GroupManager.getGroupWithId。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_get_group_with_id_nonexistent

### 153. 获取 group 文件 list 从服务端 成功

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 查询群共享文件列表
  3. 验证查询群共享文件列表返回的关键字段
  4. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.getGroupFileListFromServer。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_file_list.py::test_group_get_group_file_list_from_server_success

### 154. 获取 group 文件 list 从服务端 nonexistent group（参数：0-20）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. A 查询群共享文件列表
  2. 验证查询群共享文件列表返回的错误码与错误文案
  重点验证接口：GroupManager.getGroupFileListFromServer。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_file_list.py::test_group_get_group_file_list_from_server_nonexistent_group[0-20]

### 155. 获取 group 文件 list 从服务端 nonexistent group（参数：1-0）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. A 查询群共享文件列表
  2. 验证查询群共享文件列表返回的错误码与错误文案
  重点验证接口：GroupManager.getGroupFileListFromServer。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_file_list.py::test_group_get_group_file_list_from_server_nonexistent_group[1-0]

### 156. 获取 group 文件 list 从服务端 nonexistent group（参数：1-20）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. A 查询群共享文件列表
  2. 验证查询群共享文件列表返回的错误码与错误文案
  重点验证接口：GroupManager.getGroupFileListFromServer。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_file_list.py::test_group_get_group_file_list_from_server_nonexistent_group[1-20]

### 157. 获取 group block list 从服务端 成功

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 查询群黑名单
  3. 验证查询群黑名单返回的关键字段
  4. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.getGroupBlockListFromServer。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_server_state_lists.py::test_group_get_group_block_list_from_server_success

### 158. 获取 group mute list 从服务端 成功

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 查询群禁言列表
  3. 验证查询群禁言列表返回的关键字段
  4. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.getGroupMuteListFromServer。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_server_state_lists.py::test_group_get_group_mute_list_from_server_success

### 159. 获取 group white list and 成员 check 成功

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 查询群白名单
  3. 验证查询群白名单返回的关键字段
  4. A 查询白名单成员状态
  5. 验证查询白名单成员状态返回的关键字段
  6. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.getGroupWhiteListFromServer、GroupManager.isMemberInWhiteListFromServer。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_server_state_lists.py::test_group_get_group_white_list_and_member_check_success

### 160. 获取 joined group count 带扩展信息

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：5.0 不适用：5.0 移除服务端拉公开群（getPublicGroupsFromServer 残留，无公开群列表）
- 源码：native-auto-test/tests/group/test_group_exceptions_public_groups_count.py::test_group_fetch_joined_group_count_with_extra_info

### 161. 获取 joined groups 从服务端 带扩展信息

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：5.0 不适用：5.0 移除 getJoinedGroupsFromServer（残留，改本地 getJoinedGroups）
- 源码：native-auto-test/tests/group/test_group_exceptions_joined_groups.py::test_group_get_joined_groups_from_server_with_extra_info_fields

### 162. 获取 joined groups 带扩展信息

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. A 查询本地已加入群列表
  2. 验证查询本地已加入群列表返回的关键字段
  重点验证接口：GroupManager.getJoinedGroups。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_joined_groups.py::test_group_get_joined_groups_with_extra_info_fields

### 163. 获取 public groups 从服务端 无效 paging（参数：-1-20）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：5.0 不适用：5.0 移除服务端拉公开群（getPublicGroupsFromServer 残留，无公开群列表）
- 源码：native-auto-test/tests/group/test_group_exceptions_public_groups_count.py::test_group_get_public_groups_from_server_invalid_paging[-1-20]

### 164. 获取 public groups 从服务端 无效 paging（参数：0-20）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：5.0 不适用：5.0 移除服务端拉公开群（getPublicGroupsFromServer 残留，无公开群列表）
- 源码：native-auto-test/tests/group/test_group_exceptions_public_groups_count.py::test_group_get_public_groups_from_server_invalid_paging[0-20]

### 165. 获取 public groups 从服务端 无效 paging（参数：1--1）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：5.0 不适用：5.0 移除服务端拉公开群（getPublicGroupsFromServer 残留，无公开群列表）
- 源码：native-auto-test/tests/group/test_group_exceptions_public_groups_count.py::test_group_get_public_groups_from_server_invalid_paging[1--1]

### 166. 获取 public groups 从服务端 无效 paging（参数：1-0）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。
- 状态/版本说明：5.0 不适用：5.0 移除服务端拉公开群（getPublicGroupsFromServer 残留，无公开群列表）
- 源码：native-auto-test/tests/group/test_group_exceptions_public_groups_count.py::test_group_get_public_groups_from_server_invalid_paging[1-0]

### 167. 即使 style=1 允许成员邀请，非成员仍不能调用任一邀请 API（参数：添加-成员）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. B 执行群组业务操作
  3. 验证执行群组业务操作返回的错误码与错误文案
  4. 测试后置：销毁测试群并恢复群状态
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_non_member_cannot_invite_user[add-members]

### 168. 即使 style=1 允许成员邀请，非成员仍不能调用任一邀请 API（参数：inviter-user）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. B 执行群组业务操作
  3. 验证执行群组业务操作返回的错误码与错误文案
  4. 测试后置：销毁测试群并恢复群状态
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_non_member_cannot_invite_user[inviter-user]

### 169. 接受 邀请 从 group 没有待处理邀请

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. B 接受入群邀请
  2. 验证接受入群邀请返回的错误码与错误文案
  重点验证接口：GroupManager.acceptInvitationFromGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_join_requests_and_invitations.py::test_group_accept_invitation_from_group_without_pending_invite

### 170. 接受 join application nonexistent group

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 同意入群申请
  2. 验证同意入群申请返回的错误码与错误文案
  重点验证接口：GroupManager.acceptJoinApplication。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_join_requests_and_invitations.py::test_group_accept_join_application_nonexistent_group

### 171. 接受 join application nonexistent user

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 同意入群申请
  3. 验证同意入群申请返回的错误码与错误文案
  4. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.acceptJoinApplication。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_join_requests_and_invitations.py::test_group_accept_join_application_nonexistent_user

### 172. 拒绝 邀请 从 group 没有待处理邀请

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. B 拒绝入群邀请
  2. 验证拒绝入群邀请返回的错误码与错误文案
  重点验证接口：GroupManager.declineInvitationFromGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_join_requests_and_invitations.py::test_group_decline_invitation_from_group_without_pending_invite

### 173. 拒绝 join application nonexistent group

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 拒绝入群申请
  2. 验证拒绝入群申请返回的错误码与错误文案
  重点验证接口：GroupManager.declineJoinApplication。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_join_requests_and_invitations.py::test_group_decline_join_application_nonexistent_group

### 174. 空申请原因应被服务端规范化，并且 pending 仍可被正常拒绝

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. B 申请加入公开群
  3. 验证群业务状态、事件与关键字段
  4. 等待并校验目标业务事件
  5. A 拒绝入群申请
  6. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.requestToJoinPublicGroup、GroupManager.declineJoinApplication。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_join_application_state_matrix.py::test_group_join_application_empty_reason_uses_server_default

### 175. 链路： 1) A 建群并邀请 B 2) B 在群里发父消息 3) A 用父消息创建子区并让 B 加入 4) A 把 B 从子区移除 5) 查询子区成员，断言 A 仍在且 B 已被移除 当前 Android 实测 removeMemberFromChatThread 成功后不派发 onUserKickOutOfChatThread，因此按 SDK 可查询的真实成员状态验收移除结果

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. B 发送群消息
  3. 验证发送群消息返回的关键字段
  4. A 创建子区
  5. 验证创建子区返回的关键字段
  6. B 加入子区
  7. 验证加入子区返回的关键字段
  8. A 查询子区成员
  重点验证接口：ChatManager.sendMessage、ChatThreadManager.createChatThread、ChatThreadManager.joinChatThread、ChatThreadManager.fetchChatThreadMember、ChatThreadManager.removeMemberFromChatThread、ChatThreadManager.destroyChatThread。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_chat_thread_user_removed.py::test_chat_thread_remove_member_updates_member_list

### 176. 普通成员不能处理申请；管理员按原生权限接收并处理申请（参数：成员-接受）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。原测试目标：普通成员不能处理申请；管理员按原生权限接收并处理申请。
- 状态/版本说明：跳过：known Android SDK bug: admin accepter is reported as group owner
- 源码：native-auto-test/tests/group/test_group_join_application_state_matrix.py::test_group_join_application_processing_permission_by_role[member-accept]

### 177. 普通成员不能处理申请；管理员按原生权限接收并处理申请（参数：成员-拒绝）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。原测试目标：普通成员不能处理申请；管理员按原生权限接收并处理申请。
- 状态/版本说明：跳过：known Android SDK bug: admin accepter is reported as group owner
- 源码：native-auto-test/tests/group/test_group_join_application_state_matrix.py::test_group_join_application_processing_permission_by_role[member-decline]

### 178. 普通成员不能处理申请；管理员按原生权限接收并处理申请（参数：admin-接受）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。原测试目标：普通成员不能处理申请；管理员按原生权限接收并处理申请。
- 状态/版本说明：跳过：known Android SDK bug: admin accepter is reported as group owner
- 源码：native-auto-test/tests/group/test_group_join_application_state_matrix.py::test_group_join_application_processing_permission_by_role[admin-accept]

### 179. 普通成员不能处理申请；管理员按原生权限接收并处理申请（参数：admin-拒绝）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。原测试目标：普通成员不能处理申请；管理员按原生权限接收并处理申请。
- 状态/版本说明：跳过：known Android SDK bug: admin accepter is reported as group owner
- 源码：native-auto-test/tests/group/test_group_join_application_state_matrix.py::test_group_join_application_processing_permission_by_role[admin-decline]

### 180. 前置：使用固定不存在的 groupId 和 fileId

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 执行群组业务操作
  2. 验证执行群组业务操作返回的错误码与错误文案
  重点验证接口：GroupManager.removeGroupSharedFile。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_shared_files.py::test_group_remove_shared_file_nonexistent_group

### 181. 前置：使用固定不存在的 groupId 和显式 Android 不可读路径

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 上传群共享文件
  2. 验证 上传群共享文件返回的错误码与错误文案
  重点验证接口：GroupManager.uploadGroupSharedFile。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_shared_files.py::test_group_upload_shared_file_nonexistent_group

### 182. 前置：使用固定不存在的 groupId/fileId 和宿主机保存路径

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 下载群共享文件
  2. 验证 下载群共享文件返回的关键字段
  重点验证接口：GroupManager.downloadGroupSharedFile。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_shared_files.py::test_group_download_shared_file_nonexistent_group_current_behavior

### 183. 前置：A 为群主，显式设备路径在 Android 中不存在

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 上传群共享文件
  3. 验证 上传群共享文件返回的错误码与错误文案
  4. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.uploadGroupSharedFile。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_shared_files.py::test_group_upload_shared_file_invalid_path

### 184. 前置：A 为群主，B 初始不是目标群成员，B 的自动接受邀请开关为 true

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. 等待并校验目标业务事件
  3. 验证群业务状态、事件与关键字段
  4. 验证本用例的关键业务结果
  5. A 移除群成员
  6. 验证 移除群成员返回的关键字段
  7. A 添加群成员
  8. 验证 添加群成员返回的关键字段
  重点验证接口：GroupManager.removeMembers、GroupManager.addMembers、GroupManager.leaveGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_joined_groups.py::test_group_joined_lists_follow_invite_remove_readd_and_member_leave

### 185. 前置：A 为群主；传入的 `/private/tmp/...` 是 macOS 宿主机路径，不存在于 Android

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 上传群共享文件
  3. 验证 上传群共享文件返回的错误码与错误文案
  4. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.uploadGroupSharedFile。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_shared_files.py::test_group_upload_shared_file_explicit_host_path_is_invalid

### 186. 前置：A 已登录，当前账号可能已加入零个或多个共享环境群组

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. A 查询已加入群数量
  2. 验证查询已加入群数量返回的关键字段
  重点验证接口：GroupManager.fetchJoinedGroupCount。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_public_groups_count.py::test_group_fetch_joined_group_count_success

### 187. 前置：A 已登录，公开群列表允许包含共享环境已有数据

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。原测试目标：前置：A 已登录，公开群列表允许包含共享环境已有数据。 步骤：A 使用真实 cursor API 参数 pageSize=20 拉取第一页，不传 pageNum。 预期与断言：响应严格包含 cursor/list；cursor 为字符串，每个列表项严格只有 groupId/name。
- 状态/版本说明：5.0 不适用：5.0 移除服务端拉公开群（getPublicGroupsFromServer 残留，无公开群列表）
- 源码：native-auto-test/tests/group/test_group_public_groups_count.py::test_group_get_public_groups_from_server_success

### 188. 前置：A 已登录；测试依次创建两个名称唯一的 PublicOpenJoin（style=3）公开群

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。原测试目标：前置：A 已登录；测试依次创建两个名称唯一的 PublicOpenJoin（style=3）公开群。 步骤：A 以 pageSize=1 从无 cursor 的第一页开始查询；若返回非空 cursor，则将该真实 cursor 原样传入下一页，最多遍历 100 页，直到找到本次两个动态 groupId。 预期与断言：每页响应严格只有 cursor/list，每页最多一个且不得重复 groupId；目标群 出现时必须精确匹配创建时的 groupId/name；找到两个目标前 cursor 不得为空，且连续 两页 cursor 不得相同；最终两个目标均被真实 cursor 链路找到。
- 状态/版本说明：5.0 不适用：5.0 移除服务端拉公开群（getPublicGroupsFromServer 残留，无公开群列表）
- 源码：native-auto-test/tests/group/test_group_public_groups_count.py::test_group_public_groups_cursor_paginates_two_created_groups

### 189. 前置：A 已登录且尚未创建本 case 的目标群

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 查询本地已加入群列表
  3. 验证查询本地已加入群列表返回的关键字段
  4. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.getJoinedGroups。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_joined_groups.py::test_group_get_joined_groups_contains_created_group

### 190. 前置：A 已登录且尚未创建本 case 的目标群

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 查询本地已加入群列表
  3. 验证查询本地已加入群列表返回的关键字段
  4. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.getJoinedGroups。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_joined_groups.py::test_group_get_joined_groups_local_contains_created_group

### 191. 前置：A/B 已登录，A 创建 PrivateMemberCanInvite（style=1）私有群，B 不是成员

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. B 加入公开群
  3. 验证加入公开群返回的错误码与错误文案
  4. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.joinPublicGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_members.py::test_group_join_public_group_rejects_private_member_invite_group

### 192. 群主/管理员可禁言与解除禁言；普通成员被拒绝且状态不变（参数：成员）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立成员前置
  2. 动作端 禁言成员
  3. 验证解除成员禁言返回的错误码与错误文案
  4. 验证 禁言成员返回的关键字段
  5. 等待并校验目标业务事件
  6. 验证群业务状态、事件与关键字段
  7. 动作端 解除成员禁言
  8. 验证解除成员禁言返回的关键字段
  重点验证接口：GroupManager.muteMembers、GroupManager.unMuteMembers。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_mute_members_role_permission_matrix[member]

### 193. 群主/管理员可禁言与解除禁言；普通成员被拒绝且状态不变（参数：admin）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立成员前置
  2. 动作端 禁言成员
  3. 验证解除成员禁言返回的错误码与错误文案
  4. 验证 禁言成员返回的关键字段
  5. 等待并校验目标业务事件
  6. 验证群业务状态、事件与关键字段
  7. 动作端 解除成员禁言
  8. 验证解除成员禁言返回的关键字段
  重点验证接口：GroupManager.muteMembers、GroupManager.unMuteMembers。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_mute_members_role_permission_matrix[admin]

### 194. 群主/管理员可禁言与解除禁言；普通成员被拒绝且状态不变（参数：owner）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立成员前置
  2. 动作端 禁言成员
  3. 验证解除成员禁言返回的错误码与错误文案
  4. 验证 禁言成员返回的关键字段
  5. 等待并校验目标业务事件
  6. 验证群业务状态、事件与关键字段
  7. 动作端 解除成员禁言
  8. 验证解除成员禁言返回的关键字段
  重点验证接口：GroupManager.muteMembers、GroupManager.unMuteMembers。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_mute_members_role_permission_matrix[owner]

### 195. 群主/管理员可切换全员禁言；普通成员被拒绝且状态不变（参数：成员）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立成员前置
  2. 动作端 全员禁言
  3. 验证解除全员禁言返回的错误码与错误文案
  4. 验证 全员禁言返回的关键字段
  5. 等待并校验目标业务事件
  6. 验证群业务状态、事件与关键字段
  7. 动作端 解除全员禁言
  8. 验证解除全员禁言返回的关键字段
  重点验证接口：GroupManager.muteAllMembers、GroupManager.unMuteAllMembers。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_mute_all_role_permission_matrix[member]

### 196. 群主/管理员可切换全员禁言；普通成员被拒绝且状态不变（参数：admin）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立成员前置
  2. 动作端 全员禁言
  3. 验证解除全员禁言返回的错误码与错误文案
  4. 验证 全员禁言返回的关键字段
  5. 等待并校验目标业务事件
  6. 验证群业务状态、事件与关键字段
  7. 动作端 解除全员禁言
  8. 验证解除全员禁言返回的关键字段
  重点验证接口：GroupManager.muteAllMembers、GroupManager.unMuteAllMembers。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_mute_all_role_permission_matrix[admin]

### 197. 群主/管理员可切换全员禁言；普通成员被拒绝且状态不变（参数：owner）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立成员前置
  2. 动作端 全员禁言
  3. 验证解除全员禁言返回的错误码与错误文案
  4. 验证 全员禁言返回的关键字段
  5. 等待并校验目标业务事件
  6. 验证群业务状态、事件与关键字段
  7. 动作端 解除全员禁言
  8. 验证解除全员禁言返回的关键字段
  重点验证接口：GroupManager.muteAllMembers、GroupManager.unMuteAllMembers。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_mute_all_role_permission_matrix[owner]

### 198. 群主/管理员可增删白名单；普通成员被拒绝且白名单保持为空（参数：成员）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立成员前置
  2. 动作端 加入群白名单
  3. 验证移出群白名单返回的错误码与错误文案
  4. 验证群业务状态、事件与关键字段
  5. 等待并校验目标业务事件
  6. 动作端 查询白名单成员状态
  7. 动作端 移出群白名单
  8. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.addWhiteList、GroupManager.isMemberInWhiteListFromServer、GroupManager.removeWhiteList。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_allow_list_role_permission_matrix[member]

### 199. 群主/管理员可增删白名单；普通成员被拒绝且白名单保持为空（参数：admin）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立成员前置
  2. 动作端 加入群白名单
  3. 验证移出群白名单返回的错误码与错误文案
  4. 验证群业务状态、事件与关键字段
  5. 等待并校验目标业务事件
  6. 动作端 查询白名单成员状态
  7. 动作端 移出群白名单
  8. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.addWhiteList、GroupManager.isMemberInWhiteListFromServer、GroupManager.removeWhiteList。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_allow_list_role_permission_matrix[admin]

### 200. 群主/管理员可增删白名单；普通成员被拒绝且白名单保持为空（参数：owner）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立成员前置
  2. 动作端 加入群白名单
  3. 验证移出群白名单返回的错误码与错误文案
  4. 验证群业务状态、事件与关键字段
  5. 等待并校验目标业务事件
  6. 动作端 查询白名单成员状态
  7. 动作端 移出群白名单
  8. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.addWhiteList、GroupManager.isMemberInWhiteListFromServer、GroupManager.removeWhiteList。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_role_permission_matrix.py::test_group_allow_list_role_permission_matrix[owner]

### 201. 删除 成员 属性 成功

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. B 执行群组业务操作
  3. 验证执行群组业务操作返回的响应 result 与关键字段
  4. 等待并校验目标业务事件
  5. B 删除成员属性
  6. 验证删除成员属性返回的关键字段
  7. A 执行群组业务操作
  8. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.setMemberAttributesFromGroup、GroupManager.removeMemberAttributesFromGroup、GroupManager.fetchMemberAttributesFromGroup、GroupManager.fetchMembersAttributesFromGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_member_attributes_remove.py::test_group_remove_member_attributes_success

### 202. 删除 成员 属性 空 keys

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 删除成员属性
  3. 验证删除成员属性返回的错误码与错误文案
  4. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.removeMemberAttributesFromGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_member_attributes_remove.py::test_group_remove_member_attributes_empty_keys

### 203. 删除 成员 属性 nonexistent group

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 删除成员属性
  2. 验证删除成员属性返回的关键字段
  重点验证接口：GroupManager.removeMemberAttributesFromGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_member_attributes_remove.py::test_group_remove_member_attributes_nonexistent_group

### 204. 删除 成员 属性 nonexistent key

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 删除成员属性
  3. 验证删除成员属性返回的关键字段
  4. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.removeMemberAttributesFromGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_member_attributes_remove.py::test_group_remove_member_attributes_nonexistent_key

### 205. 删除 成员 non 成员

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 移除群成员
  3. 验证 移除群成员返回的错误码与错误文案
  4. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.removeMembers。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_members.py::test_group_remove_members_non_member

### 206. 删除 admin nonexistent group

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 移除群管理员
  2. 验证 移除群管理员返回的错误码与错误文案
  重点验证接口：GroupManager.removeAdmin。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_roles.py::test_group_remove_admin_nonexistent_group

### 207. 添加 成员 空 成员

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 添加群成员
  3. 验证 添加群成员返回的关键字段
  4. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.addMembers。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_members.py::test_group_add_members_empty_members

### 208. 添加 成员 nonexistent group

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 添加群成员
  2. 验证 添加群成员返回的错误码与错误文案
  重点验证接口：GroupManager.addMembers。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_members.py::test_group_add_members_nonexistent_group

### 209. 添加 成员 nonexistent user

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 添加群成员
  3. 验证 添加群成员返回的错误码与错误文案
  4. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.addMembers。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_members.py::test_group_add_members_nonexistent_user

### 210. 添加 admin non 成员

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 添加群管理员
  3. 验证 添加群管理员返回的错误码与错误文案
  4. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.addAdmin。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_roles.py::test_group_add_admin_non_member

### 211. 添加 admin nonexistent group

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 添加群管理员
  2. 验证 添加群管理员返回的错误码与错误文案
  重点验证接口：GroupManager.addAdmin。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_roles.py::test_group_add_admin_nonexistent_group

### 212. 通用 inviterUser API 应覆盖 style=1/2/3 的群主邀请链路（参数：private-成员-添加-成员）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 执行群组业务操作
  3. 验证群业务状态、事件与关键字段
  4. 等待并校验目标业务事件
  5. 验证执行群组业务操作返回的响应 result 与关键字段
  6. 测试后置：销毁测试群并恢复群状态
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_owner_can_invite_for_each_remaining_style[private-member-add-members]

### 213. 通用 inviterUser API 应覆盖 style=1/2/3 的群主邀请链路（参数：private-成员-inviter-user）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 执行群组业务操作
  3. 验证群业务状态、事件与关键字段
  4. 等待并校验目标业务事件
  5. 验证执行群组业务操作返回的响应 result 与关键字段
  6. 测试后置：销毁测试群并恢复群状态
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_owner_can_invite_for_each_remaining_style[private-member-inviter-user]

### 214. 通用 inviterUser API 应覆盖 style=1/2/3 的群主邀请链路（参数：public-approval-添加-成员）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 执行群组业务操作
  3. 验证群业务状态、事件与关键字段
  4. 等待并校验目标业务事件
  5. 验证执行群组业务操作返回的响应 result 与关键字段
  6. 测试后置：销毁测试群并恢复群状态
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_owner_can_invite_for_each_remaining_style[public-approval-add-members]

### 215. 通用 inviterUser API 应覆盖 style=1/2/3 的群主邀请链路（参数：public-approval-inviter-user）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 执行群组业务操作
  3. 验证群业务状态、事件与关键字段
  4. 等待并校验目标业务事件
  5. 验证执行群组业务操作返回的响应 result 与关键字段
  6. 测试后置：销毁测试群并恢复群状态
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_owner_can_invite_for_each_remaining_style[public-approval-inviter-user]

### 216. 通用 inviterUser API 应覆盖 style=1/2/3 的群主邀请链路（参数：public-open-添加-成员）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 执行群组业务操作
  3. 验证群业务状态、事件与关键字段
  4. 等待并校验目标业务事件
  5. 验证执行群组业务操作返回的响应 result 与关键字段
  6. 测试后置：销毁测试群并恢复群状态
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_owner_can_invite_for_each_remaining_style[public-open-add-members]

### 217. 通用 inviterUser API 应覆盖 style=1/2/3 的群主邀请链路（参数：public-open-inviter-user）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 执行群组业务操作
  3. 验证群业务状态、事件与关键字段
  4. 等待并校验目标业务事件
  5. 验证执行群组业务操作返回的响应 result 与关键字段
  6. 测试后置：销毁测试群并恢复群状态
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_owner_can_invite_for_each_remaining_style[public-open-inviter-user]

### 218. 同一用户重复申请时，两次通知可见，但只保留一个可处理的 pending

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 拒绝入群申请
  3. 验证群业务状态、事件与关键字段
  4. 等待并校验目标业务事件
  5. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.declineJoinApplication。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_join_application_state_matrix.py::test_group_duplicate_join_application_keeps_single_pending_request

### 219. 校验新事件名： - onMembersJoinedFromGroup - onMembersExitedFromGroup

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 添加群成员
  3. 验证 添加群成员返回的关键字段
  4. 等待并校验目标业务事件
  5. A 移除群成员
  6. 验证 移除群成员返回的关键字段
  7. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.addMembers、GroupManager.removeMembers。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_members.py::test_group_members_batch_join_exit_new_events

### 220. 邀请首次处理后 pending 消失，重复或反向处理应失败且不改变首次结果（参数：接受-then-拒绝）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立成员前置
  2. B 执行群组业务操作
  3. 验证执行群组业务操作返回的响应 result 与关键字段
  4. 等待并校验目标业务事件
  5. 验证群业务状态、事件与关键字段
  6. 验证执行群组业务操作返回的错误码与错误文案
  7. 测试后置：销毁测试群并恢复群状态
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_invitation_state_matrix.py::test_group_invitation_cannot_be_processed_twice[accept-then-decline]

### 221. 邀请首次处理后 pending 消失，重复或反向处理应失败且不改变首次结果（参数：接受-twice）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立成员前置
  2. B 执行群组业务操作
  3. 验证执行群组业务操作返回的响应 result 与关键字段
  4. 等待并校验目标业务事件
  5. 验证群业务状态、事件与关键字段
  6. 验证执行群组业务操作返回的错误码与错误文案
  7. 测试后置：销毁测试群并恢复群状态
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_invitation_state_matrix.py::test_group_invitation_cannot_be_processed_twice[accept-twice]

### 222. 邀请首次处理后 pending 消失，重复或反向处理应失败且不改变首次结果（参数：拒绝-then-接受）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立成员前置
  2. B 执行群组业务操作
  3. 验证执行群组业务操作返回的响应 result 与关键字段
  4. 等待并校验目标业务事件
  5. 验证群业务状态、事件与关键字段
  6. 验证执行群组业务操作返回的错误码与错误文案
  7. 测试后置：销毁测试群并恢复群状态
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_invitation_state_matrix.py::test_group_invitation_cannot_be_processed_twice[decline-then-accept]

### 223. 邀请首次处理后 pending 消失，重复或反向处理应失败且不改变首次结果（参数：拒绝-twice）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立成员前置
  2. B 执行群组业务操作
  3. 验证执行群组业务操作返回的响应 result 与关键字段
  4. 等待并校验目标业务事件
  5. 验证群业务状态、事件与关键字段
  6. 验证执行群组业务操作返回的错误码与错误文案
  7. 测试后置：销毁测试群并恢复群状态
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_invitation_state_matrix.py::test_group_invitation_cannot_be_processed_twice[decline-twice]

### 224. 一个 pending 申请只能处理一次，重复或反向处理不得改变首次结果（参数：接受-then-拒绝）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 执行群组业务操作
  3. 验证群业务状态、事件与关键字段
  4. 等待并校验目标业务事件
  5. 验证执行群组业务操作返回的错误码与错误文案
  6. 测试后置：销毁测试群并恢复群状态
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_join_application_state_matrix.py::test_group_join_application_cannot_be_processed_twice[accept-then-decline]

### 225. 一个 pending 申请只能处理一次，重复或反向处理不得改变首次结果（参数：接受-twice）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 执行群组业务操作
  3. 验证群业务状态、事件与关键字段
  4. 等待并校验目标业务事件
  5. 验证执行群组业务操作返回的错误码与错误文案
  6. 测试后置：销毁测试群并恢复群状态
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_join_application_state_matrix.py::test_group_join_application_cannot_be_processed_twice[accept-twice]

### 226. 一个 pending 申请只能处理一次，重复或反向处理不得改变首次结果（参数：拒绝-then-接受）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 执行群组业务操作
  3. 验证群业务状态、事件与关键字段
  4. 等待并校验目标业务事件
  5. 验证执行群组业务操作返回的错误码与错误文案
  6. 测试后置：销毁测试群并恢复群状态
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_join_application_state_matrix.py::test_group_join_application_cannot_be_processed_twice[decline-then-accept]

### 227. 一个 pending 申请只能处理一次，重复或反向处理不得改变首次结果（参数：拒绝-twice）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 执行群组业务操作
  3. 验证群业务状态、事件与关键字段
  4. 等待并校验目标业务事件
  5. 验证执行群组业务操作返回的错误码与错误文案
  6. 测试后置：销毁测试群并恢复群状态
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_join_application_state_matrix.py::test_group_join_application_cannot_be_processed_twice[decline-twice]

### 228. 有效群中没有待处理邀请时，接受和拒绝都返回稳定错误（参数：接受）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. B 执行群组业务操作
  3. 验证执行群组业务操作返回的错误码与错误文案
  4. 测试后置：销毁测试群并恢复群状态
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_invitation_state_matrix.py::test_group_invitation_valid_group_without_pending_is_rejected[accept]

### 229. 有效群中没有待处理邀请时，接受和拒绝都返回稳定错误（参数：拒绝）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. B 执行群组业务操作
  3. 验证执行群组业务操作返回的错误码与错误文案
  4. 测试后置：销毁测试群并恢复群状态
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_invitation_state_matrix.py::test_group_invitation_valid_group_without_pending_is_rejected[decline]

### 230. 有效审批群中不存在 pending 申请时，同意和拒绝都应返回稳定错误（参数：接受）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 执行群组业务操作
  3. 验证执行群组业务操作返回的错误码与错误文案
  4. 测试后置：销毁测试群并恢复群状态
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_join_application_state_matrix.py::test_group_join_application_valid_group_without_pending_is_rejected[accept]

### 231. 有效审批群中不存在 pending 申请时，同意和拒绝都应返回稳定错误（参数：拒绝）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 执行群组业务操作
  3. 验证执行群组业务操作返回的错误码与错误文案
  4. 测试后置：销毁测试群并恢复群状态
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_join_application_state_matrix.py::test_group_join_application_valid_group_without_pending_is_rejected[decline]

### 232. A 向空或不存在 groupId 发送群文本时应失败，B 不得收到目标消息（参数：空）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 向 群目标发送文本并验证失败终态
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_message_send.py::test_group_message_send_rejects_invalid_group_target[empty]

### 233. A 向空或不存在 groupId 发送群文本时应失败，B 不得收到目标消息（参数：nonexistent）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 向 群目标发送文本并验证失败终态
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_message_send.py::test_group_message_send_rejects_invalid_group_target[nonexistent]

### 234. B 被移入群黑名单并移出后，不得通过 PublicOpenJoin 重新加入

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 加入群黑名单
  3. 验证加入群黑名单返回的关键字段
  4. 等待并校验目标业务事件
  5. B 加入公开群
  6. 验证加入公开群返回的错误码与错误文案
  7. 验证加入公开群返回的关键字段
  8. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.blockMembers、GroupManager.joinPublicGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_public_open_join_rejects_blocked_user

### 235. B 成功加入 PublicOpenJoin 后再次 join，不得重复增加成员或重复发送加入事件

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. B 加入公开群
  3. 验证群业务状态、事件与关键字段
  4. 等待并校验目标业务事件
  5. 验证加入公开群返回的错误码与错误文案
  6. 验证加入公开群返回的关键字段
  7. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.joinPublicGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_public_open_join_rejects_duplicate_membership

### 236. B 从未入群、主动退出或被移除后发送群文本均应失败，群主 A 不得收到消息（参数：left）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. B 退出群
  3. 验证退出群返回的关键字段
  4. 验证群业务状态、事件与关键字段
  5. A 移除群成员
  6. 验证 移除群成员返回的关键字段
  7. 等待并校验目标业务事件
  8. A 查询服务端群详情
  重点验证接口：GroupManager.leaveGroup、GroupManager.removeMembers、GroupManager.getGroupSpecificationFromServer。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_message_send.py::test_group_message_send_rejects_non_member_states[left]

### 237. B 从未入群、主动退出或被移除后发送群文本均应失败，群主 A 不得收到消息（参数：never-成员）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. B 退出群
  3. 验证退出群返回的关键字段
  4. 验证群业务状态、事件与关键字段
  5. A 移除群成员
  6. 验证 移除群成员返回的关键字段
  7. 等待并校验目标业务事件
  8. A 查询服务端群详情
  重点验证接口：GroupManager.leaveGroup、GroupManager.removeMembers、GroupManager.getGroupSpecificationFromServer。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_message_send.py::test_group_message_send_rejects_non_member_states[never-member]

### 238. B 从未入群、主动退出或被移除后发送群文本均应失败，群主 A 不得收到消息（参数：removed）

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. B 退出群
  3. 验证退出群返回的关键字段
  4. 验证群业务状态、事件与关键字段
  5. A 移除群成员
  6. 验证 移除群成员返回的关键字段
  7. 等待并校验目标业务事件
  8. A 查询服务端群详情
  重点验证接口：GroupManager.leaveGroup、GroupManager.removeMembers、GroupManager.getGroupSpecificationFromServer。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_message_send.py::test_group_message_send_rejects_non_member_states[removed]

### 239. block idempotent

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 屏蔽群消息
  3. 验证屏蔽群消息返回的关键字段
  4. 测试后置：A 取消屏蔽群消息
  5. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.blockGroup、GroupManager.unblockGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_blocking.py::test_group_block_idempotent

### 240. block nonexistent group

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 屏蔽群消息
  2. 验证屏蔽群消息返回的错误码与错误文案
  重点验证接口：GroupManager.blockGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_blocking.py::test_group_block_nonexistent_group

### 241. block then unblock 成功

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 屏蔽群消息
  3. 验证屏蔽群消息返回的关键字段
  4. 验证群业务状态、事件与关键字段
  5. A 取消屏蔽群消息
  6. 验证取消屏蔽群消息返回的关键字段
  7. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.blockGroup、GroupManager.unblockGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_blocking.py::test_group_block_then_unblock_success

### 242. block unblock 成员 nonexistent group（参数：blockMembers）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 执行群组业务操作
  2. 验证执行群组业务操作返回的错误码与错误文案
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_moderation.py::test_group_block_unblock_members_nonexistent_group[blockMembers]

### 243. block unblock 成员 nonexistent group（参数：unblockMembers）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 执行群组业务操作
  2. 验证执行群组业务操作返回的错误码与错误文案
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_moderation.py::test_group_block_unblock_members_nonexistent_group[unblockMembers]

### 244. clearAllGroupsFromLocal：清理本地群缓存，实测成功返回 None

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 清理本地群数据
  2. 验证清理本地群数据返回的响应 result 与关键字段
  重点验证接口：GroupManager.clearAllGroupsFromDB。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_remaining_api_coverage.py::test_group_clear_all_groups_from_local_success

### 245. createGroup.inviteMembers 应覆盖 style=1/2/3 的直接邀请入群链路（参数：private-成员）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. 等待并校验目标业务事件
  3. 验证本用例的关键业务结果
  4. 测试后置：销毁测试群并恢复群状态
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_create_group_invites_member_for_each_remaining_style[private-member]

### 246. createGroup.inviteMembers 应覆盖 style=1/2/3 的直接邀请入群链路（参数：public-approval）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. 等待并校验目标业务事件
  3. 验证本用例的关键业务结果
  4. 测试后置：销毁测试群并恢复群状态
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_create_group_invites_member_for_each_remaining_style[public-approval]

### 247. createGroup.inviteMembers 应覆盖 style=1/2/3 的直接邀请入群链路（参数：public-open）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. 等待并校验目标业务事件
  3. 验证本用例的关键业务结果
  4. 测试后置：销毁测试群并恢复群状态
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_create_group_invites_member_for_each_remaining_style[public-open]

### 248. destroy group 空 group id

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 销毁测试群
  2. 验证销毁测试群返回的错误码与错误文案
  重点验证接口：GroupManager.destroyGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_destroy_group_empty_group_id

### 249. destroy group nonexistent

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 销毁测试群
  2. 验证销毁测试群返回的错误码与错误文案
  重点验证接口：GroupManager.destroyGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_lifecycle.py::test_group_destroy_group_nonexistent

### 250. fetchChatThreadDetail/getThread会话/joined/parent 列表：创建并加入子区后校验详情、线程会话和列表

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立成员前置
  2. A 查询子区详情
  3. 验证查询子区详情返回的关键字段
  4. A 执行群消息操作
  5. 验证执行群消息操作返回的响应 result 与关键字段
  6. B 执行子区业务操作
  7. 验证执行子区业务操作返回的响应 result 与关键字段
  8. 验证群业务状态、事件与关键字段
  重点验证接口：ChatThreadManager.fetchChatThreadDetail、ChatManager.getThreadConversation、ChatThreadManager.fetchJoinedChatThreads、ChatThreadManager.fetchChatThreadsWithParentId、ChatThreadManager.fetchJoinedChatThreadsWithParentId。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_chat_thread_remaining_api_coverage.py::test_chat_thread_fetch_detail_and_lists

### 251. fetchGroupMembersInfo：groupId 为空字符串时，冻结真实错误返回

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 查询群成员信息
  2. 验证群业务状态、事件与关键字段
  重点验证接口：GroupManager.fetchGroupMembersInfo。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_remaining_api_coverage.py::test_group_fetch_members_info_empty_group_id

### 252. fetchGroupMembersInfo：limit=0 的分页边界，并比对成员资料与当前用户资料一致

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 查询用户资料
  2. 验证查询用户资料返回的响应 result 与关键字段
  3. 测试准备：创建测试群并建立业务前置
  4. A 查询群成员信息
  5. 验证查询群成员信息返回的响应 result 与关键字段
  6. 测试后置：销毁测试群并恢复群状态
  重点验证接口：UserInfoManager.fetchUserInfoById、GroupManager.fetchGroupMembersInfo。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_remaining_api_coverage.py::test_group_fetch_members_info_invalid_limit

### 253. inviteNeedConfirm=false 时，即使 B 关闭自动接受，也应由服务端直接加入

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. B 关闭自动接受群邀请
  2. 验证自动接受群邀请设置已更新
  3. 测试准备：创建测试群并建立业务前置
  4. A 添加群成员
  5. 验证 添加群成员返回的关键字段
  6. 等待并校验目标业务事件
  7. 测试后置：销毁测试群并恢复群状态
  8. 测试后置：恢复 B 的自动接受群邀请设置
  重点验证接口：Client.updateAutoAcceptGroupInvitationSetting、GroupManager.addMembers。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_direct_invite_ignores_auto_accept_disabled_when_confirmation_not_required

### 254. inviter user 成功

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 邀请成员
  3. 验证邀请成员返回的响应 result 与关键字段
  4. 等待并校验目标业务事件
  5. A 查询服务端群详情
  6. 验证查询服务端群详情返回的关键字段
  7. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.inviterUser、GroupManager.getGroupSpecificationFromServer。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_inviter.py::test_group_inviter_user_success

### 255. inviter user 空 成员

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 邀请成员
  3. 验证邀请成员返回的响应 result 与关键字段
  4. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.inviterUser。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_inviter.py::test_group_inviter_user_empty_members

### 256. inviter user nonexistent group

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 邀请成员
  2. 验证邀请成员返回的错误码与错误文案
  重点验证接口：GroupManager.inviterUser。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_inviter.py::test_group_inviter_user_nonexistent_group

### 257. inviter user nonexistent user

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 邀请成员
  3. 验证邀请成员返回的错误码与错误文案
  4. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.inviterUser。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_inviter.py::test_group_inviter_user_nonexistent_user

### 258. is 成员 in white list and mute list 成功

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 查询白名单成员状态
  3. 验证查询白名单成员状态返回的关键字段
  4. A 执行群组业务操作
  5. 验证执行群组业务操作返回的响应 result 与关键字段
  6. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.isMemberInWhiteListFromServer、GroupManager.isMemberInGroupMuteList。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_membership_checks.py::test_group_is_member_in_white_list_and_mute_list_success

### 259. is 成员 in white list and mute list nonexistent group

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. A 执行群组业务操作
  2. 验证执行群组业务操作返回的错误码与错误文案
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_membership_checks.py::test_group_is_member_in_white_list_and_mute_list_nonexistent_group

### 260. joinPublicGroup 拒绝私有群（style 0/1，603）；public-approval(style=2)/public-open(style=3) 5.0 允许加入（公开群）（参数：private-成员）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. B 加入公开群
  3. 验证加入公开群返回的错误码与错误文案
  4. 验证加入公开群返回的关键字段
  5. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.joinPublicGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_join_public_group_rejects_every_non_open_style[private-member]

### 261. joinPublicGroup 拒绝私有群（style 0/1，603）；public-approval(style=2)/public-open(style=3) 5.0 允许加入（公开群）（参数：private-owner）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. B 加入公开群
  3. 验证加入公开群返回的错误码与错误文案
  4. 验证加入公开群返回的关键字段
  5. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.joinPublicGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_join_public_group_rejects_every_non_open_style[private-owner]

### 262. leave group non 成员

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. B 退出群
  2. 验证退出群返回的错误码与错误文案
  重点验证接口：GroupManager.leaveGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_members.py::test_group_leave_group_non_member

### 263. maxCount=2 的公开自由群已包含 A+B 时，C 不得加入

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. B 加入公开群
  3. 验证加入公开群返回的错误码与错误文案
  4. 验证加入公开群返回的关键字段
  5. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.joinPublicGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_public_open_join_rejects_when_group_is_full

### 264. moderation nonexistent group errors（参数：addWhiteList-info4-600-do not find this group）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 执行群组业务操作
  2. 验证执行群组业务操作返回的错误码与错误文案
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_moderation.py::test_group_moderation_nonexistent_group_errors[addWhiteList-info4-600-do not find this group]

### 265. moderation nonexistent group errors（参数：muteAllMembers-info2-600-do not find this group）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 执行群组业务操作
  2. 验证执行群组业务操作返回的错误码与错误文案
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_moderation.py::test_group_moderation_nonexistent_group_errors[muteAllMembers-info2-600-do not find this group]

### 266. moderation nonexistent group errors（参数：muteMembers-info0-600-do not find this group）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 执行群组业务操作
  2. 验证执行群组业务操作返回的错误码与错误文案
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_moderation.py::test_group_moderation_nonexistent_group_errors[muteMembers-info0-600-do not find this group]

### 267. moderation nonexistent group errors（参数：removeWhiteList-info5-600-do not find this group）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 执行群组业务操作
  2. 验证执行群组业务操作返回的错误码与错误文案
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_moderation.py::test_group_moderation_nonexistent_group_errors[removeWhiteList-info5-600-do not find this group]

### 268. moderation nonexistent group errors（参数：unMuteAllMembers-info3-600-do not find this group）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 执行群组业务操作
  2. 验证执行群组业务操作返回的错误码与错误文案
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_moderation.py::test_group_moderation_nonexistent_group_errors[unMuteAllMembers-info3-600-do not find this group]

### 269. moderation nonexistent group errors（参数：unMuteMembers-info1-600-do not find this group）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 执行群组业务操作
  2. 验证执行群组业务操作返回的错误码与错误文案
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_moderation.py::test_group_moderation_nonexistent_group_errors[unMuteMembers-info1-600-do not find this group]

### 270. moderation nonexistent group errors（参数：updateGroupExt-info6-600-do not find this group）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 执行群组业务操作
  2. 验证执行群组业务操作返回的错误码与错误文案
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_moderation.py::test_group_moderation_nonexistent_group_errors[updateGroupExt-info6-600-do not find this group]

### 271. request to join public group nonexistent group

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. B 申请加入公开群
  2. 验证申请加入公开群返回的错误码与错误文案
  重点验证接口：GroupManager.requestToJoinPublicGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_join_requests_and_invitations.py::test_group_request_to_join_public_group_nonexistent_group

### 272. set 成员 属性 空 属性

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 执行群组业务操作
  3. 验证执行群组业务操作返回的错误码与错误文案
  4. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.setMemberAttributesFromGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_member_attributes.py::test_group_set_member_attributes_empty_attributes

### 273. set 成员 属性 nonexistent group

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 执行群组业务操作
  2. 验证执行群组业务操作返回的响应 result 与关键字段
  重点验证接口：GroupManager.setMemberAttributesFromGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_member_attributes.py::test_group_set_member_attributes_nonexistent_group

### 274. set and 获取 成员 属性 成功

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. B 执行群组业务操作
  3. 验证执行群组业务操作返回的响应 result 与关键字段
  4. 等待并校验目标业务事件
  5. A 执行群组业务操作
  6. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.setMemberAttributesFromGroup、GroupManager.fetchMemberAttributesFromGroup、GroupManager.fetchMembersAttributesFromGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_member_attributes.py::test_group_set_and_fetch_member_attributes_success

### 275. style=0 仅群主可邀请；style=1 的普通成员和管理员均可邀请（参数：添加-成员-private-成员-admin-allowed）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。原测试目标：style=0 仅群主可邀请；style=1 的普通成员和管理员均可邀请。
- 状态/版本说明：跳过：pending contract confirmation: style 0 admin can invite
- 源码：native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_member_invitation_permission_depends_on_style[add-members-private-member-admin-allowed]

### 276. style=0 仅群主可邀请；style=1 的普通成员和管理员均可邀请（参数：添加-成员-private-成员-normal-成员-allowed）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。原测试目标：style=0 仅群主可邀请；style=1 的普通成员和管理员均可邀请。
- 状态/版本说明：跳过：pending contract confirmation: style 0 admin can invite
- 源码：native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_member_invitation_permission_depends_on_style[add-members-private-member-normal-member-allowed]

### 277. style=0 仅群主可邀请；style=1 的普通成员和管理员均可邀请（参数：添加-成员-private-owner-admin-denied）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。原测试目标：style=0 仅群主可邀请；style=1 的普通成员和管理员均可邀请。
- 状态/版本说明：跳过：pending contract confirmation: style 0 admin can invite
- 源码：native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_member_invitation_permission_depends_on_style[add-members-private-owner-admin-denied]

### 278. style=0 仅群主可邀请；style=1 的普通成员和管理员均可邀请（参数：添加-成员-private-owner-normal-成员-denied）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。原测试目标：style=0 仅群主可邀请；style=1 的普通成员和管理员均可邀请。
- 状态/版本说明：跳过：pending contract confirmation: style 0 admin can invite
- 源码：native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_member_invitation_permission_depends_on_style[add-members-private-owner-normal-member-denied]

### 279. style=0 仅群主可邀请；style=1 的普通成员和管理员均可邀请（参数：inviter-user-private-成员-admin-allowed）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。原测试目标：style=0 仅群主可邀请；style=1 的普通成员和管理员均可邀请。
- 状态/版本说明：跳过：pending contract confirmation: style 0 admin can invite
- 源码：native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_member_invitation_permission_depends_on_style[inviter-user-private-member-admin-allowed]

### 280. style=0 仅群主可邀请；style=1 的普通成员和管理员均可邀请（参数：inviter-user-private-成员-normal-成员-allowed）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。原测试目标：style=0 仅群主可邀请；style=1 的普通成员和管理员均可邀请。
- 状态/版本说明：跳过：pending contract confirmation: style 0 admin can invite
- 源码：native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_member_invitation_permission_depends_on_style[inviter-user-private-member-normal-member-allowed]

### 281. style=0 仅群主可邀请；style=1 的普通成员和管理员均可邀请（参数：inviter-user-private-owner-admin-denied）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。原测试目标：style=0 仅群主可邀请；style=1 的普通成员和管理员均可邀请。
- 状态/版本说明：跳过：pending contract confirmation: style 0 admin can invite
- 源码：native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_member_invitation_permission_depends_on_style[inviter-user-private-owner-admin-denied]

### 282. style=0 仅群主可邀请；style=1 的普通成员和管理员均可邀请（参数：inviter-user-private-owner-normal-成员-denied）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。原测试目标：style=0 仅群主可邀请；style=1 的普通成员和管理员均可邀请。
- 状态/版本说明：跳过：pending contract confirmation: style 0 admin can invite
- 源码：native-auto-test/tests/group/test_group_style_membership_matrix.py::test_group_member_invitation_permission_depends_on_style[inviter-user-private-owner-normal-member-denied]

### 283. unblock idempotent

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 取消屏蔽群消息
  3. 验证取消屏蔽群消息返回的关键字段
  4. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.unblockGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_blocking.py::test_group_unblock_idempotent

### 284. unblock nonexistent group

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 取消屏蔽群消息
  2. 验证取消屏蔽群消息返回的错误码与错误文案
  重点验证接口：GroupManager.unblockGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_blocking.py::test_group_unblock_nonexistent_group

### 285. update announcement 空

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 更新群公告
  3. 验证更新群公告返回的关键字段
  4. A 查询群公告
  5. 验证查询群公告返回的关键字段
  6. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.updateGroupAnnouncement、GroupManager.getGroupAnnouncementFromServer。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_announcement.py::test_group_update_announcement_empty

### 286. update announcement nonexistent group

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 更新群公告
  2. 验证更新群公告返回的错误码与错误文案
  重点验证接口：GroupManager.updateGroupAnnouncement。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_announcement.py::test_group_update_announcement_nonexistent_group

### 287. update avatar abnormal values

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 更新群头像
  3. 验证更新群头像返回的关键字段
  4. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.updateGroupAvatar。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_remaining_api_coverage.py::test_group_update_avatar_abnormal_values[]

### 288. update avatar abnormal values（参数：https://example.com/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 更新群头像
  3. 验证更新群头像返回的关键字段
  4. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.updateGroupAvatar。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_remaining_api_coverage.py::test_group_update_avatar_abnormal_values[https://example.com/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa]

### 289. update description 空

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 执行群组业务操作
  3. 验证执行群组业务操作返回的响应 result 与关键字段
  4. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.updateDescription。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_metadata.py::test_group_update_description_empty

### 290. update description nonexistent group

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 执行群组业务操作
  2. 验证执行群组业务操作返回的错误码与错误文案
  重点验证接口：GroupManager.updateDescription。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_metadata.py::test_group_update_description_nonexistent_group

### 291. update description too long

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 执行群组业务操作
  3. 验证执行群组业务操作返回的响应 result 与关键字段
  4. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.updateDescription。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_metadata.py::test_group_update_description_too_long

### 292. update group ext 成功

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 更新群扩展信息
  3. 验证更新群扩展信息返回的关键字段
  4. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.updateGroupExt。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_moderation.py::test_group_update_group_ext_success

### 293. update owner nonexistent group

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 转让群主
  2. 验证转让群主返回的错误码与错误文案
  重点验证接口：GroupManager.updateGroupOwner。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_roles.py::test_group_update_owner_nonexistent_group

### 294. update subject 空

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 更新群名称
  3. 验证更新群名称返回的关键字段
  4. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.updateGroupSubject。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_metadata.py::test_group_update_subject_empty

### 295. update subject nonexistent group

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 更新群名称
  2. 验证更新群名称返回的错误码与错误文案
  重点验证接口：GroupManager.updateGroupSubject。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_metadata.py::test_group_update_subject_nonexistent_group

### 296. update subject too long

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 更新群名称
  3. 验证更新群名称返回的关键字段
  4. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.updateGroupSubject。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_exceptions_metadata.py::test_group_update_subject_too_long

### 297. updateGroupAvatar：群主更新群头像 URL，返回群对象中 avatarUrl 为新值

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 测试准备：创建测试群并建立业务前置
  2. A 更新群头像
  3. 验证更新群头像返回的关键字段
  4. 测试后置：销毁测试群并恢复群状态
  重点验证接口：GroupManager.updateGroupAvatar。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_remaining_api_coverage.py::test_group_update_avatar_success

### 298. updateGroupAvatar：groupId 为空字符串时，冻结真实错误返回

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 更新群头像
  2. 验证群业务状态、事件与关键字段
  重点验证接口：GroupManager.updateGroupAvatar。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/group/test_group_remaining_api_coverage.py::test_group_update_avatar_empty_group_id

## Phase1

### 1. 同账号多端：A 修改服务端属性，A 全部在线端最终读取到同一结果

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. A 更新用户昵称并验证请求成功
  2. A 全部在线端查询用户资料并验证昵称同步
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：UserInfoManager.updateOwnUserInfo、UserInfoManager.fetchOwnInfo。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/phase1/test_device_topologies.py::test_same_account_second_device_sees_user_info_update

### 2. 组合拓扑：B 发给 A，A 的全部在线端都收到同一条消息

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 测试准备：清理相关设备的历史事件
  2. B 向 A 发送文本消息并验证发送成功
  3. A 全部在线端分别接收消息并验证 消息 ID 一致
  4. A 主端和副端分别接收消息并验证 消息 ID 一致
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：ChatManager.sendMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/phase1/test_device_topologies.py::test_third_party_message_reaches_both_same_account_devices

### 3. 离线 消息 sync keeps case event cursor

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 测试准备：清理收发设备历史事件
  2. A 断开网络并验证进入离线状态
  3. B 向离线的 A 发送文本消息并验证发送成功
  4. A 恢复网络并验证重新连接
  5. A 恢复后接收离线消息并验证消息内容
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：ChatManager.sendMessage。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/phase1/test_offline_sync.py::test_offline_message_sync_keeps_case_event_cursor

### 4. 同一 case：4.10 在调用前 Skip，4.14 调用真实新增 API 并成功

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 确认设备支持成员详情能力并创建测试群
  2. 查询群成员详情并验证分页结果结构
  3. 测试后置：销毁能力验证测试群
  重点验证接口：GroupManager.createGroup、GroupManager.fetchGroupMembersInfo、GroupManager.destroyGroup。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/phase1/test_version_capability.py::test_fetch_group_members_info_version_capability

### 5. Android 4.23 → 5.0 覆盖安装（同 application_id）：验证升级后消息数据保留

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 执行 4.23 到 5.0 覆盖升级并验证消息数据保留
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/phase1/test_upgrade_423_to_500.py::test_message_data_after_423_to_500_upgrade

## Presence

### 1. 多端拓扑：A 发布 presence（动作端）；B 订阅 A，订阅关系为账号级 → B 全部在线端查询订阅列表一致； B 取消订阅后全部端查询为空

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 测试准备：清理收发账号全部端的历史事件
  2. 发布在线状态 在线
  3. 确认发布请求已提交
  4. A 全部在线端查询自己的状态均为 在线（账号级服务端状态同步）
  5. 订阅 A 的在线状态
  6. 确认订阅请求已提交且返回 A 当前状态
  7. B 全部在线端查询订阅列表均含 A（订阅关系账号级共享）
  8. 取消订阅 A
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：PresenceManager.presenceWithDescription、PresenceManager.fetchPresenceStatus、PresenceManager.presenceSubscribe、PresenceManager.fetchSubscribedMembersWithPageNum、PresenceManager.presenceUnsubscribe。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/presence/test_presence.py::test_presence_publish_subscribe_query_unsubscribe

### 2. 多端拓扑：A 发布空 desc 在线状态；A 全部端查询状态 desc 为空；B 订阅后，B 全部端查询 A 状态 desc 也为空

- 类型：多设备
- 前置：相关账号的在线设备集合已启动并登录；用例拓扑关系已准备。
- 步骤及测试点：
  1. 测试准备：清理收发账号全部端的历史事件
  2. 发布空 desc 的在线状态
  3. 确认发布请求已提交
  4. A 全部在线端查询自己的状态 desc 均为空（账号级服务端状态同步）
  5. 订阅 A 的在线状态
  6. 确认订阅请求已提交
  7. B 全部在线端查询 A 状态 desc 均为空
  验证在线设备集合中的目标设备是否均收到一致结果。
  重点验证接口：PresenceManager.presenceWithDescription、PresenceManager.fetchPresenceStatus、PresenceManager.presenceSubscribe。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/presence/test_presence.py::test_presence_publish_empty_desc_then_fetch

### 3. 订阅不存在用户：B 对不存在用户发起 presenceSubscribe

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 订阅不存在用户并验证当前服务端返回语义
  重点验证接口：PresenceManager.presenceSubscribe。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/presence/test_presence.py::test_presence_subscribe_nonexistent_user

### 4. 订阅超过 100 个用户：presenceSubscribe 传入超过 100 个 成员，预期返回错误

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 订阅超过数量上限的用户并验证数量错误
  重点验证接口：PresenceManager.presenceSubscribe。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/presence/test_presence.py::test_presence_subscribe_over_100_members

### 5. 订阅存在用户但过期时间大于 30 天：B 订阅 A，expiry 设为超过 30 天，预期返回错误

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 发布在线状态作为订阅前置
  2. B 使用超过 30 天的有效期订阅并验证边界错误
  重点验证接口：PresenceManager.presenceWithDescription、PresenceManager.presenceSubscribe。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/presence/test_presence.py::test_presence_subscribe_expiry_over_30_days

### 6. 非法分页参数：pageNum=0 或 pageSize=0，预期返回错误

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 使用 pageNum=0 查询订阅列表并验证边界语义
  2. 使用 pageSize=0 查询订阅列表并验证边界错误
  重点验证接口：PresenceManager.fetchSubscribedMembersWithPageNum。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/presence/test_presence.py::test_fetch_subscribed_members_invalid_pagination

### 7. 分页 pageSize=1：第 1 页 1 条，第 2 页 0 条

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 创建在线状态并建立订阅前置
  2. 按 pageSize=1 查询第一页并验证包含 A
  3. 按 pageSize=1 查询第二页并验证为空
  重点验证接口：PresenceManager.presenceWithDescription、PresenceManager.presenceSubscribe、PresenceManager.fetchSubscribedMembersWithPageNum。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/presence/test_presence.py::test_fetch_subscribed_members_pagination_page_size_one

### 8. 分页查询订阅列表：B 订阅 A 后，第 1 页有数据，第 2 页为空

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 创建在线状态并建立订阅前置
  2. 查询第一页订阅列表并验证包含 A
  3. 查询第二页订阅列表并验证为空
  重点验证接口：PresenceManager.presenceWithDescription、PresenceManager.presenceSubscribe、PresenceManager.fetchSubscribedMembersWithPageNum。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/presence/test_presence.py::test_fetch_subscribed_members_pagination

### 9. 取消订阅超过 100 个用户：presenceUnsubscribe 传入超过 100 个 成员，预期返回错误

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 取消超过数量上限的订阅并验证数量错误
  重点验证接口：PresenceManager.presenceUnsubscribe。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/presence/test_presence.py::test_presence_unsubscribe_over_100_members

### 10. A 发布 128KB 大小 desc 的在线状态

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. A 发布超长在线状态描述并验证长度错误
  重点验证接口：PresenceManager.presenceWithDescription。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/presence/test_presence.py::test_presence_publish_128k_desc

## Push

### 1. set/获取/删除会话列表ilentMode：对单聊会话设置、查询、移除离线推送设置

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 设置单聊会话免打扰并验证成功
  2. 查询单聊会话免打扰设置并验证配置
  3. 批量查询会话免打扰设置并验证目标会话
  4. 移除单聊会话免打扰设置并验证成功
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：PushManager.setConversationSilentMode、PushManager.fetchConversationSilentMode、PushManager.fetchSilentModeForConversations、PushManager.removeConversationSilentMode。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/push/test_push_remaining_api_coverage.py::test_push_conversation_silent_mode_flow

### 2. setSilentModeForAll / fetchSilentModeForAll：设置全局离线推送提醒类型，并拉取全局设置

- 类型：离线
- 前置：发送方在线；目标设备按用例要求离线；账号和基础关系已准备。
- 步骤及测试点：
  1. 设置全局离线推送提醒类型并验证成功
  2. 查询全局离线推送设置并验证配置字段
  验证目标设备重新上线后的补同步、本地数据和事件结果。
  重点验证接口：PushManager.setSilentModeForAll、PushManager.fetchSilentModeForAll。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/push/test_push_remaining_api_coverage.py::test_push_global_silent_mode_flow

### 3. fetchPushConfigsFromServer / updatePushNickname / updatePushDisplayStyle：拉取推送配置并更新昵称和展示样式

- 类型：普通
- 前置：测试账号已登录；服务端所需数据或权限已准备。
- 步骤及测试点：
  1. 查询服务端推送配置并验证返回结构
  2. 更新推送昵称并验证配置更新结果
  3. 更新推送展示样式并验证配置更新结果
  重点验证接口：PushManager.getImPushConfigFromServer、PushManager.updatePushNickname、PushManager.updateImPushStyle。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/push/test_push_remaining_api_coverage.py::test_push_fetch_configs_update_nickname_and_style

### 4. set/fetchPreferredNotification语言 与 set/getPushTemplate：设置并查询推送语言和模板名称

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 设置首选通知语言并验证保存成功
  2. 查询首选通知语言并验证为英语
  3. 设置推送模板并验证保存成功
  4. 查询推送模板并验证模板名称
  重点验证接口：PushManager.setPreferredNotificationLanguage、PushManager.fetchPreferredNotificationLanguage、PushManager.setPushTemplate、PushManager.getPushTemplate。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/push/test_push_remaining_api_coverage.py::test_push_preferred_language_and_template

### 5. syncSilentModels：同步所有会话免打扰信息，冻结当前模拟器返回语义

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。原测试目标：syncSilentModels：同步所有会话免打扰信息，冻结当前模拟器返回语义。
- 状态/版本说明：平台不适用：当前平台或模拟器不具备该能力
- 源码：native-auto-test/tests/push/test_push_remaining_api_coverage.py::test_push_sync_conversations_silent_mode_current_environment

### 6. update*PushToken / bindDeviceToken：使用测试 token 调用，冻结当前模拟器环境下的真实返回语义（参数：bindDeviceToken-info2-None）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 更新厂商推送令牌并验证当前环境返回语义
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/push/test_push_remaining_api_coverage.py::test_push_vendor_token_update_current_environment[bindDeviceToken-info2-None]

### 7. update*PushToken / bindDeviceToken：使用测试 token 调用，冻结当前模拟器环境下的真实返回语义（参数：updateFCMPushToken-info1-expected_result1）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 更新厂商推送令牌并验证当前环境返回语义
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/push/test_push_remaining_api_coverage.py::test_push_vendor_token_update_current_environment[updateFCMPushToken-info1-expected_result1]

### 8. update*PushToken / bindDeviceToken：使用测试 token 调用，冻结当前模拟器环境下的真实返回语义（参数：updateHMSPushToken-info0-hms-token-api-coverage）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 更新厂商推送令牌并验证当前环境返回语义
  重点验证接口返回结果、关键业务字段和相关事件。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/push/test_push_remaining_api_coverage.py::test_push_vendor_token_update_current_environment[updateHMSPushToken-info0-hms-token-api-coverage]

### 9. updateAPNsPushToken：Android 模拟器不适用 APNs，缺失Plugin 记录为平台/桥接缺口

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  不执行原 Case；记录原因并确认替代验证方式。原测试目标：updateAPNsPushToken：Android 模拟器不适用 APNs，MissingPlugin 记录为平台/桥接缺口。
- 状态/版本说明：平台不适用：当前平台或模拟器不具备该能力
- 源码：native-auto-test/tests/push/test_push_remaining_api_coverage.py::test_push_apns_token_update_android_missing_plugin

## UserInfo

### 1. 先 updateOwnUserInfo，再用 fetchUserInfoById 拉当前用户（全量字段，与 fetchOwnInfo 语义等价）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 设置用于查询验证的用户资料
  2. 按用户 ID 查询资料并验证全部字段
  重点验证接口：UserInfoManager.updateOwnUserInfo、UserInfoManager.fetchUserInfoById。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/user_info/test_user_info.py::test_user_info_update_then_fetch_user_info_by_id

### 2. 先 updateOwnUserInfo，再用 fetchUserInfoByIdWithType 按类型拉取（仅 nick + sign；按类型返回时未必含 mail）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 设置按类型查询所需的用户资料
  2. 按资料类型查询用户并验证昵称和签名
  重点验证接口：UserInfoManager.updateOwnUserInfo、UserInfoManager.fetchUserInfoByIdWithType。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/user_info/test_user_info.py::test_user_info_update_then_fetch_user_info_by_id_with_type

### 3. 一次更新后：先 fetchUserInfoById（全量），再 fetchUserInfoByIdWithType（nick+sign），字段一致

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 设置统一的用户资料用于多接口查询
  2. 按用户 ID 查询全量资料并验证字段
  3. 按资料类型查询并验证部分字段一致
  重点验证接口：UserInfoManager.updateOwnUserInfo、UserInfoManager.fetchUserInfoById、UserInfoManager.fetchUserInfoByIdWithType。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/user_info/test_user_info.py::test_user_info_update_then_all_fetch_paths_in_one_flow

### 4. fetchOwnInfo：更新当前用户属性后拉取自己的用户属性

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 设置用于查询的当前用户资料
  2. 查询当前用户资料并验证属性
  重点验证接口：UserInfoManager.updateOwnUserInfo、UserInfoManager.fetchOwnInfo。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/user_info/test_user_info.py::test_user_info_update_then_fetch_own_info

### 5. fetchUserInfoById：获取指定用户（当前用户与另一用户）的属性

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 查询两个用户的资料并验证用户标识
  重点验证接口：UserInfoManager.fetchUserInfoById。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/user_info/test_user_info.py::test_user_info_fetch_by_id_normal

### 6. fetchUserInfoById：userIds 超过 100 个，预期失败

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 使用超过上限的用户列表查询资料并验证数量错误
  重点验证接口：UserInfoManager.fetchUserInfoById。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/user_info/test_user_info.py::test_user_info_fetch_by_id_user_ids_over_100

### 7. fetchUserInfoById：userIds 为空列表

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 使用空用户列表查询资料并验证参数错误
  重点验证接口：UserInfoManager.fetchUserInfoById。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/user_info/test_user_info.py::test_user_info_fetch_by_id_empty_user_ids

### 8. fetchUserInfoByIdWithType：按属性类型拉取指定用户（nick + sign）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 按昵称和签名类型查询用户资料
  重点验证接口：UserInfoManager.fetchUserInfoByIdWithType。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/user_info/test_user_info.py::test_user_info_fetch_by_id_with_type_normal

### 9. updateOwnUserInfo：昵称超过 2k长度，预期失败

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 提交超长昵称并验证长度错误
  重点验证接口：UserInfoManager.updateOwnUserInfo。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/user_info/test_user_info.py::test_user_info_update_own_nickname_length_over_64

### 10. updateOwnUserInfo：昵称为空

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 提交空昵称并验证空值处理结果
  重点验证接口：UserInfoManager.updateOwnUserInfo。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/user_info/test_user_info.py::test_user_info_update_own_nickname_empty

### 11. updateOwnUserInfo：先设置再修改当前用户属性

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 设置当前用户昵称、签名和性别并验证结果
  2. 修改当前用户昵称和签名并验证更新结果
  重点验证接口：UserInfoManager.updateOwnUserInfo。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/user_info/test_user_info.py::test_user_info_update_own_set_and_modify

### 12. updateOwnUserInfoWithType：按类型更新昵称（0 = NICKNAME）

- 类型：普通
- 前置：测试账号已登录；用例所需的基础数据已准备。
- 步骤及测试点：
  1. 按昵称类型更新当前用户昵称并验证结果
  重点验证接口：UserInfoManager.updateOwnUserInfoWithType。
- 状态/版本说明：正常执行
- 源码：native-auto-test/tests/user_info/test_user_info.py::test_user_info_update_own_with_type_nickname
