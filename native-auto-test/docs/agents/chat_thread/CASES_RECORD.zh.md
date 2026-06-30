# ChatThread 模块 Cases 总记录（按 API）

— 说明
- 本文件记录 ChatThread 模块已覆盖用例（按 API 组织）。
- 每条 case 以全局序号编号；统计按“当前记录条目数”计算。
- 暂缓与 skip 项统一写 `CASES_DEFERRED.zh.md`。

## createChatThread / joinChatThread / removeMemberFromChatThread / destroyChatThread

正常 cases
1. `tests/chat/test_chat_s4_thread_user_removed.py::test_chat_thread_user_removed_event_type_not_null`
   A 建群并基于群父消息创建子区，B 加入后 A 将 B 移出，校验 `onUserKickOutOfChatThread` 回调的 `event.type` 非空，最后销毁子区。

异常 cases
2. 无（当前发版修复场景聚焦事件字段，不单独覆盖非法入参）。

## fetchChatThreadDetail / getThreadConversation / fetchJoinedChatThreads / fetchChatThreadsWithParentId / fetchJoinedChatThreadsWithParentId

正常 cases
3. `tests/chat/test_chat_thread_remaining_api_coverage.py::test_chat_thread_fetch_detail_and_lists`
   创建并加入子区后，拉取子区详情、`ChatManager.getThreadConversation` 线程会话、当前用户已加入子区列表、指定群子区列表、指定群已加入子区列表，校验返回中包含目标 `threadId`，并冻结线程会话 `type=1/isThread=true`。

异常 cases
4. 无（本批按方法级正常链路覆盖；非法 threadId/parentId 后续作为边界专项补充）。

## fetchChatThreadMember / fetchLastMessageWithChatThreads

正常 cases
5. `tests/chat/test_chat_thread_remaining_api_coverage.py::test_chat_thread_fetch_members_and_latest_message`
   创建并加入子区后，拉取子区成员列表并校验包含 A/B；随后调用 `fetchLastMessageWithChatThreads`，冻结新建子区未发送线程内消息时返回空映射 `{}` 的实测语义。

异常 cases
6. 无（本批按方法级正常链路覆盖；非法 threadId 后续作为边界专项补充）。

## updateChatThreadSubject / leaveChatThread

正常 cases
7. `tests/chat/test_chat_thread_remaining_api_coverage.py::test_chat_thread_update_name_and_leave`
   创建并加入子区后，断言群成员收到 `onChatThreadCreate`；A 修改子区名称后断言群成员收到 `onChatThreadUpdate`，并通过详情确认新名称；B 退出子区后，再拉取指定群已加入子区列表确认目标 `threadId` 已消失。
8. `tests/chat/test_chat_thread_remaining_api_coverage.py::test_chat_thread_destroy_event_received_by_group_member`
   创建并加入子区后，A 解散子区，断言群成员收到 `onChatThreadDestroy`，并按真实模拟器返回冻结 `type/from/threadId/threadName/parentId/msgId/createAt` 等关键字段。

异常 cases
9. 无（本批按方法级正常链路覆盖；超长名称/非法 threadId 后续作为边界专项补充）。

## 统计
- 当前记录 case 条目总数：`9`
