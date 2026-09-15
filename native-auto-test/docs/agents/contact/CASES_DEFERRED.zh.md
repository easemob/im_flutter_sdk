# Contact 模块 Cases 暂缓清单（按 API）

> 当前变更：显式 skip / xfail 业务用例已按用户要求删除，准确函数/参数清单见同目录 `CASES_RECORD.zh.md` 的“已删除的 skip / xfail 用例”节。下方涉及这些场景的旧 skip/xfail 和“移除标记恢复”描述仅为历史原因；恢复需重新实现与验收，不能直接去掉标记。其他运行时条件跳过和未实现能力不在本次删除范围。

— 说明
- 本文件仅记录 Contact 模块暂缓项。
- MissingPluginException 统一记录为桥接/平台通道缺口，不作为 SDK API 正常业务预期。

## 暂缓项
- `tests/contact/test_contact.py::test_contact_fetch_all_contact_ids_bridge_missing`
  - API：`fetchAllContactIds`
  - 原因：当前原生通道未实现 direct cmd，实测返回 `MissingPluginException`；该结果属于桥接缺口，不作为 SDK 成功语义。
  - 恢复条件：桥接补齐后按真实返回重新 discovery 并改为 strict 断言。
- `tests/contact/test_contact.py::test_contact_get_all_contact_ids_bridge_missing`
  - API：`getAllContactIds`
  - 原因：当前原生通道未实现 direct cmd，实测返回 `MissingPluginException`；本地 ID 成功语义已由 `getAllContactsFromDB` 覆盖。
  - 恢复条件：桥接补齐后按真实返回重新 discovery 并改为 strict 断言。
- `tests/contact/test_friend_info_sync.py::test_friend_info_auto_sync_after_login` 【对应已删除函数的历史记录】
  - API/事件：`onFriendStartSync` / `onFriendSyncFinished`
  - 原因：当前实测重新登录后未稳定派发好友信息同步开始/结束回调。
  - 恢复条件：SDK/服务端确认并稳定派发后，去掉 xfail 并按真实事件体 strict 断言。
