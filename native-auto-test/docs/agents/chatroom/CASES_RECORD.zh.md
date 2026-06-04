# ChatRoom 模块 Cases 总记录（按 API）

— 说明
- 本文件记录 ChatRoom 模块已覆盖用例（按 API 组织）。
- 每条 case 以全局序号编号；统计按“当前记录条目数”计算。
- 暂缓与 skip 项统一写 `CASES_DEFERRED.zh.md`。

## createChatRoom

正常 cases
1. `tests/chatroom/test_chatroom_lifecycle.py::test_chatroom_create_and_fetch_from_server`
   使用 REST 创建聊天室后，SDK 拉取详情，校验 `roomId/owner/name/maxUsers/memberCount` 等核心字段。

异常 cases
2. 暂无。

## joinChatRoom

正常 cases
3. `tests/chatroom/test_chatroom_members.py::test_chatroom_join_public_chatroom_success`
   B 加入公开聊天室，校验同步成功响应与 `onMemberJoinedFromChatRoom` 回调关键字段。
4. `tests/chatroom/test_chatroom_exceptions.py::test_chatroom_join_room_nonexistent_current_behavior`
   当前实测：传入随机不存在 roomId 仍返回成功 `result=1`，先按现网行为冻结（待产品语义确认）。

异常 cases
5. `tests/chatroom/test_chatroom_exceptions.py::test_chatroom_join_room_empty_id`
   roomId 为空字符串，冻结错误语义：`code=700`，`description` 包含 `Chat room ID is invalid`。

## fetchPublicChatRoomsFromServer

正常 cases
6. `tests/chatroom/test_chatroom_server_state.py::test_chatroom_fetch_public_chat_rooms_from_server_success`
   拉取公开聊天室列表，校验返回结构 `result.count/result.list`。

异常 cases
7. `tests/chatroom/test_chatroom_exceptions.py::test_chatroom_fetch_public_chat_rooms_invalid_paging[0-1]`
   `pageNum=0`，当前行为为成功返回公开列表结构，校验 `count>=0` 与列表条目关键字段集合。
8. `tests/chatroom/test_chatroom_exceptions.py::test_chatroom_fetch_public_chat_rooms_invalid_paging[-1-1]`
   `pageNum=-1`，当前行为为成功返回公开列表结构，校验同上。
9. `tests/chatroom/test_chatroom_exceptions.py::test_chatroom_fetch_public_chat_rooms_invalid_paging[1-0]`
   `pageSize=0`，当前行为为成功返回公开列表结构，校验同上。
10. `tests/chatroom/test_chatroom_exceptions.py::test_chatroom_fetch_public_chat_rooms_invalid_paging[1--1]`
    `pageSize=-1`，当前行为为成功返回公开列表结构，校验同上。

## fetchChatRoomInfoFromServer

正常 cases
11. `tests/chatroom/test_chatroom_lifecycle.py::test_chatroom_create_and_fetch_from_server`
    创建后立即查询详情，校验返回与创建结果一致。

异常 cases
12. `tests/chatroom/test_chatroom_exceptions.py::test_chatroom_fetch_room_info_nonexistent`
    查询随机不存在 roomId，冻结错误语义：`code=700`，`description` 包含 `do not find this group`。
13. `tests/chatroom/test_chatroom_exceptions.py::test_chatroom_fetch_room_info_empty_id`
    roomId 为空字符串，冻结错误语义：`code=700`，`description` 包含 `Chat room ID is invalid`。

## destroyChatRoom

正常 cases
14. `tests/chatroom/test_chatroom_lifecycle.py::test_chatroom_destroy_room_success`
    删除 REST 创建的聊天室，校验销毁成功响应。

异常 cases
15. `tests/chatroom/test_chatroom_exceptions.py::test_chatroom_destroy_room_nonexistent`
    删除随机不存在 roomId，冻结错误语义：`code=700`，`description` 包含 `do not find this group`。
16. `tests/chatroom/test_chatroom_exceptions.py::test_chatroom_destroy_room_empty_id`
    roomId 为空字符串，冻结错误语义：`code=700`，`description` 包含 `Chat room ID is invalid`。

## 当前统计

- 总计：16 条（其中参数化 4 条分别独立统计）
- 可稳定执行并通过：14 条可执行测试（`pytest -q tests/chatroom -s` 实测 `14 passed`）
